-- [[ COMPOT SCRIPT: PRO EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local UI = { Visible = true, Binding = nil }
local Modules = {
    Aimbot = { Enabled = true, Key = Enum.KeyCode.F, Color = Color3.fromRGB(0, 255, 150) },
    ESP = { Enabled = true, Key = Enum.KeyCode.H, Color = Color3.fromRGB(255, 255, 255) },
    Skeleton = { Enabled = false, Key = Enum.KeyCode.J, Color = Color3.fromRGB(255, 0, 0) },
    Tracers = { Enabled = false, Key = Enum.KeyCode.K, Color = Color3.fromRGB(255, 255, 0) }
}

local Settings = { Fov = 150, Smooth = 0.08 }

-- === ГРАФИКА (HUD & MENU) ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- Черный прямоугольник меню
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(50, 50, 50)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "CompotScript"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 20
Title.BackgroundTransparency = 1

-- Список модулей
local Layout = Instance.new("UIListLayout", MainFrame)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(name)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    
    local function Update()
        btn.Text = name .. ": " .. (Modules[name].Enabled and "ON" or "OFF") .. " [" .. Modules[name].Key.Name .. "]"
        btn.TextColor3 = Modules[name].Enabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
    end
    
    btn.MouseButton1Click:Connect(function()
        Modules[name].Enabled = not Modules[name].Enabled
        Update()
    end)
    
    -- Бинд через СКМ (MiddleMouseButton)
    btn.MouseButton3Click:Connect(function()
        btn.Text = "PRESS ANY KEY..."
        UI.Binding = name
    end)
    
    Update()
end

for modName in pairs(Modules) do CreateButton(modName) end

-- === HUD (FPS/PING) ===
local Hud = Instance.new("Frame", ScreenGui)
Hud.Size = UDim2.new(0, 160, 0, 50)
Hud.Position = UDim2.new(0, 20, 0, 20)
Hud.BackgroundColor3 = Color3.new(0,0,0)
Hud.BackgroundTransparency = 0.4
Instance.new("UICorner", Hud)

local StatsText = Instance.new("TextLabel", Hud)
StatsText.Size = UDim2.new(1,0,1,0)
StatsText.TextColor3 = Color3.new(1,1,1)
StatsText.Font = Enum.Font.Code
StatsText.TextSize = 12
StatsText.BackgroundTransparency = 1

-- === FOV КРУГ ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.new(1, 1, 1)
FovCircle.Visible = true

-- === ЛОГИКА АИМА (В ПУЗО) ===
local function GetTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local target, minMag = nil, Settings.Fov
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < minMag then
                    target = pos
                    minMag = mag
                end
            end
        end
    end
    return target
end

-- === ОСНОВНОЙ ЦИКЛ ОБРАБОТКИ ===
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Position = center
    FovCircle.Radius = Settings.Fov
    FovCircle.Visible = Modules.Aimbot.Enabled
    
    -- Обновление HUD
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsText.Text = "CompotScript\nFPS: "..fps.." | Ping: "..ping

    -- Аимбот
    if Modules.Aimbot.Enabled then
        local t = GetTarget()
        if t then
            mousemoverel((t.X - center.X) * Settings.Smooth, (t.Y - center.Y) * Settings.Smooth)
        end
    end
    
    -- Тут можно добавить отрисовку ESP/Skeleton (через Drawing API)
end)

-- === ОБРАБОТКА ВВОДА (P и Бинды) ===
UserInputService.InputBegan:Connect(function(input, proc)
    if input.KeyCode == Enum.KeyCode.P then
        UI.Visible = not UI.Visible
        MainFrame.Visible = UI.Visible
    elseif UI.Binding then
        Modules[UI.Binding].Key = input.KeyCode
        UI.Binding = nil
        -- Перерисовать кнопки (для простоты можно просто перезапустить скрипт или обновить текст)
    else
        for _, m in pairs(Modules) do
            if input.KeyCode == m.Key then m.Enabled = not m.Enabled end
        end
    end
end)

print("CompotScript Loaded! P - Menu | СКМ - Bind")
