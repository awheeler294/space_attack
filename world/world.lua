require("TESound.tesound")
local GameObjects = require("game_objects.game_objects")
local Player = require("game_objects.player")
local Backdrop = require("world.backdrop")
local Wave = require("world.wave")

return {
   new = function(world_data)

      local sprites = world_data.sprites

      local p_x = love.graphics.getWidth() / 2
      local p_y = love.graphics.getHeight() / 1.15

      return {
         backdrop = Backdrop.new(world_data.backdrop.image_path, world_data.backdrop.speed),

         wave_count = 0,
         wave_cooldown = 0,

         game_objects = {
            player = Player.new(sprites.playerShip1_blue, p_x, p_y),
            friendlies = {},
            hostiles = {},

            update = function(self, dt)

               for i = #self.friendlies, 0, -1 do
                  local f
                  if i == 0 then
                     if self.player.state == GameObjects.State.dead then
                        break
                     end
                     f = self.player
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

               for i = #self.hostiles, 1, -1 do
                  local h = self.hostiles[i]

                  h:update(dt)

                  if h.state == GameObjects.State.dead then
                     table.remove(self.hostiles, i)
                  end

                  local attack_result = h:maybeAttack()
                  if attack_result then
                     table.insert(self.hostiles, attack_result)
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

            end,
         },

         update = function(self, dt)
            if #self.game_objects.hostiles == 0 then
               self.wave_cooldown = self.wave_cooldown - dt
               if self.wave_cooldown <= 0 then
                  self.wave_count = self.wave_count + 1
                  self.game_objects.hostiles = Wave.build_wave(self.wave_count)
                  self.wave_cooldown = 2
               end
            end

            self.backdrop:update(dt)
            self.game_objects:update(dt)
         end,

         draw = function(self)
            self.backdrop:draw()
            self.game_objects:draw()
         end,
      }
   end,
}
