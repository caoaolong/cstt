local colors = {
    xD80073 = {.84, 0, .44}, 
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
    -- 状态: created
    state = "created"
}
node.__index = node

-- shape: rect, circle
function node:new(shape, label)
    local object = setmetatable({
        shape = shape, label = label
    }, node)
    return object
end

function node:color(type)
    local color = self.colors[type]
    color[4] = color[4] or 1.0
    return color[1], color[2], color[3], color[4]
end

function node:draw(w, h, font)
    self:drawCreated(w, h, font)
    if self.state == "entered" then
        self:drawEntered(w, h, font)
    end
end

function node:drawCreated(w, h, font)
    self.tw, self.th = font:getWidth(self.label), font:getHeight(self.label)
    self.w, self.h = self.tw + self.paddingX * 2, self.th + self.paddingY * 2
    self.tx, self.ty = (w - self.tw) / 2, (h - self.th) / 2
    self.ox, self.oy = (w - self.w) / 2, (h - self.h) / 2
    self.cx, self.cy = self.ox, self.oy
    if self.shape == "rect" then
        love.graphics.setColor(self:color("bg"))
        love.graphics.rectangle("fill", self.ox, self.oy, self.w, self.h)
        love.graphics.setColor(self:color("fg"))
        love.graphics.print(self.label, self.tx, self.ty)
    end
end

function node:drawEntered(w, h, font)
    love.graphics.setColor(self:color("line"))
    love.graphics.rectangle("line", self.cx, self.cy, self.w, self.h)
end

function node:mousemoved(x, y, dx, dy, istouch)
    if x >= self.cx and x <= self.cx + self.w and y >= self.cy and y <= self.cy + self.h then
        self.state = "entered"
    else
        self.state = "created"
    end
end

return node