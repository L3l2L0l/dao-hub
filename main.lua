-- 自动生成占屏幕 50% 的窗口，带顶部彩虹标题、左侧功能栏 + ESP、视觉 和 Setting 面板
-- 优化：提高 UI 优先级，可覆盖 Esc 菜单，并解决游戏强制锁定鼠标无法点击的问题
-- 放在 StarterPlayer > StarterPlayerScripts 下的 LocalScript 中，或者直接用执行器 loadstring

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 防止重复生成
local old = playerGui:FindFirstChild("ResizableUISystem")
if old then
    old:Destroy()
end
if gethui then
    local oldHui = gethui():FindFirstChild("ResizableUISystem")
    if oldHui then oldHui:Destroy() end
end
-- 清理可能残留的视觉滤镜
local oldEffect = Lighting:FindFirstChild("Vision_Highlight")
if oldEffect then oldEffect:Destroy() end

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

-- ========== 快捷键状态 ==========
local currentToggleKey = Enum.KeyCode.G

-- ========== 创建 ScreenGui ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ResizableUISystem"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 2147483647 

local parentGui = (gethui and gethui()) or playerGui
screenGui.Parent = parentGui

-- ========== 主窗口 ==========
local main = Instance.new("Frame")
main.Name = "MainWindow"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromScale(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 100, 120)
mainStroke.Thickness = 1.5
mainStroke.Parent = main

main.MouseEnter:Connect(function()
    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

-- ========== 顶部标题栏 ==========
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundTransparency = 1
topBar.Parent = main

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Text = "dao hub"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 30
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.TextStrokeTransparency = 0.5
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Parent = topBar

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 180, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 50)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(50, 255, 50)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(50, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 255))
})
gradient.Parent = titleLabel

task.spawn(function()
    while titleLabel.Parent do
        task.wait(0.05)
        gradient.Rotation = (gradient.Rotation + 2) % 360
    end
end)

local titleDivider = Instance.new("Frame")
titleDivider.Name = "TitleDivider"
titleDivider.Size = UDim2.new(1, -20, 0, 2)
titleDivider.Position = UDim2.new(0, 10, 0, 48)
titleDivider.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleDivider.BorderSizePixel = 0
titleDivider.Parent = topBar

-- ========== 左侧新功能区 ==========
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.BackgroundTransparency = 1
-- 关键修复：高度减去 100，为底部的 Setting 按钮留出充足的专属空间，避免重叠
leftPanel.Size = UDim2.new(0, 100, 1, -100)
leftPanel.Position = UDim2.new(0, 0, 0, 50)
leftPanel.Parent = main

local blueLine = Instance.new("Frame")
blueLine.Name = "BlueDividerLine"
blueLine.Size = UDim2.new(0, 2, 1, 0)
blueLine.Position = UDim2.new(1, -2, 0, 0)
blueLine.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
blueLine.BorderSizePixel = 0
blueLine.Parent = leftPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.SortOrder = Enum.SortOrder.LayoutOrder -- 开启排序
listLayout.Parent = leftPanel

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 15)
listPadding.Parent = leftPanel

-- ESP 按钮
local espButton = Instance.new("TextButton")
espButton.Name = "ESPButton"
espButton.Text = "ESP"
espButton.TextSize = 15
espButton.Font = Enum.Font.GothamBold
espButton.TextColor3 = Color3.fromRGB(200, 200, 210)
espButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
espButton.BorderSizePixel = 0
espButton.Size = UDim2.new(0, 80, 0, 36)
espButton.LayoutOrder = 1
espButton.Parent = leftPanel

local espBtnCorner = Instance.new("UICorner")
espBtnCorner.CornerRadius = UDim.new(0, 6)
espBtnCorner.Parent = espButton

-- 视觉按钮（新增）
local visionButton = Instance.new("TextButton")
visionButton.Name = "VisionButton"
visionButton.Text = "视觉"
visionButton.TextSize = 15
visionButton.Font = Enum.Font.GothamBold
visionButton.TextColor3 = Color3.fromRGB(200, 200, 210)
visionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
visionButton.BorderSizePixel = 0
visionButton.Size = UDim2.new(0, 80, 0, 36)
visionButton.LayoutOrder = 2
visionButton.Parent = leftPanel

