local Saucer = require("game_objects.saucer")
local SaucerData = require("resources.game_object_data.saucers")

local saucer_type = {
   SaucerData.green_saucer,
   SaucerData.yellow_saucer,
   SaucerData.red_saucer,
}

local block_wave = function(danger_level, rows)
   local game_objects = {}

   local enemy_margin_h = 50
   local enemy_margin_v = 50

   local saucer_data = saucer_type[danger_level]

   local sprite = saucer_data.sprite
   local w = sprite:getWidth()
   local h = sprite:getHeight()

   for r=1, rows do
      for c=1, 10 do
         local x = enemy_margin_h + c * (w * 1.5)
         local y = enemy_margin_v + r * (h * 1.5)
         -- print("x: ", x)
         local saucer = Saucer.new(saucer_data, x, y)
         saucer.weapon.cooldown = saucer.weapon.cooldown + r + c

         table.insert(game_objects, saucer)
      end
   end

   return game_objects
end

local transverse_block_wave = function(danger_level, rows)
   local less_danger = math.max(1, danger_level - 1)
   local game_objects = {}

   local enemy_margin_h = 50
   local enemy_margin_v = 50

   for r=1, rows do
      for c=1, 10 do

         local saucer_data = saucer_type[less_danger]
         local direction = 1
         local x_offset = 0

         if r % 2 == 0 then
            saucer_data = saucer_type[danger_level]
            direction = -1
            x_offset = saucer_data.sprite:getWidth()
         end

         local sprite = saucer_data.sprite
         local w = sprite:getWidth()
         local h = sprite:getHeight()
         local x = enemy_margin_h + c * (w * 1.5) + x_offset
         local y = enemy_margin_v + r * (h * 1.5)
         -- print("x: ", x)
         local saucer = Saucer.new(saucer_data, x, y)
         saucer.weapon.cooldown = saucer.weapon.cooldown + r + c
         saucer.direction = saucer.direction * direction

         table.insert(game_objects, saucer)
      end
   end

   return game_objects
end

local waves = {
   {
      build = function()
         local danger_level = 1
         return block_wave(danger_level, 3)
      end,
   },
   {
      build = function()
         local danger_level = 1
         return transverse_block_wave(danger_level, 3)
      end,
   },
   {
      build = function()
         local danger_level = 2
         return transverse_block_wave(danger_level, 3)
      end,
   },
   {
      build = function()
         local danger_level = 2
         return block_wave(danger_level, 3)
      end,
   },
   {
      build = function()
         local danger_level = 3
         return transverse_block_wave(danger_level, 3)
      end,
   },
   {
      build = function()
         local danger_level = 3
         return block_wave(danger_level, 3)
      end,
   },
   {
      build = function()
         local danger_level = 3
         return transverse_block_wave(danger_level, 4)
      end,
   },
   {
      build = function()
         local danger_level = 3
         return transverse_block_wave(danger_level, 5)
      end,
   },
   {
      build = function()
         local danger_level = 3
         return transverse_block_wave(danger_level, 6)
      end,
   },
}

return {

   build_wave = function(wave_count)

      if wave_count > #waves then
         return {}
      end

      return waves[wave_count].build()
   end,
}
