# DeviceCard Entity

This entitiy is used in the `ControllerSelect` GameState to show information about players that are trying to join a game.

It's a fairly complex state machine, which has the following possible states:
- Unfilled - No input device has been assigned to this card yet.
- Joining - An input device has been assigned to this card, but we want the player to hold the button down for a second, in order to confirm that this wasn't a mistake.
- Joined - An input device has been assigned to this card, and the device is fully bound.
- Binding - Slots in the binding are in the process if being assigned.

## Prelude
This class is defined using [middleclass](https://github.com/kikito/middleclass). Since it's behaviour is best thought of as a state machine, we can use [stateful.lua](https://github.com/kikito/stateful.lua).

```lua
DeviceCard = class('DeviceCard', Entity)
DeviceCard:include(Stateful)
```

```lua
-- The width and height of the card.
DeviceCard.static.WIDTH = 200
DeviceCard.static.HEIGHT = 280

DeviceCard.static.MARGIN = 20

-- Fonts used for various texts on the card.
DeviceCard.static.TITLE_FONT = love.graphics.newFont(20)
DeviceCard.static.DESC_FONT = love.graphics.newFont(15)
DeviceCard.static.MID_FONT = love.graphics.newFont(16)

DeviceCard.static.JOIN_TIME = 1.0 -- How long one must hold a button to
DeviceCard.static.BIND_TIME = 1.0
DeviceCard.static.CURSOR_SPEED = 200
```

```lua
function DeviceCard:initialize(pos)
  Entity.initialize(self, 'devicecard', 0, pos)
  self:gotoState('Unfilled')
end
```

```lua
function DeviceCard:draw()
  Entity.draw(self)
  Color.WHITE:use()
  love.graphics.rectangle('fill', self.pos.x, self.pos.y, DeviceCard.WIDTH, DeviceCard.HEIGHT)
end
function DeviceCard:hasJoined() return false end
function DeviceCard:isReady() return false end
```

## Unfilled Cards
```lua
local UnfilledState = DeviceCard:addState('Unfilled')
function UnfilledState:enteredState()
  if self.inputName then
    print(self.inputName .. " leaving...")
  end
  self.inputID = nil
end
function UnfilledState:draw()
  DeviceCard.draw(self)
  Color.BLACK:use()
  love.graphics.setFont(DeviceCard.TITLE_FONT)
  love.graphics.printf("Hold any key or button to join...", self.pos.x + DeviceCard.MARGIN,
    self.pos.y  + DeviceCard.HEIGHT * 0.25, DeviceCard.WIDTH - DeviceCard.MARGIN * 2, "center")
end
```

## Joining Cards
```lua
local JoiningState = DeviceCard:addState('Joining')
function JoiningState:enteredState(inputType, inputID, inputName, joinButton)
  self.inputType = inputType
  self.inputID = inputID
  self.inputName = inputName
  self.joinButton = joinButton
  self.joinTime = 0
  print(self.inputName .. " joining...")
end
function JoiningState:draw()
  DeviceCard.draw(self)
  Color.BLACK:use()
  love.graphics.setFont(DeviceCard.TITLE_FONT)
  love.graphics.printf(self.inputName, self.pos.x + DeviceCard.MARGIN,
    self.pos.y  + DeviceCard.HEIGHT * 0.25, DeviceCard.WIDTH - DeviceCard.MARGIN * 2, "center")

  local topleft = vector(self.pos.x + DeviceCard.MARGIN, self.pos.y + DeviceCard.HEIGHT/2 - 10)
  local size = vector(DeviceCard.WIDTH - DeviceCard.MARGIN*2, 20)

  Color.RED:use()
  love.graphics.rectangle('fill', topleft.x, topleft.y, size.x, size.y)
  Color.BLUE:use()
  love.graphics.rectangle('fill', topleft.x, topleft.y,
    size.x * (self.joinTime / DeviceCard.JOIN_TIME), size.y)
  Color.BLACK:use()
  love.graphics.setLineWidth(2)
  love.graphics.rectangle('line', topleft.x, topleft.y, size.x, size.y)
  love.graphics.setLineWidth(1)
end
function JoiningState:getInitialBinding()
  if self.inputType == 'keyboard' then
    return ControllerSelect.KEYBOARD_DEFAULT()
  elseif self.inputType == 'gamepad' then
    return ControllerSelect.GAMEPAD_DEFAULT(self.inputID)
  else
    return Binding()
  end
end

function JoiningState:update(dt)
  self.joinButton:update()
  if self.joinButton:isDown() then
    self.joinTime = self.joinTime + dt
    if self.joinTime > DeviceCard.JOIN_TIME then
      self:gotoState('Joined', self:getInitialBinding())
    end
  else
    self:gotoState('Unfilled')
  end
end

local JoinedState = DeviceCard:addState('Joined')
function JoinedState:enteredState(binding)
  self.binding = binding -- The current binding for the input device.
  self.cursorPosition = vector(DeviceCard.WIDTH / 2, DeviceCard.HEIGHT / 2) -- The initial cursor position.
  self.ready = false -- Start out as not ready.

  -- If the binding is not complete, then we need to go to the binding state.
  if not self.binding:isComplete() then
    self:gotoState('Binding', self.binding)
  end
end
function JoinedState:isReady() return self.ready end
function JoinedState:drawButton(pos, text, selected)
  love.graphics.setFont(DeviceCard.TITLE_FONT)
  if selected then Color.CYAN:use() else Color.WHITE:use() end
  love.graphics.rectangle('fill', pos.x, pos.y, 150, 50)
  Color.BLACK:use()
  love.graphics.rectangle('line', pos.x, pos.y, 150, 50)
  love.graphics.print(text, (pos + vector(40, 14)):unpack())
end
function JoinedState:draw()
  DeviceCard.draw(self)
  Color.BLACK:use()
  love.graphics.setFont(DeviceCard.MID_FONT)
  love.graphics.printf(self.inputName, self.pos.x + DeviceCard.MARGIN,
    self.pos.y  + 10, DeviceCard.WIDTH - DeviceCard.MARGIN * 2, "center")

  love.graphics.setFont(DeviceCard.DESC_FONT)
  love.graphics.printf(self.binding:getText(), self.pos.x + DeviceCard.MARGIN,
    self.pos.y  + 35, DeviceCard.WIDTH - DeviceCard.MARGIN * 2, "center")

  Color.WHITE:use()
  love.graphics.circle('fill', self.pos.x + 20, self.pos.y + 20, 15, 16)
  Color.BLACK:use()
  love.graphics.setLineWidth(2)
  love.graphics.circle('line', self.pos.x + 20, self.pos.y + 20, 15, 16)
  love.graphics.line( self.pos.x + 14, self.pos.y + 14,  self.pos.x + 26, self.pos.y + 26)
  love.graphics.line( self.pos.x + 26, self.pos.y + 14,  self.pos.x + 14, self.pos.y + 26)
  love.graphics.setLineWidth(1)

  self:drawButton(self.pos + vector(25, 220), "READY", self.ready)
  self:drawButton(self.pos + vector(25, 160), "REBIND", false)

  local verts = {
    self.pos + self.cursorPosition,
    self.pos + self.cursorPosition + vector(50, 20)*0.6,
    self.pos + self.cursorPosition + vector(30, 30)*0.6,
    self.pos + self.cursorPosition + vector(20, 50)*0.6,
  }
  Color.GREY:use()
  love.graphics.polygon('fill', verts[1].x, verts[1].y, verts[2].x, verts[2].y, verts[3].x, verts[3].y)
  love.graphics.polygon('fill', verts[1].x, verts[1].y, verts[3].x, verts[3].y, verts[4].x, verts[4].y)
  Color.BLACK:use()
  love.graphics.setLineWidth(3)
  love.graphics.line(verts[1].x, verts[1].y, verts[2].x, verts[2].y, verts[3].x, verts[3].y,
    verts[4].x, verts[4].y, verts[1].x, verts[1].y)
  love.graphics.setLineWidth(1)

end
function JoinedState:hasJoined() return true end
function JoinedState:update(dt)
  -- Update the cursor's position.
  local movement =  vector(self.binding:getAxis('right'):getValue() - self.binding:getAxis('left'):getValue(),
      -(self.binding:getAxis('up'):getValue() - self.binding:getAxis('down'):getValue()))
  self.cursorPosition = self.cursorPosition + movement * DeviceCard.CURSOR_SPEED * dt
  self.cursorPosition.x = lume.clamp(self.cursorPosition.x, 0, DeviceCard.WIDTH)
  self.cursorPosition.y = lume.clamp(self.cursorPosition.y, 0, DeviceCard.HEIGHT)

  -- Click.
  self.binding:getButton('action'):update()
  if self.binding:getButton('action'):pressed() then
    if (self.cursorPosition - vector(20, 20)):len() < 15 then
      self:gotoState('Unfilled')
    elseif self.cursorPosition.x > 25 and self.cursorPosition.y > 220 and
      self.cursorPosition.x < 25 + 150 and self.cursorPosition.y < 220 + 50 then
      self.ready = not self.ready
    elseif self.cursorPosition.x > 25 and self.cursorPosition.y > 160 and
      self.cursorPosition.x < 25 + 150 and self.cursorPosition.y < 160 + 50 then
      self:gotoState('Binding', Binding())
    end
  end
end

local BindingState = DeviceCard:addState('Binding')
function BindingState:hasJoined() return true end -- This player has 'joined', and is simply rebinding controls.
function BindingState:enteredState(binding)
  if binding:isComplete() then
    self:gotoState('Joined', binding)
    return
  end

  assert(self.inputType ~= nil, 'The inputType field should be set.')
  assert(self.inputID ~= nil, 'The inputID field should be set.')

  self.binding = binding
  self.bindingType, self.bindingName = self.binding:getNextBindSlot()
  self.bindingTitle = self.bindingName:sub(1, 1):upper() .. self.bindingName:sub(2, -1)

  self.possibleButton = nil
  self.possibleAxis = nil
  self.possibleDescription = nil
  self.holdTime = 0
  self.handles = {}

  if self.inputType == 'keyboard' then
    self.handles.keypressed = self.gameState.signals.register('keypressed', function(key, isrepeat)
      self.holdTime = 0
      self.possibleDescription = key
      if self.bindingType == 'button' then
        self.possibleButton = input.Button(input.Key(key))
      elseif self.bindingType == 'axis' then
        self.possibleAxis = input.Axis(input.BinaryAxis(input.Key(key)))
      else
        error('Unkown binding type: ' .. self.bindingType)
      end
    end)
  elseif self.inputType == 'joystick' then
    self.handles.joystickpressed = self.gameState.signals.register('joystickpressed', function(joystick, button)
      if joystick:getID() ~= self.inputID then return end -- Ignore if this is not our current joystick.
      self.holdTime = 0
      self.possibleDescription = "Button " .. button
      if self.bindingType == 'button' then
        self.possibleButton = input.Button(input.JoystickButton(joystick, button))
      elseif self.bindingType == 'axis' then
        self.possibleAxis = input.Axis(input.BinaryAxis(input.JoystickButton(joystick, button)))
      else
        error('Unkown binding type: ' .. self.bindingType)
      end
    end)
    self.handles.joystickaxis = self.gameState.signals.register('joystickaxis', function(joystick, axis, value)
      if joystick:getID() ~= self.inputID then return end -- Ignore if this is not our current joystick.
      if math.abs(value) < 0.5 then return end -- Ignore if the axis value is less than 0.5

      self.holdTime = 0
      self.possibleDescription = "Axis " .. axis .. (value > 0 and "+" or "-")
      if self.bindingType == 'button' then
        self.possibleButton = input.Button(input.ThresholdButton(
          input.JoystickAxis(joystick, axis, lume.sign(value)), 0.5))
      elseif self.bindingType == 'axis' then
        self.possibleAxis = input.Axis(input.JoystickAxis(joystick, axis, lume.sign(value)))
      else
        error('Unkown binding type: ' .. self.bindingType)
      end
    end)
  elseif self.inputType == 'gamepad' then
    self.handles.gamepadpressed = self.gameState.signals.register('gamepadpressed', function(joystick, button)
      if joystick:getID() ~= self.inputID then return end -- Ignore if this is not our current joystick.
      self.holdTime = 0
      self.possibleDescription = button
      if self.bindingType == 'button' then
        self.possibleButton = input.Button(input.GamepadButton(joystick, button))
      elseif self.bindingType == 'axis' then
        self.possibleAxis = input.Axis(input.BinaryAxis(input.GamepadButton(joystick, button)))
      else
        error('Unkown binding type: ' .. self.bindingType)
      end
    end)
    self.handles.gamepadaxis = self.gameState.signals.register('gamepadaxis', function(joystick, axis, value)
      if joystick:getID() ~= self.inputID then return end -- Ignore if this is not our current joystick.
      self.holdTime = 0
      self.possibleDescription = axis .. (value > 0 and "+" or "-")
      if self.bindingType == 'button' then
        self.possibleButton = input.Button(input.ThresholdButton(
          input.GamepadAxis(joystick, axis, lume.sign(value)), 0.5))
      elseif self.bindingType == 'axis' then
        self.possibleAxis = input.Axis(input.GamepadAxis(joystick, axis, lume.sign(value)))
      else
        error('Unkown binding type: ' .. self.bindingType)
      end
    end)
  else
    error("Unkown input type: " .. self.inputType)
  end
end
function BindingState:exitedState()
  if self.inputType == 'keyboard' then
    self.gameState.signals.remove('keypressed', self.handles.keypressed)
  elseif self.inputType == 'joystick' then
    self.gameState.signals.remove('joystickpressed', self.handles.joystickpressed)
    self.gameState.signals.remove('joystickaxis', self.handles.joystickaxis)
  elseif self.inputType == 'gamepad' then
    self.gameState.signals.remove('gamepadpressed', self.handles.gamepadpressed)
    self.gameState.signals.remove('gamepadaxis', self.handles.gamepadaxis)
  end
end
function BindingState:update(dt)
  DeviceCard.update(self, dt)
  if self.possibleButton ~= nil then
    self.possibleButton:update()
    if self.possibleButton:isDown() then
      self.holdTime = self.holdTime + dt
      if self.holdTime > DeviceCard.BIND_TIME then
        self.binding:setButton(self.bindingName, self.possibleButton, self.possibleDescription)
        self:gotoState('Binding', self.binding)
      end
    else
      self.possibleButton = nil
      self.holdTime = 0
    end
  end

  if self.possibleAxis ~= nil then
    if self.possibleAxis:getValue() > 0.5 then
      self.holdTime = self.holdTime + dt
      if self.holdTime > DeviceCard.BIND_TIME then
        self.binding:setAxis(self.bindingName, self.possibleAxis, self.possibleDescription)
        self:gotoState('Binding', self.binding)
      end
    else
      self.possibleAxis = nil
      self.holdTime = 0
    end
  end
end
function BindingState:draw()
  DeviceCard.draw(self)
  Color.BLACK:use()
  love.graphics.setFont(DeviceCard.TITLE_FONT)
  love.graphics.printf('Hold ' .. self.bindingTitle, self.pos.x + DeviceCard.MARGIN,
    self.pos.y  + DeviceCard.HEIGHT * 0.25, DeviceCard.WIDTH - DeviceCard.MARGIN * 2, "center")

  local topleft = vector(self.pos.x + DeviceCard.MARGIN, self.pos.y + DeviceCard.HEIGHT/2 - 10)
  local size = vector(DeviceCard.WIDTH - DeviceCard.MARGIN*2, 20)

  if self.holdTime > 0.01 then
    Color.RED:use()
    love.graphics.rectangle('fill', topleft.x, topleft.y, size.x, size.y)
    Color.BLUE:use()
    love.graphics.rectangle('fill', topleft.x, topleft.y, size.x * (self.holdTime / DeviceCard.BIND_TIME), size.y)
    Color.BLACK:use()
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', topleft.x, topleft.y, size.x, size.y)
    love.graphics.setLineWidth(1)
  end
end
```