local visionBtnCorner = Instance.new("UICorner")
visionBtnCorner.CornerRadius = UDim.new(0, 6)
visionBtnCorner.Parent = visionButton

-- Setting 按钮（左下角固定）
local settingButton = Instance.new("TextButton")
settingButton.Name = "SettingButton"
settingButton.Text = "Setting"
settingButton.TextSize = 15
settingButton.Font = Enum.Font.GothamBold
settingButton.TextColor3 = Color3.fromRGB(200, 200, 210)
settingButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
settingButton.BorderSizePixel = 0
settingButton.AnchorPoint = Vector2.new(0.5, 1)
settingButton.Position = UDim2.new(0, 50, 1, -15)
settingButton.Size = UDim2.new(0, 80, 0, 36)
settingButton.Parent = main

local settingBtnCorner = Instance.new("UICorner")
settingBtnCorner.CornerRadius = UDim.new(0, 6)
settingBtnCorner.Parent = settingButton

-- ========== 右侧内容区域 ==========
local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.Position = UDim2.new(0, 110, 0, 110)
content.Size = UDim2.new(1, -120, 1, -120)
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
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 28
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeTransparency = 0.5
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.Size = UDim2.new(1, 0, 0, 40)
title.Parent = defaultPage

-- ========== ESP 页面 ==========
local espPage = Instance.new("Frame")
espPage.Name = "ESPPage"
espPage.BackgroundTransparency = 1
espPage.Size = UDim2.new(1, 0, 1, 0)
espPage.Visible = false
espPage.Parent = content

local espTitle = Instance.new("TextLabel")
espTitle.Text = "玩家 ESP"
espTitle.BackgroundTransparency = 1
espTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
espTitle.TextSize = 22
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.TextStrokeTransparency = 0.5
espTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
espTitle.Size = UDim2.new(1, 0, 0, 36)
espTitle.Parent = espPage

local espList = Instance.new("Frame")
espList.BackgroundTransparency = 1
espList.Position = UDim2.new(0, 0, 0, 40)
espList.Size = UDim2.new(1, 0, 0, 150)
espList.Parent = espPage

local espLayout = Instance.new("UIListLayout")
espLayout.Padding = UDim.new(0, 10)
espLayout.Parent = espList

local interactTitle = Instance.new("TextLabel")
interactTitle.Text = "交互 ESP"
interactTitle.BackgroundTransparency = 1
interactTitle.TextColor3 = Color3.fromRGB(0, 255, 100)
interactTitle.TextSize = 22
interactTitle.Font = Enum.Font.GothamBold
interactTitle.TextXAlignment = Enum.TextXAlignment.Left
interactTitle.TextStrokeTransparency = 0.5
interactTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
interactTitle.Size = UDim2.new(1, 0, 0, 36)
interactTitle.Position = UDim2.new(0, 0, 0, 200)
interactTitle.Parent = espPage

local interactList = Instance.new("Frame")
interactList.BackgroundTransparency = 1
interactList.Position = UDim2.new(0, 0, 0, 240)
interactList.Size = UDim2.new(1, 0, 0, 100)
interactList.Parent = espPage

local interactLayout = Instance.new("UIListLayout")
interactLayout.Padding = UDim.new(0, 10)
interactLayout.Parent = interactList

-- ========== 视觉页面 ==========
local visionPage = Instance.new("Frame")
visionPage.Name = "VisionPage"
visionPage.BackgroundTransparency = 1
visionPage.Size = UDim2.new(1, 0, 1, 0)
visionPage.Visible = false
visionPage.Parent = content

