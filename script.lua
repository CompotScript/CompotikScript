-- [[ COMPOT SCRIPT: FINAL EMERGENCY FIX ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Конфиг
local AimEnabled = true
local WalkSpeedValue = 60 -- Твоя скорость
local Smoothness = 0.1

-- === СОЗДАЕМ HUD (БЕЗ DRAWING API) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CompotHUD"
ScreenGui.Parent = game:GetService("CoreGui")

local MainHud = Instance.new("TextLabel")
MainHud.Parent = ScreenGui
MainHud.Size = UDim2.new(0, 250, 0, 100)
MainHud.Position = UDim2.new(0, 20, 0, 20)
MainHud.BackgroundColor3 = Color3.new(0,0,0)
MainHud.BackgroundTransparency = 0.5
MainHud.TextColor3 = Color3.fromRGB(0, 255, 150)
MainHud.TextSize = 18
MainHud.Font = Enum.Font.Code
MainHud.TextXAlignment = Enum.TextXAlignment.Left
MainHud.Text = " Loading..."

-- Функция для поиска цели
local function GetTarget()
    local target = nil
    local dist = 200
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < dist then
                    target = pos
                    dist = mag
                end
            end
        end
    end
    return target
end

-- === ОСНОВНОЙ ЦИКЛ ===
RunService.RenderStepped:Connect(function()
    -- Обновление HUD текста
    local fps = math.floor(1/task.wait())
    MainHud.Text = string.format(
        " COMPOT ELITE\n [H] Aim: %s\n [K/L] Speed: %d\n FPS: %d", 
        tostring(AimEnabled), WalkSpeedValue, fps
    )

    -- Работа аимбота
    if AimEnabled then
        local t = GetTarget()
        if t and mousemoverel then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            mousemoverel((t.X - center.X) * Smoothness, (t.Y - center.Y) * Smoothness)
        end
    end

    -- Работа спидов (Жесткий метод)
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = WalkSpeedValue
    end
end)

-- === ОБРАБОТКА КНОПОК ===
UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    
    if input.KeyCode == Enum.KeyCode.H then
        AimEnabled = not AimEnabled
    elseif input.KeyCode == Enum.KeyCode.K then
        WalkSpeedValue = WalkSpeedValue + 10
    elseif input.KeyCode == Enum.KeyCode.L then
        WalkSpeedValue = math.max(16, WalkSpeedValue - 10)
    end
end)

print("Compot Script Loaded!")
