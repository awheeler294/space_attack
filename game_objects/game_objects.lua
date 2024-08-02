---Check if a and b collide
---@param a {x: number, y: number, width: number, height: number}
---@param b {x: number, y: number, width: number, height: number}
---@return boolean
local function checkCollision(a, b)

   local lhs = {
      left = a.x,
      right = a.x + a.width,
      top = a.y,
      bottom = a.y + a.height,

      radius = math.min(a.width / 2, a.height / 2),
      center_x = a.x + a.width / 2,
      center_y = a.y + a.height / 2,
   }

   local rhs = {
      left = b.x,
      right = b.x + b.width,
      top = b.y,
      bottom = b.y + b.height,

      radius = math.min(b.width / 2, b.height / 2),
      center_x = b.x + b.width / 2,
      center_y = b.y + b.height / 2,
   }

   local distance = math.sqrt((rhs.center_x - lhs.center_x)^2 + (rhs.center_y - lhs.center_y)^2)

   return  lhs.right > rhs.left
      and lhs.left < rhs.right
      and lhs.bottom > rhs.top
      and lhs.top < rhs.bottom
      and distance < math.max(lhs.radius, rhs.radius)
end

local GameObjectState = {
   alive = "alive",
   dying = "dying",
   dead = "dead",
}

return {

   new = function (x, y, speed, health, damage, sprite, dying_sound, shield)

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

         shield = shield,

         current_collisions = {},

         update_collision = function(self)
            local my_collision = self
            if self.shield and self.shield.health > 0 then
               my_collision = self.shield
            end

            for other, _ in pairs(self.current_collisions) do
               local other_collision = other

               if other.shield and other.shield.health > 0 then
                  other_collision = other.shield
               end

               if checkCollision(my_collision, other_collision) == false then
                  -- print("Not Colliding", self, other)
                  self.current_collisions[other] = nil
                  other.current_collisions[self] = nil
               end

            end
         end,

         check_collision = function (self, other)
            if self.current_collisions[other] == nil then
               if self.shield and self.shield.health > 0 then
                  return checkCollision(self.shield, other)
               end

               return checkCollision(self, other)
            end
         end,

         collide = function(self, other)
            local this = self
            if self.shield and self.shield.health > 0 then
               this = self.shield
               -- print("Shield health: ", shield.health, "Other damage: ", other.damage, "Self: ", self, "Other: ", other)
            end

            this.health = this.health - other.damage
            other.health = other.health - this.damage

            -- if self.shield then
            --    print("Shield health: ", shield.health)
            -- end

            self.current_collisions[other] = true
            other.current_collisions[self] = true
         end,

         maybeCollide = function(self, other, dt)
            if self:check_collision(other) then
               self:collide(other, dt)
            end
         end,

         maybeAttack = function(_)
            return false
         end
      }

   end,

   State = GameObjectState,

}
