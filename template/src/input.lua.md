# Input Handling Library

> This library is written in [literate programming](https://en.wikipedia.org/wiki/Literate_programming) style, so this markdown file is both the documentation of the library, and the actual code of the module.

This is a input handling library, inspired by [tesselode/tactile](https://github.com/tesselode/tactile). It abstracts the concepts of a Buttons and Axes, separating them from phsyical resources like gamepads. The primary motivation for this is to create easily rebindable controls.

I decided to make my own library for a couple reasons. First, I wanted axes to be real values in `[0, 1]`, whereas, in tactile, axes are in `[-1, 1]`. Second, I didn't like that joysticks were identified by their index in the joysticks array, which can technically change throughout the game if joysticks are inserted and removed.


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Concepts](#concepts)
- [Prelude](#prelude)
- [Button Detectors](#button-detectors)
  - [Primitive Button Detectors](#primitive-button-detectors)
    - [Keyboard Button Detector](#keyboard-button-detector)
    - [Joystick Button Detector](#joystick-button-detector)
    - [Gamepad Button Detector](#gamepad-button-detector)
  - [Creating a Button Detector from an Axis Detector](#creating-a-button-detector-from-an-axis-detector)
  - [Button Detector Combinators](#button-detector-combinators)
- [Axis Detectors](#axis-detectors)
  - [Primitive Axis Detectors](#primitive-axis-detectors)
    - [Joystick Axis Detector](#joystick-axis-detector)
    - [Gamepad Axis Detector](#gamepad-axis-detector)
  - [Create an Axis Dectector from a Button Detector](#create-an-axis-dectector-from-a-button-detector)
  - [Axis Combinator](#axis-combinator)
- [Buttons](#buttons)
- [Axes](#axes)
- [Epilogue](#epilogue)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Concepts

This library has four core objects - **Buttons**, **Axes**, **Button Detectors**, and **Axis Detectors**. **Buttons** and **Axes** are resources that you should actually use during the game. **Button detectors** and **Axis detectors** exist to help configure the behavior of **Buttons** and **Axes**.
- A [**Button Detector**](#button-detectors) is any function that returns a boolean (corresponding to whether or not a button is pressed).
- An [**Axis Detector**](#axis-detectors) is any function that returns a real value between `0` and `1`.
- A [**Button**](#buttons) object wraps a button detector, exposing an `isDown()`, `pressed()` and `released()` function, which can be used to checkif the button is currently being held, was pressed down this frame, or was released this frame.
- An [**Axis**](#axes) object wraps an axis detector, exposing a get `getValue()` function, which returns the value of the axis. Technically, the **Axis** objects don't serve much additional purposed - they exist simply to provide some symmetry with the Button-related half of the library.

> It might make more sense for Axes to be between -1 and 1, rather than 0 and 1. However, I decided to make this change in order to make in-game controller binding a simpler task. Instead of having two axes `horizontal` and `vertical`, you have four axes `left`, `right`, `up`, and `down`. This makes the case where the user is trying to bind a button to the axes much simpler. It also lets the user determine whate is the 'positive' and negative 'direction'.

## Prelude
First, let's setup the empty module, and list some configurable globals.
```lua
local Input = {}
Input.DEAD_ZONE = 0.1 -- Default dead zone for gamepad and joystick axes.
```

## Button Detectors
As described above, button detectors are functions that return booleans (indicating that some button is pressed). Later, we will use these detectors to construct Button objects. For now, however, we'll define some primitive button detectors that should cover the most common cases.

### Primitive Button Detectors
> TODO: This section is missing a primitive button detector for joystick hats.

#### Keyboard Button Detector
This is a basic button detector that returns true if a specific key is pressed.
```lua
-- Keyboard key button detector.
function Input.Key(key)
  return function() return love.keyboard.isDown(key) end
end
```
#### Joystick Button Detector
This button detector returns true if a specific button on a joystick is pressed.
```lua
-- Joystick button detector.
function Input.JoystickButton(joystick, button)
  return function() return joystick:isDown(button) end
end
```
#### Gamepad Button Detector
This button detector returns true if a button on a gamepad is pressed.
> What's the difference between a joystick and a gamepad? Gamepads are basically just "known" joysticks, where the the LOVE engine has a mapping between button/axis identifiers and semantic descriptions (eg: "Right Bumper", as opposed to "Button 8").

```lua
-- Gamepad button detector.
function Input.GamepadButton(joystick, button)
  assert(joystick:isGamepad(), 'joystick must be a GamePad')
  return function() return joystick:isGamepadDown(button) end
end
```
### Creating a Button Detector from an Axis Detector
There are some instances where one might want to create a button detector from an axis detector - eg. using an analog trigger to correspond to some binary firing action. This can be done simply, with the use of a threshold.
```lua
-- Convert an axis detector into a button detector.
function Input.ThresholdButton(detector, threshold)
  return function() return detector() > threshold end
end
```
### Button Detector Combinators
Sometimes, you might want to combine button detectors into one button detector that is activated if any one of the member detectors is activated. This can be done through the `Or` combinator.
```lua
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
```

> See [this article](https://programmers.stackexchange.com/questions/117522/what-are-combinators-and-how-are-they-applied-to-programming-projects-practica) for a description of what combinators are.

## Axis Detectors
Axis detectors return a number between 0 and 1. The library also includes a few primitives for this.

### Primitive Axis Detectors

#### Joystick Axis Detector
This detector reads a specific axis of the given joysticl. You must specify the direction of the axis that you want to extract. Anything not in that direction is ignored. For example, if you pick the positive direction (`+1`), then the axis value is clamped between `0` and `1`. If you pick the negative direction, the axis value is inverted, and then clamped.

```lua
-- Axis detector for a joystick.
function Input.JoystickAxis(joystick, axis, direction, deadzone)
  deadzone = deadzone or Input.DEAD_ZONE
  assert(direction == -1 or direction == 1, 'direction must equal -1 or 1')
  return function()
    local value = lume.clamp(direction*joystick:getAxis(axis), 0, 1)
    if value > deadzone then return value else return 0 end
  end
end
```

#### Gamepad Axis Detector
This detector is the same as the detector above, but for a GamePad axis.

```lua
-- Axis detector for a gamepad axis.
function Input.GamepadAxis(joystick, axis, direction, deadzone)
  deadzone = deadzone or Input.DEAD_ZONE
  assert(joystick:isGamepad(), 'joystick must be a GamePad')
  assert(direction == -1 or direction == 1, 'direction must equal -1 or 1')
  return function()
    local value = lume.clamp(direction*joystick:getGamepadAxis(axis), 0, 1)
    if value > deadzone then return value else return 0 end
  end
end
```

### Create an Axis Dectector from a Button Detector
Axis detectors can be created from a button detector. This is necessary for cases such as when WASD, or a Joystick D-Pad must be bound to an axis.

```lua
-- Convert a button detector into an axis detector.
function Input.BinaryAxis(detector)
  return function()
    return detector() and 1.0 or 0.0
  end
end
```

### Axis Combinator

In the same fashion as the `Or` combinator for Button detectors, we have a `Max` combinator, for Axis detectors, which always returns the highest value of the member detectors.

```lua
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
```

## Buttons
This class simply wraps button detectors, keeping track of the state of the button every frame. As a result, you must call the `update()` function on each frame.

```lua
-- Button class
local Button = {}
Button.__index = Button
function Button:update() -- This needs to be called on every frame.
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
```

## Axes
This class wraps axis detectors, mostly to make the API symmetric with how Buttons work.

```lua
-- Axis class
local Axis = {}
Axis.__index = Axis
function Axis:getValue() return self.detector() end
function Input.Axis(detector)
  local instance = { detector = detector }
  return setmetatable(instance, Axis)
end
```

## Epilogue
That's it for this module. In summary, you create either **Buttons** or **Axes**, and you create them using **Button Detectors** or **Axis Detectors**.

```lua
return Input
```
