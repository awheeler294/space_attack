local rotation_choice = {
   0,
   math.pi/2,
   math.pi,
   3 * math.pi/2,
}

return {

   new = function(image_path, speed)

      local backdrop = {
         img = love.graphics.newImage(image_path),

         speed = speed,

         tiles = {},

         update = function(self, dt)
            for _, t in ipairs(self.tiles) do
               if t.y > love.graphics.getHeight() then
                  t.y = t.y - love.graphics.getHeight() - 2 * self.img:getHeight()
               end

               t.y = t.y + self.speed * dt

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

      }

      for y = -2 * backdrop.img:getHeight(), love.graphics.getHeight(), backdrop.img:getHeight() do
         for x = 0, love.graphics.getWidth(), backdrop.img:getWidth() do
            local rotaton = rotation_choice[math.random(4)]
            table.insert(backdrop.tiles, {x = x, y = y, rotation = rotaton})
         end
      end

      return backdrop
   end,

}
