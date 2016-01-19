ImageComponent = class('ImageComponent', Component)

function ImageComponent:initialize(image, options)
  Component.initialize(self)

  self.image = image

  options = options or {}
  self.offset = options.offset or vector(0, 0)
  self.tint = options.tint or {255, 255, 255}
  self.alpha = options.alpha or 255
  self.angle = options.angle or 0
  self.scale = options.scale or vector(1, 1)
  self.origin = options.origin or vector(0, 0)
  self.shear = options.shear or vector(0, 0)
end

function ImageComponent:draw()
  Component.draw(self)
  love.graphics.setColor(self.tint[1], self.tint[2], self.tint[3], self.alpha)
  love.graphics.draw(self.image, self.entity.pos.x + self.offset.x, self.entity.pos.y + self.offset.y, self.angle,
    self.scale.x, self.scale.y, self.origin.x, self.origin.y, self.shear.x, self.shear.y)
end

function ImageComponent:fadeOut(duration)
  self.entity.gameState.timer.tween(duration, self, {alpha = 0})
end
