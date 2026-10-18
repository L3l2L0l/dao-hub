local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 防挂机踢出
player.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/ui.lua.txt"))()

WindUI:AddTheme({
    Name = "Fallen Aero",
    Accent = Color3.fromHex("#7C3AED"),
    Background = Color3.fromHex("#09090B"),
    Outline = Color3.fromHex("#4C1D95"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#71717A"),
    Button = Color3.fromHex("#1E1B4B"),
    Icon = Color3.fromHex("#A78BFA"),
})

local Window = WindUI:CreateWindow({
    Title = "Aero      ",
    Folder = "Aero",
    SideBarWidth = 180,
    Background = "https://chaton-images.s3.us-east-2.amazonaws.com/alHcHts2JjSlmMRKjQeDXFipKS5LjNhrKrkN8TxbH7HgPmXA1QbuEYZh3Hwnb9F5_1536x1024x1945789.png",
    BackgroundImageTransparency = 0.35,
    OpenButton = {
        Title = "打开脚本",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.9,
        Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("6D28D9")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("A855F7"))
        }),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

Window:Tag({
    Title = "V1.14",
    Color = Color3.fromHex("00CED1"),
    Radius = 2,
})

Window:Tag({
    Title = "Yisan",
    Icon = "crown",
    Color = Color3.fromHex("FFD700"),
    Radius = 2,
})


local COLOR_SCHEMES = {
    ["Fallen Purple"] = {
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("2E1065")),
            ColorSequenceKeypoint.new(0.3, Color3.fromHex("4C1D95")),
            ColorSequenceKeypoint.new(0.6, Color3.fromHex("7C3AED")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("C084FC"))
        }),
        "waves"
    }
}

local borderAnimation
local animationSpeed = 5

local function createRainbowBorder(window, colorScheme)
    local mainFrame = window.UIElements.Main
    if not mainFrame then return nil end

    local existingStroke = mainFrame:FindFirstChild("RainbowStroke")
    if existingStroke then existingStroke:Destroy() end

    if not mainFrame:FindFirstChildOfClass("UICorner") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = mainFrame
    end

    local rainbowStroke = Instance.new("UIStroke")
    rainbowStroke.Name = "RainbowStroke"
    rainbowStroke.Thickness = 1.5
    rainbowStroke.Transparency = 0.15
    rainbowStroke.Color = Color3.new(1, 1, 1)
    rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rainbowStroke.LineJoinMode = Enum.LineJoinMode.Round
    rainbowStroke.Parent = mainFrame

    local glowEffect = Instance.new("UIGradient")
    glowEffect.Name = "GlowEffect"
    local schemeData = COLOR_SCHEMES[colorScheme or "彩虹颜色"]
    glowEffect.Color = schemeData and schemeData[1] or COLOR_SCHEMES["彩虹颜色"][1]
    glowEffect.Rotation = 0
    glowEffect.Parent = rainbowStroke
    local outerGlow = Instance.new("UIStroke")
    outerGlow.Name = "OuterGlow"
    outerGlow.Thickness = 8
    outerGlow.Transparency = 0.85
    outerGlow.Color = Color3.fromHex("7C3AED")
    outerGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outerGlow.Parent = mainFrame
    return rainbowStroke
end

local function startBorderAnimation(window, speed)
    local mainFrame = window.UIElements.Main
    if not mainFrame then return nil end
    local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
    if not rainbowStroke then return nil end
    local glowEffect = rainbowStroke:FindFirstChild("GlowEffect")
    if not glowEffect then return nil end

    return game:GetService("RunService").Heartbeat:Connect(function()
        if not rainbowStroke or rainbowStroke.Parent == nil then return end
        glowEffect.Rotation = (tick() * speed * 10) % 360
    end)
end

local rainbowStroke = createRainbowBorder(Window, "Fallen Purple")
if rainbowStroke then
    borderAnimation = startBorderAnimation(Window, animationSpeed)
end

local Lighting = game:GetService("Lighting")
local TweenServiceBlur = game:GetService("TweenService")

local blur = Lighting:FindFirstChildOfClass("BlurEffect")
if not blur then
    blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
end

task.spawn(function()
    local wasOpen = false
    while true do
        task.wait(0.1)
        local mainFrame = Window.UIElements and Window.UIElements.Main
        local isOpen = mainFrame and mainFrame.Visible or false
        
        if isOpen ~= wasOpen then
            wasOpen = isOpen
            TweenServiceBlur:Create(blur, TweenInfo.new(0.3), {
                Size = isOpen and 20 or 0
            }):Play()
        end
    end
end)

local getRoot
getRoot = function(model)
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
end

local ESP = {
    Players = false,
    Monsters = false,
    Self = false,
    MaxDistance = 2500,
}

local D = Drawing or drawing
local drawPool = {}
local aliveKeys = {}

local function getDraw(key)
    local t = drawPool[key]
    if not t then
        t = { box = D.new("Square"), text = D.new("Text") }
        t.box.Thickness = 2
        t.box.Filled = false
        t.text.Size = 14
        t.text.Center = true
        t.text.Outline = true
        drawPool[key] = t
    end
    return t
end

local function getDistance(model)
    local lpChar = player.Character
    local lpRoot = lpChar and getRoot(lpChar)
    local root = getRoot(model)
    if lpRoot and root then
        return (lpRoot.Position - root.Position).Magnitude
    end
    return nil
end

local function drawTarget(t, model, name, color, downed, hp, dist)
    local root = getRoot(model)
    local ok, extents = pcall(function() return model:GetExtentsSize() end)
    if not root or not ok then
        t.box.Visible = false
        t.text.Visible = false
        return
    end

    local w = math.max(extents.X / 2, 1.5)
    local hh = math.max(extents.Y / 2, 2)
    local cf = root.CFrame
    local corners = {
        cf:PointToWorldSpace(Vector3.new(-w, hh, 0)),
        cf:PointToWorldSpace(Vector3.new(w, hh, 0)),
        cf:PointToWorldSpace(Vector3.new(-w, -hh, 0)),
        cf:PointToWorldSpace(Vector3.new(w, -hh, 0)),
    }

    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    local onScreen = false
    for _, pos in ipairs(corners) do
        local v, vis = Camera:WorldToViewportPoint(pos)
        if vis then onScreen = true end
        if v.X < minX then minX = v.X end
        if v.X > maxX then maxX = v.X end
        if v.Y < minY then minY = v.Y end
        if v.Y > maxY then maxY = v.Y end
    end

    if not onScreen or (dist and dist > ESP.MaxDistance) then
        t.box.Visible = false
        t.text.Visible = false
        return
    end

    t.box.Position = Vector2.new(minX, minY)
    t.box.Size = Vector2.new(maxX - minX, maxY - minY)
    t.box.Color = color
    t.box.Visible = true

    local parts = {}
    if name then table.insert(parts, name) end
    if downed then table.insert(parts, "[倒地]") end
    if hp then table.insert(parts, "HP:" .. hp) end
    if dist then table.insert(parts, math.floor(dist) .. "m") end

    t.text.Text = table.concat(parts, " | ")
    t.text.Position = Vector2.new((minX + maxX) / 2, minY - 16)
    t.text.Color = color
    t.text.Visible = true
end

