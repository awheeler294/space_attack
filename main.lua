local GameObjects = require "game_objects.game_objects"

local backdrop = {}

local game_objects = {
   player_idx = 0,

   insertPlayer = function(self, player)
      table.insert(self.friendlies, player)
      self.player_idx = #self.friendlies
   end,

   getPlayer = function(self)
      return self.friendlies[self.player_idx]
   end,

   friendlies = {},
   hostiles = {},

   update = function(self, dt)

      for i = #self.friendlies, 1, -1 do
         local f = self.friendlies[i]

         for _, h in ipairs(self.hostiles) do
            f:maybeCollide(h)
         end

         f:update(dt)

         if f.state == GameObjects.State.dead then
            table.remove(self.friendlies, i)
         end

         local attack_result = f:maybeAttack()
         if attack_result then
            table.insert(self.friendlies, attack_result)
         end

      end

      for i = #self.hostiles, 1, -1 do
         local h = self.hostiles[i]

         h:update(dt)

         if h.state == GameObjects.State.dead then
            table.remove(self.hostiles, i)
         end

         local attack_result = h:maybeAttack()
         if attack_result then
            table.insert(self.hostiles, attack_result)
         end

      end

   end,

   draw = function(self, sprite_sheet)

      for _, o in ipairs(self.friendlies) do
         o:draw(sprite_sheet)
      end

      for _, o in ipairs(self.hostiles) do
         o:draw(sprite_sheet)
      end

   end,
}

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

   sprites.data = require("resources/game_object_data/spritesheet/sheet")
   sprites.img = love.graphics.newImage("resources/game_object_data/spritesheet/" .. sprites.data.image_path)

   backdrop.img = love.graphics.newImage("resources/backgrounds/blue.png")

   game_objects:insertPlayer(GameObjects.build_player(sprites.data, sprites.img))

   local enemy_margin_h = 50
   local enemy_margin_v = 50

   local w = sprites.data.textures.ufoGreen.width
   local h = sprites.data.textures.ufoGreen.height

   for r=1, 3 do
      for c=1, 10 do
         local x = enemy_margin_h + c * (w * 1.5)
         local y = enemy_margin_v + r * (h * 1.5)
         -- print("x: ", x)
         table.insert(game_objects.hostiles, GameObjects.build_saucer(sprites.data, x, y, sprites.img))
      end
   end

end

function love.update(dt)

   if love.keyboard.isDown('escape') then
       love.event.push('quit')
   end

   game_objects:update(dt)

end

function love.draw()

   for y=1, love.graphics.getHeight(), backdrop.img:getHeight() do
      for x=1, love.graphics.getWidth(), backdrop.img:getWidth() do
         love.graphics.draw(backdrop.img, x, y)
      end
   end

   game_objects:draw(sprites.img)

   -- sprites:debug_draw_green_lasers()

   -- love.graphics.printf("Hello World", 0, love.graphics.getHeight() / 2 , love.graphics.getWidth(), "center")
end
