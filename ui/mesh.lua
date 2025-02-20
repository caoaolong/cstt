mesh = {
    -- 是否显示网格
    show = true,
    -- 网格颜色
    color = {.4, .4, .4, .2},
    -- 网格尺寸
    cell = 20,
    -- 网格位置
    x = 0, y = 0, w = 0, h = 0
}
mesh.__index = mesh

function mesh.init()
    mesh.w, mesh.h = love.graphics.getDimensions()
end

function mesh.draw()
    if not mesh.show then
        return
    end
    local rows = math.floor(mesh.h / mesh.cell)
    local columns = math.floor(mesh.w / mesh.cell)
    love.graphics.setColor(mesh.color)
    for i = 0, rows do
        love.graphics.line(mesh.x, i * mesh.cell, mesh.w, i * mesh.cell)
    end
    for i = 0, columns do
        love.graphics.line(i * mesh.cell, mesh.y, i * mesh.cell, mesh.h)
    end
end

return mesh