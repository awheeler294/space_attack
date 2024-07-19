---Check if a and b collide
---@param a {x: number, y: number, width: number, height: number}
---@param b {x: number, y: number, width: number, height: number}
---@return boolean
local function checkCollision(a, b)

   local a = {
      left = a.x,
      right = a.x + a.width,
      top = a.y,
      bottom = a.y + a.height,

      radius = math.min(a.width / 2, a.height / 2),
      center_x = a.x + a.width / 2,
      center_y = a.y + a.height / 2,
   }

   local b = {
      left = b.x,
      right = b.x + b.width,
      top = b.y,
      bottom = b.y + b.height,

      radius = math.min(b.width / 2, b.height / 2),
      center_x = b.x + b.width / 2,
      center_y = b.y + b.height / 2,
   }

   local distance = math.sqrt((b.center_x - a.center_x)^2 + (b.center_y - a.center_y)^2)

   return  a.right > b.left
      and a.left < b.right
      and a.bottom > b.top
      and a.top < b.bottom
      and distance < math.max(a.radius, b.radius)
end

local AnimationState = {
   running = "running",
   stopped = "stopped",
}

local function create_animation(frames, frame_rate)
   local width = frames[1]:getWidth()
   local height = frames[1]:getHeight()
   local default_frame_rate = 1/30

   local animation = {
      frames = frames,
      frame_rate = frame_rate or default_frame_rate,
      frame_elapsed_time = 0,

      width = width,
      height = height,

      current_frame = 1,
      state = AnimationState.running,
   }

   animation.update = function(self, dt)
      if self.state == AnimationState.running then

         self.frame_elapsed_time = self.frame_elapsed_time + dt

         if self.frame_elapsed_time >= self.frame_rate then
            self.frame_elapsed_time = self.frame_elapsed_time - self.frame_rate
         end

         self.current_frame = math.floor(self.frame_elapsed_time / self.frame_rate * #self.frames) + 1

      end
   end

   animation.draw = function(self, x, y)
      if self.state == AnimationState.running then
         love.graphics.origin()
         love.graphics.draw(self.frames[self.current_frame], x, y)
      end
   end

   return animation

end

local function create_non_looping_animation(frames, frame_rate)
   local animation = create_animation(frames, frame_rate)

   animation.update = function(self, dt)

      if self.state == AnimationState.running then

         self.frame_elapsed_time = (self.frame_elapsed_time + dt) / self.frame_rate

         self.current_frame = math.floor(self.frame_elapsed_time) + 1

         if self.current_frame > #self.frames then
               self.state = AnimationState.stopped
         end

      end

   end

   return animation

end

local function create_scaling_animation(sprite, width)

   return {
      state = AnimationState.running,
      sprite = sprite,
      width = sprite:getWidth(),
      height = sprite:getHeight(),
      scale = .1,
      scale_max =  width / sprite:getWidth(),
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

         local rotation = rotation or 0

         if self.state == AnimationState.running then
            love.graphics.translate(center_x, center_y)
            love.graphics.rotate(rotation)
            love.graphics.scale(self.scale)
            love.graphics.draw(
               self.sprite,
               0 - self.width / 2,
               0 - self.width / 2
            )
            love.graphics.origin()
         end
      end
   }
end

local GameObjectState = {
   alive = "alive",
   dying = "dying",
   dead = "dead",
}

return {

   new = function (x, y, speed, health, damage, sprite, dying_sound)

      return {
         base_x = x,
         base_y = y,

         x = x,
         y = y,

         width = sprite:getWidth(),
         height = sprite:getHeight(),

         sprite = sprite,

         shear_x = 0,
         shear_y = 0,

         speed = speed,
         health = health,
         damage = damage,

         state = GameObjectState.alive,

         dying_sound = dying_sound,

         current_collisions = {},

         update_collision = function(self)
            for other, _ in pairs(self.current_collisions) do
               if checkCollision(self, other) == false then
                  self.current_collisions[other] = nil
                  other.current_collisions[self] = nil
               end
            end
         end,

         checkCollision = function (self, other)
            return checkCollision(self, other)
         end,

         collide = function(self, other)
            self.health = self.health - other.damage
            other.health = other.health - self.damage

            self.current_collisions[other] = true
            other.current_collisions[self] = true
         end,

         maybeCollide = function(self, other, dt)
            if self.current_collisions[other] == nil then
               if self:checkCollision(other) then
                  self:collide(other, dt)
               end
            end
         end,

         maybeAttack = function(_)
            return false
         end
      }

   end,

   create_animation = create_animation,
   create_non_looping_animation = create_non_looping_animation,
   create_scaling_animation = create_scaling_animation,
   AnimationState = AnimationState,
   State = GameObjectState,

}
