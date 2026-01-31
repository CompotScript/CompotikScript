-- [[ COMPOT SCRIPT: ULTIMATE VISUAL UPDATE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Настройки
local Config = {
    Aimbot = true,
    Fov = 150,
    Smooth = 0.08,
    ESP = true,
    Skeleton = false,
    HUD = true,
    Speed = 16,
    MenuVisible = true
}

-- === DRAWING API (FOV КРУГ) ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(0, 255, 150)
FovCircle.Filled = false
FovCircle.Visible = true

-- === КРАСИВЫЙ ИНТЕРФЕЙС ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- НОВЫЙ ДИЗАЙН HUD
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 220, 0, 75)
HudFrame.Position = UDim2.new(0, 20, 0, 20)
HudFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
HudFrame.BorderSizePixel = 0
Instance.new("UICorner", HudFrame).CornerRadius = UDim.new(0, 9)

-- Неоновая полоска сверху
local Accent = Instance.new("Frame", HudFrame)
Accent.Size = UDim2.new(1, 0, 0, 3)
Accent.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
Accent.BorderSizePixel = 0
Instance.new("UICorner", Accent)

local HudTitle = Instance.new("TextLabel", HudFrame)
HudTitle.Size = UDim2.new(1, 0, 0, 35)
HudTitle.Position = UDim2.new(0, 0, 0, 5)
HudTitle.Text = "COMPOT SCRIPT"
HudTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HudTitle.Font = Enum.Font.GothamBold
HudTitle.TextSize = 18
HudTitle.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", HudFrame)
StatsLabel.Size = UDim2.new(1, 0, 0, 30)
StatsLabel.Position = UDim2.new(0, 0, 0, 35)
StatsLabel.Text = "FPS: 0 | PING: 0ms"
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 14
StatsLabel.BackgroundTransparency = 1

-- МЕНЮ НАСТРОЕК
local MainMenu = Instance.new("Frame", ScreenGui)
MainMenu.Size = UDim2.new(0, 260, 0, 350)
MainMenu.Position = UDim2.new(0.5, -130, 0.5, -175)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.BorderSizePixel = 0
MainMenu.Visible = Config.MenuVisible
Instance.new("UICorner", MainMenu)

local MenuStroke = Instance.new("UIStroke", MainMenu)
MenuStroke.Color = Color3.fromRGB(40, 40, 40)
MenuStroke.Thickness = 2

local function CreateToggle(name, text, pos, keyhint)
    local btn = Instance.new("TextButton", MainMenu)
    btn.Size = UDim2.new(0, 220, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = text .. ": " .. (Config[name] and "ON" or "OFF") .. (keyhint and " ["..keyhint.."]" or "")
    btn.TextColor3 = Config[name] and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        Config[name] = not Config[name]
        btn.Text = text .. ": " .. (Config[name] and "ON" or "OFF") .. (keyhint and " ["..keyhint.."]" or "")
        btn.TextColor3 = Config[name] and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
    end)
    return btn
end

local aimBtn = CreateToggle("Aimbot", "AimBot", 60, "H")
CreateToggle("ESP", "Box ESP", 110)
CreateToggle("Skeleton", "Skeleton ESP", 160)

-- Настройка скорости (Кнопка-слайдер)
local SpeedBtn = Instance.new("TextButton", MainMenu)
SpeedBtn.Size = UDim2.new(0, 220, 0, 40)
SpeedBtn.Position = UDim2.new(0, 20, 0, 210)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SpeedBtn.Text = "WalkSpeed: " .. Config.Speed
SpeedBtn.TextColor3 = Color3.fromRGB(0, 180, 255)
SpeedBtn.Font = Enum.Font.GothamMedium
SpeedBtn.TextSize = 14
Instance.new("UICorner", SpeedBtn)

SpeedBtn.MouseButton1Click:Connect(function()
    if Config.Speed < 100 then
        Config.Speed = Config.Speed + 10
    else
        Config.Speed = 16
    end
    SpeedBtn.Text = "WalkSpeed: " .. Config.Speed
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
    
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsLabel.Text = string.format("FPS: %d | PING: %dms", fps, ping)
    
    if Config.Aimbot then
        local t = GetClosest()
        if t and mousemoverel then
            mousemoverel((t.X - center.X) * Config.Smooth, (t.Y - center.Y) * Config.Smooth)
        end
    end
    
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.Speed
    end
end)

-- === ОБРАБОТКА БИНДОВ ===
UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        Config.MenuVisible = not Config.MenuVisible
        MainMenu.Visible = Config.MenuVisible
    end
    
    if input.KeyCode == Enum.KeyCode.H then
        Config.Aimbot = not Config.Aimbot
        aimBtn.Text = "AimBot: " .. (Config.Aimbot and "ON [H]" or "OFF [H]")
        aimBtn.TextColor3 = Config.Aimbot and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
    end
end)
