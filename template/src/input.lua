-- Input handling library, based off of tesselode/tactile.

local Input = {}
Input.DEAD_ZONE = 0.1 -- Default dead zone for gamepads and joysticks.

-- Clamping helper function.
local function clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

--[[
Button detectors are functions that return booleans (indicating that some button is pressed).
Button objects are then constructed using a detector. (Buttons essentially add the ability to
remember state.)
]]--

-- Keyboard key button detector.
function Input.Key(key)
  return function() return love.keyboard.isDown(key) end
end
-- Joystick button detector.
function Input.JoystickButton(joystick, button)
  return function() return joystick:isDown(button) end
end
-- Gamepad button detector.
function Input.GamepadButton(joystick, button)
  assert(joystick:isGamepad(), 'joystick must be a GamePad')
  return function() return joystick:isGamepadDown(button) end
end
-- Convert an axis detector into a button detector.
function Input.ThresholdButton(detector, threshold)
  return function() return detector() > threshold end
end
-- Or combinator for ButtonDetectors
function Input.Or(...)
  local detectors = {...}
  return function()
    for _, detector in ipairs(detectors) do
      if detector() then return true end
    end
    return false
  end
end



--[[ Axis detectors return a number between 0 and 1. An axis is made up of two detectors - one
for the positive direction, and one for the negative direction. ]]--

-- Convert a button detector into an axis detector.
function Input.BinaryAxis(detector)
  return function()
    return detector() and 1.0 or 0.0
  end
end
-- Axis detector for a joystick.
function Input.JoystickAxis(joystick, axis, direction, deadzone)
  deadzone = deadzone or Input.DEAD_ZONE
  assert(direction == -1 or direction == 1, 'direction must equal -1 or 1')
  return function()
    local value = clamp(direction*joystick:getAxis(axis), 0, 1)
    if value > deadzone then return value else return 0 end
  end
end
-- Axis detector for a gamepad axis.
function Input.GamepadAxis(joystick, axis, direction, deadzone)
  deadzone = deadzone or Input.DEAD_ZONE
  assert(joystick:isGamepad(), 'joystick must be a GamePad')
  assert(direction == -1 or direction == 1, 'direction must equal -1 or 1')
  return function()
    local value = clamp(direction*joystick:getGamepadAxis(axis), 0, 1)
    if value > deadzone then return value else return 0 end
  end
end

-- Max combinator for Axis detectors.
function Input.Max(...)
  local detectors = {...}
  return function()
    local max = 0
    for _, detector in ipairs(detectors) do
      local value = detector()
      if value > max then max = value end
    end
    return max
  end
end

-- Button class
local Button = {}
Button.__index = Button
function Button:update()
  self.downPrevious = self.down
  self.down = self.detector()
end
function Button:isDown() return self.down end
function Button:pressed() return self.down and not self.downPrevious end
function Button:released() return self.downPrevious and not self.down end
function Input.Button(detector)
  local instance = { detector = detector, down = false, downPrevious = false }
  return setmetatable(instance, Button)
end

-- Axis class
local Axis = {}
Axis.__index = Axis
function Axis:getValue() return self.detector() end
function Input.Axis(detector)
  local instance = { detector = detector }
  return setmetatable(instance, Axis)
end

return Input
