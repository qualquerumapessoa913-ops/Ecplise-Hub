-- ============================================
-- ECLIPSE HUB V3 - SEM SPAM
-- ============================================

print("============================================")
print("  🌑 ECLIPSE HUB V3 - MODO CONTROLADO")
print("============================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage:FindFirstChild("events")

if not events then
    warn("❌ Pasta 'events' não encontrada! Script pode não funcionar.")
end

-- ============================================
-- REMOTES
-- ============================================
local rod_cast = events and events:FindFirstChild("rod_cast")
local reelfinished = events and events:FindFirstChild("reelfinished")
local shakeRemote = events and (events:FindFirstChild("shake") or events:FindFirstChild("rod_shake"))

if not rod_cast then warn("❌ rod_cast não encontrado!") end
if not reelfinished then warn("❌ reelfinished não encontrado!") end

-- ============================================
-- CONTROLE DE ESTADO (EVITA SPAM)
-- ============================================
getgenv().AutoFish = false
local isFishing = false          -- Impede loops duplicados
local lastCastTime = 0           -- Anti-spam por tempo

-- ============================================
-- FUNÇÕES COM ANTI-SPAM
-- ============================================
function cast()
    if not rod_cast then return false end
    if isFishing then 
        print("⏳ Já está pescando... Ignorando cast.")
        return false 
    end
    
    -- Anti-spam: só permite cast a cada 3 segundos
    local now = tick()
    if now - lastCastTime < 3 then
        print("⏳ Aguarde para lançar novamente...")
        return false
    end
    
    rod_cast:FireServer()
    lastCastTime = now
    isFishing = true
    print("🎣 Lançou a linha")
    return true
end

function shake()
    if not shakeRemote then 
        print("⚠️ Remote de shake não encontrado.")
        return false 
    end
    
    shakeRemote:FireServer()
    print("🎣 Sacudiu a vara")
    return true
end

function reel()
    if not reelfinished then return false end
    if not isFishing then
        print("⏳ Não está pescando... Ignorando reel.")
        return false
    end
    
    reelfinished:FireServer()
    isFishing = false
    print("🐟 Puxou o peixe")
    return true
end

-- ============================================
-- CICLO DE PESCA CONTROLADO
-- ============================================
local function fishLoop()
    while getgenv().AutoFish do
        -- Se já estiver pescando, espera terminar
        if isFishing then
            print("⏳ Aguardando conclusão da pesca atual...")
            task.wait(2)
            goto continue
        end
        
        -- 1. Lança a linha (com anti-spam)
        if not cast() then
            task.wait(1)
            goto continue
        end
        
        -- 2. Aguarda o peixe morder (4-7 segundos)
        local waitTime = math.random(4, 7)
        print("⏳ Aguardando peixe morder (" .. waitTime .. "s)...")
        task.wait(waitTime)
        
        -- Se o AutoFish foi desligado durante a espera, sai
        if not getgenv().AutoFish then break end
        
        -- 3. Simula o shake (3-5 vezes)
        local shakeCount = math.random(3, 5)
        print("🎣 Simulando shake (" .. shakeCount .. " vezes)...")
        for i = 1, shakeCount do
            if not getgenv().AutoFish then break end
            shake()
            task.wait(math.random(30, 70) / 100) -- 0.3-0.7 segundos
        end
        
        -- 4. Puxa o peixe
        reel()
        
        -- 5. Aguarda antes do próximo ciclo (5-8 segundos)
        local pauseTime = math.random(5, 8)
        print("⏳ Pausa de " .. pauseTime .. "s antes do próximo cast...")
        task.wait(pauseTime)
        
        ::continue::
        task.wait(0.5)
    end
    
    -- Quando desligar, reseta o estado
    isFishing = false
    print("🛑 AutoFish desligado.")
end

-- ============================================
-- MENU
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "EclipseHubV3"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Titulo = Instance.new("TextLabel")
Titulo.Size = UDim2.new(1, 0, 0, 30)
Titulo.Text = "🌑 ECLIPSE HUB V3"
Titulo.TextColor3 = Color3.fromRGB(255,255,255)
Titulo.BackgroundTransparency = 1
Titulo.Parent = Frame

local Botao = Instance.new("TextButton")
Botao.Size = UDim2.new(0, 180, 0, 35)
Botao.Position = UDim2.new(0.5, -90, 0, 40)
Botao.Text = "🎣 Auto Fish: OFF"
Botao.BackgroundColor3 = Color3.fromRGB(60,60,70)
Botao.TextColor3 = Color3.fromRGB(255,255,255)
Botao.Parent = Frame

Botao.MouseButton1Click:Connect(function()
    getgenv().AutoFish = not getgenv().AutoFish
    Botao.Text = "🎣 Auto Fish: " .. (getgenv().AutoFish and "ON" or "OFF")
    Botao.BackgroundColor3 = getgenv().AutoFish and Color3.fromRGB(40,180,40) or Color3.fromRGB(60,60,70)
    
    if getgenv().AutoFish then
        isFishing = false
        spawn(fishLoop)
    else
        isFishing = false
        print("🛑 Desligando AutoFish...")
    end
end)

print("✅ ECLIPSE HUB V3 CARREGADO!")
print("💡 Dica: O script agora tem anti-spam e delays realistas!")
