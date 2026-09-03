print("============================================")
print("  🌑 ECLIPSE HUB CARREGANDO...")
print("  Versão: TESTES")
print("  Jogo: Fisch")
print("============================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Utils = {}
function Utils.log(msg, tipo)
    tipo = tipo or "INFO"
    print(string.format("[ECLIPSE HUB] [%s] %s", tipo, msg))
end

local Remotes = {}
Remotes.Map = {
    PostieSent = ReplicatedStorage:FindFirstChild("PostieSent"),
    PostieReceived = ReplicatedStorage:FindFirstChild("PostieReceived"),
}

function Remotes.cast()
    local remote = Remotes.Map.PostieSent
    if remote then remote:FireServer() Utils.log("🎣 Lançando linha...", "FISH") return true end
    Utils.log("❌ Remote nao encontrado!", "ERROR")
    return false
end

function Remotes.reel()
    local remote = Remotes.Map.PostieReceived
    if remote then remote:FireServer() Utils.log("🐟 Puxando peixe!", "FISH") return true end
    Utils.log("❌ Remote nao encontrado!", "ERROR")
    return false
end

getgenv().AutoFish = false
local function loopPesca()
    while getgenv().AutoFish do
        Remotes.cast()
        task.wait(2)
        Remotes.reel()
        task.wait(3)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "EclipseHubGUI"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0.5, -100, 0.5, -60)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Titulo = Instance.new("TextLabel")
Titulo.Size = UDim2.new(1, 0, 0, 30)
Titulo.Text = "🌑 ECLIPSE HUB"
Titulo.TextColor3 = Color3.fromRGB(255,255,255)
Titulo.BackgroundTransparency = 1
Titulo.Parent = Frame

local Botao = Instance.new("TextButton")
Botao.Size = UDim2.new(0, 180, 0, 35)
Botao.Position = UDim2.new(0.5, -90, 0, 40)
Botao.Text = "🎣 Auto Fish: OFF"
Botao.TextColor3 = Color3.fromRGB(255,255,255)
Botao.BackgroundColor3 = Color3.fromRGB(60,60,70)
Botao.Parent = Frame

Botao.MouseButton1Click:Connect(function()
    getgenv().AutoFish = not getgenv().AutoFish
    Botao.Text = "🎣 Auto Fish: " .. (getgenv().AutoFish and "ON" or "OFF")
    Botao.BackgroundColor3 = getgenv().AutoFish and Color3.fromRGB(40,180,40) or Color3.fromRGB(60,60,70)
    if getgenv().AutoFish then spawn(loopPesca) end
end)

Utils.log("✅ ECLIPSE HUB CARREGADO!", "SYSTEM")
print("============================================")
