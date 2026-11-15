#!/usr/bin/env bash
# Builds the public (obfuscated, access-gated) loadstring file from the readable source,
# and refuses to produce output if either protection is missing or broken.
#
# Usage: tools/publish.sh [source_lua] [output_lua]
#   source_lua defaults to executor/JHubV1_Glass.lua on the CURRENT branch (should be the
#   dev branch, x86h7a, checked out) and output_lua defaults to /tmp/jhub_public_build.lua.
#
# This never touches git or pushes anything - it only builds and verifies a file. After it
# succeeds, copy output_lua over executor/JHubV1_Glass.lua on the wclom3 branch and push that.
#
# Every future version MUST go through this script before it reaches the public branch.
# If this script refuses, that's it telling you the file is not actually protected - fix
# the source, don't skip the check.

set -euo pipefail
cd "$(dirname "$0")/.."

SRC="${1:-executor/JHubV1_Glass.lua}"
OUT="${2:-/tmp/jhub_public_build.lua}"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "== JHub publish pipeline =="
echo "source: $SRC"

if [ ! -f "$SRC" ]; then
	echo "REFUSED: source file not found: $SRC" >&2
	exit 1
fi

# --- gate 1: the access-gate and its regression guard must be present in the readable source ---
fail=0
check() {
	if ! grep -qF -- "$1" "$SRC"; then
		echo "REFUSED: missing required marker in source: $1" >&2
		fail=1
	fi
}
check '-- ACCESS CHECK:'
check 'control.json'
check 'local AUTH_URL ='
check 'UI.Card(OP, "Access control")'
check 'control/enabled'
check 'control/banned'
check 'kind ~= "gather"'
if [ "$fail" = "1" ]; then
	echo "REFUSED: the access-gate (or the glide/speed fix) is missing from $SRC." >&2
	echo "Do not hand-build a public release from a file that fails this check." >&2
	exit 1
fi
echo "ok: access-gate and glide/speed-fix markers present"

# --- split into header + the readable trailing (executing) copy ---
HDR_END=$(grep -n '^local JH_SOURCE = \[==\[$' "$SRC" | head -1 | cut -d: -f1)
CLOSE_LINE=$(grep -n '^\]==\]$' "$SRC" | head -1 | cut -d: -f1)
if [ -z "$HDR_END" ] || [ -z "$CLOSE_LINE" ]; then
	echo "REFUSED: could not find the JH_SOURCE boundaries in $SRC (format changed?)." >&2
	exit 1
fi
TRAIL_START=$((CLOSE_LINE + 2))

sed -n "1,$((HDR_END - 1))p" "$SRC" > "$WORKDIR/header.lua"
sed -n "${TRAIL_START},\$p" "$SRC" > "$WORKDIR/trailing.lua"

if [ ! -s "$WORKDIR/trailing.lua" ]; then
	echo "REFUSED: extracted trailing (executing) copy is empty." >&2
	exit 1
fi

# --- obfuscate the trailing copy ---
OBF_DIR="$(cd "$(dirname "$0")/obfuscate" && pwd)"
if [ ! -d "$OBF_DIR/node_modules" ]; then
	echo "installing obfuscator dependencies..."
	(cd "$OBF_DIR" && npm install --silent)
fi
node "$OBF_DIR/encrypt.js" "$WORKDIR/trailing.lua" "$WORKDIR/trailing_enc.lua"

if [ ! -s "$WORKDIR/trailing_enc.lua" ]; then
	echo "REFUSED: obfuscation produced no output." >&2
	exit 1
fi

# --- gate 2: the obfuscated output must not contain the plaintext giveaways anymore ---
plain_fail=0
plaincheck() {
	if grep -qF -- "$1" "$WORKDIR/trailing_enc.lua"; then
		echo "REFUSED: obfuscated output still contains plaintext: $1" >&2
		plain_fail=1
	fi
}
plaincheck 'jayhubv1-default-rtdb.firebaseio.com'
plaincheck 'ACCESS CHECK'
plaincheck 'function JHubMain'
plaincheck 'JHubBlocked'
if [ "$plain_fail" = "1" ]; then
	echo "REFUSED: the obfuscator did not actually hide the sensitive strings - do not publish this." >&2
	exit 1
fi
echo "ok: obfuscated output has no readable giveaway strings"

# --- assemble the public build: header + self-referential obfuscated JH_SOURCE + obfuscated executing copy ---
{
	cat "$WORKDIR/header.lua"
	printf 'local JH_SOURCE = [==[\n'
	cat "$WORKDIR/trailing_enc.lua"
	printf '\n]==]\n\n'
	cat "$WORKDIR/trailing_enc.lua"
} > "$OUT"

# --- gate 3: both copies must actually load as valid Lua ---
if command -v python3 >/dev/null 2>&1 && python3 -c 'import lupa' >/dev/null 2>&1; then
	python3 - "$OUT" <<'PYEOF'
import re, sys, lupa
path = sys.argv[1]
src = open(path, encoding='latin-1').read()
lua = lupa.LuaRuntime()
def check(label, text):
	lua.globals().__check_src = text
	ok, err = lua.eval('(function() local f, err = load(__check_src) return f ~= nil, err end)()')
	print(f"{label}: {'OK' if ok else 'FAILED - ' + str(err)}")
	if not ok:
		sys.exit(1)
check("full build loads", src)
m = re.search(r'local JH_SOURCE = \[==\[\n(.*?)\n\]==\]', src, re.S)
check("embedded copy loads", m.group(1))
PYEOF
else
	echo "warning: lupa not available, skipping the load-check gate - verify manually before pushing" >&2
fi

echo "== built: $OUT =="
echo "This is the file to copy over executor/JHubV1_Glass.lua on the wclom3 branch. Nothing was pushed."
