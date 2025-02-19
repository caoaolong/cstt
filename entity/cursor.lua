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
    if cursor.handed ~= nil then
        return
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
        node.cx, node.cy = node.cx + dx, node.cy + dy
        node.tx, node.ty = node.cx + node.paddingX, node.cy + node.paddingY
    end
end

return cursor