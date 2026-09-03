-- ============================================
-- ECLIPSE HUB - REMOTES DO FISCH
-- ============================================

local Remotes = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(script.Parent.library)

-- MAPEANDO OS REMOTES
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

return Remotes