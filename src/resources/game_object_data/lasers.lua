local Sprites = require("resources.sprites.sprites")

return {
   LaserGun = {
      attack_rate = 1/3,
      width = 2,
      height = 2,

      sound = love.sound.newSoundData("resources/audio/laserSmall_002.ogg"),
   },

   LaserGun2 = {
      attack_rate = 1/6,
      width = 2,
      height = 2,

      sound = love.sound.newSoundData("resources/audio/laserSmall_002.ogg"),
   },

   LaserGun3 = {
      attack_rate = 1/12,
      width = 2,
      height = 2,

      sound = love.sound.newSoundData("resources/audio/laserSmall_002.ogg"),
   },

   BlueLaser = {
      speed = 1000,
      health = 1,
      damage = 1,
      range = 2000,

      sprite = Sprites.laserBlue07,

      explode_frames = {
            Sprites.laserBlue08,
            Sprites.laserBlue08,
            Sprites.laserBlue09,
            Sprites.laserBlue09,
         }
   },

   BlueLaser2 = {
      speed = 1000,
      health = 1,
      damage = 2,
      range = 2000,

      sprite = Sprites.laserBlue16,

      explode_frames = {
            Sprites.laserBlue08,
            Sprites.laserBlue08,
            Sprites.laserBlue09,
            Sprites.laserBlue09,
         }
   },

   GreenLaser = {
      speed = 1000,
      health = 1,
      damage = 1,
      range = 2000,

      sprite = Sprites.laserGreen13,

      explode_frames = {
            Sprites.laserGreen14,
            Sprites.laserGreen14,
            Sprites.laserGreen15,
            Sprites.laserGreen15,
         }
   },

   YellowLaser = {
      speed = 1250,
      health = 1,
      damage = 2,
      range = 2000,

      sprite = Sprites.laserGreen10,

      explode_frames = {
            Sprites.laserGreen14,
            Sprites.laserGreen14,
            Sprites.laserGreen15,
            Sprites.laserGreen15,
         }
   },

   RedLaser = {
      speed = 1500,
      health = 1,
      damage = 3,
      range = 2000,

      sprite = Sprites.laserRed07,

      explode_frames = {
            Sprites.laserRed14,
            Sprites.laserRed14,
            Sprites.laserRed15,
            Sprites.laserRed15,
         }
   },
}
