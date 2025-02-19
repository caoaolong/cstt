Slab = require("Slab")
cursor = require("entity.cursor")
local colors = {
    xD80073 = {.84, 0, .44}, 
    xED007E = {.92, 0, .49},
    xFFFFFF = {1.0, 1.0, 1.0}
}

node = {
    -- 形状和标签
    shape = "rect", label = "",
    --节点规则化坐标
    ox = 0, oy = 0,
    -- 节点当前坐标
    cx = 0, cy = 0,
    -- 节点文本坐标和宽高
    tx = 0, ty = 0, tw = 0, th = 0,
    -- 宽高尺寸
    w = 0, h = 0,
    -- 边距
    paddingX = 20, paddingY = 10,
    -- 颜色
    colors = {
        bg = colors.xD80073, fg = colors.xFFFFFF, line = colors.xFFFFFF
    },
    -- 是否显示边框
    border = false,
    -- 是否可以拖放
    draggable = true,
    -- 状态: created
    state = "created",
    -- 弹出菜单
    menu = {
        { ID = "Reset", Label = "重置" },
        { ID = "Separator" },
        { ID = "Top", Label = "前置" },
        { ID = "Bottom", Label = "后置" }
    },
    -- 是否显示菜单
    showMenu = false
}
node.__index = node

-- shape: rect, circle
function node:new(shape, label, ox, oy)
    local font = love.graphics.getFont()
    local w, h = love.graphics.getDimensions()
    local tw, th = font:getWidth(label), font:getHeight(label)
    nw, nh = tw + node.paddingX * 2, th + node.paddingY * 2
    if ox == nil or oy == nil then
        tx, ty = (w - tw) / 2, (h - th) / 2
        ox, oy = (w - nw) / 2, (h - nh) / 2
    else
        tx, ty = ox + node.paddingX, oy + node.paddingY
    end
    local object = setmetatable({
        shape = shape, label = label,
        tw = tw, th = th, w = nw, h = nh, tx = tx, ty = ty, ox = ox, oy = oy,
        cx = ox, cy = oy
    }, node)

    return object
end

function node:action(id)
    if id == "Reset" then
        local font = love.graphics.getFont()
        local w, h = love.graphics.getDimensions()
        self.tw, self.th = font:getWidth(self.label), font:getHeight(self.label)
        self.w, self.h = self.tw + self.paddingX * 2, self.th + self.paddingY * 2
        self.tx, self.ty = (w - self.tw) / 2, (h - self.th) / 2
        self.ox, self.oy = (w - self.w) / 2, (h - self.h) / 2
        self.state = "created"
    elseif id == "Top" then
        cursor.putTop(self)
    elseif id == "Bottom" then
        cursor.putBottom(self)
    end
end

function node:setColor(type, value)
    self.colors[type] = value
end

function node:color(type)
    local color = self.colors[type]
    color[4] = color[4] or 1.0
    return color[1], color[2], color[3], color[4]
end

function node:draw(w, h, font)
    if self.state == "entered" then
        self:stateEntered(w, h, font)
    elseif self.state == "dragging" then
        self:stateDragging(w, h, font)
    else
        self:stateCreated(w, h, font)
    end
    if self.shape == "rect" then
        love.graphics.setColor(self:color("bg"))
        love.graphics.rectangle("fill", self.cx, self.cy, self.w, self.h)
        love.graphics.setColor(self:color("fg"))
        love.graphics.print(self.label, self.tx, self.ty)
        if self.border then
            love.graphics.setColor(self:color("line"))
            love.graphics.rectangle("line", self.cx, self.cy, self.w, self.h)
        end
    end
    if self.showMenu then
        if Slab.BeginContextMenuWindow() then
            for index, value in ipairs(self.menu) do
                if value.ID == "Separator" then
                    Slab.Separator()
                else
                    if Slab.MenuItem(value.Label) then
                        self:action(value.ID)
                    end
                end
            end
            Slab.EndContextMenu()
        end
    end
end

function node:stateCreated(w, h, font)
    self:setColor("bg", colors.xD80073)
    self.border = false
    self.cx, self.cy = self.ox, self.oy
end

function node:stateEntered(w, h, font)
    self:setColor("bg", colors.xD80073)
    self.border = true
    self.cx, self.cy = self.ox, self.oy
end

function node:stateDragging(w, h, font)
    self:setColor("bg", colors.xED007E)
end

function node:mousemoved(x, y, dx, dy, istouch)
    if cursor.picked ~= nil then
        return
    end
    if x >= self.cx and x <= self.cx + self.w and y >= self.cy and y <= self.cy + self.h then
        cursor.handOn(self)
    else
        cursor.handOff(self)
    end
end

function node:mousepressed(x, y, button, istouch, presses)
    if cursor.picked ~= nil then
        return
    end
    if self.state == "entered" and button == 1 then
        cursor.pickUp(self)
        return
    end
    if self.state == "entered" and button == 2 then
        self.showMenu = true
    end
end

function node:mousereleased(x, y, button, istouch, presses)
    if self.state == "dragging" then
        cursor.putDown()
        if self.draggable then
            self.ox, self.oy = self.cx, self.cy
        end
    end
end

return node