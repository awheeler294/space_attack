local sprite_data = require("resources/game_object_data/spritesheet/sheet")

return {
   blueLaser = {
      speed = 1000,
      health = 1,
      damage = 1,
      range = 2000,

      texture = sprite_data.textures.laserBlue07,

      explode_frames = {
            sprite_data.textures.laserBlue08,
            sprite_data.textures.laserBlue08,
            sprite_data.textures.laserBlue09,
            sprite_data.textures.laserBlue09,
         }
   },

   greenLaser = {
      speed = 1000,
      health = 1,
      damage = 1,
      range = 2000,

      texture = sprite_data.textures.laserGreen13,

      explode_frames = {
            sprite_data.textures.laserGreen14,
            sprite_data.textures.laserGreen14,
            sprite_data.textures.laserGreen15,
            sprite_data.textures.laserGreen15,
         }
   },
}

