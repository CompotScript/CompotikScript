-- [[ COMPOT SCRIPT: XENO ULTIMATE FIX ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Конфиг
local AimEnabled = true
local FovSize = 150
local Smooth = 0.1 -- Попробуй 0.05 если улетает слишком сильно
local MenuShow = true

-- === ГРАФИКА (HUD) ===
local Gui = Instance.new("ScreenGui", game.CoreGui)

local MainHUD = Instance.new("Frame", Gui)
MainHUD.Size = UDim2.new(0, 180, 0, 60)
MainHUD.Position = UDim2.new(0, 20, 0, 20)
MainHUD.BackgroundColor3 = Color3.new(0, 0, 0)
MainHUD.BorderSizePixel = 2

local Title = Instance.new("TextLabel", MainHUD)
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.Text = "CompotScript"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

local Info = Instance.new("TextLabel", MainHUD)
Info.Size = UDim2.new(1, 0, 0.5, 0)
Info.Position = UDim2.new(0, 0, 0.5, 0)
Info.Text = "P - Toggle Menu"
Info.TextColor3 = Color3.new(0.8, 0.8, 0.8)
Info.BackgroundTransparency = 1

-- === FOV КРУГ ===
local Circle = Drawing.new("Circle")
Circle.Thickness = 1
Circle.Color = Color3.new(1, 1, 1)
Circle.Visible = true
Circle.Filled = false

-- === ЛОГИКА АИМА (ФИКС УЛЕТА МЫШКИ) ===
local function GetClosest()
    local target = nil
    local dist = FovSize
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local part = p.Character.HumanoidRootPart -- Пузо
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if magnitude < dist then
                    target = pos
                    dist = magnitude
                end
            end
        end
    end
    return target
end

-- === ОБНОВЛЕНИЕ ===
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Circle.Position = center
    Circle.Radius = FovSize
    Circle.Visible = AimEnabled

    if AimEnabled then
        local targetPos = GetClosest()
        if targetPos and mousemoverel then
            -- Вычисляем смещение от центра до цели
            local diffX = (targetPos.X - center.X) * Smooth
            local diffY = (targetPos.Y - center.Y) * Smooth
            
            -- Ограничиваем резкий рывок, чтобы не улетало в небо
            mousemoverel(diffX, diffY)
        end
    end
end)

-- === ФИКС КНОПКИ P ===
-- Если UserInputService не ловит, проверяем через цикл
task.spawn(function()
    while true do
        if UserInputService:IsKeyDown(Enum.KeyCode.P) then
            MenuShow = not MenuShow
            MainHUD.Visible = MenuShow
            print("Menu Toggled:", MenuShow)
            task.wait(0.3) -- Защита от спама
        end
        task.wait(0.01)
    end
end)

print("CompotScript Loaded. Use P.")
