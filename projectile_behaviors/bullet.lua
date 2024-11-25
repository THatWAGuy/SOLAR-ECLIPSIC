function update(deltaTime, thisProjectile)
    
    --move projectile based off velocity
    thisProjectile.position.x = thisProjectile.position.x + (thisProjectile.velocity.x * deltaTime)
    thisProjectile.position.y = thisProjectile.position.y + (thisProjectile.velocity.y * deltaTime)

    --accelerate projectile based off acceleration
    thisProjectile.velocity.x = thisProjectile.velocity.x + (thisProjectile.acceleration.x * deltaTime)
    thisProjectile.velocity.y = thisProjectile.velocity.y + (thisProjectile.acceleration.y * deltaTime)

    --slow projectile based off of drag

    local slow_across_full_second = vec2.new()
    slow_across_full_second.x = thisProjectile.velocity.x * thisProjectile.drag
    slow_across_full_second.y = thisProjectile.velocity.y * thisProjectile.drag

    thisProjectile.velocity.x = thisProjectile.velocity.x - slow_across_full_second.x * deltaTime
    thisProjectile.velocity.y = thisProjectile.velocity.y - slow_across_full_second.y * deltaTime

    --drop projectile based off of drop
    thisProjectile.velocity.y = thisProjectile.velocity.y + (thisProjectile.drop * deltaTime)

end

function onHitWall(thisProjectile)
    thisProjectile.bounces = thisProjectile.bounces - 1

    if(thisProjectile.bounces < 1) then
        thisProjectile.delete_this = true
       end
end

function onHitEntity(thisProjectile, collidingEntity)
   collidingEntity:takedamage(thisProjectile.damage, thisProjectile:getstat("armorpierce"), false, 0.5)

   if(thisProjectile.pierces < 1) then
    thisProjectile.delete_this = true
   end
end

function onHitProjectile(thisProjectile, otherProjectile)

end