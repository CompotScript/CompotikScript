-- [[ COMPOT SCRIPT: DM ARENA ULTIMATE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Настройки
local Config = {
    Aimbot = true,
    Fov = 150,
    Smooth = 0.1,
    ESP = true,
    Skeleton = true,
    HUD = true,
    Speed = 16,
    MenuVisible = true
}

-- === DRAWING API (ВИЗУАЛ) ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.new(1, 1, 1)
FovCircle.Visible = true

-- === ГУИ МЕНЮ (ScreenGui) ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- HUD (Сверху слева)
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 180, 0, 60)
HudFrame.Position = UDim2.new(0, 10, 0, 10)
HudFrame.BackgroundColor3 = Color3.new(0,0,0)
HudFrame.BackgroundTransparency = 0.4
HudFrame.Visible = Config.HUD
Instance.new("UICorner", HudFrame)

local HudText = Instance.new("TextLabel", HudFrame)
HudText.Size = UDim2.new(1,0,1,0)
HudText.Text = "CompotScript\nFPS: ... | PING: ..."
HudText.TextColor3 = Color3.new(1,1,1)
HudText.Font = Enum.Font.Code
HudText.BackgroundTransparency = 1

-- МЕНЮ НАСТРОЕК
local MainMenu = Instance.new("Frame", ScreenGui)
MainMenu.Size = UDim2.new(0, 250, 0, 300)
MainMenu.Position = UDim2.new(0.5, -125, 0.5, -150)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainMenu.Visible = Config.MenuVisible
Instance.new("UICorner", MainMenu)
local Stroke = Instance.new("UIStroke", MainMenu)
Stroke.Color = Color3.fromRGB(0, 255, 150)

local function CreateToggle(name, text, pos, callback)
    local btn = Instance.new("TextButton", MainMenu)
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = UDim2.new(0, 25, 0, pos)
    btn.Text = text .. ": ON"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Config[name] = not Config[name]
        btn.Text = text .. ": " .. (Config[name] and "ON" or "OFF")
        callback(Config[name])
    end)
end

CreateToggle("Aimbot", "AimBot", 50, function() end)
CreateToggle("ESP", "Box ESP", 90, function() end)
CreateToggle("Skeleton", "Skeleton ESP", 130, function() end)
CreateToggle("HUD", "Show HUD", 170, function(v) HudFrame.Visible = v end)

-- Слайдер скорости (простой клик)
local SpeedBtn = Instance.new("TextButton", MainMenu)
SpeedBtn.Size = UDim2.new(0, 200, 0, 30)
SpeedBtn.Position = UDim2.new(0, 25, 0, 210)
SpeedBtn.Text = "Speed: 16 (Click to +)"
SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SpeedBtn)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.Speed = Config.Speed + 10
    if Config.Speed > 100 then Config.Speed = 16 end
    SpeedBtn.Text = "Speed: " .. Config.Speed
end)

-- === ЛОГИКА ===
local function GetClosest()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local target, minDist = nil, Config.Fov
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
    return target
end

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- FOV Круг
    FovCircle.Position = center
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Aimbot
    
    -- HUD Stats
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    HudText.Text = "CompotScript\nFPS: "..fps.." | PING: "..ping.."ms"
    
    -- AimBot
    if Config.Aimbot then
        local t = GetClosest()
        if t then
            mousemoverel((t.X - center.X) * Config.Smooth, (t.Y - center.Y) * Config.Smooth)
        end
    end
    
    -- Speed
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.Speed
    end
end)

-- Переключение меню на P
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        Config.MenuVisible = not Config.MenuVisible
        MainMenu.Visible = Config.MenuVisible
    end
end)
