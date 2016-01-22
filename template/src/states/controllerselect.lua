ControllerSelect = class('ControllerSelect', GameState)
ControllerSelect.static.MIN_PLAYERS = 1 -- The minimum number of players required to start a game.
ControllerSelect.static.MAX_PLAYERS = 8 -- The maximum number of players that can be in a game.
ControllerSelect.static.CARDS_PER_ROW = 4 -- The number of device cards that should be shown per row.
ControllerSelect.static.TITLE_FONT = love.graphics.newFont(30) -- Font for displaying information in this menu.
ControllerSelect.static.BUTTONS = {'action', 'special', 'pause'} -- Buttons that must be bound for every player.
ControllerSelect.static.AXES = {'left', 'right', 'up', 'down'} -- Axes that must be bound for every player.

Binding = class('Binding')
function Binding:initialize()
  self.buttons, self.axes, self.descriptions = {}, {}, {}
end
function Binding:isComplete()
  for _, button in ipairs(ControllerSelect.BUTTONS) do
    if self.buttons[button] == nil then return false end
  end
  for _, axis in ipairs(ControllerSelect.AXES) do
    if self.axes[axis] == nil then return false end
  end
  return true
end
function Binding:setButton(buttonName, button, description)
  self.buttons[buttonName] = button
  self.descriptions[buttonName] = description
end
function Binding:setAxis(axisName, axis, description)
  self.axes[axisName] = axis
  self.descriptions[axisName] = description
end
function Binding:getNextBindSlot()
  for _, axis in ipairs(ControllerSelect.AXES) do
    if self.axes[axis] == nil then return 'axis', axis end
  end
  for _, button in ipairs(ControllerSelect.BUTTONS) do
    if self.buttons[button] == nil then return 'button', button end
  end
  return nil
end
function Binding:getText()
  local text = ""
  for _, axis in ipairs(ControllerSelect.AXES) do
    text = text .. axis:sub(1, 1):upper() .. axis:sub(2, -1) .. " - " ..self.descriptions[axis] .. "\n"
  end
  for _, button in ipairs(ControllerSelect.BUTTONS) do
    text = text .. button:sub(1, 1):upper() .. button:sub(2, -1) .. " - " ..self.descriptions[button] .. "\n"
  end
  return text
end
function Binding:getAxis(axis) return self.axes[axis] end
function Binding:getButton(button) return self.buttons[button] end

-- The control menu can surface default bindings for keyboards and gamepads (known joysticks).
ControllerSelect.static.KEYBOARD_DEFAULT = function() -- Default bindings for a keyboard player.
  local binding = Binding()
  binding:setButton('action', input.Button(input.Key('z')), 'z')
  binding:setButton('special', input.Button(input.Key('x')), 'x')
  binding:setButton('pause', input.Button(input.Key('escape')), 'escape')

  binding:setAxis('right', input.Axis(input.BinaryAxis(input.Key('right'))), 'right')
  binding:setAxis('left', input.Axis(input.BinaryAxis(input.Key('left'))), 'left')
  binding:setAxis('up', input.Axis(input.BinaryAxis(input.Key('up'))), 'up')
  binding:setAxis('down', input.Axis(input.BinaryAxis(input.Key('down'))), 'down')
  return binding
end
ControllerSelect.static.GAMEPAD_DEFAULT = function(joystickID) -- Default bindings for a gamepad player.
  local joystick = nil
  for _, joy in ipairs(love.joystick.getJoysticks()) do
    if joy:getID() == joystickID then joystick = joy end
  end
  assert(joystick ~= nil)
  assert(joystick:isGamepad() == true)

  local binding = Binding()
  binding:setButton('action', input.Button(input.GamepadButton(joystick, 'a')), 'a')
  binding:setButton('special', input.Button(input.GamepadButton(joystick, 'b')), 'b')
  binding:setButton('pause', input.Button(input.GamepadButton(joystick, 'start')), 'start')

  binding:setAxis('right', input.Axis(input.GamepadAxis(joystick, 'leftx', 1)), 'leftx+')
  binding:setAxis('left', input.Axis(input.GamepadAxis(joystick, 'leftx', -1)), 'leftx-')

  binding:setAxis('up', input.Axis(input.GamepadAxis(joystick, 'lefty', -1)), 'lefty+')
  binding:setAxis('down', input.Axis(input.GamepadAxis(joystick, 'lefty', 1)), 'lefty-')
  return binding
