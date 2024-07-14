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

local function create_animation(frames, width, height, sprite_sheet, frame_rate)
   local default_frame_rate = 1/30

   local animation = {
      frames = {},
      frame_rate = frame_rate or default_frame_rate,
      frame_elapsed_time = 0,

      width = width,
      height = height,

      current_frame = 1,
      state = AnimationState.running,
   }

   for _, texture in ipairs(frames) do
      table.insert(animation.frames, love.graphics.newQuad(texture.x, texture.y, texture.width, texture.height, sprite_sheet:getDimensions()))
   end

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
         love.graphics.draw(sprite_sheet, self.frames[self.current_frame], x, y)
      end
   end

   return animation

end

local function create_non_looping_animation(frames, width, height, sprite_sheet, frame_rate)
   local animation = create_animation(frames, width, height, sprite_sheet, frame_rate)

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

local function create_scaling_animation(texture, width, sprite_sheet)

   return {
      state = AnimationState.running,
      frame = love.graphics.newQuad(texture.x, texture.y, texture.width, texture.height, sprite_sheet:getDimensions()),
      width = texture.width,
      height = texture.height,
      scale = .1,
      scale_max =  width / texture.width,
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
               sprite_sheet,
               self.frame,
               0 - self.width / 2,
               0 - self.width / 2
            )
            love.graphics.origin()
         end
      end
   }
end

local explosions = {
   love.audio.newSource("resources/audio/explosionCrunch_000.ogg", "static"),
   love.audio.newSource("resources/audio/explosionCrunch_001.ogg", "static"),
   love.audio.newSource("resources/audio/explosionCrunch_002.ogg", "static"),
   love.audio.newSource("resources/audio/explosionCrunch_003.ogg", "static"),
   love.audio.newSource("resources/audio/explosionCrunch_004.ogg", "static"),
}

local GameObjectState = {
   alive = "alive",
   dying = "dying",
   dead = "dead",
}

return {

   State = GameObjectState,

   new = function (x, y, width, height, speed, health, damage, sprite)

      return {
         base_x = x,
         base_y = y,

         x = x,
         y = y,

         width = width,
         height = height,

         sprite = sprite,

         shear_x = 0,
         shear_y = 0,

         speed = speed,
         health = health,
         damage = damage,

         state = GameObjectState.alive,

         checkCollision = function (self, other)
            return checkCollision(self, other)
         end,

         collide = function(self, other)
            self.health = self.health - other.damage
            other.health = other.health - self.damage
         end,

         maybeCollide = function(self, other)
            if self:checkCollision(other) then
               self:collide(other)
            end
         end,

         maybeAttack = function(_)
            return false
         end
      }

   end,

   play_explosion = function()
      local explosion = math.random(1, #explosions)
      explosions[explosion]:play()
   end,

   create_animation = create_animation,
   create_non_looping_animation = create_non_looping_animation,
   create_scaling_animation = create_scaling_animation,
   AnimationState = AnimationState,

}
