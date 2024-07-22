require("TESound.tesound")

-- local Push = require("push.push")
local World = require("world.world")
local WorldData = require("resources.game_object_data.worlds")



-- Setup Resolution Solution.
local rs = require("resolution_solution.resolution_solution")

-- Configure Resolution Solution to 640x480 game with Aspect Scaling mode.
rs.conf({
    game_width = 1920,
    game_height = 1080,
    scale_mode = rs.ASPECT_MODE
  })

-- Make window resizable.
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

-- Change "black" bars color to blue.
love.graphics.setBackgroundColor(0.3, 0.5, 1)

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

-- Change scaling mode at runtime.
love.keypressed = function(key)
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

   -- local gameWidth, gameHeight = 1920, 1200 --fixed game resolution
   -- local windowWidth, windowHeight = love.window.getDesktopDimensions()
   -- windowWidth, windowHeight = windowWidth*.7, windowHeight*.7 --make the window a bit smaller than the screen itself
   --
   -- Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})
   -- -- Push:setupScreen(1920, 1080, love.graphics.getWidth(), love.graphics.getHeight(), {fullscreen = false, resizable = true, pixelperfect = true})
end

function love.update(dt)

   if love.keyboard.isDown('escape') then
       love.event.push('quit')
   end

   -- local dbg = require 'debugger.debugger'; dbg()
   world:update(dt)

   TEsound.cleanup()

end

function love.draw()
   -- Setup canvas.
   love.graphics.setCanvas(game_canvas)
   -- Clear it to avoid artefacts. Refer to love wiki.
   love.graphics.clear(0, 0, 0, 1)

   world:draw(sprites.img)

   -- Print some hints.
   love.graphics.print("Try to resize window!", 0, 0)
   love.graphics.print("Press F1, F2, F3, F4 to change scale mode.", 0, 20)

  -- Once we done with drawing, lets close canvas.
  love.graphics.setCanvas()

   -- Start scaling.
   rs.push()
      -- Scale our canvas.
      love.graphics.draw(game_canvas)
   -- Stop scaling.
   rs.pop()

   -- Push:start()



   -- world:draw(sprites.img)

   -- sprites:debug_draw_green_lasers()

   -- love.graphics.printf("Hello World", 0, love.graphics.getHeight() / 2 , love.graphics.getWidth(), "center")

   -- Push:finish()

end

-- function love.resize(w, h)
--   return Push:resize(w, h)
-- end
