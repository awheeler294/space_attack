require("TESound.tesound")
local rs = require("resolution_solution.resolution_solution")

local Fonts = require("resources.fonts.fonts")
local World = require("world.world")
local WorldData = require("resources.game_object_data.worlds")

rs.conf({
    game_width = 1920,
    game_height = 1080,
    scale_mode = rs.ASPECT_MODE
  })

rs.setMode(rs.game_width, rs.game_height, {resizable = true})

-- Change "black" bars color
-- love.graphics.setBackgroundColor(love.math.colorFromBytes(29, 31, 33))
love.graphics.setBackgroundColor(love.math.colorFromBytes(38, 39, 43))

-- Setup Resolution Solution canvas, which will be scaled later.
-- Set canvas to size of game.
-- Note:
-- If you going to implement several resolutions in your game
-- e,g 800x600, 1920x1080, etc
-- then you need to re-create this canvas with new game size.
local game_canvas = love.graphics.newCanvas(rs.get_game_size())

-- Update Resolution Solution once window size changes.
love.resize = function(w, h)
   rs.resize(w, h)
end

local world = {
   handle_keypress = function(_, _) end,
   update = function(_) end,
   draw = function(_) end,
}

love.keypressed = function(key)
   -- Change scaling mode at runtime.
   if key == "f1" then
      rs.conf({scale_mode = rs.ASPECT_MODE})
   elseif key == "f2" then
      rs.conf({scale_mode = rs.STRETCH_MODE})
   elseif key == "f3" then
      rs.conf({scale_mode = rs.PIXEL_PERFECT_MODE})
   elseif key == "f4" then
      rs.conf({scale_mode = rs.NO_SCALING_MODE})
   end

   local result = world:handle_keypress(key)

   if result == World.menu_items.restart then
      world = World.new(WorldData.game_world)
   end
end

local sprites = {}

function love.load()
   love.window.setTitle("Space Attack!")

   love.graphics.setFont(Fonts.normal)

   world = World.new(WorldData.game_world)

end

function love.update(dt)

   -- local dbg = require 'debugger.debugger'; dbg()
   world:update(dt)

   TEsound.cleanup()

end

function love.draw()

   love.graphics.setCanvas(game_canvas)
   love.graphics.clear(0, 0, 0, 1)

   world:draw(sprites.img)

   -- love.graphics.print("Try to resize window!", 0, 0)
   -- love.graphics.print("Press F1, F2, F3, F4 to change scale mode.", 0, 20)

  love.graphics.setCanvas()

   rs.push()
      love.graphics.draw(game_canvas)
   rs.pop()
end
