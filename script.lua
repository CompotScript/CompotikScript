-- [[ COMPOT SCRIPT: CLOUD EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Конфигурация
local Config = {
    Aimbot = true,
    ESP = true,
    Skeleton = false,
    Tracers = false,
    Fov = 150,
    Smooth = 0.08, -- Настройка плавности (0.05 - 0.2)
    MenuKey = Enum.KeyCode.P,
    Visible = true
}

-- === КРАСИВЫЙ HUD (Черный прямоугольник) ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 180, 0, 65)
HudFrame.Position = UDim2.new(0, 20, 0, 20)
HudFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
HudFrame.BorderSizePixel = 0
Instance.new("UICorner", HudFrame).CornerRadius = UDim.new(0, 8)

local HudStroke = Instance.new("UIStroke", HudFrame)
HudStroke.Color = Color3.fromRGB(0, 255, 150)
HudStroke.Thickness = 1.5

local HudTitle = Instance.new("TextLabel", HudFrame)
HudTitle.Size = UDim2.new(1, 0, 0, 35)
HudTitle.Text = "CompotScript"
HudTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
HudTitle.Font = Enum.Font.GothamBold
HudTitle.TextSize = 18
HudTitle.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", HudFrame)
StatsLabel.Position = UDim2.new(0, 0, 0, 30)
StatsLabel.Size = UDim2.new(1, 0, 0, 30)
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 13
StatsLabel.Font = Enum.Font.Code
StatsLabel.BackgroundTransparency = 1

-- === FOV КРУГ (Центр экрана) ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false
FovCircle.Visible = true

-- === ЛОГИКА AIMBOT (В ПУЗО) ===
local function GetClosestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local target = nil
    local maxDist = Config.Fov

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if mag < maxDist then
                        target = screenPos
                        maxDist = mag
                    end
                end
            end
        end
    end
    return target
end

-- === ОБРАБОТКА ВВОДА И БИНДОВ ===
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Config.MenuKey then
        Config.Visible = not Config.Visible
        HudFrame.Visible = Config.Visible
        FovCircle.Visible = (Config.Visible and Config.Aimbot)
    end
    
    -- Пример бинда через СКМ (если нажать на колесико - вкл/выкл аим)
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        Config.Aimbot = not Config.Aimbot
    end
end)

-- === ОСНОВНОЙ ЦИКЛ (60 FPS) ===
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Обновление круга и статов
    FovCircle.Position = center
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Aimbot
    
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping)

    -- Работа Аимбота
    if Config.Aimbot then
        local targetPos = GetClosestTarget()
        if targetPos and mousemoverel then
            local x = (targetPos.X - center.X) * Config.Smooth
            local y = (targetPos.Y - center.Y) * Config.Smooth
            mousemoverel(x, y)
        end
    end
end)

print("CompotScript successfully hosted on GitHub!")
