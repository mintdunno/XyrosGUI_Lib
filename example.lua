-- Xyros Modern GUI - Example Usage

-- It is recommended to use a Raw-URL link to your script from GitHub.
-- local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repo/main/XyrosGUI.lua"))()

-- For local testing, you can require the library directly.
local Library = require(script.Parent.XyrosGUI)

task.wait(2) -- Wait for game to load

-- 1. Create the main window
local MyWindow = Library.new("Xyros Modern Showcase", {
    constrainToScreen = true
})

-- 2. Create tabs
local MainTab = Library.CreateTab(MyWindow, "Main", "rbxassetid://10746039695")
local VisualsTab = Library.CreateTab(MyWindow, "Visuals", "rbxassetid://11454041890")

-- Activate the first tab by default
MainTab.Tab.MouseButton1Click:Fire()

-- 3. Create sections and add components to the Main Tab
local PlayerSection = MainTab.AddSection("Player")
local WorldSection = MainTab.AddSection("World")

-- Add components to PlayerSection
PlayerSection.AddToggle("God Mode", function(toggled)
    print("God Mode toggled:", toggled)
end)

PlayerSection.AddButton("Reset Character", function()
    print("Character reset!")
    local player = game:GetService("Players").LocalPlayer
    player:LoadCharacter()
end)

PlayerSection.AddSlider("WalkSpeed", 16, 100, 16, function(value)
    print("WalkSpeed changed to:", value)
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = value
    end
end)

-- Add components to WorldSection
WorldSection.AddSlider("Time of Day", 0, 24, 12, function(value)
    print("Time of Day changed to:", value)
    game:GetService("Lighting").ClockTime = value
end)

WorldSection.AddDropdown("Skybox", {
    {text = "Default", value = "default"},
    {text = "Night", value = "night"},
    {text = "Sunset", value = "sunset"}
}, function(selectedValue)
    print("Skybox changed to:", selectedValue)
    -- Logic to change skybox would go here
end)


-- 4. Create sections and add components to the Visuals Tab
local ESPSection = VisualsTab.AddSection("ESP")

ESPSection.AddToggle("Player ESP", function(toggled)
    print("Player ESP toggled:", toggled)
end)

ESPSection.AddToggle("Box ESP", function(toggled)
    print("Box ESP toggled:", toggled)
end)

ESPSection.AddSlider("ESP Distance", 50, 500, 200, function(value)
    print("ESP Distance changed to:", value)
end)
