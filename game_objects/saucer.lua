local Sounds = require("resources.audio.sounds")

local GameObject = require("game_objects.game_objects")
local AnimationState = GameObject.AnimationState
local Weapons = require("game_objects.weapons")

return {
   new = function(data, x, y)

      -- local dbg = require 'debugger.debugger'; dbg()
      local saucer = GameObject.new(
         x, y, data.speed, data.health, data.damage, data.sprite, data.dying_sound
      )

      saucer.direction = 1
      saucer.rotation = 1
      saucer.rotation_rate = 6

      saucer.drop_rate = data.drop_rate

      saucer.weapon = Weapons.build_gun(
         saucer.width / 2,
         0 - saucer.height,
         data.weapon.gun,
         data.weapon.shot_type
      )
      saucer.weapon.rotation = data.weapon.rotation
      saucer.weapon.attack_rate = math.random(data.weapon.attack_rate.min, data.weapon.attack_rate.max)
      saucer.weapon.cooldown = saucer.weapon.attack_rate / 2
      saucer.weapon.sound = data.weapon.sound

      saucer.dying_animation = GameObject.create_scaling_animation(data.explosion_sprite, saucer.width)

      saucer.update = function(self, dt)
         if self.state ~= GameObject.State.dead then

            self:update_collision()

            local delta_x = self.speed * dt

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
               TEsound.play(self.dying_sound, 'static')
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

         love.graphics.push()
            love.graphics.translate(center_x, center_y)
            love.graphics.rotate(self.rotation)
            love.graphics.draw(self.sprite, 0 - self.width / 2, 0 - self.width / 2)
         love.graphics.pop()

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
