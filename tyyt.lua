--[[
 Combat Arena – ALL‑IN LEGIT++ (Mobile Safe)
 ✔ Adaptive Performance (FPS aware)
 ✔ Dynamic FOV + Dynamic Smooth
 ✔ Light Prediction (no raycast)
 ✔ Legit Randomization (hit rate ~92–95%)
 ✔ Aim only when SHOOTING
 ✔ Enemy‑only aim / teammate ESP faded
 ✔ Auto Headshot (close & mid)
 ✔ Auto‑disable + Hop on Admin
 Works on: Delta / KRNL / Fluxus
]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer

--// ================= CONFIG =================
local cfg = {
    ESP = true,
    BOX = true,
    AIM = true,
    TEAM_CHECK = true,

    -- Aim trigger
    SHOOT_ONLY = true,
    FIRE_BUTTON = Enum.UserInputType.MouseButton1,

    -- Base FOV (dynamic overrides below)
    FOV_BASE = 200,
    FOV_VISIBLE = true,

    -- Smooth range (dynamic)
    SMOOTH_MIN = 0.14,
    SMOOTH_MAX = 0.24,

    -- Head logic
    HEADSHOT_CLOSE = 85,
    HEADSHOT_MID   = 180,

    DEFAULT_PART = "HumanoidRootPart",
    HEAD_PART    = "Head",

    -- Prediction
    PREDICT_FACTOR = 0.12,   -- light, legit

    -- Legit randomization (keep hit rate > 90%)
    MISS_CHANCE = 0.08,      -- 8% intentional soft miss
    DELAY_CHANCE = 0.10,     -- 10% micro delay
    DELAY_MIN = 0.015,
    DELAY_MAX = 0.045,

    -- Adaptive perf
    FPS_LOW = 40,
    FPS_MED = 55,

    -- Admin protection
    AUTO_DISABLE_ON_ADMIN = true,
    ADMIN_KEYWORDS = {"admin","mod","staff","dev"},
}

--// ================= UTILS =================
local function isEnemy(plr)
    if not cfg.TEAM_CHECK then return true end
    if not LP.Team or not plr.Team then return true end
    return plr.Team ~= LP.Team
end

local function hrp()
    return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
end

local function distFromMe(pos)
    local r = hrp()
    if not r then return math.huge end
    return (r.Position - pos).Magnitude
end

-- FPS estimator
local fps, frames, last = 60, 0, tick()
RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - last >= 1 then
        fps = frames / (tick() - last)
        frames = 0
        last = tick()
    end
end)

-- Dynamic smooth & FOV
local function dynParams(distance)
    local fov = cfg.FOV_BASE
    local smooth
    if distance < 80 then
        fov = 160; smooth = 0.14
    elseif distance < 180 then
        fov = 200; smooth = 0.18
    else
        fov = 260; smooth = 0.24
    end
    -- Adaptive perf
    if fps < cfg.FPS_LOW then
        fov -= 30; smooth += 0.04; cfg.BOX = false
    elseif fps < cfg.FPS_MED then
        smooth += 0.02
    end
    return math.max(120,fov), math.clamp(smooth, cfg.SMOOTH_MIN, cfg.SMOOTH_MAX)
end

-- Legit randomization helpers
local function shouldMiss() return math.random() < cfg.MISS_CHANCE end
local function maybeDelay()
    if math.random() < cfg.DELAY_CHANCE then
        task.wait(math.random()*(cfg.DELAY_MAX-cfg.DELAY_MIN)+cfg.DELAY_MIN)
    end
end

--// ================= GUI (ICON ONLY / NO MENU) =================
-- All features ENABLED by default. No menu to avoid mobile UI bugs.

-- Force-enable features
cfg.ESP = true
cfg.AIM = true
cfg.FOV_VISIBLE = true

-- Small status icon (touch-safe, does nothing except indicate running)
local gui = Instance.new("ScreenGui")
gui.Name = "RunIcon"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local icon = Instance.new("TextButton", gui)
icon.Size = UDim2.fromOffset(44, 44)
icon.Position = UDim2.fromOffset(16, 90)
icon.Text = "ON"
icon.Font = Enum.Font.GothamBold
icon.TextSize = 12
icon.TextColor3 = Color3.new(1,1,1)
icon.BackgroundColor3 = Color3.fromRGB(35, 140, 85)
icon.ZIndex = 10

-- Optional: tap to re-center icon (harmless)
icon.Activated:Connect(function()
    icon.Position = UDim2.fromOffset(16, 90)
end)

