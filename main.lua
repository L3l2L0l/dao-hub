-- 自动生成占屏幕 50% 的窗口，带顶部彩虹标题、左侧功能栏 + 右侧 ESP 功能面板
-- 放在 StarterPlayer > StarterPlayerScripts 下的 LocalScript 中

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 防止重复生成
local old = playerGui:FindFirstChild("ResizableUISystem")
if old then
    old:Destroy()
end

-- ========== 自动识别设备 ==========
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPC = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled
local deviceText = "未知设备"

if isPC then
    deviceText = "PC"
elseif isMobile then
    deviceText = "手机/平板"
else
    deviceText = UserInputService.TouchEnabled and "触摸设备" or "键盘设备"
end

-- ========== 创建 ScreenGui ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ResizableUISystem"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ========== 主窗口 ==========
local main = Instance.new("Frame")
main.Name = "MainWindow"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromScale(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(80, 80, 95)
mainStroke.Thickness = 1
mainStroke.Parent = main

-- ========== 顶部标题栏（新增） ==========
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundTransparency = 1
topBar.Parent = main

-- 彩虹字标题
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Text = "dao hub"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 28
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.Parent = topBar

-- 彩虹渐变
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),     -- 红
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 165, 0)),  -- 橙
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),  -- 黄
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 0)),    -- 绿
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 127, 255)),  -- 蓝
    ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 128))     -- 紫
})
gradient.Parent = titleLabel

-- 让彩虹缓缓流动
task.spawn(function()
    while titleLabel.Parent do
        task.wait(0.05)
        gradient.Rotation = (gradient.Rotation + 2) % 360
    end
end)

-- 标题下方的分割线
local titleDivider = Instance.new("Frame")
titleDivider.Name = "TitleDivider"
titleDivider.Size = UDim2.new(1, -20, 0, 2)
titleDivider.Position = UDim2.new(0, 10, 0, 48)
titleDivider.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
titleDivider.BorderSizePixel = 0
titleDivider.Parent = topBar

-- ========== 右上角“调节UI”按钮 ==========
local resizeButton = Instance.new("TextButton")
resizeButton.Name = "ResizeUI"
resizeButton.Text = "调节UI"
resizeButton.TextSize = 14
resizeButton.Font = Enum.Font.GothamBold
resizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resizeButton.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
resizeButton.BorderSizePixel = 0
resizeButton.AutoButtonColor = false
resizeButton.Size = UDim2.new(0, 70, 0, 32)
resizeButton.Position = UDim2.new(1, -80, 0, 9)
resizeButton.Parent = topBar

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = resizeButton

-- ========== 左侧新功能区（下移避开标题） ==========
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.BackgroundTransparency = 1
leftPanel.Size = UDim2.new(0, 100, 1, -50) -- 高度减去 50
leftPanel.Position = UDim2.new(0, 0, 0, 50) -- 从顶部 50 像素处开始
leftPanel.Parent = main

-- 左侧功能区右侧的贯穿蓝线（分割线）
local blueLine = Instance.new("Frame")
blueLine.Name = "BlueDividerLine"
blueLine.Size = UDim2.new(0, 2, 1, 0)
blueLine.Position = UDim2.new(1, -2, 0, 0)
blueLine.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
blueLine.BorderSizePixel = 0
blueLine.Parent = leftPanel

-- 左侧列表布局
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Parent = leftPanel

-- ========== 左侧功能按钮：ESP ==========
local espButton = Instance.new("TextButton")
espButton.Name = "ESPButton"
espButton.Text = "ESP"
espButton.TextSize = 14
espButton.Font = Enum.Font.GothamBold
espButton.TextColor3 = Color3.fromRGB(200, 200, 200)
espButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
espButton.BorderSizePixel = 0
espButton.Size = UDim2.new(0, 80, 0, 36)
espButton.Parent = leftPanel

local espBtnCorner = Instance.new("UICorner")
espBtnCorner.CornerRadius = UDim.new(0, 6)
espBtnCorner.Parent = espButton

-- ========== 右侧内容区域（下移避开标题） ==========
local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.Position = UDim2.new(0, 110, 0, 110) -- 之前是 60，现在下移 50
content.Size = UDim2.new(1, -120, 1, -120) -- 高度减去 120
content.Parent = main

-- 默认页面
local defaultPage = Instance.new("Frame")
defaultPage.Name = "DefaultPage"
defaultPage.BackgroundTransparency = 1
defaultPage.Size = UDim2.new(1, 0, 1, 0)
defaultPage.Parent = content

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Text = "窗口内容"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Size = UDim2.new(1, 0, 0, 36)
title.Parent = defaultPage

-- ========== ESP 页面 ==========
local espPage = Instance.new("Frame")
espPage.Name = "ESPPage"
espPage.BackgroundTransparency = 1
espPage.Size = UDim2.new(1, 0, 1, 0)
espPage.Visible = false -- 默认隐藏
espPage.Parent = content

