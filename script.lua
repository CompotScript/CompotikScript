--[[
    CompotScript - Professional Edition
    Настройки: ESP, Aimbot (FOV + Smooth), HUD
    Клавиша меню: P
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("CompotScript", "DarkTheme")

-- Настройки
local Settings = {
    AimEnabled = false,
    AimPart = "Head",
    AimFOV = 150,
    AimSmooth = 1, -- Плавность (1 - мгновенно, выше - плавнее)
    AimBind = Enum.UserInputType.MouseButton2,
    IsAiming = false,
    WalkSpeed = 16,
    EspEnabled = false,
    ShowFov = true,
    FovColor = Color3.fromRGB(0, 255, 127)
}

-- [FOV КРУГ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Settings.FovColor
FOVCircle.Transparency = 1
FOVCircle.Filled = false
FOVCircle.Visible = Settings.ShowFov
FOVCircle.Radius = Settings.AimFOV

-- [HUD]
local HUD = Instance.new("ScreenGui")
HUD.Name = "CompotHUD"
HUD.Parent = game:GetService("CoreGui")
HUD.Enabled = false

local MainHud = Instance.new("Frame", HUD)
MainHud.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainHud.Position = UDim2.new(0, 15, 0, 15)
MainHud.Size = UDim2.new(0, 200, 0, 60)
Instance.new("UICorner", MainHud)

local Title = Instance.new("TextLabel", MainHud)
Title.Text = "CompotScript"
Title.TextColor3 = Color3.fromRGB(0, 255, 127)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.BackgroundTransparency = 1

local Stats = Instance.new("TextLabel", MainHud)
Stats.Position = UDim2.new(0, 0, 0.5, 0)
Stats.Size = UDim2.new(1, 0, 0.5, 0)
Stats.TextColor3 = Color3.fromRGB(255, 255, 255)
Stats.BackgroundTransparency = 1
Stats.Text = "FPS: 0 | PING: 0"

-- [ESP ФУНКЦИЯ]
local function CreateESP(player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Health = Drawing.new("Text")
    local Weapon = Drawing.new("Text")

    game:GetService("RunService").RenderStepped:Connect(function()
        if Settings.EspEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= game.Players.LocalPlayer then
            local root = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            if not head or not hum or hum.Health <= 0 then 
                Box.Visible = false; Name.Visible = false; Health.Visible = false; Weapon.Visible = false
                return 
            end

            local pos, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            if onScreen then
                local headPos = game.Workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = game.Workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 1.5

                Box.Visible = true
                Box.Size = Vector2.new(width, height)
                Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                Box.Color = Color3.fromRGB(255, 255, 255)

                Name.Visible = true
                Name.Text = player.Name
                Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 15)
                Name.Center = true; Name.Outline = true

                Health.Visible = true
                Health.Text = math.floor(hum.Health) .. " HP"
                Health.Color = Color3.fromHSV(math.clamp(hum.Health/100, 0, 1) * 0.3, 1, 1)
                Health.Position = Vector2.new(pos.X + width / 2 + 5, pos.Y - height / 2)

                local tool = player.Character:FindFirstChildOfClass("Tool")
                Weapon.Visible = true
                Weapon.Text = tool and tool.Name or "Hands"
                Weapon.Position = Vector2.new(pos.X, pos.Y + height / 2 + 5)
                Weapon.Center = true; Weapon.Outline = true
            else
                Box.Visible = false; Name.Visible = false; Health.Visible = false; Weapon.Visible = false
            end
        else
            Box.Visible = false; Name.Visible = false; Health.Visible = false; Weapon.Visible = false
        end
    end)
end

for _, p in pairs(game.Players:GetPlayers()) do CreateESP(p) end
game.Players.PlayerAdded:Connect(CreateESP)

-- [МЕНЮ]
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local PlayerTab = Window:NewTab("Player")

local AimSection = Combat:NewSection("Aimbot Settings")
AimSection:NewToggle("Enable Aimbot", "Включить наводку", function(state) Settings.AimEnabled = state end)
AimSection:NewBind("Aim Key", "Клавиша зажатия", Enum.UserInputType.MouseButton2, function() end, function(key) Settings.AimBind = key end)
AimSection:NewSlider("Aim FOV", "Радиус захвата", 500, 10, function(s) 
    Settings.AimFOV = s 
    FOVCircle.Radius = s 
end)
AimSection:NewSlider("Smoothness", "Плавность", 20, 1, function(s) 
    Settings.AimSmooth = s 
end)
AimSection:NewToggle("Show FOV Circle", "Показывать круг", function(state) FOVCircle.Visible = state end)

local VisSection = Visuals:NewSection("ESP & HUD")
VisSection:NewToggle("Enable ESP", "Боксы + Инфо", function(state) Settings.EspEnabled = state end)
VisSection:NewToggle("Show HUD", "FPS / Ping панель", function(state) HUD.Enabled = state end)

local PlayerSection = PlayerTab:NewSection("Character")
PlayerSection:NewSlider("WalkSpeed", "Скорость бега", 150, 16, function(s) Settings.WalkSpeed = s end)

-- [ГЛАВНЫЙ ЦИКЛ]
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    -- Центровка FOV круга
    local cam = game.Workspace.CurrentCamera
    FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    
    -- Обновление статистики
    local fps = math.floor(1/RunService.RenderStepped:Wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    Stats.Text = "FPS: " .. fps .. " | PING: " .. ping .. "ms"

    -- Логика Аима
    Settings.IsAiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UIS:IsKeyDown(Settings.AimBind)

    if Settings.AimEnabled and Settings.IsAiming then
        local target = nil
        local shortestDist = Settings.AimFOV
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
                local part = v.Character[Settings.AimPart]
                local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < shortestDist then
                        target = part
                        shortestDist = mag
                    end
                end
            end
        end

        if target then
            -- Вычисление плавности (Smoothness)
            local targetCFrame = CFrame.new(cam.CFrame.Position, target.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCFrame, 1 / Settings.AimSmooth)
        end
    end

    -- Скорость игрока
    local lp = game.Players.LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end
end)

-- Управление меню
UIS.InputBegan:Connect(function(input, proc)
    if not proc and input.KeyCode == Enum.KeyCode.P then
        Library:Toggle()
    end
end)
