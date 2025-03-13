local Slab = require 'Slab'

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
    
    -- 调整尺寸相关的状态
    self.resizeArea = 5  -- 边框感应区域宽度
    self.isResizing = false  -- 是否正在调整尺寸
    self.resizeEdge = nil   -- 当前调整的边缘
    self.minWidth = 50      -- 最小宽度
    self.minHeight = 50     -- 最小高度

    -- 形状相关
    self.shape = "rectangle"  -- 默认为矩形，可选值：rectangle, circle, ellipse
    self.contextMenuShow = false  -- 控制右键菜单的显示
    self.menuX = 0  -- 添加菜单X坐标
    self.menuY = 0  -- 添加菜单Y坐标
    return self
end

function Node:update(mx, my)
    -- 如果正在调整尺寸
    if self.isResizing then
        self:handleResize(mx, my)
        return
    end

    -- 检测鼠标是否在调整区域内
    local edge = self:getResizeEdge(mx, my)
    if edge then
        -- 设置对应的鼠标样式
        if edge == "right" or edge == "left" then
            love.mouse.setCursor(love.mouse.getSystemCursor("sizewe"))
        elseif edge == "bottom" or edge == "top" then
            love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
        elseif edge == "bottomright" or edge == "topleft" then
            love.mouse.setCursor(love.mouse.getSystemCursor("sizenwse"))
        elseif edge == "bottomleft" or edge == "topright" then
            love.mouse.setCursor(love.mouse.getSystemCursor("sizenesw"))
        end
    else
        -- 恢复默认鼠标样式
        love.mouse.setCursor()
    end

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

function Node:getResizeEdge(mx, my)
    local near = function(a, b) return math.abs(a - b) <= self.resizeArea end
    
    -- 检查是否在边框区域内
    if mx < self.x - self.resizeArea or mx > self.x + self.width + self.resizeArea or
       my < self.y - self.resizeArea or my > self.y + self.height + self.resizeArea then
        return nil
    end

    if self.shape == "rectangle" then
        -- 检查四个角
        if near(mx, self.x) and near(my, self.y) then return "topleft" end
        if near(mx, self.x + self.width) and near(my, self.y) then return "topright" end
        if near(mx, self.x) and near(my, self.y + self.height) then return "bottomleft" end
        if near(mx, self.x + self.width) and near(my, self.y + self.height) then return "bottomright" end

        -- 检查四条边
        if near(mx, self.x) then return "left" end
        if near(mx, self.x + self.width) then return "right" end
        if near(my, self.y) then return "top" end
        if near(my, self.y + self.height) then return "bottom" end
    elseif self.shape == "circle" or self.shape == "ellipse" then
        local centerX = self.x + self.width / 2
        local centerY = self.y + self.height / 2
        
        -- 计算鼠标到中心的角度
        local angle = math.atan2(my - centerY, mx - centerX)
        
        -- 检查是否在边缘附近
        if self.shape == "circle" then
            local radius = math.min(self.width, self.height) / 2
            local distToCenter = math.sqrt((mx - centerX)^2 + (my - centerY)^2)
            if math.abs(distToCenter - radius) <= self.resizeArea then
                -- 根据角度返回合适的调整方向
                if angle >= -math.pi/4 and angle < math.pi/4 then return "right"
                elseif angle >= math.pi/4 and angle < 3*math.pi/4 then return "bottom"
                elseif angle >= -3*math.pi/4 and angle < -math.pi/4 then return "top"
                else return "left" end
            end
        else -- ellipse
            -- 计算椭圆上对应角度的点
            local px = centerX + (self.width/2) * math.cos(angle)
            local py = centerY + (self.height/2) * math.sin(angle)
            local distToEdge = math.sqrt((mx - px)^2 + (my - py)^2)
            
            if distToEdge <= self.resizeArea then
                -- 根据角度返回合适的调整方向
                if angle >= -math.pi/4 and angle < math.pi/4 then return "right"
                elseif angle >= math.pi/4 and angle < 3*math.pi/4 then return "bottom"
                elseif angle >= -3*math.pi/4 and angle < -math.pi/4 then return "top"
                else return "left" end
            end
        end
    end

    return nil
end