local visionTitle = Instance.new("TextLabel")
visionTitle.Text = "视觉设置"
visionTitle.BackgroundTransparency = 1
visionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
visionTitle.TextSize = 24
visionTitle.Font = Enum.Font.GothamBold
visionTitle.TextXAlignment = Enum.TextXAlignment.Left
visionTitle.TextStrokeTransparency = 0.5
visionTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
visionTitle.Size = UDim2.new(1, 0, 0, 36)
visionTitle.Parent = visionPage

local visionList = Instance.new("Frame")
visionList.BackgroundTransparency = 1
visionList.Position = UDim2.new(0, 0, 0, 50)
visionList.Size = UDim2.new(1, 0, 1, -50)
visionList.Parent = visionPage

local visionLayout = Instance.new("UIListLayout")
visionLayout.Padding = UDim.new(0, 12)
visionLayout.Parent = visionList

-- 状态表
local espState = { Highlight = false, Name = false, Line = false, Interact = false }
local visualState = { HighlightMode = false, RemoveDarkness = false }

-- 通用创建开关按钮函数
local function createToggleButton(parent, text, key, onColor)
    local btn = Instance.new("TextButton")
    btn.Name = key .. "Toggle"
    btn.Text = text .. "：关"
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 200, 0, 38)
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if key == "HighlightMode" or key == "RemoveDarkness" then
            visualState[key] = not visualState[key]
            if visualState[key] then
                btn.Text = text .. "：开"
                btn.BackgroundColor3 = onColor or Color3.fromRGB(0, 120, 255)
            else
                btn.Text = text .. "：关"
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
            if updateVisuals then updateVisuals() end
        else
            espState[key] = not espState[key]
            if espState[key] then
                btn.Text = text .. "：开"
                btn.BackgroundColor3 = onColor or Color3.fromRGB(0, 120, 255)
            else
                btn.Text = text .. "：关"
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
        end
    end)
end

createToggleButton(espList, "高亮显示玩家", "Highlight", Color3.fromRGB(0, 120, 255))
createToggleButton(espList, "显示玩家用户名", "Name", Color3.fromRGB(0, 120, 255))
createToggleButton(espList, "显示距离射线", "Line", Color3.fromRGB(0, 120, 255))
createToggleButton(interactList, "高亮可交互目标", "Interact", Color3.fromRGB(0, 200, 80))

-- 视觉页面按钮
createToggleButton(visionList, "开启高亮模式", "HighlightMode", Color3.fromRGB(255, 180, 0))
createToggleButton(visionList, "删除地图黑暗效果", "RemoveDarkness", Color3.fromRGB(255, 100, 100))

-- ========== 视觉核心逻辑 ==========
local highlightEffect = nil
local originalLighting = {
    Brightness = nil, Ambient = nil, OutdoorAmbient = nil, ClockTime = nil, FogEnd = nil
}

updateVisuals = function()
    -- 1. 高亮模式
    if visualState.HighlightMode then
        if not highlightEffect or not highlightEffect.Parent then
            highlightEffect = Instance.new("ColorCorrectionEffect")
            highlightEffect.Name = "Vision_Highlight"
            highlightEffect.Brightness = 0.3
            highlightEffect.Contrast = 0.2
            highlightEffect.Saturation = 0.1
            highlightEffect.Parent = Lighting
        end
    else
        if highlightEffect then
            highlightEffect:Destroy()
            highlightEffect = nil
        end
    end

    -- 2. 删除黑暗效果
    if visualState.RemoveDarkness then
        if not originalLighting.Brightness then
            originalLighting.Brightness = Lighting.Brightness
            originalLighting.Ambient = Lighting.Ambient
            originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
            originalLighting.ClockTime = Lighting.ClockTime
            originalLighting.FogEnd = Lighting.FogEnd
        end
        
        pcall(function()
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
        end)
    else
        if originalLighting.Brightness then
            pcall(function()
                Lighting.Brightness = originalLighting.Brightness
                Lighting.Ambient = originalLighting.Ambient
                Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
                Lighting.ClockTime = originalLighting.ClockTime
                Lighting.FogEnd = originalLighting.FogEnd
            end)
            
            originalLighting = { Brightness = nil, Ambient = nil, OutdoorAmbient = nil, ClockTime = nil, FogEnd = nil }
        end
    end
