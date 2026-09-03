-- ============================================
-- ECLIPSE HUB V7 - SCRIPT DEFINITIVO
-- BASEADO NA BUSCA COMPLETA DE REMOTES
-- ============================================

print("============================================")
print("  🌑 ECLIPSE HUB V7 - VERSÃO DEFINITIVA")
print("  🔍 Baseado na busca completa de remotes")
print("============================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage:FindFirstChild("events")
local fishingEvents = ReplicatedStorage:FindFirstChild("shared") 
    and ReplicatedStorage.shared:FindFirstChild("modules")
    and ReplicatedStorage.shared.modules:FindFirstChild("fishing")
    and ReplicatedStorage.shared.modules.fishing:FindFirstChild("rodresources")
    and ReplicatedStorage.shared.modules.fishing.rodresources:FindFirstChild("events")

-- ============================================
-- TODOS OS REMOTES DE PESCA
-- ============================================
local Remotes = {}

-- Remotes principais (events)
Remotes.rod_cast = events and events:FindFirstChild("rod_cast")
Remotes.shakehudeffect = events and events:FindFirstChild("shakehudeffect")
Remotes.reelfinished = events and events:FindFirstChild("reelfinished")
Remotes.fishMutation = events and events:FindFirstChild("fishMutation")
Remotes.rodwave = events and events:FindFirstChild("rodwave")
Remotes.exalted_rod_animation = events and events:FindFirstChild("exalted_rod_animation")
Remotes.bite_event_sound = events and events:FindFirstChild("bite_event_sound")

-- Remotes de rodresources (fishing)
if fishingEvents then
    Remotes.handlebobber = fishingEvents:FindFirstChild("handlebobber")
    Remotes.breakbobber = fishingEvents:FindFirstChild("breakbobber")
    Remotes.catchfinish = fishingEvents:FindFirstChild("catchfinish")
    Remotes.reset = fishingEvents:FindFirstChild("reset")
    Remotes.castAsync = fishingEvents:FindFirstChild("castAsync")
end

-- ============================================
-- STATUS DOS REMOTES
-- ============================================
print("📊 STATUS DOS REMOTES:")
local encontrados = 0
for nome, remote in pairs(Remotes) do
    if remote then
        print("✅ " .. nome .. " - ENCONTRADO!")
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
-- FUNÇÃO: Reset do estado da vara
-- ============================================
function resetRod()
    if Remotes.reset then
        Remotes.reset:FireServer()
        print("🔄 Reset da vara")
        return true
    end
    return false
end

-- ============================================
-- FUNÇÃO: Lançar a linha
-- ============================================
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
    
    -- Chama o cast
    Remotes.rod_cast:FireServer()
    lastCastTime = now
    isFishing = true
    print("🎣 1. Lançou a linha (rod_cast)")
    
    -- Chama castAsync se existir
    if Remotes.castAsync then
        task.wait(0.2)
        Remotes.castAsync:FireServer()
        print("🎣 1.1. castAsync executado!")
    end
    
    return true
end

-- ============================================
-- FUNÇÃO: Handle Bobber (pós-cast)
-- ============================================
function handleBobber()
    if Remotes.handlebobber then
        Remotes.handlebobber:FireServer()
        print("🎣 2. handlebobber executado!")
        return true
    end
    return false
end

-- ============================================
-- FUNÇÃO: Sacudir a vara
-- ============================================
function shake()
    if not Remotes.shakehudeffect then
        print("⚠️ shakehudeffect não encontrado!")
        return false
    end
    
    Remotes.shakehudeffect:FireServer()
    print("🎣 3. Sacudiu a vara (shakehudeffect)")
    
    -- Chama rodwave junto (efeito visual)
    if Remotes.rodwave then
        Remotes.rodwave:FireServer()
        print("   🌊 rodwave ativado!")
    end
    
    return true
end

-- ============================================
-- FUNÇÃO: Finalizar a pesca
-- ============================================
function finishFishing()
    if not Remotes.reelfinished then
        print("❌ reelfinished não encontrado!")
        return false
    end
    
    if not isFishing then
        print("⏳ Não está pescando...")
        return false
    end
    
    -- 1. Chama fishMutation
    if Remotes.fishMutation then
        Remotes.fishMutation:FireServer()
        print("🐟 4.1. fishMutation executado!")
        task.wait(0.3)
    end
    
    -- 2. Chama catchfinish
    if Remotes.catchfinish then
        Remotes.catchfinish:FireServer()
        print("🐟 4.2. catchfinish executado!")
        task.wait(0.3)
    end
    
    -- 3. Chama reelfinished
    Remotes.reelfinished:FireServer()
    isFishing = false
    fishCount = fishCount + 1
    print("🐟 4.3. Puxou o peixe (reelfinished) #" .. fishCount)
    
    -- 4. Chama breakbobber (opcional)
    if Remotes.breakbobber then
        task.wait(0.2)
        Remotes.breakbobber:FireServer()
        print("🎣 4.4. breakbobber executado!")
    end
    
    return true
}

