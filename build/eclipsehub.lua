-- ============================================
-- ECLIPSE HUB - SCRIPT FINAL (COMPLETO)
-- ============================================

-- ============================================
-- UTILS.LIBRARY
-- ============================================
local Utils = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

function Utils.getCharacter(player)
    player = player or LocalPlayer
    local char = player.Character
    if not char or not char.Parent then
        char = player.CharacterAdded:Wait()
    end
    return char
end

function Utils.getHumanoid(player)
    local char = Utils.getCharacter(player)
    return char:FindFirstChild("Humanoid")
end

function Utils.getRootPart(player)
    local char = Utils.getCharacter(player)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

function Utils.getClosestPlayer(maxDistance)
    local root = Utils.getRootPart(LocalPlayer)
    if not root then return nil end
    local closest = nil
    local shortestDist = maxDistance or math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetRoot = Utils.getRootPart(player)
            if targetRoot then
                local dist = (root.Position - targetRoot.Position).magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

function Utils.worldToScreen(worldPos)
    local camera = workspace.CurrentCamera
    return camera:WorldToViewportPoint(worldPos)
end

function Utils.findRemote(name)
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:lower():find(string.lower(name)) then
                return obj
            end
        end
    end
    return nil
end

function Utils.log(msg, type)
    type = type or "INFO"
    print(string.format("[ECLIPSE HUB] [%s] %s", type, msg))
end

-- ============================================
-- REMOTES.LUA
-- ============================================
local Remotes = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

Remotes.Map = {
    PostieSent = ReplicatedStorage:FindFirstChild("PostieSent"),
    PostieReceived = ReplicatedStorage:FindFirstChild("PostieReceived"),
    RadarToggleEvent = ReplicatedStorage:FindFirstChild("RadarToggleEvent"),
}

function Remotes.cast()
    local remote = Remotes.Map.PostieSent
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer()
        Utils.log("🎣 Lançando a linha...", "FISH")
        return true
    else
        Utils.log("❌ Remote de pesca não encontrado!", "ERROR")
        return false
    end
end

function Remotes.reel()
    local remote = Remotes.Map.PostieReceived
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer()
        Utils.log("🐟 Puxando o peixe!", "FISH")
        return true
    else
        Utils.log("❌ Remote de receber não encontrado!", "ERROR")
        return false
    end
end

function Remotes.toggleRadar()
    local remote = Remotes.Map.RadarToggleEvent
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer()
        Utils.log("📡 Radar alternado!", "RADAR")
        return true
    else
        Utils.log("❌ Remote do radar não encontrado!", "ERROR")
        return false
    end
end

function Remotes.testAll()
    Utils.log("🧪 TESTANDO TODOS OS REMOTES...", "DEBUG")
    for name, remote in pairs(Remotes.Map) do
        if remote then
            Utils.log(string.format("✅ %s encontrado! (Tipo: %s)", name, remote.ClassName), "DEBUG")
        else
            Utils.log(string.format("❌ %s NÃO encontrado!", name), "DEBUG")
        end
    end
end

-- ============================================
-- FISCH.LUA
-- ============================================
local Fisch = {}

getgenv().Eclipse_AutoFish = false
getgenv().Eclipse_AutoReel = false
getgenv().Eclipse_AutoSell = false
getgenv().Eclipse_InfiniteOxygen = false

local function autoFishLoop()
    while getgenv().Eclipse_AutoFish do
        Remotes.cast()
        task.wait(1.5)
        if getgenv().Eclipse_AutoReel then
            Remotes.reel()
        end
        task.wait(2)
    end
end

function Fisch.toggleAutoFish()
    getgenv().Eclipse_AutoFish = not getgenv().Eclipse_AutoFish
    if getgenv().Eclipse_AutoFish then
        Utils.log("🎣 Auto Fish LIGADO!", "FISH")
        spawn(autoFishLoop)
    else
        Utils.log("🎣 Auto Fish DESLIGADO!", "FISH")
    end
end

function Fisch.toggleAutoReel()
    getgenv().Eclipse_AutoReel = not getgenv().Eclipse_AutoReel
    Utils.log("🐟 Auto Reel: " .. (getgenv().Eclipse_AutoReel and "ON" or "OFF"), "FISH")