end

-- ========== 设置页面 ==========
local settingPage = Instance.new("Frame")
settingPage.Name = "SettingPage"
settingPage.BackgroundTransparency = 1
settingPage.Size = UDim2.new(1, 0, 1, 0)
settingPage.Visible = false
settingPage.Parent = content

local settingTitle = Instance.new("TextLabel")
settingTitle.Text = "设置"
settingTitle.BackgroundTransparency = 1
settingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
settingTitle.TextSize = 24
settingTitle.Font = Enum.Font.GothamBold
settingTitle.TextXAlignment = Enum.TextXAlignment.Left
settingTitle.TextStrokeTransparency = 0.5
settingTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
settingTitle.Size = UDim2.new(1, 0, 0, 36)
settingTitle.Parent = settingPage

local settingList = Instance.new("Frame")
settingList.BackgroundTransparency = 1
settingList.Position = UDim2.new(0, 0, 0, 50)
settingList.Size = UDim2.new(1, 0, 1, -50)
settingList.Parent = settingPage

local settingLayout = Instance.new("UIListLayout")
settingLayout.Padding = UDim.new(0, 15)
settingLayout.Parent = settingList

-- 快捷键设置
local keyContainer = Instance.new("Frame")
keyContainer.Name = "KeybindContainer"
keyContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
keyContainer.BorderSizePixel = 0
keyContainer.Size = UDim2.new(0, 320, 0, 60)
keyContainer.Parent = settingList

local keyContainerCorner = Instance.new("UICorner")
keyContainerCorner.CornerRadius = UDim.new(0, 8)
keyContainerCorner.Parent = keyContainer

local keyLabel = Instance.new("TextLabel")
keyLabel.Text = "开关快捷键"
keyLabel.Font = Enum.Font.GothamBold
keyLabel.TextSize = 16
keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
keyLabel.BackgroundTransparency = 1
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Size = UDim2.new(0.5, 0, 1, 0)
keyLabel.Position = UDim2.new(0, 15, 0, 0)
keyLabel.Parent = keyContainer

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyInput"
keyBox.Text = "G"
keyBox.Font = Enum.Font.GothamBold
keyBox.TextSize = 16
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
keyBox.BorderSizePixel = 0
keyBox.Size = UDim2.new(0, 80, 0, 34)
keyBox.Position = UDim2.new(1, -95, 0.5, -17)
keyBox.Parent = keyContainer

local keyBoxCorner = Instance.new("UICorner")
keyBoxCorner.CornerRadius = UDim.new(0, 6)
keyBoxCorner.Parent = keyBox

keyBox.FocusLost:Connect(function()
    local inputText = string.upper(keyBox.Text)
    if inputText == "" then
        keyBox.Text = string.upper(currentToggleKey.Name)
        return
    end
    
    local success, keyCode = pcall(function()
        return Enum.KeyCode[inputText]
    end)
    
    if success and keyCode then
        currentToggleKey = keyCode
        keyBox.Text = inputText
    else
        keyBox.Text = string.upper(currentToggleKey.Name)
    end
end)

-- ========== 屏幕上方居中悬浮窗（缩小状态） ==========
local minimizedUi = Instance.new("Frame")
minimizedUi.Name = "MinimizedUI"
minimizedUi.AnchorPoint = Vector2.new(0.5, 0)
minimizedUi.Position = UDim2.new(0.5, 0, 0, 20)
minimizedUi.Size = UDim2.new(0, 120, 0, 40)
minimizedUi.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
minimizedUi.BorderSizePixel = 0
minimizedUi.Visible = false
minimizedUi.Active = true
minimizedUi.Parent = screenGui

local minimizedCorner = Instance.new("UICorner")
minimizedCorner.CornerRadius = UDim.new(0, 10)
minimizedCorner.Parent = minimizedUi

local minimizedStroke = Instance.new("UIStroke")
minimizedStroke.Color = Color3.fromRGB(100, 100, 120)
minimizedStroke.Thickness = 1.5
minimizedStroke.Parent = minimizedUi

