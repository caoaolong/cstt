cursor = {
    state = "normal", 
    cameraX = 0, cameraY = 0,
    scale = 1.0,
    -- 当前触发的节点
    handed = nil,
    -- 当前选择的节点
    picked = nil,
    -- 当前场景的所有节点列表引用
    nodes = nil
}
cursor.__index = cursor

function cursor.load(nodes)
    cursor.nodes = nodes
end

function cursor.nodes()
    return cursor.nodes
end

local function findNodeIndex(node)
    for index, value in ipairs(cursor.nodes) do
        if value == node then
            return index
        end
    end
    return 0
end

function cursor.putTop(node)
    local index = findNodeIndex(node)
    if index > 0 then
        table.remove(cursor.nodes, index)
        table.insert(cursor.nodes, node)
    end
end

function cursor.putBottom(node)
    local index = findNodeIndex(node)
    if index > 0 then
        table.remove(cursor.nodes, index)
        table.insert(cursor.nodes, 1, node)
    end
end

function cursor.moveCamera(dx, dy)
    cursor.cameraX = cursor.cameraX + dx / cursor.scale
    cursor.cameraY = cursor.cameraY + dy / cursor.scale
end

function cursor.scaleCamera(x, y)
    -- 获取鼠标位置
    local mx, my = love.mouse.getPosition()
    -- 计算鼠标在世界坐标中的位置
    local worldX, worldY = love.graphics.inverseTransformPoint(mx, my)
    -- 更新缩放比例
    local zoomFactor = 0.1
    if y > 0 then
        cursor.scale = cursor.scale + zoomFactor
    elseif y < 0 then
        cursor.scale = cursor.scale - zoomFactor
    end
    -- 计算新的偏移，使鼠标位置在缩放后保持不变
    cursor.cameraX = mx - worldX * cursor.scale
    cursor.cameraY = my - worldY * cursor.scale
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

function cursor.pickUp(node)
    node.state = "dragging"
    cursor.picked = node
end

function cursor.putDown()
    local node = cursor.picked
    node.state = "entered"
    cursor.picked = nil
    return node
end

function cursor.handOn(node)
    if cursor.handing then
        return
    end
    if cursor.handed ~= nil then
        cursor.handed.state = "created"
    end
    node.state = "entered"
    cursor.handed = node
end

function cursor.handOff(node)
    node.state = "created"
    if cursor.handed == node then
        cursor.handed = nil
    end
end

function cursor.mousemoved(x, y, dx, dy, istouch)
    if cursor.picked == nil then
        return
    end
    local node = cursor.picked
    if node.state == "dragging" then
        node.cx, node.cy = node.cx + dx / cursor.scale, node.cy + dy / cursor.scale
        node.tx, node.ty = node.cx + node.paddingX, node.cy + node.paddingY
    end
end

return cursor