local Sounds = require("resources.audio.sounds")
local Sprites = require("resources.sprites.sprites")
local Lasers = require("resources.game_object_data.lasers")

return {
   green_saucer = {
      sprite = Sprites.ufoGreen,

      speed = 100,
      health = 1,
      damage = 1,

      dying_sound = Sounds.laser_explosions,
      explosion_sprite = Sprites.laserGreen14,
      rotation_rate = 6,

      weapon = {
         gun = Lasers.LaserGun,
         shot_type = Lasers.GreenLaser,
         rotation = math.pi,
         attack_rate = {
            min = 2,
            max = 10,
         },
         sound = Sounds.laser_09,
      }
   },

   yellow_saucer = {
      sprite = Sprites.ufoYellow,

      speed = 100,
      health = 2,
      damage = 1,

      dying_sound = Sounds.laser_explosions,
      explosion_sprite = Sprites.laserGreen14,
      rotation_rate = 6,

      weapon = {
         gun = Lasers.LaserGun,
         shot_type = Lasers.YellowLaser,
         rotation = math.pi,
         attack_rate = {
            min = 2,
            max = 10,
         },
         sound = Sounds.laser_09,
      }
   },

   red_saucer = {
      sprite = Sprites.ufoRed,

      speed = 100,
      health = 3,
      damage = 1,

      dying_sound = Sounds.laser_explosions,
      explosion_sprite = Sprites.laserRed08,
      rotation_rate = 6,

      weapon = {
         gun = Lasers.LaserGun,
         shot_type = Lasers.RedLaser,
         rotation = math.pi,
         attack_rate = {
            min = 2,
            max = 10,
         },
         sound = Sounds.laser_09,
      }
   }
}
