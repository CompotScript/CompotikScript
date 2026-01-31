-- [[ COMPOT SCRIPT: FINAL ELITE UPDATE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Конфигурация
local Config = {
    Aimbot = true,
    Fov = 150,
    Smooth = 0.08,
    ESP = true,
    HUD = true,
    SpeedEnabled = true,
    WalkSpeed = 35,
    MenuKey = Enum.KeyCode.P,
    AimKey = Enum.KeyCode.H
}

-- === DRAWING API (FOV И ESP) ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(0, 255, 150)
FovCircle.Visible = true

local Boxes = {}

local function CreateESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Visible = false
    Boxes[player] = box
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP then CreateESP(p) end
end

Players.PlayerAdded:Connect(function(p) CreateESP(p) end)
Players.PlayerRemoving:Connect(function(p)
    if Boxes[p] then Boxes[p]:Remove() Boxes[p] = nil end
end)

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- HUD
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 240, 0, 80)
HudFrame.Position = UDim2.new(0, 20, 0, 20)
HudFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HudFrame.BorderSizePixel = 0
Instance.new("UICorner", HudFrame)

local HudTitle = Instance.new("TextLabel", HudFrame)
HudTitle.Size = UDim2.new(1, 0, 0, 40)
HudTitle.Text = "COMPOT ELITE"
HudTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
HudTitle.Font = Enum.Font.GothamBold
HudTitle.TextSize = 20
HudTitle.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", HudFrame)
StatsLabel.Position = UDim2.new(0, 0, 0.5, 0)
StatsLabel.Size = UDim2.new(1, 0, 0.4, 0)
StatsLabel.TextColor3 = Color3.new(1,1,1)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 14
StatsLabel.BackgroundTransparency = 1

-- МЕНЮ
local MainMenu = Instance.new("Frame", ScreenGui)
MainMenu.Size = UDim2.new(0, 300, 0, 420)
MainMenu.Position = UDim2.new(0.5, -150, 0.5, -210)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainMenu.BorderSizePixel = 0
Instance.new("UICorner", MainMenu)
Instance.new("UIStroke", MainMenu).Color = Color3.fromRGB(40, 40, 40)

local function CreateButton(name, text, pos)
    local btn = Instance.new("TextButton", MainMenu)
    btn.Size = UDim2.new(0, 260, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    
    local function Update()
        btn.Text = text .. ": " .. (Config[name] and "ON" or "OFF")
        btn.TextColor3 = Config[name] and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
    end
    btn.MouseButton1Click:Connect(function() Config[name] = not Config[name] Update() end)
    Update() return btn
end

local aimBtn = CreateButton("Aimbot", "AimBot [H]", 70)
CreateButton("ESP", "Box ESP", 120)
CreateButton("SpeedEnabled", "Speed Hack", 170)

local SpeedLabel = Instance.new("TextLabel", MainMenu)
SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
SpeedLabel.Position = UDim2.new(0, 0, 0, 220)
SpeedLabel.Text = "WalkSpeed: 35"
SpeedLabel.TextColor3 = Color3.new(1,1,1)
SpeedLabel.BackgroundTransparency = 1

local function SpeedBtn(text, x, change)
    local b = Instance.new("TextButton", MainMenu)
    b.Size = UDim2.new(0, 125, 0, 35)
    b.Position = UDim2.new(0, x, 0, 255)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Config.WalkSpeed = math.clamp(Config.WalkSpeed + change, 16, 250)
        SpeedLabel.Text = "WalkSpeed: " .. Config.WalkSpeed
    end)
end

SpeedBtn("- Speed", 20, -10)
SpeedBtn("+ Speed", 155, 10)

-- === ЛОГИКА ===
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Position = center
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Aimbot
    
    StatsLabel.Text = string.format("FPS: %d | PING: %dms", math.floor(1/task.wait()), math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()))
    
    for player, box in pairs(Boxes) do
        if Config.ESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local size = (Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
                box.Size = Vector2.new(size * 0.6, size)
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                box.Visible = true
            else box.Visible = false end
        else box.Visible = false end
    end

    if Config.Aimbot then
        local target, minMag = nil, Config.Fov
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pPos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(pPos.X, pPos.Y) - center).Magnitude
                    if mag < minMag then target = pPos minMag = mag end
                end
            end
        end
        if target then mousemoverel((target.X - center.X) * Config.Smooth, (target.Y - center.Y) * Config.Smooth) end
    end
    
    if Config.SpeedEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Config.MenuKey then MainMenu.Visible = not MainMenu.Visible
    elseif i.KeyCode == Config.AimKey then 
        Config.Aimbot = not Config.Aimbot 
        aimBtn.Text = "Aimbot [H]: " .. (Config.Aimbot and "ON" or "OFF")
        aimBtn.TextColor3 = Config.Aimbot and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
    end
end)
