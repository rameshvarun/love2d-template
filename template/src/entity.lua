Entity = class('Entity')

-- Utility to generate a randomized id for an entity.
Entity.static.ID_LENGTH = 5
Entity.static.ID_VALUES = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_'
Entity.static.generateID = function()
  local id = ""
  while id:len() < Entity.ID_LENGTH do
    id = id .. Entity.ID_VALUES:byte(love.math.random(1, Entity.ID_VALUES:len()))
  end
  return id
end

function Entity:initialize(tag, layer, pos)
  -- Argument type checking.
  assert(type(tag) == "string", "'tag' must be a string.")
  assert(type(layer) == "number", "'layer' must be a number.")
  assert(isvector(pos), "'pos' must be a vector. ")

  self.id = Entity.generateID() -- Generate a random ID.

  self.tag = tag -- Some sort of descriptive category for this entity. eg: 'player'
  self.layer = layer -- The layer that this entity is on. Determines draw order.
  self.pos = pos -- The position of this entity (vector). All entities need a
  -- position, though it may not have any semantic meaning. Determines draw order.
  self.components = {} -- The components that make up this entity.
  self.signals = Signal.new() -- A signal dispatcher, for communicating between components.

  self.dead = false -- Whether or not the entity is dead (starts out as false).
  -- Call self:destroy() to mark as dead.
  self.visible = true -- Whether not this entity should be drawn.
  self.enabled = true -- Whether or not this entity should be updated or drawn.

  self.gameState = nil -- Reference to the owning gamestate. Starts out as nil.
end

-- Invoked after an entity has been added to a GameState.
function Entity:start() end

-- Show and hide this entity.
function Entity:hide() self.visible = false end
function Entity:show() self.visible = true end
function Entity:isVisible() return self.visible end

-- Disable and enable this entity.
function Entity:disable() self.enabled = false end
function Entity:enable() self.enabled = true end
function Entity:isEnabled() return self.enabled end

-- Set / get the owning GameState of this entity.
function Entity:setGameState(gameState) self.gameState = gameState end
function Entity:getGameState() return self.gameState end

--[[ Add a newly created component to this object. Returns the component for
compositional purposes. ]]--
function Entity:addComponent(comp)
  comp:setEntity(self) -- Set the owning entity of this component.
  table.insert(self.components, comp) -- Add to components table.
  return comp -- Return the component.
end

--[[ BEWARE: Not very well tested.
'Installs' a component into the current object by delegating all methods
to it. Returns the component for compositional purposes. ]]--
function Entity:includeComponent(comp)
  self:addComponent(comp) -- Add the component, so that it's draw, update, etc. functions will be called.
  for key, value in pairs(comp.class.__instanceDict) do
    if type(value) == "function" and not key:startsWith("__") and
      key ~= "draw" and key ~= "debugDraw" and key ~= "overlay" and
      key ~= "debugOverlay" and key ~= "update" and key ~= "initialize" then
        self[key] = function(_, ...)
          return comp[key](comp, ...)
        end
    end
  end
  return comp -- Return the component.
end

-- Draw and update simply call out to the components.
function Entity:draw()
  for _, comp in ipairs(self.components) do
    if comp.visible and comp.enabled then comp:draw() end
  end
end
function Entity:debugDraw()
  -- Draw a dot at the location of this entity.
  love.graphics.setPointSize(10)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.points(self.pos:unpack())

  -- Invoke the debugDraw method of the components.
  for _, comp in ipairs(self.components) do
    if comp.visible and comp.enabled then comp:debugDraw() end
  end
end
-- Draw and update simply call out to the components.
function Entity:overlay()
  for _, comp in ipairs(self.components) do
    if comp.visible and comp.enabled then comp:overlay() end
  end
end
-- Draw and update simply call out to the components.
function Entity:debugOverlay()
  for _, comp in ipairs(self.components) do
    if comp.visible and comp.enabled then comp:debugOverlay() end
  end
end

function Entity:update(dt)
  for _, comp in ipairs(self.components) do
    if comp.enabled then comp:update(dt) end
  end
end

function Entity:destroy() self.dead = true end -- Mark this entity for removal.

require_dir "src/entities"
