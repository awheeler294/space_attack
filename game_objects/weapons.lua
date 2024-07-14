local weapon_data = require("resources.game_object_data.lasers")
local GameObject = require("game_objects.game_object")
local AnimationState = GameObject.AnimationState

local function build_laser(data, x, y, rotation, sprites)
   local speed = data.speed
   local health = data.health
   local damage = data.damage
   local range = data.range

   local texture = data.texture

   local texture_quad = love.graphics.newQuad(texture.x, texture.y, texture.width, texture.height, sprites:getDimensions())

   local laser = GameObject.new(
      x, y, texture.width, texture.height, speed, health, damage, texture_quad
   )

   local explode_frames = data.explode_frames

   local e_width = explode_frames[1].width
   local e_height = explode_frames[1].height
   laser.explode_animation = GameObject.create_non_looping_animation(
      explode_frames, e_width, e_height, sprites
   )

   laser.rotation = rotation

   laser.update = function(self, dt)

      if math.abs(self.y - self.base_y) > range then
         self.health = 0
      end

      if self.state == GameObject.State.alive then

         if self.health > 0 then

            self.x = self.x + speed * math.sin(self.rotation) * dt
            self.y = self.y - speed * math.cos(self.rotation) * dt

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
      love.graphics.translate(self.x + self.width/2, self.y + self.height/2)
      love.graphics.rotate(self.rotation)

      if self.state == GameObject.State.alive then
         love.graphics.draw(sprites, self.sprite, 0, 0)
      elseif self.state == GameObject.State.dying then
         local e_x = (self.x + self.width / 2) - (self.explode_animation.width / 2)
         local e_y = (self.y + self.height / 2) - (self.explode_animation.height / 2)
         self.explode_animation:draw(e_x, e_y)
      end

      love.graphics.origin()
   end

   return laser

end

local build_gun = function(x, y, gun_data, shot_type, sprite_sheet)
   return {
      x = x,
      y = y,

      width = gun_data.width,
      height = gun_data.height,

      attack_rate = gun_data.attack_rate,
      cooldown = 0,
      rotation = 0,

      shot_type = shot_type,

      sound = love.audio.newSource(gun_data.sound, "static"),

      maybeAttack = function(self, x_offset, y_offset)
         if self.cooldown <= 0 then
            self.cooldown = self.attack_rate
            love.audio.play(self.sound)
            return build_laser(
               self.shot_type,
               x_offset + self.x + self.width / 2,
               y_offset - self.y - self.height,
               self.rotation,
               sprite_sheet
            )
         end
      end,

      update = function(self, dt)
         if self.cooldown > 0 then
            self.cooldown = self.cooldown - dt
         end
      end,

      draw = function(self)
         love.graphics.draw(sprite_sheet, self.shot_type.texture, self.x, self.y)
      end
   }
end

return {

   build_blue_laser_gun = function(x, y, sprite_sheet)
      return build_gun(x, y, weapon_data.LaserGun, weapon_data.BlueLaser, sprite_sheet)
   end,

   build_green_laser_gun = function(x, y,  sprite_sheet)
      return build_gun(x, y, weapon_data.LaserGun, weapon_data.GreenLaser, sprite_sheet)
   end,

}
