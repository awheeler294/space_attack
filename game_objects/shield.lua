local GameObject = require("game_objects.game_objects")
local Sounds = require("resources.audio.sounds")
local Sprites = require("resources.sprites.sprites")

local ShieldData = {
   speed = 0,
   health = 3,
   damage = 1,
   dying_sound = Sounds.laser_explosions,
   x_offset = 0,
   y_offset = 5,

   sprites = {
      Sprites.shield1,
      Sprites.shield2,
      Sprites.shield3,
   }
}

return {
   new = function(x, y, rotation)
      local sprite = ShieldData.sprites[math.min(ShieldData.health, #ShieldData.sprites)]

      local shield = GameObject.new(
         x,
         y,
         ShieldData.speed,
         ShieldData.health,
         ShieldData.damage,
         sprite,
         ShieldData.dying_sound
      )

      shield.rotation = rotation or 0

      shield.update = function (self, shielded_object)
         self.x = shielded_object.x + ShieldData.x_offset + shielded_object.width / 2 - self.sprite:getWidth() / 2
         self.y = shielded_object.y - ShieldData.y_offset + shielded_object.height / 2 - self.sprite:getHeight() / 2

         if self.health > 0 then
            self.sprite = ShieldData.sprites[math.min(self.health, #ShieldData.sprites)]
         end
      end

      shield.draw = function(self)
         love.graphics.push()
            love.graphics.rotate(self.rotation)
            love.graphics.translate(self.x, self.y)
            love.graphics.draw(self.sprite, 0, 0)
         love.graphics.pop()
      end

      return shield
   end,
}
