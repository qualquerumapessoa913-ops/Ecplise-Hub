-- ============================================
-- ECLIPSE HUB - BIBLIOTECA UNIVERSAL
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

return Utils