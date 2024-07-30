require("TESound.tesound")
local rs = require("resolution_solution.resolution_solution")

local Fonts = require("resources.fonts.fonts")
local World = require("world.world")
local WorldData = require("resources.game_object_data.worlds")
local Menu = require("menu")

rs.conf({
    game_width = 1920,
    game_height = 1080,
    scale_mode = rs.ASPECT_MODE
  })

rs.setMode(rs.game_width, rs.game_height, {resizable = true})

-- Change "black" bars color
-- love.graphics.setBackgroundColor(love.math.colorFromBytes(29, 31, 33))
love.graphics.setBackgroundColor(love.math.colorFromBytes(38, 39, 43))

-- Setup Resolution Solution canvas, which will be scaled later.
-- Set canvas to size of game.
-- Note:
-- If you going to implement several resolutions in your game
-- e,g 800x600, 1920x1080, etc
-- then you need to re-create this canvas with new game size.
local game_canvas = love.graphics.newCanvas(rs.get_game_size())

-- Update Resolution Solution once window size changes.
love.resize = function(w, h)
   rs.resize(w, h)
end

local mouse_timer = {
   vanish_cooldown = 1/10,

   last_x = love.mouse.getX(),
   last_y = love.mouse.getY(),
   last_moved = love.timer.getTime(),

   update = function(self)
      if not love.window.hasFocus() then
         love.mouse.setVisible(true)
      else
         local time = love.timer.getTime()

         local dx = math.abs(love.mouse.getX() - self.last_x)
         local dy = math.abs(love.mouse.getY() - self.last_y)

         if dx >= 2 then
            self.last_x = love.mouse.getX()
            self.last_moved = time
            love.mouse.setVisible(true)
         end

         if dy >= 2 then
            self.last_y = love.mouse.getY()
            self.last_moved = time
            love.mouse.setVisible(true)
         end

         if time - self.last_moved > self.vanish_cooldown then
            love.mouse.setVisible(false)
         end
      end
   end
}

local world = {}

local pause = {
   is_paused = false,

   menu_items = {
      resume = "Resume",
      restart = "Restart",
      quit = "Quit",
   },

   menu = {},

   set_pause = function(self, val)
      self.is_paused = val

      if self.is_paused then
         love.mouse.setVisible(true)
         self.menu = Menu.new(
            "Paused",
            {
               self.menu_items.resume,
               self.menu_items.restart,
               self.menu_items.quit,
            }
         )
      end
   end,

   handle_keypress = function(self, key)
      if key == 'escape' then
         self:set_pause(not self.is_paused)
      else
         if self.is_paused then
            local result = self.menu:handle_keypress(key)

            if result == self.menu_items.resume then
               self:set_pause(false)
            end

            if result == self.menu_items.restart then
               world = World.new(WorldData.game_world)
               self:set_pause(false)
            end

            if result == self.menu_items.quit then
               love.event.push('quit')
            end

         end
      end
   end,

   draw = function(self)
      if self.is_paused then
         self.menu:draw()
      end
   end,
}

love.keypressed = function(key)
   -- Change scaling mode at runtime.
   if key == "f1" then
      rs.conf({scale_mode = rs.ASPECT_MODE})
   elseif key == "f2" then
      rs.conf({scale_mode = rs.STRETCH_MODE})
   elseif key == "f3" then
      rs.conf({scale_mode = rs.PIXEL_PERFECT_MODE})
   elseif key == "f4" then
      rs.conf({scale_mode = rs.NO_SCALING_MODE})
   end

   -- Handle pausing
   pause:handle_keypress(key)
end

local sprites = {}

function love.load()
   love.window.setTitle("Space Attack!")

   love.graphics.setFont(Fonts.normal)

   world = World.new(WorldData.game_world)

   love.mouse.setVisible(false)
end

function love.update(dt)

   if not pause.is_paused then

      -- local dbg = require 'debugger.debugger'; dbg()
      world:update(dt)

      mouse_timer:update()
   end

   TEsound.cleanup()

end

function love.draw()

   love.graphics.setCanvas(game_canvas)
   love.graphics.clear(0, 0, 0, 1)

   world:draw(sprites.img)
   pause:draw()

   -- love.graphics.print("Try to resize window!", 0, 0)
   -- love.graphics.print("Press F1, F2, F3, F4 to change scale mode.", 0, 20)

  love.graphics.setCanvas()

   rs.push()
      love.graphics.draw(game_canvas)
   rs.pop()
end
