-- [[ COMPOT SCRIPT: ELITE UPDATE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Настройки
local Config = {
    Aimbot = true,
    Fov = 150,
    Smooth = 0.08,
    ESP = true,
    Skeleton = false,
    HUD = true,
    Speed = 16,
    MenuVisible = true
}

-- === DRAWING API (FOV КРУГ) ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.Color = Color3.fromRGB(0, 255, 150)
FovCircle.Filled = false
FovCircle.Visible = true

-- === ГУИ МЕНЮ И HUD ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- КРУПНЫЙ HUD (Сверху слева)
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 220, 0, 80) -- Увеличен размер
HudFrame.Position = UDim2.new(0, 15, 0, 15)
HudFrame.BackgroundColor3 = Color3.new(0,0,0)
HudFrame.BackgroundTransparency = 0.4
Instance.new("UICorner", HudFrame)

local HudText = Instance.new("TextLabel", HudFrame)
HudText.Size = UDim2.new(1, 0, 1, 0)
HudText.Text = "CompotScript"
HudText.TextColor3 = Color3.fromRGB(0, 255, 150)
HudText.Font = Enum.Font.GothamBold
HudText.TextSize = 22 -- Увеличен шрифт заголовка
HudText.TextYAlignment = Enum.TextYAlignment.Top
HudText.BackgroundTransparency = 1

local StatsText = Instance.new("TextLabel", HudFrame)
StatsText.Size = UDim2.new(1, 0, 0.5, 0)
StatsText.Position = UDim2.new(0, 0, 0.4, 0)
StatsText.Text = "FPS: ... | PING: ..."
StatsText.TextColor3 = Color3.new(1, 1, 1)
StatsText.Font = Enum.Font.Code
StatsText.TextSize = 16 -- Увеличен шрифт статов
StatsText.BackgroundTransparency = 1

-- МЕНЮ НАСТРОЕК
local MainMenu = Instance.new("Frame", ScreenGui)
MainMenu.Size = UDim2.new(0, 250, 0, 320)
MainMenu.Position = UDim2.new(0.5, -125, 0.5, -160)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.Visible = Config.MenuVisible
Instance.new("UICorner", MainMenu)
local Stroke = Instance.new("UIStroke", MainMenu)
Stroke.Color = Color3.fromRGB(0, 255, 150)
Stroke.Thickness = 2

local MenuTitle = Instance.new("TextLabel", MainMenu)
MenuTitle.Size = UDim2.new(1, 0, 0, 50)
MenuTitle.Text = "SETTINGS"
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextColor3 = Color3.new(1,1,1)
MenuTitle.TextSize = 20
MenuTitle.BackgroundTransparency = 1

local function CreateToggle(name, text, pos, extraInfo)
    local btn = Instance.new("TextButton", MainMenu)
    btn.Size = UDim2.new(0, 210, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, pos)
    btn.Text = text .. ": ON" .. (extraInfo or "")
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Config[name] = not Config[name]
        btn.Text = text .. ": " .. (Config[name] and "ON" or "OFF") .. (extraInfo or "")
        btn.TextColor3 = Config[name] and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
    end)
    return btn
end

local aimBtn = CreateToggle("Aimbot", "AimBot", 60, " [H]")
CreateToggle("ESP", "Box ESP", 100)
CreateToggle("Skeleton", "Skeleton ESP", 140)
CreateToggle("HUD", "Show HUD", 180)

-- === ЛОГИКА ===
local function GetClosest()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local target, minDist = nil, Config.Fov
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local part = p.Character.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(part.Position)
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
    
    FovCircle.Position = center
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Aimbot
    
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsText.Text = string.format("FPS: %d | PING: %dms", fps, ping)
    HudFrame.Visible = Config.HUD
    
    if Config.Aimbot then
        local t = GetClosest()
        if t and mousemoverel then
            mousemoverel((t.X - center.X) * Config.Smooth, (t.Y - center.Y) * Config.Smooth)
        end
    end
    
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.Speed
    end
end)

-- === ОБРАБОТКА БИНДОВ ===
UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    
    -- P - Открыть/Закрыть меню
    if input.KeyCode == Enum.KeyCode.P then
        Config.MenuVisible = not Config.MenuVisible
        MainMenu.Visible = Config.MenuVisible
    end
    
    -- H - Вкл/Выкл Аимбот
    if input.KeyCode == Enum.KeyCode.H then
        Config.Aimbot = not Config.Aimbot
        aimBtn.Text = "AimBot: " .. (Config.Aimbot and "ON [H]" or "OFF [H]")
        aimBtn.TextColor3 = Config.Aimbot and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
    end
end)
