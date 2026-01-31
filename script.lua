--[[
    CompotScript - Full Edition (DM Arena)
    Функции: ESP, Aimbot (with Bind), Speed, HUD, FOV Circle
    Кнопка управления меню: P
--]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("CompotScript", "DarkTheme")

-- Настройки
local Settings = {
    AimEnabled = false,
    AimPart = "Head",
    AimFOV = 150,
    AimBind = Enum.UserInputType.MouseButton1, -- Бинд по умолчанию
    IsAiming = false, -- Состояние нажатия клавиши
    WalkSpeed = 16,
    EspEnabled = false,
    FovVisible = true
}

-- [FOV КРУГ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 127)
FOVCircle.Transparency = 0.8
FOVCircle.Visible = Settings.FovVisible
FOVCircle.Radius = Settings.AimFOV

-- [HUD]
local HUD = Instance.new("ScreenGui")
HUD.Name = "CompotHUD"
HUD.Parent = game:GetService("CoreGui")
local MainHud = Instance.new("Frame", HUD)
MainHud.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainHud.Position = UDim2.new(0, 10, 0, 10)
MainHud.Size = UDim2.new(0, 180, 0, 50)
Instance.new("UICorner", MainHud).CornerRadius = UDim.new(0, 8)

local Stats = Instance.new("TextLabel", MainHud)
Stats.Size = UDim2.new(1, 0, 1, 0)
Stats.BackgroundTransparency = 1
Stats.TextColor3 = Color3.fromRGB(255, 255, 255)
Stats.Font = Enum.Font.GothamBold
Stats.TextSize = 12

-- [МЕНЮ]
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local PlayerTab = Window:NewTab("Player")

local AimSection = Combat:NewSection("Aimbot")
AimSection:NewToggle("Enable Aimbot", "Включить аим", function(state) Settings.AimEnabled = state end)

AimSection:NewBind("Aim Bind", "Кнопка активации", Enum.KeyCode.E, function()
    -- Эта функция в Kavo для KeyCode, ниже в InputBegan мы обработаем всё гибко
end, function(key)
    Settings.AimBind = key
end)

AimSection:NewSlider("FOV Radius", "Радиус круга", 500, 50, function(s) 
    Settings.AimFOV = s 
    FOVCircle.Radius = s
end)

AimSection:NewToggle("Show FOV Circle", "Показывать круг", function(state) 
    FOVCircle.Visible = state
end)

local EspSection = Visuals:NewSection("Visuals")
EspSection:NewToggle("ESP Highlight", "Подсветка", function(state) Settings.EspEnabled = state end)

local SpeedSection = PlayerTab:NewSection("Movement")
SpeedSection:NewSlider("WalkSpeed", "Скорость", 150, 16, function(s) Settings.WalkSpeed = s end)

-- [ЛОГИКА]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

-- Проверка видимости (Wall Check)
local function IsVisible(targetPart)
    local castPoints = {Camera.CFrame.Position, targetPart.Position}
    local ignoreList = {LocalPlayer.Character, targetPart.Parent}
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    
    local ray = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, params)
    if ray and ray.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

local function GetClosest()
    local target = nil
    local dist = Settings.AimFOV
    local mousePos = UIS:GetMouseLocation()

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            local part = v.Character[Settings.AimPart]
            local pos, vis = Camera:WorldToViewportPoint(part.Position)
            
            if vis then
                local magnitude = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if magnitude < dist and IsVisible(part) then
                    target = v
                    dist = magnitude
                end
            end
        end
    end
    return target
end

-- Обработка зажатия бинда
UIS.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Settings.AimBind or input.UserInputType == Settings.AimBind then
        Settings.IsAiming = true
    end
    if input.KeyCode == Enum.KeyCode.P then
        Library:Toggle()
        HUD.Enabled = not HUD.Enabled
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.AimBind or input.UserInputType == Settings.AimBind then
        Settings.IsAiming = false
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    -- Обновление HUD и Круга
    FOVCircle.Position = UIS:GetMouseLocation()
    local fps = math.floor(1/game:GetService("RunService").RenderStepped:Wait())
    Stats.Text = "CompotScript | FPS: " .. fps

    -- Логика Аима
    if Settings.AimEnabled and Settings.IsAiming then
        local target = GetClosest()
        if target then
            local targetPos = target.Character[Settings.AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 0.2) -- Плавная наводка
        end
    end
    
    -- Скорость
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end
    
    -- ESP
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local h = v.Character:FindFirstChild("CompotESP")
            if Settings.EspEnabled and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                if not h then
                    h = Instance.new("Highlight", v.Character)
                    h.Name = "CompotESP"
                    h.FillColor = Color3.fromRGB(0, 255, 127)
                end
                h.Enabled = true
            elseif h then 
                h.Enabled = false 
            end
        end
    end
end)
