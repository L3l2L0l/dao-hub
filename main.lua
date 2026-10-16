-- 自动生成占屏幕 50% 的窗口，并识别 PC / 手机
-- 放在 StarterPlayer > StarterPlayerScripts 下的 LocalScript 中
-- 或作为 loadstring 脚本执行

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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

-- ========== 内容区域 ==========
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

local deviceLabel = Instance.new("TextLabel")
deviceLabel.Name = "DeviceLabel"
deviceLabel.BackgroundTransparency = 1
deviceLabel.Text = "当前设备：" .. deviceText
deviceLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
deviceLabel.TextSize = 18
deviceLabel.Font = Enum.Font.Gotham
deviceLabel.TextXAlignment = Enum.TextXAlignment.Left
deviceLabel.Size = UDim2.new(1, 0, 0, 24)
deviceLabel.Position = UDim2.new(0, 0, 0, 40)
deviceLabel.Parent = content

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Name = "SizeLabel"
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "当前大小：加载中..."
sizeLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
sizeLabel.TextSize = 16
sizeLabel.Font = Enum.Font.Gotham
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
sizeLabel.Size = UDim2.new(1, 0, 0, 24)
sizeLabel.Position = UDim2.new(0, 0, 0, 70)
sizeLabel.Parent = content

-- 等待一帧以获取正确的 AbsoluteSize
task.wait()

-- 更新尺寸标签
local function updateSizeLabel()
    local absSize = main.AbsoluteSize
    sizeLabel.Text = string.format("当前大小：%d x %d", absSize.X, absSize.Y)
end
updateSizeLabel()

-- ========== 调整大小逻辑 ==========
local resizing = false
local startMouse = Vector2.new()
local startWidth = 0
local startHeight = 0

-- 最小 / 最大尺寸限制
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
        updateSizeLabel()
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
    updateSizeLabel()
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        stopResize()
    end
end)

-- 窗口大小变化时更新标签
main:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSizeLabel)

print("UI 已加载，设备类型：" .. deviceText)