--// ================= FOV =================
local fov = Instance.new("Frame", gui)
fov.AnchorPoint = Vector2.new(0.5,0.5)
fov.BackgroundTransparency = 1
fov.BorderSizePixel = 0
local st = Instance.new("UIStroke", fov)
st.Thickness = 2
st.Color = Color3.fromRGB(255,120,120)
Instance.new("UICorner", fov).CornerRadius = UDim.new(1,0)

--// ================= ESP =================
local esp = {}
local function addESP(plr)
    if plr == LP then return end
    local char = plr.Character; if not char then return end
    local r = char:FindFirstChild("HumanoidRootPart"); if not r then return end
    if esp[plr] then return end
    local bill = Instance.new("BillboardGui", gui)
    bill.Adornee = r; bill.Size = UDim2.new(0,120,0,30); bill.AlwaysOnTop = true
    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold; txt.TextSize = 14; txt.Text = plr.Name
    local box
    if cfg.BOX then
        box = Instance.new("BoxHandleAdornment", gui)
        box.Adornee = char; box.AlwaysOnTop = true; box.Size = Vector3.new(4,6,2); box.Transparency = 0.75
    end
    esp[plr] = {bill=bill, label=txt, box=box}
end

local function updateESP()
    for plr,d in pairs(esp) do
        if not plr.Character or not d.bill.Adornee then
            d.bill.Enabled = false
        else
            local enemy = isEnemy(plr)
            d.bill.Enabled = cfg.ESP and enemy
            d.label.TextTransparency = enemy and 0 or 0.7
            d.label.TextColor3 = enemy and Color3.fromRGB(255,80,80) or Color3.fromRGB(120,120,120)
            if d.box then d.box.Visible = cfg.ESP and cfg.BOX and enemy end
        end
    end
end

--// ================= AIM =================
local shooting = false
UserInputService.InputBegan:Connect(function(i) if i.UserInputType==cfg.FIRE_BUTTON then shooting=true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==cfg.FIRE_BUTTON then shooting=false end end)

local function pickTarget()
    local best, bestScore, bestDist = nil, math.huge, math.huge
    local mouse = UserInputService:GetMouseLocation()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LP and isEnemy(plr) and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and r and hum.Health>0 then
                local dist = distFromMe(r.Position)
                local part = r
                if dist<=cfg.HEADSHOT_MID then
                    local h = plr.Character:FindFirstChild(cfg.HEAD_PART); if h then part=h end
                end
                local pos,on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local fovDyn,_ = dynParams(dist)
                    local d2 = (Vector2.new(pos.X,pos.Y)-mouse).Magnitude
                    if d2 < fovDyn then
                        local score = d2 + dist*0.25
                        if score<bestScore then bestScore, best, bestDist = score, part, dist end
                    end
                end
            end
        end
    end
    return best, bestDist
end

--// ================= ADMIN PROTECT =================
local function isAdmin(plr)
    local n = plr.Name:lower(); for _,k in pairs(cfg.ADMIN_KEYWORDS) do if n:find(k) then return true end end
end
local function panic(reason)
    status.Text = "Status: PANIC ("..reason..")"; status.TextColor3 = Color3.fromRGB(255,80,80)
    cfg.AIM=false; cfg.ESP=false
    if cfg.AUTO_DISABLE_ON_ADMIN then task.wait(1.2); pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
end
for _,p in pairs(Players:GetPlayers()) do if isAdmin(p) then panic("ADMIN") end end
Players.PlayerAdded:Connect(function(p) if isAdmin(p) then panic("ADMIN JOIN") end end)

--// ================= LOOP =================
RunService.RenderStepped:Connect(function()
    local m = UserInputService:GetMouseLocation()
    fov.Position = UDim2.fromOffset(m.X, m.Y)
    fov.Visible = cfg.FOV_VISIBLE

    updateESP()

    if cfg.AIM and (not cfg.SHOOT_ONLY or shooting) then
        local tgt, dist = pickTarget()
        if tgt and not shouldMiss() then
            maybeDelay()
            local fovDyn, smooth = dynParams(dist)
            fov.Size = UDim2.new(0,fovDyn*2,0,fovDyn*2)
            local camPos = Camera.CFrame.Position
            local vel = tgt.AssemblyLinearVelocity
            local aimPos = tgt.Position + (vel * cfg.PREDICT_FACTOR)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, aimPos), smooth)
        end
    end
end)

--// ================= PLAYERS =================
for _,p in pairs(Players:GetPlayers()) do if p.Character then addESP(p) end; p.CharacterAdded:Connect(function() task.wait(0.3); addESP(p) end) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.3); addESP(p) end) end)

print("✅ Combat Arena LEGIT++ Loaded")
