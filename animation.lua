local rs = require("resolution_solution.resolution_solution")

local Fonts = require("resources.fonts.fonts")

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

         self.frame_elapsed_time = (self.frame_elapsed_time + dt) / self.frame_rate

         self.current_frame = math.floor(self.frame_elapsed_time) + 1

         if self.current_frame > #self.frames then
               self.state = AnimationState.stopped
         end

      end

   end

   animation.draw = function(self, x, y)
      if self.state == AnimationState.running then
         love.graphics.draw(self.frames[self.current_frame], x, y)
      end
   end

   return animation

end

local function create_looping_animation(frames, frame_rate)

   local animation = create_animation(frames, frame_rate)

   animation.update = function(self, dt)
      if self.state == AnimationState.running then

         self.frame_elapsed_time = self.frame_elapsed_time + dt

         if self.frame_elapsed_time >= self.frame_rate then
            self.frame_elapsed_time = self.frame_elapsed_time - self.frame_rate
         end

         self.current_frame = math.floor(self.frame_elapsed_time / self.frame_rate * #self.frames) + 1

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
            love.graphics.push()
               love.graphics.translate(center_x, center_y)
               love.graphics.rotate(rotation)
               love.graphics.scale(self.scale)
               love.graphics.draw(
                  self.sprite,
                  0 - self.width / 2,
                  0 - self.width / 2
               )
            love.graphics.pop()
         end
      end
   }
end

local function create_text_animation(text)
   return {
      text = text,
      current_frame = 0,
      state = AnimationState.running,
      frame_elapsed_time = 0,
      frame_rate = 5/6,

      update = function (self, dt)
         if self.state == AnimationState.running then

            self.frame_elapsed_time = (self.frame_elapsed_time + dt) / self.frame_rate

            self.current_frame = math.floor(self.frame_elapsed_time)

            self.frame_rate = self.frame_rate - (1/2 * dt)

            if self.current_frame > #self.text then
                  self.state = AnimationState.stopped
            end

         end
      end,

      draw = function (self)
         love.graphics.push()

            love.graphics.setFont(Fonts.announce)

            local message = string.sub(self.text, 1, self.current_frame)
            local message_width = Fonts.announce:getWidth(message)

            local x = rs.game_width / 2 - message_width / 2
            local y = rs.game_height / 3

            love.graphics.printf(message, x, y, message_width, "center")

         love.graphics.pop()
      end,
   }
end

return {
   State = AnimationState,

   create_animation = create_animation,
   create_looping_animation = create_looping_animation,
   create_scaling_animation = create_scaling_animation,
   create_text_animation = create_text_animation,
}
