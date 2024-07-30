local rs = require("resolution_solution.resolution_solution")
local Fonts = require("resources.fonts.fonts")

local print_centered = function(text, y, font)
   love.graphics.setFont(font)

   local message_width = font:getWidth(text)

   local x = rs.game_width / 2 - message_width / 2

   love.graphics.printf(text, x, y, message_width, "center")
end

return {

   new = function(title, menu_items)
      return {

         title = title,

         menu_items = menu_items,

         selected_item = 1,

         margin = 0,

         handle_keypress = function(self, key)

            if key == "up" then
               self.selected_item = self.selected_item - 1
               if self.selected_item < 1 then
                  self.selected_item = #self.menu_items
               end
            end

            if key == "down" then
               self.selected_item = self.selected_item + 1
               if self.selected_item > #self.menu_items then
                  self.selected_item = 1
               end
            end

            if key == "return" then
               return self.menu_items[self.selected_item]
            end
         end,

         draw = function(self)
            love.graphics.push("all")
               love.graphics.setColor(0, 0, 0, .6)
               love.graphics.rectangle("fill", self.margin, 0, rs.game_width - (self.margin * 2), rs.game_height)
            love.graphics.pop()

            love.graphics.push("all")

               local title_font = Fonts.announce
               love.graphics.setColor(1, 1, 1)

               local title_y = rs.game_height / 4

               print_centered(self.title, title_y, title_font)

               for i, txt in ipairs(menu_items) do

                  love.graphics.push("all")
                     local font = Fonts.normal
                     if i == self.selected_item then
                        font = Fonts.highlight
                        love.graphics.setColor(1, 1, 0)
                     end

                     local y = title_y + title_font:getHeight() + (Fonts.normal:getHeight() + 10) * i

                     print_centered(txt, y, font)

                  love.graphics.pop()
               end
            love.graphics.pop()
         end
      }
   end,
}
