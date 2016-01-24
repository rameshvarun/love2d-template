--[[ PhysicsWorld mixin. This mixin can be included into GameStates to allow for the
convenient creation and manipulation of a love.physics World object. ]]--
PhysicsWorld = {
  -- Call this to initialize the physics world.
  createPhysicsWorld = function(self, gravity, sleep)
    assert(vector.isvector(gravity), 'gravity is a vector')
    self.world = love.physics.newWorld(gravity.x, gravity.y, sleep)
  end,
  -- Call this function with a dt in order to step the physics simulation forward.
  updatePhysicsWorld = function(self, dt) self.world:update(dt) end,
  --  Get the physics world object.
  getPhysicsWorld = function(self) return self.world end
}
