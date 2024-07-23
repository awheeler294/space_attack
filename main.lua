require("TESound.tesound")
local rs = require("resolution_solution.resolution_solution")

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
end

local world = {}

local sprites = {
   debug_draw_blue_lasers = function(self)
      self:debug_draw({
         self.data.textures.laserBlue01,
         self.data.textures.laserBlue02,
         self.data.textures.laserBlue03,
         self.data.textures.laserBlue04,
         self.data.textures.laserBlue05,
         self.data.textures.laserBlue06,
         self.data.textures.laserBlue07,
         self.data.textures.laserBlue08,
         self.data.textures.laserBlue09,
         self.data.textures.laserBlue10,
         self.data.textures.laserBlue11,
         self.data.textures.laserBlue12,
         self.data.textures.laserBlue13,
         self.data.textures.laserBlue14,
         self.data.textures.laserBlue15,
         self.data.textures.laserBlue16,
      })
   end,

   debug_draw_green_lasers = function(self)
      self:debug_draw({
         self.data.textures.laserGreen01,
         self.data.textures.laserGreen02,
         self.data.textures.laserGreen03,
         self.data.textures.laserGreen04,
         self.data.textures.laserGreen05,
         self.data.textures.laserGreen06,
         self.data.textures.laserGreen07,
         self.data.textures.laserGreen08,
         self.data.textures.laserGreen09,
         self.data.textures.laserGreen10,
         self.data.textures.laserGreen11,
         self.data.textures.laserGreen12,
         self.data.textures.laserGreen13,
         self.data.textures.laserGreen14,
         self.data.textures.laserGreen15,
         self.data.textures.laserGreen16,
      })
   end,

   debug_draw = function(self, textures)
      for i, texture in ipairs(textures) do

         love.graphics.setColor(1, 1, 1)
         local frame = love.graphics.newQuad(texture.x, texture.y, texture.width, texture.height, self.img:getDimensions())
         local x = 100 * i
         local y = 1000
         love.graphics.print("" .. i, x, y - 50)
         love.graphics.draw(self.img, frame, x, y)
      end
   end,
}


function love.load()
   love.window.setTitle("Space Attack!")

   love.graphics.setNewFont(24)

   world = World.new(WorldData.game_world)
end

function love.update(dt)

   if love.keyboard.isDown('escape') then
       love.event.push('quit')
   end

   if love.keyboard.isDown('r') then
      world = World.new(WorldData.game_world)
   end

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