local minimizedTitle = Instance.new("TextLabel")
minimizedTitle.Text = "dao hub"
minimizedTitle.Font = Enum.Font.GothamBlack
minimizedTitle.TextSize = 18
minimizedTitle.BackgroundTransparency = 1
minimizedTitle.Size = UDim2.new(1, 0, 1, 0)
minimizedTitle.TextStrokeTransparency = 0.5
minimizedTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
minimizedTitle.Parent = minimizedUi

local minimizedGradient = Instance.new("UIGradient")
minimizedGradient.Color = gradient.Color
minimizedGradient.Parent = minimizedTitle

task.spawn(function()
    while minimizedTitle.Parent do
        task.wait(0.05)
        minimizedGradient.Rotation = (minimizedGradient.Rotation + 2) % 360
    end
end)

-- ========== 快捷键逻辑 ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == currentToggleKey then
        local isMainVisible = main.Visible
        main.Visible = not isMainVisible
        minimizedUi.Visible = isMainVisible
    end
end)

-- ========== 按钮切换逻辑 ==========
local function resetButton(btn)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
end

local function highlightButton(btn)
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

local function switchPage(pageToShow, btnToHighlight)
    defaultPage.Visible = false
    espPage.Visible = false
    settingPage.Visible = false
    visionPage.Visible = false
    
    pageToShow.Visible = true
    
    highlightButton(btnToHighlight)
    if btnToHighlight ~= espButton then resetButton(espButton) end
    if btnToHighlight ~= settingButton then resetButton(settingButton) end
    if btnToHighlight ~= visionButton then resetButton(visionButton) end
end

espButton.MouseButton1Click:Connect(function()
    switchPage(espPage, espButton)
end)

visionButton.MouseButton1Click:Connect(function()
    switchPage(visionPage, visionButton)
end)

settingButton.MouseButton1Click:Connect(function()
    switchPage(settingPage, settingButton)
end)

-- ========== 核心玩家 ESP 逻辑 ==========
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

-- ========== 核心交互 ESP 逻辑（极度严格版） ==========
local interactCache = {}

local function cleanupInteractESP()
    for _, data in pairs(interactCache) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Label then data.Label:Destroy() end
    end
    interactCache = {}
end

