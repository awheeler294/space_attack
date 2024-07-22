local rs = require("resolution_solution.resolution_solution")

local rotation_choice = {
   0,
   math.pi/2,
   math.pi,
   3 * math.pi/2,
}

return {

   new = function(image_path, speed)

      return {
         img = love.graphics.newImage(image_path),
         speed = speed,
         height = 0,
         width = 0,
         tiles = {},

         update = function(self, dt)
            if rs.game_height ~= self.height
               or rs.game_width ~= self.width then

               self.height = rs.game_height
               self.width = rs.game_width
               self:rebuild()

            else
               for _, t in ipairs(self.tiles) do
                  if t.y > rs.game_height then
                     t.y = t.y - rs.game_height - 2 * self.img:getHeight()
                  end

                  t.y = t.y + self.speed * dt

               end
            end
         end,

         draw = function(self)
            for _, tile in ipairs(self.tiles) do
               love.graphics.push()
                  love.graphics.translate(tile.x + self.img:getWidth() / 2, tile.y + self.img:getHeight() / 2)
                  love.graphics.rotate(tile.rotation)
                  love.graphics.draw(self.img, 0 - self.img:getWidth() / 2, 0 - self.img:getHeight() / 2)
               love.graphics.pop()
            end
         end,

         rebuild = function(self)
            self.tiles = {}
            for y = -2 * self.img:getHeight(), rs.game_height, self.img:getHeight() do
               for x = 0, rs.game_width, self.img:getWidth() do
                  local rotaton = rotation_choice[math.random(4)]
                  table.insert(self.tiles, {x = x, y = y, rotation = rotaton})
               end
            end
         end

      }
   end,

}
