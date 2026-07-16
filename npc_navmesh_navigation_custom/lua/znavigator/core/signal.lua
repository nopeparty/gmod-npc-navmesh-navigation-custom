--================================================================--
-- ZNavigator
-- core/signal.lua
-- Part 1 / 3
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Core = ZNavigator.Core or {}

local Class = ZNavigator.Core.Class

----------------------------------------------------------
-- Connection
----------------------------------------------------------

local Connection = Class.Create("SignalConnection")

function Connection:Initialize(signal, callback, once)

    assert(signal ~= nil, "Signal expected.")
    assert(isfunction(callback), "Callback expected.")

    self.Signal = signal

    self.Callback = callback

    self.Once = once == true

    self.Connected = true
    self.Paused = false

    self.Next = nil
    self.Previous = nil

end

----------------------------------------------------------
-- State
----------------------------------------------------------

function Connection:IsConnected()

    return self.Connected

end

function Connection:IsPaused()

    return self.Paused

end

----------------------------------------------------------
-- Pause
----------------------------------------------------------

function Connection:Pause()

    self.Paused = true

    return self

end

function Connection:Resume()

    self.Paused = false

    return self

end

----------------------------------------------------------
-- Disconnect
----------------------------------------------------------

function Connection:Disconnect()

    if not self.Connected then
        return false
    end

    self.Connected = false

    local signal = self.Signal

    local previous = self.Previous
    local nextNode = self.Next

    if previous then

        previous.Next = nextNode

    else

        signal.Head = nextNode

    end

    if nextNode then

        nextNode.Previous = previous

    else

        signal.Tail = previous

    end

    self.Next = nil
    self.Previous = nil

    signal.Count = signal.Count - 1

    return true

end

----------------------------------------------------------
-- Signal
----------------------------------------------------------

local Signal = Class.Create("Signal")

function Signal:Initialize()

    self.Head = nil
    self.Tail = nil

    self.Count = 0

    self.Destroyed = false
    self.Firing = false

end

----------------------------------------------------------
-- Internal
----------------------------------------------------------

function Signal:_Connect(callback, once)

    assert(
        isfunction(callback),
        "Signal callback must be a function."
    )

    if self.Destroyed then
        error("Signal has been destroyed.")
    end

    local connection = Connection:new(

        self,

        callback,

        once

    )

    if self.Tail then

        self.Tail.Next = connection

        connection.Previous = self.Tail

        self.Tail = connection

    else

        self.Head = connection

        self.Tail = connection

    end

    self.Count = self.Count + 1

    return connection

end

----------------------------------------------------------
-- Public
----------------------------------------------------------

function Signal:Connect(callback)

    return self:_Connect(

        callback,

        false

    )

end

function Signal:Once(callback)

    return self:_Connect(

        callback,

        true

    )

end

----------------------------------------------------------
-- Query
----------------------------------------------------------

function Signal:IsEmpty()

    return self.Count == 0

end

function Signal:GetConnectionCount()

    return self.Count

end

function Signal:IsDestroyed()

    return self.Destroyed

end

function Signal:IsFiring()

    return self.Firing

end

----------------------------------------------------------
-- Find
----------------------------------------------------------

function Signal:Find(callback)

    local node = self.Head

    while node do

        if node.Callback == callback then
            return node
        end

        node = node.Next

    end

    return nil

end

----------------------------------------------------------
-- Iterator
----------------------------------------------------------

function Signal:Iter()

    local node = self.Head

    return function()

        local current = node

        if current then
            node = current.Next
        end

        return current

    end

end

----------------------------------------------------------
-- Internal Safe Call
----------------------------------------------------------

local function SafeCall(callback, ...)

    local ok, err = xpcall(
        callback,
        debug.traceback,
        ...
    )

    if not ok then

        ErrorNoHalt(
            ("[ZNavigator::Signal]\n%s\n")
                :format(err)
        )

    end

end

----------------------------------------------------------
-- Fire
----------------------------------------------------------

function Signal:Fire(...)

    if self.Destroyed then
        return
    end

    if self.Head == nil then
        return
    end

    self.Firing = true

    local node = self.Head

    while node do

        local nextNode = node.Next

        if node.Connected and not node.Paused then

            node.Callback(...)

            if node.Once and node.Connected then
                node:Disconnect()
            end

        end

        node = nextNode

    end

    self.Firing = false

