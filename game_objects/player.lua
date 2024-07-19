require("TESound.tesound")

local Sounds = require("resources.audio.sounds")
local Sprites = require("resources.sprites.sprites")
local GameObject = require("game_objects.game_objects")
local AnimationState = GameObject.AnimationState
local Weapons = require("game_objects.weapons")
local create_scaling_animation = GameObject.create_scaling_animation

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

      player.dying_animation = create_scaling_animation(Sprites.laserBlue08, player.width)

      player.weapon = Weapons.build_blue_laser_gun(
         player.width / 2, player.height
      )

      player.max_health = max_health

      player.damage_textures = {
         Sprites.playerShip1_damage1,
         Sprites.playerShip1_damage2,
         Sprites.playerShip1_damage3,
      }

      player.render = function(self)
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

         love.graphics.origin()

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

         self:update_collision(dt)

         self.weapon:update(dt)

         local shear_x = 0

         if love.keyboard.isDown('d') then
            if self.x < (love.graphics.getWidth() - self.width - 10) then
               self.x = self.x + (self.speed * dt)
               shear_x = 1
            end
         end

         if love.keyboard.isDown('a') then
            if self.x > 10 then
               self.x = self.x - (self.speed * dt)
               shear_x = -1
            end
         end

         if love.keyboard.isDown('w') then
            if self.y > 10 then
               self.y = self.y - (self.speed * dt)
            end
         end

         if love.keyboard.isDown('s') then
            if self.y < (love.graphics.getHeight() - self.height - 10) then
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

            if self.dying_animation.state == AnimationState.stopped then
               self.state = GameObject.State.dead
            end

         end

      end

      player.maybeAttack = function(self)
         if love.keyboard.isDown('space') and self.state == GameObject.State.alive then
            return self.weapon:maybeAttack(self.x, self.y)
         end

      end

      return player

   end
}
