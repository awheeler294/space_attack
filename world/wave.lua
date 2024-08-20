local rs = require "resolution_solution.resolution_solution"

local MovementProfiles = require("game_objects.movement_profiles")
local Saucer = require("game_objects.saucer")
local SaucerData = require("resources.game_object_data.saucers")

local saucer_type = {
   SaucerData.green_saucer,
   SaucerData.yellow_saucer,
   SaucerData.red_saucer,
}

local enemy_margin_h = 50
local enemy_margin_v = 50

local block_wave = function(danger_level, rows)
   local game_objects = {}

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

local circle_wave = function(danger_level, circle_count, ring_count)
   local game_objects = {}
   local saucer_data = saucer_type[math.min(danger_level, #saucer_type)]
   local sprite = saucer_data.sprite
   local w = sprite:getWidth()
   local h = sprite:getHeight()
   local radius = h * 1.5
   local center_y = (rs.game_height - radius * (ring_count / 2)) / 2

   for circle = 1, circle_count do

      local center_x = circle * (rs.game_width / (circle_count + 1)) - w / 2

      local center_saucer = Saucer.new(saucer_data, center_x, center_y)
      center_saucer.movement_profile = MovementProfiles.stationary.new()
      table.insert(game_objects, center_saucer)

      for ring = 1, ring_count do
         local less_danger = math.min(math.max(danger_level - ring, 1), #saucer_type)
         local ring_saucer_data = saucer_type[less_danger]
         local r = radius * ring

         for angle = 0, 2 * math.pi, (2 * math.pi) / (6 * ring) do
            local saucer = Saucer.new(ring_saucer_data, center_x, center_y + r)
            saucer.movement_profile = MovementProfiles.circular.new(center_saucer, r, angle)

            if ring % 2 == 0 then
               saucer.direction = saucer.direction * -1
            end

            saucer.weapon.cooldown = saucer.weapon.cooldown + ring

            table.insert(game_objects, saucer)
         end
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
         local danger_level = 1
         local circles = 2
         local rings = 2
         return circle_wave(danger_level, circles, rings)
      end,
   },
   {
      build = function()
         local danger_level = 1
         local circles = 1
         local rings = 3
         return circle_wave(danger_level, circles, rings)
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
         local danger_level = 2
         local circles = 2
         local rings = 2
         return circle_wave(danger_level, circles, rings)
      end,
   },
   {
      build = function()
         local danger_level = 2
         local circles = 1
         local rings = 3
         return circle_wave(danger_level, circles, rings)
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
         local circles = 2
         local rings = 2
         return circle_wave(danger_level, circles, rings)
      end,
   },
   {
      build = function()
         local danger_level = 3
         local circles = 1
         local rings = 3
         return circle_wave(danger_level, circles, rings)
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
   {
      build = function()
         local danger_level = 5
         local circles = 2
         local rings = 2
         return circle_wave(danger_level, circles, rings)
      end,
   },
   {
      build = function()
         local danger_level = 5
         local circles = 1
         local rings = 3
         return circle_wave(danger_level, circles, rings)
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
