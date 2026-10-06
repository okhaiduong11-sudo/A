local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local LANG = "vi"

local T = {
    vi = {
        title = "MENU KESTREL-7",
        tab_main = "Chính",
        tab_movement = "Di chuyển",
        tab_visual = "Hình ảnh",
        tab_misc = "Khác",
        speed = "Tốc độ đi",
        jump = "Lực nhảy",
        fly = "Bay",
        fly_speed = "Tốc độ bay",
        noclip = "Xuyên vật thể",
        inf_jump = "Nhảy vô hạn",
        fullbright = "Ánh sáng đầy",
        no_fog = "Không sương mù",
        esp = "Xuyên tường (ESP)",
        anti_afk = "Chống AFK",
        reset_char = "Hồi sinh nhân vật",
        rejoin = "Vào lại server",
        copied = "Đã copy!",
        lang_label = "Ngôn ngữ",
        minimize = "Thu nhỏ",
        close = "Đóng",
    },
    en = {
        title = "KESTREL-7 MENU",
        tab_main = "Main",
        tab_movement = "Movement",
        tab_visual = "Visual",
        tab_misc = "Misc",
        speed = "Walk Speed",
        jump = "Jump Power",
        fly = "Fly",
        fly_speed = "Fly Speed",
        noclip = "Noclip",
        inf_jump = "Infinite Jump",
        fullbright = "Full Bright",
        no_fog = "No Fog",
        esp = "Wallhack (ESP)",
        anti_afk = "Anti AFK",
        reset_char = "Reset Character",
        rejoin = "Rejoin Server",
        copied = "Copied!",
        lang_label = "Language",
        minimize = "Minimize",
        close = "Close",
    },
}

local COLORS = {
    bg        = Color3.fromRGB(20, 20, 26),
    panel     = Color3.fromRGB(28, 28, 36),
    panel2    = Color3.fromRGB(36, 36, 46),
    accent    = Color3.fromRGB(90, 130, 255),
    accent2   = Color3.fromRGB(140, 90, 255),
    text      = Color3.fromRGB(235, 235, 245),
    text_dim  = Color3.fromRGB(150, 150, 165),
    good      = Color3.fromRGB(80, 200, 120),
    bad       = Color3.fromRGB(220, 70, 70),
}

local state = {
    speed = false, speed_value = 16,
    jump = false, jump_value = 50,
    fly = false, fly_speed_value = 50,
    noclip = false,
    inf_jump = false,
    fullbright = false,
    no_fog = false,
    esp = false,
    anti_afk = false,
}

local orig = {
    fog_end = Lighting.FogEnd,
    ambient = Lighting.Ambient,
    outdoor = Lighting.OutdoorAmbient,
    bright = Lighting.Brightness,
    clock = Lighting.ClockTime,
}

local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function getHum()
    local c = LP.Character
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = LP.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

-- ==================== FEATURES ====================

local function applySpeed()
    local h = getHum()
    if h then h.WalkSpeed = state.speed and state.speed_value or 16 end
end

local function applyJump()
    local h = getHum()
    if h then
        if state.jump then
            h.UseJumpPower = true
            h.JumpPower = state.jump_value
        else
            h.UseJumpPower = true
            h.JumpPower = 50
        end
    end
end

RunService.Heartbeat:Connect(function()
    applySpeed()
    applyJump()

    if state.noclip then
        local c = LP.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end

    if state.fly then
        local root = getRoot()
        local h = getHum()
        if root and h then
            h.PlatformStand = true
            local cam = workspace.CurrentCamera
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
            if move.Magnitude > 0 then

                root.Velocity = move.Unit * state.fly       _speed_value
            else
                root.Velocity Lighting = Vector3.zero
            end
        end
    end.B

    if state.fullbright thenrightness = 3
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = orig.bright
        Lighting.ClockTime = orig.clock
        Lighting.Ambient = orig.ambient
        Lighting.OutdoorAmbient = orig.outdoor
    end

    if state.no_fog then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = orig.fog_end
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed()
    applyJump()
end)

