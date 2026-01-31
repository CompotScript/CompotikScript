-- [[ COMPOT SCRIPT: DM ARENA EDITION ]] --

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Настройки
_G.AimbotEnabled = true
_G.FovRadius = 150
_G.Smoothness = 0.25 -- Чем меньше, тем плавнее
_G.FovVisible = true
_G.MenuVisible = true

-- Создаем HUD и Меню
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- КРАСИВЫЙ HUD (FPS/PING)
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 180, 0, 60)
HudFrame.Position = UDim2.new(0, 20, 0, 20)
HudFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HudFrame.BorderSizePixel = 0

local HudCorner = Instance.new("UICorner", HudFrame)
HudCorner.CornerRadius = UDim.new(0, 8)

local HudStroke = Instance.new("UIStroke", HudFrame)
HudStroke.Color = Color3.fromRGB(0, 255, 150)
HudStroke.Thickness = 1.5

local HudTitle = Instance.new("TextLabel", HudFrame)
HudTitle.Size = UDim2.new(1, 0, 0, 30)
HudTitle.Text = "CompotScript"
HudTitle.Font = Enum.Font.GothamBold
HudTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
HudTitle.TextSize = 18
HudTitle.BackgroundTransparency = 1

local HudStats = Instance.new("TextLabel", HudFrame)
HudStats.Position = UDim2.new(0, 0, 0, 30)
HudStats.Size = UDim2.new(1, 0, 0, 25)
HudStats.Text = "FPS: ... | PING: ..."
HudStats.Font = Enum.Font.Code
HudStats.TextColor3 = Color3.fromRGB(255, 255, 255)
HudStats.TextSize = 14
HudStats.BackgroundTransparency = 1

-- ПРОСТОЕ МЕНЮ (По центру для настройки)
local MainMenu = Instance.new("Frame", ScreenGui)
MainMenu.Size = UDim2.new(0, 250, 0, 150)
MainMenu.Position = UDim2.new(0.5, -125, 0.5, -75)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainMenu.BorderSizePixel = 0
MainMenu.Visible = _G.MenuVisible

local MenuCorner = Instance.new("UICorner", MainMenu)
local MenuTitle = Instance.new("TextLabel", MainMenu)
MenuTitle.Size = UDim2.new(1, 0, 0, 40)
MenuTitle.Text = "SETTINGS [P TO HIDE]"
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.BackgroundTransparency = 1

local InfoLabel = Instance.new("TextLabel", MainMenu)
InfoLabel.Position = UDim2.new(0, 0, 0.4, 0)
InfoLabel.Size = UDim2.new(1, 0, 0, 60)
InfoLabel.Text = "Aimbot is ON\nFOV: 150\nSmooth: 0.25"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.BackgroundTransparency = 1

-- FOV КРУГ (РИСОВАНИЕ)
local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(0, 255, 150)
Circle.Thickness = 1
Circle.NumSides = 64
Circle.Radius = _G.FovRadius
Circle.Visible = _G.FovVisible
Circle.Filled = false

-- Функция поиска цели
local function GetClosestTarget()
    local nearestTarget = nil
    local maxDistance = _G.FovRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)

            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if distance < maxDistance then
                    nearestTarget = player.Character.HumanoidRootPart
                    maxDistance = distance
                end
            end
        end
    end
    return nearestTarget
end

-- Основной цикл
RunService.RenderStepped:Connect(function()
    -- Обновление позиции FOV круга (Строго центр)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Circle.Position = center
    Circle.Radius = _G.FovRadius
    Circle.Visible = _G.FovVisible

    -- Логика Аима
    if _G.AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = center
            local moveX = (targetPos.X - mousePos.X) * _G.Smoothness
            local moveY = (targetPos.Y - mousePos.Y) * _G.Smoothness
            
            -- Используем mousemoverel для Xeno
            if mousemoverel then
                mousemoverel(moveX, moveY)
            end
        end
    end

    -- Обновление HUD статистики
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    HudStats.Text = "FPS: " .. fps .. " | PING: " .. ping .. "ms"
end)

-- Переключение меню на P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.P then
        _G.MenuVisible = not _G.MenuVisible
        MainMenu.Visible = _G.MenuVisible
    end
end)

print("CompotScript successfully loaded! Use P to toggle menu.")
