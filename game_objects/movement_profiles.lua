local rs = require "resolution_solution.resolution_solution"

local two_pi = math.pi * 2

return {
   stationary = {
      new = function()
         return {
            update = function(_, game_object)
               return game_object.x, game_object.y
            end,
         }
      end,
   },

   human_control = {
      new = function()
         return {
            update = function(_, game_object, dt)

               local dx, dy = 0, 0
               local shear_x = 0

               if love.keyboard.isDown("right", "d") then
                  if game_object.x < (rs.game_width - game_object.width - 10) then
                     dx = dx + (game_object.speed * dt)
                     shear_x = 1
                  end
               end

               if love.keyboard.isDown("left", "a") then
                  if game_object.x > 10 then
                     dx = dx - (game_object.speed * dt)
                     shear_x = -1
                  end
               end

               if love.keyboard.isDown("up", "w") then
                  if game_object.y > 10 then
                     dy = dy - (game_object.speed * dt)
                  end
               end

               if love.keyboard.isDown("down", "s") then
                  if game_object.y < (rs.game_height - game_object.height - 10) then
                     dy = dy + (game_object.speed * dt)
                  end
               end

               return dx + game_object.x, dy + game_object.y, shear_x / 20

            end
         }
      end,
   },

   side_to_side = {
      new = function(base_x)
         return {
            base_x = base_x,

            update = function(self, game_object, dt)
               local x, y = game_object.x, game_object.y
               local delta_x = game_object.speed * dt

               local distance = math.abs(self.base_x - game_object.x)

               if distance >= game_object.width then
                  self.base_x = game_object.x
                  game_object.direction = game_object.direction * -1
               end

               x = x + delta_x * game_object.direction

               return x, y
            end
         }
      end
   },

   circular = {
      new = function (center_object, radius, angle)
         return {
            center_object = center_object,
            radius = radius,
            theta = angle,

            update = function(self, game_object, dt)
               local x, y = 0, 0

               self.theta = self.theta + game_object.speed / 50 * game_object.direction * dt
               if self.theta >= two_pi then
                  self.theta = self.theta - two_pi
               end

               x = self.center_object.x + (self.radius * math.cos(self.theta))
               y = self.center_object.y + (self.radius * math.sin(self.theta))

               return x, y
            end
         }
      end
   }
}