UserInputService.JumpRequest:Connect(function()
    if state.inf_jump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local antiAfkConn
local function setAntiAfk(on)
    if on then
        antiAfkConn = LP.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    else
        if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
    end
end

local espFolder
local function clearESP()
    if espFolder then espFolder:Destroy(); espFolder = nil end
end

local function setESP(on)
    clearESP()
    if not on then return end
    espFolder = Instance.new("Folder")
    espFolder.Name = "KestrelESP"
    espFolder.Parent = CoreGui

    local function addHighlight(plr)
        if plr == LP then return end
        local char = plr.Character
        if not char then return end
        local hl = Instance.new("Highlight")
        hl.Name = plr.Name .. "_HL"
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(255, 60, 60)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.Parent = espFolder
    end

    for _, p in ipairs(Players:GetPlayers()) do addHighlight(p) end
    Players.PlayerAdded:Connect(addHighlight)
end

-- ==================== UI ====================

if CoreGui:FindFirstChild("KestrelMenu") then
    CoreGui.KestrelMenu:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "KestrelMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 480, 0, 320)
main.Position = UDim2.new(0.5, -240, 0.5, -160)
main.BackgroundColor3 = COLORS.bg
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local ms = Instance.new("UIStroke", main)
ms.Color = COLORS.accent
ms.Thickness = 1

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = COLORS.panel
topBar.BorderSizePixel = 0
topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = T[LANG].title
title.TextColor3 = COLORS.text
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 30, 0, 30)
btnMin.Position = UDim2.new(1, -72, 0, 5)
btnMin.BackgroundColor3 = COLORS.panel2
btnMin.Text = "−"
btnMin.TextColor3 = COLORS.text
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 18
btnMin.BorderSizePixel = 0
btnMin.Parent = topBar
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 8)

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -38, 0, 5)
btnClose.BackgroundColor3 = COLORS.bad
btnClose.Text = "✕"
btnClose.TextColor3 = COLORS.text
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 14
btnClose.BorderSizePixel = 0
btnClose.Parent = topBar
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 8)

-- drag
do
    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                       startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- tabs row
local tabRow = Instance.new("Frame")
tabRow.Size = UDim2.new(1, 0, 0, 36)
tabRow.Position = UDim2.new(0, 0, 0, 40)
tabRow.BackgroundColor3 = COLORS.panel2
tabRow.BorderSizePixel = 0
tabRow.Parent = main

local tabLayout = Instance.new("UIListLayout", tabRow)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 0)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -16, 1, -92)
content.Position = UDim2.new(0, 8, 0, 84)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}

local function makeTab(key)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.25, 0, 1, 0)
    b.BackgroundColor3 = COLORS.panel2
    b.Text = T[LANG][key]
    b.TextColor3 = COLORS.text_dim
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.Parent = tabRow
    return b
end

local function makePage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = COLORS.accent
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = content
    local lay = Instance.new("UIListLayout", p)
    lay.Padding = UDim.new(0, 6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    return p
end

local pageMain = makePage()
local pageMove = makePage()
local pageVis  = makePage()
local pageMisc = makePage()

pages = {pageMain, pageMove, pageVis, pageMisc}

local function selectPage(n)
    for i, p in ipairs(pages) do
        p.Visible = (i == n)
    end
end

local tabKeys = {"tab_main", "tab_movement", "tab_visual", "tab_misc"}
local tabs = {}
for i, k in ipairs(tabKeys) do
    local t = makeTab(k)
    tabs[i] = t
    t.MouseButton1Click:Connect(function() selectPage(i) end)
end
selectPage(1)

-- toggle widget
local function makeToggle(page, label, key)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 34)
    row.BackgroundColor3 = COLORS.panel
    row.BorderSizePixel = 0
    row.Parent = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COLORS.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 46, 0, 22)
    btn.Position = UDim2.new(1, -58, 0.5, -11)
    btn.BackgroundColor3 = COLORS.panel2
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = COLORS.text_dim
    knob.BorderSizePixel = 0
    knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 9)

    local function refresh()
        local on = state[key]
        btn.BackgroundColor3 = on and COLORS.accent or COLORS.panel2
        knob.BackgroundColor3 = on and COLORS.text or COLORS.text_dim
        knob.Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    end

    btn.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        if key == "anti_afk" then setAntiAfk(state.anti_afk) end
        if key == "esp" then setESP(state.esp) end
        if key == "fly" then
            local h = getHum()
            if h and not state.fly then h.PlatformStand = false end
        end
        refresh()
    end)
    refresh()
    return row
end

