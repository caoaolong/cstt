Slab = require("Slab")
node = require("entity.node")

local nodes = {}

function love.load(args)
	Slab.Initialize(args)
	Slab.DisableDocks({"Left", "Right", "Bottom"})
	local font = love.graphics.newFont("assets/Deng.ttf", 16)
	local Style = Slab.GetStyle()
	Style.API.PushFont(font)

	table.insert(nodes, node:new("rect", "Node"))
end

local windows = {
	{ Title = "时间轴", Show = false, ID = "timeline" },
	{ Title = "大纲", Show = false, ID = "outline" }
}

local uiMenu = require("ui.menu")
local uiWindow = require("ui.window")
function love.update( dt )
	Slab.Update(dt)
	uiMenu.draw(windows)
	uiWindow.draw(windows)
end

function love.draw()
    love.graphics.clear( .16, .16, .16 )
	-- 绘制图形
	local w, h = love.graphics.getDimensions()
	local font = love.graphics.getFont()
	for index, value in ipairs(nodes) do
		value:draw(w, h, font)
	end
	-- 绘制界面
    Slab.Draw()
end

function love.mousemoved( x, y, dx, dy, istouch )
	for index, value in ipairs(nodes) do
		value:mousemoved(x, y, dx, dy, istouch)
	end
end