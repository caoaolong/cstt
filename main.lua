Slab = require("Slab")
node = require("entity.node")
cursor = require("entity.cursor")

local nodes = {}

local uiMenu = require("ui.menu")
local uiWindow = require("ui.window")
local uiMesh = require("ui.mesh")

function love.load(args)
	Slab.Initialize(args)
	Slab.DisableDocks({"Left", "Right", "Bottom"})
	local font = love.graphics.newFont("assets/Deng.ttf", 16)
	local Style = Slab.GetStyle()
	Style.API.PushFont(font)

	love.graphics.setFont(font)
	table.insert(nodes, node:new("rect", "Node1", 0, 0))
	table.insert(nodes, node:new("rect", "Node2", 300, 400))

	uiMesh.init()
	cursor.load(nodes)
end

local windows = {
	{ Title = "时间轴", Show = false, ID = "timeline" },
	{ Title = "大纲", Show = false, ID = "outline" }
}

local components = {
	{ Title = "网格", Comp = uiMesh }
}

function love.update( dt )
	Slab.Update(dt)
	uiMenu.draw(windows, components)
	uiWindow.draw(windows)
end

function love.draw()
    love.graphics.clear( .16, .16, .16 )
	-- 绘制网格
	uiMesh.draw()
	-- 视图操作
	love.graphics.translate(cursor.camera())
	love.graphics.scale(cursor.zoom())
	-- 绘制图形
	local w, h = love.graphics.getDimensions()
	local font = love.graphics.getFont()
	for index, value in ipairs(nodes) do
		value:draw(w, h, font)
	end
	-- 绘制界面
    Slab.Draw()
end

function love.keypressed( key, scancode, isrepeat )
    if key == "lctrl" then
		cursor.handing = true
	elseif key == "r" then
		cursor.reset()
	end
end

function love.keyreleased( key, scancode, isrepeat )
    if key == "lctrl" then
		cursor.handing = false
	end
end

function love.wheelmoved(x, y)
    if cursor.handing then
		cursor.scaleCamera(x, y)
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	if cursor.state == "pressed" then
		cursor.moveCamera(dx, dy, mesh)
	end

	local logx, logy = love.graphics.inverseTransformPoint(x, y)
	cursor.mousemoved(logx, logy, dx, dy, istouch)

	for index, value in ipairs(nodes) do
		value:mousemoved(logx, logy, dx, dy, istouch)
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 and cursor.handing then
		cursor.state = "pressed"
	end
	
	for index, value in ipairs(nodes) do
		value:mousepressed(x, y, button, istouch, presses)
	end
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then
		cursor.state = "normal"
	end
	
	for index, value in ipairs(nodes) do
		value:mousereleased(x, y, button, istouch, presses)
	end
end