-- slider widget
local function makeSlider(page, label, key, min, max, default)
    state[key] = default
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 46)
    row.BackgroundColor3 = COLORS.panel
    row.BorderSizePixel = 0
    row.Parent = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -100, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COLORS.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 80, 0, 20)
    valLbl.Position = UDim2.new(1, -92, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = COLORS.accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 0, 30)
    track.BackgroundColor3 = COLORS.panel2
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local function setFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rel)
        state[key] = v
        valLbl.Text = tostring(v)
        fill.Size = UDim2.new(rel, 0, 1, 0)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
            local conn
            conn = UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch then
                    setFromX(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)

    local rel0 = (default - min) / (max - min)
    fill.Size = UDim2.new(rel0, 0, 1, 0)
    return row
end

-- button
local function makeButton(page, label, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 34)
    b.BackgroundColor3 = COLORS.panel
    b.Text = label
    b.TextColor3 = COLORS.text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.Parent = page
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- Fill pages
makeSlider(pageMain, T[LANG].speed, "speed_value", 1, 200, 16)
makeSlider(pageMain, T[LANG].jump, "jump_value", 1, 500, 50)
makeToggle(pageMain, T[LANG].speed, "speed")
makeToggle(pageMain, T[LANG].jump, "jump")
makeToggle(pageMain, T[LANG].inf_jump, "inf_jump")

makeSlider(pageMove, T[LANG].fly_speed, "fly_speed_value", 10, 500, 50)
makeToggle(pageMove, T[LANG].fly, "fly")
makeToggle(pageMove, T[LANG].noclip, "noclip")

makeToggle(pageVis, T[LANG].fullbright, "fullbright")
makeToggle(pageVis, T[LANG].no_fog, "no_fog")
makeToggle(pageVis, T[LANG].esp, "esp")

makeToggle(pageMisc, T[LANG].anti_afk, "anti_afk")
makeButton(pageMisc, T[LANG].reset_char, function()
    local c = LP.Character
    if c then c:BreakJoints() end
end)
makeButton(pageMisc, T[LANG].rejoin, function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- language switch button at bottom
local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.new(0, 90, 0, 26)
langBtn.Position = UDim2.new(0, 8, 1, -32)
langBtn.BackgroundColor3 = COLORS.panel2
langBtn.Text = "🇻🇳 VI / EN 🇺🇸"
langBtn.TextColor3 = COLORS.text
langBtn.Font = Enum.Font.GothamSemibold
langBtn.TextSize = 12
langBtn.BorderSizePixel = 0
langBtn.Parent = main
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 8)

langBtn.MouseButton1Click:Connect(function()
    LANG = (LANG == "vi") and "en" or "vi"
    title.Text = T[LANG].title
    for i, k in ipairs(tabKeys) do
        tabs[i].Text = T[LANG][k]
    end
    -- reload UI text by rebuilding pages
    local toggles = {
        [pageMain] = {T[LANG].speed, T[LANG].jump, T[LANG].inf_jump},
        [pageMove] = {T[LANG].fly, T[LANG].noclip},
        [pageVis]  = {T[LANG].fullbright, T[LANG].no_fog, T[LANG].esp},
        [pageMisc] = {T[LANG].anti_afk},
    }
    for page, list in pairs(toggles) do
        local i = 1
        for _, child in ipairs(page:GetChildren()) do
            if child:IsA("Frame") then
                local lbl = child:FindFirstChild("TextLabel")
                if lbl and list[i] then lbl.Text = list[i] end
                i = i + 1
            end
        end
    end
end)

btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local minimized = false
btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Size = minimized and UDim2.new(0, 480, 0, 40) or UDim2.new(0, 480, 0, 320)
end)

-- floating toggle button
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.Position = UDim2.new(0, 20, 0.4, 0)
floatBtn.BackgroundColor3 = COLORS.accent
floatBtn.Text = "K7"
floatBtn.TextColor3 = COLORS.text
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 16
floatBtn.BorderSizePixel = 0
floatBtn.Parent = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 25)
local fs = Instance.new("UIStroke", floatBtn)
fs.Color = COLORS.accent2
fs.Thickness = 2

do
    local dragging, dragStart, startPos, moved
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            dragStart = input.Position
            startPos = floatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved then
                        main.Visible = not main.Visible
                    end
                end
            end)
        end
    end)
    floatBtn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if math.abs(d.X) + math.abs(d.Y) > 5 then moved = true end
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                          startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end