local espTitle = Instance.new("TextLabel")
espTitle.Text = "ESP 功能"
espTitle.BackgroundTransparency = 1
espTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
espTitle.TextSize = 22
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Size = UDim2.new(1, 0, 0, 36)
espTitle.Parent = espPage

local espList = Instance.new("Frame")
espList.BackgroundTransparency = 1
espList.Position = UDim2.new(0, 0, 0, 50)
espList.Size = UDim2.new(1, 0, 1, -50)
espList.Parent = espPage

local espLayout = Instance.new("UIListLayout")
espLayout.Padding = UDim.new(0, 12)
espLayout.Parent = espList

-- 状态表
local espState = {
    Highlight = false,
    Name = false,
    Line = false
}

-- 创建 ESP 开关按钮的函数
local function createToggleButton(parent, text, key)
    local btn = Instance.new("TextButton")
    btn.Name = key .. "Toggle"
    btn.Text = text .. "：关"
    btn.TextSize = 16
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 200, 0, 36)
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        espState[key] = not espState[key]
        if espState[key] then
            btn.Text = text .. "：开"
            btn.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
        else
            btn.Text = text .. "：关"
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end
    end)
end

createToggleButton(espList, "高亮显示玩家", "Highlight")
createToggleButton(espList, "显示玩家用户名", "Name")
createToggleButton(espList, "显示距离射线", "Line")

