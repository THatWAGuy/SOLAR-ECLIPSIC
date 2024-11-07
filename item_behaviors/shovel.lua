function onClick(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)

        --this is pretty self explanatory
        local currentItem = currentSlot.item

        local playerPos = vec2.new(player.position.x, player.position.y)
        local playerVel = player.velocity
        
        local pick_speed_stat = currentItem:getstat("pickaxe_speed")
        local pick_power_stat = currentItem:getstat("pickaxe_strength")
        local pick_range_stat = currentItem:getstat("pickaxe_range")
        local pick_speed = pick_speed_stat.value
        local pick_power = pick_power_stat.value
        local pick_range = pick_range_stat.value

        currentItem:changestat("held_timer", deltaTime) --held_timer is just for the item display code, not for any actual functionality.

        if(currentItem:getstat("held_timer").value > 2) then
        
            currentItem:setstat("held_timer", 0)
        end
        
        if(mouseFocused) then

            --attempt to break block right where mouse is

            --dist takes two vec2s and returns the distance in blocks
            if dist(playerPos, mouseWorldPos) < pick_range then

                --getBlockAt takes a vec2 and returns an integer, which you can use to get the block data
                local block_ind = getBlockAt(mouseWorldPos)
                local block_data = getBlockData(block_ind)

                local block_mining_time = block_data.time_to_break
                local block_hardness = block_data.hardness
    
                --avoid division by 0
                if block_hardness < 0.01 then block_hardness = 0.01 end
                if block_mining_time < 0.01 then block_mining_time = 0.01 end
                
                local total_time = block_mining_time / pick_speed
                
                if pick_power >= block_hardness then
    
                    --you might notice that "use_timer" isn't a stat on a pickaxe item. When calling "setstat" or "changestat" for a stat that doesn't exist, it'll make a new stat and assume it's value was 0.
                    currentItem:changestat("use_timer", deltaTime)

                    if currentItem:getstat("use_timer").value > total_time then
    
                        -- Create a new vec2 instance with the same values as mouseWorldPos
                        local center_of_block = vec2.new(mouseWorldPos.x, mouseWorldPos.y)
                        center_of_block.x = math.floor(center_of_block.x) + 0.5
                        center_of_block.y = math.floor(center_of_block.y) + 0.5
                    
                        dropItem(block_data.name, 1, center_of_block)
                        alterBlock(mouseWorldPos, 0)
                    
                        currentItem:setstat("use_timer", 0)
                    end
                end
            end
        else 

            --find block we're looking at
            local angleToMouse = angle(playerPos, mouseWorldPos)
            local furthestLocation = playerPos - vec2.new(0, 0.2) + vec2.new(math.cos(angleToMouse) * pick_range, math.sin(angleToMouse) * pick_range)
            local delta = furthestLocation - playerPos
            local steps

            if(math.abs(delta.x) > math.abs(delta.y)) then 
                steps = math.abs(delta.x) 
            else 
                steps = math.abs(delta.y) 
            end
            
            local xIncrement = delta.x / steps
            local yIncrement = delta.y / steps
            local currentPoint = playerPos

            --start with i = 0, repeat until i = steps, and change by 1
            for i=0,steps,1 do 
            
                if (getBlockAt(currentPoint) ~= 0) then
                    --there's a block here, attempt to break the block

                    local block_ind = getBlockAt(currentPoint)
                    local block_data = getBlockData(block_ind)

                    local block_mining_time = block_data.time_to_break
                    local block_hardness = block_data.hardness
    
                    --avoid division by 0
                    if block_hardness < 0.01 then block_hardness = 0.01 end
                    if block_mining_time < 0.01 then block_mining_time = 0.01 end
                
                    local total_time = block_mining_time / pick_speed
                
                    if pick_power >= block_hardness then
    
                        currentItem:changestat("use_timer", deltaTime)
    
                        if currentItem:getstat("use_timer").value > total_time then
    
                            local center_of_block = vec2.new(currentPoint.x, currentPoint.y)

                            center_of_block.x = math.floor(center_of_block.x) + 0.5
                            center_of_block.y = math.floor(center_of_block.y) + 0.5

                            currentPointl = vec2.new(currentPoint.x-1,currentPoint.y)
                            currentPointr = vec2.new(currentPoint.x+1,currentPoint.y)
                            currentPointu = vec2.new(currentPoint.x,currentPoint.y-1)
                            currentPointd = vec2.new(currentPoint.x,currentPoint.y+1)

                            currentPointlu = vec2.new(currentPoint.x-1,currentPoint.y-1)
                            currentPointrd = vec2.new(currentPoint.x+1,currentPoint.y+1)
                            currentPointur = vec2.new(currentPoint.x+1,currentPoint.y-1)
                            currentPointdl = vec2.new(currentPoint.x-1,currentPoint.y+1)
                    
                            dropItem("dirt", 9, center_of_block)

                            alterBlock(currentPoint, 0)

                            alterBlock(currentPointl, 0)
                            alterBlock(currentPointr, 0)
                            alterBlock(currentPointu, 0)
                            alterBlock(currentPointd, 0)

                            alterBlock(currentPointlu, 0)
                            alterBlock(currentPointrd, 0)
                            alterBlock(currentPointur, 0)
                            alterBlock(currentPointdl, 0)
                    
                            currentItem:setstat("use_timer", 0)
                        end
                    end

                    break
                end

                currentPoint.x = currentPoint.x + xIncrement
                currentPoint.y = currentPoint.y + yIncrement

            end
        end
