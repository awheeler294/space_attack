local Saucer = require("game_objects.saucer")
local SaucerData = require("resources.game_object_data.saucers")

return {
   build_wave = function(wave_count)

      local game_objects = {}

      local enemy_margin_h = 50
      local enemy_margin_v = 50

      local saucer_type = {
         SaucerData.green_saucer,
         SaucerData.yellow_saucer,
         SaucerData.red_saucer,
      }

      local saucer_data = saucer_type[wave_count]

      local sprite = saucer_data.sprite
      local w = sprite:getWidth()
      local h = sprite:getHeight()

      for r=1, 3 do
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
   end,
}
