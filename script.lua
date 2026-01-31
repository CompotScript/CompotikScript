-- [[ COMPOT ELITE: ULTIMATE CS EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Конфиг
local Config = {
    Aimbot = true,
    Fov = 150,
    Smooth = 0.08,
    ESP = true,
    Skeleton = true,
    SpeedEnabled = true,
    WalkSpeed = 50,
    Visible = true
}

-- === КРАСИВЫЙ HUD (Стеклянный стиль) ===
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 220, 0, 70)
HudFrame.Position = UDim2.new(0, 15, 0, 15)
HudFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
HudFrame.BorderSizePixel = 0
Instance.new("UICorner", HudFrame).CornerRadius = UDim.new(0, 8)

local Line = Instance.new("Frame", HudFrame)
Line.Size = UDim2.new(1, 0, 0, 2)
Line.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
Line.BorderSizePixel = 0
Instance.new("UICorner", Line)

local HudTitle = Instance.new("TextLabel", HudFrame)
HudTitle.Size = UDim2.new(1, 0, 0, 35)
HudTitle.Text = "COMPOT.ELITE"
HudTitle.TextColor3 = Color3.new(1,1,1)
HudTitle.Font = Enum.Font.GothamBold
HudTitle.TextSize = 16
HudTitle.BackgroundTransparency = 1

local HudStats = Instance.new("TextLabel", HudFrame)
HudStats.Position = UDim2.new(0, 0, 0, 30)
HudStats.Size = UDim2.new(1, 0, 0, 30)
HudStats.Text = "FPS: ... | PING: ..."
HudStats.TextColor3 = Color3.fromRGB(200, 200, 200)
HudStats.Font = Enum.Font.Code
HudStats.TextSize = 14
HudStats.BackgroundTransparency = 1

-- === CS-STYLE GUI (Меню) ===
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 400, 0, 300)
Main.Position = UDim2.new(0.5, -200, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Visible = Config.Visible
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(40, 40, 40)
Stroke.Thickness = 2

local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 100, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SideBar.BorderSizePixel = 0
Instance.new("UICorner", SideBar)

local MenuTitle = Instance.new("TextLabel", SideBar)
MenuTitle.Size = UDim2.new(1, 0, 0, 40)
MenuTitle.Text = "MENU"
MenuTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.BackgroundTransparency = 1

local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 110, 0, 10)
Container.Size = UDim2.new(1, -120, 1, -20)
Container.BackgroundTransparency = 1

local function CreateToggle(text, cfg_key, pos)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    
    local function Update()
        btn.Text = text .. ": " .. (Config[cfg_key] and "ON" or "OFF")
        btn.TextColor3 = Config[cfg_key] and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
    end
    btn.MouseButton1Click:Connect(function() Config[cfg_key] = not Config[cfg_key] Update() end)
    Update()
end

CreateToggle("AimBot [H]", "Aimbot", 0)
CreateToggle("Player ESP", "ESP", 45)
CreateToggle("Skeleton ESP", "Skeleton", 90)
CreateToggle("Speed Enabled", "SpeedEnabled", 135)

-- Скорость +/-
local SLabel = Instance.new("TextLabel", Container)
SLabel.Size = UDim2.new(1, 0, 0, 30)
SLabel.Position = UDim2.new(0, 0, 0, 180)
SLabel.Text = "WalkSpeed: " .. Config.WalkSpeed
SLabel.TextColor3 = Color3.new(1,1,1)
SLabel.BackgroundTransparency = 1

local function SBtn(text, x, val)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(0.45, 0, 0, 30)
    b.Position = UDim2.new(x, 0, 0, 215)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Config.WalkSpeed = math.clamp(Config.WalkSpeed + val, 16, 200)
        SLabel.Text = "WalkSpeed: " .. Config.WalkSpeed
    end)
end
SBtn("- Speed", 0, -10)
SBtn("+ Speed", 0.55, 10)

-- === ОСНОВНАЯ ЛОГИКА (SPEED / AIM) ===
RunService.RenderStepped:Connect(function()
    -- Обновление HUD
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    HudStats.Text = "FPS: " .. fps .. " | PING: " .. ping .. "ms"

    -- Aim
    if Config.Aimbot then
        local target, dist = nil, Config.Fov
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < dist then target = pos dist = mag end
                end
            end
        end
        if target and mousemoverel then
            mousemoverel((target.X - center.X) * Config.Smooth, (target.Y - center.Y) * Config.Smooth)
        end
    end

    -- SPEED (ПРИНУДИТЕЛЬНО)
    if Config.SpeedEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

-- Бинды
UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Config.MenuKey then
        Config.Visible = not Config.Visible
        Main.Visible = Config.Visible
    elseif input.KeyCode == Enum.KeyCode.H then
        Config.Aimbot = not Config.Aimbot
    end
end)
