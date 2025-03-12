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
    Slab.Initialize()
    Slab.PushFont(font)
    
    -- 创建网格实例
    grid = Grid.new(20)
    -- 创建菜单实例
    menu = Menu.new(grid)
end

function love.update(dt)
    -- 更新Slab
    Slab.Update(dt)
    -- 更新菜单
    menu:update()
end

function love.wheelmoved(x, y)
    grid:zoom(y)
end

function love.draw()
    -- 绘制网格
    grid:draw()

    -- 绘制Slab GUI
    Slab.Draw()
end

-- 添加鼠标拖动功能
function love.mousemoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(1) then  -- 按住鼠标左键拖动
        grid:pan(dx, dy)
    end
end