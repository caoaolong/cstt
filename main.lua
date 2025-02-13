Slab = require("Slab")

function love.load(args)
	Slab.Initialize(args)
	Slab.DisableDocks({"Left", "Right", "Bottom"})
	local font = love.graphics.newFont("assets/Deng.ttf", 16)
	local Style = Slab.GetStyle()
	Style.API.PushFont(font)
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
    love.graphics.clear( .1, .1, .1 )
    Slab.Draw()
end