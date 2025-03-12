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

function love.update(dt)
    -- 更新Slab（必须在draw中调用）
    Slab.Update(dt)
    -- 更新菜单中的节点
    menu:update(dt)
end

function love.wheelmoved(x, y)
    grid:zoom(y)
end

function love.draw()
    -- 绘制网格
    grid:draw()
    -- 绘制节点
    menu:draw()
    
    -- 绘制GUI
    menu:drawGUI()
    
    -- 绘制Slab（必须在所有GUI操作之后调用）
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
    
    -- 否则处理网格平移
    if love.mouse.isDown(1) then
        grid:pan(dx, dy)
    end
end