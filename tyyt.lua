-- Research Script: Mobile UI Controller & Module Manager
-- Environment: Mobile Delta Executor

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Module States
local _G_State = {
    ESP_Enabled = false,
    Aimbot_Enabled = false
}

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ESPButton = Instance.new("TextButton")
local AimButton = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "OmniCore_MobileUI"
ScreenGui.Parent = CoreGui -- Or LocalPlayer.PlayerGui for compatibility
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame (Draggable for Mobile)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 150, 0, 120)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Legacy support for mobile executors
MainFrame.Parent = ScreenGui

-- UI Styling Logic
local function styleButton(btn, text)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text .. ": OFF"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = MainFrame
    
    -- Rounding corners for modern look
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
end

Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "OmniCore v1.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 5)

styleButton(ESPButton, "Enemy ESP")
styleButton(AimButton, "Silent Aim")

-- Toggle Functionality
ESPButton.MouseButton1Click:Connect(function()
    _G_State.ESP_Enabled = not _G_State.ESP_Enabled
    ESPButton.Text = "Enemy ESP: " .. (_G_State.ESP_Enabled and "ON" or "OFF")
    ESPButton.BackgroundColor3 = _G_State.ESP_Enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(45, 45, 45)
end)

AimButton.MouseButton1Click:Connect(function()
    _G_State.Aimbot_Enabled = not _G_State.Aimbot_Enabled
    AimButton.Text = "Silent Aim: " .. (_G_State.Aimbot_Enabled and "ON" or "OFF")
    AimButton.BackgroundColor3 = _G_State.Aimbot_Enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(45, 45, 45)
end)

print("OmniCore: Interface Initialized.")
