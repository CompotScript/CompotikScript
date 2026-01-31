--[[
    CompotScript - Full Edition (DM Arena)
    Функции: ESP, Aimbot, Speed, HUD, Chat Message
    Кнопка управления: P
--]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("CompotScript", "DarkTheme")

-- Уведомление в чат
game.StarterGui:SetCore("ChatMakeSystemMessage", {
    Text = "[CompotScript]: Загрузка завершена! Нажми P для управления.";
    Color = Color3.fromRGB(0, 255, 127);
    Font = Enum.Font.GothamBold;
})

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
MainHud.Position = UDim2.new(0, 10, 0, 10)
MainHud.Size = UDim2.new(0, 180, 0, 50)
local Corner = Instance.new("UICorner", MainHud)
Corner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Parent = MainHud
Title.Text = "CompotScript"
Title.TextColor3 = Color3.fromRGB(0, 255, 127)
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Stats = Instance.new("TextLabel")
Stats.Parent = MainHud
Stats.Position = UDim2.new(0, 0, 0.5, 0)
Stats.Size = UDim2.new(1, 0, 0.5, 0)
Stats.BackgroundTransparency = 1
Stats.TextColor3 = Color3.fromRGB(255, 255, 255)
Stats.TextSize = 12

-- Обновление FPS/Ping
spawn(function()
    while task.wait(0.5) do
        local fps = math.floor(1/game:GetService("RunService").RenderStepped:Wait())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        Stats.Text = "FPS: " .. fps .. " | PING: " .. ping .. "ms"
    end
end)

-- [МЕНЮ]
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local PlayerTab = Window:NewTab("Player")

local AimSection = Combat:NewSection("Aimbot")
AimSection:NewToggle("Enable Aimbot", "Авто-наводка", function(state) Settings.AimEnabled = state end)
AimSection:NewSlider("FOV", "Радиус", 500, 50, function(s) Settings.AimFOV = s end)

local EspSection = Visuals:NewSection("Visuals")
EspSection:NewToggle("ESP Highlight", "Подсветка врагов", function(state) Settings.EspEnabled = state end)

local SpeedSection = PlayerTab:NewSection("Movement")
SpeedSection:NewSlider("Speed", "Скорость", 150, 16, function(s) Settings.WalkSpeed = s end)

-- [ЛОГИКА]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function GetClosest()
    local target = nil
    local dist = Settings.AimFOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            local pos, vis = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)).Magnitude
            if magnitude < dist and vis then
                target = v
                dist = magnitude
            end
        end
    end
    return target
end

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
            local h = v.Character:FindFirstChild("CompotESP")
            if Settings.EspEnabled then
                if not h then
                    h = Instance.new("Highlight", v.Character)
                    h.Name = "CompotESP"
                    h.FillColor = Color3.fromRGB(0, 255, 127)
                end
                h.Enabled = true
            elseif h then h.Enabled = false end
        end
    end
end)

-- Управление кнопкой P
game:GetService("UserInputService").InputBegan:Connect(function(input, proc)
    if not proc and input.KeyCode == Enum.KeyCode.P then
        for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
            if v.Name == "CompotScript" or v.Name == "CompotHUD" then
                v.Enabled = not v.Enabled
            end
        end
    end
end)
