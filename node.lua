local Node = {}
Node.__index = Node

function Node.new(x, y, width, height)
    local self = setmetatable({}, Node)
    self.x = x
    self.y = y
    self.width = width or 100
    self.height = height or 100
    self.isDragging = false
    self.isHovered = false
    self.isHighlighted = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.backgroundColor = {0.2, 0.3, 0.4, 1.0}  -- 默认背景色
    self.hoverColor = {0.3, 0.4, 0.5, 1.0}      -- 悬停时的颜色
    self.activeColor = {0.4, 0.5, 0.6, 1.0}     -- 点击时的颜色
    self.currentColor = self.backgroundColor
    self.borderColor = {1, 1, 1, 0.8}           -- 边框颜色
    self.highlightColor = {0.8, 0.8, 0.2, 1.0}  -- 高亮颜色
    self.text = "节点"
    return self
end

function Node:update(mx, my)
    -- 检查鼠标是否在节点上
    self.isHovered = mx >= self.x and mx <= self.x + self.width and
                     my >= self.y and my <= self.y + self.height

    -- 更新颜色
    if self.isDragging then
        self.currentColor = self.activeColor
    elseif self.isHovered then
        self.currentColor = self.hoverColor
    else
        self.currentColor = self.backgroundColor
    end

    -- 处理拖动
    if self.isDragging then
        self.x = mx - self.dragOffsetX
        self.y = my - self.dragOffsetY
    end
end

function Node:setHighlight(highlighted)
    self.isHighlighted = highlighted
end

function Node:draw()
    -- 绘制背景
    love.graphics.setColor(self.currentColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- 如果鼠标悬停或节点被高亮，绘制边框
    if self.isHovered or self.isHighlighted then
        love.graphics.setColor(self.isHighlighted and self.highlightColor or self.borderColor)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end
    
    -- 绘制文字
    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    love.graphics.print(self.text, 
        self.x + (self.width - textWidth) / 2,
        self.y + (self.height - textHeight) / 2)
end

function Node:mousepressed(x, y, button)
    if button == 1 and self.isHovered then
        self.isDragging = true
        self.dragOffsetX = x - self.x
        self.dragOffsetY = y - self.y
        return true
    end
    return false
end

function Node:mousereleased(x, y, button)
    if button == 1 then
        self.isDragging = false
    end
end

return Node 