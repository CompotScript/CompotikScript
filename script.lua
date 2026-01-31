-- [[ COMPOT SCRIPT: DM ARENA OPTIMIZED ]] --

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow({ Title = 'CompotScript | DM Arena', Center = true, AutoShow = true })

local Settings = {
    AimBot = false,
    Fov = 150,
    Smoothness = 0.2, -- Чем ниже, тем жестче липнет
    ShowFov = true
}

-- === КРАСИВЫЙ HUD (КАК НА СКРИНЕ) ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 50)
MainFrame.Position = UDim2.new(0, 10, 0, 45) -- Сдвинул чуть ниже иконок Roblox
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.3

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.Text = "COMPOT SCRIPT"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.BackgroundTransparency = 1

local Stats = Instance.new("TextLabel", MainFrame)
Stats.Position = UDim2.new(0, 0, 0.5, 0)
Stats.Size = UDim2.new(1, 0, 0.5, 0)
Stats.Text = "FPS: 0 | PING: 0ms"
Stats.Font = Enum.Font.Code
Stats.TextColor3 = Color3.fromRGB(180, 180, 180)
Stats.TextSize = 12
Stats.BackgroundTransparency = 1

task.spawn(function()
    while task.wait(0.5) do
        local fps = math.floor(1/task.wait())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        Stats.Text = string.format("FPS: %d | PING: %dms", fps, ping)
    end
end)

-- === ЛОГИКА AIM И FOV ===
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false

local function GetClosestToCenter()
    local target = nil
    local dist = Settings.Fov
    local center = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            -- Целимся в Пузо (HumanoidRootPart или UpperTorso)
            local part = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < dist then
                        target = part
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

game:GetService("RunService").RenderStepped:Connect(function()
    local center = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
    
    FovCircle.Visible = Settings.ShowFov
    FovCircle.Radius = Settings.Fov
    FovCircle.Position = center

    if Settings.AimBot then
        local target = GetClosestToCenter()
        if target then
            local tPos = workspace.CurrentCamera:WorldToViewportPoint(target.Position)
            -- Наведение через mousemoverel (Xeno)
            mousemoverel((tPos.X - center.X) * Settings.Smoothness, (tPos.Y - center.Y) * Settings.Smoothness)
        end
    end
end)

-- === МЕНЮ ===
local Tabs = { Main = Window:AddTab('Combat') }
local AimSection = Tabs.Main:AddLeftGroupbox('Aimbot Settings')

AimSection:AddToggle('AimToggle', { Text = 'Enable Aimbot', Default = false }):OnChanged(function()
    Settings.AimBot = Toggles.AimToggle.Value
end)

AimSection:AddSlider('FovSlider', { Text = 'FOV Radius', Default = 150, Min = 10, Max = 500, Rounding = 0 }):OnChanged(function()
    Settings.Fov = Options.FovSlider.Value
end)

AimSection:AddSlider('SmoothSlider', { Text = 'Smoothness', Default = 0.2, Min = 0.05, Max = 1, Rounding = 2 }):OnChanged(function()
    Settings.Smoothness = Options.SmoothSlider.Value
end)

AimSection:AddToggle('FovVisible', { Text = 'Show FOV Circle', Default = true }):OnChanged(function()
    Settings.ShowFov = Toggles.FovVisible.Value
end)

Window:SetKeybind(Enum.KeyCode.P)
Library:Notify("CompotScript Loaded. Press P to toggle menu.")