-- 点击左侧 ESP 按钮切换页面
espButton.MouseButton1Click:Connect(function()
    defaultPage.Visible = not defaultPage.Visible
    espPage.Visible = not espPage.Visible
    
    if espPage.Visible then
        espButton.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
        espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        espButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        espButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- ========== 核心 ESP 逻辑 ==========
local espCache = {}

local function cleanupESP()
    for _, data in pairs(espCache) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        if data.Line then data.Line:Destroy() end
        if data.DistanceGui then data.DistanceGui:Destroy() end
    end
    espCache = {}
end

RunService.RenderStepped:Connect(function()
    if not (espState.Highlight or espState.Name or espState.Line) then
        cleanupESP()
        return
    end

    local localPlayer = Players.LocalPlayer
    local localChar = localPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= localPlayer then
            local char = targetPlayer.Character
            local head = char and char:FindFirstChild("Head")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if head and root and humanoid and humanoid.Health > 0 then
                if not espCache[targetPlayer] then
                    espCache[targetPlayer] = {}
                end
                local data = espCache[targetPlayer]

                -- 1. 高亮
                if espState.Highlight then
                    if not data.Highlight or not data.Highlight.Parent then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESP_Highlight"
                        hl.FillColor = Color3.fromRGB(60, 120, 220)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                        data.Highlight = hl
                    end
                else
                    if data.Highlight then
                        data.Highlight:Destroy()
                        data.Highlight = nil
                    end
                end

                -- 2. 用户名
                if espState.Name then
                    if not data.Billboard or not data.Billboard.Parent then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "ESP_Name"
                        bb.Adornee = head
                        bb.Size = UDim2.new(0, 200, 0, 50)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = head
                        
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Name = "NameLabel"
                        textLabel.BackgroundTransparency = 1
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.TextSize = 14
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextStrokeTransparency = 0
                        textLabel.Text = targetPlayer.Name
                        textLabel.Parent = bb
                        
                        data.Billboard = bb
                        data.NameLabel = textLabel
                    end
                    if data.NameLabel then
                        data.NameLabel.Text = targetPlayer.Name
                    end
                else
                    if data.Billboard then
                        data.Billboard:Destroy()
                        data.Billboard = nil
                        data.NameLabel = nil
                    end
                end

                -- 3. 距离
                if espState.Line then
                    if localRoot then
                        local distance = (root.Position - localRoot.Position).Magnitude
                        
                        if not data.Line or not data.Line.Parent then
                            local line = Instance.new("LineHandleAdornment")
                            line.Name = "ESP_Line"
                            line.Adornee = root
                            line.Thickness = 1.5
                            line.Color3 = Color3.fromRGB(60, 120, 220)
                            line.Transparency = 0.5
                            line.ZIndex = 1
                            line.Parent = root
                            data.Line = line
                            
                            local distBb = Instance.new("BillboardGui")
                            distBb.Name = "ESP_Distance"
                            distBb.Adornee = root
                            distBb.Size = UDim2.new(0, 100, 0, 20)
                            distBb.StudsOffset = Vector3.new(0, -2.5, 0)
                            distBb.AlwaysOnTop = true
                            distBb.Parent = root
                            
                            local distLabel = Instance.new("TextLabel")
                            distLabel.BackgroundTransparency = 1
                            distLabel.Size = UDim2.new(1, 0, 1, 0)
                            distLabel.Font = Enum.Font.Gotham
                            distLabel.TextSize = 12
                            distLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
                            distLabel.TextStrokeTransparency = 0
                            distLabel.Text = string.format("%d m", distance)
                            distLabel.Parent = distBb
                            
                            data.DistanceGui = distBb
                            data.DistanceLabel = distLabel
                        end
                        
                        if data.DistanceLabel then
                            data.DistanceLabel.Text = string.format("%d m", distance)
                        end
                    end
                else
                    if data.Line then data.Line:Destroy() data.Line = nil end
                    if data.DistanceGui then data.DistanceGui:Destroy() data.DistanceGui = nil end
                    if data.DistanceLabel then data.DistanceLabel:Destroy() data.DistanceLabel = nil end
                end
            end
        end
    end

    -- 清理离开/死亡的玩家
    for p, data in pairs(espCache) do
        if not p.Parent or not p.Character or not p.Character:FindFirstChild("Humanoid") or p.Character.Humanoid.Health <= 0 then
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
            if data.Line then data.Line:Destroy() end
            if data.DistanceGui then data.DistanceGui:Destroy() end
            espCache[p] = nil
        end
    end
end)

-- ========== 调整大小逻辑 ==========
local resizing = false
local startMouse = Vector2.new()
local startWidth = 0
local startHeight = 0

local MIN_WIDTH = 300
local MIN_HEIGHT = 200
local MAX_WIDTH_RATIO = 0.95
local MAX_HEIGHT_RATIO = 0.95

local function startResize(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        
        resizing = true
        startMouse = Vector2.new(input.Position.X, input.Position.Y)
        startWidth = main.AbsoluteSize.X
        startHeight = main.AbsoluteSize.Y
        
        resizeButton.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    end
end

local function stopResize()
    if resizing then
        resizing = false
        resizeButton.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
    end
end

resizeButton.InputBegan:Connect(startResize)
resizeButton.InputEnded:Connect(stopResize)

UserInputService.InputChanged:Connect(function(input)
    if not resizing then return end
    
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    
    local currentMouse = Vector2.new(input.Position.X, input.Position.Y)
    local delta = currentMouse - startMouse
    
    local screenSize = screenGui.AbsoluteSize
    local maxWidth = screenSize.X * MAX_WIDTH_RATIO
    local maxHeight = screenSize.Y * MAX_HEIGHT_RATIO
    
    local newWidth = math.clamp(startWidth + delta.X, MIN_WIDTH, maxWidth)
    local newHeight = math.clamp(startHeight + delta.Y, MIN_HEIGHT, maxHeight)
    
    main.Size = UDim2.fromOffset(newWidth, newHeight)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        stopResize()
    end
end)

-- ========== 右下角弹窗（5秒后消失） ==========
task.wait() 

local absSize = main.AbsoluteSize

local notification = Instance.new("Frame")
notification.Name = "Notification"
notification.AnchorPoint = Vector2.new(1, 1)
notification.Position = UDim2.new(1, -20, 1, -20)
notification.Size = UDim2.new(0, 260, 0, 80)
notification.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
notification.BackgroundTransparency = 0.1
notification.BorderSizePixel = 0
notification.Parent = screenGui

local notifyCorner = Instance.new("UICorner")
notifyCorner.CornerRadius = UDim.new(0, 8)
notifyCorner.Parent = notification

local notifyStroke = Instance.new("UIStroke")
notifyStroke.Color = Color3.fromRGB(80, 80, 95)
notifyStroke.Thickness = 1
notifyStroke.Parent = notification

local notifyTitle = Instance.new("TextLabel")
notifyTitle.Text = "✅ 加载完成"
notifyTitle.Font = Enum.Font.GothamBold
notifyTitle.TextSize = 16
notifyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
notifyTitle.BackgroundTransparency = 1
notifyTitle.Size = UDim2.new(1, -20, 0, 24)
notifyTitle.Position = UDim2.new(0, 10, 0, 10)
notifyTitle.TextXAlignment = Enum.TextXAlignment.Left
notifyTitle.Parent = notification

local notifyText = Instance.new("TextLabel")
notifyText.Font = Enum.Font.Gotham
notifyText.TextSize = 14
notifyText.TextColor3 = Color3.fromRGB(200, 200, 210)
notifyText.BackgroundTransparency = 1
notifyText.Size = UDim2.new(1, -20, 0, 36)
notifyText.Position = UDim2.new(0, 10, 0, 34)
notifyText.TextXAlignment = Enum.TextXAlignment.Left
notifyText.TextYAlignment = Enum.TextYAlignment.Top
notifyText.TextWrapped = true
notifyText.Text = string.format("设备：%s\n窗口大小：%d x %d", deviceText, absSize.X, absSize.Y)
notifyText.Parent = notification

task.delay(5, function()
    local fadeTime = 0.5
    local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    TweenService:Create(notification, tweenInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(notifyStroke, tweenInfo, {Transparency = 1}):Play()
    TweenService:Create(notifyTitle, tweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(notifyText, tweenInfo, {TextTransparency = 1}):Play()
    
    task.wait(fadeTime)
    notification:Destroy()
end)

print("UI 已加载，设备类型：" .. deviceText)
