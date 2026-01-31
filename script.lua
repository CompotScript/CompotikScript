-- [[ COMPOT SCRIPT: XENO GOD MODE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Config = {
    Aimbot = {Enabled = true, Key = Enum.KeyCode.F, BindMode = false},
    ESP = {Enabled = true, Key = Enum.KeyCode.H, BindMode = false},
    Skeleton = {Enabled = false, Key = Enum.KeyCode.J, BindMode = false},
    Tracers = {Enabled = false, Key = Enum.KeyCode.K, BindMode = false},
    Fov = 150,
    Smooth = 0.07,
    MenuVisible = true
}

-- Создаем визуальное меню (ручная отрисовка для стабильности)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = Config.MenuVisible

local Corner = Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 255, 150)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "CompotScript"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.BackgroundTransparency = 1
Title.TextSize = 18

-- Функция создания кнопок
local function AddModule(name, order)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0, 180, 0, 35)
    Btn.Position = UDim2.new(0, 10, 0, 45 + (order * 40))
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Font = Enum.Font.Gotham
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextSize = 12
    Instance.new("UICorner", Btn)

    local function UpdateText()
        if Config[name].BindMode then
            Btn.Text = "WAITING FOR KEY..."
            Btn.TextColor3 = Color3.new(1, 1, 0)
        else
            Btn.Text = name .. ": " .. (Config[name].Enabled and "ON" or "OFF") .. " [" .. Config[name].Key.Name .. "]"
            Btn.TextColor3 = Config[name].Enabled and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
        end
    end

    Btn.MouseButton1Click:Connect(function()
        Config[name].Enabled = not Config[name].Enabled
        UpdateText()
    end)

    Btn.MouseButton3Click:Connect(function() -- СКМ
        Config[name].BindMode = true
        UpdateText()
    end)

    UpdateText()
    return UpdateText
end

local updateA = AddModule("Aimbot", 0)
local updateE = AddModule("ESP", 1)
local updateS = AddModule("Skeleton", 2)
local updateT = AddModule("Tracers", 3)

-- Логика FOV
local Circle = Drawing.new("Circle")
Circle.Thickness = 1
Circle.Color = Color3.new(1,1,1)
Circle.Filled = false

-- Логика Аима
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    Circle.Position = center
    Circle.Radius = Config.Fov
    Circle.Visible = Config.Aimbot.Enabled

    if Config.Aimbot.Enabled then
        local target = nil
        local minDist = Config.Fov
        
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
        
        if target then
            mousemoverel((target.X - center.X) * Config.Smooth, (target.Y - center.Y) * Config.Smooth)
        end
    end
end)

-- Обработка клавиш
UserInputService.InputBegan:Connect(function(input, proc)
    if input.KeyCode == Enum.KeyCode.P then
        Config.MenuVisible = not Config.MenuVisible
        MainFrame.Visible = Config.MenuVisible
    end

    for name, data in pairs(Config) do
        if type(data) == "table" and data.BindMode then
            data.Key = input.KeyCode
            data.BindMode = false
            updateA() updateE() updateS() updateT() -- Обновляем текст всех кнопок
            return
        end
    end
end)
