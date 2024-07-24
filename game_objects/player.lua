require("TESound.tesound")
local rs = require("resolution_solution.resolution_solution")

local Animation = require("animation")
local GameObject = require("game_objects.game_objects")
local Lasers = require("resources.game_object_data.lasers")
local Sounds = require("resources.audio.sounds")
local Sprites = require("resources.sprites.sprites")
local Weapons = require("game_objects.weapons")


local powerup_data = {
   {
      weapon = Lasers.LaserGun,
      shot_type = Lasers.BlueLaser,
   },

   {
      weapon = Lasers.LaserGun2,
      shot_type = Lasers.BlueLaser,
   },

   {
      weapon = Lasers.LaserGun2,
      shot_type = Lasers.BlueLaser2,
   },

   {
      weapon = Lasers.LaserGun3,
      shot_type = Lasers.BlueLaser2,
   },
}

return {
   new = function(sprite, x, y)

      local speed = 600
      local max_health = 4
      local health = max_health
      local damage = 1

      local dying_sound = Sounds.crunchy_explosions

      local player = GameObject.new(
         x, y, speed, health, damage, sprite, dying_sound
      )

      player.dying_animation = Animation.create_scaling_animation(Sprites.laserBlue08, player.width)

      player.powerup_level = 0

      player.powerup = function(self, power)

         self.powerup_level = self.powerup_level + power

         local power_idx = math.min(self.powerup_level, #powerup_data)

         local new_weapon = Weapons.build_gun (
            self.width / 2,
            self.height,
            powerup_data[power_idx].weapon,
            powerup_data[power_idx].shot_type
         )

         if self.weapon then
            new_weapon.cooldown = self.weapon.cooldown
         end

         self.weapon = new_weapon

      end

      player:powerup(1)

      player.max_health = max_health

      player.damage_textures = {
         Sprites.playerShip1_damage1,
         Sprites.playerShip1_damage2,
         Sprites.playerShip1_damage3,
      }

      player.render = function(self)
         love.graphics.push()
            love.graphics.translate(self.x, self.y)
            love.graphics.shear(self.shear_x, self.shear_y)

            love.graphics.draw(self.sprite, 0, 0)

            local health_diff = math.floor(self.max_health - self.health)

            if health_diff > 0 then
               if health_diff > #self.damage_textures then
                  health_diff = #self.damage_textures
               end
               love.graphics.draw(self.damage_textures[health_diff], 0, 0)
            end

         love.graphics.pop()

      end

      player.draw = function(self)

         local render = {
            [GameObject.State.alive] = function()
               self:render()
            end,

            [GameObject.State.dying] = function()
               if self.dying_animation.scale_rate > 0 then
                  self:render()
               end

               local center_x = self.x + self.width / 2
               local center_y = self.y + self.height / 2
               -- love.graphics.circle("fill", center_x, center_y, 5)
               self.dying_animation:draw(center_x, center_y, self.rotation)
            end,

            [GameObject.State.dead] = function()
            end,
         }

         render[self.state]()

      end

      player.update = function(self, dt)

         self:update_collision()

         self.weapon:update(dt)

         local shear_x = 0

         if love.keyboard.isDown("right", "d") then
            if self.x < (rs.game_width - self.width - 10) then
               self.x = self.x + (self.speed * dt)
               shear_x = 1
            end
         end

         if love.keyboard.isDown("left", "a") then
            if self.x > 10 then
               self.x = self.x - (self.speed * dt)
               shear_x = -1
            end
         end

         if love.keyboard.isDown("up", "w") then
            if self.y > 10 then
               self.y = self.y - (self.speed * dt)
            end
         end

         if love.keyboard.isDown("down", "s") then
            if self.y < (rs.game_height - self.height - 10) then
               self.y = self.y + (self.speed * dt)
            end
         end

         self.shear_x = shear_x / 20

         if self.health <= 0 and self.state == GameObject.State.alive then
            self.state = GameObject.State.dying
            TEsound.play(Sounds.low_frequency_explosions, 'static')
            TEsound.play(self.dying_sound, 'static')
         end

         if self.state == GameObject.State.dying then

            self.dying_animation:update(dt)

            if self.dying_animation.state == Animation.State.stopped then
               self.state = GameObject.State.dead
            end

         end

      end

      player.maybeAttack = function(self)
         if self.state == GameObject.State.alive then
            for _, j in ipairs(love.joystick.getJoysticks()) do
		if j:isGamepadDown("a", "b", "x", "y") then
		   return self.weapon:maybeAttack(self.x, self.y)
		end
	    end
            if love.keyboard.isDown('space') then
               return self.weapon:maybeAttack(self.x, self.y)
            end
         end

      end

      return player

   end
}
