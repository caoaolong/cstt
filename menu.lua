local Slab = require 'Slab'

local Menu = {}
Menu.__index = Menu

function Menu.new(grid)
    local self = setmetatable({}, Menu)
    self.grid = grid
    return self
end

function Menu:update()
    -- 创建主菜单栏
    if Slab.BeginMainMenuBar() then
        self:viewMenu()
        Slab.EndMainMenuBar()
    end
end

function Menu:viewMenu()
    -- 视图菜单
    if Slab.BeginMenu("视图") then
        -- 显示/隐藏网格选项
        if Slab.MenuItemChecked("显示网格", self.grid:isVisible()) then
            self.grid:setVisible(not self.grid:isVisible())
        end
        Slab.EndMenu()
    end
end

return Menu 