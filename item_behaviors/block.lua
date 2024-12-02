function onClick(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)
    local playerPos = player.position
    if dist(playerPos, mouseWorldPos) < 8 then

        local currentItem = currentSlot.item
        if(getBlockAt(mouseWorldPos) == 0) then
            --block here is air, we can place
            local blockId = currentItem:getstat("block_id").value

            local neighbors = 0

            if(getWallAt(mouseWorldPos) ~= 0) then neighbors = neighbors + 1 end

            if(getBlockAt(mouseWorldPos + vec2.new(1,0)) ~= 0) then neighbors = neighbors + 1 end
            if(getBlockAt(mouseWorldPos + vec2.new(-1,0)) ~= 0) then neighbors = neighbors + 1 end
            if(getBlockAt(mouseWorldPos + vec2.new(0,1)) ~= 0) then neighbors = neighbors + 1 end
            if(getBlockAt(mouseWorldPos + vec2.new(0,-1)) ~= 0) then neighbors = neighbors + 1 end

            --if there's a neighboring block or a wall behind the current block
            if (neighbors > 0) then
                alterBlock(mouseWorldPos, blockId)
                currentSlot.amount = currentSlot.amount - 1
            end
        end
    end
end

function onHold(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)
    -- Add your logic here
end

function onRelease(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)
    currentItem:setstat("use_timer", 0)
end

function onDraw(player, playerFacingRight, mouseWorldPos, mouseScreenPos, mouseState, totalWorldTime, currentSlot)

    local playerPos = player.position

    local sprites = createSpriteVector()

    local block = sprite.new()

    block.position = playerPos - vec2.new(bool_to_number(playerFacingRight) * -0.6, -0.2)
    block.size = vec2.new(0.6, 0.6)
    block.rotation = 180 + bool_to_number(playerFacingRight) * -10

    block.flip_sprite_x = playerFacingRight
    block.flip_sprite_y = true

    block.image_path = "base item" --the drawing code in c++ will add in the "mods/specific_mod" part of the file path. If you input "base item", it'll just grab the image of the item itself.
    block.min_corner = vec2.new(0,0) -- this should be the top left corner (in pixels) of your texture.
    block.tex_size = vec2.new(8,8) -- this should be the texture size (in pixels) of your texture.

    sprites:add(block)

    return sprites --this line is ALSO crucial! It sends the entire list of sprites to the c++ code to go draw it.
end