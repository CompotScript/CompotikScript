-- [[ COMPOT ELITE: REBORN STABLE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Config = {
    Aimbot = true, Fov = 150, Smooth = 0.08,
    ESP = true, Skeleton = true, Names = true, Weapons = true,
    SpeedEnabled = true, WalkSpeed = 35,
    MenuKey = Enum.KeyCode.P, AimKey = Enum.KeyCode.H, Visible = true
}

-- === DRAWING API (FOV И ESP) ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(0, 255, 150)
FovCircle.Visible = true

local ESP_Data = {}
local function CreateESP(p)
    local data = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Weapon = Drawing.new("Text"),
        Bones = {}
    }
    data.Box.Thickness = 1
    data.Box.Color = Color3.new(1,1,1)
    data.Name.Size = 14
    data.Name.Center, data.Name.Outline = true, true
    data.Weapon.Size = 13
    data.Weapon.Center, data.Weapon.Outline = true, true
    data.Weapon.Color = Color3.fromRGB(0, 255, 150)
    
    local bones = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
    }
    for i=1, #bones do
        local l = Drawing.new("Line")
        l.Thickness = 1
        l.Color = Color3.new(1,1,1)
        table.insert(data.Bones, {l, bones[i]})
    end
    ESP_Data[p] = data
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LP then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

-- === КРАСИВЫЙ HUD (ВЕРНУЛ) ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 200, 0, 70)
HudFrame.Position = UDim2.new(0, 20, 0, 20)
HudFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
HudFrame.BorderSizePixel = 0
Instance.new("UICorner", HudFrame)
local Accent = Instance.new("Frame", HudFrame)
Accent.Size = UDim2.new(1, 0, 0, 2)
Accent.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
Accent.BorderSizePixel = 0

local HudInfo = Instance.new("TextLabel", HudFrame)
HudInfo.Size = UDim2.new(1, 0, 1, 0)
HudInfo.BackgroundTransparency = 1
HudInfo.Font = Enum.Font.Code
HudInfo.TextColor3 = Color3.new(1,1,1)
HudInfo.TextSize = 14
HudInfo.Text = "COMPOT.ELITE\nFPS: 0 | PING: 0"

-- === МЕНЮ ===
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.5, -150, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Visible = Config.Visible
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(40, 40, 40)

local function AddBtn(text, cfg_key, pos)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 260, 0, 35)
    b.Position = UDim2.new(0, 20, 0, pos)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Font = Enum.Font.Gotham
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text .. ": ON"
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Config[cfg_key] = not Config[cfg_key]
        b.Text = text .. ": " .. (Config[cfg_key] and "ON" or "OFF")
        b.TextColor3 = Config[cfg_key] and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
    end)
end

AddBtn("AimBot [H]", "Aimbot", 60)
AddBtn("Player ESP", "ESP", 100)
AddBtn("Skeleton", "Skeleton", 140)
AddBtn("Speed Hack", "SpeedEnabled", 180)

-- Speed Controls
local SLabel = Instance.new("TextLabel", Main)
SLabel.Size = UDim2.new(1, 0, 0, 30)
SLabel.Position = UDim2.new(0, 0, 0, 230)
SLabel.Text = "WalkSpeed: 35"
SLabel.TextColor3 = Color3.new(1,1,1)
SLabel.BackgroundTransparency = 1

local function SBtn(t, x, v)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 125, 0, 35)
    b.Position = UDim2.new(0, x, 0, 265)
    b.Text = t
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Config.WalkSpeed = math.clamp(Config.WalkSpeed + v, 16, 200)
        SLabel.Text = "WalkSpeed: " .. Config.WalkSpeed
    end)
end
SBtn("- Speed", 20, -5) SBtn("+ Speed", 155, 5)

-- === LOGIC ===
RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Aimbot
    HudInfo.Text = string.format("COMPOT.ELITE\nFPS: %d | PING: %dms", math.floor(1/task.wait()), math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()))

    for p, v in pairs(ESP_Data) do
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
            local hrp = char.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            if vis and Config.ESP then
                local h = math.abs(Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.5, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0)).Y)
                v.Box.Size = Vector2.new(h * 0.6, h)
                v.Box.Position = Vector2.new(pos.X - v.Box.Size.X/2, pos.Y - h/2)
                v.Box.Visible = true
                v.Name.Text = p.Name
                v.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15)
                v.Name.Visible = Config.Names
                local tool = char:FindFirstChildOfClass("Tool")
                v.Weapon.Text = tool and tool.Name or "Hands"
                v.Weapon.Position = Vector2.new(pos.X, pos.Y + h/2 + 5)
                v.Weapon.Visible = Config.Weapons
                if Config.Skeleton then
                    for _, b in pairs(v.Bones) do
                        local p1_part, p2_part = char:FindFirstChild(b[2][1]), char:FindFirstChild(b[2][2])
                        if p1_part and p2_part then
                            local p1, p2 = Camera:WorldToViewportPoint(p1_part.Position), Camera:WorldToViewportPoint(p2_part.Position)
                            b[1].From, b[1].To, b[1].Visible = Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y), true
                        else b[1].Visible = false end
                    end
                else for _, b in pairs(v.Bones) do b[1].Visible = false end end
            else v.Box.Visible, v.Name.Visible, v.Weapon.Visible = false, false, false
                for _, b in pairs(v.Bones) do b[1].Visible = false end end
        else v.Box.Visible, v.Name.Visible, v.Weapon.Visible = false, false, false
            for _, b in pairs(v.Bones) do b[1].Visible = false end end
    end

    if Config.Aimbot then
        local target, minMag = nil, Config.Fov
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pPos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(pPos.X, pPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < minMag then target = pPos minMag = mag end
                end
            end
        end
        if target then mousemoverel((target.X - Camera.ViewportSize.X/2) * Config.Smooth, (target.Y - Camera.ViewportSize.Y/2) * Config.Smooth) end
    end
    
    -- ПРИНУДИТЕЛЬНЫЕ СПИДЫ (FIXED)
    if Config.SpeedEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Config.MenuKey then Config.Visible = not Config.Visible Main.Visible = Config.Visible
    elseif i.KeyCode == Config.AimKey then Config.Aimbot = not Config.Aimbot end
end)
