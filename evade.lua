local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
    Background = "https://chaton-images.s3.us-east-2.amazonaws.com/alHcHts2JjSlmMRKjQeDXFipKS5LjNhrKrkN8TxbH7HgPmXA1QbuEYZh3Hwnb9F5_1536x1024x1945789.png", -- 背景视频
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
    Title = "V1.04",
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
            ColorSequenceKeypoint.new(
                0,
                Color3.fromHex("2E1065")
            ),
            ColorSequenceKeypoint.new(
                0.3,
                Color3.fromHex("4C1D95")
            ),
            ColorSequenceKeypoint.new(
                0.6,
                Color3.fromHex("7C3AED")
            ),
            ColorSequenceKeypoint.new(
                1,
                Color3.fromHex("C084FC")
            )
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

local autoRevive = false
local downedSince = nil
local fired = false
local retryCount = 0
local lastFireTime = 0

local function enterRound()
    pcall(function()
        local UI = ReplicatedStorage.Services.UI
        local ev = ReplicatedStorage.Events.SetPlayerMode
        ev:FireServer(UI.GameUIService)
    end)
end

local function isDowned()
    local char = player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health <= 0
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if not autoRevive then
            downedSince = nil
            fired = false
            retryCount = 0
            continue
        end
        local downed = isDowned()
        if not downed then
            downedSince = nil
            fired = false
            retryCount = 0
            continue
        end
        if downedSince == nil then
            downedSince = tick()
            continue
        end
        local now = tick()
        if not fired and (now - downedSince) < 1.5 then continue end
        if not fired then
            enterRound()
            fired = true
            retryCount = 1
            lastFireTime = now
            continue
        end
        if retryCount >= 6 then
            if now - lastFireTime > 30 then
                enterRound()
                lastFireTime = now
                retryCount = 1
            end
            continue
        end
        if now - lastFireTime >= 8 then
            retryCount = retryCount + 1
            enterRound()
            lastFireTime = now
        end
    end
end)

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

local rescueEnabled = false
local rescueCurrentTarget = nil
local rescueSelfDowned = false
local rescueVelocity = nil
local rescueKeyHeld = false

-- 倒地后等待多久再飞过去救（秒）
local rescueWaitSeconds = 7
-- 记录每个倒地玩家首次被发现的时间：{ [model] = tick() }
local rescueDownedSince = {}

-- 秒救配置
local instantRescue = false          -- 秒救开关
local instantRescueBurst = 40        -- 抵达瞬间爆发的 E 键次数
local instantBurstRemaining = 0      -- 剩余爆发次数
local lastBurstTarget = nil          -- 上次爆发所针对的目标（避免重复爆发）

local rescueCFG = {
    HoverHeight = 3,
    FlySpeed = 2500,
    ArriveDist = 3,
    HoldDistance = 15,
    PressE = true,
    PressInterval = 0.01,
    TargetSwitchDelay = 1.5,
    MaxDistance = 3000,
    UpdateInterval = 0.02,
}

local function isPlayerDowned(model)
    if not model or not model.Parent then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health <= 0
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

local function rescueRestoreMove()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = jumpValue * 98.1
        end
    end
    destroyRescueVelocity()
end

local function rescueHoldKey()
    if not rescueKeyHeld then
        rescueKeyHeld = true
        pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
    end
end

local function rescueReleaseKey()
    if rescueKeyHeld then
        rescueKeyHeld = false
        pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
    end
end

local function handleSelfDowned()
    rescueSelfDowned = true
    rescueReleaseKey()
    rescueCurrentTarget = nil
    rescueRestoreMove()
    instantBurstRemaining = 0
    lastBurstTarget = nil
end

