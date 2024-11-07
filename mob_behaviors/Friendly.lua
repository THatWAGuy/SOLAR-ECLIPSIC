function update(deltaTime, thisMob)
    -- Determine where we're going to move
    local nearestPlayer = findClosestMobWithTag(thisMob.position, "Hostile")
    if(nearestPlayer == nil)then
        local nearestPlayer = findClosestPlayer(thisMob.position)
    end
    local nearestPlayerPos = nearestPlayer.position

    local move_dir = -1
    if nearestPlayerPos.x > thisMob.position.x then
        move_dir = 1
        thisMob:setstat("player_is_right", 1)
    else
        thisMob:setstat("player_is_right", 0)

    end

    -- Determine if we should jump
    local jump = false
    local getPos = vec2.new();
    getPos.x = thisMob.position.x;
    getPos.y = thisMob.position.y;

    -- Check the pos one block to the side of the mob, in the direction we're moving
    getPos.x = getPos.x + (move_dir * thisMob.size.x * 0.50) + move_dir * 0.95
    -- Offset to edge of mob and offset ~1 block further

    -- Make sure the point is near the ground as well
    getPos.y = getPos.y + thisMob.size.y * 0.48

    if getBlockAt(getPos) > 0 then
        jump = true
    end

    -- If we've touched the ground recently and we haven't used up all of our jumping frames
    if thisMob:getstat("time_since_last_touched_ground").value < 0.1 and thisMob:getstat("jump_time").value > 0 and jump then
        thisMob:changestat("jump_time", -deltaTime)
        thisMob.velocity.y = thisMob.velocity.y - thisMob:getstat("jump_power").value * deltaTime
    end

    -- Cap our movement speed to our max movement speed
    local maxspeed = thisMob:getstat("max_movement_speed").value

    if thisMob.velocity.x < maxspeed * -1 then
        thisMob.velocity.x = maxspeed * -1
    elseif thisMob.velocity.x > maxspeed then
        thisMob.velocity.x = maxspeed
    end

    --actually accelerate mob towards player
    thisMob.velocity.x = thisMob.velocity.x + thisMob:getstat("movement_speed").value * move_dir * deltaTime

    --accelerate mob towards ground based on gravity
    thisMob.velocity.y = thisMob.velocity.y + thisMob:getstat("gravity").value * deltaTime

    local vel_dif = vec2.new();
    vel_dif.x = thisMob.velocity.x * thisMob.friction
    vel_dif.y = thisMob.velocity.y * thisMob.friction

    thisMob.velocity.x = thisMob.velocity.x - vel_dif.x * deltaTime
    thisMob.velocity.y = thisMob.velocity.y - vel_dif.y * deltaTime

    -- Move mob
    thisMob.position.x = thisMob.position.x + (thisMob.velocity.x * deltaTime)
    thisMob.position.y = thisMob.position.y + (thisMob.velocity.y * deltaTime)

    --Now do ground check for jumping stuff
    local touching_ground = thisMob:touchingground(false);
    if touching_ground then

        thisMob:setstat("time_since_last_touched_ground", 0)
        thisMob:setstat("jump_time", thisMob:getstat("max_jump_time").value)

    end

    --flag this mob for deletion if its health drops below 0
    --the reason why this is left to the developer is that it should be customizable. This allows for a mob to explode on death for example, or enter a 30 second desperation phase, etc.
    if (thisMob.health < 0) then
        thisMob.delete_this = true --when delete_this is set to true, the mob is deleted that frame and wont be rendered, but it'll still call onHitEntity, onHitWall, onHitProjectile and finish updating.
    end

    thisMob:changestat("anim_time", (math.abs(thisMob.velocity.x)/deltaTime)/6000)
    if(thisMob:getstat("anim_time").value > 1) then
        --increment anim frame counter
        thisMob:setstat("anim_time", 0)
        thisMob:changestat("anim_frame", 1)
    end
end

function onHitWall(thisMob)

end

function onHitEntity(thisMob, otherEntity)
   if(otherEntity:is_player()==false) then
        if(otherEntity:hastag("sentry"))then
            --otherEntity:takedamage(-1, 1, 0.4, false)
        else
            otherEntity:takedamage(20, 1, 0.4, false)
            thisMob:takedamage(1, 1, 0.4, false)
        end
   end
end

function onDraw(thisMob)

    local sprites = createSpriteVector()

    local zombie = sprite.new()
    zombie.image_path = "this mob" --"this mob" will just use the image of the mob. This is significantly faster than a seperate spritesheet


    local tex_res_x = thisMob:getstat("texture_res_x").value
    local tex_res_y = thisMob:getstat("texture_res_y").value
    local tex_min_x = 0
    local tex_min_y = 0

    zombie.tex_size = vec2.new(tex_res_x, tex_res_y)
    zombie.size = vec2.new(tex_res_x/8, tex_res_y/8)

    if(math.abs(thisMob.velocity.y) > 0.5) then
        --mob is traveling vertically, prioritise that

        tex_min_x = 0

        if(thisMob.velocity.y > 0) then
            --mob travelling down

            tex_min_y = 0
        else
            --mob travelling up

            tex_min_y = 0
        end
    else
        --mob is traveling horizontally, or not at all
        if(math.abs(thisMob.velocity.x) > 0.1) then

            tex_min_x = 0
            tex_min_y = thisMob:getstat("anim_frame").value % thisMob:getstat("run_frames").value

        else
            tex_min_x = 0
            tex_min_y = 0
        end
    end

    if(thisMob:getstat("player_is_right").value == 1) then
        zombie.flip_sprite_x = true
    else
        zombie.flip_sprite_x = false
    end

    zombie.min_corner = vec2.new(tex_min_x * tex_res_x, tex_min_y * tex_res_y)
    zombie.origin = vec2.new(0.5, 0.5)
    zombie.position = thisMob.position
    sprites:add(zombie)

    return sprites
end