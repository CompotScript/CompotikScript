--[[
    CompotScript - DM Arena Edition
    Открытие меню: Клавиша "P"
--]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("CompotScript | DM Arena", "DarkTheme")

-- Настройки
local Settings = {
    AimEnabled = false,
    AimPart = "Head",
    AimFOV = 150,
    WalkSpeed = 16,
    EspEnabled = false
}

-- [HUD СОЗДАНИЕ]
local HUD = Instance.new("ScreenGui")
HUD.Name = "CompotHUD"
HUD.Parent = game:GetService("CoreGui")

local MainHud = Instance.new("Frame")
MainHud.Parent = HUD
MainHud.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainHud.BackgroundTransparency = 0.2
MainHud.BorderSizePixel = 0
MainHud.Position = UDim2.new(0, 10, 0, 10)
MainHud.Size = UDim2.new(0, 200, 0, 60)

-- Скругление углов HUD
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainHud

local Title = Instance.new("TextLabel")
Title.Parent = MainHud
Title.Text = "CompotScript"
Title.TextColor3 = Color3.fromRGB(0, 255, 127)
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local Stats = Instance.new("TextLabel")
Stats.Parent = MainHud
Stats.Position = UDim2.new(0, 0, 0.4, 0)
Stats.Size = UDim2.new(1, 0, 0.6, 0)
Stats.BackgroundTransparency = 1
Stats.TextColor3 = Color3.fromRGB(255, 255, 255)
Stats.Font = Enum.Font.Code
Stats.TextSize = 14

-- Обновление FPS и Ping
spawn(function()
    local RunService = game:GetService("RunService")
    while task.wait(0.5) do
        local fps = math.floor(1/RunService.RenderStepped:Wait())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        Stats.Text = "FPS: " .. fps .. " | PING: " .. ping .. "ms"
    end
end)

-- [ВКЛАДКИ МЕНЮ]
local Combat = Window:NewTab("AimBot")
local Visuals = Window:NewTab("Visuals")
local PlayerTab = Window:NewTab("Player")

local AimSection = Combat:NewSection("Aimbot")
AimSection:NewToggle("Enable Aimbot", "Авто-наводка", function(state) Settings.AimEnabled = state end)
AimSection:NewSlider("FOV", "Радиус", 500, 50, function(s) Settings.AimFOV = s end)

local EspSection = Visuals:NewSection("ESP")
EspSection:NewToggle("Highlight ESP", "Подсветка врагов", function(state) Settings.EspEnabled = state end)

local SpeedSection = PlayerTab:NewSection("Movement")
SpeedSection:NewSlider("WalkSpeed", "Скорость", 150, 16, function(s) Settings.WalkSpeed = s end)

-- [ЛОГИКА РАБОТЫ]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- Функция поиска цели
local function GetClosest()
    local target = nil
    local dist = Settings.AimFOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            local pos, vis = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if magnitude < dist and vis then
                target = v
                dist = magnitude
            end
        end
    end
    return target
end

-- Основной цикл
game:GetService("RunService").RenderStepped:Connect(function()
    if Settings.AimEnabled then
        local target = GetClosest()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[Settings.AimPart].Position)
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local highlight = v.Character:FindFirstChild("CompotESP")
            if Settings.EspEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight", v.Character)
                    highlight.Name = "CompotESP"
                    highlight.FillColor = Color3.fromRGB(0, 255, 127)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                highlight.Enabled = true
            elseif highlight then
                highlight.Enabled = false
            end
        end
    end
end)

-- Переключение меню на кнопку "P"
local MenuVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.P then
        MenuVisible = not MenuVisible
        -- Скрываем основной GUI библиотеки
        for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
            if v:FindFirstChild("Main") and v.Name == "CompotScript | DM Arena" then
                v.Enabled = MenuVisible
            end
        end
        -- Скрываем HUD вместе с меню
        HUD.Enabled = MenuVisible
    end
end)

print("CompotScript Loaded! Press 'P' to Toggle.")