task.spawn(function()
    while true do
        task.wait(rescueCFG.UpdateInterval)

        if not rescueEnabled then
            rescueReleaseKey()
            rescueCurrentTarget = nil
            destroyRescueVelocity()
            instantBurstRemaining = 0
            lastBurstTarget = nil
            if next(rescueDownedSince) then
                for k in pairs(rescueDownedSince) do rescueDownedSince[k] = nil end
            end
            continue
        end

        -- 清理已不再倒地或已不存在的记录，防止表无限增长
        for m in pairs(rescueDownedSince) do
            if not isPlayerDowned(m) then
                rescueDownedSince[m] = nil
            end
        end

        local myChar = player.Character
        if not myChar then continue end
        local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")

        if myHumanoid and myHumanoid.Health <= 0 then
            handleSelfDowned()
            continue
        end

        if rescueSelfDowned and myHumanoid and myHumanoid.Health > 0 then
            rescueSelfDowned = false
        end

        if rescueCurrentTarget and not isPlayerDowned(rescueCurrentTarget) then
            rescueReleaseKey()
            rescueCurrentTarget = nil
            destroyRescueVelocity()
            instantBurstRemaining = 0
            lastBurstTarget = nil
            task.wait(rescueCFG.TargetSwitchDelay)
            continue
        end

        if not rescueCurrentTarget then
            rescueCurrentTarget = findDownedPlayer()
        end

        if not rescueCurrentTarget then
            rescueReleaseKey()
            destroyRescueVelocity()
            instantBurstRemaining = 0
            lastBurstTarget = nil
            continue
        end

        local targetRoot = getRoot(rescueCurrentTarget)
        if not targetRoot then
            rescueCurrentTarget = nil
            continue
        end

        -- 倒地等待：发现有人倒地后先原地等 rescueWaitSeconds 秒，
        -- 避免怪物还在倒地玩家附近时飞过去被怪物锁定
        local since = rescueDownedSince[rescueCurrentTarget]
        if not since then
            rescueDownedSince[rescueCurrentTarget] = tick()
            since = rescueDownedSince[rescueCurrentTarget]
        end
        local elapsed = tick() - since
        if elapsed < rescueWaitSeconds then
            rescueReleaseKey()
            destroyRescueVelocity()
            continue
        end

        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        local targetPos = targetRoot.Position + Vector3.new(0, rescueCFG.HoverHeight, 0)
        local diff = targetPos - myRoot.Position
        local dist = diff.Magnitude

        local bv = getRescueVelocity(myChar)
        if bv then
            if dist > rescueCFG.ArriveDist then
                local speed = rescueCFG.FlySpeed
                local maxStep = dist / math.max(rescueCFG.UpdateInterval, 0.01)
                speed = math.min(speed, maxStep)
                bv.Velocity = diff.Unit * speed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end

        if dist < rescueCFG.HoldDistance then
            if rescueCFG.PressE then rescueHoldKey() end
            -- 秒救：抵达 HoldDistance 内的瞬间触发一次爆发
            if instantRescue and lastBurstTarget ~= rescueCurrentTarget then
                lastBurstTarget = rescueCurrentTarget
                instantBurstRemaining = instantRescueBurst
            end
        else
            rescueReleaseKey()
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(rescueCFG.PressInterval)
        if not rescueEnabled or rescueSelfDowned then
            rescueReleaseKey()
            continue
        end

        -- 秒救爆发：一次性把剩余次数在极短时间连发出去
        if instantRescue and instantBurstRemaining > 0 then
            local n = math.min(instantBurstRemaining, 8)
            for _ = 1, n do
                pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
                pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
            end
            instantBurstRemaining = instantBurstRemaining - n
        end

        if rescueKeyHeld then
            pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
            task.wait(0.01)
            pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
        end
    end
end)

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
    Value = false,
    Callback = function(state)
        autoRevive = state
    end
})

local rescueSection = Tab:Section({
    Title = "复活",
    IconName = "hand-heart"
})

rescueSection:Toggle({
    Title = "自动救",
    Value = false,
    Callback = function(state)
        rescueEnabled = state
        if not state then
            rescueReleaseKey()
            rescueCurrentTarget = nil
            rescueSelfDowned = false
            rescueRestoreMove()
            instantBurstRemaining = 0
            lastBurstTarget = nil
            if next(rescueDownedSince) then
                for k in pairs(rescueDownedSince) do rescueDownedSince[k] = nil end
            end
        end
    end
})

rescueSection:Toggle({
    Title = "秒救（到达即按E）",
    Desc = "抵达目标范围瞬间连发按键，把救援时间压到极限",
    Value = false,
    Callback = function(state)
        instantRescue = state
        -- 秒救时缩短到达距离、加快脉冲频率
        rescueCFG.ArriveDist = state and 2 or 3
        rescueCFG.PressInterval = state and 0.001 or 0.01
        if not state then
            instantBurstRemaining = 0
            lastBurstTarget = nil
        end
    end
})

rescueSection:Slider({
    Title = "倒地等待(秒)",
    Value = {
        Min = 0,
        Max = 20,
        Default = 7,
    },
    Callback = function(value)
        rescueWaitSeconds = value
    end
})

local farmSection = Tab:Section({
    Title = "农场",
    IconName = "home"
})

farmSection:Toggle({
    Title = "高空平台",
    Value = false,
    Callback = function(state)
        platformEnabled = state
        if state then
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
-- 目标：让 WindUI 的所有 ScreenGui 渲染在 Roblox ESC 菜单（CoreGui.RobloxGui）之上
-- 原理：
--   1. 用执行器特权 gethui()/get_hidden_gui() 拿到隐藏容器（其渲染层高于 RobloxGui）
--   2. syn.protect_gui / protect_gui 防止 GUI 被 Roblox 自动清理
--   3. DisplayOrder = 2147483647 + IgnoreGuiInset = true + ResetOnSpawn = false
--   4. 用 Heartbeat 每秒自检，防止 DisplayOrder/Parent 被系统重置
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
