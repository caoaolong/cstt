local Grid = {}
Grid.__index = Grid

function Grid.new(cellSize)
    local self = setmetatable({}, Grid)
    self.scale = 1.0
    self.cellSize = cellSize or 20
    self.offsetX = 0
    self.offsetY = 0
    self.visible = true  -- 添加可见性控制
    return self
end

function Grid:zoom(direction)
    if direction > 0 then
        self.scale = self.scale * 1.1
    elseif direction < 0 then
        self.scale = self.scale * 0.9
    end
    self.scale = math.max(0.1, math.min(self.scale, 5.0))
end

function Grid:pan(dx, dy)
    self.offsetX = self.offsetX + dx
    self.offsetY = self.offsetY + dy
end

function Grid:draw()
    -- 如果网格不可见，直接返回
    if not self.visible then
        return
    end
    
    -- 保存当前颜色
    local r, g, b, a = love.graphics.getColor()
    
    -- 设置绘图颜色为灰色
    love.graphics.setColor(0.5, 0.5, 0.5)
    
    -- 计算实际网格大小
    local actualCellSize = self.cellSize * self.scale
    
    -- 获取窗口尺寸
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- 计算需要绘制的网格线数量
    local startX = self.offsetX % actualCellSize
    local startY = self.offsetY % actualCellSize
    
    -- 绘制垂直线
    local numVerticalLines = math.ceil(windowWidth / actualCellSize) + 1
    for i = 0, numVerticalLines do
        local x = startX + i * actualCellSize
        love.graphics.line(x, 0, x, windowHeight)
    end
    
    -- 绘制水平线
    local numHorizontalLines = math.ceil(windowHeight / actualCellSize) + 1
    for i = 0, numHorizontalLines do
        local y = startY + i * actualCellSize
        love.graphics.line(0, y, windowWidth, y)
    end
    
    -- 恢复原来的颜色
    love.graphics.setColor(r, g, b, a)
end

-- 获取当前缩放比例
function Grid:getScale()
    return self.scale
end

-- 获取当前网格大小
function Grid:getCellSize()
    return self.cellSize
end

-- 设置网格大小
function Grid:setCellSize(size)
    self.cellSize = size
end

-- 设置网格可见性
function Grid:setVisible(visible)
    self.visible = visible
end

-- 获取网格可见性
function Grid:isVisible()
    return self.visible
end

return Grid 