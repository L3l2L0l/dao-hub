-- 自动生成占屏幕 50% 的窗口，识别 PC / 手机，并在右下角弹窗提示 5 秒
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
main.Size = UDim2.fromScale(0.5, 0.5) -- 宽高各占屏幕 50%
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

-- ========== 左侧“调节UI”按钮 ==========
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
resizeButton.Position = UDim2.new(0, 10, 0, 10)
resizeButton.Parent = main

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = resizeButton

-- ========== 内容区域（干净，以后放你的功能） ==========
local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.Position = UDim2.new(0, 10, 0, 60)
content.Size = UDim2.new(1, -20, 1, -70)
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

local MIN_WIDTH = 200
local MIN_HEIGHT = 150
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
task.wait() -- 等待一帧，确保窗口尺寸计算完毕

local absSize = main.AbsoluteSize

-- 创建弹窗 Frame
local notification = Instance.new("Frame")
notification.Name = "Notification"
notification.AnchorPoint = Vector2.new(1, 1)
notification.Position = UDim2.new(1, -20, 1, -20) -- 右下角，距离边缘 20 像素
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

-- 弹窗标题
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

-- 弹窗内容
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

-- 5秒后自动消失（带淡出动画）
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
