local Sounds = require("resources.audio.sounds")

local GameObject = require("game_objects.game_objects")
local AnimationState = GameObject.AnimationState
local Weapons = require("game_objects.weapons")

return {
   new = function(sprite_data, x, y, sprite_sheet)

      local speed = 100
      local health = 1
      local damage = 1

      local texture = sprite_data.textures.ufoGreen
      local texture_quad = love.graphics.newQuad(texture.x, texture.y, texture.width, texture.height, sprite_sheet:getDimensions())

      local dying_sound = Sounds.laser_explosions

      local saucer = GameObject.new(
         x, y, texture.width, texture.height, speed, health, damage, texture_quad, dying_sound
      )

      saucer.direction = 1
      saucer.rotation = 1
      saucer.rotation_rate = 6

      saucer.weapon = Weapons.build_green_laser_gun(
         saucer.width / 2, 0 - saucer.height, sprite_sheet
      )
      saucer.weapon.rotation = math.pi
      saucer.weapon.attack_rate = math.random(2, 10)
      saucer.weapon.cooldown = saucer.weapon.attack_rate / 2
      saucer.weapon.sound = love.sound.newSoundData("resources/audio/Laser/Laser_09.wav")

      local e_texture = sprite_data.textures.laserGreen14
      saucer.dying_animation = {
         state = AnimationState.running,
         frame = love.graphics.newQuad(e_texture.x, e_texture.y, e_texture.width, e_texture.height, sprite_sheet:getDimensions()),
         width = e_texture.width,
         height = e_texture.height,
         scale = .1,
         scale_max = saucer.width / e_texture.width,
         scale_rate = 25,

         update = function(self, dt)
            if self.scale_rate > 0 and self.scale >= self.scale_max then
               self.scale_rate = self.scale_rate * -1
            end

            if self.scale_rate < 0 and self.scale < .1 then
               self.state = AnimationState.stopped
            end

            self.scale = self.scale + self.scale_rate * dt

         end,

         draw = function(self, center_x, center_y, rotation)
            if self.state == AnimationState.running then
               love.graphics.translate(center_x, center_y)
               love.graphics.rotate(rotation)
               love.graphics.scale(self.scale)
               love.graphics.draw(
                  sprite_sheet,
                  self.frame,
                  0 - self.width / 2,
                  0 - self.width / 2
               )
               love.graphics.origin()
            end
         end
      }

      saucer.update = function(self, dt)
         if self.state ~= GameObject.State.dead then

            local delta_x = speed * dt

            local distance = self.base_x - self.x

            if math.abs(distance) >= self.width then
               self.base_x = self.x
               self.direction = self.direction * -1
            end

            self.x = self.x + delta_x * self.direction

            self.rotation = (self.rotation + (self.rotation_rate * dt)) % (2 * math.pi)

            if self.health <= 0 and self.state == GameObject.State.alive then
               self.state = GameObject.State.dying
               TEsound.play(Sounds.low_frequency_explosions, 'static')
               TEsound.play(dying_sound, 'static')
            end

            if self.state == GameObject.State.alive then
               self.weapon:update(dt)
            end

            if self.state == GameObject.State.dying then

               self.dying_animation:update(dt)

               if self.dying_animation.state == AnimationState.stopped then
                  self.state = GameObject.State.dead
               end

            end

         end

      end

      saucer.render = function(self)

         local center_x = self.x + self.width / 2
         local center_y = self.y + self.height / 2

         -- love.graphics.circle("fill", center_x, center_y, 5)

         love.graphics.translate(center_x, center_y)
         love.graphics.rotate(self.rotation)
         love.graphics.draw(sprite_sheet, self.sprite, 0 - self.width / 2, 0 - self.width / 2)
         love.graphics.origin()

      end

      saucer.draw = function(self)
         if self.state == GameObject.State.alive then

            self:render()

         elseif self.state == GameObject.State.dying then

            if self.dying_animation.scale_rate > 0 then
               self:render()
            end

            local center_x = self.x + self.width / 2
            local center_y = self.y + self.height / 2
            -- love.graphics.circle("fill", center_x, center_y, 5)
            self.dying_animation:draw(center_x, center_y, self.rotation)

         end
      end

      saucer.maybeAttack = function(self)
         return self.weapon:maybeAttack(self.x, self.y)
         -- if self.attack_cooldown <= 0 then
         --    self.attack_cooldown = self.attack_rate
         --    return build_laser(laser_data.blueLaser, self.x + self.width / 2, self.y - self.height, sprite_sheet)
         -- end
      end


      return saucer

   end
}
