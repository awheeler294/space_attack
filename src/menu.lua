local rs = require("resolution_solution.resolution_solution")
local Fonts = require("resources.fonts.fonts")

local padding = 10
local corner_radius = 10

local draw_shaded_rect = function (x, y, width, height)
   love.graphics.push("all")
      love.graphics.setColor(0, 0, 0, .6)
      love.graphics.rectangle(
         "fill",
         x - padding,
         y - padding,
         width + (padding * 2),
         height + (padding * 2),
         corner_radius
      )
   love.graphics.pop()
end

local print_centered = function(text, y, font, shade)
   love.graphics.setFont(font)

   local message_width = font:getWidth(text)

   local x = rs.game_width / 2 - message_width / 2

   if shade then
      draw_shaded_rect(x, y, message_width, font:getHeight())
   end

   love.graphics.printf(text, x, y, message_width, "center")
end

local function option_or_default(value, default)
   return (value == nil and default) or value
end

return {

   new = function(options)
      return {

         title = option_or_default(options.title, ""),
         menu_items = option_or_default(options.menu_items, {}),
         margin = option_or_default(options.margin, 0),
         shade_background = option_or_default(options.shade_background, true),
         shade_menu_items = option_or_default(options.shade_menu_items, false),
         skip_lines = option_or_default(options.skip_lines, 0),

         selected_item = 1,


         reset_selection = function(self)
            self.selected_item = 1
         end,

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
            if self.shade_background then
               love.graphics.push("all")
                  love.graphics.setColor(0, 0, 0, .6)
                  love.graphics.rectangle("fill", self.margin, 0, rs.game_width - (self.margin * 2), rs.game_height)
               love.graphics.pop()
            end

            love.graphics.push("all")
               local title_font = Fonts.announce
               love.graphics.setColor(1, 1, 1)

               local title_y = rs.game_height / 3

               if self.title:len() > 0 then
                  print_centered(self.title, title_y, title_font, self.shade_menu_items)
               end

               for i, txt in ipairs(self.menu_items) do

                  love.graphics.push("all")
                     local font = Fonts.normal
                     if i == self.selected_item then
                        font = Fonts.highlight
                        love.graphics.setColor(1, 1, 0)
                     end

                     local y = title_y + title_font:getHeight() + (Fonts.normal:getHeight() + padding * 4) * (i + self.skip_lines)

                     if txt:len() > 0 then
                        print_centered(txt, y, font, self.shade_menu_items)
                     end

                  love.graphics.pop()
               end
            love.graphics.pop()
         end
      }
   end,
}
