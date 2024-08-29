require("TESound.tesound")
local rs = require("resolution_solution.resolution_solution")

local Animation = require("animation")
local Backdrop = require("world.backdrop")
local GameObjects = require("game_objects.game_objects")
local Menu = require("menu")
local Player = require("game_objects.player")
local Powerup = require("game_objects.powerups")
local Wave = require("world.wave")

local menu_items = {
   resume = "Resume",
   restart = "Restart",
   quit = "Quit",
}

local world_state = {
   player_won = "Player Won",
   player_died = "Player Died",
   running = "Running",
   paused = "Paused",
}

return {
   menu_items = menu_items,

   new = function(world_data)

      local sprites = world_data.sprites

      love.mouse.setVisible(false)

      local px = rs.game_width / 2
      local py = rs.game_height / 1.15

      local player = Player.new(sprites.playerShip1_blue, px, py)

      return {

         state = world_state.running,

         backdrop = Backdrop.new(world_data.backdrop.image_path, world_data.backdrop.speed),

         wave_count = 0,
         wave_cooldown = 0,

         mouse_timer = {
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
         },

         pause_menu = Menu.new("Paused", { menu_items.resume, menu_items.restart, menu_items.quit, }),

         text_animations = {
            update = function(self, dt)
               for _, animation in ipairs(self) do
                  animation:update(dt)
               end
            end,

            draw = function(self)
               for _, animation in ipairs(self) do
                  animation:draw()
               end
            end,
         },

         game_objects = {
            player = player,
            friendlies = {},
            hostiles = {},
            powerups = {},

            -- Update Friendlies
            update = function(self, dt)

               for i = #self.friendlies, 0, -1 do
                  local f
                  if i == 0 then
                     if self.player.state == GameObjects.State.dead then
                        break
                     end

                     f = self.player

                     for _, p in ipairs(self.powerups) do
                        if f:check_collision(p) then
                           f:collide(p)
                           f:powerup(p.powerup_amount)
                        end
                     end
                  else
                     f = self.friendlies[i]
                  end

                  for _, h in ipairs(self.hostiles) do
                     -- local dbg = require 'debugger.debugger'; dbg()
                     f:maybeCollide(h, dt)
                  end

                  f:update(dt)

                  if f.state == GameObjects.State.dead then
                     table.remove(self.friendlies, i)
                  end

                  local attack_result = f:maybeAttack()
                  if attack_result then
                     table.insert(self.friendlies, attack_result)
                  end

               end

               -- Update Hostiles
               for i = #self.hostiles, 1, -1 do
                  local h = self.hostiles[i]

                  h:update(dt)

                  if h.state == GameObjects.State.dead then
                     table.remove(self.hostiles, i)

                     if h.drop_rate then
                        local drop_chance = math.random(1, 100)
                        if drop_chance <= h.drop_rate then
                           table.insert(self.powerups, Powerup.new(h.x + h.width / 2, h.y + h.height / 2))
                        end
                     end
                  end

                  local attack_result = h:maybeAttack()
                  if attack_result then
                     table.insert(self.hostiles, attack_result)
                  end

               end

               -- Update Powerups
               for i = #self.powerups, 1, -1 do
                  local p = self.powerups[i]

                  p:update(dt)

                  if p.state == GameObjects.State.dead then
                     table.remove(self.powerups, i)
                  end
               end

            end,

            draw = function(self)

               self.player:draw()

               for _, o in ipairs(self.friendlies) do
                  o:draw()
               end

               for _, o in ipairs(self.hostiles) do
                  o:draw()
               end

               for _, o in ipairs(self.powerups) do
                  o:draw()
               end

            end,
         },

         update = function(self, dt)
            if self.state ~= world_state.paused then

               if #self.game_objects.hostiles == 0 then
                  self.wave_cooldown = self.wave_cooldown - dt
                  if self.wave_cooldown <= 0 then

                     self.wave_count = self.wave_count + 1
                     self.wave_cooldown = 2

                     self.game_objects.hostiles = Wave.build_wave(self.wave_count)

                     if self.state ~= world_state.player_won and #self.game_objects.hostiles == 0 then
                        if not self.text_animations.player_won then
                           self.text_animations.player_won = true
                           table.insert(self.text_animations, Animation.create_text_animation("You Win!"))
                        end
                        self.pause_menu.title = "You Win!"
                        self.state = world_state.player_won
                     end

                  end
               end

               if self.state ~= world_state.player_died and self.game_objects.player.health <= 0 then
                  if not self.text_animations.player_died then
                     self.text_animations.player_died = true
                     table.insert(self.text_animations, Animation.create_text_animation("You Died"))
                  end
                  self.pause_menu.title = "You Died"
                  self.state = world_state.player_died
               end

               self.text_animations:update(dt)
               self.backdrop:update(dt)
               self.game_objects:update(dt)

               self.mouse_timer:update()

            end
         end,

         draw = function(self)
            self.backdrop:draw()
            self.game_objects:draw()
            self.text_animations:draw()

            self.pause_menu:draw()
         end,

         handle_keypress = function(self, key)
            if self.state == world_state.paused then

               if key == "escape" then
                  self.pause_menu:set_visible(false)
                  self.state = world_state.running
               else
                  local result = self.pause_menu:handle_keypress(key)

                  if result == menu_items.resume then
                     self.pause_menu:set_visible(false)
                     self.state = world_state.running
                  end

                  if result == menu_items.quit then
                     love.event.push('quit')
                  end

                  return result
               end

            else

               if key == "escape" then
                  self.state = world_state.paused
                  love.mouse.setVisible(true)
                  self.pause_menu:set_visible(true)
               end

            end
         end,
      }
   end,
}