local function collectTargets()
    local list = {}
    local container = workspace:FindFirstChild("Players")
    if not container then return list end

    for _, model in ipairs(container:GetChildren()) do
        if model:IsA("Model") then
            local team = model:GetAttribute("Team")
            if team == "Nextbot" and ESP.Monsters then
                list[#list + 1] = { model = model, kind = "monster" }
            elseif team == "PlayerTeam" and (model ~= player.Character or ESP.Self) and ESP.Players then
                list[#list + 1] = { model = model, kind = "player" }
            end
        end
    end
    return list
end

local function update()
    if not D then return end
    local targets = collectTargets()
    aliveKeys = {}

    for _, entry in ipairs(targets) do
        local model = entry.model
        local key = entry.kind .. ":" .. tostring(model)
        aliveKeys[key] = true

        local t = getDraw(key)
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local hp = humanoid and math.floor(humanoid.Health + 0.5) or nil
        local dist = getDistance(model)

        if entry.kind == "player" then
            local downed = humanoid and humanoid.Health <= 0 or false
            local disp = humanoid and humanoid.DisplayName or model.Name
            local name = (disp and disp ~= "" and disp ~= "(无)") and disp or model.Name
            drawTarget(t, model, name, downed and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(0, 255, 128), downed, hp, dist)
        else
            drawTarget(t, model, model.Name, Color3.fromRGB(255, 40, 40), false, nil, dist)
        end
    end

    local toRemove = {}
    for key, t in pairs(drawPool) do
        if not aliveKeys[key] then
            table.insert(toRemove, key)
        end
    end
    for _, key in ipairs(toRemove) do
        local t = drawPool[key]
        pcall(function() t.box:Remove() end)
        pcall(function() t.text:Remove() end)
        drawPool[key] = nil
    end
end

task.spawn(function()
    while true do
        pcall(update)
        task.wait(0.03)
    end
end)

local currentSpeed = 2000
local jumpValue = 7
local autoJumpEnabled = false
local BaseStatsModule = nil
local speedHooked = false

local okLoad, bs, mf = pcall(function()
    local r = ReplicatedStorage.Objects.Game.Character.Client.Movement
    return require(r.MoveStats.BaseStats), require(r.MoveFunction)
end)
if okLoad and bs and mf and not mf.__speedHooked then
    mf.__speedHooked = true
    local originalMove = mf.Move
    mf.Move = function(self, dt, state, stats)
        if type(stats) == "table" then
            stats.Speed = currentSpeed
        end
        return originalMove(self, dt, state, stats)
    end
    BaseStatsModule = bs
    speedHooked = true
end

local function applySpeed(value)
    currentSpeed = value
    if BaseStatsModule then
        BaseStatsModule.Speed = value
    end
end

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    pcall(function()
        humanoid.JumpHeight = jumpValue
        humanoid.JumpPower = jumpValue * 98.1
    end)
end)

local lastJumpTime = 0
local function hookAutoJump(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.StateChanged:Connect(function(old, new)
        if not autoJumpEnabled then return end
        if new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running then
            task.delay(0.1, function()
                if not autoJumpEnabled then return end
                local now = tick()
                if now - lastJumpTime < 0.3 then return end
                lastJumpTime = now
                pcall(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end)
        end
    end)
end
player.CharacterAdded:Connect(hookAutoJump)
if player.Character then hookAutoJump(player.Character) end

-- 基础加入/复活函数
local function enterRound()
    pcall(function()
        local events = ReplicatedStorage:FindFirstChild("Events")
        local ev = events and (events:FindFirstChild("SetPlayerMode") or events:WaitForChild("SetPlayerMode", 5))
        if ev then
            ev:FireServer(true)
        end
    end)
end

-- ==================== 自动复活 / 无限复活 ====================
local autoRevive = false
local autoReviveDelay = 1.5
local reEnterCooldown = 3
local downedSince = nil
local lastEnterAttempt = 0

local function isDowned()
    local char = player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health <= 0
end

local function isInRound()
    local char = player.Character
    if not char then return false end
    local container = workspace:FindFirstChild("Players")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return container ~= nil and char.Parent == container and humanoid ~= nil and humanoid.Health > 0
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if not autoRevive then
            downedSince = nil
            lastEnterAttempt = 0
            continue
        end

        local now = tick()

        if isDowned() then
            if downedSince == nil then
                downedSince = now
            elseif now - downedSince >= autoReviveDelay and now - lastEnterAttempt >= reEnterCooldown then
                lastEnterAttempt = now
                enterRound()
            end
            continue
        end

        downedSince = nil

        if not isInRound() and now - lastEnterAttempt >= reEnterCooldown then
            lastEnterAttempt = now
            enterRound()
        end
    end
end)
-- ==================== 自动复活 / 无限复活 结束 ====================

local platformEnabled = false
local platformHeight = 400
local platform = nil
local mapCenter = nil
local hasCenter = false
local cachedPartsCenter = nil
local lastFallbackScan = 0

local function median(t)
    if #t == 0 then return nil end
    table.sort(t)
    return t[math.floor(#t / 2) + 1]
end

local function destroyPlatform()
    if platform then
        pcall(function() platform:Destroy() end)
        platform = nil
    end
end

local function buildPlatform()
    if not mapCenter then return end
    destroyPlatform()
    platform = Instance.new("Part")
    platform.Name = "SkyPlatform"
    platform.Size = Vector3.new(300, 4, 300)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.Glass
    platform.Transparency = 0.4
    platform.Color = Color3.fromRGB(200, 230, 255)
    platform.CastShadow = false
    platform.Reflectance = 0.1
    platform.Position = Vector3.new(mapCenter.X, mapCenter.Y + platformHeight, mapCenter.Z)
    platform.Parent = workspace
end

local function centerFromSpawns()
    local xs, ys, zs = {}, {}, {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            table.insert(xs, obj.Position.X)
            table.insert(ys, obj.Position.Y)
            table.insert(zs, obj.Position.Z)
        end
    end
    if #xs == 0 then return nil end
    return Vector3.new(median(xs), median(ys), median(zs))
end

local function centerFromParts()
    local xs, zs = {}, {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Anchored then
            local sz = obj.Size
            if sz.X < 500 and sz.Z < 500 then
                table.insert(xs, obj.Position.X)
                table.insert(zs, obj.Position.Z)
            end
        end
    end
    if #xs == 0 then return nil end
    return Vector3.new(median(xs), 0, median(zs))
end

local function rescanCenter()
    local newCenter = nil
    local groundY = 0

    local spawnCenter = centerFromSpawns()
    if spawnCenter then
        newCenter = spawnCenter
        groundY = spawnCenter.Y
    else
        local now = tick()
        if not cachedPartsCenter or (now - lastFallbackScan >= 20) then
            cachedPartsCenter = centerFromParts()
            lastFallbackScan = now
        end
        if not cachedPartsCenter then return end
        local char = player.Character
        local root = char and getRoot(char)
        groundY = (root and root.Position.Y > -1000) and root.Position.Y or 0
        newCenter = Vector3.new(cachedPartsCenter.X, groundY, cachedPartsCenter.Z)
    end

    if not hasCenter then
        mapCenter = Vector3.new(newCenter.X, groundY, newCenter.Z)
        hasCenter = true
        buildPlatform()
        return
    end

    local moved = Vector3.new(newCenter.X - mapCenter.X, 0, newCenter.Z - mapCenter.Z).Magnitude
    if moved > 150 then
        mapCenter = Vector3.new(newCenter.X, groundY, newCenter.Z)
        buildPlatform()
    end
end

local function clearForces(char)
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("LinearVelocity") then
            pcall(function() v:Destroy() end)
        end
    end
end

local function teleportToPlatform()
    if not platformEnabled or not platform then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    clearForces(char)

    local target = Vector3.new(platform.Position.X, platform.Position.Y + platform.Size.Y / 2 + 3, platform.Position.Z)
    char:PivotTo(CFrame.new(target))

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        Camera.CameraSubject = humanoid
    end
    Camera.CFrame = CFrame.lookAt(target + Vector3.new(0, 5, 12), target)
end

task.spawn(function()
    local lastForceTeleport = 0
    local lastRescan = 0

    while true do
        task.wait(0.3)
        if not platformEnabled then continue end

        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local now = tick()
        if now - lastRescan >= 4 then
            lastRescan = now
            rescanCenter()
        end

        if not platform or not platform.Parent then
            if hasCenter then buildPlatform() end
        end

        if not platform then continue end

        local top = platform.Position.Y + platform.Size.Y / 2
        local dropped = root.Position.Y < (top - 25)
        local timeUp = (now - lastForceTeleport) >= 5

        if dropped or timeUp then
            lastForceTeleport = now
            teleportToPlatform()
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    task.wait(1)
    char:WaitForChild("HumanoidRootPart", 5)
    if platformEnabled then
        teleportToPlatform()
    end
end)

-- ==================== 自动收集（代币优先） ====================
local toraCollectEnabled = false

local function getTicketsFolder()
    local effects = workspace:FindFirstChild("Effects")
    return effects and effects:FindFirstChild("Tickets")
end

local function hasTokens()
    local tickets = getTicketsFolder()
    if not tickets then return false end
    for _, child in ipairs(tickets:GetChildren()) do
        if child:FindFirstChild("HumanoidRootPart") then
            return true
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if not toraCollectEnabled then continue end
        pcall(function()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local tickets = getTicketsFolder()
            if not tickets then return end

            for _, ticket in ipairs(tickets:GetChildren()) do
                if not toraCollectEnabled then break end
                local tr = ticket:FindFirstChild("HumanoidRootPart")
                if tr then
                    root.CFrame = CFrame.new(tr.Position)
                end
            end
        end)
    end
end)
-- ==================== 自动收集 结束 ====================

-- ==================== 自动躲避 Nextbot ====================
local avoidEnabled = false
local avoidDistance = 30

local function getItemSpawnPoints()
    local map = workspace:FindFirstChild("Map")
    local itemSpawns = map and map:FindFirstChild("ItemSpawns")
    if not itemSpawns then return {} end
    local list = {}
    for _, s in ipairs(itemSpawns:GetChildren()) do
        if s.Name == "ItemSpawn" then
            table.insert(list, s)
        end
    end
    return list
end

task.spawn(function()
    while true do
        task.wait()
        if not avoidEnabled then continue end
        pcall(function()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local nearest, nearestDist = nil, avoidDistance
            local playersContainer = workspace:FindFirstChild("Players")
            if playersContainer then
                for _, child in ipairs(playersContainer:GetChildren()) do
                    if child:GetAttribute("AI") == true then
                        local cr = child:FindFirstChild("HumanoidRootPart")
                        if cr then
                            local d = (root.Position - cr.Position).Magnitude
                            if d < nearestDist then
                                nearest, nearestDist = child, d
                            end
                        end
                    end
                end
            end

            if nearest then
                local list = getItemSpawnPoints()
                if #list > 0 then
                    local target = list[math.random(1, #list)]
                    root.CFrame = target.CFrame
                end
            end
        end)
    end
end)
-- ==================== 自动躲避 Nextbot 结束 ====================

-- ==================== 自动装备灯笼（真实装备） ====================
local autoEquipLantern = false
local lanternInterval = 1
local lanternCosmetic = true
local lanternLastNotify = 0
local lanternCosmeticModel = nil
local LanternState = { CharacterService = nil, Module = nil }

local function lanternCharService()
    if LanternState.CharacterService then return LanternState.CharacterService end
    local ok, mod = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Asset"):WaitForChild("CharacterService"))
    end)
    if ok and type(mod) == "table" then
        LanternState.CharacterService = mod
        return mod
    end
    return nil
end

local function lanternLocalCharacter()
    local svc = lanternCharService()
    if not svc then return nil end
    local ok, char = pcall(function() return svc:GetLocalCharacter() end)
    if ok then return char end
    return nil
end

local function lanternModule()
    if LanternState.Module and LanternState.Module.Parent then return LanternState.Module end
    local tools = ReplicatedStorage:FindFirstChild("Tools")
    if not tools then return nil end
    LanternState.Module = tools:FindFirstChild("Lantern")
    return LanternState.Module
end

local function findLanternTool(profile)
    local list = profile and profile.Tools
    if type(list) ~= "table" then return nil end
    local target = lanternModule()
    for idx, tool in ipairs(list) do
        local mod = tool and tool.Module
        if mod and mod.Name == "Lantern" then return tool, idx end
        if target and mod == target then return tool, idx end
    end
    return nil
end

local function lanternCurrentName(profile)
    local cur
    pcall(function() cur = profile:GetCurrentTool() end)
    local mod = cur and cur.Module
    return mod and mod.Name or nil
end

local function lanternNotify(content, force)
    if not force and tick() - lanternLastNotify < 10 then return end
    lanternLastNotify = tick()
    pcall(function()
        WindUI:Notify({ Title = "自动装备灯笼", Content = content, Duration = 3 })
    end)
end

local LKEY = {
    Flashlight = Enum.KeyCode.F,
    ["1"] = Enum.KeyCode.One, ["2"] = Enum.KeyCode.Two, ["3"] = Enum.KeyCode.Three,
    ["4"] = Enum.KeyCode.Four, ["5"] = Enum.KeyCode.Five, ["6"] = Enum.KeyCode.Six,
    ["7"] = Enum.KeyCode.Seven, ["8"] = Enum.KeyCode.Eight, ["9"] = Enum.KeyCode.Nine,
}

local function pressKey(keyCode)
    if not keyCode then return end
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.04)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function lanternToolNames(profile)
    local out = {}
    for i, t in ipairs((profile and profile.Tools) or {}) do
        out[#out + 1] = i .. "=" .. tostring(t.Module and t.Module.Name)
            .. "(" .. tostring(t.Keybind) .. ")"
    end
    return table.concat(out, " ")
end

local function lanternDiag()
    local lines = { "===== 灯笼诊断 =====" }
    local svc = lanternCharService()
    lines[#lines + 1] = "CharacterService: " .. (svc and "OK" or "不可用（require 被禁？）")

    local char = lanternLocalCharacter()
    lines[#lines + 1] = "本地角色: " .. (char and tostring(char.Name) or "nil")
    if char then
        local profile = char.ToolProfile
        lines[#lines + 1] = "ToolProfile: " .. (profile and "OK" or "nil")
        if profile then
            local tools = profile.Tools or {}
            lines[#lines + 1] = "Tools(" .. #tools .. "): " .. lanternToolNames(profile)
            lines[#lines + 1] = "当前工具: " .. tostring(lanternCurrentName(profile))
            local tool, idx = findLanternTool(profile)
            if tool then
                lines[#lines + 1] = "灯笼: 有 / 序号=" .. tostring(idx)
                    .. " / Keybind=" .. tostring(tool.Keybind)
            else
                lines[#lines + 1] = "灯笼: 无（本局装备栏没有 Lantern）"
            end
        end
        pcall(function()
            lines[#lines + 1] = "注册表 Equipped=" .. tostring(char.DataRegistry:Get("Equipped"))
                .. " / EquippedName=" .. tostring(char.DataRegistry:Get("EquippedName"))
                .. " / Tools=" .. tostring(#(char.DataRegistry:Get("Tools") or {}))
        end)
    end
    local text = table.concat(lines, "\n")
    print(text)
    return text
end

local function equipLanternReal(verbose)
    local char = lanternLocalCharacter()
    if not char then return "no_char" end
    local profile = char.ToolProfile
    if not profile then return "no_profile" end

    local tools = profile.Tools or {}
    if #tools == 0 then return "not_ready" end

    local tool, index = findLanternTool(profile)
    if not tool then
        if verbose then print("[灯笼] 装备栏里没有 Lantern ->", lanternToolNames(profile)) end
        return "not_in_loadout"
    end

    if lanternCurrentName(profile) == "Lantern" then return "already" end

    local keybind = tool.Keybind
    local steps = {
        { name = "KeyPhraseUsed", run = function() profile:KeyPhraseUsed({ Key = keybind, Down = true }) end },
        { name = "AttemptEquip", run = function() profile:AttemptEquip(keybind) end },
        { name = "DataRegistry.Equipped", run = function() char.DataRegistry:Set("Equipped", index) end },
        { name = "KeyPress", run = function() pressKey(LKEY[tostring(keybind)]) end },
    }

    for _, step in ipairs(steps) do
        local ok, err = pcall(step.run)
        if not ok and verbose then
            print("[灯笼] " .. step.name .. " 报错:", err)
        end
        task.wait(0.25)
        if lanternCurrentName(profile) == "Lantern" then
            if verbose then print("[灯笼] 装备成功，方式:", step.name) end
            return "equipped:" .. step.name
        end
    end

    if verbose then
        print("[灯笼] 4 条路径都没成功")
        lanternDiag()
    end
    return "failed"
end

local function removeCosmeticLantern()
    if lanternCosmeticModel then
        pcall(function() lanternCosmeticModel:Destroy() end)
        lanternCosmeticModel = nil
    end
end

local function applyCosmeticLantern()
    if not lanternCosmetic then return end
    local char = player.Character
    if not char then return end
    local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    if not hand then return end
    if lanternCosmeticModel and lanternCosmeticModel.Parent then return end

    removeCosmeticLantern()

    local items = ReplicatedStorage:FindFirstChild("Items")
    local baseItems = items and items:FindFirstChild("BaseItems")
    local loadout = baseItems and baseItems:FindFirstChild("Loadout")
    local lights = loadout and loadout:FindFirstChild("Lights")
    local lantern = lights and lights:FindFirstChild("Lantern")
    if not lantern then return end

    local clone = lantern:Clone()
    clone.Name = "LocalLantern"
    local grip = clone:FindFirstChild("Grip")
        or (clone:FindFirstChild("Visual") and clone.Visual:FindFirstChild("Grip"))
        or clone:FindFirstChildWhichIsA("BasePart")
    if not grip then clone:Destroy(); return end

    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.CanCollide = false
            part.Massless = true
        end
    end

    clone.PrimaryPart = grip
    clone:PivotTo(hand.CFrame * CFrame.new(0, -0.5, 0))
    clone.Parent = char

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hand
    weld.Part1 = grip
    weld.Parent = grip

    lanternCosmeticModel = clone
end

task.spawn(function()
    while true do
        task.wait(lanternInterval)
        if autoEquipLantern then
            local ok, res = pcall(equipLanternReal, false)
            if ok and type(res) == "string" then
                if res == "not_in_loadout" or res == "failed" then
                    applyCosmeticLantern()
                elseif res == "already" or res:sub(1, 9) == "equipped:" then
                    removeCosmeticLantern()
                end
            end
        end
    end
end)
-- ==================== 自动装备灯笼 结束 ====================

-- ==================== 救人 / 放逐 ====================
-- 反编译依据（ReplicatedStorage.Services.Asset.InteractionService.InteractionTypes）：
--   Carry  = { Keybind = "Melee", KeybindName = "Q" }  → Interact:FireServer("Carry", tag)   扛起
--   放下   = MobileInteractTypes 里 Carrying → UncarryIcon = "Melee"，再按一次 Q
--   Revive = { Keybind = "Interact", KeybindName = "E", Length = "ReviveLength" } 长按 E
--   扛着时目标 Carried ≠ 0，Requirements.Carried = false → 必须先放下才能救
--
-- 两种模式：
--   rescue（救人）：扛起 → 随机 workspace.Map.ItemSpawns.ItemSpawn → 放下 → 长按 E 救
--   banish（放逐）：扛起 → 地图外的"虚空上方" → 放下（玩家掉进虚空）→ 自己撤回安全点
local rescueEnabled = false
local rescueMode = "rescue"        -- "rescue" / "banish"
local rescueVelocity = nil

local rescueState = "idle"         -- idle / approach / carryWait / toSafe / drop / revive / retreat
local rescueTarget = nil
local rescueStateSince = 0
local rescueCarryTries = 0
local rescueDropTries = 0
local rescueSafePoint = nil
local rescueTargetCooldown = {}
local rescueDownedSince = {}
local retreatPoint = nil

local rescueWaitSeconds = 0

local fastReviveEnabled = false
local fastReviveLength = 0.05
local originalReviveLength = nil

local rescueCFG = {
    HoverHeight = 3,
    FlySpeed = 2500,
    ArriveDist = 5,
    CarryRange = 7,
    BanishOffset = 150,       -- 地图边界外扩（虚空方向）
    BanishHeight = 6,         -- 站在"虚空上方"的高度
    CarryTimeout = 2.0,
    ToSafeTimeout = 7.0,
    DropTimeout = 2.0,
    ReviveTimeout = 10.0,
    RetreatTimeout = 7.0,
    StateInterval = 0.05,
    MaxDistance = 3000,
}

local interactionService = nil

local function getInteractionService()
    if interactionService then return interactionService end
    local services = ReplicatedStorage:FindFirstChild("Services")
    local asset = services and services:FindFirstChild("Asset")
    local mod = asset and asset:FindFirstChild("InteractionService")
    if not mod then return nil end
    local ok, res = pcall(require, mod)
    if ok and type(res) == "table" then
        interactionService = res
        return res
    end
    return nil
end

local function setLocalReviveLength(value)
    local char = lanternLocalCharacter()
    if not char or not char.DataRegistry then return false end
    if originalReviveLength == nil then
        local ok0, cur = pcall(function() return char.DataRegistry:Get("ReviveLength") end)
        if ok0 then originalReviveLength = cur end
    end
    return (pcall(function() char.DataRegistry:Set("ReviveLength", value) end))
end

local function restoreReviveLength()
    if originalReviveLength == nil then return end
    local char = lanternLocalCharacter()
    if not char or not char.DataRegistry then return end
    pcall(function() char.DataRegistry:Set("ReviveLength", originalReviveLength) end)
end

-- 按键：先真按一次，0.15s 后再补一次游戏交互入口（Carry 有 1s 冷却，不会重复触发）
local function pressKeyVirtual(keyCode)
    if not keyCode then return end
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function pressKeybind(keybind, keyCode)
    pressKeyVirtual(keyCode)
    task.delay(0.15, function()
        local svc = getInteractionService()
        if svc then
            pcall(function() svc:KeyUsed({ Key = keybind, Keybind = keybind, Down = true }) end)
        end
    end)
end

local eHeld = false
local function holdE()
    if not eHeld then
        eHeld = true
        pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
    end
    local svc = getInteractionService()
    if svc then
        pcall(function() svc:KeyUsed({ Key = "Interact", Keybind = "Interact", Down = true }) end)
    end
end

local function releaseE()
    if eHeld then
        eHeld = false
        pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
    end
end

local function isPlayerDowned(model)
    if not model or not model.Parent then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health <= 0
end

local function isMyCarrying()
    local char = lanternLocalCharacter()
    if not char or not char.DataRegistry then return false end
    local ok, v = pcall(function() return char.DataRegistry:Get("Carrying") end)
    if not ok then return false end
    return v ~= nil and v ~= 0
end

local function isTargetCarried(model)
    local svc = lanternCharService()
    if not svc or not model then return false end
    local tag = model:GetAttribute("Tag")
    if tag == nil then return false end
    local ok, targetChar = pcall(function() return svc:GetCharacterFromTag(tag) end)
    if not ok or not targetChar or not targetChar.DataRegistry then return false end
    local ok2, v = pcall(function() return targetChar.DataRegistry:Get("Carried") end)
    if not ok2 then return false end
    return v ~= nil and v ~= 0
end

local function findDownedPlayer()
    local container = workspace:FindFirstChild("Players")
    if not container then return nil end
    local best, bestDist = nil, math.huge
    local myChar = player.Character
    local myRoot = myChar and getRoot(myChar)
    for _, model in ipairs(container:GetChildren()) do
        if model:IsA("Model") and model ~= myChar and model:GetAttribute("Team") == "PlayerTeam" then
            if isPlayerDowned(model) then
                local root = getRoot(model)
                if root then
                    local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
                    if dist <= rescueCFG.MaxDistance and dist < bestDist then
                        best, bestDist = model, dist
                    end
                end
            end
        end
    end
    return best
end

-- ===== 地图信息（算虚空点用）=====
local mapInfoCache = nil
local mapInfoAt = 0

local function getMapInfo()
    local now = tick()
    if mapInfoCache and now - mapInfoAt < 20 then return mapInfoCache end

    local info = { minX = nil, maxX = nil, minZ = nil, maxZ = nil, groundY = 0 }
    local ys = {}
    local rootFolder = workspace:FindFirstChild("Map") or workspace

    for _, obj in ipairs(rootFolder:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Anchored then
            local p = obj.Position
            local s = obj.Size
            if s.X < 600 and s.Z < 600 and s.Y < 600 then
                info.minX = math.min(info.minX or p.X, p.X)
                info.maxX = math.max(info.maxX or p.X, p.X)
                info.minZ = math.min(info.minZ or p.Z, p.Z)
                info.maxZ = math.max(info.maxZ or p.Z, p.Z)
                if #ys < 4000 then
                    table.insert(ys, p.Y)
                end
            end
        end
    end

    if not info.minX then
        local char = player.Character
        local r = char and getRoot(char)
        local base = r and r.Position or Vector3.new(0, 0, 0)
        info.minX, info.maxX = base.X - 500, base.X + 500
        info.minZ, info.maxZ = base.Z - 500, base.Z + 500
        info.groundY = base.Y
    else
        info.groundY = (median(ys) or 0)
    end

    mapInfoCache = info
    mapInfoAt = now
    return info
end

-- 虚空上方：地图边界外，无地板的空中，自己飞着不掉
local function computeBanishPoint()
    local info = getMapInfo()
    local cx = (info.minX + info.maxX) / 2
    local cz = (info.minZ + info.maxZ) / 2
    local x = info.maxX + rescueCFG.BanishOffset
    return Vector3.new(x, info.groundY + rescueCFG.BanishHeight, cz)
end

-- 救人落点：跟"自动躲避 Nextbot"一样，随机 ItemSpawn
local function randomItemSpawnPos(widthOffset)
    local list = getItemSpawnPoints()
    if #list == 0 then return nil end
    local pick = list[math.random(1, #list)]
    return pick.Position + Vector3.new(0, widthOffset or (rescueCFG.HoverHeight + 2), 0)
end

local function getRescueVelocity(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    if not rescueVelocity or rescueVelocity.Parent ~= root then
        if rescueVelocity then pcall(function() rescueVelocity:Destroy() end) end
        rescueVelocity = Instance.new("BodyVelocity")
        rescueVelocity.Name = "RescueVelocity"
        rescueVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        rescueVelocity.Velocity = Vector3.new(0, 0, 0)
        rescueVelocity.Parent = root
    end
    return rescueVelocity
end

local function destroyRescueVelocity()
    if rescueVelocity then
        pcall(function() rescueVelocity:Destroy() end)
        rescueVelocity = nil
    end
end

local function stopRescueVelocity()
    local char = player.Character
    if not char then return end
    local bv = getRescueVelocity(char)
    if bv then bv.Velocity = Vector3.new(0, 0, 0) end
end

local function flyTo(pos, stopDist)
    local char = player.Character
    if not char then return false, math.huge end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false, math.huge end

    local diff = pos - myRoot.Position
    local dist = diff.Magnitude
    local bv = getRescueVelocity(char)
    if bv then
        if dist > stopDist then
            bv.Velocity = diff.Unit * math.min(rescueCFG.FlySpeed, dist / rescueCFG.StateInterval)
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    end
    return dist <= stopDist, dist
end

local function setState(s)
    rescueState = s
    rescueStateSince = tick()
    print("[自动救] 状态 →", s)
end

local function stopRescue()
    rescueEnabled = false
    rescueTarget = nil
    rescueSafePoint = nil
    retreatPoint = nil
    rescueCarryTries = 0
    rescueDropTries = 0
    releaseE()
    destroyRescueVelocity()
    rescueState = "idle"
    rescueStateSince = tick()
end

local function abandonTarget(seconds)
    if rescueTarget then
        rescueTargetCooldown[rescueTarget] = tick() + (seconds or 6)
    end
    rescueTarget = nil
    rescueSafePoint = nil
    retreatPoint = nil
    rescueCarryTries = 0
    rescueDropTries = 0
    releaseE()
    destroyRescueVelocity()
    setState("idle")
end

local function startApproach(model)
    rescueTarget = model
    rescueCarryTries = 0
    rescueDropTries = 0
    rescueSafePoint = nil
    retreatPoint = nil
    releaseE()
    setState("approach")
end

-- 目的地：救 = 随机 ItemSpawn；放逐 = 地图外虚空上方
local function pickDestination()
    if rescueMode == "banish" then
        return computeBanishPoint()
    end
    local pos = randomItemSpawnPos(rescueCFG.HoverHeight + 2)
    if pos then return pos end
    -- 没有 ItemSpawns 就退回地图中心上方
    local info = getMapInfo()
    return Vector3.new((info.minX + info.maxX) / 2, info.groundY + 40, (info.minZ + info.maxZ) / 2)
end

task.spawn(function()
    while true do
        task.wait(rescueCFG.StateInterval)

        if not rescueEnabled then
            if rescueState ~= "idle" then stopRescue() end
            continue
        end

        local now = tick()
        local myChar = player.Character
        if not myChar then continue end
        local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
        if myHumanoid and myHumanoid.Health <= 0 then
            if rescueState ~= "idle" then abandonTarget(0) end
            continue
        end

        -- ===== 优先级：有代币可捡就先捡代币 =====
        if toraCollectEnabled and hasTokens() then
            if rescueState ~= "idle" and rescueState ~= "revive" and rescueState ~= "drop" then
                if not isMyCarrying() then
                    print("[自动救] 检测到代币，救人让路（捡代币优先）")
                    rescueTarget = nil
                    rescueSafePoint = nil
                    retreatPoint = nil
                    releaseE()
                    destroyRescueVelocity()
                    setState("idle")
                end
            end
            continue
        end

        if rescueState == "idle" then
            local target = findDownedPlayer()
            if target and now >= (rescueTargetCooldown[target] or 0) then
                local since = rescueDownedSince[target]
                if not since then
                    rescueDownedSince[target] = now
                elseif now - since >= rescueWaitSeconds then
                    startApproach(target)
                end
            end

            for m in pairs(rescueTargetCooldown) do
                if not isPlayerDowned(m) then rescueTargetCooldown[m] = nil end
            end
            for m in pairs(rescueDownedSince) do
                if not isPlayerDowned(m) then rescueDownedSince[m] = nil end
            end
            continue
        end

        -- 目标已经起身：收工
        if not rescueTarget or not isPlayerDowned(rescueTarget) then
            if rescueState == "retreat" then
                -- 放逐完撤退中，继续飞回去
            else
                abandonTarget(2)
                continue
            end
        end

        local targetRoot = rescueTarget and getRoot(rescueTarget)
        if rescueState ~= "retreat" and (not targetRoot) then
            abandonTarget(3)
            continue
        end

        if rescueState == "approach" then
            local ok = flyTo(targetRoot.Position + Vector3.new(0, rescueCFG.HoverHeight, 0), rescueCFG.CarryRange - 1)
            if ok then
                stopRescueVelocity()
                pressKeybind("Melee", Enum.KeyCode.Q)
                rescueCarryTries = 1
                setState("carryWait")
            elseif now - rescueStateSince > 8 then
                abandonTarget(8)
            end
            continue
        end

        if rescueState == "carryWait" then
            if isMyCarrying() then
                rescueSafePoint = pickDestination()
                if rescueMode == "banish" then
                    print("[放逐] 已扛起，前往地图外虚空上方")
                else
                    print("[自动救] 已扛起，前往随机 ItemSpawn")
                end
                setState("toSafe")
            elseif now - rescueStateSince > rescueCFG.CarryTimeout then
                if rescueCarryTries < 3 then
                    rescueCarryTries = rescueCarryTries + 1
                    pressKeybind("Melee", Enum.KeyCode.Q)
                    rescueStateSince = now
                else
                    print("[自动救] 扛不起来（Q 无效），放弃这个目标")
                    abandonTarget(8)
                end
            end
            continue
        end

        if rescueState == "toSafe" then
            if not rescueSafePoint then
                rescueSafePoint = pickDestination()
            end

            local atDest = flyTo(rescueSafePoint, 5)
            if atDest or now - rescueStateSince > rescueCFG.ToSafeTimeout then
                stopRescueVelocity()
                rescueDropTries = 1
                pressKeybind("Melee", Enum.KeyCode.Q)
                if rescueMode == "banish" then
                    print("[放逐] 到虚空上方，丢下目标")
                else
                    print("[自动救] 到 ItemSpawn，放下")
                end
                setState("drop")
            end
            continue
        end

        if rescueState == "drop" then
            if not isMyCarrying() then
                if rescueMode == "banish" then
                    -- 丢进虚空后，自己立刻撤回安全点
                    retreatPoint = randomItemSpawnPos(20) or (getMapInfo() and Vector3.new(
                        (getMapInfo().minX + getMapInfo().maxX) / 2,
                        getMapInfo().groundY + 80,
                        (getMapInfo().minZ + getMapInfo().maxZ) / 2))
                    print("[放逐] 已丢下，撤回安全点")
                    setState("retreat")
                else
                    print("[自动救] 已放下，开始长按 E")
                    setState("revive")
                end
            elseif now - rescueStateSince > rescueCFG.DropTimeout then
                if rescueDropTries < 3 then
                    rescueDropTries = rescueDropTries + 1
                    pressKeybind("Melee", Enum.KeyCode.Q)
                    rescueStateSince = now
                else
                    print("[自动救] 放不下，直接尝试救人")
                    setState("revive")
                end
            end
            continue
        end

        if rescueState == "retreat" then
            if not retreatPoint then
                retreatPoint = randomItemSpawnPos(20)
                if not retreatPoint then
                    abandonTarget(2)
                    continue
                end
            end
            local reached = flyTo(retreatPoint, 6)
            if reached or now - rescueStateSince > rescueCFG.RetreatTimeout then
                stopRescueVelocity()
                print("[放逐] 已回到安全区")
                abandonTarget(2)
            end
            continue
        end

        if rescueState == "revive" then
            local nearOk = flyTo(targetRoot.Position + Vector3.new(0, rescueCFG.HoverHeight, 0), rescueCFG.CarryRange - 2)
            if nearOk then
                stopRescueVelocity()
                holdE()
            else
                releaseE()
            end

            if now - rescueStateSince > rescueCFG.ReviveTimeout then
                print("[自动救] 救人超时，换下一个")
                abandonTarget(6)
            end
            continue
        end
    end
end)

-- 目标被救起来就立刻收工
task.spawn(function()
    while true do
        task.wait(0.2)
        if rescueTarget and rescueState ~= "retreat" and not isPlayerDowned(rescueTarget) then
            print("[自动救] 目标已起身，收工")
            releaseE()
            rescueTargetCooldown[rescueTarget] = tick() + 2
            rescueTarget = nil
            rescueSafePoint = nil
            destroyRescueVelocity()
            if rescueState ~= "idle" then setState("idle") end
        end
    end
end)
-- ==================== 救人 / 放逐 结束 ====================

local boomboxEnabled = false
local bbCurrent = nil
local bbSongId = 1840041514
local bbVolume = 1
local bbPlaying = true

local bbSongs = {
    {"Getting Higher", 1840041514},
    {"Christmas Rock", 1839286325},
    {"21st Century", 1837367459},
    {"Clap", 1843663202},
    {"Moon King", 1842514702},
    {"Pull Over", 1839983980},
    {"Watcha Don", 1837908256},
    {"Jingle Bells", 1839286187},
    {"Funky Agent", 1839322710},
    {"Teach Me", 1836515657},
}

local bbSkin = nil
pcall(function()
    bbSkin = ReplicatedStorage.Items.BaseItems.Boomboxes.Boombox
end)

local function bbFindSound()
    local holders = {player.Character, workspace:FindFirstChild("Players")}
    for _, h in ipairs(holders) do
        if h then
            for _, d in ipairs(h:GetDescendants()) do
                if d:IsA("Sound") and d.Name == "LocalMusic" then return d end
            end
        end
    end
    return nil
end

local function bbApplySong(id)
    bbSongId = id
    local s = bbFindSound()
    if s then
        s.SoundId = "rbxassetid://" .. id
        if bbPlaying then s:Play() end
    end
end

local function bbSetVolume(v)
    bbVolume = v / 100
    local s = bbFindSound()
    if s then s.Volume = bbVolume end
end

local function bbFindPart(model)
    for _, d in ipairs(model:GetDescendants()) do
        if d.Name == "Boombox" and d:IsA("BasePart") then return d end
    end
    return nil
end

local function bbFindWeld(model)
    for _, d in ipairs(model:GetDescendants()) do
        if d.Name == "Boombox" and d:IsA("Weld") then return d end
    end
    return nil
end

local function bbGetModel()
    local pf = workspace:FindFirstChild("Players")
    if not pf then return nil end
    local fb = nil
    for _, m in ipairs(pf:GetChildren()) do
        if m:IsA("Model") then
            if m.Name == player.Name then return m end
            if not fb and m:GetAttribute("Team") == "PlayerTeam" then fb = m end
        end
    end
    return fb
end

local function bbFindAnchor(model)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and d.Name == "UpperTorso" then return d end
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and d.Name == "Torso" then return d end
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and d.Name == "HumanoidRootPart" then return d end
    end
    return nil
end

local function bbDestroy()
    if bbCurrent and bbCurrent.bb and bbCurrent.bb.Parent then
        pcall(function() bbCurrent.bb:Destroy() end)
    end
    bbCurrent = nil
end

local function bbBuild()
    if not bbSkin then return end
    local model = bbGetModel()
    local anchor = model and bbFindAnchor(model)
    if not model or not anchor then return end

    if bbCurrent and bbCurrent.bb and bbCurrent.bb.Parent and bbCurrent.anchor == anchor then
        return
    end

    local templateName = (anchor.Name == "Torso") and "CharacterClassic" or "Character"
    local template = bbSkin:FindFirstChild(templateName)
    if not template then return end
    local bbT = bbFindPart(template)
    if not bbT then return end

    bbDestroy()

    local bb = bbT:Clone()
    bb.Name = "LocalBoombox"
    bb.Anchored = false
    bb.CanCollide = false
    bb.Massless = true
    for _, c in ipairs(bb:GetChildren()) do
        if c:IsA("JointInstance") then c:Destroy() end
    end

    local weldT = bbFindWeld(template)
    local rel = weldT and (weldT.C0 * weldT.C1:Inverse()) or CFrame.new(0, 0, -1.2)
    bb.CFrame = anchor.CFrame * rel
    bb.Parent = model

    for _, d in ipairs(model:GetDescendants()) do
        if d.Name == "LocalBoombox" and d ~= bb then
            pcall(function() d:Destroy() end)
        end
    end

    local w = Instance.new("Weld")
    w.Part0 = anchor
    w.Part1 = bb
    w.C0 = rel
    w.C1 = CFrame.new()
    w.Parent = bb

    local s = Instance.new("Sound")
    s.Name = "LocalMusic"
    s.SoundId = "rbxassetid://" .. bbSongId
    s.Volume = bbVolume
    s.Looped = true
    s.Parent = bb
    if bbPlaying then s:Play() end

    bbCurrent = {bb = bb, anchor = anchor}
end

task.spawn(function()
    while true do
        task.wait(1)
        if not boomboxEnabled then continue end
        pcall(bbBuild)
    end
end)

local Tab = Window:Tab({
    Title = "功能",
    Icon = "sparkles",
    Locked = false,
})
Window:SelectTab(1)

local espSection = Tab:Section({
    Title = "ESP",
    IconName = "eye"
})

espSection:Toggle({
    Title = "玩家方框",
    Value = false,
    Callback = function(state)
        ESP.Players = state
    end
})

espSection:Toggle({
    Title = "怪物方框",
    Value = false,
    Callback = function(state)
        ESP.Monsters = state
    end
})

espSection:Toggle({
    Title = "显示自己",
    Value = false,
    Callback = function(state)
        ESP.Self = state
    end
})

espSection:Slider({
    Title = "最大距离",
    Value = {
        Min = 100,
        Max = 5000,
        Default = 2500,
    },
    Callback = function(value)
        ESP.MaxDistance = value
    end
})

local moveSection = Tab:Section({
    Title = "移动",
    IconName = "zap"
})

moveSection:Toggle({
    Title = "自动跳跃",
    Value = false,
    Callback = function(state)
        autoJumpEnabled = state
    end
})

moveSection:Slider({
    Title = "移动速度",
    Value = {
        Min = 1,
        Max = 10000,
        Default = 2000,
    },
    Callback = function(value)
        applySpeed(value)
    end
})

moveSection:Slider({
    Title = "跳跃高度",
    Value = {
        Min = 0,
        Max = 100,
        Default = 7,
    },
    Callback = function(value)
        jumpValue = value
    end
})

local reviveSection = Tab:Section({
    Title = "复活",
    IconName = "heart"
})

reviveSection:Toggle({
    Title = "自动复活",
    Desc = "死亡 / 回到大厅后自动重新进局（无限复活）",
    Value = false,
    Callback = function(state)
        autoRevive = state
        if state then
            enterRound()
        end
    end
})

local rescueSection = Tab:Section({
    Title = "救人",
    IconName = "hand-heart"
})

local rescueToggle, banishToggle

rescueToggle = rescueSection:Toggle({
    Title = "自动救（送到 ItemSpawn 救）",
    Desc = "扛起倒地队友 → 随机 ItemSpawn → 放下 → 长按 E 救起",
    Value = false,
    Callback = function(state)
        if state then
            rescueMode = "rescue"
            rescueEnabled = true
            if banishToggle then pcall(function() banishToggle:Set(false) end) end
        else
            if rescueMode == "rescue" then stopRescue() end
        end
    end
})

banishToggle = rescueSection:Toggle({
    Title = "放逐（丢进虚空）",
    Desc = "扛起后飞到地图外的虚空上方 → 丢下 → 自己撤回安全点",
    Value = false,
    Callback = function(state)
        if state then
            rescueMode = "banish"
            rescueEnabled = true
            if rescueToggle then pcall(function() rescueToggle:Set(false) end) end
        else
            if rescueMode == "banish" then stopRescue() end
        end
    end
})

rescueSection:Toggle({
    Title = "快速读条",
    Desc = "把本地 ReviveLength 压到 0.05 秒（服务端可能不认，默认关闭）",
    Value = false,
    Callback = function(state)
        fastReviveEnabled = state
        if state then
            setLocalReviveLength(fastReviveLength)
        else
            restoreReviveLength()
        end
    end
})

rescueSection:Slider({
    Title = "倒地等待(秒)",
    Value = {
        Min = 0,
        Max = 20,
        Default = 0,
    },
    Callback = function(value)
        rescueWaitSeconds = value
    end
})

rescueSection:Slider({
    Title = "放逐外扩距离",
    Value = {
        Min = 30,
        Max = 400,
        Default = 150,
    },
    Callback = function(value)
        rescueCFG.BanishOffset = value
    end
})

local farmSection = Tab:Section({
    Title = "农场",
    IconName = "home"
})

local toraCollectToggle
local platformToggle

toraCollectToggle = farmSection:Toggle({
    Title = "自动收集（代币优先）",
    Desc = "瞬移到 workspace.Effects.Tickets 收集；开着时救人会让路",
    Value = false,
    Callback = function(state)
        toraCollectEnabled = state
        if state then
            if platformEnabled and platformToggle then
                pcall(function() platformToggle:Set(false) end)
            end
            WindUI:Notify({
                Title = "自动收集",
                Content = "已开启（捡代币优先级高于救人）",
                Duration = 2
            })
        end
    end
})

farmSection:Toggle({
    Title = "自动躲避 Nextbot",
    Desc = "检测范围内 AI 怪物，靠近时随机传送到 ItemSpawn",
    Value = false,
    Callback = function(state)
        avoidEnabled = state
        if state then
            WindUI:Notify({
                Title = "自动躲避",
                Content = "已开启：靠近怪物自动跳到刷新点",
                Duration = 2
            })
        end
    end
})

farmSection:Slider({
    Title = "躲避检测距离",
    Value = {
        Min = 10,
        Max = 100,
        Default = 30,
    },
    Callback = function(value)
        avoidDistance = value
    end
})

platformToggle = farmSection:Toggle({
    Title = "高空平台",
    Value = false,
    Callback = function(state)
        platformEnabled = state
        if state then
            if toraCollectEnabled and toraCollectToggle then
                pcall(function() toraCollectToggle:Set(false) end)
            end
            rescanCenter()
        else
            destroyPlatform()
        end
    end
})

farmSection:Slider({
    Title = "平台高度",
    Value = {
        Min = 100,
        Max = 2000,
        Default = 400,
    },
    Callback = function(value)
        platformHeight = value
        if platform then
            buildPlatform()
        end
    end
})

farmSection:Button({
    Title = "传送至平台",
    Callback = function()
        teleportToPlatform()
    end
})

local utilSection = Tab:Section({
    Title = "实用",
    IconName = "wrench"
})

utilSection:Toggle({
    Title = "自动装备灯笼",
    Desc = "真实装备（ToolProfile + Equipped），需灯笼在装备栏内",
    Value = false,
    Callback = function(state)
        autoEquipLantern = state
        if state then
            local ok, res = pcall(equipLanternReal, true)
            if not ok then
                lanternNotify("调用出错，详见控制台", true)
            elseif res == "not_in_loadout" then
                lanternNotify("本局装备栏没有灯笼（菜单里要带 Lantern）", true)
                applyCosmeticLantern()
            elseif res == "not_ready" then
                lanternNotify("工具列表还没同步，稍后自动重试", true)
            elseif res == "no_char" then
                lanternNotify("还没进对局，进图后自动装备", true)
            elseif res == "no_profile" then
                lanternNotify("角色工具档案未就绪", true)
            elseif res == "failed" then
                lanternNotify("自动切换失败，试试手动按 F / 1-9", true)
            elseif type(res) == "string" and (res == "already" or res:sub(1, 9) == "equipped:") then
                lanternNotify("已装备灯笼", true)
            end
        else
            removeCosmeticLantern()
        end
    end
})

utilSection:Button({
    Title = "手动装备灯笼",
    Callback = function()
        local ok, res = pcall(equipLanternReal, true)
        if not ok then
            lanternNotify("调用出错，详见控制台", true)
        elseif res == "not_in_loadout" then
            lanternNotify("装备栏里没有 Lantern（检查菜单里是否带了灯笼）", true)
        elseif res == "no_char" or res == "no_profile" then
            lanternNotify("角色还没加载好", true)
        elseif res == "not_ready" then
            lanternNotify("工具列表还没同步", true)
        elseif res == "failed" then
            lanternNotify("切换失败，试试手动按 F / 1-9", true)
        else
            lanternNotify("已切换到灯笼", true)
        end
    end
})

utilSection:Button({
    Title = "灯笼诊断（看控制台）",
    Callback = function()
        local text = lanternDiag()
        local short = text:gsub("\n", " | ")
        lanternNotify(short:sub(1, 110), true)
    end
})

utilSection:Button({
    Title = "还原读条",
    Desc = "把本地 ReviveLength 恢复成游戏原值",
    Callback = function()
        restoreReviveLength()
        WindUI:Notify({ Title = "救人", Content = "已还原本地读条长度", Duration = 2 })
    end
})

utilSection:Button({
    Title = "救人 / 放逐状态诊断",
    Desc = "打印状态、扛人情况、目标点、代币到控制台",
    Callback = function()
        local lines = { "===== 救人状态 =====" }
        lines[#lines + 1] = "模式: " .. tostring(rescueMode) .. " / 状态: " .. tostring(rescueState)
        lines[#lines + 1] = "目标: " .. (rescueTarget and tostring(rescueTarget.Name) or "nil")
        lines[#lines + 1] = "我扛着人: " .. tostring(isMyCarrying())
        if rescueTarget then
            lines[#lines + 1] = "目标被扛: " .. tostring(isTargetCarried(rescueTarget))
            lines[#lines + 1] = "目标倒地: " .. tostring(isPlayerDowned(rescueTarget))
        end
        lines[#lines + 1] = "有代币可捡: " .. tostring(hasTokens())
        lines[#lines + 1] = "目的地: " .. (rescueSafePoint and tostring(rescueSafePoint) or "nil")
        local itemCount = #getItemSpawnPoints()
        lines[#lines + 1] = "ItemSpawn 数量: " .. tostring(itemCount)
        local info = getMapInfo()
        lines[#lines + 1] = string.format("地图边界 X[%.0f,%.0f] Z[%.0f,%.0f] 地面Y=%.0f",
            info.minX, info.maxX, info.minZ, info.maxZ, info.groundY)
        local text = table.concat(lines, "\n")
        print(text)
        WindUI:Notify({ Title = "救人状态", Content = (text:gsub("\n", " | ")):sub(1, 120), Duration = 4 })
    end
})

local musicSection = Tab:Section({
    Title = "音箱",
    IconName = "music"
})

musicSection:Toggle({
    Title = "挂载音箱",
    Value = false,
    Callback = function(state)
        boomboxEnabled = state
        if not state then
            bbDestroy()
        end
    end
})

for _, v in ipairs(bbSongs) do
    musicSection:Button({
        Title = v[1],
        Desc = tostring(v[2]),
        Callback = function()
            bbApplySong(v[2])
            WindUI:Notify({
                Title = "正在播放",
                Content = v[1],
                Duration = 2
            })
        end
    })
end

musicSection:Slider({
    Title = "音量",
    Value = {
        Min = 0,
        Max = 100,
        Default = 100,
    },
    Callback = function(value)
        bbSetVolume(value)
    end
})

musicSection:Toggle({
    Title = "播放中",
    Value = true,
    Callback = function(state)
        bbPlaying = state
        local s = bbFindSound()
        if s then
            if state then
                s:Play()
            else
                s:Pause()
            end
        end
    end
})

musicSection:Button({
    Title = "停止",
    Callback = function()
        local s = bbFindSound()
        if s then s:Stop() end
    end
})

local customId = nil
musicSection:Input({
    Title = "自定义ID",
    Placeholder = "输入歌曲ID",
    Callback = function(v)
        customId = tonumber(v)
    end
})

musicSection:Button({
    Title = "播放自定义",
    Callback = function()
        if customId and customId > 0 then
            bbApplySong(customId)
            WindUI:Notify({
                Title = "正在播放",
                Content = "ID " .. tostring(customId),
                Duration = 2
            })
        end
    end
})

-- ==================== UI 优先级提升（增强版） ====================
do
    local CoreGui   = game:GetService("CoreGui")
    local PlayerGui = player:FindFirstChildOfClass("PlayerGui")

    local function getHiddenGui()
        local g = getgenv and getgenv() or _G
        local candidates = {
            g.gethui, g.get_hidden_gui, gethui, get_hidden_gui,
        }
        for _, f in ipairs(candidates) do
            if type(f) == "function" then
                local ok, r = pcall(f)
                if ok and r then return r end
            end
        end
        return CoreGui
    end

    local function protectGui(gui)
        local g = getgenv and getgenv() or _G
        local candidates = {
            (type(syn) == "table" and syn.protect_gui) or nil,
            g.protect_gui, protect_gui,
        }
        for _, f in ipairs(candidates) do
            if type(f) == "function" then
                local ok = pcall(f, gui)
                if ok then return true end
            end
        end
        return false
    end

    local function elevate(sg)
        if not sg or not sg:IsA("ScreenGui") then return end
        pcall(function()
            sg.DisplayOrder     = 2147483647
            sg.IgnoreGuiInset   = true
            sg.ResetOnSpawn     = false
            sg.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
            sg.Enabled          = true
        end)
        protectGui(sg)
        local hidden = getHiddenGui()
        if hidden and sg.Parent ~= hidden then
            pcall(function() sg.Parent = hidden end)
        end
    end

    local function windowGui()
        local mf = Window and Window.UIElements and Window.UIElements.Main
        if not mf then return nil end
        local cur = mf
        while cur and not cur:IsA("ScreenGui") do
            cur = cur.Parent
        end
        return cur
    end

    local function collectGuis()
        local list, seen = {}, {}
        local wg = windowGui()
        if wg then list[#list+1] = wg; seen[wg] = true end

        local containers = { PlayerGui, CoreGui, getHiddenGui() }
        for _, c in ipairs(containers) do
            if c then
                pcall(function()
                    for _, obj in ipairs(c:GetChildren()) do
                        if obj:IsA("ScreenGui") and not seen[obj] then
                            if obj == wg or obj:FindFirstChild("OpenButton", true) then
                                seen[obj] = true
                                list[#list+1] = obj
                            end
                        end
                    end
                end)
            end
        end
        return list
    end

    local function apply()
        for _, sg in ipairs(collectGuis()) do
            elevate(sg)
        end
    end

    task.defer(function()
        task.wait(0.3)
        apply()
    end)

    local lastCheck = 0
    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastCheck < 1 then return end
        lastCheck = now
        pcall(apply)
    end)

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        pcall(apply)
    end)
end
-- ==================== UI 优先级提升（增强版）结束 ====================
