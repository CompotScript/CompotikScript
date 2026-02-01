-- [[ COMPOT ELITE: ULTIMATE V4 ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Config = {
    Aimbot = true,
    Fov = 150,
    Smooth = 0.1,
    TargetPart = "Head", -- Head или UpperTorso
    ESP = true,
    Skeletons = true,
    WalkSpeed = 60,
    MenuVisible = true
}

-- === КРАСИВЫЙ HUD И МЕНЮ ===
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "Compot_Elite_V4"

-- Фоновый HUD (Левый верхний угол)
local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.new(0, 200, 0, 80)
HudFrame.Position = UDim2.new(0, 15, 0, 15)
HudFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", HudFrame)
Instance.new("UIStroke", HudFrame).Color = Color3.fromRGB(0, 255, 150)

local HudLabel = Instance.new("TextLabel", HudFrame)
HudLabel.Size = UDim2.new(1, 0, 1, 0)
HudLabel.BackgroundTransparency = 1
HudLabel.TextColor3 = Color3.new(1,1,1)
HudLabel.Font = Enum.Font.Code
HudLabel.TextSize = 14
HudLabel.Text = "COMPOT ELITE\nAim: ON [H]\nPart: Head"

-- ОСНОВНОЕ CS-МЕНЮ
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 450, 0, 350)
Main.Position = UDim2.new(0.5, -225, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Visible = Config.MenuVisible
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(40, 40, 40)

local function CreateBtn(text, pos, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 180, 0, 35)
    b.Position = UDim2.new(0, 20, 0, pos)
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- Кнопки управления
CreateBtn("Toggle Aim [H]", 60, function() Config.Aimbot = not Config.Aimbot end)
CreateBtn("Part: Head", 100, function(b) 
    if Config.TargetPart == "Head" then 
        Config.TargetPart = "UpperTorso"
    else 
        Config.TargetPart = "Head" 
    end
end)
CreateBtn("Skeleton ESP", 140, function() Config.Skeletons = not Config.Skeletons end)
CreateBtn("Speed +", 180, function() Config.WalkSpeed = Config.WalkSpeed + 10 end)
CreateBtn("Speed -", 220, function() Config.WalkSpeed = math.max(16, Config.WalkSpeed - 10) end)

-- === SKELETON ESP (ЖЕСТКИЙ МЕТОД) ===
local function AddSkeleton(char)
    local p = Players:GetPlayerFromCharacter(char)
    if not p or p == LP then return end
    
    RunService.RenderStepped:Connect(function()
        if Config.Skeletons and char and char:FindFirstChild("HumanoidRootPart") then
            -- Здесь можно добавить отрисовку линий через Beam или Adornments
            -- Для DM Arena используем Highlight (самый стабильный)
            if not char:FindFirstChild("CompotHighlight") then
                local hl = Instance.new("Highlight", char)
                hl.Name = "CompotHighlight"
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.new(1,1,1)
            end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do if p.Character then AddSkeleton(p.Character) end p.CharacterAdded:Connect(AddSkeleton) end

-- === ГЛАВНЫЙ ЦИКЛ ===
RunService.RenderStepped:Connect(function()
    HudLabel.Text = string.format("COMPOT ELITE\nAim: %s [H]\nPart: %s\nSpeed: %d", tostring(Config.Aimbot), Config.TargetPart, Config.WalkSpeed)
    
    -- Speed Hack
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.WalkSpeed
        if LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
            LP.Character:TranslateBy(LP.Character.Humanoid.MoveDirection * (Config.WalkSpeed / 160))
        end
    end

    -- Aimbot Logic
    if Config.Aimbot then
        local target = nil
        local dist = Config.Fov
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild(Config.TargetPart) then
                local part = p.Character[Config.TargetPart]
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local m = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if m < dist then target = pos dist = m end
                end
            end
        end
        
        if target and mousemoverel then
            mousemoverel((target.X - center.X) * Config.Smooth, (target.Y - center.Y) * Config.Smooth)
        end
    end
end)

-- Бинды
UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.P then Main.Visible = not Main.Visible
    elseif i.KeyCode == Enum.KeyCode.H then Config.Aimbot = not Config.Aimbot end
end)
