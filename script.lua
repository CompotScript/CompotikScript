--[[
    CompotScript Elite Edition
    Hotkey: [P] to Toggle Menu
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow({
    Title = 'CompotScript | DM Arena',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Настройки
local Settings = {
    AimBot = false,
    Fov = 100,
    Smoothness = 0.5,
    ShowFov = false
}

-- === КРАСИВЫЙ HUD ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 65)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0

-- Скругление и обводка HUD
local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

local Gradient = Instance.new("UIGradient", MainFrame)
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
}

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Текст заголовка
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "COMPOT SCRIPT"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.BackgroundTransparency = 1

-- Статистика (FPS/Ping)
local Stats = Instance.new("TextLabel", MainFrame)
Stats.Position = UDim2.new(0, 0, 0, 30)
Stats.Size = UDim2.new(1, 0, 0, 25)
Stats.Text = "FPS: ... | PING: ..."
Stats.Font = Enum.Font.Code
Stats.TextColor3 = Color3.fromRGB(200, 200, 200)
Stats.TextSize = 14
Stats.BackgroundTransparency = 1

-- Обновление HUD
task.spawn(function()
    while task.wait(0.5) do
        local fps = math.floor(1/task.wait())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        Stats.Text = string.format("FPS: %d | PING: %dms", fps, ping)
    end
end)

-- === ФУНКЦИОНАЛ ===
local Tabs = { Main = Window:AddTab('Combat') }
local AimSection = Tabs.Main:AddLeftGroupbox('Aimbot Settings')

AimSection:AddToggle('AimToggle', { Text = 'Enable Aimbot' }):OnChanged(function()
    Settings.AimBot = Toggles.AimToggle.Value
end)

AimSection:AddSlider('FovSlider', { Text = 'FOV Radius', Default = 100, Min = 10, Max = 500, Rounding = 0 }):OnChanged(function()
    Settings.Fov = Options.FovSlider.Value
end)

AimSection:AddSlider('SmoothSlider', { Text = 'Smoothness', Default = 0.5, Min = 0.1, Max = 1, Rounding = 1 }):OnChanged(function()
    Settings.Smoothness = Options.SmoothSlider.Value
end)

AimSection:AddToggle('FovVisible', { Text = 'Show FOV Circle' }):OnChanged(function()
    Settings.ShowFov = Toggles.FovVisible.Value
end)

-- Управление открытием на P
Window:SetKeybind(Enum.KeyCode.P)

-- Фов круг (Drawing API)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(0, 255, 150)
FovCircle.Filled = false

game:GetService("RunService").RenderStepped:Connect(function()
    FovCircle.Visible = Settings.ShowFov
    FovCircle.Radius = Settings.Fov
    FovCircle.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
    
    if Settings.AimBot then
        -- Логика аима (наведение на ближайшего)
        local target = nil
        local dist = Settings.Fov
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - FovCircle.Position).Magnitude
                    if mag < dist then
                        target = p
                        dist = mag
                    end
                end
            end
        end
        if target then
            local tPos = game.Workspace.CurrentCamera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
            mousemoverel((tPos.X - FovCircle.Position.X) * Settings.Smoothness, (tPos.Y - FovCircle.Position.Y) * Settings.Smoothness)
        end
    end
end)

Library:Notify("CompotScript Loaded! Press [P] to toggle.")
