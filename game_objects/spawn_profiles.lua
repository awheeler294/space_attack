local rs = require "resolution_solution.resolution_solution"

local two_pi = math.pi * 2
local rotation_direction = -1
local rotation_radius = 600
local rotation_rate = 4


return {

   instant = {
      new = function()
         return {
            duration = 0,

            update = function() end,

            get_transform = function(_, _)
               return love.math.newTransform()
            end,

            is_finished = function()
               return true
            end,
         }
      end,
   },

   rotate = {
      new = function()
         return {
            angle = 3 * math.pi / 2,
            radius = rotation_radius,

            update = function(self, dt)
               self.angle = self.angle + rotation_rate * rotation_direction * dt
               if self.angle >= two_pi then
                  self.angle = self.angle - two_pi
               end

               self.radius = self.radius - self.radius / 10
            end,

            get_transform = function(self, _)
               local tx = self.radius * math.cos(self.angle)
               local ty = self.radius * math.sin(self.angle)

               local transform = love.math.newTransform()

               transform:translate(tx, ty)

               return transform
            end,

            is_finished = function(self)

               if self.radius <= 10 then
                  return true
               end

               return false

            end,
         }
      end
   },

   horizontal = {
      new = function(game_object)
         return {

            offset = rs.game_width,
            direction = game_object.direction,
            speed = game_object.speed * 20,

            update = function(self, dt)
               self.offset = self.offset - self.speed * dt
            end,

            get_transform = function(self, _)
               local tx = self.offset * self.direction
               local ty = 0

               local transform = love.math.newTransform()

               transform:translate(tx, ty)

               return transform
            end,

            is_finished = function(self)

               if self.offset <= 0 then
                  return true
               end

               return false

            end,
         }
      end
   },

   scaled = {
      new = function()
         return {
            scale = 0,
            scale_rate = 2,

            update = function(self, dt)
               self.scale = self.scale + self.scale_rate * dt
            end,

            get_transform = function(self, game_object)
               local transform = love.math.newTransform()
               transform:scale(self.scale, self.scale)

               local tx = (game_object:center_x() / self.scale) - game_object:center_x()
               local ty = (game_object:center_y() / self.scale) - game_object:center_y()

               transform:translate(tx, ty)

               return transform
            end,

            is_finished = function(self)

               if self.scale >= 1 then
                  return true
               end

               return false

            end,
         }
      end,
   },
}
