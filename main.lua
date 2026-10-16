-- 自动生成占屏幕 50% 的窗口，识别设备，右下角弹窗提示，左侧带功能栏分割线
-- 放在 StarterPlayer > StarterPlayerScripts 下的 LocalScript 中

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
    if UserInputService.TouchEnabled then
        deviceText = "触摸设备"
    elseif UserInputService.KeyboardEnabled then
        deviceText = "键盘设备"
    end
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

-- ========== 右上角“调节UI”按钮（避让左侧功能区） ==========
local resizeButton = Instance.new("TextButton")
resizeButton.Name = "ResizeUI"
resizeButton.Text = "调节UI"
resizeButton.TextSize = 16
resizeButton.Font = Enum.Font.GothamBold
resizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resizeButton.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
resizeButton.BorderSizePixel = 0
resizeButton.AutoButtonColor = false
resizeButton.Size = UDim2.new(0, 80, 0, 40)
resizeButton.Position = UDim2.new(1, -90, 0, 10) -- 移到右上角
resizeButton.Parent = main

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = resizeButton

-- ========== 左侧新功能区 ==========
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.BackgroundTransparency = 1
leftPanel.Size = UDim2.new(0, 100, 1, 0) -- 宽度 100 像素
leftPanel.Position = UDim2.new(0, 0, 0, 0)
leftPanel.Parent = main

-- 左侧功能区右侧的贯穿蓝线（分割线）
local blueLine = Instance.new("Frame")
blueLine.Name = "BlueDividerLine"
blueLine.Size = UDim2.new(0, 2, 1, 0)
blueLine.Position = UDim2.new(1, -2, 0, 0)
blueLine.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
blueLine.BorderSizePixel = 0
blueLine.Parent = leftPanel

-- 在左侧功能区里添加一排蓝色细竖线（作为视觉点缀和占位）
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Parent = leftPanel

for i = 1, 4 do
    local shortLine = Instance.new("Frame")
    shortLine.Name = "DecoLine" .. i
    shortLine.Size = UDim2.new(0, 4, 0, 30) -- 短竖线
    shortLine.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
    shortLine.BackgroundTransparency = 0.2 + (i * 0.15) -- 透明渐变
    shortLine.BorderSizePixel = 0
    shortLine.Parent = leftPanel
end

-- ========== 右侧内容区域 ==========
local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.Position = UDim2.new(0, 110, 0, 60) -- 向右偏移，避让左侧功能区
content.Size = UDim2.new(1, -120, 1, -70)
content.Parent = main

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Text = "窗口内容"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 0)
title.Parent = content

-- ========== 调整大小逻辑 ==========
local resizing = false
local startMouse = Vector2.new()
local startWidth = 0
local startHeight = 0

local MIN_WIDTH = 300 -- 稍微加大最小宽度，以免左侧功能栏被挤压变形
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
