local weapon_data = require("resources.game_object_data.lasers")
local GameObject = require("game_objects.game_objects")
local AnimationState = GameObject.AnimationState

local function build_laser(data, x, y, rotation)
   local laser = GameObject.new(
      x, y, data.speed, data.health, data.damage, data.sprite
   )

   laser.range = data.range

   laser.explode_animation = GameObject.create_non_looping_animation(
      data.explode_frames
   )

   laser.rotation = rotation

   laser.update = function(self, dt)

      self:update_collision()

      if math.abs(self.y - self.base_y) > self.range then
         self.health = 0
      end

      if self.state == GameObject.State.alive then

         if self.health > 0 then

            self.x = self.x + self.speed * math.sin(self.rotation) * dt
            self.y = self.y - self.speed * math.cos(self.rotation) * dt

         else

            -- local dbg = require 'debugger'; dbg()
            self.state = GameObject.State.dying

         end

      elseif self.state == GameObject.State.dying then

         -- local dbg = require 'debugger'; dbg()
         self.explode_animation:update(dt)

      end

      if self.state == GameObject.State.dying then
         if self.explode_animation.state == AnimationState.stopped then
            self.state = GameObject.State.dead
         end
      end

   end

   laser.draw = function(self)
      love.graphics.push()
         love.graphics.translate(self.x + self.width/2, self.y + self.height/2)
         love.graphics.rotate(self.rotation)

         if self.state == GameObject.State.alive then
            love.graphics.draw(self.sprite, 0, 0)
         elseif self.state == GameObject.State.dying then
            local e_x = (self.width / 2) - (self.explode_animation.width / 2)
            local e_y = (self.height / 2) - (self.explode_animation.height / 2)
            self.explode_animation:draw(e_x, e_y)
         end
      love.graphics.pop()
   end

   return laser

end

local build_gun = function(x, y, gun_data, shot_type)
   return {
      x = x,
      y = y,

      width = gun_data.width,
      height = gun_data.height,

      attack_rate = gun_data.attack_rate,
      cooldown = 0,
      rotation = 0,

      shot_type = shot_type,

      sound = gun_data.sound,

      maybeAttack = function(self, x_offset, y_offset)
         if self.cooldown <= 0 then
            self.cooldown = self.attack_rate
            TEsound.play(self.sound, 'static')
            return build_laser(
               self.shot_type,
               x_offset + self.x - self.width / 2,
               y_offset - self.y - self.height,
               self.rotation
            )
         end
      end,

      update = function(self, dt)
         if self.cooldown > 0 then
            self.cooldown = self.cooldown - dt
         end
      end,

      draw = function(self)
         love.graphics.draw(self.shot_type.sprite, self.x, self.y)
      end
   }
end

return {

   build_blue_laser_gun = function(x, y)
      return build_gun(x, y, weapon_data.LaserGun, weapon_data.BlueLaser)
   end,

   build_green_laser_gun = function(x, y)
      return build_gun(x, y, weapon_data.LaserGun, weapon_data.GreenLaser)
   end,

   build_gun = build_gun,
}
