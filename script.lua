-- [[ COMPOT ELITE: HARDCORE DRAWING EDITION ]] --
if not Drawing then print("XENO ERROR: Drawing API not found!") return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Настройки
local Config = {
    Aim = true, Fov = 150, Smooth = 0.1, Target = "Head",
    Speed = 60, ESP = true, Skeletons = true
}

-- === DRAWING HUD (Прямая отрисовка) ===
local HudBase = Drawing.new("Text")
HudBase.Visible = true
HudBase.Size = 20
HudBase.Color = Color3.fromRGB(0, 255, 150)
HudBase.Outline = true
HudBase.Position = Vector2.new(30, 50)

local FovRing = Drawing.new("Circle")
FovRing.Thickness = 1
FovRing.Color = Color3.fromRGB(0, 255, 150)

-- Хранилище для скелетов
local Bones = {}

local function CreateSkeleton(p)
    Bones[p] = {
        L1 = Drawing.new("Line"), L2 = Drawing.new("Line"), 
        L3 = Drawing.new("Line"), L4 = Drawing.new("Line")
    }
    for _, line in pairs(Bones[p]) do
        line.Thickness = 1
        line.Color = Color3.new(1,1,1)
    end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LP then CreateSkeleton(p) end end
Players.PlayerAdded:Connect(CreateSkeleton)

-- === ГЛАВНЫЙ ЦИКЛ (RENDER) ===
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Обновление HUD
    HudBase.Text = string.format(
        "COMPOT ELITE\n[H] AIM: %s\n[J] TARGET: %s\n[K/L] SPEED: %d\n[UP/DN] FOV: %d\n[L/R] SMOOTH: %.2f",
        tostring(Config.Aim), Config.Target, Config.Speed, Config.Fov, Config.Smooth
    )

    -- FOV Ring
    FovRing.Visible = Config.Aim
    FovRing.Radius = Config.Fov
    FovRing.Position = center

    -- SPEED (HARD METHOD)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local hum = LP.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Config.Speed / 100))
        end
    end

    -- AIM & ESP
    for p, b in pairs(Bones) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local char = p.Character
            local root = char.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(root.Position)
            
            if vis and Config.Skeletons then
                -- Примитивный скелет (Линии от головы к ногам)
                local head = Camera:WorldToViewportPoint(char.Head.Position)
                local larm = Camera:WorldToViewportPoint(char:FindFirstChild("LeftUpperArm") and char.LeftUpperArm.Position or root.Position)
                local rarm = Camera:WorldToViewportPoint(char:FindFirstChild("RightUpperArm") and char.RightUpperArm.Position or root.Position)
                
                b.L1.From, b.L1.To = Vector2.new(head.X, head.Y), Vector2.new(pos.X, pos.Y)
                b.L1.Visible = true
            else
                b.L1.Visible = false
            end
        else
            b.L1.Visible = false
        end
    end

    -- AIMBOT
    if Config.Aim then
        local target = nil
        local minDist = Config.Fov
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild(Config.Target) then
                local part = p.Character[Config.Target]
                local pPos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local mag = (Vector2.new(pPos.X, pPos.Y) - center).Magnitude
                    if mag < minDist then target = pPos minDist = mag end
                end
            end
        end
        if target and mousemoverel then
            mousemoverel((target.X - center.X) * Config.Smooth, (target.Y - center.Y) * Config.Smooth)
        end
    end
end)

-- === УПРАВЛЕНИЕ КЛАВИШАМИ ===
UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Enum.KeyCode.H then Config.Aim = not Config.Aim
    elseif input.KeyCode == Enum.KeyCode.J then Config.Target = (Config.Target == "Head" and "UpperTorso" or "Head")
    elseif input.KeyCode == Enum.KeyCode.K then Config.Speed = Config.Speed + 10
    elseif input.KeyCode == Enum.KeyCode.L then Config.Speed = math.max(16, Config.Speed - 10)
    elseif input.KeyCode == Enum.KeyCode.Up then Config.Fov = Config.Fov + 20
    elseif input.KeyCode == Enum.KeyCode.Down then Config.Fov = math.max(10, Config.Fov - 20)
    elseif input.KeyCode == Enum.KeyCode.Right then Config.Smooth = math.min(1, Config.Smooth + 0.05)
    elseif input.KeyCode == Enum.KeyCode.Left then Config.Smooth = math.max(0.01, Config.Smooth - 0.05)
    end
end)