function Node:handleResize(mx, my)
    local newX, newY = self.x, self.y
    local newWidth, newHeight = self.width, self.height
    local centerX = self.x + self.width / 2
    local centerY = self.y + self.height / 2

    if self.shape == "circle" then
        -- 计算鼠标到圆心的距离作为新半径
        local radius = math.sqrt((mx - centerX)^2 + (my - centerY)^2)
        radius = math.max(self.minWidth / 2, radius)  -- 确保不小于最小尺寸
        newWidth = radius * 2
        newHeight = radius * 2
        -- 保持圆心不变，更新左上角坐标
        newX = centerX - radius
        newY = centerY - radius
    else
        -- 原有的矩形和椭圆的调整逻辑
        if self.resizeEdge:find("right") then
            newWidth = math.max(self.minWidth, mx - self.x)
        elseif self.resizeEdge:find("left") then
            local right = self.x + self.width
            newX = math.min(mx, right - self.minWidth)
            newWidth = right - newX
        end

        if self.resizeEdge:find("bottom") then
            newHeight = math.max(self.minHeight, my - self.y)
        elseif self.resizeEdge:find("top") then
            local bottom = self.y + self.height
            newY = math.min(my, bottom - self.minHeight)
            newHeight = bottom - newY
        end
    end

    self.x, self.y = newX, newY
    self.width, self.height = newWidth, newHeight
end

function Node:setHighlight(highlighted)
    self.isHighlighted = highlighted
end

function Node:draw()
    -- 绘制背景
    love.graphics.setColor(self.currentColor)
    
    -- 根据不同形状绘制
    if self.shape == "rectangle" then
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        -- 如果鼠标悬停或节点被高亮，绘制边框
        if self.isHovered or self.isHighlighted then
            love.graphics.setColor(self.isHighlighted and self.highlightColor or self.borderColor)
            love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        end
    elseif self.shape == "circle" then
        local radius = math.min(self.width, self.height) / 2
        local centerX = self.x + self.width / 2
        local centerY = self.y + self.height / 2
        love.graphics.circle("fill", centerX, centerY, radius)
        -- 如果鼠标悬停或节点被高亮，绘制边框
        if self.isHovered or self.isHighlighted then
            love.graphics.setColor(self.isHighlighted and self.highlightColor or self.borderColor)
            love.graphics.circle("line", centerX, centerY, radius)
        end
    elseif self.shape == "ellipse" then
        local centerX = self.x + self.width / 2
        local centerY = self.y + self.height / 2
        love.graphics.ellipse("fill", centerX, centerY, self.width / 2, self.height / 2)
        -- 如果鼠标悬停或节点被高亮，绘制边框
        if self.isHovered or self.isHighlighted then
            love.graphics.setColor(self.isHighlighted and self.highlightColor or self.borderColor)
            love.graphics.ellipse("line", centerX, centerY, self.width / 2, self.height / 2)
        end
    end
    
    -- 绘制文字
    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    love.graphics.print(self.text, 
        self.x + (self.width - textWidth) / 2,
        self.y + (self.height - textHeight) / 2)

    -- 显示右键菜单
    if self.contextMenuShow then
        self:showContextMenu()
    end
end

function Node:showContextMenu()
    Slab.BeginWindow("NodeContextMenu", {
        X = self.menuX,
        Y = self.menuY,
        W = 120,
        H = 100,
        NoOutline = true,
        AutoSizeWindow = true,
        AllowMove = false
    })

    if Slab.BeginMenu("形状设置") then
        if Slab.MenuItem("矩形", {Selected = self.shape == "rectangle"}) then
            self.shape = "rectangle"
            self.contextMenuShow = false
        end
        if Slab.MenuItem("圆形", {Selected = self.shape == "circle"}) then
            self.shape = "circle"
            self.contextMenuShow = false
        end
        if Slab.MenuItem("椭圆", {Selected = self.shape == "ellipse"}) then
            self.shape = "ellipse"
            self.contextMenuShow = false
        end
        Slab.EndMenu()
    end

    Slab.EndWindow()
end

function Node:mousepressed(x, y, button)
    if button == 1 then
        local edge = self:getResizeEdge(x, y)
        if edge then
            self.isResizing = true
            self.resizeEdge = edge
            return true
        elseif self.isHovered then
            self.isDragging = true
            self.dragOffsetX = x - self.x
            self.dragOffsetY = y - self.y
            return true
        end
    elseif button == 2 and self.isHovered then  -- 右键点击
        self.contextMenuShow = true
        self.menuX = x  -- 记录菜单弹出位置
        self.menuY = y
        return true
    end
    return false
end

function Node:mousereleased(x, y, button)
    if button == 1 then
        self.isDragging = false
        self.isResizing = false
        self.resizeEdge = nil
        love.mouse.setCursor()  -- 恢复默认鼠标样式
    elseif button == 2 and not self.isHovered then
        self.contextMenuShow = false
    end
end

return Node 