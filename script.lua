-- [[ COMPOT SCRIPT: DEFINITIVE EDITION ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Настройки по умолчанию
local Config = {
    AimActive = true,
    FovRadius = 150,
    Smoothness = 0.1, -- 0.1 - жестко, 0.5 - плавно
    MenuOpen = true
}

-- === КРАСИВЫЙ HUD (Всегда виден) ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 180, 0, 60)
HudFrame.Position = UDim2.new(0, 20, 0, 20)
HudFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
HudFrame.BackgroundTransparency = 0.2
HudFrame.BorderSizePixel = 0

Instance.new("UICorner", HudFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", HudFrame)
Stroke.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150)).Keypoints[1].Value
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", HudFrame)
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.Text = "CompotScript"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", HudFrame)
StatsLabel.Position = UDim2.new(0, 0, 0.5, 0)
StatsLabel.Size = UDim2.new(1, 0, 0.5, 0)
StatsLabel.Text = "FPS: ... | PING: ..."
StatsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 12
StatsLabel.BackgroundTransparency = 1

-- === ОКНО НАСТРОЕК (Скрывается на P) ===
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 220, 0, 120)
MenuFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = Config.MenuOpen

Instance.new("UICorner", MenuFrame)
local MenuTitle = Instance.new("TextLabel", MenuFrame)
MenuTitle.Size = UDim2.new(1, 0, 0, 40)
MenuTitle.Text = "MENU [P TO CLOSE]"
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
MenuTitle.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", MenuFrame)
StatusLabel.Position = UDim2.new(0, 0, 0.4, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 60)
StatusLabel.Text = "AIM: ON (Center)\nTARGET: BELLY\nFOV: 150"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundTransparency = 1

-- === FOV КРУГ (ПО ЦЕНТРУ) ===
local Circle = Drawing.new("Circle")
Circle.Thickness = 1
Circle.Color = Color3.fromRGB(255, 255, 255)
Circle.Visible = true
Circle.Filled = false

-- === ЛОГИКА АИМА (В ПУЗО) ===
local function GetTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local target = nil
    local dist = Config.FovRadius

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- Наведение на HumanoidRootPart (Пузо)
            local part = p.Character:FindFirstChild("HumanoidRootPart")
            if part and p.Character.Humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if mag < dist then
                        target = screenPos
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

-- === ЦИКЛ ===
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Круг всегда в центре
    Circle.Position = center
    Circle.Radius = Config.FovRadius
    Circle.Visible = true -- Всегда виден, даже если меню закрыто
    
    -- Обновление HUD
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping)

    -- Работа аима
    if Config.AimActive then
        local t = GetTarget()
        if t and mousemoverel then
            mousemoverel((t.X - center.X) * Config.Smoothness, (t.Y - center.Y) * Config.Smoothness)
        end
    end
end)

-- === ОБРАБОТКА P (ТОЛЬКО ДЛЯ МЕНЮ) ===
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.P then
        Config.MenuOpen = not Config.MenuOpen
        MenuFrame.Visible = Config.MenuOpen
        -- HUD и FOV здесь не трогаем, они остаются!
    end
end)

print("CompotScript Elite Loaded!")
