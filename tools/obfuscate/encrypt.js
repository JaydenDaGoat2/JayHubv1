const fs = require('fs');
const luaparse = require('luaparse');
const luamin = require('luamin');

const srcPath = process.argv[2];
const outPath = process.argv[3];

const source = fs.readFileSync(srcPath, { encoding: 'binary' }); // 1 byte per char, matches x-user-defined

const ast = luaparse.parse(source, { scope: true, encodingMode: 'x-user-defined' });

// 1. Sanity: fail loudly instead of silently mis-handling bare-string call sugar ("foo \"x\"" / foo[[x]])
let hasStringCallExpr = false;
(function scanForStringCall(node) {
	if (node === null || typeof node !== 'object') return;
	if (Array.isArray(node)) { node.forEach(scanForStringCall); return; }
	if (node.type === 'StringCallExpression') hasStringCallExpr = true;
	for (const k in node) if (k !== 'type') scanForStringCall(node[k]);
})(ast);
if (hasStringCallExpr) {
	console.error('ABORT: found StringCallExpression (bare-string call sugar) - transform does not handle this, refusing to risk corrupting the file.');
	process.exit(1);
}

// 2. Walk and replace every StringLiteral node with a call to the decoder, collecting originals by value (dedup).
const strings = [];
const indexOf = new Map();
function internString(value) {
	if (indexOf.has(value)) return indexOf.get(value);
	strings.push(value);
	const idx = strings.length; // 1-based
	indexOf.set(value, idx);
	return idx;
}

const DECODE_NAME = '__JHubDecodeCall__';

function makeDecodeCall(idx) {
	return {
		type: 'CallExpression',
		base: { type: 'Identifier', name: DECODE_NAME, isLocal: true },
		arguments: [{ type: 'NumericLiteral', value: idx, raw: String(idx) }],
	};
}

function walk(node) {
	if (node === null || typeof node !== 'object') return node;
	if (Array.isArray(node)) {
		for (let i = 0; i < node.length; i++) {
			const child = node[i];
			if (child && typeof child === 'object' && child.type === 'StringLiteral') {
				node[i] = makeDecodeCall(internString(child.value));
			} else {
				walk(child);
			}
		}
		return node;
	}
	for (const k in node) {
		if (k === 'type') continue;
		const child = node[k];
		if (child && typeof child === 'object' && !Array.isArray(child) && child.type === 'StringLiteral') {
			node[k] = makeDecodeCall(internString(child.value));
		} else {
			walk(child);
		}
	}
	return node;
}

walk(ast.body);

console.error('Unique strings collected:', strings.length);

// 3. Build the cipher key + per-string ciphertexts, escaped as safe Lua string literals (always 3-digit \ddd for any
//    non-trivially-safe byte, so there is never ambiguity with a following literal digit).
function randomBytes(n) {
	const out = [];
	for (let i = 0; i < n; i++) out.push(Math.floor(Math.random() * 256));
	return out;
}
const KEY_BYTES = randomBytes(24);

function luaEscapeBytes(bytes) {
	let out = '';
	for (const b of bytes) {
		if (b >= 48 && b <= 57) { out += '\\' + String(b).padStart(3, '0'); continue; } // escape digits too, simplicity
		if (b === 34 || b === 92) { out += '\\' + String(b).padStart(3, '0'); continue; } // " and \
		if (b >= 33 && b <= 126) { out += String.fromCharCode(b); continue; } // safe printable ASCII
		out += '\\' + String(b).padStart(3, '0');
	}
	return out;
}

function xorBytes(str, key) {
	const out = [];
	for (let i = 0; i < str.length; i++) {
		out.push((str.charCodeAt(i) & 0xff) ^ key[i % key.length]);
	}
	return out;
}

const keyLit = luaEscapeBytes(KEY_BYTES);
const cipherLits = strings.map((s) => luaEscapeBytes(xorBytes(s, KEY_BYTES)));

const preambleSrc = [
	'local __JHubCipherKey__ = "' + keyLit + '"',
	'local __JHubCipherTable__ = {' + cipherLits.map((c) => '"' + c + '"').join(',') + '}',
	'local __JHubDecodeMemo__ = {}',
	'local function __JHubDecodeCall__(i)',
	'local v = __JHubDecodeMemo__[i]',
	'if v then return v end',
	'local s = __JHubCipherTable__[i]',
	'local kl = #__JHubCipherKey__',
	'local out = {}',
	'for j = 1, #s do',
	'out[j] = string.char(bit32.bxor(string.byte(s, j), string.byte(__JHubCipherKey__, (j - 1) % kl + 1)))',
	'end',
	'v = table.concat(out)',
	'__JHubDecodeMemo__[i] = v',
	'return v',
	'end',
].join('\n');

const preambleAst = luaparse.parse(preambleSrc, { scope: true, encodingMode: 'x-user-defined' });

// 4. Splice the preamble statements onto the front, keep the main ast's own globals list (preamble has none - all local).
ast.body = preambleAst.body.concat(ast.body);

// 5. Minify/rename via luamin, same pipeline as before.
const out = luamin.minify(ast);
fs.writeFileSync(outPath, out, { encoding: 'binary' });
console.error('Wrote', outPath, 'length', out.length);
