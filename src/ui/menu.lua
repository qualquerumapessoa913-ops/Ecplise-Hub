-- ============================================
-- ECLIPSE HUB - MENU PRINCIPAL
-- ============================================

local Menu = {}
local Fisch = require(script.Parent.Parent.games.fisch)

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

return Menu