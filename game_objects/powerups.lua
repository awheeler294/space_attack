
local GameObject = require("game_objects.game_objects")
local Sprites = require("resources.sprites.sprites")
local rs = require("resolution_solution.resolution_solution")

return {
   new = function(x, y)

      local speed = 500
      local health = 1
      local damage = 0

      local sprite = Sprites.powerupBlue_bolt

      local cx = x - sprite:getWidth() / 2
      local cy = y + sprite:getHeight() / 2

      local powerup = GameObject.new(
         cx, cy, speed, health, damage, sprite
      )

      powerup.powerup_amount = 1

      powerup.update = function(self, dt)
         self:update_collision()
         self.y = self.y + self.speed * dt

         if self.health <= 0
         or self.y > rs.game_height then
            self.state = GameObject.State.dead
         end

      end

      powerup.draw = function(self)
         love.graphics.draw(self.sprite, self.x, self.y)
      end

      return powerup

   end,

}
