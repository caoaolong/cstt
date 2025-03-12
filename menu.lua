local Slab = require 'Slab'
local Node = require 'node'

local Menu = {}
Menu.__index = Menu

function Menu.new(grid)
    local self = setmetatable({}, Menu)
    self.grid = grid
    self.nodes = {}  -- 存储所有节点
    self.nodeCount = 0  -- 节点计数器
    self.selectedNode = nil  -- 当前选中的节点
    return self
end

function Menu:isDraggingNode()
    -- 检查是否有节点正在被拖动
    for _, node in ipairs(self.nodes) do
        if node.isDragging then
            return true
        end
    end
    return false
end

function Menu:update(dt)
    -- 更新所有节点
    local mx, my = love.mouse.getPosition()
    for _, node in ipairs(self.nodes) do
        node:update(mx, my)
    end
end

function Menu:drawGUI()
    -- 绘制主菜单栏
    if Slab.BeginMainMenuBar() then
        -- 操作菜单
        if Slab.BeginMenu("操作") then
            if Slab.MenuItem("创建节点") then
                self:createNode()
            end
            Slab.EndMenu()
        end
        
        -- 视图菜单
        if Slab.BeginMenu("视图") then
            if Slab.MenuItemChecked("显示网格", self.grid:isVisible()) then
                self.grid:setVisible(not self.grid:isVisible())
            end
            Slab.EndMenu()
        end
        
        Slab.EndMainMenuBar()
    end
    
    -- 显示节点列表窗口
    self:showNodeListWindow()
end

function Menu:showNodeListWindow()
    local windowHeight = love.graphics.getHeight()
    -- 设置窗口选项
    Slab.BeginWindow('节点列表', {
        Title = "节点列表",
        AutoSizeWindow = true,
        AllowResize = true,
        AllowMove = true,
        NoSavedSettings = true,
        StatusBar = true
    })

    -- 显示节点总数
    Slab.Text("节点数量: " .. #self.nodes)
    Slab.Separator()

    -- 创建一个滚动区域来容纳所有节点
    Slab.BeginListBox('NodeList', {
        H = windowHeight - 80,  -- 减去菜单栏、标题栏和节点总数的高度
        Clear = true
    })
    -- 显示节点列表
    for i, node in ipairs(self.nodes) do
        -- 开始一个新的列表项
        Slab.BeginListBoxItem('node_' .. i, {
            Selected = (self.selectedNode == node)
        })
        
        -- 节点标题和选择框
        if Slab.CheckBox(self.selectedNode == node, "节点 #" .. i) then
            if self.selectedNode == node then
                self.selectedNode = nil  -- 取消选择
            else
                self.selectedNode = node  -- 选择节点
            end
        end
        Slab.EndListBoxItem()
    end
    Slab.EndListBox()
    Slab.EndWindow()
end

function Menu:deleteNode(index)
    if self.selectedNode == self.nodes[index] then
        self.selectedNode = nil
    end
    table.remove(self.nodes, index)
end

function Menu:createNode()
    -- 在屏幕中央创建节点
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local node = Node.new(
        (windowWidth - 100) / 2,  -- x坐标居中
        (windowHeight - 100) / 2   -- y坐标居中
    )
    table.insert(self.nodes, node)
end

function Menu:draw()
    -- 绘制所有节点
    for _, node in ipairs(self.nodes) do
        -- 如果节点被选中，绘制高亮边框
        if node == self.selectedNode then
            node:setHighlight(true)
        else
            node:setHighlight(false)
        end
        node:draw()
    end
end

function Menu:mousepressed(x, y, button)
    -- 处理节点的鼠标按下事件
    for _, node in ipairs(self.nodes) do
        if node:mousepressed(x, y, button) then
            break  -- 如果某个节点处理了事件，就停止遍历
        end
    end
end

function Menu:mousereleased(x, y, button)
    -- 处理节点的鼠标释放事件
    for _, node in ipairs(self.nodes) do
        node:mousereleased(x, y, button)
    end
end

return Menu 