task.spawn(function()
    while true do
        task.wait(1.5)
        
        if not espState.Interact then
            if next(interactCache) then cleanupInteractESP() end
        else
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local targetPart = nil
                    
                    if obj.Parent:IsA("BasePart") then
                        targetPart = obj.Parent
                    elseif obj.Parent:IsA("Attachment") and obj.Parent.Parent:IsA("BasePart") then
                        targetPart = obj.Parent.Parent
                    end
                    
                    if targetPart and not interactCache[targetPart] then
                        -- 关键修复：仅当部件最大尺寸小于 15 时才进行高亮（宝箱大小通常小于10）
                        -- 这样哪怕提示挂在地板或墙壁上，也不会全屏变绿
                        local size = targetPart.Size
                        local isSmallEnough = (size.X <= 15 and size.Y <= 15 and size.Z <= 15)
                        
                        local hl = nil
                        if isSmallEnough then
                            hl = Instance.new("Highlight")
                            hl.Name = "Interact_Highlight"
                            hl.FillColor = Color3.fromRGB(0, 255, 100)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.4
                            hl.OutlineTransparency = 0
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = targetPart
                        end
                        
                        -- 无论大小，都会在物体上方显示“[可交互]”标签
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "Interact_Label"
                        bb.Adornee = targetPart
                        bb.Size = UDim2.new(0, 120, 0, 30)
                        bb.StudsOffset = Vector3.new(0, 3.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = targetPart
                        
                        local text = Instance.new("TextLabel")
                        text.Text = "[可交互]"
                        text.BackgroundTransparency = 1
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.Font = Enum.Font.GothamBold
                        text.TextSize = 14
                        text.TextColor3 = Color3.fromRGB(0, 255, 100)
                        text.TextStrokeTransparency = 0
                        text.Parent = bb
                        
                        interactCache[targetPart] = {Highlight = hl, Label = bb}
                    end
                end
            end
            
            for target, data in pairs(interactCache) do
                if not target.Parent then
                    if data.Highlight then data.Highlight:Destroy() end
                    if data.Label then data.Label:Destroy() end
                    interactCache[target] = nil
                end
            end
        end
    end
end)

-- ========== 玩家 ESP 渲染循环 ==========
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

                if espState.Highlight then
                    if not data.Highlight or not data.Highlight.Parent then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESP_Highlight"
                        hl.FillColor = Color3.fromRGB(0, 150, 255)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                        data.Highlight = hl
                    end
                else
                    if data.Highlight then data.Highlight:Destroy() data.Highlight = nil end
                end

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
                        textLabel.TextSize = 16
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextStrokeTransparency = 0
                        textLabel.Text = targetPlayer.Name
                        textLabel.Parent = bb
                        
                        data.Billboard = bb
                        data.NameLabel = textLabel
                    end
                    if data.NameLabel then data.NameLabel.Text = targetPlayer.Name end
                else
                    if data.Billboard then data.Billboard:Destroy() data.Billboard = nil data.NameLabel = nil end
                end

                if espState.Line then
                    if localRoot then
                        local distance = (root.Position - localRoot.Position).Magnitude
                        if not data.Line or not data.Line.Parent then
                            local line = Instance.new("LineHandleAdornment")
                            line.Name = "ESP_Line"
                            line.Adornee = root
                            line.Thickness = 2
                            line.Color3 = Color3.fromRGB(0, 150, 255)
                            line.Transparency = 0.4
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
                            distLabel.Font = Enum.Font.GothamBold
                            distLabel.TextSize = 14
                            distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            distLabel.TextStrokeTransparency = 0
                            distLabel.Text = string.format("%d m", distance)
                            distLabel.Parent = distBb
                            
                            data.DistanceGui = distBb
                            data.DistanceLabel = distLabel
                        end
                        if data.DistanceLabel then data.DistanceLabel.Text = string.format("%d m", distance) end
                    end
                else
                    if data.Line then data.Line:Destroy() data.Line = nil end
                    if data.DistanceGui then data.DistanceGui:Destroy() data.DistanceGui = nil end
                    if data.DistanceLabel then data.DistanceLabel:Destroy() data.DistanceLabel = nil end
                end
            end
        end
    end

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

-- ========== 右下角弹窗（5秒后消失） ==========
task.wait() 

local absSize = main.AbsoluteSize

local notification = Instance.new("Frame")
notification.Name = "Notification"
notification.AnchorPoint = Vector2.new(1, 1)
notification.Position = UDim2.new(1, -20, 1, -20)
notification.Size = UDim2.new(0, 260, 0, 80)
notification.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
notification.BackgroundTransparency = 0.1
notification.BorderSizePixel = 0
notification.Parent = screenGui

local notifyCorner = Instance.new("UICorner")
notifyCorner.CornerRadius = UDim.new(0, 8)
notifyCorner.Parent = notification

local notifyStroke = Instance.new("UIStroke")
notifyStroke.Color = Color3.fromRGB(100, 100, 120)
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
notifyTitle.TextStrokeTransparency = 0.5
notifyTitle.Parent = notification

local notifyText = Instance.new("TextLabel")
notifyText.Font = Enum.Font.GothamBold
notifyText.TextSize = 14
notifyText.TextColor3 = Color3.fromRGB(220, 220, 230)
notifyText.BackgroundTransparency = 1
notifyText.Size = UDim2.new(1, -20, 0, 36)
notifyText.Position = UDim2.new(0, 10, 0, 34)
notifyText.TextXAlignment = Enum.TextXAlignment.Left
notifyText.TextYAlignment = Enum.TextYAlignment.Top
notifyText.TextWrapped = true
notifyText.TextStrokeTransparency = 0.5
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
