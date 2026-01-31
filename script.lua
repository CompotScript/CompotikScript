-- [[ COMPOT SCRIPT: PREMIUM EDITION ]] --
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
    ESP = false,
    Skeleton = false,
    HUD = true,
    SpeedEnabled = true,
    WalkSpeed = 35, -- Стандартная скорость увеличена
    MenuKey = Enum.KeyCode.P,
    AimKey = Enum.KeyCode.H
}

-- === DRAWING API (FOV КРУГ) ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(0, 255, 150)
FovCircle.Filled = false
FovCircle.Visible = true

-- === СОВРЕМЕННОЕ GUI ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- КРАСИВЫЙ HUD
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 240, 0, 80)
HudFrame.Position = UDim2.new(0, 20, 0, 20)
HudFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HudFrame.BorderSizePixel = 0
Instance.new("UICorner", HudFrame).CornerRadius = UDim.new(0, 10)

local HudGradient = Instance.new("UIGradient", HudFrame)
HudGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
}

local HudLine = Instance.new("Frame", HudFrame)
HudLine.Size = UDim2.new(1, 0, 0, 2)
HudLine.BackgroundColor3 = Color3.new(1, 1, 1)
HudLine.BorderSizePixel = 0
Instance.new("UICorner", HudLine)

local HudTitle = Instance.new("TextLabel", HudFrame)
HudTitle.Size = UDim2.new(1, 0, 0, 40)
HudTitle.Text = "COMPOT ELITE"
HudTitle.TextColor3 = Color3.new(1, 1, 1)
HudTitle.Font = Enum.Font.GothamBold
HudTitle.TextSize = 20
HudTitle.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", HudFrame)
StatsLabel.Position = UDim2.new(0, 0, 0.5, 0)
StatsLabel.Size = UDim2.new(1, 0, 0.4, 0)
StatsLabel.Text = "FPS: 0 | PING: 0ms"
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 14
StatsLabel.BackgroundTransparency = 1

-- ОСНОВНОЕ МЕНЮ
local MainMenu = Instance.new("Frame", ScreenGui)
MainMenu.Size = UDim2.new(0, 300, 0, 400)
MainMenu.Position = UDim2.new(0.5, -150, 0.5, -200)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainMenu.BorderSizePixel = 0
MainMenu.Visible = true
Instance.new("UICorner", MainMenu)

local MenuStroke = Instance.new("UIStroke", MainMenu)
MenuStroke.Thickness = 2
MenuStroke.Color = Color3.fromRGB(40, 40, 40)

local MenuTitle = Instance.new("TextLabel", MainMenu)
MenuTitle.Size = UDim2.new(1, 0, 0, 60)
MenuTitle.Text = "MAIN SETTINGS"
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
MenuTitle.TextSize = 22
MenuTitle.BackgroundTransparency = 1

local function CreateButton(name, text, pos, toggleFunc)
    local btn = Instance.new("TextButton", MainMenu)
    btn.Size = UDim2.new(0, 260, 0, 45)
    btn.Position = UDim2.new(0, 20, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 15
    Instance.new("UICorner", btn)
    
    local function Update()
        btn.Text = text .. ": " .. (Config[name] and "ENABLED" or "DISABLED")
        btn.TextColor3 = Config[name] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
    end
    
    btn.MouseButton1Click:Connect(function()
        Config[name] = not Config[name]
        Update()
        if toggleFunc then toggleFunc() end
    end)
    Update()
    return btn
end

local aimBtn = CreateButton("Aimbot", "AimBot [H]", 70)
CreateButton("ESP", "Box ESP", 125)
CreateButton("SpeedEnabled", "Speed Hack", 180)

-- Слайдер скорости (Кнопка + и -)
local SpeedDisplay = Instance.new("TextLabel", MainMenu)
SpeedDisplay.Size = UDim2.new(0, 260, 0, 40)
SpeedDisplay.Position = UDim2.new(0, 20, 0, 235)
SpeedDisplay.Text = "WalkSpeed: " .. Config.WalkSpeed
SpeedDisplay.TextColor3 = Color3.new(1,1,1)
SpeedDisplay.BackgroundTransparency = 1
SpeedDisplay.Font = Enum.Font.Gotham

local AddSpeed = Instance.new("TextButton", MainMenu)
AddSpeed.Size = UDim2.new(0, 125, 0, 35)
AddSpeed.Position = UDim2.new(0, 20, 0, 275)
AddSpeed.Text = "+ Speed"
AddSpeed.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AddSpeed.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", AddSpeed)

AddSpeed.MouseButton1Click:Connect(function()
    Config.WalkSpeed = math.min(Config.WalkSpeed + 10, 200)
    SpeedDisplay.Text = "WalkSpeed: " .. Config.WalkSpeed
end)

-- === ЛОГИКА ===
local function GetClosest()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local target, minDist = nil, Config.Fov
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < minDist then
                    target = pos
                    minDist = mag
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Position = center
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Aimbot
    
    -- Статистика
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsLabel.Text = string.format("FPS: %d | PING: %dms", fps, ping)
    
    -- Аим
    if Config.Aimbot then
        local t = GetClosest()
        if t and mousemoverel then
            mousemoverel((t.X - center.X) * Config.Smooth, (t.Y - center.Y) * Config.Smooth)
        end
    end
    
    -- ПРИНУДИТЕЛЬНЫЕ СПИДЫ (FIX)
    if Config.SpeedEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    elseif LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Бинды
UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Config.MenuKey then
        MainMenu.Visible = not MainMenu.Visible
    elseif input.KeyCode == Config.AimKey then
        Config.Aimbot = not Config.Aimbot
        aimBtn.Text = "AimBot [H]: " .. (Config.Aimbot and "ENABLED" or "DISABLED")
        aimBtn.TextColor3 = Config.Aimbot and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
    end
end)
