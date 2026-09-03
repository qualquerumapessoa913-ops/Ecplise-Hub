-- ============================================
-- ECLIPSE HUB V4 - SHAKE CORRETO!
-- ============================================

print("============================================")
print("  🌑 ECLIPSE HUB V4 - SHAKE ENCONTRADO!")
print("============================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage:FindFirstChild("events")

if not events then
    warn("❌ Pasta 'events' não encontrada!")
end

-- ============================================
-- REMOTES (ATUALIZADO!)
-- ============================================
local rod_cast = events and events:FindFirstChild("rod_cast")
local reelfinished = events and events:FindFirstChild("reelfinished")
local shakeRemote = events and events:FindFirstChild("shakehudeffect")  -- ← ESSE É O CERTO!

if not rod_cast then warn("❌ rod_cast não encontrado!") end
if not reelfinished then warn("❌ reelfinished não encontrado!") end
if not shakeRemote then warn("❌ shakehudeffect não encontrado!") end

-- ============================================
-- CONTROLE DE ESTADO
-- ============================================
getgenv().AutoFish = false
local isFishing = false
local lastCastTime = 0

-- ============================================
-- FUNÇÃO CAST
-- ============================================
function cast()
    if not rod_cast then return false end
    if isFishing then 
        print("⏳ Já está pescando... Ignorando cast.")
        return false 
    end
    
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

-- ============================================
-- FUNÇÃO SHAKE (AGORA COM O REMOTE CERTO!)
-- ============================================
function shake()
    if not shakeRemote then 
        print("⚠️ Remote de shake não encontrado!")
        return false 
    end
    
    shakeRemote:FireServer()
    print("🎣 Sacudiu a vara (shakehudeffect)")
    return true
end

-- ============================================
-- FUNÇÃO REEL
-- ============================================
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
-- LOOP DE PESCA (COM DELAYS MAIORES)
-- ============================================
local function fishLoop()
    while getgenv().AutoFish do
        if isFishing then
            print("⏳ Aguardando conclusão da pesca atual...")
            task.wait(2)
        else
            if cast() then
                -- Espera o peixe morder (5-8 segundos)
                local waitTime = math.random(5, 8)
                print("⏳ Aguardando peixe morder (" .. waitTime .. "s)...")
                task.wait(waitTime)
                
                if not getgenv().AutoFish then break end
                
                -- Simula o shake (5-8 vezes, com intervalos maiores)
                local shakeCount = math.random(5, 8)
                print("🎣 Simulando shake (" .. shakeCount .. " vezes)...")
                for i = 1, shakeCount do
                    if not getgenv().AutoFish then break end
                    shake()
                    task.wait(math.random(40, 90) / 100) -- 0.4-0.9 segundos
                end
                
                -- Puxa o peixe
                reel()
                
                -- Pausa maior antes do próximo ciclo (8-12 segundos)
                local pauseTime = math.random(8, 12)
                print("⏳ Pausa de " .. pauseTime .. "s antes do próximo cast...")
                task.wait(pauseTime)
            else
                task.wait(1)
            end
        end
        task.wait(0.5)
    end
    
    isFishing = false
    print("🛑 AutoFish desligado.")
end

-- ============================================
-- MENU
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "EclipseHubV4"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Titulo = Instance.new("TextLabel")
Titulo.Size = UDim2.new(1, 0, 0, 30)
Titulo.Text = "🌑 ECLIPSE HUB V4"
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

print("✅ ECLIPSE HUB V4 CARREGADO!")
print("💡 Remote de shake encontrado: shakehudeffect")
print("💡 Delays aumentados para evitar ban!")
