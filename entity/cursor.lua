cursor = {
    state = "normal", 
    cameraX = 0, cameraY = 0,
    scale = 1.0,
    -- 视图操作开启状态
    handing = false
}
cursor.__index = cursor

function cursor.moveCamera(dx, dy)
    cursor.cameraX = cursor.cameraX + dx
    cursor.cameraY = cursor.cameraY + dy
end

function cursor.scaleCamera(d)
    cursor.scale = cursor.scale + d * 0.1
    cursor.cameraX = cursor.cameraX + d * 0.05
    cursor.cameraY = cursor.cameraY + d * 0.05
end

function cursor.zoom()
    return cursor.scale, cursor.scale
end

function cursor.camera()
    return cursor.cameraX, cursor.cameraY
end

function cursor.reset()
    cursor.cameraX = 0
    cursor.cameraY = 0
    cursor.scale = 1.0
end

return cursor