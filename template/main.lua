-- Global 'DEBUG' flag
DEBUG = true

require "utils"

-- Install some libraries into the global namespace.
_ = require "vendor.underscore"
class = require "vendor.middleclass"
vector = require "vendor.vector"
lume = require "vendor.lume"
Timer = require "vendor.timer"
Signal = require 'vendor.signal'
Stateful = require 'vendor.stateful'
Camera  = require 'vendor.camera'
Actions = require 'vendor.actions'
debugGraph = require 'vendor.debugGraph'
assets = require("vendor.cargo").init('assets')
HC = require "vendor.hc"


require "src.component" -- Load in components.
require "src.entity" -- Load in entities.
require "src.gamestate" -- Load in game states.

require_dir "script/" -- Load in script.
require_dir "src/combat" -- Load in combat stuff.

function love.load(arg)
  -- Debug graphs.
  FPSGraph = debugGraph:new('fps', 0, 0)
  MemGraph = debugGraph:new('mem', 0, 40)

  -- GameState.switchTo(GameState())
end

function love.draw()
  -- If there is a current gamestate, draw it.
  if GameState.currentState ~= nil then
    GameState.currentState:draw()
  end

  if DEBUG then
    FPSGraph:draw()
    MemGraph:draw()
  end
end

function love.update(dt)
  if DEBUG then
    FPSGraph:update(dt)
    MemGraph:update(dt)
    require("vendor.lurker").update() -- Update lurker (live code-reloading).
    require("vendor.lovebird").update() -- Update lovebird (web console).
  end

  Timer.update(dt) -- Update global timer events.

  -- If there is a current GameState, update it.
  if GameState.currentState ~= nil then
    GameState.currentState:update(dt)
  end
end

function love.keypressed(key, isrepeat)
  if key == 'f1' then
    DEBUG = not DEBUG
  elseif GameState.currentState ~= nil then
    GameState.currentState:keypressed(key, isrepeat)
  end
end

function love.mousereleased(...)
  if GameState.currentState ~= nil then
    GameState.currentState:mousereleased(...)
  end
end
