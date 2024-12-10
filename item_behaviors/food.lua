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
    local currentItem = currentSlot.item
    print(0)
    player.item_use_cooldown = 1/currentItem.use_speed
    print(1)
    player.health = player.health + 30
    print(2)
    currentSlot.amount = currentSlot.amount - 1
    print(3)
end

function onHold(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)
end

function onRelease(isLeftClick, isRightClick, player, mouseWorldPos, mouseScreenPos, deltaTime, currentSlot, mouseFocused)
end

function onDraw(player, playerFacingRight, mouseWorldPos, mouseScreenPos, mouseState, totalWorldTime, currentSlot)
    local sprites = createSpriteVector()
    return sprites 
end