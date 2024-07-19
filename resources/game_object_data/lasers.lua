local Sprites = require("resources.sprites.sprites")

return {
   LaserGun = {
      attack_rate = 1/3,
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
}