end

----------------------------------------------------------
-- Safe Fire
----------------------------------------------------------

function Signal:FireSafe(...)

    if self.Destroyed then
        return
    end

    if self.Head == nil then
        return
    end

    self.Firing = true

    local node = self.Head

    while node do

        local nextNode = node.Next

        if node.Connected and not node.Paused then

            SafeCall(
                node.Callback,
                ...
            )

            if node.Once and node.Connected then
                node:Disconnect()
            end

        end

        node = nextNode

    end

    self.Firing = false

end

----------------------------------------------------------
-- Alias
----------------------------------------------------------

Signal.Emit = Signal.Fire

----------------------------------------------------------
-- Broadcast
----------------------------------------------------------

function Signal:Broadcast(...)

    self:Fire(...)

end

----------------------------------------------------------
-- ForEach
----------------------------------------------------------

function Signal:ForEach(callback)

    assert(
        isfunction(callback),
        "Callback expected."
    )

    local node = self.Head

    while node do

        local nextNode = node.Next

        callback(node)

        node = nextNode

    end

end

----------------------------------------------------------
-- Disconnect All
----------------------------------------------------------

function Signal:DisconnectAll()

    local node = self.Head

    while node do

        local nextNode = node.Next

        node:Disconnect()

        node = nextNode

    end

end

----------------------------------------------------------
-- Clear
----------------------------------------------------------

function Signal:Clear()

    local node = self.Head

    while node do

        local nextNode = node.Next

        node.Signal = nil
        node.Callback = nil

        node.Next = nil
        node.Previous = nil

        node.Connected = false

        node = nextNode

    end

    self.Head = nil
    self.Tail = nil

    self.Count = 0

end

----------------------------------------------------------
-- Wait
----------------------------------------------------------

function Signal:Wait()

    local thread = coroutine.running()

    assert(
        thread,
        "Signal:Wait() must be called inside a coroutine."
    )

    local connection

    connection = self:Once(function(...)

        if connection then
            connection:Disconnect()
        end

		local args = { ... }
		
        timer.Simple(0, function()

			if coroutine.status(thread) == "suspended" then
				coroutine.resume(thread, unpack(args))
			end
			
        end)

    end)

    return coroutine.yield()

end

----------------------------------------------------------
-- Deferred Fire
----------------------------------------------------------

function Signal:FireDeferred(...)

    if self.Destroyed then
        return
    end

    local args = table.pack(...)

    timer.Simple(0, function()

        if self.Destroyed then
            return
        end

        self:Fire(
            table.unpack(
                args,
                1,
                args.n
            )
        )

    end)

end

----------------------------------------------------------
-- Count
----------------------------------------------------------

function Signal:__len()

    return self.Count

end

----------------------------------------------------------
-- Empty
----------------------------------------------------------

function Signal:HasConnections()

    return self.Count > 0

end

----------------------------------------------------------
-- Clone
----------------------------------------------------------

function Signal:Clone()

    if self.Destroyed then
        error("Cannot clone a destroyed signal.")
    end

    local clone = Signal:new()

    local node = self.Head

    while node do

        if node.Once then
            clone:Once(node.Callback)
        else
            clone:Connect(node.Callback)
        end

        node = node.Next

    end

    return clone

end

----------------------------------------------------------
-- Destroy
----------------------------------------------------------

function Signal:Destroy()

    if self.Destroyed then
        return
    end

    self:Clear()

    self.Destroyed = true
    self.Firing = false

end

----------------------------------------------------------
-- Connection Meta
----------------------------------------------------------

function Connection:__tostring()

    return string.format(
        "SignalConnection<Connected=%s, Once=%s>",
        tostring(self.Connected),
        tostring(self.Once)
    )

end

----------------------------------------------------------
-- Signal Meta
----------------------------------------------------------

function Signal:__tostring()

    return string.format(
        "Signal<Connections=%d>",
        self.Count
    )

end

----------------------------------------------------------
-- Metatable
----------------------------------------------------------

Signal.__call = function(self, ...)

    return self:Fire(...)

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Core.Signal = Signal
ZNavigator.Core.SignalConnection = Connection

return Signal