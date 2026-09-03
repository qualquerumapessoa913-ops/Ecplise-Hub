-- ============================================
-- ECLIPSE HUB V7.1 - CORRIGIDO (RemoteFunction)
-- ============================================

print("============================================")
print("  🌑 ECLIPSE HUB V7.1 - CORRIGIDO!")
print("============================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage:FindFirstChild("events")
local fishingEvents = ReplicatedStorage:FindFirstChild("shared") 
    and ReplicatedStorage.shared:FindFirstChild("modules")
    and ReplicatedStorage.shared.modules:FindFirstChild("fishing")
    and ReplicatedStorage.shared.modules.fishing:FindFirstChild("rodresources")
    and ReplicatedStorage.shared.modules.fishing.rodresources:FindFirstChild("events")

-- ============================================
-- REMOTES
-- ============================================
local Remotes = {}

Remotes.rod_cast = events and events:FindFirstChild("rod_cast")
Remotes.shakehudeffect = events and events:FindFirstChild("shakehudeffect")
Remotes.reelfinished = events and events:FindFirstChild("reelfinished")
Remotes.fishMutation = events and events:FindFirstChild("fishMutation")
Remotes.rodwave = events and events:FindFirstChild("rodwave")
Remotes.exalted_rod_animation = events and events:FindFirstChild("exalted_rod_animation")
Remotes.bite_event_sound = events and events:FindFirstChild("bite_event_sound")

if fishingEvents then
    Remotes.handlebobber = fishingEvents:FindFirstChild("handlebobber")
    Remotes.breakbobber = fishingEvents:FindFirstChild("breakbobber")
    Remotes.catchfinish = fishingEvents:FindFirstChild("catchfinish")
    Remotes.reset = fishingEvents:FindFirstChild("reset")
    Remotes.castAsync = fishingEvents:FindFirstChild("castAsync")  -- RemoteFunction!
end

-- ============================================
-- STATUS
-- ============================================
print("📊 STATUS DOS REMOTES:")
local encontrados = 0
for nome, remote in pairs(Remotes) do
    if remote then
        local tipo = remote:IsA("RemoteFunction") and "RemoteFunction" or "RemoteEvent"
        print("✅ " .. nome .. " - " .. tipo .. " ENCONTRADO!")
        encontrados = encontrados + 1
    else
        print("❌ " .. nome .. " - NÃO ENCONTRADO")
    end
end
print("📈 Total encontrados: " .. encontrados .. "/" .. #Remotes)
print("============================================")

-- ============================================
-- CONFIGURAÇÕES
-- ============================================
getgenv().AutoFish = false
local isFishing = false
local lastCastTime = 0
local fishCount = 0

-- ============================================
-- FUNÇÕES
-- ============================================
function resetRod()
    if Remotes.reset then
        Remotes.reset:FireServer()
        print("🔄 Reset da vara")
        return true
    end
    return false
end

function cast()
    if not Remotes.rod_cast then 
        print("❌ rod_cast não encontrado!")
        return false 
    end
    if isFishing then 
        print("⏳ Já está pescando...")
        return false 
    end
    
    local now = tick()
    if now - lastCastTime < 5 then
        print("⏳ Aguarde 5 segundos...")
        return false
    end
    
    Remotes.rod_cast:FireServer()
    lastCastTime = now
    isFishing = true
    print("🎣 1. Lançou a linha (rod_cast)")
    
    -- castAsync é RemoteFunction! Usa InvokeServer!
    if Remotes.castAsync then
        task.wait(0.2)
        local result = Remotes.castAsync:InvokeServer()
        print("🎣 1.1. castAsync executado! Resultado: " .. tostring(result))
    end
    
    return true
end

function handleBobber()
    if Remotes.handlebobber then
        Remotes.handlebobber:FireServer()
        print("🎣 2. handlebobber executado!")
        return true
    end
    return false
end

function shake()
    if not Remotes.shakehudeffect then
        print("⚠️ shakehudeffect não encontrado!")
        return false
    end
    
    Remotes.shakehudeffect:FireServer()
    print("🎣 3. Sacudiu a vara (shakehudeffect)")
    
    if Remotes.rodwave then
        Remotes.rodwave:FireServer()
        print("   🌊 rodwave ativado!")
    end
    
    return true
end

function finishFishing()
    if not Remotes.reelfinished then
        print("❌ reelfinished não encontrado!")
        return false
    end
    
    if not isFishing then
        print("⏳ Não está pescando...")
        return false
    end
    
    if Remotes.fishMutation then
        Remotes.fishMutation:FireServer()
        print("🐟 4.1. fishMutation executado!")
        task.wait(0.3)
    end
    
    if Remotes.catchfinish then
        Remotes.catchfinish:FireServer()
        print("🐟 4.2. catchfinish executado!")
        task.wait(0.3)
    end
    
    Remotes.reelfinished:FireServer()
    isFishing = false
    fishCount = fishCount + 1
    print("🐟 4.3. Puxou o peixe (reelfinished) #" .. fishCount)
    
    if Remotes.breakbobber then
        task.wait(0.2)
        Remotes.breakbobber:FireServer()
        print("🎣 4.4. breakbobber executado!")
    end
    
    return true
end

function resetAfterCatch()
    if Remotes.reset then
        task.wait(0.3)
        Remotes.reset:FireServer()
        print("🔄 5. Reset da vara após captura")
        return true
    end
    return false
end

-- ============================================
-- LOOP DE PESCA
-- ============================================
local function fishLoop()
    print("🔄 Iniciando ciclo de pesca definitivo...")
    
    while getgenv().AutoFish do
        if isFishing then
            print("⏳ Aguardando conclusão da pesca atual...")
            task.wait(2)
        else
            resetRod()
            task.wait(0.5)
            
            if cast() then
                handleBobber()
                
                local waitTime = math.random(6, 10)
                print("⏳ 2. Aguardando peixe morder (" .. waitTime .. "s)...")
                task.wait(waitTime)
                
                if getgenv().AutoFish then
                    local shakeCount = math.random(8, 12)
                    print("🎣 3. Simulando shake (" .. shakeCount .. " vezes)...")
                    for i = 1, shakeCount do
                        if not getgenv().AutoFish then break end
                        shake()
                        task.wait(math.random(40, 80) / 100)
                    end
                    
                    if getgenv().AutoFish then
                        finishFishing()
                        resetAfterCatch()
                        
                        local pauseTime = math.random(12, 18)
                        print("⏳ 6. Pausa de " .. pauseTime .. "s antes do próximo cast...")
                        task.wait(pauseTime)
                    end
                end
            else
                task.wait(2)
            end
        end
        task.wait(0.5)
    end
    
    isFishing = false
    print("🛑 AutoFish desligado. Total de peixes: " .. fishCount)
end

-- ============================================
-- MENU
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "EclipseHubV7"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 180)
Frame.Position = UDim2.new(0.5, -130, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

local Titulo = Instance.new("TextLabel")
Titulo.Size = UDim2.new(1, 0, 0, 35)
Titulo.Position = UDim2.new(0, 0, 0, 5)
Titulo.Text = "🌑 ECLIPSE HUB V7.1"
Titulo.TextColor3 = Color3.fromRGB(255,255,255)
Titulo.TextSize = 20
Titulo.Font = Enum.Font.GothamBold
Titulo.BackgroundTransparency = 1
Titulo.Parent = Frame

local SubTitulo = Instance.new("TextLabel")
SubTitulo.Size = UDim2.new(1, 0, 0, 20)
SubTitulo.Position = UDim2.new(0, 0, 0, 42)
SubTitulo.Text = "🔥 RemoteFunction Corrigida!"
SubTitulo.TextColor3 = Color3.fromRGB(150, 150, 200)
SubTitulo.TextSize = 11
SubTitulo.Font = Enum.Font.Gotham
SubTitulo.BackgroundTransparency = 1
SubTitulo.Parent = Frame

local Botao = Instance.new("TextButton")
Botao.Size = UDim2.new(0, 220, 0, 40)
Botao.Position = UDim2.new(0.5, -110, 0, 75)
Botao.Text = "🎣 Auto Fish: OFF"
Botao.TextColor3 = Color3.fromRGB(255,255,255)
Botao.TextSize = 16
Botao.Font = Enum.Font.Gotham
Botao.BackgroundColor3 = Color3.fromRGB(60,60,70)
Botao.Parent = Frame

local BotaoCorner = Instance.new("UICorner")
BotaoCorner.CornerRadius = UDim.new(0, 8)
BotaoCorner.Parent = Botao

Botao.MouseButton1Click:Connect(function()
    getgenv().AutoFish = not getgenv().AutoFish
    Botao.Text = "🎣 Auto Fish: " .. (getgenv().AutoFish and "ON" or "OFF")
    Botao.BackgroundColor3 = getgenv().AutoFish and Color3.fromRGB(40,180,40) or Color3.fromRGB(60,60,70)
    
    if getgenv().AutoFish then
        isFishing = false
        fishCount = 0
        spawn(fishLoop)
        print("🚀 AutoFish LIGADO!")
    else
        isFishing = false
        print("🛑 AutoFish DESLIGADO! Total: " .. fishCount)
    end
end)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 130)
Status.Text = "📊 Status: Aguardando..."
Status.TextColor3 = Color3.fromRGB(100, 100, 130)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.BackgroundTransparency = 1
Status.Parent = Frame

local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(1, 0, 0, 20)
Counter.Position = UDim2.new(0, 0, 0, 150)
Counter.Text = "🐟 Total: 0"
Counter.TextColor3 = Color3.fromRGB(100, 100, 130)
Counter.TextSize = 11
Counter.Font = Enum.Font.Gotham
Counter.BackgroundTransparency = 1
Counter.Parent = Frame

spawn(function()
    while true do
        local status = "🔴 Desligado"
        if getgenv().AutoFish then
            status = isFishing and "🟢 Pesca em andamento..." or "🟡 Aguardando..."
        end
        Status.Text = "📊 Status: " .. status
        Counter.Text = "🐟 Total: " .. fishCount
        task.wait(0.5)
    end
end)

print("============================================")
print("✅ ECLIPSE HUB V7.1 CARREGADO COM SUCESSO!")
print("💡 castAsync corrigido: InvokeServer em vez de FireServer")
print("============================================")
