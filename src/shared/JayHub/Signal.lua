--!nonstrict
-- Minimal signal class. Listener errors are caught and reported so one bad
-- handler can never break the others.

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Connection:Disconnect()
	if not self.Connected then
		return
	end
	self.Connected = false
	local list = self._signal._connections
	local index = table.find(list, self)
	if index then
		table.remove(list, index)
	end
end

function Signal.new()
	return setmetatable({ _connections = {} }, Signal)
end

function Signal:Connect(fn: (...any) -> ())
	local connection = setmetatable({ Connected = true, _fn = fn, _signal = self }, Connection)
	table.insert(self._connections, connection)
	return connection
end

function Signal:Once(fn: (...any) -> ())
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		fn(...)
	end)
	return connection
end

function Signal:Fire(...: any)
	-- Copy so handlers may disconnect while we iterate.
	local snapshot = table.clone(self._connections)
	local args = table.pack(...)
	for _, connection in snapshot do
		if connection.Connected then
			local ok, err = pcall(connection._fn, table.unpack(args, 1, args.n))
			if not ok then
				warn("[JayHub] Signal handler error:", err)
			end
		end
	end
end

function Signal:DisconnectAll()
	for _, connection in self._connections do
		connection.Connected = false
	end
	table.clear(self._connections)
end

return Signal
