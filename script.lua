-- [[ COMPOT ELITE: PRO VERSION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Config = {
    Aimbot = true, Fov = 150, Smooth = 0.08,
    ESP = true, Skeleton = true, Names = true, Weapons = true,
    SpeedEnabled = true, WalkSpeed = 35,
    MenuKey = Enum.KeyCode.P, AimKey = Enum.KeyCode.H, Visible = true
}

-- === DRAWING API TOOLS ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(0, 255, 150)
FovCircle.Visible = true

local ESP_Data = {}

local function CreateESP(p)
    local data = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Weapon = Drawing.new("Text"),
        Bones = {}
    }
    data.Box.Thickness = 1
    data.Box.Color = Color3.new(1,1,1)
    data.Name.Size = 14
    data.Name.Center = true
    data.Name.Outline = true
    data.Name.Color = Color3.new(1,1,1)
    data.Weapon.Size = 13
    data.Weapon.Center = true
    data.Weapon.Outline = true
    data.Weapon.Color = Color3.fromRGB(0, 255, 150)
    
    local connections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
    }
    for i=1, #connections do
        local l = Drawing.new("Line")
        l.Thickness = 1
        l.Color = Color3.new(1,1,1)
        table.insert(data.Bones, {l, connections[i]})
    end
    ESP_Data[p] = data
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LP then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESP_Data[p] then
        ESP_Data[p].Box:Remove()
        ESP_Data[p].Name:Remove()
        ESP_Data[p].Weapon:Remove()
        for _, b in pairs(ESP_Data[p].Bones) do b[1]:Remove() end
        ESP_Data[p] = nil
    end
end)

-- === CS GUI ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 380)
Main.Position = UDim2.new(0.5, -250, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Visible = Config.Visible
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 150)

local Container = Instance.new("ScrollingFrame", Main)
Container.Position = UDim2.new(0, 10, 0, 10)
Container.Size = UDim2.new(1, -20, 1, -20)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0,0,1.5,0)
Container.ScrollBarThickness = 2

local function AddToggle(text, cfg_key)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(0, 220, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        Config[cfg_key] = not Config[cfg_key]
        btn.BackgroundColor3 = Config[cfg_key] and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(25, 25, 25)
    end)
    Instance.new("UIListLayout", Container).Padding = UDim.new(0,5)
end

AddToggle("Enable Aimbot [H]", "Aimbot")
AddToggle("Show Box ESP", "ESP")
AddToggle("Show Skeleton", "Skeleton")
AddToggle("Show Names", "Names")
AddToggle("Show Weapons", "Weapons")

-- === LOGIC ===
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Position = center
    FovCircle.Radius = Config.Fov
    FovCircle.Visible = Config.Aimbot

    for p, v in pairs(ESP_Data) do
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
            local hrp = char.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            
            if vis and Config.ESP then
                local top = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.5, 0))
                local bottom = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
                local h = math.abs(top.Y - bottom.Y)
                local w = h * 0.6
                
                v.Box.Size = Vector2.new(w, h)
                v.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                v.Box.Visible = true
                
                v.Name.Text = p.Name
                v.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15)
                v.Name.Visible = Config.Names
                
                local tool = char:FindFirstChildOfClass("Tool")
                v.Weapon.Text = tool and tool.Name or "Hands"
                v.Weapon.Position = Vector2.new(pos.X, pos.Y + h/2 + 5)
                v.Weapon.Visible = Config.Weapons
                
                if Config.Skeleton then
                    for _, bone in pairs(v.Bones) do
                        local b1 = char:FindFirstChild(bone[2][1])
                        local b2 = char:FindFirstChild(bone[2][2])
                        if b1 and b2 then
                            local p1 = Camera:WorldToViewportPoint(b1.Position)
                            local p2 = Camera:WorldToViewportPoint(b2.Position)
                            bone[1].From = Vector2.new(p1.X, p1.Y)
                            bone[1].To = Vector2.new(p2.X, p2.Y)
                            bone[1].Visible = true
                        else bone[1].Visible = false end
                    end
                else for _, b in pairs(v.Bones) do b[1].Visible = false end end
            else
                v.Box.Visible = false v.Name.Visible = false v.Weapon.Visible = false
                for _, b in pairs(v.Bones) do b[1].Visible = false end
            end
        else
            v.Box.Visible = false v.Name.Visible = false v.Weapon.Visible = false
            for _, b in pairs(v.Bones) do b[1].Visible = false end
        end
    end

    if Config.Aimbot then
        local target, minMag = nil, Config.Fov
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pPos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(pPos.X, pPos.Y) - center).Magnitude
                    if mag < minMag then target = pPos minMag = mag end
                end
            end
        end
        if target then mousemoverel((target.X - center.X) * Config.Smooth, (target.Y - center.Y) * Config.Smooth) end
    end
    if Config.SpeedEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Config.MenuKey then Config.Visible = not Config.Visible Main.Visible = Config.Visible
    elseif i.KeyCode == Config.AimKey then Config.Aimbot = not Config.Aimbot end
end)
