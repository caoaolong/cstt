UI2D = require("ui2d")

function love.load()
	UI2D.Init( "love" )
end

function love.keypressed( key, scancode, isrepeat )
	UI2D.KeyPressed( key, isrepeat )
end

function love.textinput( text )
	UI2D.TextInput( text )
end

function love.keyreleased( key, scancode )
	UI2D.KeyReleased()
end

function love.wheelmoved( x, y )
	UI2D.WheelMoved( x, y )
end

function love.update( dt )
	UI2D.InputInfo()
end

local amplitude = 50
local frequency = 0.1

local function drawc( tex, held, hovered, mx, my )
	if held then
		amplitude = (75 * my) / 150
		frequency = (0.2 * mx) / 250
	end

	local col = { 0, 0, 0 }
	if hovered then
		col = { 0.1, 0, 0.2 }
	end

	-- Prepare this custom-widget's canvas
	love.graphics.setCanvas( tex )
	love.graphics.clear( col )
	love.graphics.setColor( 1, 1, 1 )

	local xx = 0
	local yy = 0
	local y = 75

	for i = 1, 250 do
		yy = y + (amplitude * math.sin( frequency * xx ))
		love.graphics.points( xx, yy )
		xx = xx + 1
	end
end

function love.draw()
    love.graphics.clear( .1, .1, .1 )
    local w, h = love.graphics.getDimensions()
    UI2D.Begin("Test Window", 0, 0)
    local tex, clicked, held, released, hovered, mx, my, wheelx, wheely = UI2D.CustomWidget( "widget1", 250, 150 )
    drawc( tex, held, hovered, mx, my )
    UI2D.End()
    UI2D.RenderFrame()
end