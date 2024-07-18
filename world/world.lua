require("TESound.tesound")
local GameObjects = require("game_objects.game_objects")
local Player = require("game_objects.player")
local Saucer = require("game_objects.saucer")
local Backdrop = require("world.backdrop")

return {
   new = function(world_data)

      local sprite_data = require(world_data.sprite_data)
      local sprite_sheet = love.graphics.newImage("resources/game_object_data/spritesheet/" .. sprite_data.image_path)

      local hostiles = {}


      return {
         wave_count = 1,

         backdrop = Backdrop.new(world_data.backdrop.image_path, world_data.backdrop.speed),

         game_objects = {

            player = Player.new(sprite_data, sprite_sheet),
            friendlies = {},
            hostiles = {},

            build_wave = function()
               local game_objects = {}

               local enemy_margin_h = 50
               local enemy_margin_v = 50

               local w = sprite_data.textures.ufoGreen.width
               local h = sprite_data.textures.ufoGreen.height

               for r=1, 3 do
                  for c=1, 10 do
                     local x = enemy_margin_h + c * (w * 1.5)
                     local y = enemy_margin_v + r * (h * 1.5)
                     -- print("x: ", x)
                     local saucer = Saucer.new(sprite_data, x, y, sprite_sheet)
                     saucer.weapon.cooldown = saucer.weapon.cooldown + r + c
                     table.insert(game_objects, saucer)
                  end
               end

               return game_objects
            end,

            update = function(self, dt)
               if #self.hostiles == 0 and #self.friendlies == 0 then
                  self.hostiles = self.build_wave()
               end

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
                     f:maybeCollide(h)
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
                  o:draw(sprite_sheet)
               end

               for _, o in ipairs(self.hostiles) do
                  o:draw(sprite_sheet)
               end

            end,
         },

         update = function(self, dt)
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
