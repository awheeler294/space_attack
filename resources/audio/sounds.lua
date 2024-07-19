local laser_00 = love.sound.newSoundData("resources/audio/Laser/Laser_00.wav")
local laser_01 = love.sound.newSoundData("resources/audio/Laser/Laser_01.wav")
local laser_02 = love.sound.newSoundData("resources/audio/Laser/Laser_02.wav")
local laser_03 = love.sound.newSoundData("resources/audio/Laser/Laser_03.wav")
local laser_04 = love.sound.newSoundData("resources/audio/Laser/Laser_04.wav")
local laser_05 = love.sound.newSoundData("resources/audio/Laser/Laser_05.wav")
local laser_06 = love.sound.newSoundData("resources/audio/Laser/Laser_06.wav")
local laser_07 = love.sound.newSoundData("resources/audio/Laser/Laser_07.wav")
local laser_08 = love.sound.newSoundData("resources/audio/Laser/Laser_08.wav")
local laser_09 = love.sound.newSoundData("resources/audio/Laser/Laser_09.wav")

return {

   laser_00 = laser_00,
   laser_01 = laser_01,
   laser_02 = laser_02,
   laser_03 = laser_03,
   laser_04 = laser_04,
   laser_05 = laser_05,
   laser_06 = laser_06,
   laser_07 = laser_07,
   laser_08 = laser_08,
   laser_09 = laser_09,

   crunchy_explosions = {
      love.sound.newSoundData("resources/audio/explosionCrunch_000.ogg"),
      love.sound.newSoundData("resources/audio/explosionCrunch_001.ogg"),
      love.sound.newSoundData("resources/audio/explosionCrunch_002.ogg"),
      love.sound.newSoundData("resources/audio/explosionCrunch_003.ogg"),
      love.sound.newSoundData("resources/audio/explosionCrunch_004.ogg"),
   },

   low_frequency_explosions = {
      love.sound.newSoundData("resources/audio/lowFrequency_explosion_000.ogg"),
      love.sound.newSoundData("resources/audio/lowFrequency_explosion_001.ogg"),
   },

   laser_explosions = {
      laser_00,
      laser_01,
      laser_02,
      laser_03,
      laser_04,
      laser_05,
      laser_06,
      laser_07,
      laser_08,
   }
}

