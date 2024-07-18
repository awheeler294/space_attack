require("TESound.tesound")

local World = require("world.world")
local WorldData = require("resources.game_object_data.worlds")

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

   -- local dbg = require 'debugger.debugger'; dbg()
   world:update(dt)

   TEsound.cleanup()

end

function love.draw()


   world:draw(sprites.img)

   -- sprites:debug_draw_green_lasers()

   -- love.graphics.printf("Hello World", 0, love.graphics.getHeight() / 2 , love.graphics.getWidth(), "center")
end
