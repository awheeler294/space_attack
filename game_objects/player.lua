require("TESound.tesound")

local Sounds = require("resources.audio.sounds")
local GameObject = require("game_objects.game_object")
local AnimationState = GameObject.AnimationState
local Weapons = require("game_objects.weapons")
local create_scaling_animation = GameObject.create_scaling_animation

return {
   new = function(sprite_data, sprites)

      local x = love.graphics.getWidth() / 2
      local y = love.graphics.getHeight() / 1.15

      local speed = 600
      local health = 1
      local damage = 1

      local texture = sprite_data.textures.playerShip1_blue
      local texture_quad = love.graphics.newQuad(
         texture.x, texture.y, texture.width, texture.height, sprites:getDimensions()
      )

      local dying_sound = Sounds.crunchy_explosions

      local player = GameObject.new(
         x, y, texture.width, texture.height, speed, health, damage, texture_quad, dying_sound
      )

      player.dying_animation = create_scaling_animation(sprite_data.textures.laserBlue08, player.width, sprites)
      player.weapon = Weapons.build_blue_laser_gun(
         player.width / 2, player.height, sprites
      )

      player.render = function(self)
         love.graphics.translate(self.x, self.y)
         love.graphics.shear(self.shear_x, self.shear_y)

         love.graphics.draw(sprites, self.sprite, 0, 0)

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
