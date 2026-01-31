-- [[ COMPOT ELITE: CS-STYLE EDITION ]] --
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
    SpeedEnabled = true,
    WalkSpeed = 35,
    MenuKey = Enum.KeyCode.P,
    AimKey = Enum.KeyCode.H,
    Visible = true
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
    box.Color = Color3.fromRGB(255, 255, 255)
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

-- === PREMIUM CS GUI ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- HUD (Сверху слева)
local HUD = Instance.new("Frame", ScreenGui)
HUD.Size = UDim2.new(0, 200, 0, 50)
HUD.Position = UDim2.new(0, 15, 0, 15)
HUD.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HUD.BorderSizePixel = 0
Instance.new("UICorner", HUD)
Instance.new("UIStroke", HUD).Color = Color3.fromRGB(0, 255, 150)

local HudInfo = Instance.new("TextLabel", HUD)
HudInfo.Size = UDim2.new(1, 0, 1, 0)
HudInfo.BackgroundTransparency = 1
HudInfo.Font = Enum.Font.Code
HudInfo.TextSize = 14
HudInfo.TextColor3 = Color3.new(1, 1, 1)
HudInfo.Text = "COMPOT.ELITE | FPS: 0\nPING: 0ms"

-- ГЛАВНОЕ МЕНЮ
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 450, 0, 320)
Main.Position = UDim2.new(0.5, -225, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Visible = Config.Visible
Instance.new("UICorner", Main)

local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 120, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SideBar.BorderSizePixel = 0
Instance.new("UICorner", SideBar)

local Title = Instance.new("TextLabel", SideBar)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "COMPOT"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.BackgroundTransparency = 1

-- Контейнер для кнопок функций
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 130, 0, 10)
Container.Size = UDim2.new(1, -140, 1, -20)
Container.BackgroundTransparency = 1

local function CreateToggle(name, text, pos)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    
    local function Update()
        btn.Text = text .. ": " .. (Config[name] and "ON" or "OFF")
        btn.TextColor3 = Config[name] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
    end
    btn.MouseButton1Click:Connect(function() Config[name] = not Config[name] Update() end)
    Update()
    return btn
end

local aimBtn = CreateToggle("Aimbot", "AimBot [H]", 0)
CreateToggle("ESP", "Player ESP", 45)
CreateToggle("SpeedEnabled", "Enable Speed", 90)

-- Управление скоростью
local SpeedControl = Instance.new("Frame", Container)
SpeedControl.Position = UDim2.new(0, 0, 0, 140)
SpeedControl.Size = UDim2.new(1, 0, 0, 80)
SpeedControl.BackgroundTransparency = 1

local SLabel = Instance.new("TextLabel", SpeedControl)
SLabel.Size = UDim2.new(1, 0, 0, 30)
SLabel.Text = "Movement Speed: 35"
SLabel.TextColor3 = Color3.new(1,1,1)
SLabel.Font = Enum.Font.Gotham
SLabel.BackgroundTransparency = 1

local function SBtn(text, x, change)
    local b = Instance.new("TextButton", SpeedControl)
    b.Size = UDim2.new(0.45, 0, 0, 35)
    b.Position = UDim2.new(x, 0, 0, 40)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Config.WalkSpeed = math.clamp(Config.WalkSpeed + change, 16, 250)
        SLabel.Text = "Movement Speed: " .. Config.WalkSpeed
    end)
end

SBtn("-", 0, -10)
SBtn("+", 0.55, 10)

-- === ЛОГИКА ===
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Position = center
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Aimbot
    
    HudInfo.Text = string.format("COMPOT.ELITE | FPS: %d\nPING: %dms", math.floor(1/task.wait()), math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()))
    
    -- ESP Logic
    for player, box in pairs(Boxes) do
        if Config.ESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local h = math.abs(top.Y - bottom.Y)
                box.Size = Vector2.new(h * 0.6, h)
                box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                box.Visible = true
            else box.Visible = false end
        else box.Visible = false end
    end

    -- Aim Logic
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
    
    -- Speed Logic
    if Config.SpeedEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Config.MenuKey then 
        Config.Visible = not Config.Visible
        Main.Visible = Config.Visible
    elseif i.KeyCode == Config.AimKey then 
        Config.Aimbot = not Config.Aimbot 
        aimBtn.Text = "AimBot [H]: " .. (Config.Aimbot and "ON" or "OFF")
        aimBtn.TextColor3 = Config.Aimbot and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
    end
end)
