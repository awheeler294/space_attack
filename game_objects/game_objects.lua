---Check if a and b collide
---@param a {x: number, y: number, width: number, height: number}
---@param b {x: number, y: number, width: number, height: number}
---@return boolean
local function checkCollision(a, b)

   local a = {
      left = a.x,
      right = a.x + a.width,
      top = a.y,
      bottom = a.y + a.height,

      radius = math.min(a.width / 2, a.height / 2),
      center_x = a.x + a.width / 2,
      center_y = a.y + a.height / 2,
   }

   local b = {
      left = b.x,
      right = b.x + b.width,
      top = b.y,
      bottom = b.y + b.height,

      radius = math.min(b.width / 2, b.height / 2),
      center_x = b.x + b.width / 2,
      center_y = b.y + b.height / 2,
   }

   local distance = math.sqrt((b.center_x - a.center_x)^2 + (b.center_y - a.center_y)^2)

   return  a.right > b.left
      and a.left < b.right
      and a.bottom > b.top
      and a.top < b.bottom
      and distance < math.max(a.radius, b.radius)
end

local GameObjectState = {
   alive = "alive",
   dying = "dying",
   dead = "dead",
}

return {

   new = function (x, y, speed, health, damage, sprite, dying_sound)

      return {
         base_x = x,
         base_y = y,

         x = x,
         y = y,

         width = sprite:getWidth(),
         height = sprite:getHeight(),

         sprite = sprite,

         shear_x = 0,
         shear_y = 0,

         speed = speed,
         health = health,
         damage = damage,

         state = GameObjectState.alive,

         dying_sound = dying_sound,

         current_collisions = {},

         update_collision = function(self)
            for other, _ in pairs(self.current_collisions) do
               if checkCollision(self, other) == false then
                  self.current_collisions[other] = nil
                  other.current_collisions[self] = nil
               end
            end
         end,

         checkCollision = function (self, other)
            return checkCollision(self, other)
         end,

         collide = function(self, other)
            self.health = self.health - other.damage
            other.health = other.health - self.damage

            self.current_collisions[other] = true
            other.current_collisions[self] = true
         end,

         maybeCollide = function(self, other, dt)
            if self.current_collisions[other] == nil then
               if self:checkCollision(other) then
                  self:collide(other, dt)
               end
            end
         end,

         maybeAttack = function(_)
            return false
         end
      }

   end,

   State = GameObjectState,

}