end

local function autoSellLoop()
    while getgenv().Eclipse_AutoSell do
        local sellItems = workspace:FindFirstChild("Sell") 
            or workspace:FindFirstChild("Shop")
            or workspace:FindFirstChild("Merchant")
        if sellItems then
            local clickDetector = sellItems:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                Utils.log("💰 Vendendo peixes...", "SELL")
            end
        end
        task.wait(5)
    end
end

function Fisch.toggleAutoSell()
    getgenv().Eclipse_AutoSell = not getgenv().Eclipse_AutoSell
    if getgenv().Eclipse_AutoSell then
        Utils.log("💰 Auto Sell LIGADO!", "SELL")
        spawn(autoSellLoop)
    else
        Utils.log("💰 Auto Sell DESLIGADO!", "SELL")
    end
end

function Fisch.toggleInfiniteOxygen()
    getgenv().Eclipse_InfiniteOxygen = not getgenv().Eclipse_InfiniteOxygen
    if getgenv().Eclipse_InfiniteOxygen then
        local char = game.Players.LocalPlayer.Character
        local oxygen = char:FindFirstChild("Oxygen") or char.Humanoid:FindFirstChild("Oxygen")
        if oxygen then
            Utils.log("🫧 Oxigênio Infinito LIGADO!", "OXYGEN")
            game:GetService("RunService").Heartbeat:Connect(function()
                if getgenv().Eclipse_InfiniteOxygen and oxygen then
                    oxygen.Value = oxygen.MaxValue or 100
                end
            end)
        else
            Utils.log("⚠️ Oxigênio não encontrado! Procure por 'Oxygen' no jogo.", "WARN")
        end
    else
        Utils.log("🫧 Oxigênio Infinito DESLIGADO!", "OXYGEN")
    end
end

-- ============================================
-- MENU.LUA
-- ============================================
local Menu = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "EclipseHubGUI"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 350)
Frame.Position = UDim2.new(0.5, -125, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Text = "🌑 ECLIPSE HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = Frame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 35)
SubTitle.Text = "⚡ FISCH V1.0"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 200)
SubTitle.TextSize = 14
SubTitle.Font = Enum.Font.Gotham
SubTitle.BackgroundTransparency = 1
SubTitle.Parent = Frame

function Menu.createToggle(text, yPos, callback, initialState)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 220, 0, 35)
    button.Position = UDim2.new(0.5, -110, 0, yPos)
    button.Text = text .. ": " .. (initialState and "ON" or "OFF")
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.BackgroundColor3 = initialState and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(60, 60, 70)
    button.BorderSizePixel = 0
    button.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local state = initialState or false
    
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = text .. ": " .. (state and "ON" or "OFF")
        button.BackgroundColor3 = state and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(60, 60, 70)
        callback(state)
    end)
    
    return button
end

-- CRIANDO OS BOTÕES
Menu.createToggle("🎣 Auto Fish", 80, function(state)
    Fisch.toggleAutoFish()
end, false)

Menu.createToggle("🐟 Auto Reel", 125, function(state)
    Fisch.toggleAutoReel()
end, false)

Menu.createToggle("💰 Auto Sell", 170, function(state)
    Fisch.toggleAutoSell()
end, false)

Menu.createToggle("🫧 Infinite Oxygen", 215, function(state)
    Fisch.toggleInfiniteOxygen()
end, false)

local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 20)
Credits.Position = UDim2.new(0, 0, 0, 320)
Credits.Text = "By: Eclipse Developer"
Credits.TextColor3 = Color3.fromRGB(100, 100, 130)
Credits.TextSize = 11
Credits.Font = Enum.Font.Gotham
Credits.BackgroundTransparency = 1
Credits.Parent = Frame

-- ============================================
-- MAIN
-- ============================================
print("============================================")
print("  🌑 ECLIPSE HUB CARREGANDO...")
print("  Versão: TESTES")
print("  Jogo: Fisch")
print("============================================")

Utils.log("🧪 Testando remotes do Fisch...", "DEBUG")
Remotes.testAll()

Utils.log("📱 Carregando interface...", "UI")

Utils.log("✅ ECLIPSE HUB CARREGADO COM SUCESSO!", "SYSTEM")
print("============================================")
