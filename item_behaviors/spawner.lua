function bool_to_number(value)
    return value and 1 or -1
    -- 1 to -1 because easier for rendering code
end

function number_to_bool(value)
    if(value) then
        return 1 
    else
        return 0
    end
end

function onClick(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)
    spawnMob(getMobID("Sentry"), mouseWorldPos, vec2.new(0,0))
    player.item_use_cooldown = 0.05
end

function onHold(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)

end

function onRelease(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)

    local currentItem = currentSlot.item
    currentItem:setstat("swing_count", 0) --reset to zero when we stop using the sword
end

function onDraw(player, playerFacingRight, mouseWorldPos, mouseScreenPos, mouseState, totalWorldTime, currentSlot)

    local playerPos = vec2.new(player.position.x, player.position.y)

    local currentItem = currentSlot.item
    local mouseAngle = angle(player.position, mouseWorldPos)
    local sprites = createSpriteVector()
    local staff = sprite.new()
    
    staff.image_path = "base item" --the drawing code in c++ will add in the "mods/specific_mod" part of the file path. If you input "base item", it'll just grab the image of the item itself.
    staff.min_corner = vec2.new(currentItem.spritesheet_x,currentItem.spritesheet_y) -- this should be the top left corner (in pixels) of your texture.
    staff.tex_size = vec2.new(currentItem.texture_size) -- this should be the texture size (in pixels) of your texture.

    staff.position = playerPos
    staff.rotation = 0
    staff.size = vec2.new(currentItem.size, currentItem.size)
    if(player.item_use_cooldown > 0) then
        staff.origin = vec2.new(0, 1)
        staff.position = playerPos + vec2.new(math.cos(mouseAngle), math.sin(mouseAngle))
        staff.rotation = 45 + radiansToDegrees(mouseAngle)
    else 
        staff.position = playerPos - vec2.new(bool_to_number(playerFacingRight) * 0.4, -0.2)
        staff.rotation = 180 + bool_to_number(playerFacingRight) * 10
    
        staff.flip_sprite_x = true 
        if (playerFacingRight) then staff.flip_sprite_x = false end

    end

    sprites:add(staff)

    return sprites --this line is ALSO crucial! It sends the entire list of sprites to the c++ code to go draw it.

end