-- ============================================
-- FUNÇÃO: Reset final
-- ============================================
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
-- LOOP DE PESCA (COM TODOS OS PASSOS)
-- ============================================
local function fishLoop()
    print("🔄 Iniciando ciclo de pesca definitivo...")
    
    while getgenv().AutoFish do
        if isFishing then
            print("⏳ Aguardando conclusão da pesca atual...")
            task.wait(2)
        else
            -- PASSO 1: Reset da vara (limpa estado anterior)
            resetRod()
            task.wait(0.5)
            
            -- PASSO 2: Cast
            if not cast() then
                task.wait(2)
                goto continue
            end
            
            -- PASSO 3: Handle Bobber (opcional)
            handleBobber()
            
            -- PASSO 4: Esperar o peixe morder (6-10 segundos)
            local waitTime = math.random(6, 10)
            print("⏳ 2. Aguardando peixe morder (" .. waitTime .. "s)...")
            task.wait(waitTime)
            
            if not getgenv().AutoFish then break end
            
            -- PASSO 5: Shake (8-12 vezes)
            local shakeCount = math.random(8, 12)
            print("🎣 3. Simulando shake (" .. shakeCount .. " vezes)...")
            for i = 1, shakeCount do
                if not getgenv().AutoFish then break end
                shake()
                task.wait(math.random(40, 80) / 100)
            end
            
            if not getgenv().AutoFish then break end
            
            -- PASSO 6: Finalizar a pesca
            finishFishing()
            
            -- PASSO 7: Reset após captura
            resetAfterCatch()
            
            -- PASSO 8: Pausa (12-18 segundos - MAIOR!)
            local pauseTime = math.random(12, 18)
            print("⏳ 6. Pausa de " .. pauseTime .. "s antes do próximo cast...")
            task.wait(pauseTime)
        end
        
        ::continue::
        task.wait(0.5)
    end
    
    isFishing = false
    print("🛑 AutoFish desligado. Total de peixes: " .. fishCount)
end

-- ============================================
-- MENU (ATUALIZADO)
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
Titulo.Text = "🌑 ECLIPSE HUB V7"
Titulo.TextColor3 = Color3.fromRGB(255,255,255)
Titulo.TextSize = 20
Titulo.Font = Enum.Font.GothamBold
Titulo.BackgroundTransparency = 1
Titulo.Parent = Frame

local SubTitulo = Instance.new("TextLabel")
SubTitulo.Size = UDim2.new(1, 0, 0, 20)
SubTitulo.Position = UDim2.new(0, 0, 0, 42)
SubTitulo.Text = "🔥 Versão Definitiva - " .. encontrados .. " remotes"
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

-- Atualiza o status em tempo real
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

-- ============================================
-- FINALIZAÇÃO
-- ============================================
print("============================================")
print("✅ ECLIPSE HUB V7 CARREGADO COM SUCESSO!")
print("📊 Remotes encontrados: " .. encontrados .. "/" .. #Remotes)
print("🔄 Ciclo completo: Reset → Cast → Handle → Esperar → Shake → FishMutation → CatchFinish → ReelFinished → BreakBobber → Reset → Pausa")
print("⏱️ Delays: 6-10s (morder), 8-12x (shake), 12-18s (pausa)")
print("============================================")
