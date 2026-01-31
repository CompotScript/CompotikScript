-- [[ COMPOT SCRIPT FINAL REMAKE ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Настройки (можно менять тут)
local Config = {
    Enabled = true,
    Fov = 150,
    Smoothness = 0.15, -- Чем меньше, тем быстрее доводка
    MenuKey = Enum.KeyCode.P,
    Visible = true
}

-- === СОЗДАНИЕ HUD (Сверху слева) ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 180, 0, 60)
HudFrame.Position = UDim2.new(0, 20, 0, 20)
HudFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HudFrame.BorderSizePixel = 2

local HudStroke = Instance.new("UIStroke", HudFrame)
HudStroke.Color = Color3.fromRGB(255, 255, 255)

local Title = Instance.new("TextLabel", HudFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "COMPOT SCRIPT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", HudFrame)
StatsLabel.Position = UDim2.new(0, 0, 0, 30)
StatsLabel.Size = UDim2.new(1, 0, 0, 25)
StatsLabel.Text = "FPS: ... | PING: ..."
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 13
StatsLabel.BackgroundTransparency = 1

-- === FOV КРУГ (Drawing API) ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Visible = true
FovCircle.Filled = false

-- === ФУНКЦИЯ ПОИСКА ЦЕЛИ (В ПУЗО) ===
local function GetClosestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local target = nil
    local maxDist = Config.Fov

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart") -- Центр тела (пузо)
            local hum = player.Character:FindFirstChild("Humanoid")

            if root and hum and hum.Health > 0 then
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

-- === ОСНОВНОЙ ЦИКЛ ===
RunService.RenderStepped:Connect(function()
    -- Центр экрана
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Обновление круга
    FovCircle.Position = center
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Enabled
    
    -- Обновление HUD
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping)

    -- Работа Аима
    if Config.Enabled then
        local targetPos = GetClosestTarget()
        if targetPos then
            -- Рассчитываем движение мыши через mousemoverel (Xeno)
            local moveX = (targetPos.X - center.X) * Config.Smoothness
            local moveY = (targetPos.Y - center.Y) * Config.Smoothness
            mousemoverel(moveX, moveY)
        end
    end
end)

-- === ОБРАБОТКА КНОПКИ P ===
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Config.MenuKey then
        Config.Enabled = not Config.Enabled
        HudFrame.Visible = not HudFrame.Visible
        -- Уведомление в консоль для проверки
        print("CompotScript Toggle: ", Config.Enabled)
    end
end)

print("--- COMPOT SCRIPT LOADED ---")
print("Press P to Toggle Aim and HUD")
