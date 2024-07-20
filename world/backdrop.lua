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
            if love.graphics.getHeight() ~= self.height
               or love.graphics.getWidth() ~= self.width then

               self.height = love.graphics.getHeight()
               self.width = love.graphics.getWidth()
               self:rebuild()

            else
               for _, t in ipairs(self.tiles) do
                  if t.y > love.graphics.getHeight() then
                     t.y = t.y - love.graphics.getHeight() - 2 * self.img:getHeight()
                  end

                  t.y = t.y + self.speed * dt

               end
            end
         end,

         draw = function(self)
            for _, tile in ipairs(self.tiles) do

               love.graphics.origin()
               love.graphics.translate(tile.x + self.img:getWidth() / 2, tile.y + self.img:getHeight() / 2)
               love.graphics.rotate(tile.rotation)
               love.graphics.draw(self.img, 0 - self.img:getWidth() / 2, 0 - self.img:getHeight() / 2)
            end
            love.graphics.origin()
         end,

         rebuild = function(self)
            self.tiles = {}
            for y = -2 * self.img:getHeight(), love.graphics.getHeight(), self.img:getHeight() do
               for x = 0, love.graphics.getWidth(), self.img:getWidth() do
                  local rotaton = rotation_choice[math.random(4)]
                  table.insert(self.tiles, {x = x, y = y, rotation = rotaton})
               end
            end
         end

      }
   end,

}
