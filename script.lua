-- [[ COMPOT ELITE: GOD MODE EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Config = {
    Aimbot = true,
    Fov = 150,
    ESP = true,
    Skeletons = true,
    Speed = 60,
    Visible = true
}

-- === КРАСИВЫЙ HUD (SCREEN GUI) ===
local function CreateUI()
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    sg.Name = "Compot_Elite"

    local hud = Instance.new("Frame", sg)
    hud.Size = UDim2.new(0, 200, 0, 60)
    hud.Position = UDim2.new(0, 20, 0, 20)
    hud.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", hud)

    local txt = Instance.new("TextLabel", hud)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(0, 255, 150)
    txt.Font = Enum.Font.Code
    txt.TextSize = 14
    
    local menu = Instance.new("Frame", sg)
    menu.Size = UDim2.new(0, 300, 0, 200)
    menu.Position = UDim2.new(0.5, -150, 0.5, -100)
    menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    menu.Visible = Config.Visible
    Instance.new("UICorner", menu)
    Instance.new("UIStroke", menu).Color = Color3.fromRGB(0, 255, 150)

    local title = Instance.new("TextLabel", menu)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "COMPOT SETTINGS [P]"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1

    return sg, txt, menu
end

local gui, hudText, mainMenu = CreateUI()

-- === ESP & SKELETON LOGIC ===
local function ApplyESP(p)
    if p == LP then return end
    p.CharacterAdded:Connect(function(char)
        wait(1)
        if not char:FindFirstChild("HumanoidRootPart") then return end
        
        -- Box & Info
        local bgu = Instance.new("BillboardGui", char.HumanoidRootPart)
        bgu.AlwaysOnTop = true
        bgu.Size = UDim2.new(4, 0, 5, 0)
        bgu.Name = "CompotESP"
        
        local frame = Instance.new("Frame", bgu)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(255, 0, 0)
        stroke.Thickness = 1
        
        local info = Instance.new("TextLabel", bgu)
        info.Size = UDim2.new(1, 0, 0, 20)
        info.Position = UDim2.new(0, 0, -0.3, 0)
        info.Text = p.Name
        info.TextColor3 = Color3.new(1,1,1)
        info.BackgroundTransparency = 1
    end)
end

for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)

-- === ОСНОВНОЙ ЦИКЛ ===
RunService.RenderStepped:Connect(function()
    -- HUD
    hudText.Text = string.format("COMPOT ELITE\nAim: %s | Spd: %d\n[P] Menu | [H] Aim", tostring(Config.Aimbot), Config.Speed)
    
    -- Speed
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.Speed
        if LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
            LP.Character:TranslateBy(LP.Character.Humanoid.MoveDirection * (Config.Speed / 150))
        end
    end

    -- Aim
    if Config.Aimbot then
        local target = nil
        local dist = Config.Fov
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local m = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if m < dist then target = pos dist = m end
                end
            end
        end
        if target and mousemoverel then
            mousemoverel((target.X - center.X) * 0.1, (target.Y - center.Y) * 0.1)
        end
    end
end)

-- === БИНДЫ ===
UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.P then
        Config.Visible = not Config.Visible
        mainMenu.Visible = Config.Visible
    elseif i.KeyCode == Enum.KeyCode.H then
        Config.Aimbot = not Config.Aimbot
    elseif i.KeyCode == Enum.KeyCode.K then
        Config.Speed = Config.Speed + 10
    elseif i.KeyCode == Enum.KeyCode.L then
        Config.Speed = math.max(16, Config.Speed - 10)
    end
end)
