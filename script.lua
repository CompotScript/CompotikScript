-- [[ COMPOT ELITE: XENO ULTIMATE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Config = {
    Aimbot = true, Fov = 150, Smooth = 0.08,
    ESP = true, Skeleton = true, Names = true, Weapons = true,
    SpeedEnabled = true, WalkSpeed = 50, -- По умолчанию выше обычного
    MenuVisible = true, AimKey = Enum.KeyCode.H, MenuKey = Enum.KeyCode.P
}

-- === DRAWING API (HUD, FOV, ESP) ===
local function CreateDraw(type, properties)
    local obj = Drawing.new(type)
    for i, v in pairs(properties) do obj[i] = v end
    return obj
end

local HudText = CreateDraw("Text", {Size = 20, Color = Color3.fromRGB(0, 255, 150), Outline = true, Position = Vector2.new(20, 40), Visible = true})
local FovCircle = CreateDraw("Circle", {Thickness = 1, Color = Color3.fromRGB(0, 255, 150), Visible = true})

local ESP_Data = {}
local function CreateESP(p)
    ESP_Data[p] = {
        Box = CreateDraw("Square", {Thickness = 1, Color = Color3.new(1,1,1)}),
        Name = CreateDraw("Text", {Size = 14, Center = true, Outline = true, Color = Color3.new(1,1,1)}),
        Weapon = CreateDraw("Text", {Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(0, 255, 150)}),
        Bones = {}
    }
    local bones = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"}}
    for _=1, #bones do table.insert(ESP_Data[p].Bones, {CreateDraw("Line", {Thickness = 1, Color = Color3.new(1,1,1)}), bones[_]}) end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LP then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

-- === ОБРАБОТКА ЛОГИКИ КАЖДЫЙ КАДР ===
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- HUD ОБНОВЛЕНИЕ
    local fps = math.floor(1/task.wait())
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    HudText.Text = string.format("COMPOT ELITE\nFPS: %d | PING: %dms\nSPEED: %d (Press H for Aim)", fps, ping, Config.WalkSpeed)
    HudText.Visible = true

    -- FOV
    FovCircle.Position = center
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Aimbot

    -- SPEED HACK (ЖЕСТКИЙ МЕТОД)
    if Config.SpeedEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local hum = LP.Character.Humanoid
        hum.WalkSpeed = Config.WalkSpeed
        -- Дополнительный пинок скорости, если игра сбрасывает WalkSpeed
        if hum.MoveDirection.Magnitude > 0 then
            LP.Character:TranslateBy(hum.MoveDirection * (Config.WalkSpeed / 100))
        end
    end

    -- ESP & AIM
    for p, v in pairs(ESP_Data) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local hrp = p.Character.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            if vis and Config.ESP then
                local h = math.abs(Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.8, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.8, 0)).Y)
                local w = h * 0.6
                v.Box.Size = Vector2.new(w, h)
                v.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                v.Box.Visible = true
                v.Name.Text = p.Name; v.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15); v.Name.Visible = true
                local tool = p.Character:FindFirstChildOfClass("Tool")
                v.Weapon.Text = tool and tool.Name or "Hands"
                v.Weapon.Position = Vector2.new(pos.X, pos.Y + h/2 + 5); v.Weapon.Visible = true
            else
                v.Box.Visible = false v.Name.Visible = false v.Weapon.Visible = false
            end
        else
            v.Box.Visible = false v.Name.Visible = false v.Weapon.Visible = false
        end
    end

    if Config.Aimbot then
        local target, minMag = nil, Config.Fov
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local pPos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(pPos.X, pPos.Y) - center).Magnitude
                    if mag < minMag then target = pPos minMag = mag end
                end
            end
        end
        if target then mousemoverel((target.X - center.X) * Config.Smooth, (target.Y - center.Y) * Config.Smooth) end
    end
end)

-- === УПРАВЛЕНИЕ ===
UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Config.AimKey then
        Config.Aimbot = not Config.Aimbot
    elseif i.KeyCode == Enum.KeyCode.Up then -- На стрелочку вверх + скорость
        Config.WalkSpeed = Config.WalkSpeed + 10
    elseif i.KeyCode == Enum.KeyCode.Down then -- На стрелочку вниз - скорость
        Config.WalkSpeed = math.max(16, Config.WalkSpeed - 10)
    end
end)