end

function ControllerSelect:initialize(continuation)
  GameState.initialize(self)
  self.continuation = continuation
  local rows = math.ceil(ControllerSelect.MAX_PLAYERS / ControllerSelect.CARDS_PER_ROW)
  local padding = 20

  self.cards = {}
  for i=1, ControllerSelect.MAX_PLAYERS do
    local row = math.floor((i - 1) / ControllerSelect.CARDS_PER_ROW)
    local positionInRow = (i - 1) % ControllerSelect.CARDS_PER_ROW
    local top = love.graphics.getHeight()/2 - (rows * (DeviceCard.HEIGHT + padding) + padding)/2
    local ypos = top + padding + row*(DeviceCard.HEIGHT + padding)
    local left = love.graphics.getWidth()/2 - (padding + ControllerSelect.CARDS_PER_ROW*(DeviceCard.WIDTH + padding)) / 2
    local xpos = left + positionInRow*(DeviceCard.WIDTH + padding)

    table.insert(self.cards, self:addEntity(DeviceCard(vector(xpos, ypos))))
  end
end

function ControllerSelect:canDeviceJoin(inputID)
  for _, card in ipairs(self.cards) do
    if card.inputID == inputID then return false end
  end
  return true
end

function ControllerSelect:firstAvailableCard()
  for i, card in ipairs(self.cards) do
    if card.inputID == nil then return card end
  end
  return nil
end

--[[ This helper function counts the number of DeviceCards that are not in the "Unfilled" or
"Joining" state. ]]--
function ControllerSelect:numberOfJoinedDevices()
  local count = 0
  for _, card in ipairs(self.cards) do
    if card:hasJoined() then count = count + 1 end
  end
  return count
end

function ControllerSelect:draw()
  GameState.draw(self)
  Color.WHITE:use()
  love.graphics.setFont(ControllerSelect.TITLE_FONT)

  if self:numberOfJoinedDevices() < ControllerSelect.MIN_PLAYERS then
    love.graphics.printf((ControllerSelect.MIN_PLAYERS - self:numberOfJoinedDevices()) ..
      " more players needed...", 0, 15, love.graphics.getWidth(), 'center')
  end
end

function ControllerSelect:update(dt)
  GameState.update(self, dt)

  -- If more than the minimum number of players have joined.
  if self:numberOfJoinedDevices() >= ControllerSelect.MIN_PLAYERS then
    -- Check if all joined players are ready.
    local ready = true
    for _, card in ipairs(self.cards) do
      if card:hasJoined() and card:isReady() == false then
        ready = false
        break
      end
    end

    if ready then
      print("All players are ready.")
      if self.continuation ~= nil then self.continuation() end
    end
  end
end

function ControllerSelect:keypressed(key, isrepeat)
  GameState.keypressed(self, key, isrepeat)
  if self:canDeviceJoin('keyboard') then
    local card = self:firstAvailableCard()
    if card ~= nil then
      card:gotoState('Joining', 'keyboard', 'keyboard', 'Keyboard', input.Button(input.Key(key)))
    end
  end
end

function ControllerSelect:joystickpressed(joystick, button)
  GameState.joystickpressed(self, joystick, button)
  if self:canDeviceJoin(joystick:getID()) then
    local card = self:firstAvailableCard()
    if card ~= nil then
      if joystick:isGamepad() then
        card:gotoState('Joining', 'gamepad', joystick:getID(), joystick:getName(), input.Button(
          input.JoystickButton(joystick, button)))
      else
        card:gotoState('Joining', 'joystick', joystick:getID(), joystick:getName(), input.Button(
          input.JoystickButton(joystick, button)))
      end
    end
  end
end
