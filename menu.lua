local Slab = require 'Slab'
local Node = require 'node'

local Menu = {}
Menu.__index = Menu

function Menu.new(grid)
    local self = setmetatable({}, Menu)
    self.grid = grid
    self.nodes = {} -- 存储所有节点
    self.nodeCount = 0 -- 节点计数器
    self.selectedNode = nil -- 当前选中的节点
    self.windowWidth = love.graphics.getWidth()
    self.windowHeight = love.graphics.getHeight()
    self.listWindowWidth = 200 -- 列表窗口的默认宽度
    self.showNodeList = true -- 控制节点列表窗口的显示状态
    return self
end

function Menu:onResize(w, h)
    self.windowWidth = w
    self.windowHeight = h
    -- 如果有选中的节点，确保它不会超出新的窗口边界
    if self.selectedNode then
        local node = self.selectedNode
        node.x = math.min(math.max(0, node.x), w - node.width)
        node.y = math.min(math.max(0, node.y), h - node.height)
    end
end

function Menu:isDraggingNode()
    -- 检查是否有节点正在被拖动
    for _, node in ipairs(self.nodes) do
        if node.isDragging then return true end
    end
    return false
end

function Menu:update(dt)
    -- 更新所有节点
    local mx, my = love.mouse.getPosition()
    for _, node in ipairs(self.nodes) do node:update(mx, my) end
end

function Menu:drawGUI()
    -- 绘制主菜单栏
    if Slab.BeginMainMenuBar() then
        -- 操作菜单
        if Slab.BeginMenu("操作") then
            if Slab.MenuItem("创建节点") then self:createNode() end
            Slab.EndMenu()
        end

        -- 视图菜单
        if Slab.BeginMenu("视图") then
            if Slab.MenuItemChecked("显示网格", self.grid:isVisible()) then
                self.grid:setVisible(not self.grid:isVisible())
            end
            if Slab.MenuItemChecked("节点列表", self.showNodeList) then
                self.showNodeList = not self.showNodeList
            end
            Slab.EndMenu()
        end

        Slab.EndMainMenuBar()
    end

    -- 显示节点列表窗口
    self:showNodeListWindow()
end

function Menu:showNodeListWindow()
    -- 如果节点列表窗口被设置为隐藏，则直接返回
    if not self.showNodeList then
        return
    end
    
    -- 设置窗口选项
    Slab.BeginWindow('节点列表', {
        Title = "节点列表",
        X = 0,
        Y = 20, -- 留出顶部菜单栏的空间
        W = self.listWindowWidth,
        H = self.windowHeight - 20,
        AutoSizeWindow = true,
        AllowMove = true
    })
    Slab.DisableDocks({'Left', 'Right', 'Bottom'})
    -- 显示节点总数
    Slab.Text("节点数量: " .. #self.nodes)
    Slab.Separator()

    -- 创建一个滚动区域来容纳所有节点
    Slab.BeginListBox('NodeList', {
        H = 200,
        W = 200,
        Clear = true
    })
    -- 显示节点列表
    for i, node in ipairs(self.nodes) do
        -- 开始一个新的列表项
        Slab.BeginListBoxItem('node_' .. i,
                              {Selected = (self.selectedNode == node)})

        -- 节点标题和选择框
        if Slab.CheckBox(self.selectedNode == node, "节点 #" .. i) then
            if self.selectedNode == node then
                self.selectedNode = nil -- 取消选择
            else
                self.selectedNode = node -- 选择节点
            end
        end

        -- -- 如果节点被选中，显示更多信息
        -- if self.selectedNode == node then
        --     Slab.Indent()
        --     Slab.Text(string.format("位置: (%.0f, %.0f)", node.x, node.y))
        --     if Slab.Button("删除节点") then
        --         self:deleteNode(i)
        --     end
        --     Slab.Unindent()
        -- end

        Slab.EndListBoxItem()
    end
    Slab.EndListBox()

    -- 获取窗口的实际大小（以防用户调整了大小）
    local windowW = love.graphics.getWidth()
    if windowW ~= self.listWindowWidth then self.listWindowWidth = windowW end

    Slab.EndWindow()
end

function Menu:deleteNode(index)
    if self.selectedNode == self.nodes[index] then self.selectedNode = nil end
    table.remove(self.nodes, index)
end

function Menu:createNode()
    -- 在屏幕中央创建节点
    local node =
        Node.new((self.windowWidth - 100) / 2, -- x坐标居中（考虑左侧窗口）
                 (self.windowHeight - 100) / 2 -- y坐标居中
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
            break -- 如果某个节点处理了事件，就停止遍历
        end
    end
end

function Menu:mousereleased(x, y, button)
    -- 处理节点的鼠标释放事件
    for _, node in ipairs(self.nodes) do node:mousereleased(x, y, button) end
end

return Menu
