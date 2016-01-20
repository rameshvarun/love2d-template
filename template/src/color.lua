Color = class('Color')

function Color:initialize(r, g, b, a)
  assert(type(r) == "number", "'r' must be a number.")
  assert(type(g) == "number", "'g' must be a number.")
  assert(type(b) == "number", "'b' must be a number.")

  self.r = r
  self.g = g
  self.b = b
  self.a = a or 255
end

function Color:rgb() return self.r, self.g, self.b end
function Color:rgba() return self.r, self.g, self.b, self.a end

WHITE = Color(255, 255, 255, 255)
BLACK = Color(0, 0, 0, 255)
TRANSPARENT = Color(0, 0, 0, 0)

RED = Color(255, 0, 0, 255)
GREEN = Color(0, 255, 0, 255)
BLUE = Color(0, 0, 255, 255)

YELLOW = Color(255, 255, 0, 255)
PURPLE = Color(255, 0, 255, 255)
CYAN = Color(0, 255, 255, 255)

return Color
