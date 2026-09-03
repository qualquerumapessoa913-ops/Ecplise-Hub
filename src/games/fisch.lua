-- ============================================
-- ECLIPSE HUB - SCRIPT DO FISCH
-- ============================================

local Fisch = {}
local Utils = require(script.Parent.Parent.utils.library)
local Remotes = require(script.Parent.Parent.utils.remotes)

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

return Fisch