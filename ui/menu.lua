cursor = require("entity.cursor")
menu = {}

local function projectMenu()
    if Slab.BeginMenu("项目") then
        if Slab.BeginMenu("新建") then
            if Slab.MenuItem("文件") then
                -- Create a new file.
            end

            if Slab.MenuItem("工程") then
                -- Create a new project.
            end

            Slab.EndMenu()
        end
        Slab.MenuItem("打开")
        Slab.MenuItem("保存")

        Slab.Separator()

        if Slab.MenuItem("退出") then
            love.event.quit()
        end

        Slab.EndMenu()
    end
end

local function viewMenu(windows, components)
    if Slab.BeginMenu("视图") then
        for index, value in ipairs(windows) do
            if value.Show then
                if Slab.MenuItem("√ " .. value.Title) then
                    value.Show = false
                end
            else
                if Slab.MenuItem("  " .. value.Title) then
                    value.Show = true
                end
            end
        end
        Slab.Separator()
        for index, value in ipairs(components) do
            if value.Comp.show then
                if Slab.MenuItem("√ " .. value.Title) then
                    value.Comp.show = false
                end
            else
                if Slab.MenuItem("  " .. value.Title) then
                    value.Comp.show = true
                end
            end
        end
        Slab.Separator()
        if Slab.MenuItem("重置视图") then
            cursor.reset()
        end
        Slab.EndMenu()
    end
end

local function componentMenu()
    if Slab.BeginMenu("组件") then
        if Slab.BeginMenu("数组") then
            if Slab.MenuItem("一维") then
                -- Create a new file.
            end

            if Slab.MenuItem("二维") then
                -- Create a new project.
            end

            Slab.EndMenu()
        end
        Slab.MenuItem("链表")
        Slab.Separator()
        Slab.MenuItem("地图")
        Slab.EndMenu()
    end
end

function menu.draw(windows, components)
    if Slab.BeginMainMenuBar() then
		projectMenu()
		viewMenu(windows, components)
        componentMenu()
		Slab.EndMainMenuBar()
	end
end

return menu