end

function onHold(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)

end

function onRelease(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)
    local currentItem = currentSlot.item
    currentItem:setstat("use_timer", 0)
    currentItem:setstat("held_timer", 0)

end

function bool_to_number(value)
    return value and 1 or -1
    -- 1 to -1 because easier for rendering code
end

function onDraw(player, playerFacingRight, mouseWorldPos, mouseScreenPos, mouseState, totalWorldTime, currentSlot)

    local currentItem = currentSlot.item
    local playerPos = vec2.new(player.position.x, player.position.y)

    local mouseAngle = angle(playerPos, mouseWorldPos)

    local sprites = createSpriteVector()

    local pickaxe = sprite.new()
    pickaxe.size = vec2.new(1, 1)
    if(mouseState.is_left_held) then
        pickaxe.position = playerPos + vec2.new(math.cos(mouseAngle), math.sin(mouseAngle))

        local time_held = currentSlot.item:getstat("held_timer").value
        local swingRotation
        local swingMagnitude = 40

        if(time_held % 2 <= 1) then

            swingRotation = (time_held % 2) ^ 7 --0 to 1

        else
            
            swingRotation = 1 - (time_held - 1 % 2) ^ 7 --1 to 0

        end

        swingRotation = swingRotation * 2
        swingRotation = swingRotation - 1

        pickaxe.rotation = mouseAngle * 180/3.14159 + 45 + swingRotation * swingMagnitude
        pickaxe.origin = vec2.new(0, 1)
    else
        pickaxe.position = playerPos - vec2.new(bool_to_number(playerFacingRight) * 0.4, -0.2)
        pickaxe.rotation = 180 + bool_to_number(playerFacingRight) * 10
    
        pickaxe.flip_sprite_x = true 
        if (playerFacingRight) then pickaxe.flip_sprite_x = false end
    end


    pickaxe.image_path = "base item" --the drawing code in c++ will add in the "mods/specific_mod" part of the file path. If you input "base item", it'll just grab the image of the item itself.
    pickaxe.min_corner = vec2.new(currentItem.spritesheet_x, currentItem.spritesheet_y) -- this should be the top left corner (in pixels) of your texture.
    pickaxe.tex_size = vec2.new(currentItem.texture_size) -- this should be the texture size (in pixels) of your texture.

    sprites:add(pickaxe)
    return sprites --this line is ALSO crucial! It sends the entire list of sprites to the c++ code to go draw it.

end

