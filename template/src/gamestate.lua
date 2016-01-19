GameState = class('GameState')

GameState.static.debugFont = love.graphics.newFont(12)

-- Store the current, active GameState in a static variable.
GameState.static.currentState = nil
-- Static method to switch to a game state.
function GameState.static.switchTo(state)
  -- If we are moving away from an existing state, invoke the 'exit' function.
  if GameState.static.currentState ~= nil then
    GameState.static.currentState:exit()
  end

  -- Transition to the new state and invoke the 'enter' function.
  GameState.static.currentState = state
  GameState.static.currentState:enter()
end

-- Default draw order for entities.
function GameState.static.defaultDrawOrder(a, b)
	if a.layer == b.layer then -- If the layers are equal, try to sort by y-position.
    if math.abs(a.pos.y - b.pos.y) < 0.01 then
      -- If the positions are very similar, sort by id (just to get some determinism).
      return a.id < b.id
    else
      return a.pos.y < b.pos.y
    end
	else return a.layer < b.layer end
end

function GameState:initialize()
  self.timer = Timer.new() -- Timer for handling tweening and delayed callbacks.
  self.cam = Camera.new() -- Camera for the scene.
  self.entities = {} -- A list of entities in the scene.
  self.signals = Signal.new() -- A signal dispatcher.
  self.collider = HC.new()
  self.time = 0
end

function GameState:update(dt)
  -- Use F2 in while in debug mode to speed up the time.
  if DEBUG and love.keyboard.isDown('f2') then dt = dt*5 end
  -- Update total time.
  self.time = self.time + dt
  -- Step the timer / tweening system for this state forward.
  self.timer.update(dt)
  -- Update every entity one step.
  for _, entity in ipairs(self.entities) do entity:update(dt) end
  -- Prune dead entities.
  self.entities = lume.reject(self.entities, function(e) return e.dead end)
end

function GameState:draw()
  -- Sort entities - first by layer, then by y-position
  self.entities = lume.sort(self.entities, GameState.defaultDrawOrder)

  -- Perform regular draw and debug with the camera transformation.
  self.cam:attach()
  for _, entity in ipairs(self.entities) do
    if entity.visible then entity:draw() end
  end
  if DEBUG then
    for _, entity in ipairs(self.entities) do
      if entity.visible then entity:debugDraw() end
    end
  end
  self.cam:detach()

  -- Draw overlays without camera transformation.
  for _, entity in ipairs(self.entities) do
    if entity.visible then
      entity:overlay()
      if DEBUG then entity:debugOverlay() end
    end
  end

  if DEBUG then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(GameState.debugFont)
    local worldx, worldy =  self.cam:mousePosition()
    love.graphics.print("Mouse Position (World): " .. worldx .. ", " .. worldy, 0, 80)
  end
end

function GameState:addEntity(entity)
  assert(entity:isInstanceOf(Entity)) -- Assert that the argument is an instance of Entity.
  entity:setGameState(self) -- Give the entity a reference to the current GameState.
  entity:start() -- 'Start' the entity.
  table.insert(self.entities, entity) -- Add the entity to the table of entities.
  return entity -- Return the entity (for compositional purposes).
end

-- Input events.
function GameState:keypressed(...) self.signals.emit('keypressed', ...) end
function GameState:keyreleased(...) self.signals.emit('keyreleased', ...) end
function GameState:mousepressed(...) self.signals.emit('mousepressed', ...) end
function GameState:mousereleased(...) self.signals.emit('mousereleased', ...) end

-- Empty enter and exit functions.
function GameState:enter() end
function GameState:exit() end

-- Get the first entity that has a certain tag.
function GameState:getEntityByTag(tag)
  for _, entity in ipairs(self.entities) do
    if entity.tag == tag then return entity end
  end
end

-- Get a list of all entities with a certain tag.
function GameState:getEntitiesByTag(tag)
  local entities = {}
  for _, entity in ipairs(self.entities) do
    if entity.tag == tag then table.insert(entities, entity) end
  end
  return entities
end

require_dir "src/states"
