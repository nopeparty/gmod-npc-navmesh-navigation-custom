--================================================================--
-- ZNavigator
-- core/class.lua
-- Part 1 / 2
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Core = ZNavigator.Core or {}

local Class = {}

Class.__index = Class

--------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------

local function Construct(class, ...)

    local object = setmetatable({}, class)

    print("[ZN] class =", class)
    print("[ZN] object mt =", getmetatable(object))
    print("[ZN] class.__index =", class.__index)

    if object.Initialize then
        object:Initialize(...)
    end

    print("[ZN] object.GetName =", object.GetName)

    return object

end

--------------------------------------------------------------------
-- Create
--------------------------------------------------------------------

function Class.Create(name, base)

    assert(type(name) == "string", "Class name expected.")

    local cls = {}

    cls.__index = cls

    cls.__name = name
    cls.__base = base

    --------------------------------------------------------------

    if base then

        setmetatable(cls, {

            __index = base,

            __call = function(self, ...)

                return Construct(self, ...)

            end

        })

    else

        setmetatable(cls, {

            __call = function(self, ...)

                return Construct(self, ...)

            end

        })

    end

    --------------------------------------------------------------

    function cls:new(...)

    print("[ZN] new() class =", self:GetClassName())

    return Construct(self, ...)

	end

    --------------------------------------------------------------

    function cls:GetClass()

        return cls

    end

    --------------------------------------------------------------

    function cls:GetClassName()

        return cls.__name

    end

    --------------------------------------------------------------

    function cls:GetBaseClass()

        return cls.__base

    end

    --------------------------------------------------------------

    function cls:IsClass(class)

        return self:GetClass() == class

    end

    --------------------------------------------------------------

    function cls:Initialize()

    end
	
--------------------------------------------------------------
-- Extend
--------------------------------------------------------------

	function cls:Extend(name)

		return Class.Create(name, self)

	end	

    return cls

end

--------------------------------------------------------------------
-- Shortcut
--------------------------------------------------------------------

setmetatable(Class, {

    __call = function(_, name, base)

        return Class.Create(name, base)

    end

})

--------------------------------------------------------------------
-- Root Object
--------------------------------------------------------------------

local Object = Class.Create("Object")

function Object:ToString()

    return self:GetClassName()

end

function Object:__tostring()

    return self:ToString()

end

function Object:IsValid()

    return true

end

Class.Object = Object

--------------------------------------------------------------------
-- Extend
--------------------------------------------------------------------

function Class.Extend(base, name)

    assert(Class.IsClass(base), "Base class expected.")

    return Class.Create(name, base)

end

function Object:Extend(name)

    return Class.Create(name, self:GetClass())

end

--------------------------------------------------------------------
-- Inheritance
--------------------------------------------------------------------

function Object:IsA(class)

    local current = self:GetClass()

    while current do

        if current == class then
            return true
        end

        current = current.__base

    end

    return false

end

--------------------------------------------------------------------
-- Super
--------------------------------------------------------------------

function Object:GetSuper()

    return self:GetClass().__base

end

function Object:CallSuper(method, ...)

    local super = self:GetSuper()

    if not super then
        return
    end

    local func = super[method]

    if func then
        return func(self, ...)
    end

end

--------------------------------------------------------------------
-- Clone
--------------------------------------------------------------------

function Object:Clone()

    local copy = setmetatable({}, self:GetClass())

    for k, v in pairs(self) do

        copy[k] = v

    end

    return copy

end

--------------------------------------------------------------------
-- Destroy
--------------------------------------------------------------------

function Object:Destroy()

end

--------------------------------------------------------------------
-- Static
--------------------------------------------------------------------

function Class.IsClass(value)

    return istable(value)
        and rawget(value, "__name") ~= nil
        and rawget(value, "__index") == value

end

function Class.IsInstance(value)

    if not istable(value) then
        return false
    end

    return Class.IsClass(
        getmetatable(value)
    )

end

function Class.IsSubclass(class, base)

    while class do

        if class == base then
            return true
        end

        class = class.__base

    end

    return false

end

--------------------------------------------------------------------
-- Mixin
--------------------------------------------------------------------

function Class.Mixin(class, mixin)

    for k, v in pairs(mixin) do

        if rawget(class, k) == nil then

            class[k] = v

        end

    end

    return class

end

--------------------------------------------------------------------
-- tostring
--------------------------------------------------------------------

function Class.ToString(class)

    return ("Class<%s>")
        :format(class.__name)

end

--------------------------------------------------------------------
-- Export
--------------------------------------------------------------------

ZNavigator.Core.Class = Class

return Class