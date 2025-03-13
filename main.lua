-- 引入必要的库和类
local Slab = require 'Slab'
local Grid = require 'grid'
local Menu = require 'menu'

-- 初始化变量
local grid = nil
local menu = nil

function love.load()
    -- 设置背景色
    love.graphics.setBackgroundColor(.1, .1, .1)
    -- 加载字体
    local font = love.graphics.newFont("assets/Deng.ttf", 16)
    -- 初始化Slab并设置字体
    Slab.Initialize({
        DisplayFlags = {
            NoTitleBar = false,
            NoResize = true,
            NoScrollbar = true,
            NoCollapse = true
        }
    })
    Slab.PushFont(font)
    
    -- 创建网格实例
    grid = Grid.new(20)
    -- 创建菜单实例
    menu = Menu.new(grid)
end

-- 处理窗口大小改变事件
function love.resize(w, h)
    -- 通知菜单窗口大小改变
    if menu then
        menu:onResize(w, h)
    end
end

function love.update(dt)
    -- 更新Slab
    Slab.Update(dt)
    -- 更新菜单中的节点
    menu:update(dt)
end

function love.wheelmoved(x, y)
    -- 只有在按住左Ctrl键时才允许缩放网格
    if love.keyboard.isDown('lctrl') then
        grid:zoom(y)
    end
end

function love.draw()
    -- 绘制网格
    grid:draw()
    -- 绘制节点
    menu:draw()
    -- 绘制GUI
    menu:drawGUI()
    -- 绘制Slab
    Slab.Draw()
end

function love.mousepressed(x, y, button)
    menu:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    menu:mousereleased(x, y, button)
end

-- 添加鼠标拖动功能
function love.mousemoved(x, y, dx, dy, istouch)
    -- 检查是否有节点正在拖动
    if menu:isDraggingNode() then
        return  -- 如果有节点在拖动，不处理网格平移
    end
    
    -- 只有在按住左Ctrl键和鼠标左键时才允许平移网格
    if love.keyboard.isDown('lctrl') and love.mouse.isDown(1) then
        grid:pan(dx, dy)
    end
end