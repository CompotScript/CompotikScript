--[[
    CompotScript - DM Arena Edition
    Hotkeys: [P] - Open/Close Menu
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow({ Title = 'CompotScript | DM Arena', Center = true, AutoShow = true })

-- Настройки
local Settings = {
    AimBot = false,
    Fov = 100,
    Smoothness = 0.5,
    ESP = false,
}

-- Создаем вкладки
local Tabs = { Main = Window:AddTab('Main'), Visuals = Window:AddTab('Visuals') }

-- Фов круг
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.NumSides = 100
FovCircle.Radius = Settings.Fov
FovCircle.Filled = false
FovCircle.Visible = false
FovCircle.Color = Color3.fromRGB(255, 255, 255)

-- HUD (FPS и Ping)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local HudLabel = Instance.new("TextLabel", ScreenGui)
HudLabel.Size = UDim2.new(0, 200, 0, 50)
HudLabel.Position = UDim2.new(0, 10, 0, 10)
HudLabel.BackgroundTransparency = 1
HudLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
HudLabel.TextStrokeTransparency = 0
HudLabel.TextSize = 18
HudLabel.Font = Enum.Font.Code
HudLabel.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    while task.wait(0.5) do
        local fps = math.floor(1/task.wait())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        HudLabel.Text = string.format("CompotScript\nFPS: %d | Ping: %dms", fps, ping)
    end
end)

-- Логика Аимбота
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = Settings.Fov

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y)).Magnitude
                if distance < shortestDistance then
                    closest = v
                    shortestDistance = distance
                end
            end
        end
    end
    return closest
end

game:GetService("RunService").RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y + 36)
    
    if Settings.AimBot then
        local target = GetClosestPlayer()
        if target and target.Character then
            local cam = game.Workspace.CurrentCamera
            local targetPos = cam:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
            local mousePos = Vector2.new(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y + 36)
            local moveVector = (Vector2.new(targetPos.X, targetPos.Y) - mousePos) * Settings.Smoothness
            
            mousemoverel(moveVector.X, moveVector.Y)
        end
    end
end)

-- Интерфейс управления
local MainGroupBox = Tabs.Main:AddLeftGroupbox('Aim Settings')

MainGroupBox:AddToggle('AimToggle', { Text = 'Enable AimBot', Default = false }):OnChanged(function()
    Settings.AimBot = Toggles.AimToggle.Value
end)

MainGroupBox:AddSlider('FovSlider', { Text = 'FOV Radius', Default = 100, Min = 10, Max = 500, Rounding = 0 }):OnChanged(function()
    Settings.Fov = Options.FovSlider.Value
    FovCircle.Radius = Settings.Fov
end)

MainGroupBox:AddToggle('ShowFov', { Text = 'Show FOV Circle', Default = false }):OnChanged(function()
    FovCircle.Visible = Toggles.ShowFov.Value
end)

MainGroupBox:AddSlider('SmoothSlider', { Text = 'Smoothness', Default = 0.5, Min = 0.1, Max = 1, Rounding = 1 }):OnChanged(function()
    Settings.Smoothness = Options.SmoothSlider.Value
end)

-- ESP (Упрощенный Box)
Tabs.Visuals:AddToggle('ESPToggle', { Text = 'Enable ESP', Default = false }):OnChanged(function()
    Settings.ESP = Toggles.ESPToggle.Value
    -- Логика ESP обычно требует отдельного цикла, здесь база
end)

-- Бинд на кнопку P
Library:SetWatermark('CompotScript Loaded')
Library.KeybindFrame.Visible = false 
Window:SetKeybind(Enum.KeyCode.P)

print("CompotScript loaded successfully!")
