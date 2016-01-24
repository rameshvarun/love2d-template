Component = class('Component')

function Component:initialize()
  self.entity = nil -- A reference back to the entity that owns this component.
  self.visible = true -- Whether or not this component should be drawn.
  self.enabled = true -- Whether or not this component should be updated or drawn.
end

-- Overridable callback, invoked after the component is added to an entity.
function Component:start() end
function Component:destroy() end

-- Get and set the owning entity of this component.
function Component:setEntity(entity) self.entity = entity end
function Component:getEntity() return self.entity end

-- Show and hide the component.
function Component:show() self.visible = true end
function Component:hide() self.visible = false end
function Component:isVisible() return self.visible end

-- Disable and enable this component.
function Component:disable() self.enabled = false end
function Component:enable() self.enabled = true end
function Component:isEnabled() return self.enabled end

-- Draw and update callbacks (meant to be overriden).
function Component:draw() end
function Component:debugDraw() end
function Component:overlay() end
function Component:debugOverlay() end
function Component:update(dt) end

-- Load in all of the components.
require_dir "src/components"
