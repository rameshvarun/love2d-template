--[[ CollisionWorld mixin. This mixin can be included into a GameState, providing functions that interface with
the HardonCollider collision library. ]]--
CollisionWorld = {
  -- Create a new collision world, using an optional cell_size.
  createCollisionWorld = function(self, cell_size)
    self.collider = HC.new(cell_size) -- A collision detection 'world'.
  end
}

-- Delegate these methods to self.collider.
local METHODS_TO_DELEGATE = { 'rectangle', 'polygon', 'circle', 'point', 'remove', 'collisions', 'neighbors' }
for _, method in ipairs(METHODS_TO_DELEGATE) do
  CollisionWorld[method] = function(self, ...)
    self.collider[method](self.collider, ...)
  end
end
