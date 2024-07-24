require("TESound.tesound")
local rs = require("resolution_solution.resolution_solution")

local Animation = require("animation")
local Backdrop = require("world.backdrop")
local GameObjects = require("game_objects.game_objects")
local Player = require("game_objects.player")
local Powerup = require("game_objects.powerups")
local Wave = require("world.wave")

return {
   new = function(world_data)

      local sprites = world_data.sprites

      local px = rs.game_width / 2
      local py = rs.game_height / 1.15

      return {
         backdrop = Backdrop.new(world_data.backdrop.image_path, world_data.backdrop.speed),

         wave_count = 0,
         wave_cooldown = 0,

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
            player = Player.new(sprites.playerShip1_blue, px, py),
            friendlies = {},
            hostiles = {},
            powerups = {},

            player_won = false,

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
                        if f:checkCollision(p) then
                           f:collide(p)
                           f:powerup(p.powerup_amount)
                        end
                     end
                  else
                     f = self.friendlies[i]
                  end

                  for _, h in ipairs(self.hostiles) do
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
            if self.player_won == true and #self.text_animations == 0 then
               table.insert(self.text_animations, Animation.create_text_animation("You Win!"))
            end

            if #self.game_objects.hostiles == 0 then
               self.wave_cooldown = self.wave_cooldown - dt
               if self.wave_cooldown <= 0 then

                  self.wave_count = self.wave_count + 1
                  self.wave_cooldown = 2

                  self.game_objects.hostiles = Wave.build_wave(self.wave_count)

                  if #self.game_objects.hostiles == 0 then
                     self.player_won = true
                  end

               end
            end

            self.text_animations:update(dt)
            self.backdrop:update(dt)
            self.game_objects:update(dt)
         end,

         draw = function(self)
            self.backdrop:draw()
            self.game_objects:draw()
            self.text_animations:draw()
         end,
      }
   end,
}
