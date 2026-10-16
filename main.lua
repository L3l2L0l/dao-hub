-- 自动生成占屏幕 50% 的窗口，带顶部彩虹标题、左侧功能栏 + ESP 和 Setting 面板（支持快捷键隐藏/显示）
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

-- ========== 快捷键状态 ==========
local currentToggleKey = Enum.KeyCode.G -- 默认 G 键

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
main.Size = UDim2.fromScale(0.5, 0.5) -- 初始为屏幕 50% 大小
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 100, 120)
mainStroke.Thickness = 1.5
mainStroke.Parent = main

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
leftPanel.Size = UDim2.new(0, 100, 1, -50)
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
espButton.Parent = leftPanel

local espBtnCorner = Instance.new("UICorner")
espBtnCorner.CornerRadius = UDim.new(0, 6)
espBtnCorner.Parent = espButton

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
espTitle.Text = "ESP 功能"
espTitle.BackgroundTransparency = 1
espTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
espTitle.TextSize = 24
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.TextStrokeTransparency = 0.5
espTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
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

local espState = { Highlight = false, Name = false, Line = false }

local function createToggleButton(parent, text, key)
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
        espState[key] = not espState[key]
        if espState[key] then
            btn.Text = text .. "：开"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        else
            btn.Text = text .. "：关"
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
    end)
end

createToggleButton(espList, "高亮显示玩家", "Highlight")
createToggleButton(espList, "显示玩家用户名", "Name")
createToggleButton(espList, "显示距离射线", "Line")

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

-- ========== 在设置页面中添加：快捷键设置 ==========
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
minimizedUi.Position = UDim2.new(0.5, 0, 0, 20) -- 屏幕上方居中
minimizedUi.Size = UDim2.new(0, 120, 0, 40)
minimizedUi.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
minimizedUi.BorderSizePixel = 0
minimizedUi.Visible = false -- 默认隐藏
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
minimizedGradient.Color = gradient.Color -- 复用彩虹渐变色
minimizedGradient.Parent = minimizedTitle

task.spawn(function()
    while minimizedTitle.Parent do
        task.wait(0.05)
        minimizedGradient.Rotation = (minimizedGradient.Rotation + 2) % 360
    end
end)

-- ========== 快捷键逻辑 ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- gameProcessed 为 true 时表示玩家正在聊天框或输入框中打字，不触发切换
    if gameProcessed then return end
    
    if input.KeyCode == currentToggleKey then
        local isMainVisible = main.Visible
        main.Visible = not isMainVisible
        minimizedUi.Visible = isMainVisible -- 主界面隐藏时，显示悬浮窗，反之亦然
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

espButton.MouseButton1Click:Connect(function()
    defaultPage.Visible = false
    espPage.Visible = true
    settingPage.Visible = false
    highlightButton(espButton)
    resetButton(settingButton)
end)

settingButton.MouseButton1Click:Connect(function()
    defaultPage.Visible = false
    espPage.Visible = false
    settingPage.Visible = true
    highlightButton(settingButton)
    resetButton(espButton)
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
                        hl.FillColor = Color3.fromRGB(0, 150, 255)
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
                        textLabel.TextSize = 16
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
