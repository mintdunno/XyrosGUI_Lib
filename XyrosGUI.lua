_G.JxereasExistingHooks = _G.JxereasExistingHooks or {}
if not _G.JxereasExistingHooks.GuiDetectionBypass then
    local CoreGui = game.CoreGui
    local ContentProvider = game.ContentProvider
    local RobloxGuis = {"RobloxGui", "TeleportGui", "RobloxPromptGui", "RobloxLoadingGui", "PlayerList", "RobloxNetworkPauseNotification", "PurchasePrompt", "HeadsetDisconnectedDialog", "ThemeProvider", "DevConsoleMaster"}

    local function FilterTable(tbl)
        local context = syn_context_get()
        syn_context_set(7)
        local new = {}
        for i,v in ipairs(tbl) do --roblox iterates the array part
            if typeof(v) ~= "Instance" then
                table.insert(new, v)
            else
                if v == CoreGui or v == game then
                    --insert only the default roblox guis
                    for i,v in pairs(RobloxGuis) do
                        local gui = CoreGui:FindFirstChild(v)
                        if gui then
                            table.insert(new, gui)
                        end
                    end

                    if v == game then
                        for i,v in pairs(game:GetChildren()) do
                            if v ~= CoreGui then
                                table.insert(new, v)
                            end
                        end
                    end
                else
                    if not CoreGui:IsAncestorOf(v) then
                        table.insert(new, v)
                    else
                        --don't insert it if it's a descendant of a different gui than default roblox guis
                        for j,k in pairs(RobloxGuis) do
                            local gui = CoreGui:FindFirstChild(k)
                            if gui then
                                if v == gui or gui:IsAncestorOf(v) then
                                    table.insert(new, v)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        syn_context_set(context)
        return new
    end

    local old
    old = hookfunc(ContentProvider.PreloadAsync, function(self, tbl, cb)
        if self ~= ContentProvider or type(tbl) ~= "table" or type(cb) ~= "function" then --note: callback can be nil but in that case it's useless anyways
            return old(self, tbl, cb)
        end

        --check for any errors that I might've missed (such as table being {[2] = "something"} which causes "Unable to cast to Array")
        local err
        task.spawn(function() --TIL pcalling a C yield function inside a C yield function is a bad idea ("cannot resume non-suspended coroutine")
            local s,e = pcall(old, self, tbl)
            if not s and e then
                err = e
            end
        end)

        if err then
            return old(self, tbl) --don't pass the callback, just in case
        end

        tbl = FilterTable(tbl)
        return old(self, tbl, cb)
    end)

    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == ContentProvider and (method == "PreloadAsync" or method == "preloadAsync") then
            local args = {...}
            if type(args[1]) ~= "table" or type(args[2]) ~= "function" then
                return old(self, ...)
            end

            local err
            task.spawn(function()
                setnamecallmethod(method) --different thread, different namecall method
                local s,e = pcall(old, self, args[1])
                if not s and e then
                    err = e
                end
            end)

            if err then
                return old(self, args[1])
            end

            args[1] = FilterTable(args[1])
            setnamecallmethod(method)
            return old(self, args[1], args[2])
        end
        return old(self, ...)
    end)

    _G.JxereasExistingHooks.GuiDetectionBypass = true
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

for _, connection in pairs(getconnections(player.Idled)) do
	if connection.Enabled then
    	connection:Disable()
    end
end


local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local mouse = player:GetMouse()
local viewPortSize = workspace.CurrentCamera.ViewportSize

-- Modern Frosted Glass Theme System
local Theme = {
	Name = "XyrosModern";

	-- Modern Color Palette with Frosted Glass Aesthetics
	Colors = {
		-- Base Colors (Darker, more sophisticated)
		Background = Color3.fromRGB(8, 12, 20);          -- Deep dark blue-black
		Surface = Color3.fromRGB(15, 20, 30);            -- Slightly lighter surface
		SurfaceVariant = Color3.fromRGB(20, 25, 35);     -- Surface variant

		-- Frosted Glass Colors
		Glass = Color3.fromRGB(25, 30, 45);              -- Main glass color
		GlassLight = Color3.fromRGB(35, 42, 60);         -- Lighter glass variant
		GlassDark = Color3.fromRGB(18, 22, 35);          -- Darker glass variant

		-- Accent Colors (Modern gradient-friendly)
		Primary = Color3.fromRGB(99, 102, 241);          -- Indigo primary
		PrimaryVariant = Color3.fromRGB(79, 70, 229);    -- Darker indigo
		Secondary = Color3.fromRGB(139, 92, 246);        -- Purple secondary
		SecondaryVariant = Color3.fromRGB(124, 58, 237); -- Darker purple

		-- Status Colors
		Success = Color3.fromRGB(34, 197, 94);           -- Green
		Warning = Color3.fromRGB(251, 191, 36);          -- Amber
		Error = Color3.fromRGB(239, 68, 68);             -- Red
		Info = Color3.fromRGB(59, 130, 246);             -- Blue

		-- Text Colors (High contrast for accessibility)
		TextPrimary = Color3.fromRGB(248, 250, 252);     -- Near white
		TextSecondary = Color3.fromRGB(203, 213, 225);   -- Light gray
		TextMuted = Color3.fromRGB(148, 163, 184);       -- Medium gray
		TextDisabled = Color3.fromRGB(100, 116, 139);    -- Dark gray

		-- Border and Outline Colors
		Border = Color3.fromRGB(51, 65, 85);             -- Subtle border
		BorderLight = Color3.fromRGB(71, 85, 105);       -- Lighter border
		Outline = Color3.fromRGB(30, 41, 59);            -- Outline color

		-- Interactive States
		Hover = Color3.fromRGB(45, 55, 75);              -- Hover state
		Active = Color3.fromRGB(55, 65, 85);             -- Active/pressed state
		Focus = Color3.fromRGB(99, 102, 241);            -- Focus ring color
	};

	-- Frosted Glass Transparency Values
	Transparency = {
		Glass = 0.15;           -- Main frosted glass transparency
		GlassLight = 0.25;      -- Lighter glass elements
		GlassDark = 0.05;       -- Darker glass elements
		Overlay = 0.4;          -- Modal overlays
		Backdrop = 0.6;         -- Background blur
		Subtle = 0.8;           -- Very subtle elements
	};

	-- Modern Rounded Corners
	Rounding = {
		Small = 6;              -- Small elements (buttons, inputs)
		Medium = 12;            -- Medium elements (cards, panels)
		Large = 20;             -- Large elements (modals, windows)
		XLarge = 28;            -- Extra large (main containers)
	};

	-- Typography System
	Font = {
		-- Primary fonts
		Display = Enum.Font.GothamBold;        -- Large headings
		Heading = Enum.Font.GothamSemibold;    -- Section headings
		Body = Enum.Font.Gotham;               -- Body text
		Caption = Enum.Font.GothamMedium;      -- Small text, captions

		-- Monospace for code/numbers
		Mono = Enum.Font.RobotoMono;           -- Monospace text
	};

	-- Animation and Easing
	Animation = {
		Fast = 0.15;            -- Quick transitions
		Normal = 0.25;          -- Standard transitions
		Slow = 0.4;             -- Slow, smooth transitions

		-- Easing styles
		EaseOut = Enum.EasingStyle.Quart;
		EaseIn = Enum.EasingStyle.Quint;
		Bounce = Enum.EasingStyle.Back;
	};

	-- Spacing System (8px base unit)
	Spacing = {
		XS = 4;                 -- Extra small spacing
		SM = 8;                 -- Small spacing
		MD = 16;                -- Medium spacing
		LG = 24;                -- Large spacing
		XL = 32;                -- Extra large spacing
		XXL = 48;               -- Extra extra large spacing
	};

	-- Shadow and Blur Effects
	Effects = {
		-- Blur intensities
		BlurLight = 10;         -- Light blur for subtle glass effect
		BlurMedium = 20;        -- Medium blur for main glass elements
		BlurHeavy = 40;         -- Heavy blur for strong glass effect

		-- Shadow configurations
		ShadowLight = {
			Color = Color3.fromRGB(0, 0, 0);
			Transparency = 0.9;
			Size = 4;
		};
		ShadowMedium = {
			Color = Color3.fromRGB(0, 0, 0);
			Transparency = 0.8;
			Size = 8;
		};
		ShadowHeavy = {
			Color = Color3.fromRGB(0, 0, 0);
			Transparency = 0.7;
			Size = 16;
		};
	};
}

-- Modern Design System Helper Functions
local DesignSystem = {}

-- Create frosted glass effect with blur
function DesignSystem.CreateGlassEffect(parent, intensity)
	intensity = intensity or "Medium"

	-- Create blur effect
	local blur = Instance.new("BlurEffect")
	blur.Size = Theme.Effects["Blur" .. intensity] or Theme.Effects.BlurMedium
	blur.Parent = game.Lighting

	-- Create glass frame with proper transparency
	local glassFrame = Instance.new("Frame")
	glassFrame.BackgroundColor3 = Theme.Colors.Glass
	glassFrame.BackgroundTransparency = Theme.Transparency.Glass
	glassFrame.BorderSizePixel = 0
	glassFrame.Parent = parent

	-- Add subtle border
	local border = Instance.new("UIStroke")
	border.Color = Theme.Colors.Border
	border.Transparency = 0.7
	border.Thickness = 1
	border.Parent = glassFrame

	-- Add corner rounding
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Theme.Rounding.Medium)
	corner.Parent = glassFrame

	return glassFrame, blur
end

-- Create responsive layout that adapts to screen size
function DesignSystem.CreateResponsiveLayout(container)
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local isMobile = viewportSize.X < 768 or UserInputService.TouchEnabled

	-- Adjust layout based on device type
	if isMobile then
		-- Mobile layout adjustments
		container.Size = UDim2.new(0.95, 0, 0.85, 0)
		container.Position = UDim2.new(0.5, 0, 0.5, 0)
	else
		-- Desktop layout
		container.Size = UDim2.new(0.7, 0, 0.75, 0)
		container.Position = UDim2.new(0.5, 0, 0.5, 0)
	end

	-- Add responsive constraint
	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	aspectRatio.AspectRatio = isMobile and 0.75 or 1.6
	aspectRatio.AspectType = Enum.AspectType.FitWithinMaxSize
	aspectRatio.Parent = container

	return isMobile
end

-- Create modern button with glass effect and animations
function DesignSystem.CreateModernButton(parent, text, buttonType)
	buttonType = buttonType or "Primary"

	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Theme.Colors[buttonType] or Theme.Colors.Primary
	button.BackgroundTransparency = Theme.Transparency.Glass
	button.BorderSizePixel = 0
	button.Font = Theme.Font.Body
	button.Text = text or "Button"
	button.TextColor3 = Theme.Colors.TextPrimary
	button.TextSize = 14
	button.AutoButtonColor = false
	button.Parent = parent

	-- Add glass effect
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Theme.Rounding.Small)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Colors.Border
	stroke.Transparency = 0.6
	stroke.Thickness = 1
	stroke.Parent = button

	-- Add hover and click animations
	local hoverTween = TweenService:Create(button,
		TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
		{BackgroundColor3 = Theme.Colors.Hover}
	)

	local clickTween = TweenService:Create(button,
		TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseIn),
		{Size = UDim2.new(button.Size.X.Scale * 0.95, 0, button.Size.Y.Scale * 0.95, 0)}
	)

	local resetTween = TweenService:Create(button,
		TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
		{Size = button.Size}
	)

	-- Connect events
	button.MouseEnter:Connect(function()
		hoverTween:Play()
	end)

	button.MouseLeave:Connect(function()
		local resetColorTween = TweenService:Create(button,
			TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
			{BackgroundColor3 = Theme.Colors[buttonType] or Theme.Colors.Primary}
		)
		resetColorTween:Play()
	end)

	button.MouseButton1Down:Connect(function()
		clickTween:Play()
	end)

	button.MouseButton1Up:Connect(function()
		resetTween:Play()
	end)

	return button
end

-- Create modern input field with glass styling
function DesignSystem.CreateModernInput(parent, placeholder)
	local inputFrame = Instance.new("Frame")
	inputFrame.BackgroundColor3 = Theme.Colors.GlassLight
	inputFrame.BackgroundTransparency = Theme.Transparency.GlassLight
	inputFrame.BorderSizePixel = 0
	inputFrame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Theme.Rounding.Small)
	corner.Parent = inputFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Colors.Border
	stroke.Transparency = 0.7
	stroke.Thickness = 1
	stroke.Parent = inputFrame

	local textBox = Instance.new("TextBox")
	textBox.BackgroundTransparency = 1
	textBox.Font = Theme.Font.Body
	textBox.PlaceholderText = placeholder or "Enter text..."
	textBox.PlaceholderColor3 = Theme.Colors.TextMuted
	textBox.Text = ""
	textBox.TextColor3 = Theme.Colors.TextPrimary
	textBox.TextSize = 14
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.Size = UDim2.new(1, -Theme.Spacing.SM * 2, 1, 0)
	textBox.Position = UDim2.new(0, Theme.Spacing.SM, 0, 0)
	textBox.Parent = inputFrame

	-- Focus animations
	textBox.Focused:Connect(function()
		local focusTween = TweenService:Create(stroke,
			TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
			{Color = Theme.Colors.Focus, Transparency = 0.3}
		)
		focusTween:Play()
	end)

	textBox.FocusLost:Connect(function()
		local unfocusTween = TweenService:Create(stroke,
			TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
			{Color = Theme.Colors.Border, Transparency = 0.7}
		)
		unfocusTween:Play()
	end)

	return inputFrame, textBox
end

local originalElements = {}
local modernElements = {}  -- Store modern element references

local Library = {}
local elementHandler = {}
local windowHandler = {}
local tabHandler = {}
local sectionHandler = {}
local titleHandler = {}
local labelHandler = {}
local toggleHandler = {}
local buttonHandler = {}
local dropdownHandler = {}
local sliderHandler = {}
local searchBarHandler = {}
local keybindHandler = {}
local textBoxHandler = {}
local colorWheelHandler = {}

elementHandler.__index = elementHandler
windowHandler.__index = function(_, i) return rawget(windowHandler, i) or rawget(elementHandler, i) end
tabHandler.__index = function(_, i ) return rawget(tabHandler, i) or rawget(elementHandler, i) end
sectionHandler.__index = function(_, i) return rawget(sectionHandler, i) or rawget(elementHandler, i) end
titleHandler.__index = function(_, i) return rawget(titleHandler, i) or rawget(elementHandler, i) end
labelHandler.__index = function(_, i) return rawget(labelHandler, i) or rawget(elementHandler, i) end
toggleHandler.__index = function(_, i) return rawget(toggleHandler, i) or rawget(elementHandler, i) end
buttonHandler.__index = function(_, i) return rawget(buttonHandler, i) or rawget(elementHandler, i) end
dropdownHandler.__index = function(_, i) return rawget(dropdownHandler, i) or rawget(elementHandler, i) end
sliderHandler.__index = function(_, i) return rawget(sliderHandler, i) or rawget(elementHandler, i) end
searchBarHandler.__index = function(_, i) return rawget(searchBarHandler, i) or rawget(elementHandler, i) end
keybindHandler.__index = function(_, i) return rawget(keybindHandler, i) or rawget(elementHandler, i) end
textBoxHandler.__index = function(_, i) return rawget(textBoxHandler, i) or rawget(elementHandler, i) end
colorWheelHandler.__index = function(_, i) return rawget(colorWheelHandler, i) or rawget(elementHandler, i) end

local function animateText(textInstance: Instance, animationSpeed: number, text: string, placeholderText: string?, fillPlaceHolder: boolean?, emptyPlaceHolderText: boolean?): nil
	if emptyPlaceHolderText then
		for i = #textInstance.PlaceholderText, 0, -1 do
			textInstance.PlaceholderText = textInstance.PlaceholderText:sub(1,i)
			task.wait(animationSpeed)
		end
	else
		for i = #textInstance.Text, 0, -1 do
			textInstance.Text = textInstance.Text:sub(1,i)
			task.wait(animationSpeed)
		end
	end

	if fillPlaceHolder then
		for i = 1, #placeholderText do
			textInstance.PlaceholderText = placeholderText:sub(1, i)
			task.wait(animationSpeed)
		end
	else
		for i = 1, #text do
			textInstance.Text = text:sub(1, i)
			task.wait(animationSpeed)
		end
	end
end

local function toPolar(vector)
	return vector.Magnitude, math.atan2(vector.Y, vector.X)
end

local function toCartesian(radius, theta)
	return math.cos(theta) * radius, math.sin(theta) * radius
end

-- Modern GUI Library Implementation
local function createModernElements()
	return {
		createWindow = createWindow,
		createTab = createTab,
		createPage = createPage,
		createSection = createSection,
		createTitle = createTitle,
		createLabel = createLabel,
		createToggle = createToggle,
		createButton = createButton,
		createDropdown = createDropdown,
		createSlider = createSlider,
		createSearchBar = createSearchBar,
		createKeybind = createKeybind,
		createTextBox = createTextBox,
		createColorWheel = createColorWheel
	}
end

local function createOriginialElements()
	-- Modern Window Creation with Frosted Glass Design
	local function createWindow()
		local screenGui = Instance.new("ScreenGui")
		local background = Instance.new("Frame")
		local backgroundBlur = Instance.new("Frame")
		local pagesFolder = Instance.new("Folder")
		local titleBar = Instance.new("Frame")
		local titleBarGlass = Instance.new("Frame")
		local windowControls = Instance.new("Frame")
		local minimizeBtn = Instance.new("TextButton")
		local maximizeBtn = Instance.new("TextButton")
		local closeBtn = Instance.new("TextButton")
		local titleLabel = Instance.new("TextLabel")
		local dragHandle = Instance.new("TextButton")
		local contentArea = Instance.new("Frame")
		local sidebar = Instance.new("ScrollingFrame")
		local mainContent = Instance.new("Frame")
		local statusBar = Instance.new("Frame")

		-- Main ScreenGui setup
		screenGui.Name = "XyrosModernGUI"
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.Parent = game.CoreGui

		-- Background with blur backdrop
		background.Name = "Background"
		background.Parent = screenGui
		background.AnchorPoint = Vector2.new(0.5, 0.5)
		background.BackgroundColor3 = Theme.Colors.Background
		background.BackgroundTransparency = Theme.Transparency.Backdrop
		background.BorderSizePixel = 0
		background.Position = UDim2.new(0.5, 0, 0.5, 0)
		background.Size = UDim2.new(1, 0, 1, 0)
		background.ZIndex = 1

		-- Main window container with frosted glass effect
		local windowContainer = Instance.new("Frame")
		windowContainer.Name = "WindowContainer"
		windowContainer.Parent = background
		windowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		windowContainer.BackgroundColor3 = Theme.Colors.Glass
		windowContainer.BackgroundTransparency = Theme.Transparency.Glass
		windowContainer.BorderSizePixel = 0
		windowContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
		windowContainer.ClipsDescendants = true
		windowContainer.ZIndex = 2

		-- Apply responsive sizing
		local isMobile = DesignSystem.CreateResponsiveLayout(windowContainer)

		-- Window glass effect and styling
		local windowCorner = Instance.new("UICorner")
		windowCorner.CornerRadius = UDim.new(0, Theme.Rounding.Large)
		windowCorner.Parent = windowContainer

		local windowStroke = Instance.new("UIStroke")
		windowStroke.Color = Theme.Colors.BorderLight
		windowStroke.Transparency = 0.5
		windowStroke.Thickness = 1
		windowStroke.Parent = windowContainer

		-- Add subtle shadow effect
		local shadowFrame = Instance.new("Frame")
		shadowFrame.Name = "Shadow"
		shadowFrame.Parent = background
		shadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		shadowFrame.BackgroundColor3 = Theme.Effects.ShadowMedium.Color
		shadowFrame.BackgroundTransparency = Theme.Effects.ShadowMedium.Transparency
		shadowFrame.BorderSizePixel = 0
		shadowFrame.Position = UDim2.new(0.5, 4, 0.5, 4)
		shadowFrame.Size = windowContainer.Size
		shadowFrame.ZIndex = 1

		local shadowCorner = Instance.new("UICorner")
		shadowCorner.CornerRadius = UDim.new(0, Theme.Rounding.Large)
		shadowCorner.Parent = shadowFrame

		-- Modern Title Bar
		titleBar.Name = "TitleBar"
		titleBar.Parent = windowContainer
		titleBar.BackgroundColor3 = Theme.Colors.GlassLight
		titleBar.BackgroundTransparency = Theme.Transparency.GlassLight
		titleBar.BorderSizePixel = 0
		titleBar.Size = UDim2.new(1, 0, 0, isMobile and 50 or 40)
		titleBar.ZIndex = 3

		local titleBarCorner = Instance.new("UICorner")
		titleBarCorner.CornerRadius = UDim.new(0, Theme.Rounding.Large)
		titleBarCorner.Parent = titleBar

		-- Hide bottom corners of title bar
		local titleBarBottom = Instance.new("Frame")
		titleBarBottom.Name = "TitleBarBottom"
		titleBarBottom.Parent = titleBar
		titleBarBottom.AnchorPoint = Vector2.new(0, 1)
		titleBarBottom.BackgroundColor3 = Theme.Colors.GlassLight
		titleBarBottom.BackgroundTransparency = Theme.Transparency.GlassLight
		titleBarBottom.BorderSizePixel = 0
		titleBarBottom.Position = UDim2.new(0, 0, 1, 0)
		titleBarBottom.Size = UDim2.new(1, 0, 0, Theme.Rounding.Large)

		-- Title bar separator
		local titleSeparator = Instance.new("Frame")
		titleSeparator.Name = "TitleSeparator"
		titleSeparator.Parent = titleBar
		titleSeparator.AnchorPoint = Vector2.new(0, 1)
		titleSeparator.BackgroundColor3 = Theme.Colors.Primary
		titleSeparator.BorderSizePixel = 0
		titleSeparator.Position = UDim2.new(0, 0, 1, 0)
		titleSeparator.Size = UDim2.new(1, 0, 0, 2)

		-- Add gradient to separator
		local separatorGradient = Instance.new("UIGradient")
		separatorGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Theme.Colors.Primary),
			ColorSequenceKeypoint.new(0.5, Theme.Colors.Secondary),
			ColorSequenceKeypoint.new(1, Theme.Colors.Primary)
		}
		separatorGradient.Parent = titleSeparator

		-- Window title
		titleLabel.Name = "TitleLabel"
		titleLabel.Parent = titleBar
		titleLabel.BackgroundTransparency = 1
		titleLabel.Position = UDim2.new(0, Theme.Spacing.MD, 0, 0)
		titleLabel.Size = UDim2.new(0.6, -Theme.Spacing.MD, 1, 0)
		titleLabel.Font = Theme.Font.Heading
		titleLabel.Text = "Xyros Modern GUI"
		titleLabel.TextColor3 = Theme.Colors.TextPrimary
		titleLabel.TextSize = isMobile and 18 or 16
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextYAlignment = Enum.TextYAlignment.Center

		-- Window controls container
		windowControls.Name = "WindowControls"
		windowControls.Parent = titleBar
		windowControls.AnchorPoint = Vector2.new(1, 0)
		windowControls.BackgroundTransparency = 1
		windowControls.Position = UDim2.new(1, -Theme.Spacing.SM, 0, Theme.Spacing.SM)
		windowControls.Size = UDim2.new(0, isMobile and 120 or 90, 0, isMobile and 35 or 25)

		local controlsLayout = Instance.new("UIListLayout")
		controlsLayout.FillDirection = Enum.FillDirection.Horizontal
		controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		controlsLayout.Padding = UDim.new(0, Theme.Spacing.XS)
		controlsLayout.Parent = windowControls

		-- Modern window control buttons
		local function createControlButton(name, symbol, color, layoutOrder)
			local btn = Instance.new("TextButton")
			btn.Name = name
			btn.Parent = windowControls
			btn.BackgroundColor3 = color
			btn.BackgroundTransparency = 0.3
			btn.BorderSizePixel = 0
			btn.Size = UDim2.new(0, isMobile and 35 or 25, 1, 0)
			btn.Font = Theme.Font.Body
			btn.Text = symbol
			btn.TextColor3 = Theme.Colors.TextPrimary
			btn.TextSize = isMobile and 16 or 12
			btn.AutoButtonColor = false
			btn.LayoutOrder = layoutOrder

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, Theme.Rounding.Small)
			btnCorner.Parent = btn

			-- Hover effects
			btn.MouseEnter:Connect(function()
				local hoverTween = TweenService:Create(btn,
					TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
					{BackgroundTransparency = 0.1}
				)
				hoverTween:Play()
			end)

			btn.MouseLeave:Connect(function()
				local leaveTween = TweenService:Create(btn,
					TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
					{BackgroundTransparency = 0.3}
				)
				leaveTween:Play()
			end)

			return btn
		end

		minimizeBtn = createControlButton("Minimize", "−", Theme.Colors.Warning, 1)
		maximizeBtn = createControlButton("Maximize", "□", Theme.Colors.Info, 2)
		closeBtn = createControlButton("Close", "×", Theme.Colors.Error, 3)

		-- Drag handle for window movement
		dragHandle.Name = "DragHandle"
		dragHandle.Parent = titleBar
		dragHandle.BackgroundTransparency = 1
		dragHandle.Size = UDim2.new(1, 0, 1, 0)
		dragHandle.Text = ""
		dragHandle.AutoButtonColor = false
		dragHandle.ZIndex = 4

		-- Content area setup
		contentArea.Name = "ContentArea"
		contentArea.Parent = windowContainer
		contentArea.BackgroundTransparency = 1
		contentArea.BorderSizePixel = 0
		contentArea.Position = UDim2.new(0, 0, 0, titleBar.Size.Y.Offset)
		contentArea.Size = UDim2.new(1, 0, 1, -titleBar.Size.Y.Offset - (isMobile and 30 or 20))

		-- Pages folder
		pagesFolder.Name = "Pages"
		pagesFolder.Parent = contentArea

		-- Modern sidebar with frosted glass
		sidebar.Name = "Sidebar"
		sidebar.Parent = contentArea
		sidebar.BackgroundColor3 = Theme.Colors.GlassDark
		sidebar.BackgroundTransparency = Theme.Transparency.GlassDark
		sidebar.BorderSizePixel = 0
		sidebar.Position = UDim2.new(0, Theme.Spacing.SM, 0, Theme.Spacing.SM)
		sidebar.Size = UDim2.new(0, isMobile and 200 or 180, 1, -Theme.Spacing.MD)
		sidebar.ScrollBarThickness = 2
		sidebar.ScrollBarImageColor3 = Theme.Colors.Primary
		sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
		sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y

		local sidebarCorner = Instance.new("UICorner")
		sidebarCorner.CornerRadius = UDim.new(0, Theme.Rounding.Medium)
		sidebarCorner.Parent = sidebar

		local sidebarStroke = Instance.new("UIStroke")
		sidebarStroke.Color = Theme.Colors.Border
		sidebarStroke.Transparency = 0.7
		sidebarStroke.Thickness = 1
		sidebarStroke.Parent = sidebar

		local sidebarLayout = Instance.new("UIListLayout")
		sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
		sidebarLayout.Padding = UDim.new(0, Theme.Spacing.XS)
		sidebarLayout.Parent = sidebar

		local sidebarPadding = Instance.new("UIPadding")
		sidebarPadding.PaddingTop = UDim.new(0, Theme.Spacing.SM)
		sidebarPadding.PaddingBottom = UDim.new(0, Theme.Spacing.SM)
		sidebarPadding.PaddingLeft = UDim.new(0, Theme.Spacing.SM)
		sidebarPadding.PaddingRight = UDim.new(0, Theme.Spacing.SM)
		sidebarPadding.Parent = sidebar

		-- Main content area
		mainContent.Name = "MainContent"
		mainContent.Parent = contentArea
		mainContent.BackgroundTransparency = 1
		mainContent.BorderSizePixel = 0
		mainContent.Position = UDim2.new(0, sidebar.Size.X.Offset + Theme.Spacing.MD, 0, Theme.Spacing.SM)
		mainContent.Size = UDim2.new(1, -(sidebar.Size.X.Offset + Theme.Spacing.MD + Theme.Spacing.SM), 1, -Theme.Spacing.MD)

		-- Status bar
		statusBar.Name = "StatusBar"
		statusBar.Parent = windowContainer
		statusBar.AnchorPoint = Vector2.new(0, 1)
		statusBar.BackgroundColor3 = Theme.Colors.GlassDark
		statusBar.BackgroundTransparency = Theme.Transparency.GlassDark
		statusBar.BorderSizePixel = 0
		statusBar.Position = UDim2.new(0, 0, 1, 0)
		statusBar.Size = UDim2.new(1, 0, 0, isMobile and 30 or 20)

		local statusCorner = Instance.new("UICorner")
		statusCorner.CornerRadius = UDim.new(0, Theme.Rounding.Large)
		statusCorner.Parent = statusBar

		-- Hide top corners of status bar
		local statusTop = Instance.new("Frame")
		statusTop.Name = "StatusTop"
		statusTop.Parent = statusBar
		statusTop.BackgroundColor3 = Theme.Colors.GlassDark
		statusTop.BackgroundTransparency = Theme.Transparency.GlassDark
		statusTop.BorderSizePixel = 0
		statusTop.Size = UDim2.new(1, 0, 0, Theme.Rounding.Large)

		-- Store references for modern elements
		modernElements.screenGui = screenGui
		modernElements.windowContainer = windowContainer
		modernElements.titleBar = titleBar
		modernElements.sidebar = sidebar
		modernElements.mainContent = mainContent
		modernElements.pagesFolder = pagesFolder

		return screenGui
	end

	-- Modern Tab Creation with Frosted Glass Design
	local function createTab()
		local tab = Instance.new("TextButton")
		local tabContainer = Instance.new("Frame")
		local tabIcon = Instance.new("ImageLabel")
		local tabText = Instance.new("TextLabel")
		local tabIndicator = Instance.new("Frame")
		local tabHoverEffect = Instance.new("Frame")

		-- Main tab button
		tab.Name = "ModernTab"
		tab.BackgroundColor3 = Theme.Colors.Glass
		tab.BackgroundTransparency = Theme.Transparency.Glass
		tab.BorderSizePixel = 0
		tab.Size = UDim2.new(1, 0, 0, 45)
		tab.AutoButtonColor = false
		tab.Font = Theme.Font.Body
		tab.Text = ""
		tab.TextColor3 = Theme.Colors.TextSecondary
		tab.TextSize = 14

		-- Tab container for glass effect
		tabContainer.Name = "TabContainer"
		tabContainer.Parent = tab
		tabContainer.BackgroundColor3 = Theme.Colors.Glass
		tabContainer.BackgroundTransparency = 1
		tabContainer.BorderSizePixel = 0
		tabContainer.Size = UDim2.new(1, 0, 1, 0)

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, Theme.Rounding.Medium)
		tabCorner.Parent = tab

		-- Hover effect overlay
		tabHoverEffect.Name = "HoverEffect"
		tabHoverEffect.Parent = tab
		tabHoverEffect.BackgroundColor3 = Theme.Colors.Hover
		tabHoverEffect.BackgroundTransparency = 1
		tabHoverEffect.BorderSizePixel = 0
		tabHoverEffect.Size = UDim2.new(1, 0, 1, 0)

		local hoverCorner = Instance.new("UICorner")
		hoverCorner.CornerRadius = UDim.new(0, Theme.Rounding.Medium)
		hoverCorner.Parent = tabHoverEffect

		-- Tab icon
		tabIcon.Name = "TabIcon"
		tabIcon.Parent = tab
		tabIcon.AnchorPoint = Vector2.new(0, 0.5)
		tabIcon.BackgroundTransparency = 1
		tabIcon.Position = UDim2.new(0, Theme.Spacing.SM, 0.5, 0)
		tabIcon.Size = UDim2.new(0, 20, 0, 20)
		tabIcon.Image = "rbxassetid://10746039695"
		tabIcon.ImageColor3 = Theme.Colors.TextMuted
		tabIcon.ImageTransparency = 0.3

		-- Tab text
		tabText.Name = "TabText"
		tabText.Parent = tab
		tabText.BackgroundTransparency = 1
		tabText.Position = UDim2.new(0, Theme.Spacing.SM + 28, 0, 0)
		tabText.Size = UDim2.new(1, -(Theme.Spacing.SM + 32), 1, 0)
		tabText.Font = Theme.Font.Body
		tabText.Text = "Tab Name"
		tabText.TextColor3 = Theme.Colors.TextSecondary
		tabText.TextSize = 14
		tabText.TextXAlignment = Enum.TextXAlignment.Left
		tabText.TextYAlignment = Enum.TextYAlignment.Center
		tabText.ClipsDescendants = true

		-- Active indicator
		tabIndicator.Name = "ActiveIndicator"
		tabIndicator.Parent = tab
		tabIndicator.BackgroundColor3 = Theme.Colors.Primary
		tabIndicator.BorderSizePixel = 0
		tabIndicator.Position = UDim2.new(0, 0, 0, 0)
		tabIndicator.Size = UDim2.new(0, 0, 1, 0)

		local indicatorCorner = Instance.new("UICorner")
		indicatorCorner.CornerRadius = UDim.new(0, Theme.Rounding.Small)
		indicatorCorner.Parent = tabIndicator

		-- Add gradient to indicator
		local indicatorGradient = Instance.new("UIGradient")
		indicatorGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Theme.Colors.Primary),
			ColorSequenceKeypoint.new(1, Theme.Colors.Secondary)
		}
		indicatorGradient.Rotation = 90
		indicatorGradient.Parent = tabIndicator

		-- Tab interaction animations
		local function animateTabHover(isHovering)
			local targetTransparency = isHovering and 0.8 or 1
			local targetIconTransparency = isHovering and 0.1 or 0.3
			local targetTextColor = isHovering and Theme.Colors.TextPrimary or Theme.Colors.TextSecondary

			local hoverTween = TweenService:Create(tabHoverEffect,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{BackgroundTransparency = targetTransparency}
			)

			local iconTween = TweenService:Create(tabIcon,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{ImageTransparency = targetIconTransparency, ImageColor3 = targetTextColor}
			)

			local textTween = TweenService:Create(tabText,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{TextColor3 = targetTextColor}
			)

			hoverTween:Play()
			iconTween:Play()
			textTween:Play()
		end

		local function animateTabActive(isActive)
			local targetIndicatorSize = isActive and UDim2.new(0, 4, 1, 0) or UDim2.new(0, 0, 1, 0)
			local targetBackgroundTransparency = isActive and 0.7 or Theme.Transparency.Glass
			local targetTextColor = isActive and Theme.Colors.TextPrimary or Theme.Colors.TextSecondary
			local targetIconColor = isActive and Theme.Colors.Primary or Theme.Colors.TextMuted

			local indicatorTween = TweenService:Create(tabIndicator,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{Size = targetIndicatorSize}
			)

			local backgroundTween = TweenService:Create(tab,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{BackgroundTransparency = targetBackgroundTransparency}
			)

			local textTween = TweenService:Create(tabText,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{TextColor3 = targetTextColor}
			)

			local iconTween = TweenService:Create(tabIcon,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{ImageColor3 = targetIconColor, ImageTransparency = isActive and 0 or 0.3}
			)

			indicatorTween:Play()
			backgroundTween:Play()
			textTween:Play()
			iconTween:Play()
		end

		-- Connect hover events
		tab.MouseEnter:Connect(function()
			animateTabHover(true)
		end)

		tab.MouseLeave:Connect(function()
			animateTabHover(false)
		end)

		-- Store animation functions for external use
		tab.AnimateActive = animateTabActive
		tab.TabText = tabText
		tab.TabIcon = tabIcon
		tab.TabIndicator = tabIndicator

		return tab
	end

	local function createPage()
		local page = Instance.new("Frame")
		local leftScrollingFrame = Instance.new("ScrollingFrame")
		local leftScrollingFrameList = Instance.new("UIListLayout")
		local rightScrollingFrame = Instance.new("ScrollingFrame")
		local rightScrollingFrameList = Instance.new("UIListLayout")

		page.Name = "Page"
		page.AnchorPoint = Vector2.new(1, 1)
		page.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		page.BackgroundTransparency = 1.000
		page.BorderSizePixel = 0
		page.Position = UDim2.new(1, -10, 1, -5)
		page.Visible = false
		page.Size = UDim2.new(.775,-25,0,0)

		leftScrollingFrame.Name = "LeftScrollingFrame"
		leftScrollingFrame.Active = true
		leftScrollingFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		leftScrollingFrame.BackgroundTransparency = 1.000
		leftScrollingFrame.Size = UDim2.new(0.5, -5, 1, 0)
		leftScrollingFrame.ScrollBarThickness = 0
		leftScrollingFrame.CanvasSize = UDim2.fromScale(0,0)
		leftScrollingFrame.Parent = page

		leftScrollingFrameList.Name = "LeftScrollingFrameList"
		leftScrollingFrameList.Padding = UDim.new(0,7)
		leftScrollingFrameList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		leftScrollingFrameList.Parent = leftScrollingFrame

		rightScrollingFrame.Name = "RightScrollingFrame"
		rightScrollingFrame.Active = true
		rightScrollingFrame.AnchorPoint = Vector2.new(1, 0)
		rightScrollingFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		rightScrollingFrame.BackgroundTransparency = 1.000
		rightScrollingFrame.Position = UDim2.new(1, 0, 0, 0)
		rightScrollingFrame.Size = UDim2.new(0.5, -5, 1, 0)
		rightScrollingFrame.CanvasSize = UDim2.fromScale(0,0)
		rightScrollingFrame.ScrollBarThickness = 0
		rightScrollingFrame.Parent = page

		rightScrollingFrameList.Name = "RightScrollingFrameList"
		rightScrollingFrameList.Padding = UDim.new(0,7)
		rightScrollingFrameList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		rightScrollingFrameList.Parent = rightScrollingFrame

		return page
	end

	local function createSection()
		local section = Instance.new("Frame")
		local heading = Instance.new("Frame")
		local headingSeperator = Instance.new("Frame")
		local title = Instance.new("TextLabel")
		local titleUIPadding = Instance.new("UIPadding")
		local resizeButton = Instance.new("ImageButton")
		local resizeButtonAspect = Instance.new("UIAspectRatioConstraint")
		local elementHolder = Instance.new("Frame")
		local elementHolderList = Instance.new("UIListLayout")
		local elementHolderPadding = Instance.new("UIPadding")

		section.Name = "Section"
		section.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		section.BorderSizePixel = 0
		section.Size = UDim2.new(1, 0, 0, 200)
		section.ClipsDescendants = true

		heading.Name = "Heading"
		heading.Parent = section
		heading.BackgroundColor3 = Color3.fromRGB(40, 41, 52)
		heading.BorderSizePixel = 0
		heading.Size = UDim2.new(1, 0, 0, 22)

		headingSeperator.Name = "HeadingSeperator"
		headingSeperator.Parent = heading
		headingSeperator.AnchorPoint = Vector2.new(0, 1)
		headingSeperator.BackgroundColor3 = Color3.fromRGB(163, 33, 38)
		headingSeperator.BorderSizePixel = 0
		headingSeperator.Position = UDim2.new(0, 0, 1, 0)
		headingSeperator.Size = UDim2.new(1, 0, 0, 2)

		title.Name = "Title"
		title.Parent = heading
		title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		title.BackgroundTransparency = 1.000
		title.Size = UDim2.new(1, -20, 0, 20)
		title.Font = Enum.Font.GothamMedium
		title.Text = "N/A"
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextSize = 14.000
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ClipsDescendants = true

		titleUIPadding.Name = "TitleUIPadding"
		titleUIPadding.Parent = title
		titleUIPadding.PaddingLeft = UDim.new(0, 5)

		resizeButton.Name = "ResizeButton"
		resizeButton.Parent = heading
		resizeButton.AnchorPoint = Vector2.new(1, 0.5)
		resizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		resizeButton.BackgroundTransparency = 1.000
		resizeButton.BorderSizePixel = 0
		resizeButton.Position = UDim2.new(1, -5, 0.5, 0)
		resizeButton.Size = UDim2.fromScale(.75, .75)
		resizeButton.Image = "rbxassetid://11269835227"

		resizeButtonAspect.Parent = resizeButton

		elementHolder.Name = "ElementHolder"
		elementHolder.Parent = section
		elementHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		elementHolder.BackgroundTransparency = 1.000
		elementHolder.BorderSizePixel = 0
		elementHolder.Position = UDim2.new(0, 0, 0, 22)
		elementHolder.Size = UDim2.new(1, 0, 0, 178)
		elementHolder.ClipsDescendants = true

		elementHolderList.Name = "ElementHolderList"
		elementHolderList.Parent = elementHolder
		elementHolderList.SortOrder = Enum.SortOrder.LayoutOrder
		elementHolderList.Padding = UDim.new(0, 5)

		elementHolderPadding.Name = "ElementHolderPadding"
		elementHolderPadding.Parent = elementHolder
		elementHolderPadding.PaddingBottom = UDim.new(0, 4)
		elementHolderPadding.PaddingLeft = UDim.new(0, 5)
		elementHolderPadding.PaddingRight = UDim.new(0, 5)
		elementHolderPadding.PaddingTop = UDim.new(0, 4)

		return section
	end

	local function createTitle()
		local title = Instance.new("Frame")
		local titleText = Instance.new("TextLabel")
		local design = Instance.new("Frame")
		local designGradient = Instance.new("UIGradient")

		title.Name = "Title"
		title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		title.BackgroundTransparency = 1.000
		title.BorderSizePixel = 0
		title.Size = UDim2.new(1, 0, 0, 14)

		titleText.Name = "TitleText"
		titleText.Parent = title
		titleText.AnchorPoint = Vector2.new(0.5, 0)
		titleText.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		titleText.BorderSizePixel = 0
		titleText.Position = UDim2.new(0.5, 0, 0, 0)
		titleText.Size = UDim2.new(0.200000003, 0, 1, 0)
		titleText.ZIndex = 2
		titleText.Font = Enum.Font.GothamMedium
		titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleText.Text = "N/A"
		titleText.TextSize = 14.000

		design.Name = "Design"
		design.Parent = title
		design.AnchorPoint = Vector2.new(0, 0.5)
		design.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		design.BorderSizePixel = 0
		design.Position = UDim2.new(0, 0, 0.5, 0)
		design.Size = UDim2.new(1, 0, 0.25, 0)

		designGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(31, 31, 43)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(163, 33, 38)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(31, 31, 43))}
		designGradient.Name = "DesignGradient"
		designGradient.Parent = design

		return title
	end

	local function createLabel()
		local label = Instance.new("Frame")
		local labelPadding = Instance.new("UIPadding")
		local labelBackground = Instance.new("Frame")
		local labelText = Instance.new("TextLabel")
		local labelTextPadding = Instance.new("UIPadding")
		local labelBackgroundPadding = Instance.new("UIPadding")

		label.Name = "Label"
		label.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		label.BorderSizePixel = 0
		label.Size = UDim2.new(1, 0, 0, 18)

		labelPadding.Name = "LabelPadding"
		labelPadding.Parent = label
		labelPadding.PaddingBottom = UDim.new(0, 1)
		labelPadding.PaddingLeft = UDim.new(0, 1)
		labelPadding.PaddingRight = UDim.new(0, 1)
		labelPadding.PaddingTop = UDim.new(0, 1)

		labelBackground.Name = "LabelBackground"
		labelBackground.Parent = label
		labelBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		labelBackground.BorderSizePixel = 0
		labelBackground.Size = UDim2.new(1, 0, 1, 0)

		labelText.Name = "LabelText"
		labelText.Parent = labelBackground
		labelText.AnchorPoint = Vector2.new(0.5, 0)
		labelText.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		labelText.BorderSizePixel = 0
		labelText.Position = UDim2.new(0.5, 0, 0, 0)
		labelText.Size = UDim2.new(1, 0, 1, 0)
		labelText.ZIndex = 2
		labelText.Font = Enum.Font.GothamMedium
		labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
		labelText.TextSize = 14.000
		labelText.TextWrapped = true
		labelText.TextXAlignment = Enum.TextXAlignment.Left
		labelText.TextYAlignment = Enum.TextYAlignment.Top

		labelTextPadding.Name = "LabelTextPadding"
		labelTextPadding.Parent = labelText
		labelTextPadding.PaddingLeft = UDim.new(0, 4)
		labelTextPadding.PaddingRight = UDim.new(0, 4)
		labelTextPadding.PaddingBottom = UDim.new(0, 2)
		labelTextPadding.PaddingTop = UDim.new(0, 2)

		labelBackgroundPadding.Name = "LabelBackgroundPadding"
		labelBackgroundPadding.Parent = labelBackground
		labelBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		labelBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		labelBackgroundPadding.PaddingRight = UDim.new(0, 1)
		labelBackgroundPadding.PaddingTop = UDim.new(0, 1)

		return label
	end

	-- Modern Toggle with Smooth Animations
	local function createToggle()
		local toggle = Instance.new("TextButton")
		local toggleContainer = Instance.new("Frame")
		local toggleText = Instance.new("TextLabel")
		local switchTrack = Instance.new("Frame")
		local switchThumb = Instance.new("Frame")
		local switchGlow = Instance.new("Frame")

		-- Main toggle button
		toggle.Name = "ModernToggle"
		toggle.BackgroundTransparency = 1
		toggle.BorderSizePixel = 0
		toggle.Size = UDim2.new(1, 0, 0, 32)
		toggle.AutoButtonColor = false
		toggle.Font = Theme.Font.Body
		toggle.Text = ""
		toggle.TextSize = 14

		-- Toggle container
		toggleContainer.Name = "ToggleContainer"
		toggleContainer.Parent = toggle
		toggleContainer.BackgroundTransparency = 1
		toggleContainer.Size = UDim2.new(1, 0, 1, 0)

		-- Toggle text label
		toggleText.Name = "ToggleText"
		toggleText.Parent = toggle
		toggleText.BackgroundTransparency = 1
		toggleText.Position = UDim2.new(0, 0, 0, 0)
		toggleText.Size = UDim2.new(1, -60, 1, 0)
		toggleText.Font = Theme.Font.Body
		toggleText.Text = "Toggle Option"
		toggleText.TextColor3 = Theme.Colors.TextPrimary
		toggleText.TextSize = 14
		toggleText.TextXAlignment = Enum.TextXAlignment.Left
		toggleText.TextYAlignment = Enum.TextYAlignment.Center

		-- Switch track (background)
		switchTrack.Name = "SwitchTrack"
		switchTrack.Parent = toggle
		switchTrack.AnchorPoint = Vector2.new(1, 0.5)
		switchTrack.BackgroundColor3 = Theme.Colors.GlassDark
		switchTrack.BackgroundTransparency = Theme.Transparency.GlassDark
		switchTrack.BorderSizePixel = 0
		switchTrack.Position = UDim2.new(1, 0, 0.5, 0)
		switchTrack.Size = UDim2.new(0, 48, 0, 24)

		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(0.5, 0)
		trackCorner.Parent = switchTrack

		local trackStroke = Instance.new("UIStroke")
		trackStroke.Color = Theme.Colors.Border
		trackStroke.Transparency = 0.6
		trackStroke.Thickness = 1
		trackStroke.Parent = switchTrack

		-- Switch thumb (movable part)
		switchThumb.Name = "SwitchThumb"
		switchThumb.Parent = switchTrack
		switchThumb.AnchorPoint = Vector2.new(0.5, 0.5)
		switchThumb.BackgroundColor3 = Theme.Colors.TextPrimary
		switchThumb.BorderSizePixel = 0
		switchThumb.Position = UDim2.new(0.25, 0, 0.5, 0)
		switchThumb.Size = UDim2.new(0, 18, 0, 18)

		local thumbCorner = Instance.new("UICorner")
		thumbCorner.CornerRadius = UDim.new(0.5, 0)
		thumbCorner.Parent = switchThumb

		-- Glow effect for active state
		switchGlow.Name = "SwitchGlow"
		switchGlow.Parent = switchThumb
		switchGlow.AnchorPoint = Vector2.new(0.5, 0.5)
		switchGlow.BackgroundColor3 = Theme.Colors.Primary
		switchGlow.BackgroundTransparency = 1
		switchGlow.BorderSizePixel = 0
		switchGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
		switchGlow.Size = UDim2.new(1.5, 0, 1.5, 0)

		local glowCorner = Instance.new("UICorner")
		glowCorner.CornerRadius = UDim.new(0.5, 0)
		glowCorner.Parent = switchGlow

		-- Toggle state management
		local isToggled = false

		local function animateToggle(enabled)
			isToggled = enabled

			-- Animate thumb position
			local thumbPosition = enabled and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)
			local thumbTween = TweenService:Create(switchThumb,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{Position = thumbPosition}
			)

			-- Animate track color
			local trackColor = enabled and Theme.Colors.Primary or Theme.Colors.GlassDark
			local trackTween = TweenService:Create(switchTrack,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{BackgroundColor3 = trackColor}
			)

			-- Animate thumb color
			local thumbColor = enabled and Theme.Colors.TextPrimary or Theme.Colors.TextSecondary
			local thumbColorTween = TweenService:Create(switchThumb,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{BackgroundColor3 = thumbColor}
			)

			-- Animate glow effect
			local glowTransparency = enabled and 0.7 or 1
			local glowTween = TweenService:Create(switchGlow,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{BackgroundTransparency = glowTransparency}
			)

			-- Animate stroke color
			local strokeColor = enabled and Theme.Colors.Primary or Theme.Colors.Border
			local strokeTween = TweenService:Create(trackStroke,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{Color = strokeColor}
			)

			thumbTween:Play()
			trackTween:Play()
			thumbColorTween:Play()
			glowTween:Play()
			strokeTween:Play()
		end

		-- Hover effects
		toggle.MouseEnter:Connect(function()
			local hoverTween = TweenService:Create(switchTrack,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{Size = UDim2.new(0, 50, 0, 26)}
			)
			hoverTween:Play()
		end)

		toggle.MouseLeave:Connect(function()
			local leaveTween = TweenService:Create(switchTrack,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{Size = UDim2.new(0, 48, 0, 24)}
			)
			leaveTween:Play()
		end)

		-- Click handler
		toggle.MouseButton1Click:Connect(function()
			animateToggle(not isToggled)
		end)

		-- Store references and functions
		toggle.ToggleText = toggleText
		toggle.SetToggled = animateToggle
		toggle.IsToggled = function() return isToggled end

		return toggle
	end

	-- Modern Button with Frosted Glass and Gradient Effects
	local function createButton()
		local button = Instance.new("TextButton")
		local buttonText = Instance.new("TextLabel")
		local buttonGlass = Instance.new("Frame")
		local buttonGradient = Instance.new("UIGradient")
		local buttonShine = Instance.new("Frame")
		local buttonShineGradient = Instance.new("UIGradient")

		-- Main button element
		button.Name = "ModernButton"
		button.BackgroundColor3 = Theme.Colors.Primary
		button.BackgroundTransparency = 1
		button.BorderSizePixel = 0
		button.Size = UDim2.new(1, 0, 0, 36)
		button.AutoButtonColor = false
		button.Font = Theme.Font.Body
		button.Text = ""
		button.TextSize = 14

		-- Glass container for background and effects
		buttonGlass.Name = "ButtonGlass"
		buttonGlass.Parent = button
		buttonGlass.BackgroundColor3 = Theme.Colors.Primary
		buttonGlass.BackgroundTransparency = Theme.Transparency.Glass
		buttonGlass.BorderSizePixel = 0
		buttonGlass.Size = UDim2.new(1, 0, 1, 0)
		buttonGlass.ClipsDescendants = true

		local glassCorner = Instance.new("UICorner")
		glassCorner.CornerRadius = UDim.new(0, Theme.Rounding.Small)
		glassCorner.Parent = buttonGlass

		local glassStroke = Instance.new("UIStroke")
		glassStroke.Color = Theme.Colors.PrimaryVariant
		glassStroke.Transparency = 0.5
		glassStroke.Thickness = 1
		glassStroke.Parent = buttonGlass

		-- Gradient background
		buttonGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Theme.Colors.Primary),
			ColorSequenceKeypoint.new(1, Theme.Colors.Secondary)
		}
		buttonGradient.Rotation = 45
		buttonGradient.Parent = buttonGlass

		-- Shine effect for hover
		buttonShine.Name = "ButtonShine"
		buttonShine.Parent = buttonGlass
		buttonShine.BackgroundColor3 = Color3.new(1, 1, 1)
		buttonShine.BackgroundTransparency = 1
		buttonShine.BorderSizePixel = 0
		buttonShine.Position = UDim2.new(-1, 0, 0, 0)
		buttonShine.Size = UDim2.new(1, 0, 1, 0)

		buttonShineGradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.8),
			NumberSequenceKeypoint.new(1, 1)
		}
		buttonShineGradient.Rotation = -45
		buttonShineGradient.Parent = buttonShine

		-- Button text
		buttonText.Name = "ButtonText"
		buttonText.Parent = button
		buttonText.BackgroundTransparency = 1
		buttonText.Size = UDim2.new(1, 0, 1, 0)
		buttonText.Font = Theme.Font.Heading
		buttonText.Text = "Modern Button"
		buttonText.TextColor3 = Theme.Colors.TextPrimary
		buttonText.TextSize = 14
		buttonText.TextWrapped = true
		buttonText.TextXAlignment = Enum.TextXAlignment.Center
		buttonText.TextYAlignment = Enum.TextYAlignment.Center

		-- Interaction animations
		local function animateButtonHover(isHovering)
			local targetPosition = isHovering and UDim2.new(1, 0, 0, 0) or UDim2.new(-1, 0, 0, 0)
			local shineTween = TweenService:Create(buttonShine,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{Position = targetPosition}
			)
			shineTween:Play()
		end

		local function animateButtonClick()
			local clickTween = TweenService:Create(buttonGlass,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut, 0, true),
				{Size = UDim2.new(0.98, 0, 0.95, 0)}
			)
			clickTween:Play()
		end

		-- Connect events
		button.MouseEnter:Connect(function()
			animateButtonHover(true)
		end)

		button.MouseLeave:Connect(function()
			animateButtonHover(false)
		end)

		button.MouseButton1Down:Connect(function()
			animateButtonClick()
		end)

		-- Store references
		button.ButtonText = buttonText

		return button
	end

	-- Modern Dropdown with Frosted Glass and Smooth Animations
	local function createDropdown()
		local dropdown = Instance.new("Frame")
		local dropdownButton = Instance.new("TextButton")
		local buttonGlass = Instance.new("Frame")
		local dropdownText = Instance.new("TextLabel")
		local dropdownIcon = Instance.new("ImageLabel")
		local dropdownMenu = Instance.new("ScrollingFrame")
		local menuGlass = Instance.new("Frame")
		local menuContent = Instance.new("Frame")

		-- Main dropdown container
		dropdown.Name = "ModernDropdown"
		dropdown.BackgroundTransparency = 1
		dropdown.BorderSizePixel = 0
		dropdown.ClipsDescendants = true
		dropdown.Size = UDim2.new(1, 0, 0, 36)

		-- Dropdown button
		dropdownButton.Name = "DropdownButton"
		dropdownButton.Parent = dropdown
		dropdownButton.BackgroundTransparency = 1
		dropdownButton.BorderSizePixel = 0
		dropdownButton.Size = UDim2.new(1, 0, 0, 36)
		dropdownButton.AutoButtonColor = false
		dropdownButton.Font = Theme.Font.Body
		dropdownButton.Text = ""
		dropdownButton.TextSize = 14

		-- Button glass background
		buttonGlass.Name = "ButtonGlass"
		buttonGlass.Parent = dropdownButton
		buttonGlass.BackgroundColor3 = Theme.Colors.GlassLight
		buttonGlass.BackgroundTransparency = Theme.Transparency.GlassLight
		buttonGlass.BorderSizePixel = 0
		buttonGlass.Size = UDim2.new(1, 0, 1, 0)

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, Theme.Rounding.Small)
		buttonCorner.Parent = buttonGlass

		local buttonStroke = Instance.new("UIStroke")
		buttonStroke.Color = Theme.Colors.Border
		buttonStroke.Transparency = 0.7
		buttonStroke.Thickness = 1
		buttonStroke.Parent = buttonGlass

		-- Dropdown text
		dropdownText.Name = "DropdownText"
		dropdownText.Parent = dropdownButton
		dropdownText.BackgroundTransparency = 1
		dropdownText.Position = UDim2.new(0, Theme.Spacing.SM, 0, 0)
		dropdownText.Size = UDim2.new(1, -(Theme.Spacing.SM + 30), 1, 0)
		dropdownText.Font = Theme.Font.Body
		dropdownText.Text = "Select Option"
		dropdownText.TextColor3 = Theme.Colors.TextSecondary
		dropdownText.TextSize = 14
		dropdownText.TextXAlignment = Enum.TextXAlignment.Left
		dropdownText.TextYAlignment = Enum.TextYAlignment.Center
		dropdownText.ClipsDescendants = true

		-- Dropdown icon
		dropdownIcon.Name = "DropdownIcon"
		dropdownIcon.Parent = dropdownButton
		dropdownIcon.AnchorPoint = Vector2.new(1, 0.5)
		dropdownIcon.BackgroundTransparency = 1
		dropdownIcon.Position = UDim2.new(1, -Theme.Spacing.SM, 0.5, 0)
		dropdownIcon.Size = UDim2.new(0, 16, 0, 16)
		dropdownIcon.Image = "rbxassetid://11269835227"
		dropdownIcon.ImageColor3 = Theme.Colors.TextMuted
		dropdownIcon.Rotation = 0

		-- Dropdown menu (initially hidden)
		dropdownMenu.Name = "DropdownMenu"
		dropdownMenu.Parent = dropdown
		dropdownMenu.BackgroundTransparency = 1
		dropdownMenu.BorderSizePixel = 0
		dropdownMenu.Position = UDim2.new(0, 0, 1, Theme.Spacing.XS)
		dropdownMenu.Size = UDim2.new(1, 0, 0, 0)
		dropdownMenu.ScrollBarThickness = 2
		dropdownMenu.ScrollBarImageColor3 = Theme.Colors.Primary
		dropdownMenu.CanvasSize = UDim2.new(0, 0, 0, 0)
		dropdownMenu.AutomaticCanvasSize = Enum.AutomaticSize.Y
		dropdownMenu.Visible = false

		-- Menu glass background
		menuGlass.Name = "MenuGlass"
		menuGlass.Parent = dropdownMenu
		menuGlass.BackgroundColor3 = Theme.Colors.Glass
		menuGlass.BackgroundTransparency = Theme.Transparency.Glass
		menuGlass.BorderSizePixel = 0
		menuGlass.Size = UDim2.new(1, 0, 1, 0)

		local menuCorner = Instance.new("UICorner")
		menuCorner.CornerRadius = UDim.new(0, Theme.Rounding.Medium)
		menuCorner.Parent = menuGlass

		local menuStroke = Instance.new("UIStroke")
		menuStroke.Color = Theme.Colors.BorderLight
		menuStroke.Transparency = 0.6
		menuStroke.Thickness = 1
		menuStroke.Parent = menuGlass

		-- Menu content container
		menuContent.Name = "MenuContent"
		menuContent.Parent = dropdownMenu
		menuContent.BackgroundTransparency = 1
		menuContent.Size = UDim2.new(1, 0, 1, 0)

		local menuLayout = Instance.new("UIListLayout")
		menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
		menuLayout.Padding = UDim.new(0, 2)
		menuLayout.Parent = menuContent

		local menuPadding = Instance.new("UIPadding")
		menuPadding.PaddingTop = UDim.new(0, Theme.Spacing.SM)
		menuPadding.PaddingBottom = UDim.new(0, Theme.Spacing.SM)
		menuPadding.PaddingLeft = UDim.new(0, Theme.Spacing.SM)
		menuPadding.PaddingRight = UDim.new(0, Theme.Spacing.SM)
		menuPadding.Parent = menuContent

		-- Dropdown state management
		local isOpen = false
		local selectedValue = nil
		local options = {}

		-- Animation functions
		local function animateDropdownOpen()
			isOpen = true
			dropdownMenu.Visible = true

			-- Animate menu appearance
			local menuTween = TweenService:Create(dropdownMenu,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{Size = UDim2.new(1, 0, 0, math.min(200, #options * 32 + Theme.Spacing.MD))}
			)

			-- Animate icon rotation
			local iconTween = TweenService:Create(dropdownIcon,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{Rotation = 180}
			)

			-- Animate button border
			local borderTween = TweenService:Create(buttonStroke,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{Color = Theme.Colors.Primary, Transparency = 0.4}
			)

			menuTween:Play()
			iconTween:Play()
			borderTween:Play()
		end

		local function animateDropdownClose()
			isOpen = false

			-- Animate menu disappearance
			local menuTween = TweenService:Create(dropdownMenu,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseIn),
				{Size = UDim2.new(1, 0, 0, 0)}
			)

			-- Animate icon rotation
			local iconTween = TweenService:Create(dropdownIcon,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{Rotation = 0}
			)

			-- Animate button border
			local borderTween = TweenService:Create(buttonStroke,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{Color = Theme.Colors.Border, Transparency = 0.7}
			)

			menuTween:Play()
			iconTween:Play()
			borderTween:Play()

			menuTween.Completed:Connect(function()
				dropdownMenu.Visible = false
			end)
		end

		-- Create dropdown option
		local function createDropdownOption(text, value)
			local option = Instance.new("TextButton")
			option.Name = "DropdownOption"
			option.Parent = menuContent
			option.BackgroundColor3 = Theme.Colors.Hover
			option.BackgroundTransparency = 1
			option.BorderSizePixel = 0
			option.Size = UDim2.new(1, 0, 0, 28)
			option.AutoButtonColor = false
			option.Font = Theme.Font.Body
			option.Text = text
			option.TextColor3 = Theme.Colors.TextSecondary
			option.TextSize = 14
			option.TextXAlignment = Enum.TextXAlignment.Left

			local optionCorner = Instance.new("UICorner")
			optionCorner.CornerRadius = UDim.new(0, Theme.Rounding.Small)
			optionCorner.Parent = option

			local optionPadding = Instance.new("UIPadding")
			optionPadding.PaddingLeft = UDim.new(0, Theme.Spacing.SM)
			optionPadding.PaddingRight = UDim.new(0, Theme.Spacing.SM)
			optionPadding.Parent = option

			-- Option hover effects
			option.MouseEnter:Connect(function()
				local hoverTween = TweenService:Create(option,
					TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
					{BackgroundTransparency = 0.8, TextColor3 = Theme.Colors.TextPrimary}
				)
				hoverTween:Play()
			end)

			option.MouseLeave:Connect(function()
				local leaveTween = TweenService:Create(option,
					TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
					{BackgroundTransparency = 1, TextColor3 = Theme.Colors.TextSecondary}
				)
				leaveTween:Play()
			end)

			-- Option selection
			option.MouseButton1Click:Connect(function()
				selectedValue = value
				dropdownText.Text = text
				dropdownText.TextColor3 = Theme.Colors.TextPrimary
				animateDropdownClose()
			end)

			return option
		end

		-- Button interactions
		dropdownButton.MouseButton1Click:Connect(function()
			if isOpen then
				animateDropdownClose()
			else
				animateDropdownOpen()
			end
		end)

		-- Close dropdown when clicking outside
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
				local mousePosition = UserInputService:GetMouseLocation()
				local dropdownPosition = dropdown.AbsolutePosition
				local dropdownSize = dropdown.AbsoluteSize

				if mousePosition.X < dropdownPosition.X or mousePosition.X > dropdownPosition.X + dropdownSize.X or
				   mousePosition.Y < dropdownPosition.Y or mousePosition.Y > dropdownPosition.Y + dropdownSize.Y then
					animateDropdownClose()
				end
			end
		end)

		-- Store references and functions
		dropdown.AddOption = function(text, value)
			table.insert(options, {text = text, value = value or text})
			createDropdownOption(text, value or text)
		end

		dropdown.SetSelected = function(value)
			for _, option in pairs(options) do
				if option.value == value then
					selectedValue = value
					dropdownText.Text = option.text
					dropdownText.TextColor3 = Theme.Colors.TextPrimary
					break
				end
			end
		end

		dropdown.GetSelected = function()
			return selectedValue
		end

		dropdown.DropdownText = dropdownText

		return dropdown
	end

		elementHolderInnerBackgroundList.Name = "ElementHolderInnerBackgroundList"
		elementHolderInnerBackgroundList.Parent = elementHolderInnerBackground
		elementHolderInnerBackgroundList.SortOrder = Enum.SortOrder.LayoutOrder
		elementHolderInnerBackgroundList.Padding = UDim.new(0, 5)

		elementHolderInnerBackgroundPadding.Name = "ElementHolderInnerBackgroundPadding"
		elementHolderInnerBackgroundPadding.Parent = elementHolderInnerBackground
		elementHolderInnerBackgroundPadding.PaddingBottom = UDim.new(0, 4)
		elementHolderInnerBackgroundPadding.PaddingLeft = UDim.new(0, 5)
		elementHolderInnerBackgroundPadding.PaddingRight = UDim.new(0, 5)
		elementHolderInnerBackgroundPadding.PaddingTop = UDim.new(0, 4)

		elementHolderBackgroundPadding.Name = "ElementHolderBackgroundPadding"
		elementHolderBackgroundPadding.Parent = elementHolderBackground
		elementHolderBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingRight = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingTop = UDim.new(0, 1)

		elementHolderPadding.Name = "ElementHolderPadding"
		elementHolderPadding.Parent = elementHolder
		elementHolderPadding.PaddingBottom = UDim.new(0, 1)
		elementHolderPadding.PaddingLeft = UDim.new(0, 1)
		elementHolderPadding.PaddingRight = UDim.new(0, 1)

		return dropdown
	end

	-- Modern Slider with Smooth Animations and Glass Design
	local function createSlider()
		local sliderElement = Instance.new("Frame")
		local headerFrame = Instance.new("Frame")
		local sliderText = Instance.new("TextLabel")
		local valueDisplay = Instance.new("TextBox")
		local sliderTrack = Instance.new("TextButton")
		local trackBackground = Instance.new("Frame")
		local trackFill = Instance.new("Frame")
		local sliderThumb = Instance.new("Frame")
		local thumbGlow = Instance.new("Frame")

		-- Main slider container
		sliderElement.Name = "ModernSlider"
		sliderElement.BackgroundTransparency = 1
		sliderElement.BorderSizePixel = 0
		sliderElement.Size = UDim2.new(1, 0, 0, 50)

		-- Header with label and value
		headerFrame.Name = "HeaderFrame"
		headerFrame.Parent = sliderElement
		headerFrame.BackgroundTransparency = 1
		headerFrame.Size = UDim2.new(1, 0, 0, 20)

		-- Slider label
		sliderText.Name = "SliderText"
		sliderText.Parent = headerFrame
		sliderText.BackgroundTransparency = 1
		sliderText.Size = UDim2.new(0.6, 0, 1, 0)
		sliderText.Font = Theme.Font.Body
		sliderText.Text = "Slider"
		sliderText.TextColor3 = Theme.Colors.TextPrimary
		sliderText.TextSize = 14
		sliderText.TextXAlignment = Enum.TextXAlignment.Left
		sliderText.TextYAlignment = Enum.TextYAlignment.Center

		-- Value display
		valueDisplay.Name = "ValueDisplay"
		valueDisplay.Parent = headerFrame
		valueDisplay.AnchorPoint = Vector2.new(1, 0)
		valueDisplay.BackgroundColor3 = Theme.Colors.GlassLight
		valueDisplay.BackgroundTransparency = Theme.Transparency.GlassLight
		valueDisplay.BorderSizePixel = 0
		valueDisplay.Position = UDim2.new(1, 0, 0, 0)
		valueDisplay.Size = UDim2.new(0, 60, 1, 0)
		valueDisplay.Font = Theme.Font.Body
		valueDisplay.Text = "50"
		valueDisplay.TextColor3 = Theme.Colors.TextPrimary
		valueDisplay.TextSize = 12
		valueDisplay.TextXAlignment = Enum.TextXAlignment.Center

		local valueCorner = Instance.new("UICorner")
		valueCorner.CornerRadius = UDim.new(0, Theme.Rounding.Small)
		valueCorner.Parent = valueDisplay

		local valueStroke = Instance.new("UIStroke")
		valueStroke.Color = Theme.Colors.Border
		valueStroke.Transparency = 0.7
		valueStroke.Thickness = 1
		valueStroke.Parent = valueDisplay

		-- Slider track (clickable area)
		sliderTrack.Name = "SliderTrack"
		sliderTrack.Parent = sliderElement
		sliderTrack.BackgroundTransparency = 1
		sliderTrack.BorderSizePixel = 0
		sliderTrack.Position = UDim2.new(0, 0, 0, 25)
		sliderTrack.Size = UDim2.new(1, 0, 0, 20)
		sliderTrack.AutoButtonColor = false
		sliderTrack.Text = ""

		-- Track background
		trackBackground.Name = "TrackBackground"
		trackBackground.Parent = sliderTrack
		trackBackground.AnchorPoint = Vector2.new(0, 0.5)
		trackBackground.BackgroundColor3 = Theme.Colors.GlassDark
		trackBackground.BackgroundTransparency = Theme.Transparency.GlassDark
		trackBackground.BorderSizePixel = 0
		trackBackground.Position = UDim2.new(0, 0, 0.5, 0)
		trackBackground.Size = UDim2.new(1, 0, 0, 6)

		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(0, 3)
		trackCorner.Parent = trackBackground

		local trackStroke = Instance.new("UIStroke")
		trackStroke.Color = Theme.Colors.Border
		trackStroke.Transparency = 0.8
		trackStroke.Thickness = 1
		trackStroke.Parent = trackBackground

		-- Track fill (progress indicator)
		trackFill.Name = "TrackFill"
		trackFill.Parent = trackBackground
		trackFill.BackgroundColor3 = Theme.Colors.Primary
		trackFill.BorderSizePixel = 0
		trackFill.Size = UDim2.new(0.5, 0, 1, 0)

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 3)
		fillCorner.Parent = trackFill

		-- Add gradient to fill
		local fillGradient = Instance.new("UIGradient")
		fillGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Theme.Colors.Primary),
			ColorSequenceKeypoint.new(1, Theme.Colors.Secondary)
		}
		fillGradient.Parent = trackFill

		-- Slider thumb (draggable handle)
		sliderThumb.Name = "SliderThumb"
		sliderThumb.Parent = sliderTrack
		sliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
		sliderThumb.BackgroundColor3 = Theme.Colors.TextPrimary
		sliderThumb.BorderSizePixel = 0
		sliderThumb.Position = UDim2.new(0.5, 0, 0.5, 0)
		sliderThumb.Size = UDim2.new(0, 16, 0, 16)

		local thumbCorner = Instance.new("UICorner")
		thumbCorner.CornerRadius = UDim.new(0.5, 0)
		thumbCorner.Parent = sliderThumb

		local thumbStroke = Instance.new("UIStroke")
		thumbStroke.Color = Theme.Colors.Primary
		thumbStroke.Transparency = 0.5
		thumbStroke.Thickness = 2
		thumbStroke.Parent = sliderThumb

		-- Thumb glow effect
		thumbGlow.Name = "ThumbGlow"
		thumbGlow.Parent = sliderThumb
		thumbGlow.AnchorPoint = Vector2.new(0.5, 0.5)
		thumbGlow.BackgroundColor3 = Theme.Colors.Primary
		thumbGlow.BackgroundTransparency = 1
		thumbGlow.BorderSizePixel = 0
		thumbGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
		thumbGlow.Size = UDim2.new(1.5, 0, 1.5, 0)

		local glowCorner = Instance.new("UICorner")
		glowCorner.CornerRadius = UDim.new(0.5, 0)
		glowCorner.Parent = thumbGlow

		-- Slider functionality
		local minValue = 0
		local maxValue = 100
		local currentValue = 50
		local isDragging = false

		local function updateSlider(value)
			currentValue = math.clamp(value, minValue, maxValue)
			local percentage = (currentValue - minValue) / (maxValue - minValue)

			-- Update visual elements
			valueDisplay.Text = tostring(math.floor(currentValue))

			local fillTween = TweenService:Create(trackFill,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{Size = UDim2.new(percentage, 0, 1, 0)}
			)

			local thumbTween = TweenService:Create(sliderThumb,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{Position = UDim2.new(percentage, 0, 0.5, 0)}
			)

			fillTween:Play()
			thumbTween:Play()
		end

		-- Interaction handling
		local function startDrag()
			isDragging = true
			local glowTween = TweenService:Create(thumbGlow,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{BackgroundTransparency = 0.7, Size = UDim2.new(2, 0, 2, 0)}
			)
			glowTween:Play()
		end

		local function stopDrag()
			isDragging = false
			local glowTween = TweenService:Create(thumbGlow,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{BackgroundTransparency = 1, Size = UDim2.new(1.5, 0, 1.5, 0)}
			)
			glowTween:Play()
		end

		-- Mouse events
		sliderTrack.MouseButton1Down:Connect(function()
			startDrag()
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
				stopDrag()
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local trackPosition = sliderTrack.AbsolutePosition.X
				local trackSize = sliderTrack.AbsoluteSize.X
				local mouseX = input.Position.X
				local percentage = math.clamp((mouseX - trackPosition) / trackSize, 0, 1)
				local newValue = minValue + percentage * (maxValue - minValue)
				updateSlider(newValue)
			end
		end)

		-- Value input handling
		valueDisplay.FocusLost:Connect(function()
			local inputValue = tonumber(valueDisplay.Text)
			if inputValue then
				updateSlider(inputValue)
			else
				valueDisplay.Text = tostring(math.floor(currentValue))
			end
		end)

		-- Initialize slider
		updateSlider(currentValue)

		-- Store references and functions
		sliderElement.SetValue = updateSlider
		sliderElement.GetValue = function() return currentValue end
		sliderElement.SetRange = function(min, max)
			minValue = min
			maxValue = max
			updateSlider(math.clamp(currentValue, minValue, maxValue))
		end
		sliderElement.SliderText = sliderText

		return sliderElement
	end

	local function createSearchBar()
		local searchBar = Instance.new("Frame")
		local searchBarFrame = Instance.new("Frame")
		local buttonBackgroundPadding = Instance.new("Frame")
		local buttonBackgroundPadding_2 = Instance.new("UIPadding")
		local searchBox = Instance.new("TextBox")
		local searchBoxPadding = Instance.new("UIPadding")
		local searchBoxBackground = Instance.new("Frame")
		local searchImage = Instance.new("ImageLabel")
		local searchImageAspect = Instance.new("UIAspectRatioConstraint")
		local searchButtonPadding = Instance.new("UIPadding")
		local elementHolder = Instance.new("ScrollingFrame")
		local elementHolderBackground = Instance.new("Frame")
		local elementHolderInnerBackground = Instance.new("Frame")
		local elementHolderInnerBackgroundList = Instance.new("UIListLayout")
		local elementHolderInnerBackgroundPadding = Instance.new("UIPadding")
		local elementHolderBackgroundPadding = Instance.new("UIPadding")
		local elementHolderPadding = Instance.new("UIPadding")

		searchBar.Name = "SearchBar"
		searchBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		searchBar.BackgroundTransparency = 1.000
		searchBar.BorderSizePixel = 0
		searchBar.ClipsDescendants = true
		searchBar.Size = UDim2.new(1, 0, 0, 18)

		searchBarFrame.Name = "SearchBarFrame"
		searchBarFrame.Parent = searchBar
		searchBarFrame.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		searchBarFrame.BorderSizePixel = 0
		searchBarFrame.Size = UDim2.new(1, 0, 0, 18)

		buttonBackgroundPadding.Name = "ButtonBackgroundPadding"
		buttonBackgroundPadding.Parent = searchBarFrame
		buttonBackgroundPadding.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonBackgroundPadding.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		buttonBackgroundPadding.BorderSizePixel = 0
		buttonBackgroundPadding.Position = UDim2.new(0.5, 0, 0.5, 0)
		buttonBackgroundPadding.Size = UDim2.new(1, 0, 1, 0)

		buttonBackgroundPadding_2.Name = "ButtonBackgroundPadding"
		buttonBackgroundPadding_2.Parent = buttonBackgroundPadding
		buttonBackgroundPadding_2.PaddingBottom = UDim.new(0, 1)
		buttonBackgroundPadding_2.PaddingLeft = UDim.new(0, 1)
		buttonBackgroundPadding_2.PaddingRight = UDim.new(0, 1)
		buttonBackgroundPadding_2.PaddingTop = UDim.new(0, 1)

		searchBox.Name = "SearchBox"
		searchBox.Parent = buttonBackgroundPadding
		searchBox.Active = false
		searchBox.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		searchBox.BackgroundTransparency = 1
		searchBox.BorderSizePixel = 0
		searchBox.Size = UDim2.new(1, 0, 1, 0)
		searchBox.Font = Enum.Font.Gotham
		searchBox.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		searchBox.PlaceholderText = "N/A"
		searchBox.Text = ""
		searchBox.TextColor3 = Color3.fromRGB(139, 141, 147)
		searchBox.TextSize = 14.000
		searchBox.TextXAlignment = Enum.TextXAlignment.Left

		searchBoxPadding.Name = "SearchBoxPadding"
		searchBoxPadding.Parent = searchBox
		searchBoxPadding.PaddingLeft = UDim.new(0, 4)

		searchBoxBackground.Name = "SearchBoxBackground"
		searchBoxBackground.Parent = buttonBackgroundPadding
		searchBoxBackground.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		searchBoxBackground.BorderSizePixel = 0
		searchBoxBackground.Size = UDim2.new(1, 0, 1, 0)
		searchBoxBackground.ZIndex = 0

		searchImage.Name = "SearchImage"
		searchImage.Parent = buttonBackgroundPadding
		searchImage.AnchorPoint = Vector2.new(1, 0.5)
		searchImage.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		searchImage.BackgroundTransparency = 1
		searchImage.BorderSizePixel = 0
		searchImage.Position = UDim2.new(1, 0, 0.5, 0)
		searchImage.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
		searchImage.Image = "rbxassetid://11454041890"

		searchImageAspect.Name = "SearchImageAspect"
		searchImageAspect.Parent = searchImage

		searchButtonPadding.Name = "SearchButtonPadding"
		searchButtonPadding.Parent = searchBarFrame
		searchButtonPadding.PaddingBottom = UDim.new(0, 1)
		searchButtonPadding.PaddingLeft = UDim.new(0, 1)
		searchButtonPadding.PaddingRight = UDim.new(0, 1)
		searchButtonPadding.PaddingTop = UDim.new(0, 1)

		elementHolder.Name = "ElementHolder"
		elementHolder.Parent = searchBar
		elementHolder.Active = true
		elementHolder.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		elementHolder.BorderSizePixel = 0
		elementHolder.Position = UDim2.new(0, 0, 0, 18)
		elementHolder.Size = UDim2.new(0.925000012, 0, 0, 0)
		elementHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
		elementHolder.ScrollBarThickness = 0

		elementHolderBackground.Name = "ElementHolderBackground"
		elementHolderBackground.Parent = elementHolder
		elementHolderBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		elementHolderBackground.BorderSizePixel = 0
		elementHolderBackground.Size = UDim2.new(1, 0, 1, 0)

		elementHolderInnerBackground.Name = "ElementHolderInnerBackground"
		elementHolderInnerBackground.Parent = elementHolderBackground
		elementHolderInnerBackground.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		elementHolderInnerBackground.BorderSizePixel = 0
		elementHolderInnerBackground.Visible = false
		elementHolderInnerBackground.Size = UDim2.new(1, 0, 1, 0)

		elementHolderInnerBackgroundList.Name = "ElementHolderInnerBackgroundList"
		elementHolderInnerBackgroundList.Parent = elementHolderInnerBackground
		elementHolderInnerBackgroundList.SortOrder = Enum.SortOrder.LayoutOrder
		elementHolderInnerBackgroundList.Padding = UDim.new(0, 5)

		elementHolderInnerBackgroundPadding.Name = "ElementHolderInnerBackgroundPadding"
		elementHolderInnerBackgroundPadding.Parent = elementHolderInnerBackground
		elementHolderInnerBackgroundPadding.PaddingBottom = UDim.new(0, 4)
		elementHolderInnerBackgroundPadding.PaddingLeft = UDim.new(0, 5)
		elementHolderInnerBackgroundPadding.PaddingRight = UDim.new(0, 5)
		elementHolderInnerBackgroundPadding.PaddingTop = UDim.new(0, 4)

		elementHolderBackgroundPadding.Name = "ElementHolderBackgroundPadding"
		elementHolderBackgroundPadding.Parent = elementHolderBackground
		elementHolderBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingRight = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingTop = UDim.new(0, 1)

		elementHolderPadding.Name = "ElementHolderPadding"
		elementHolderPadding.Parent = elementHolder
		elementHolderPadding.PaddingBottom = UDim.new(0, 1)
		elementHolderPadding.PaddingLeft = UDim.new(0, 1)
		elementHolderPadding.PaddingRight = UDim.new(0, 1)

		return searchBar
	end

	local function createKeybind()
		local keybind = Instance.new("TextButton")
		local keybindText = Instance.new("TextLabel")
		local boxBackground = Instance.new("Frame")
		local boxAspect = Instance.new("UIAspectRatioConstraint")
		local boxPadding = Instance.new("UIPadding")
		local innerBox = Instance.new("Frame")
		local boxPadding_2 = Instance.new("UIPadding")
		local keyText = Instance.new("TextLabel")

		keybind.Name = "Keybind"
		keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybind.BackgroundTransparency = 1.000
		keybind.BorderSizePixel = 0
		keybind.Size = UDim2.new(1, 0, 0, 18)
		keybind.AutoButtonColor = false
		keybind.Font = Enum.Font.SourceSans
		keybind.Text = ""
		keybind.TextColor3 = Color3.fromRGB(0, 0, 0)
		keybind.TextSize = 14.000

		keybindText.Name = "KeybindText"
		keybindText.Parent = keybind
		keybindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindText.BackgroundTransparency = 1.000
		keybindText.Size = UDim2.new(1, -18, 1, 0)
		keybindText.Font = Enum.Font.Gotham
		keybindText.Text = "N/A"
		keybindText.TextColor3 = Color3.fromRGB(255, 255, 255)
		keybindText.TextSize = 14.000
		keybindText.ClipsDescendants = true
		keybindText.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = keybind
		boxBackground.AnchorPoint = Vector2.new(1, 0)
		boxBackground.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		boxBackground.BorderSizePixel = 0
		boxBackground.Position = UDim2.new(1, 0, 0, 0)
		boxBackground.Size = UDim2.new(1, 0, 1, 0)

		boxAspect.Name = "BoxAspect"
		boxAspect.Parent = boxBackground

		boxPadding.Name = "BoxPadding"
		boxPadding.Parent = boxBackground
		boxPadding.PaddingBottom = UDim.new(0, 1)
		boxPadding.PaddingLeft = UDim.new(0, 1)
		boxPadding.PaddingRight = UDim.new(0, 1)
		boxPadding.PaddingTop = UDim.new(0, 1)

		innerBox.Name = "InnerBox"
		innerBox.Parent = boxBackground
		innerBox.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox.BorderSizePixel = 0
		innerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_2.Name = "BoxPadding"
		boxPadding_2.Parent = innerBox
		boxPadding_2.PaddingBottom = UDim.new(0, 1)
		boxPadding_2.PaddingLeft = UDim.new(0, 1)
		boxPadding_2.PaddingRight = UDim.new(0, 1)
		boxPadding_2.PaddingTop = UDim.new(0, 1)

		keyText.Parent = innerBox
		keyText.Name = "KeyText"
		keyText.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		keyText.BorderSizePixel = 0
		keyText.Size = UDim2.new(1, 0, 1, 0)
		keyText.Font = Enum.Font.Gotham
		keyText.Text = "N/A"
		keyText.TextColor3 = Color3.fromRGB(139, 141, 147)
		keyText.TextSize = 14.000

		return keybind
	end

	local function createTextBox()
		local textBox = Instance.new("TextButton")
		local textBoxNameText = Instance.new("TextLabel")
		local boxBackground = Instance.new("Frame")
		local boxPadding = Instance.new("UIPadding")
		local innerBox = Instance.new("Frame")
		local boxPadding_2 = Instance.new("UIPadding")
		local textBoxText = Instance.new("TextBox")

		textBox.Name = "TextBox"
		textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textBox.BackgroundTransparency = 1.000
		textBox.BorderSizePixel = 0
		textBox.Size = UDim2.new(1, 0, 0, 18)
		textBox.AutoButtonColor = false
		textBox.Font = Enum.Font.SourceSans
		textBox.Text = ""
		textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
		textBox.TextSize = 14.000

		textBoxNameText.Name = "TextBoxNameText"
		textBoxNameText.Parent = textBox
		textBoxNameText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textBoxNameText.BackgroundTransparency = 1.000
		textBoxNameText.Size = UDim2.new(1, -18, 1, 0)
		textBoxNameText.Font = Enum.Font.Gotham
		textBoxNameText.Text = "Textbox"
		textBoxNameText.ClipsDescendants = true
		textBoxNameText.TextColor3 = Color3.fromRGB(255, 255, 255)
		textBoxNameText.TextSize = 14.000
		textBoxNameText.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = textBox
		boxBackground.AnchorPoint = Vector2.new(1, 0)
		boxBackground.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		boxBackground.BorderSizePixel = 0
		boxBackground.Position = UDim2.new(1, 0, 0, 0)
		boxBackground.Size = UDim2.new(0.400000006, 0, 1, 0)

		boxPadding.Name = "BoxPadding"
		boxPadding.Parent = boxBackground
		boxPadding.PaddingBottom = UDim.new(0, 1)
		boxPadding.PaddingLeft = UDim.new(0, 1)
		boxPadding.PaddingRight = UDim.new(0, 1)
		boxPadding.PaddingTop = UDim.new(0, 1)

		innerBox.Name = "InnerBox"
		innerBox.Parent = boxBackground
		innerBox.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox.BorderSizePixel = 0
		innerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_2.Name = "BoxPadding"
		boxPadding_2.Parent = innerBox
		boxPadding_2.PaddingBottom = UDim.new(0, 1)
		boxPadding_2.PaddingLeft = UDim.new(0, 1)
		boxPadding_2.PaddingRight = UDim.new(0, 1)
		boxPadding_2.PaddingTop = UDim.new(0, 1)

		textBoxText.Name = "TextBoxText"
		textBoxText.Parent = innerBox
		textBoxText.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		textBoxText.BorderSizePixel = 0
		textBoxText.ClipsDescendants = true
		textBoxText.Size = UDim2.new(1, 0, 1, 0)
		textBoxText.Font = Enum.Font.Gotham
		textBoxText.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		textBoxText.PlaceholderText = "Type here..."
		textBoxText.Text = ""
		textBoxText.TextXAlignment = Enum.TextXAlignment.Left
		textBoxText.TextColor3 = Color3.fromRGB(139, 141, 147)
		textBoxText.TextSize = 14.000

		return textBox
	end

	local function createColorWheel()
		local colorWheel = Instance.new("Frame")
		local heading = Instance.new("TextButton")
		local colorWheelName = Instance.new("TextLabel")
		local boxBackground = Instance.new("Frame")
		local boxBackgroundPadding = Instance.new("UIPadding")
		local innerBox = Instance.new("Frame")
		local innerBoxPadding = Instance.new("UIPadding")
		local innerBoxCorner = Instance.new("UICorner")
		local centerBox = Instance.new("Frame")
		local centerBoxPadding = Instance.new("UIPadding")
		local centerBoxCorner = Instance.new("UICorner")
		local wheelImage = Instance.new("ImageLabel")
		local wheelImageAspect = Instance.new("UIAspectRatioConstraint")
		local dropdownImage = Instance.new("ImageLabel")
		local dropdownButtonAspect = Instance.new("UIAspectRatioConstraint")
		local boxBackgroundCorner = Instance.new("UICorner")
		local wheelHolder = Instance.new("Frame")
		local valueHolder = Instance.new("Frame")
		local colorInputHolder = Instance.new("Frame")
		local colorInputHolderList = Instance.new("UIListLayout")
		local red = Instance.new("Frame")
		local colorText = Instance.new("TextLabel")
		local boxBackground_2 = Instance.new("Frame")
		local boxPadding = Instance.new("UIPadding")
		local innerBox_2 = Instance.new("Frame")
		local boxPadding_2 = Instance.new("UIPadding")
		local colorValue = Instance.new("TextBox")
		local green = Instance.new("Frame")
		local colorText_2 = Instance.new("TextLabel")
		local boxBackground_3 = Instance.new("Frame")
		local boxPadding_3 = Instance.new("UIPadding")
		local innerBox_3 = Instance.new("Frame")
		local boxPadding_4 = Instance.new("UIPadding")
		local colorValue_2 = Instance.new("TextBox")
		local blue = Instance.new("Frame")
		local colorText_3 = Instance.new("TextLabel")
		local boxBackground_4 = Instance.new("Frame")
		local boxPadding_5 = Instance.new("UIPadding")
		local innerBox_4 = Instance.new("Frame")
		local boxPadding_6 = Instance.new("UIPadding")
		local colorValue_3 = Instance.new("TextBox")
		local colorSample = Instance.new("Frame")
		local colorSampleCorner = Instance.new("UICorner")
		local valueSlider = Instance.new("TextButton")
		local valueSliderCorner = Instance.new("UICorner")
		local valueSliderGradient = Instance.new("UIGradient")
		local sliderBar = Instance.new("Frame")
		local sliderBarCorner = Instance.new("UICorner")
		local wheel = Instance.new("ImageButton")
		local wheelAspect = Instance.new("UIAspectRatioConstraint")
		local selector = Instance.new("ImageLabel")
		local selectorAspect = Instance.new("UIAspectRatioConstraint")

		colorWheel.Name = "ColorWheel"
		colorWheel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorWheel.BackgroundTransparency = 1.000
		colorWheel.BorderSizePixel = 0
		colorWheel.ClipsDescendants = true
		colorWheel.Size = UDim2.new(1, 0, 0, 18)

		heading.Name = "Heading"
		heading.Parent = colorWheel
		heading.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		heading.BackgroundTransparency = 1.000
		heading.BorderSizePixel = 0
		heading.Size = UDim2.new(1, 0, 0, 18)
		heading.Font = Enum.Font.SourceSans
		heading.Text = ""
		heading.TextColor3 = Color3.fromRGB(0, 0, 0)
		heading.TextSize = 14.000

		colorWheelName.Name = "ColorWheelName"
		colorWheelName.Parent = heading
		colorWheelName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorWheelName.BackgroundTransparency = 1.000
		colorWheelName.BorderSizePixel = 0
		colorWheelName.Size = UDim2.new(1, 0, 1, 0)
		colorWheelName.Font = Enum.Font.Gotham
		colorWheelName.Text = "ColorWheel"
		colorWheelName.ClipsDescendants = true
		colorWheelName.TextColor3 = Color3.fromRGB(255, 255, 255)
		colorWheelName.TextSize = 14.000
		colorWheelName.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = heading
		boxBackground.AnchorPoint = Vector2.new(1, 0)
		boxBackground.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		boxBackground.BorderSizePixel = 0
		boxBackground.Position = UDim2.new(1, 0, 0, 0)
		boxBackground.Size = UDim2.new(0.174999997, 0, 1, 0)

		boxBackgroundPadding.Name = "BoxBackgroundPadding"
		boxBackgroundPadding.Parent = boxBackground
		boxBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		boxBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		boxBackgroundPadding.PaddingRight = UDim.new(0, 1)
		boxBackgroundPadding.PaddingTop = UDim.new(0, 1)

		innerBox.Name = "InnerBox"
		innerBox.Parent = boxBackground
		innerBox.AnchorPoint = Vector2.new(1, 0)
		innerBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox.BorderSizePixel = 0
		innerBox.Position = UDim2.new(1, 0, 0, 0)
		innerBox.Size = UDim2.new(1, 0, 1, 0)

		innerBoxPadding.Name = "InnerBoxPadding"
		innerBoxPadding.Parent = innerBox
		innerBoxPadding.PaddingBottom = UDim.new(0, 1)
		innerBoxPadding.PaddingLeft = UDim.new(0, 1)
		innerBoxPadding.PaddingRight = UDim.new(0, 1)
		innerBoxPadding.PaddingTop = UDim.new(0, 1)

		innerBoxCorner.Name = "InnerBoxCorner"
		innerBoxCorner.Parent = innerBox

		centerBox.Name = "CenterBox"
		centerBox.Parent = innerBox
		centerBox.AnchorPoint = Vector2.new(1, 0)
		centerBox.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		centerBox.BorderSizePixel = 0
		centerBox.Position = UDim2.new(1, 0, 0, 0)
		centerBox.Size = UDim2.new(1, 0, 1, 0)

		centerBoxPadding.Name = "CenterBoxPadding"
		centerBoxPadding.Parent = centerBox
		centerBoxPadding.PaddingBottom = UDim.new(0, 1)
		centerBoxPadding.PaddingLeft = UDim.new(0, 3)
		centerBoxPadding.PaddingRight = UDim.new(0, 1)
		centerBoxPadding.PaddingTop = UDim.new(0, 1)

		centerBoxCorner.Name = "CenterBoxCorner"
		centerBoxCorner.Parent = centerBox

		wheelImage.Name = "WheelImage"
		wheelImage.Parent = centerBox
		wheelImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		wheelImage.BackgroundTransparency = 1.000
		wheelImage.Size = UDim2.new(1, 0, 1, 0)
		wheelImage.Image = "rbxassetid://11515288750"

		wheelImageAspect.Name = "WheelImageAspect"
		wheelImageAspect.Parent = wheelImage

		dropdownImage.Name = "DropdownImage"
		dropdownImage.Parent = centerBox
		dropdownImage.AnchorPoint = Vector2.new(1, 0)
		dropdownImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdownImage.BackgroundTransparency = 1.000
		dropdownImage.BorderSizePixel = 0
		dropdownImage.Rotation = 180
		dropdownImage.Position = UDim2.new(1, 0, 0, 0)
		dropdownImage.Size = UDim2.new(1, 0, 1, 0)
		dropdownImage.Image = "rbxassetid://11269835227"

		dropdownButtonAspect.Name = "DropdownButtonAspect"
		dropdownButtonAspect.Parent = dropdownImage

		boxBackgroundCorner.Name = "BoxBackgroundCorner"
		boxBackgroundCorner.Parent = boxBackground

		wheelHolder.Name = "WheelHolder"
		wheelHolder.Parent = colorWheel
		wheelHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		wheelHolder.BackgroundTransparency = 1.000
		wheelHolder.BorderSizePixel = 0
		wheelHolder.Position = UDim2.new(0, 0, 0, 22)
		wheelHolder.Size = UDim2.new(1, 0, 0, 98)

		valueHolder.Name = "ValueHolder"
		valueHolder.Parent = wheelHolder
		valueHolder.AnchorPoint = Vector2.new(1, 0)
		valueHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		valueHolder.BackgroundTransparency = 1.000
		valueHolder.BorderSizePixel = 0
		valueHolder.Position = UDim2.new(1, 0, 0, 0)
		valueHolder.Size = UDim2.new(0.899999976, -102, 1, 0)

		colorInputHolder.Name = "ColorInputHolder"
		colorInputHolder.Parent = valueHolder
		colorInputHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorInputHolder.BackgroundTransparency = 1.000
		colorInputHolder.BorderSizePixel = 0
		colorInputHolder.Size = UDim2.new(1, 0, 1, -36)

		colorInputHolderList.Name = "ColorInputHolderList"
		colorInputHolderList.Parent = colorInputHolder
		colorInputHolderList.SortOrder = Enum.SortOrder.LayoutOrder
		colorInputHolderList.Padding = UDim.new(0, 4)

		red.Name = "Red"
		red.Parent = colorInputHolder
		red.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		red.BackgroundTransparency = 1.000
		red.BorderSizePixel = 0
		red.ClipsDescendants = true
		red.Size = UDim2.new(1, 0, 0, 18)

		colorText.Name = "ColorText"
		colorText.Parent = red
		colorText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorText.BackgroundTransparency = 1.000
		colorText.BorderSizePixel = 0
		colorText.Size = UDim2.new(0.670000017, 0, 1, 0)
		colorText.Font = Enum.Font.Gotham
		colorText.Text = "Red:"
		colorText.TextColor3 = Color3.fromRGB(255, 255, 255)
		colorText.TextSize = 14.000
		colorText.TextXAlignment = Enum.TextXAlignment.Right

		boxBackground_2.Name = "BoxBackground"
		boxBackground_2.Parent = red
		boxBackground_2.AnchorPoint = Vector2.new(1, 0)
		boxBackground_2.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		boxBackground_2.BorderSizePixel = 0
		boxBackground_2.Position = UDim2.new(1, 0, 0, 0)
		boxBackground_2.Size = UDim2.new(0.300000012, 0, 1, 0)

		boxPadding.Name = "BoxPadding"
		boxPadding.Parent = boxBackground_2
		boxPadding.PaddingBottom = UDim.new(0, 1)
		boxPadding.PaddingLeft = UDim.new(0, 1)
		boxPadding.PaddingRight = UDim.new(0, 1)
		boxPadding.PaddingTop = UDim.new(0, 1)

		innerBox_2.Name = "InnerBox"
		innerBox_2.Parent = boxBackground_2
		innerBox_2.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox_2.BorderSizePixel = 0
		innerBox_2.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox_2.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_2.Name = "BoxPadding"
		boxPadding_2.Parent = innerBox_2
		boxPadding_2.PaddingBottom = UDim.new(0, 1)
		boxPadding_2.PaddingLeft = UDim.new(0, 1)
		boxPadding_2.PaddingRight = UDim.new(0, 1)
		boxPadding_2.PaddingTop = UDim.new(0, 1)

		colorValue.Name = "ColorValue"
		colorValue.Parent = innerBox_2
		colorValue.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		colorValue.BorderSizePixel = 0
		colorValue.ClipsDescendants = true
		colorValue.Size = UDim2.new(1, 0, 1, 0)
		colorValue.Font = Enum.Font.Gotham
		colorValue.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		colorValue.Text = "255"
		colorValue.TextColor3 = Color3.fromRGB(139, 141, 147)
		colorValue.TextSize = 14.000

		green.Name = "Green"
		green.Parent = colorInputHolder
		green.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		green.BackgroundTransparency = 1.000
		green.BorderSizePixel = 0
		green.Size = UDim2.new(1, 0, 0, 18)

		colorText_2.Name = "ColorText"
		colorText_2.Parent = green
		colorText_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorText_2.BackgroundTransparency = 1.000
		colorText_2.BorderSizePixel = 0
		colorText_2.Size = UDim2.new(0.699999988, 0, 1, 0)
		colorText_2.Font = Enum.Font.Gotham
		colorText_2.Text = "Green:"
		green.ClipsDescendants = true
		colorText_2.TextColor3 = Color3.fromRGB(255, 255, 255)
		colorText_2.TextSize = 14.000
		colorText_2.TextXAlignment = Enum.TextXAlignment.Right

		boxBackground_3.Name = "BoxBackground"
		boxBackground_3.Parent = green
		boxBackground_3.AnchorPoint = Vector2.new(1, 0)
		boxBackground_3.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		boxBackground_3.BorderSizePixel = 0
		boxBackground_3.Position = UDim2.new(1, 0, 0, 0)
		boxBackground_3.Size = UDim2.new(0.300000012, 0, 1, 0)

		boxPadding_3.Name = "BoxPadding"
		boxPadding_3.Parent = boxBackground_3
		boxPadding_3.PaddingBottom = UDim.new(0, 1)
		boxPadding_3.PaddingLeft = UDim.new(0, 1)
		boxPadding_3.PaddingRight = UDim.new(0, 1)
		boxPadding_3.PaddingTop = UDim.new(0, 1)

		innerBox_3.Name = "InnerBox"
		innerBox_3.Parent = boxBackground_3
		innerBox_3.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox_3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox_3.BorderSizePixel = 0
		innerBox_3.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox_3.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_4.Name = "BoxPadding"
		boxPadding_4.Parent = innerBox_3
		boxPadding_4.PaddingBottom = UDim.new(0, 1)
		boxPadding_4.PaddingLeft = UDim.new(0, 1)
		boxPadding_4.PaddingRight = UDim.new(0, 1)
		boxPadding_4.PaddingTop = UDim.new(0, 1)

		colorValue_2.Name = "ColorValue"
		colorValue_2.Parent = innerBox_3
		colorValue_2.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		colorValue_2.BorderSizePixel = 0
		colorValue_2.ClipsDescendants = true
		colorValue_2.Size = UDim2.new(1, 0, 1, 0)
		colorValue_2.Font = Enum.Font.Gotham
		colorValue_2.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		colorValue_2.Text = "255"
		colorValue_2.TextColor3 = Color3.fromRGB(139, 141, 147)
		colorValue_2.TextSize = 14.000

		blue.Name = "Blue"
		blue.Parent = colorInputHolder
		blue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		blue.BackgroundTransparency = 1.000
		blue.ClipsDescendants = true
		blue.BorderSizePixel = 0
		blue.Size = UDim2.new(1, 0, 0, 18)

		colorText_3.Name = "ColorText"
		colorText_3.Parent = blue
		colorText_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorText_3.BackgroundTransparency = 1.000
		colorText_3.BorderSizePixel = 0
		colorText_3.Size = UDim2.new(0.670000017, 0, 1, 0)
		colorText_3.Font = Enum.Font.Gotham
		colorText_3.Text = "Blue:"
		colorText_3.TextColor3 = Color3.fromRGB(255, 255, 255)
		colorText_3.TextSize = 14.000
		colorText_3.TextXAlignment = Enum.TextXAlignment.Right

		boxBackground_4.Name = "BoxBackground"
		boxBackground_4.Parent = blue
		boxBackground_4.AnchorPoint = Vector2.new(1, 0)
		boxBackground_4.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		boxBackground_4.BorderSizePixel = 0
		boxBackground_4.Position = UDim2.new(1, 0, 0, 0)
		boxBackground_4.Size = UDim2.new(0.300000012, 0, 1, 0)

		boxPadding_5.Name = "BoxPadding"
		boxPadding_5.Parent = boxBackground_4
		boxPadding_5.PaddingBottom = UDim.new(0, 1)
		boxPadding_5.PaddingLeft = UDim.new(0, 1)
		boxPadding_5.PaddingRight = UDim.new(0, 1)
		boxPadding_5.PaddingTop = UDim.new(0, 1)

		innerBox_4.Name = "InnerBox"
		innerBox_4.Parent = boxBackground_4
		innerBox_4.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox_4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox_4.BorderSizePixel = 0
		innerBox_4.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox_4.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_6.Name = "BoxPadding"
		boxPadding_6.Parent = innerBox_4
		boxPadding_6.PaddingBottom = UDim.new(0, 1)
		boxPadding_6.PaddingLeft = UDim.new(0, 1)
		boxPadding_6.PaddingRight = UDim.new(0, 1)
		boxPadding_6.PaddingTop = UDim.new(0, 1)

		colorValue_3.Name = "ColorValue"
		colorValue_3.Parent = innerBox_4
		colorValue_3.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		colorValue_3.BorderSizePixel = 0
		colorValue_3.ClipsDescendants = true
		colorValue_3.Size = UDim2.new(1, 0, 1, 0)
		colorValue_3.Font = Enum.Font.Gotham
		colorValue_3.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		colorValue_3.Text = "255"
		colorValue_3.TextColor3 = Color3.fromRGB(139, 141, 147)
		colorValue_3.TextSize = 14.000

		colorSample.Name = "ColorSample"
		colorSample.Parent = valueHolder
		colorSample.AnchorPoint = Vector2.new(0, 1)
		colorSample.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorSample.BorderSizePixel = 0
		colorSample.Position = UDim2.new(0, 0, 1, -18)
		colorSample.Size = UDim2.new(1, 0, 0, 14)

		colorSampleCorner.CornerRadius = UDim.new(0.25, 0)
		colorSampleCorner.Name = "ColorSampleCorner"
		colorSampleCorner.Parent = colorSample

		valueSlider.Name = "ValueSlider"
		valueSlider.Parent = valueHolder
		valueSlider.AnchorPoint = Vector2.new(0, 1)
		valueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		valueSlider.BorderSizePixel = 0
		valueSlider.Position = UDim2.new(0, 0, 1, 0)
		valueSlider.Size = UDim2.new(1, 0, 0, 14)
		valueSlider.AutoButtonColor = false
		valueSlider.Font = Enum.Font.SourceSans
		valueSlider.Text = ""
		valueSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
		valueSlider.TextSize = 14.000

		valueSliderCorner.CornerRadius = UDim.new(0.25, 0)
		valueSliderCorner.Name = "ValueSliderCorner"
		valueSliderCorner.Parent = valueSlider

		valueSliderGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
		valueSliderGradient.Name = "ValueSliderGradient"
		valueSliderGradient.Parent = valueSlider

		sliderBar.Name = "SliderBar"
		sliderBar.Parent = valueSlider
		sliderBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		sliderBar.BorderSizePixel = 0
		sliderBar.Size = UDim2.new(0, 3, 1, 0)

		sliderBarCorner.CornerRadius = UDim.new(0.25, 0)
		sliderBarCorner.Name = "SliderBarCorner"
		sliderBarCorner.Parent = sliderBar

		wheel.Name = "Wheel"
		wheel.Parent = wheelHolder
		wheel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		wheel.BackgroundTransparency = 1.000
		wheel.BorderSizePixel = 0
		wheel.Size = UDim2.new(1, 0, 1, 0)
		wheel.AutoButtonColor = false
		wheel.Image = "rbxassetid://11515288750"

		wheelAspect.Name = "WheelAspect"
		wheelAspect.Parent = wheel

		selector.Name = "Selector"
		selector.Parent = wheel
		selector.AnchorPoint = Vector2.new(0.5, 0.5)
		selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		selector.BackgroundTransparency = 1.000
		selector.BorderSizePixel = 0
		selector.Position = UDim2.new(0.5, 0, 0.5, 0)
		selector.Size = UDim2.new(0.125, 0, 0.125, 0)
		selector.Image = "rbxassetid://11515686713"

		selectorAspect.Name = "SelectorAspect"
		selectorAspect.Parent = selector

		return colorWheel
	end

	originalElements.Window = createWindow()
	originalElements.Tab = createTab()
	originalElements.Page = createPage()
	originalElements.Section = createSection()
	originalElements.Title = createTitle()
	originalElements.Label = createLabel()
	originalElements.Toggle = createToggle()
	originalElements.Button = createButton()
	originalElements.Dropdown = createDropdown()
	originalElements.Slider = createSlider()
	originalElements.SearchBar = createSearchBar()
	originalElements.Keybind = createKeybind()
	originalElements.TextBox = createTextBox()
	originalElements.ColorWheel = createColorWheel()
end

function elementHandler:Remove()
	self.GuiToRemove:Destroy()
end

-- Modern Library Implementation
function Library.new(windowName: string, options: table?): table
	options = options or {}
	local constrainToScreen = options.constrainToScreen ~= false
	local enableBlur = options.enableBlur ~= false
	local theme = options.theme or "Modern"

	-- Create modern window with responsive design
	local window = setmetatable({}, windowHandler)
	local windowInstance = createWindow()

	-- Apply modern styling and responsive behavior
	local isMobile = DesignSystem.CreateResponsiveLayout(modernElements.windowContainer)

	-- Window dragging functionality
	local startDragMousePos
	local startDragWindowPos
	local isDragging = false

	-- Get drag handle from modern window
	local dragHandle = windowInstance:FindFirstChild("Background"):FindFirstChild("WindowContainer"):FindFirstChild("TitleBar"):FindFirstChild("DragHandle")

	-- Modern drag implementation
	dragHandle.MouseButton1Down:Connect(function()
		isDragging = true
		startDragMousePos = UserInputService:GetMouseLocation()
		startDragWindowPos = modernElements.windowContainer.Position

		-- Add dragging visual feedback
		local dragTween = TweenService:Create(modernElements.windowContainer,
			TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
			{Size = UDim2.new(modernElements.windowContainer.Size.X.Scale * 1.02, 0, modernElements.windowContainer.Size.Y.Scale * 1.02, 0)}
		)
		dragTween:Play()
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local currentMousePos = UserInputService:GetMouseLocation()
			local deltaX = currentMousePos.X - startDragMousePos.X
			local deltaY = currentMousePos.Y - startDragMousePos.Y

			local newPosition = UDim2.new(
				startDragWindowPos.X.Scale,
				startDragWindowPos.X.Offset + deltaX,
				startDragWindowPos.Y.Scale,
				startDragWindowPos.Y.Offset + deltaY
			)

			if constrainToScreen then
				local viewportSize = workspace.CurrentCamera.ViewportSize
				local windowSize = modernElements.windowContainer.AbsoluteSize

				newPosition = UDim2.new(
					newPosition.X.Scale,
					math.clamp(newPosition.X.Offset, 0, viewportSize.X - windowSize.X),
					newPosition.Y.Scale,
					math.clamp(newPosition.Y.Offset, 0, viewportSize.Y - windowSize.Y)
				)
			end

			modernElements.windowContainer.Position = newPosition
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
			isDragging = false

			-- Reset dragging visual feedback
			local resetTween = TweenService:Create(modernElements.windowContainer,
				TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EaseOut),
				{Size = UDim2.new(modernElements.windowContainer.Size.X.Scale / 1.02, 0, modernElements.windowContainer.Size.Y.Scale / 1.02, 0)}
			)
			resetTween:Play()
		end
	end)

	-- Window controls functionality
	local minimizeBtn = windowInstance:FindFirstChild("Background"):FindFirstChild("WindowContainer"):FindFirstChild("TitleBar"):FindFirstChild("WindowControls"):FindFirstChild("Minimize")
	local maximizeBtn = windowInstance:FindFirstChild("Background"):FindFirstChild("WindowContainer"):FindFirstChild("TitleBar"):FindFirstChild("WindowControls"):FindFirstChild("Maximize")
	local closeBtn = windowInstance:FindFirstChild("Background"):FindFirstChild("WindowContainer"):FindFirstChild("TitleBar"):FindFirstChild("WindowControls"):FindFirstChild("Close")

	local isMaximized = false
	local originalSize = modernElements.windowContainer.Size
	local originalPosition = modernElements.windowContainer.Position

	minimizeBtn.MouseButton1Click:Connect(function()
		local minimizeTween = TweenService:Create(modernElements.windowContainer,
			TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
			{Size = UDim2.new(0.3, 0, 0, 40), Position = UDim2.new(0.1, 0, 0.9, 0)}
		)
		minimizeTween:Play()
	end)

	maximizeBtn.MouseButton1Click:Connect(function()
		if isMaximized then
			-- Restore
			local restoreTween = TweenService:Create(modernElements.windowContainer,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{Size = originalSize, Position = originalPosition}
			)
			restoreTween:Play()
			isMaximized = false
		else
			-- Maximize
			local maximizeTween = TweenService:Create(modernElements.windowContainer,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
				{Size = UDim2.new(0.95, 0, 0.9, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}
			)
			maximizeTween:Play()
			isMaximized = true
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		local closeTween = TweenService:Create(modernElements.windowContainer,
			TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EaseOut),
			{Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}
		)
		closeTween:Play()

		closeTween.Completed:Connect(function()
			windowInstance:Destroy()
		end)
	end)

	-- Set window title
	local titleLabel = windowInstance:FindFirstChild("Background"):FindFirstChild("WindowContainer"):FindFirstChild("TitleBar"):FindFirstChild("TitleLabel")
	titleLabel.Text = windowName or "Modern GUI"

	-- Store window references
	window.WindowInstance = windowInstance
	window.Container = modernElements.windowContainer
	window.Sidebar = modernElements.sidebar
	window.MainContent = modernElements.mainContent
	window.PagesFolder = modernElements.pagesFolder
	window.IsMobile = isMobile

	-- Modern window methods
	window.SetTitle = function(title)
		titleLabel.Text = title
	end

	window.SetVisible = function(visible)
		windowInstance.Enabled = visible
	end

	window.Destroy = function()
		windowInstance:Destroy()
	end

	return window
end

-- Modern Tab Creation Function
function Library.CreateTab(window, tabName, iconId)
	local tab = createTab()
	tab.TabText.Text = tabName or "New Tab"

	if iconId then
		tab.TabIcon.Image = iconId
	end

	tab.Parent = window.Sidebar

	-- Create corresponding page
	local page = createPage()
	page.Name = tabName or "NewTab"
	page.Parent = window.PagesFolder

	-- Tab switching functionality
	tab.MouseButton1Click:Connect(function()
		-- Hide all other pages
		for _, child in pairs(window.PagesFolder:GetChildren()) do
			if child:IsA("Frame") then
				child.Visible = false
			end
		end

		-- Show this page
		page.Visible = true

		-- Update all tab states
		for _, sibling in pairs(window.Sidebar:GetChildren()) do
			if sibling:IsA("TextButton") and sibling.AnimateActive then
				sibling.AnimateActive(sibling == tab)
			end
		end
	end)

	-- Store references
	tab.Page = page
	tab.Window = window

	return {
		Tab = tab,
		Page = page,
		AddSection = function(sectionName)
			return Library.CreateSection(page, sectionName)
		end
	}
end

-- Modern Section Creation
function Library.CreateSection(page, sectionName)
	local section = createSection()
	section.Heading.Title.Text = sectionName or "Section"

	-- Determine which column to add to (left or right)
	local leftColumn = page.LeftScrollingFrame
	local rightColumn = page.RightScrollingFrame

	-- Add to column with less content
	local leftHeight = leftColumn.UIListLayout.AbsoluteContentSize.Y
	local rightHeight = rightColumn.UIListLayout.AbsoluteContentSize.Y

	if leftHeight <= rightHeight then
		section.Parent = leftColumn
	else
		section.Parent = rightColumn
	end

	return {
		Section = section,
		AddToggle = function(name, callback)
			return Library.CreateToggle(section, name, callback)
		end,
		AddButton = function(name, callback)
			return Library.CreateButton(section, name, callback)
		end,
		AddSlider = function(name, min, max, default, callback)
			return Library.CreateSlider(section, name, min, max, default, callback)
		end,
		AddDropdown = function(name, options, callback)
			return Library.CreateDropdown(section, name, options, callback)
		end
	}
end

-- Modern Component Creation Functions
function Library.CreateToggle(section, name, callback)
	local toggle = createToggle()
	toggle.ToggleText.Text = name or "Toggle"
	toggle.Parent = section.ElementHolder

	toggle.MouseButton1Click:Connect(function()
		if callback then
			callback(toggle.IsToggled())
		end
	end)

	return toggle
end

function Library.CreateButton(section, name, callback)
	local button = createButton()
	button.ButtonText.Text = name or "Button"
	button.Parent = section.ElementHolder

	button.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)

	return button
end

function Library.CreateSlider(section, name, min, max, default, callback)
	local slider = createSlider()
	slider.SliderText.Text = name or "Slider"
	slider.SetRange(min or 0, max or 100)
	slider.SetValue(default or 50)
	slider.Parent = section.ElementHolder

	-- Connect value change callback
	local lastValue = slider.GetValue()
	game:GetService("RunService").Heartbeat:Connect(function()
		local currentValue = slider.GetValue()
		if currentValue ~= lastValue then
			lastValue = currentValue
			if callback then
				callback(currentValue)
			end
		end
	end)

	return slider
end

function Library.CreateDropdown(section, name, options, callback)
	local dropdown = createDropdown()
	dropdown.DropdownText.Text = name or "Dropdown"
	dropdown.Parent = section.ElementHolder

	-- Add options
	for _, option in pairs(options or {}) do
		if type(option) == "string" then
			dropdown.AddOption(option, option)
		elseif type(option) == "table" then
			dropdown.AddOption(option.text or option.name, option.value)
		end
	end

	-- Connect selection callback
	local lastSelected = dropdown.GetSelected()
	game:GetService("RunService").Heartbeat:Connect(function()
		local currentSelected = dropdown.GetSelected()
		if currentSelected ~= lastSelected then
			lastSelected = currentSelected
			if callback then
				callback(currentSelected)
			end
		end
	end)

	return dropdown
end

--[[
    Xyros Modern GUI - Documentation & Example

    This document provides a comprehensive guide on how to use the modernized Xyros GUI library.
    The new design is built with a frosted glass aesthetic, smooth animations, and a responsive layout system.

    -------------------------------------------------
    -- 1. Creating a Window
    -------------------------------------------------
    To create a new GUI window, use the `Library.new()` function.

    `local window = Library.new(windowName, options)`

    - `windowName` (string): The title of the window.
    - `options` (table, optional): A table of options to customize the window.
        - `constrainToScreen` (boolean, default: true): Restricts window dragging to screen bounds.
        - `enableBlur` (boolean, default: true): Enables the background blur effect.

    Example:
    `local MyWindow = Library.new("My Modern GUI")`

    -------------------------------------------------
    -- 2. Creating Tabs
    -------------------------------------------------
    Tabs are created within a window and are displayed in the sidebar.

    `local myTab = Library.CreateTab(window, tabName, iconId)`

    - `window` (table): The window object returned by `Library.new()`.
    - `tabName` (string): The name of the tab.
    - `iconId` (string, optional): The Roblox asset ID for the tab icon.

    The function returns a table containing the `Tab` and `Page` objects, and an `AddSection` method.

    Example:
    `local MainTab = Library.CreateTab(MyWindow, "Main", "rbxassetid://123456789")`

    -------------------------------------------------
    -- 3. Creating Sections
    -------------------------------------------------
    Sections are containers for UI elements within a tab's page. They are automatically arranged in columns.

    `local mySection = MainTab.AddSection(sectionName)`

    - `sectionName` (string): The title of the section.

    The function returns a table containing the `Section` object and methods to add UI components.

    Example:
    `local PlayerSection = MainTab.AddSection("Player Settings")`

    -------------------------------------------------
    -- 4. Adding UI Components
    -------------------------------------------------
    All components are added to a section.

    -- Toggle
    `PlayerSection.AddToggle(name, callback)`
    - `name` (string): The label for the toggle.
    - `callback` (function): A function that is called when the toggle state changes. It receives the new state (boolean) as an argument.

    -- Button
    `PlayerSection.AddButton(name, callback)`
    - `name` (string): The text on the button.
    - `callback` (function): A function that is called when the button is clicked.

    -- Slider
    `PlayerSection.AddSlider(name, min, max, default, callback)`
    - `name` (string): The label for the slider.
    - `min` (number): The minimum value of the slider.
    - `max` (number): The maximum value of the slider.
    - `default` (number): The initial value of the slider.
    - `callback` (function): A function that is called when the slider value changes. It receives the new value as an argument.

    -- Dropdown
    `PlayerSection.AddDropdown(name, options, callback)`
    - `name` (string): The label for the dropdown.
    - `options` (table): A table of options for the dropdown. Each option can be a string or a table `{text = "Display Text", value = "SomeValue"}`.
    - `callback` (function): A function that is called when a new option is selected. It receives the selected value as an argument.

    -------------------------------------------------
    -- Example Usage
    -------------------------------------------------
]]

-- Example Implementation
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

return Library
	local window = setmetatable({}, windowHandler) -- remove elementhandler from window hanlers index?
	local windowInstance = originalElements.Window:Clone()
	local startDragMousePos
	local startDragWindowPos
	local originialWindowSize
	local minimizedLongBarOriginialSize
	local minimizedShortBarOriginialSize

	local background = windowInstance.Background
	local heading = background.Heading
	local buttonHolder = heading.ButtonHolder
	local holder = background.Holder

	local function updateWindowPos()
		local deltaPos = Vector2.new(mouse.X, mouse.Y) - startDragMousePos
		local windowPos = background.Position

		if window.isConstraintedToScreenBoundaries then
			local backgroundAbsPos = background.AbsolutePosition
			local backgroundAbsSize = background.AbsoluteSize

			background.Position = UDim2.new(0,math.clamp(startDragWindowPos.X + deltaPos.X, 0 + backgroundAbsSize.X / 2, viewPortSize.X - backgroundAbsSize.X / 2), windowPos.Y.Scale, math.clamp(startDragWindowPos.Y + deltaPos.Y, 0 + backgroundAbsSize.Y / 2,viewPortSize.Y - backgroundAbsSize.Y / 2))
		else
			background.Position = UDim2.new(0, startDragWindowPos.X + deltaPos.X, 0, startDragWindowPos.Y + deltaPos.Y)
		end
	end

	local function onHeadingMouseDown()
		local mouseMovedConnection = mouse.Move:Connect(updateWindowPos)
		local inputEndedConnection

		startDragMousePos = Vector2.new(mouse.X, mouse.Y)
		startDragWindowPos = Vector2.new(background.Position.X.Offset, background.Position.Y.Offset)
		updateWindowPos()

		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				mouseMovedConnection:Disconnect()
				inputEndedConnection:Disconnect()
			end
		end)
	end

	local function closeWindow()
        local closeWindowTween = TweenService:Create(windowInstance.Background, TweenInfo.new(.15, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        closeWindowTween.Completed:Connect(function()
            task.wait()
			windowInstance:Destroy() -- add cool tween cause cool
            window = nil
        end)
        closeWindowTween:Play()
	end

	local function minimizeWindow()
		window.IsMinimized = true
		local backgroundAbsPos = background.AbsolutePosition
		local backgroundAbsSize = background.AbsoluteSize
		local minimizeWindowUpTween = TweenService:Create(background, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0,minimizedLongBarOriginialSize.X,0, minimizedLongBarOriginialSize.Y), Position = UDim2.new(0,backgroundAbsPos.X + minimizedLongBarOriginialSize.X / 2,0, backgroundAbsPos.Y + minimizedLongBarOriginialSize.Y / 2 + 36)})
		local minimizeMinusImageTween = TweenService:Create(buttonHolder.Minus, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Rotation = 180, ImageTransparency = 1})
		local minimizePlusImageTween = TweenService:Create(buttonHolder.Plus, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Rotation = 0, ImageTransparency = 0})

		minimizeWindowUpTween.Completed:Connect(function()
			task.wait(.1)
			if minimizeWindowUpTween.PlaybackState == Enum.PlaybackState.Completed then
				local minimizeWindowLeftTween = TweenService:Create(background, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0, minimizedShortBarOriginialSize.X,0,minimizedShortBarOriginialSize.Y), Position = UDim2.new(0,background.AbsolutePosition.X + minimizedShortBarOriginialSize.X / 2,0, background.AbsolutePosition.Y + minimizedShortBarOriginialSize.Y / 2 + 36)})
				minimizeWindowLeftTween:Play()
			end
		end)

		minimizeMinusImageTween.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed then
				buttonHolder.Minus.Visible = false
				buttonHolder.Plus.Visible = true
				minimizePlusImageTween:Play()
			end
		end)

		minimizeWindowUpTween:Play()
		minimizeMinusImageTween:Play()
	end

	local function maximizeWindow()
		window.IsMinimized = false
		local backgroundAbsPos = background.AbsolutePosition
		local backgroundAbsSize = background.AbsoluteSize
		local maximizeWindowRightTween = TweenService:Create(background, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0,minimizedLongBarOriginialSize.X,0,minimizedLongBarOriginialSize.Y), Position = UDim2.new(0, backgroundAbsPos.X + minimizedLongBarOriginialSize.X / 2,0,backgroundAbsPos.Y + minimizedLongBarOriginialSize.Y / 2 + 36)})
		local maximizePlusImageTween = TweenService:Create(buttonHolder.Plus, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Rotation = 180, ImageTransparency = 1})
		local maximizeMinusImageTween = TweenService:Create(buttonHolder.Minus, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Rotation = 0, ImageTransparency = 0})

		maximizeWindowRightTween.Completed:Connect(function()
			task.wait(.1)
			if maximizeWindowRightTween.PlaybackState == Enum.PlaybackState.Completed then
				local maximizeWindowDownTween = TweenService:Create(background, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0, originialWindowSize.X, 0, originialWindowSize.Y), Position = UDim2.new(0,backgroundAbsPos.X + originialWindowSize.X / 2,0,backgroundAbsPos.Y + originialWindowSize.Y / 2 + 36)})
				buttonHolder.Plus.Visible = false
				buttonHolder.Minus.Visible = true
				maximizeWindowDownTween:Play()
				maximizeMinusImageTween:Play()
			end
		end)

		maximizeWindowRightTween:Play()
		maximizePlusImageTween:Play()
	end

	if constrainToScreen == nil then
		constrainToScreen = true
	end

	window.Type = "Window"
	window.Instance = windowInstance
	window.GuiToRemove = windowInstance
	window.isConstraintedToScreenBoundaries = constrainToScreen
	window.IsMinimized = false
	window.IsHidden = false
	window.TabInfo = {}

	heading.MouseButton1Down:Connect(onHeadingMouseDown)
	buttonHolder.Close.MouseButton1Click:Connect(closeWindow)
	buttonHolder.Plus.MouseButton1Click:Connect(maximizeWindow)
	buttonHolder.Minus.MouseButton1Click:Connect(minimizeWindow)

	holder.Tabs.TabsUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		holder.Tabs.CanvasSize = UDim2.fromOffset(0,holder.Tabs.TabsUIListLayout.AbsoluteContentSize.Y + holder.Tabs.TabsUIListLayout.Padding.Offset)
	end)

	heading.Title.Text = windowName or "Cerberus"
	windowInstance.Parent = game:GetService("CoreGui") -- Change to core later on and add detection bypass
	background.Size = UDim2.new(0,background.AbsoluteSize.X,0,background.AbsoluteSize.Y)
	background.Position = UDim2.new(0, background.AbsolutePosition.X + background.AbsoluteSize.X / 2, 0, background.AbsolutePosition.Y + background.AbsoluteSize.Y / 2 + 36)
	background.BackgroundUIAspectRatioConstraint:Destroy()
	holder.Size = UDim2.new(0,holder.AbsoluteSize.X,0,holder.AbsoluteSize.Y)
	holder.Position = UDim2.new(0,0,0,heading.AbsoluteSize.Y)
	heading.Size = UDim2.new(1,0,0,heading.AbsoluteSize.Y)
	buttonHolder.Size = UDim2.new(0,buttonHolder.ButtonHolderList.AbsoluteContentSize.X + buttonHolder.ButtonHolderPadding.PaddingRight.Offset,.9,0)
	heading.Title.Size = UDim2.new(1,-(buttonHolder.ButtonHolderList.AbsoluteContentSize.X + buttonHolder.ButtonHolderPadding.PaddingRight.Offset + 4),.9,0)
	minimizedLongBarOriginialSize = Vector2.new(heading.AbsoluteSize.X, heading.AbsoluteSize.Y)
	minimizedShortBarOriginialSize = Vector2.new(heading.AbsoluteSize.X / 6 * 2, heading.AbsoluteSize.Y)
	originialWindowSize = background.AbsoluteSize

	return window
end

function windowHandler:LockScreenBoundaries(constrainWindowToScreenBoundaries)
	self.isConstraintedToScreenBoundaries = constrainWindowToScreenBoundaries
end

function windowHandler:Tab(tabName: string, tabImage: string): table
	local tab = setmetatable({}, tabHandler)
	local tabInstance = originalElements.Tab:Clone()
	local pageInstance = originalElements.Page:Clone()

	local tabOpenTween = TweenService:Create(tabInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {BackgroundTransparency = .25})
	local tabCloseTween = TweenService:Create(tabInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 1})
	local tabSeperatorOpenTween = TweenService:Create(tabInstance.TabSeperator, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(.035,1)})
	local tabSeperatorCloseTween = TweenService:Create(tabInstance.TabSeperator, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,1)})
	local pageOpenTween = TweenService:Create(pageInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0.774999976, -25, 1, -15)})
	local pageCloseTween = TweenService:Create(pageInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(.775,-25,0,0)})
	local logoShowTween = TweenService:Create(self.Instance.Background.Holder.PageLogo, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = .65})
	local logoHideTween = TweenService:Create(self.Instance.Background.Holder.PageLogo, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 1})

	local function isTabFirstTab()
		local amountOfTabs = 0
		for _, foundTab in ipairs(self.Instance.Background.Holder.Tabs:GetChildren()) do
			if foundTab:IsA("TextButton") then
				amountOfTabs += 1
			end
		end

		if amountOfTabs == 1 then
			return true
		end

		return false
	end

	local function onMouseEnter()
		if not pageInstance.Visible then
			tabOpenTween:Play()
		end
	end

	local function onMouseLeave()
		if not pageInstance.Visible then
			tabCloseTween:Play()
		end
	end

	local function onMouseClick()
		local selfInfo = self.TabInfo[tabInstance]

		local function openTab()
			local isATabOpen = false

			for foundTabInstance, tabInfo in pairs(self.TabInfo) do
				if foundTabInstance ~= tabInstance then
					if tabInfo.isOpen then
						local foundPageCloseTween = TweenService:Create(tabInfo.Page, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(.775,-25,0,0)})
						local foundTabCloseTween = TweenService:Create(foundTabInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 1})
						local foundTabSeperatorCloseTween = TweenService:Create(foundTabInstance.TabSeperator, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,1)})

						isATabOpen = true
						tabInfo.isOpen = false

						foundPageCloseTween.Completed:Connect(function()
							task.wait(.15)
							if selfInfo.isQueued and foundPageCloseTween.PlaybackState == Enum.PlaybackState.Completed then
								selfInfo.isOpen = true
								pageInstance.Visible = true
								tabInfo.Page.Visible = false
								tabOpenTween:Play()
								tabSeperatorOpenTween:Play()
								pageOpenTween:Play()
							end
						end)

						pageOpenTween.Completed:Connect(function()
							if pageOpenTween.PlaybackState == Enum.PlaybackState.Completed then
								logoHideTween:Play()
							end
						end)

						selfInfo.isQueued = true
						foundPageCloseTween:Play()
						foundTabCloseTween:Play()
						foundTabSeperatorCloseTween:Play()
						logoShowTween:Play()
					elseif tabInfo.isQueued then
						tabInfo.isQueued = false
					end
				end
			end

			if not isATabOpen then
				selfInfo.isOpen = true
				pageInstance.Visible = true
				pageOpenTween:Play()
				tabOpenTween:Play()
				tabSeperatorOpenTween:Play()
				logoHideTween:Play()
			end
		end

		local function closeTab()
			selfInfo.isOpen = false
			tabCloseTween:Play()
			tabSeperatorCloseTween:Play()
			pageCloseTween:Play()
			logoShowTween:Play()
		end

		if selfInfo.isOpen then
			closeTab()
		else
			openTab()
		end
	end

	tab.Type = "Tab"
	tab.IdentifierText = tabName or "N/A"
	tab.TabToRemove = tabInstance
	tab.PageToRemove = pageInstance
	tab.ElementToParentChildren = pageInstance

	tabInstance.TabText.Text = tabName or "N/A"
	tabInstance.TabImage.Image = tabImage or "rbxassetid://11436779516" -- Add n/a found image here later on

	tabInstance.MouseEnter:Connect(onMouseEnter)
	tabInstance.MouseLeave:Connect(onMouseLeave)
	tabInstance.MouseButton1Click:Connect(onMouseClick)

	self.TabInfo[tabInstance] = {Page = pageInstance, isOpen = false, isQueued = false}
	tabInstance.Parent = self.Instance.Background.Holder.Tabs
	tabInstance.TabText.Position = UDim2.new(0.035, 8 + tabInstance.TabImage.AbsoluteSize.X, 0, 0)
	tabInstance.TabText.Size = UDim2.new(0.965, -(8 + tabInstance.TabImage.AbsoluteSize.X + 8), 1, 0)
	pageInstance.Parent = self.Instance.Background.Holder

	if isTabFirstTab() then
		tabInstance.TabSeperator.Size = UDim2.fromScale(.035,1)
		tabInstance.BackgroundTransparency = .25
		pageInstance.Visible = true
		pageInstance.Size = UDim2.new(0.774999976, -25, 1, -15)
		self.TabInfo[tabInstance].isOpen = true
	end

	pageCloseTween.Completed:Connect(function()
		if pageCloseTween.PlaybackState == Enum.PlaybackState.Completed then
			pageInstance.Visible = false
		end
	end)

	for _, scrollingFrame in ipairs(pageInstance:GetChildren()) do
		local list = scrollingFrame:FindFirstChildWhichIsA("UIListLayout")
		list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scrollingFrame.CanvasSize = UDim2.fromOffset(0,list.AbsoluteContentSize.Y + list.Padding.Offset)
		end)
	end

	return tab
end

function tabHandler:Remove()
	self.TabToRemove:Destroy()
	self.PageToRemove:Destroy()
end

function tabHandler:Section(sectionTitle: string) -- Add option to make on left or right after
	local section = setmetatable({}, sectionHandler)
	local sectionInstance = originalElements.Section:Clone()
	local isMaximized = true
	local resizeButtonMinimizeTween = TweenService:Create(sectionInstance.Heading.ResizeButton, TweenInfo.new(.15, Enum.EasingStyle.Linear), {Rotation = 180})
	local resizeButtonMaximizeTween = TweenService:Create(sectionInstance.Heading.ResizeButton, TweenInfo.new(.15, Enum.EasingStyle.Linear), {Rotation = 0})
	local sectionInstanceMinimizeTween = TweenService:Create(sectionInstance, TweenInfo.new(.15, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,sectionInstance.Heading.Size.Y.Offset)})

	local function getSectionNeededYOffsetSize()
		local minimumSize = 200
		return math.max(minimumSize, sectionInstance.Heading.Size.Y.Offset + sectionInstance.ElementHolder.ElementHolderList.AbsoluteContentSize.Y + sectionInstance.ElementHolder.ElementHolderPadding.PaddingBottom.Offset + sectionInstance.ElementHolder.ElementHolderPadding.PaddingTop.Offset)
	end

	local function getShorterScrollingFrame()
		local pageScrollingFrame
		local pageScrollingFrameContentSizeY = math.huge

		for _, scrollingFrame in ipairs(self.ElementToParentChildren:GetChildren()) do
			local list = scrollingFrame:FindFirstChildWhichIsA("UIListLayout")
			if pageScrollingFrameContentSizeY > list.AbsoluteContentSize.Y then
				pageScrollingFrame = scrollingFrame
				pageScrollingFrameContentSizeY = list.AbsoluteContentSize.Y
			end
		end

		return pageScrollingFrame
	end

	local function onResizeClick()
		if isMaximized then
			isMaximized = false
			resizeButtonMinimizeTween:Play()
			sectionInstanceMinimizeTween:Play()
		else
			isMaximized = true
			local sectionInstanceMaximizeTween = TweenService:Create(sectionInstance, TweenInfo.new(.15, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,getSectionNeededYOffsetSize())})
			resizeButtonMaximizeTween:Play()
			sectionInstanceMaximizeTween:Play()
			sectionInstanceMaximizeTween:Play()
		end
	end

	section.Type = "Section"
	section.IdentiferText = sectionTitle or "N/A"
	section.Instance = sectionInstance
	section.GuiToRemove = sectionInstance
	section.ElementToParentChildren = sectionInstance.ElementHolder

	sectionInstance.Heading.ResizeButton.MouseButton1Click:Connect(onResizeClick)

	sectionInstance.ElementHolder.ElementHolderList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		sectionInstance.Size = UDim2.new(1, 0, 0, getSectionNeededYOffsetSize())
		sectionInstance.ElementHolder.Size = UDim2.new(1,0,0, math.max(200 - sectionInstance.Heading.Size.Y.Offset, sectionInstance.ElementHolder.ElementHolderList.AbsoluteContentSize.Y + sectionInstance.ElementHolder.ElementHolderPadding.PaddingBottom.Offset + sectionInstance.ElementHolder.ElementHolderPadding.PaddingTop.Offset))
	end)

	sectionInstance.Heading.Title.Text = sectionTitle or "N/A"
	sectionInstance.Parent = getShorterScrollingFrame()
	sectionInstance.Heading.Title.Size = UDim2.new(1,-(sectionInstance.Heading.ResizeButton.AbsoluteSize.X + 5 + 3),0,20)

	return section
end

function elementHandler:Title(titleName: string)
	local title = setmetatable({}, titleHandler)
	local titleInstance = originalElements.Title:Clone()

	local textSpaceOffset = Vector2.new(10,0)
	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = titleName or "N/A"
	textParams.Font = titleInstance.TitleText.FontFace
	textParams.Size = 14
	textParams.Width = 10000

	local requiredTextSpace = TextService:GetTextBoundsAsync(textParams) + textSpaceOffset

	title.Type = "Title"
	title.IdentifierText = titleName or "N/A"
	title.Instance = titleInstance
	title.GuiToRemove = titleInstance

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[titleInstance] = title
	end

	titleInstance.TitleText.Text = titleName or "N/A"
	titleInstance.TitleText.Size = UDim2.new(0, requiredTextSpace.X, 1, 0)

	titleInstance.Parent = self.ElementToParentChildren

	return title
end

function titleHandler:ChangeText(newText: string): nil
	local textSpaceOffset = Vector2.new(10,0)
	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = newText or "N/A"
	textParams.Font = self.Instance.TitleText.FontFace
	textParams.Size = 14
	textParams.Width = 10000

	local requiredTextSpace = TextService:GetTextBoundsAsync(textParams) + textSpaceOffset

	self.Instance.TitleText.Text = newText or "N/A"
	self.Instance.TitleText.Size = UDim2.new(0, requiredTextSpace.X, 1, 0)
end

function elementHandler:Label(labelInputtedText: string, textSize: number, textColor: Color3): table
	local label = setmetatable({}, labelHandler)
	local labelInstance = originalElements.Label:Clone()

	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = labelInputtedText or "N/A"
	textParams.Font = labelInstance.LabelBackground.LabelText.FontFace
	textParams.Size = textSize or 13

	label.Type = "Label"
	label.IdentifierText = labelInputtedText or "N/A"
	label.Instance = labelInstance
	label.GuiToRemove = labelInstance
	label.PlayingAnimations = {}

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[labelInstance] = label
	end

	labelInstance.LabelBackground.LabelText.Text = labelInputtedText or "N/A"
	labelInstance.LabelBackground.LabelText.TextColor3 = textColor or Color3.fromRGB(255,255,255)
	labelInstance.LabelBackground.LabelText.TextSize = textSize or 13

	labelInstance.Parent = self.ElementToParentChildren
	textParams.Width = labelInstance.LabelBackground.LabelText.AbsoluteSize.X - labelInstance.LabelBackground.LabelText.LabelTextPadding.PaddingLeft.Offset - labelInstance.LabelBackground.LabelText.LabelTextPadding.PaddingRight.Offset
	labelInstance.Size = UDim2.new(1,0,0,TextService:GetTextBoundsAsync(textParams).Y + labelInstance.LabelBackground.LabelText.LabelTextPadding.PaddingTop.Offset + labelInstance.LabelBackground.LabelText.LabelTextPadding.PaddingBottom.Offset + labelInstance.LabelPadding.PaddingTop.Offset + labelInstance.LabelPadding.PaddingBottom.Offset + labelInstance.LabelBackground.LabelBackgroundPadding.PaddingTop.Offset + labelInstance.LabelBackground.LabelBackgroundPadding.PaddingBottom.Offset)

	return label
end

function labelHandler:ChangeText(newText: string, playAnimation: boolean): nil
	local textParams = Instance.new("GetTextBoundsParams") -- Add Tween here for text
	textParams.Text = newText or "N/A"
	textParams.Font = self.Instance.LabelBackground.LabelText.FontFace
	textParams.Size = 13
	textParams.Width = self.Instance.LabelBackground.LabelText.AbsoluteSize.X

	playAnimation = playAnimation or false

	local function closeAllRunningAnimations()
		for i, foundAnimation in pairs(self.PlayingAnimations) do
			coroutine.close(foundAnimation)
			table.remove(self.PlayingAnimations, i)
		end
	end

	if playAnimation then
		closeAllRunningAnimations()

		local animationCoroutine = coroutine.create(function()
			for i = 1, #newText do
				self.Instance.LabelBackground.LabelText.Text = string.sub(newText or "N/A", 1, i)
				task.wait(.01)
			end
		end)

		table.insert(self.PlayingAnimations, animationCoroutine)
		coroutine.resume(animationCoroutine)
	else
		closeAllRunningAnimations()
		self.Instance.LabelBackground.LabelText.Text = newText or "N/A"
	end
end

function elementHandler:Toggle(toggleName: string, callback): table
	local toggle = setmetatable({}, toggleHandler)
	local toggleInstance = originalElements.Toggle:Clone()
	local textOffset = 4

	local tweenTime = .275
	local cornerOnTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage.ToggleImageCorner, TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {CornerRadius = UDim.new(0, 0)})
	local cornerOffTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage.ToggleImageCorner, TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CornerRadius = UDim.new(.5, 0)})
	local imageRotationOnTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Rotation = 360})
	local imageRotationOffTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Rotation = 0})
	local imageSizeOnTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(1,1)});
	local imageSizeOffTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,0)});

	toggle.Type = "Toggle"
	toggle.IdentifierText = toggleName or "N/A"
	toggle.Instance = toggleInstance
	toggle.GuiToRemove = toggleInstance
	toggle.Enabled = false

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[toggleInstance] = toggle
	end

	callback = callback or function() end

	local function onToggleClick()
		if toggle.Enabled then
			cornerOffTween:Play()
			imageRotationOffTween:Play()
			imageSizeOffTween:Play()
		else
			cornerOnTween:Play()
			imageRotationOnTween:Play()
			imageSizeOnTween:Play()
		end

		toggle.Enabled = not toggle.Enabled

		callback(toggle.Enabled)
	end

	toggleInstance.MouseButton1Click:Connect(onToggleClick)

	toggleInstance.ToggleText.Text = toggleName or "N/A"

	toggleInstance.Parent = self.ElementToParentChildren
	toggleInstance.ToggleText.Size = UDim2.new(1,-(toggleInstance.BoxBackground.AbsoluteSize.X + textOffset),1,0)
	toggleInstance.Position = UDim2.fromOffset(toggleInstance.BoxBackground.AbsoluteSize.X + textOffset,0)

	return toggle
end
 -- SET IDENTIFIER IN SELF AND ADD TOGGLES TO EACH IDENTIFIER RADIO GROUP
function toggleHandler:Set(bool: boolean, callback): nil -- Add Callback to self?
	local tweenTime = .275
	local cornerOnTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage.ToggleImageCorner, TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {CornerRadius = UDim.new(0, 0)})
	local cornerOffTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage.ToggleImageCorner, TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CornerRadius = UDim.new(.5, 0)})
	local imageRotationOnTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Rotation = 360})
	local imageRotationOffTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Rotation = 0})
	local imageSizeOnTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(1,1)});
	local imageSizeOffTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,0)});

	if typeof(bool) ~= "boolean" then error("First argument must be a boolean.") end

	callback = callback or function() end
	self.Enabled = bool

	if self.Enabled then
		cornerOnTween:Play()
		imageRotationOnTween:Play()
		imageSizeOnTween:Play()
	else
		cornerOffTween:Play()
		imageRotationOffTween:Play()
		imageSizeOffTween:Play()
	end

	callback(bool)
end

function elementHandler:Button(buttonName: string, callback): table -- Add Callback to self?
	local button = setmetatable({}, buttonHandler)
	local buttonInstance = originalElements.Button:Clone()
	local textOffset = 4

	local tweenTime = .25
	local buttonExpandTween = TweenService:Create(buttonInstance.CircleBackground.InnerCircle.CenterCircle.ButtonCircle, TweenInfo.new(tweenTime / 2, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(1,1)})
	local buttonCondenseTween = TweenService:Create(buttonInstance.CircleBackground.InnerCircle.CenterCircle.ButtonCircle, TweenInfo.new(tweenTime / 2, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,0)})

	buttonName = buttonName or "N/A"
	callback = callback or function() end

	buttonExpandTween.Completed:Connect(function(playbackState)
		task.wait(.1)
		if playbackState == Enum.PlaybackState.Completed then
			buttonCondenseTween:Play()
		end
	end)

	local function onButtonClick()
		buttonExpandTween:Play()
		callback()
	end

	button.Type = "Button"
	button.IdentifierText = buttonName or "N/A"
	button.Instance = buttonInstance
	button.GuiToRemove = buttonInstance

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[buttonInstance] = button
	end

	buttonInstance.MouseButton1Click:Connect(onButtonClick)

	buttonInstance.ButtonText.Text = buttonName

	buttonInstance.Parent = self.ElementToParentChildren
	buttonInstance.ButtonText.Size = UDim2.new(1,-(buttonInstance.CircleBackground.AbsoluteSize.X + textOffset),1,0)
	buttonInstance.ButtonText.Position = UDim2.fromOffset(buttonInstance.CircleBackground.AbsoluteSize.X + textOffset,0)
end

function elementHandler:Dropdown(dropdownName: string): table
	local dropdown = setmetatable({}, dropdownHandler)
	local dropdownInstance = originalElements.Dropdown:Clone()
	local elementHolderInnerBackground = dropdownInstance.ElementHolder.ElementHolderBackground.ElementHolderInnerBackground
	local elementHolderInnerBackgroundPaddings = dropdownInstance.ElementHolder.ElementHolderPadding.PaddingBottom.Offset + dropdownInstance.ElementHolder.ElementHolderPadding.PaddingTop.Offset + dropdownInstance.ElementHolder.ElementHolderBackground.ElementHolderBackgroundPadding.PaddingBottom.Offset + dropdownInstance.ElementHolder.ElementHolderBackground.ElementHolderBackgroundPadding.PaddingTop.Offset + elementHolderInnerBackground.ElementHolderInnerBackgroundPadding.PaddingBottom.Offset + elementHolderInnerBackground.ElementHolderInnerBackgroundPadding.PaddingTop.Offset

	local imageRotationOpenTween = TweenService:Create(dropdownInstance.DropdownButton.ButtonBackground.DropdownImage, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Rotation = 0})
	local imageRotationCloseTween = TweenService:Create(dropdownInstance.DropdownButton.ButtonBackground.DropdownImage, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Rotation = 180})
	local dropdownInstanceCloseTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,dropdownInstance.DropdownButton.Size.Y.Offset)})
	local dropdownInstanceOpenTween

	local function onDropdownClicked()
		if dropdown.IsExpanded then
			dropdown.IsExpanded = false
			imageRotationCloseTween:Play()
			dropdownInstanceCloseTween:Play()
		else
			dropdown.IsExpanded = true
			imageRotationOpenTween:Play()
			dropdownInstanceOpenTween:Play()
		end
	end

	dropdown.Type = "Dropdown"
	dropdown.IdentifierText = dropdownName or "N/A"
	dropdown.Instance = dropdownInstance
	dropdown.GuiToRemove = dropdownInstance
	dropdown.ElementToParentChildren = dropdownInstance.ElementHolder.ElementHolderBackground.ElementHolderInnerBackground
	dropdown.IsExpanded = false

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[dropdownInstance] = dropdown
	end

	dropdownInstance.DropdownButton.MouseButton1Click:Connect(onDropdownClicked)

	elementHolderInnerBackground.ElementHolderInnerBackgroundList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if dropdown.IsExpanded then
			if elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y == 0 then
				dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0, dropdownInstance.DropdownButton.AbsoluteSize.Y)})
			else
				local elementHolderTween = TweenService:Create(dropdownInstance.ElementHolder, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(.925,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings)})
				dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings + dropdownInstance.DropdownButton.Size.Y.Offset)})

				elementHolderTween:Play()
			end
			dropdownInstanceOpenTween:Play()
		else
			dropdownInstance.ElementHolder.Size = UDim2.new(.925,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings)
			if elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y == 0 then
				dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0, dropdownInstance.DropdownButton.AbsoluteSize.Y)})
			else
				dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings + dropdownInstance.DropdownButton.Size.Y.Offset)})
			end
		end
	end)

	dropdownInstance.DropdownButton.ButtonBackground.DropdownText.Text = dropdownName or "N/A"

	dropdownInstance.Parent = self.ElementToParentChildren
	dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0, dropdownInstance.DropdownButton.AbsoluteSize.Y + dropdownInstance.ElementHolder.AbsoluteSize.Y)})
	return dropdown
end

function dropdownHandler:ChangeText(newText: string)
	newText = newText or "N/A"
	self.Instance.DropdownButton.ButtonBackground.DropdownText.Text = newText
	self.IdentifierText = newText
end

function elementHandler:Slider(sliderName: string, callback, maximumValue: number, minimumValue: number): table
	local slider = setmetatable({}, sliderHandler) -- MAKE RIGHT CLICK AND BAR GOES TO MID
	local sliderInstance = originalElements.Slider:Clone()
	local isMouseDown = false
	local sliderBar = sliderInstance.SliderBackground.SliderInnerBackground.Slider
	local minimumClosePixelsLeft = 2
	local textPixelOffset = 2
	local absPos
	local absSize

	minimumValue = minimumValue or 0
	maximumValue = maximumValue or 100

	assert(maximumValue > minimumValue, "Maximum must be greater than minimum.")

	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = tostring(maximumValue) or "N/A"
	textParams.Font = sliderInstance.TextGrouping.NumberText.FontFace
	textParams.Size = 14
	textParams.Width = 10000

	local requiredNumberTextSpace = TextService:GetTextBoundsAsync(textParams)
	textParams.Text = "ERR"
	local requiredErrorTextSpace = TextService:GetTextBoundsAsync(textParams)

	local maxMinRange = math.abs(minimumValue - maximumValue)
	local sliderValue = minimumValue

	local sliderConnection
	local endInputConnection

	callback = callback or function() end

	local function onMouseDown()
		local function onMouseMoved()
			local absPos = sliderBar.AbsolutePosition
			local absSize = sliderBar.Parent.EmptySliderBackground.AbsoluteSize

			if mouse.X < absPos.X then
				sliderBar.Size = UDim2.new(0,minimumClosePixelsLeft,1,0)
				sliderValue = minimumValue
			elseif mouse.X > absPos.X + absSize.X then
				sliderBar.Size = UDim2.new(1,0,1,0)
				sliderValue = maximumValue
			else
				local percentOfBarFilled = (mouse.X - absPos.X) / absSize.X
				sliderBar.Size = UDim2.new(0,math.max(minimumClosePixelsLeft, mouse.X - absPos.X),1,0)
				sliderValue = minimumValue + (maxMinRange * percentOfBarFilled)
			end

			sliderInstance.TextGrouping.NumberText.Text = math.round(sliderValue)
			callback(sliderValue)
		end

		onMouseMoved()
		sliderConnection = mouse.Move:Connect(onMouseMoved)

		endInputConnection = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				sliderConnection:Disconnect()
				endInputConnection:Disconnect()
			end
		end)
	end

	local function onFocusLost(enterPressed)
		if enterPressed then
			local enteredNum = tonumber(sliderInstance.TextGrouping.NumberText.Text)
			if typeof(enteredNum) == "number" and enteredNum >= minimumValue and enteredNum <= maximumValue then
				local absPos = sliderBar.AbsolutePosition
				local absSize = sliderBar.Parent.EmptySliderBackground.AbsoluteSize
				local percentOfBarFilled = enteredNum / absSize.X
				sliderValue = enteredNum
				sliderInstance.TextGrouping.NumberText.Text = math.round(sliderValue)
				sliderBar.Size = UDim2.new((sliderValue - minimumValue) / maxMinRange,0,1,0)
				callback(sliderValue)
			else
				sliderInstance.TextGrouping.NumberText.Text = "ERR"
				task.wait(.5)
				if sliderInstance.TextGrouping.NumberText.Text == "ERR" then
					sliderInstance.TextGrouping.NumberText.Text = math.round(sliderValue)
				end
			end
		else
			sliderInstance.TextGrouping.NumberText.Text = math.round(sliderValue)
		end
	end

	slider.Type = "Slider"
	slider.IdentifierText = sliderName or "N/A"
	slider.Instance = sliderInstance
	slider.GuiToRemove = sliderInstance

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[sliderInstance] = slider
	end

	sliderInstance.SliderBackground.MouseButton1Down:Connect(onMouseDown)
	sliderInstance.TextGrouping.NumberText.FocusLost:Connect(onFocusLost)

	sliderInstance.TextGrouping.SliderText.Text = sliderName or "N/A"
	sliderInstance.TextGrouping.NumberText.Text = minimumValue
	sliderInstance.TextGrouping.NumberText.Size = UDim2.new(0,math.max(requiredErrorTextSpace.X, requiredNumberTextSpace.X) + textPixelOffset,1,0)

	sliderInstance.Parent = self.ElementToParentChildren
	sliderInstance.TextGrouping.SliderText.Size = UDim2.new(0, sliderInstance.TextGrouping.AbsoluteSize.X - textPixelOffset - requiredNumberTextSpace.X, 1, 0)
end

function elementHandler:SearchBar(placeholderText: string): table
	local searchBar = setmetatable({}, searchBarHandler)
	local searchBarInstance = originalElements.SearchBar:Clone()
	local searchBox = searchBarInstance.SearchBarFrame.ButtonBackgroundPadding.SearchBox
	local elementHolder = searchBarInstance.ElementHolder
    local elementHolderBackground = elementHolder.ElementHolderBackground
	local elementHolderInnerBackground = elementHolderBackground.ElementHolderInnerBackground
	local elementHolderInnerBackgroundPaddings = elementHolder.ElementHolderPadding.PaddingBottom.Offset + elementHolder.ElementHolderPadding.PaddingTop.Offset + elementHolderBackground.ElementHolderBackgroundPadding.PaddingBottom.Offset + elementHolderBackground.ElementHolderBackgroundPadding.PaddingTop.Offset + elementHolderInnerBackground.ElementHolderInnerBackgroundPadding.PaddingBottom.Offset + elementHolderInnerBackground.ElementHolderInnerBackgroundPadding.PaddingTop.Offset
	local searchBarInstanceCloseTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,searchBarInstance.SearchBarFrame.Size.Y.Offset)})
	local searchBarInstanceOpenTween
	local isMouseHoveringOver = false
	local mouseEnterConnection
	local mouseLeftConnection
	local uisFocusLost
	local playingAnimation
	local searchingText

	placeholderText = placeholderText or "N/A"

	local function onTextChanged()
		if searchBar.IsExpanded then
			if searchingText then coroutine.close(searchingText) end
			searchingText = coroutine.create(function()
				for _, foundElement in ipairs(elementHolderInnerBackground:GetChildren()) do
					local foundElementInfo = searchBar.ChildedElementsInfo[foundElement]
					if foundElementInfo ~= nil then
						if foundElementInfo.IdentifierText:lower():find(searchBox.Text:lower(), 1, true) then
							foundElement.Visible = true
						else
							foundElement.Visible = false
						end
					end
				end
				searchingText = nil
			end)
			coroutine.resume(searchingText)
		end
	end

	local function onFocused()
		elementHolderInnerBackground.Visible = true
		searchBar.IsExpanded = true
		onTextChanged()
		isMouseHoveringOver = true
		searchBarInstanceOpenTween:Play()

		if playingAnimation then
			coroutine.close(playingAnimation)
			searchBox.PlaceholderText = placeholderText
			searchBox.Text = ""
		end

		mouseLeftConnection = searchBarInstance.MouseLeave:Connect(function()
			isMouseHoveringOver = false

			if not searchBox:IsFocused() then
				searchBar.IsExpanded = false
				searchBarInstanceCloseTween:Play()
				mouseLeftConnection:Disconnect()
				mouseEnterConnection:Disconnect()
				uisFocusLost:Disconnect()

				searchBarInstanceCloseTween.Completed:Connect(function(playbackState)
					if playbackState == Enum.PlaybackState.Completed then
						elementHolderInnerBackground.Visible = false
					end
				end)

				if playingAnimation then coroutine.close(playingAnimation) end
				playingAnimation = coroutine.create(function()
					searchBox.PlaceholderText = ""
					animateText(searchBox, .025, nil, placeholderText, true)
					playingAnimation = nil
				end)
				coroutine.resume(playingAnimation)
			end
		end)

		mouseEnterConnection = searchBarInstance.MouseEnter:Connect(function()
			isMouseHoveringOver = true
		end)

		uisFocusLost = UserInputService.TextBoxFocusReleased:Connect(function(textBoxReleased)
			if textBoxReleased == searchBox then
				if not isMouseHoveringOver then
					searchBar.IsExpanded = false
					searchBarInstanceCloseTween:Play()
					mouseLeftConnection:Disconnect()
					mouseEnterConnection:Disconnect()
					uisFocusLost:Disconnect()

					searchBarInstanceCloseTween.Completed:Connect(function(playbackState)
						if playbackState == Enum.PlaybackState.Completed then
							elementHolderInnerBackground.Visible = false
						end
					end)

					if playingAnimation then coroutine.close(playingAnimation) end
					playingAnimation = coroutine.create(function()
						searchBox.PlaceholderText = ""
						animateText(searchBox, .025, nil, placeholderText, true)
						playingAnimation = nil
					end)
					coroutine.resume(playingAnimation)
				end
			end
		end)
	end

	searchBar.Type = "SearchBar"
	searchBar.IdentifierText = placeholderText or "N/A"
	searchBar.Instance = searchBarInstance
	searchBar.GuiToRemove = searchBarInstance
	searchBar.ElementToParentChildren = elementHolderInnerBackground
	searchBar.ChildedElementsInfo = {}
	searchBar.IsExpanded = false

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[searchBarInstance] = searchBar
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(onTextChanged)
	searchBox.Focused:Connect(onFocused)

	elementHolderInnerBackground.ElementHolderInnerBackgroundList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if searchBar.IsExpanded then
			if elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y == 0 then
				searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,searchBarInstance.SearchBarFrame.Size.Y.Offset)})
			else
				local elementHolderOpenTween = TweenService:Create(elementHolder, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(.925,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings)})
				searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings + searchBarInstance.SearchBarFrame.Size.Y.Offset)})
				elementHolderOpenTween:Play()
			end

			searchBarInstanceOpenTween:Play()
		else
			elementHolder.Size = UDim2.new(.925,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings)
			if elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y == 0 then
				searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,searchBarInstance.SearchBarFrame.Size.Y.Offset)})
			else
				searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings + searchBarInstance.SearchBarFrame.Size.Y.Offset)})
			end
		end
	end)

	searchBox.PlaceholderText = placeholderText or "N/A"

	searchBarInstance.Parent = self.ElementToParentChildren
	searchBox.Size = UDim2.new(1,-(searchBox.Parent.SearchImage.AbsoluteSize.X + searchBox.Parent.ButtonBackgroundPadding.PaddingRight.Offset),1,0)
	searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,searchBarInstance.SearchBarFrame.Size.Y.Offset)})

	return searchBar
end

--REWORK KEYBIND COMPLETLEY INEFFICENT !!!
-- ADD RIGHT CLICK TO REMOVE CURRENT KEYBIND TO NOTHING
function elementHandler:Keybind(keybindName: string, callback, defaultKey: string): table
	local keybind = setmetatable({}, keybindHandler)
	local keybindInstance = originalElements.Keybind:Clone()
	local sideClosedTextPaddingPixels = 1
	local keybindTextPadding = 4
	local isOverriding = false
	local inputBeingProcessed
	local originialOffsetSize
	local textAnimationSpeed = .025
	local textAnimation

	local pressKeyMsg = "Press a key..."
	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = pressKeyMsg
	textParams.Width = 10000
	textParams.Font = keybindInstance.BoxBackground.InnerBox.KeyText.FontFace
	textParams.Size = 14

	local requiredInputKeyTextSize = TextService:GetTextBoundsAsync(textParams)
	local requiredInputKeyTextTween = TweenService:Create(keybindInstance.BoxBackground, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0,requiredInputKeyTextSize.X + keybindInstance.BoxBackground.BoxPadding.PaddingLeft.Offset + keybindInstance.BoxBackground.BoxPadding.PaddingRight.Offset + keybindInstance.BoxBackground.InnerBox.BoxPadding.PaddingLeft.Offset + keybindInstance.BoxBackground.InnerBox.BoxPadding.PaddingRight.Offset,1,0)})

	callback = callback or function() end
	keybindName = keybindName or "N/A"
	defaultKey = defaultKey or "F"

	local function getMatchingKeyCodeFromName(name: string)
		for i, keycode in pairs(Enum.KeyCode:GetEnumItems()) do
			if keycode.Name:lower() == name:lower() then
				return keycode
			end
		end
	end

	local function onKeybindClick()
		local recognizedKey = false
		local input

		requiredInputKeyTextTween:Play()

		repeat
			local gameProcessedEvent
			input, gameProcessedEvent = UserInputService.InputBegan:Wait()
			if input.KeyCode.Name ~= "Unknown" then
				recognizedKey = true
			end
		until recognizedKey

		isOverriding = true
		if textAnimation then
			coroutine.close(textAnimation)
		end

		textAnimation = coroutine.create(function()
			animateText(keybindInstance.BoxBackground.InnerBox.KeyText, textAnimationSpeed, input.KeyCode.Name)

			textParams.Text = input.KeyCode.Name
			local requiredNewTextSpace = TextService:GetTextBoundsAsync(textParams)
			local closeTween = TweenService:Create(keybindInstance.BoxBackground, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0,math.max(originialOffsetSize.X, requiredNewTextSpace.X + keybindInstance.BoxBackground.BoxPadding.PaddingLeft.Offset + keybindInstance.BoxBackground.BoxPadding.PaddingRight.Offset + keybindInstance.BoxBackground.InnerBox.BoxPadding.PaddingLeft.Offset + keybindInstance.BoxBackground.InnerBox.BoxPadding.PaddingRight.Offset + sideClosedTextPaddingPixels),1,0)})
			closeTween:Play()
			isOverriding = false
		end)

		coroutine.resume(textAnimation)

		repeat task.wait() until not inputBeingProcessed
		defaultKey = input.KeyCode
	end

	local function onInputBegan(input, gameProcessedEvent)
		inputBeingProcessed = true
		if gameProcessedEvent then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == defaultKey then
				callback()
			end
		end
		inputBeingProcessed = false
	end
	-- for toggle radio buttons do a fn to loop all and toggles in table given and setttoggle fn to false  by checking if self.IsToggled
	requiredInputKeyTextTween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed and not isOverriding then -- Animation runs after other override starts due to tween completed after override starts
			if textAnimation then
				coroutine.close(textAnimation)
			end

			textAnimation = coroutine.create(function()
				animateText(keybindInstance.BoxBackground.InnerBox.KeyText, textAnimationSpeed, pressKeyMsg)
			end)

			coroutine.resume(textAnimation)
		end
	end)

	keybind.Type = "Keybind"
	keybind.IdentifierText = keybindName
	keybind.Instance = keybindInstance
	keybind.GuiToRemove = keybindInstance

	UserInputService.InputBegan:Connect(onInputBegan)
	keybindInstance.MouseButton1Click:Connect(onKeybindClick)

	keybindInstance.KeybindText.Text = keybindName
	keybindInstance.BoxBackground.InnerBox.KeyText.Text = defaultKey

	defaultKey = getMatchingKeyCodeFromName(defaultKey)

	keybindInstance.Parent = self.ElementToParentChildren
	originialOffsetSize = keybindInstance.BoxBackground.AbsoluteSize
	keybindInstance.BoxBackground.Size = UDim2.fromOffset(originialOffsetSize.X,originialOffsetSize.Y)
	keybindInstance.BoxBackground.BoxAspect:Destroy()
	keybindInstance.KeybindText.Size = UDim2.new(1,-(originialOffsetSize.X + keybindTextPadding),1,0)
end

function elementHandler:TextBox(textBoxName:string, callback): table
	local textBox = setmetatable({}, textBoxHandler)
	local textBoxInstance = originalElements.TextBox:Clone()
	local placeholderText = "Type here..."
	local sidePlaceholderTextPadding = 2
	local textAnimation

	local boxBackground = textBoxInstance.BoxBackground
	local innerBox = boxBackground.InnerBox
	local textBoxText = innerBox.TextBoxText

	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = placeholderText
	textParams.Width = 10000
	textParams.Font = textBoxText.FontFace
	textParams.Size = 14

	local requiredPlaceholderTextSpace = TextService:GetTextBoundsAsync(textParams)

	local function onInstanceClicked(): nil
		textBoxText:CaptureFocus()
	end

	local function onFocusLost(enterPressed: boolean): nil
		if enterPressed then callback(textBoxText.Text) end
		if textAnimation then coroutine.close(textAnimation) end
		textAnimation = coroutine.create(function()
			textBoxText.PlaceholderText = ""
			animateText(textBoxText, .025, _, placeholderText, true)
			textAnimation = nil
		end)
		coroutine.resume(textAnimation)
	end

	local function onFocused()
		if textAnimation then
			coroutine.close(textAnimation)
			textBoxText.PlaceholderText = placeholderText
			textBoxText.Text = ""
		end
	end

	local function onTextChanged()
		local boxBackgroundPaddingNeededSize = (sidePlaceholderTextPadding * 2) + boxBackground.BoxPadding.PaddingLeft.Offset + boxBackground.BoxPadding.PaddingRight.Offset + innerBox.BoxPadding.PaddingLeft.Offset + innerBox.BoxPadding.PaddingRight.Offset
		textParams.Text = textBoxText.Text
		local requiredTextSize = TextService:GetTextBoundsAsync(textParams)
		local textChangedTween = TweenService:Create(boxBackground, TweenInfo.new(.1, Enum.EasingStyle.Linear), {Size = UDim2.new(0,math.clamp(boxBackgroundPaddingNeededSize + requiredTextSize.X, boxBackgroundPaddingNeededSize + requiredPlaceholderTextSpace.X, textBoxInstance.AbsoluteSize.X / 8 * 5),1,0)})
		textChangedTween:Play()
	end

	textBoxName = textBoxName or "N/A"
	callback = callback or function() end

	textBox.Type = "TextBox"
	textBox.IdentifierText = textBoxName
	textBox.Instance = textBoxInstance
	textBox.GuiToRemove = textBoxInstance

	textBoxInstance.MouseButton1Click:Connect(onInstanceClicked)
	textBoxText.FocusLost:Connect(onFocusLost)
	textBoxText.Focused:Connect(onFocused)
	textBoxText:GetPropertyChangedSignal("Text"):Connect(onTextChanged)

	textBoxText.PlaceholderText = placeholderText
	textBoxInstance.TextBoxNameText.Text = textBoxName

	textBoxInstance.Parent = self.ElementToParentChildren
	boxBackground.Size = UDim2.new(0,requiredPlaceholderTextSpace.X + (sidePlaceholderTextPadding * 2) + boxBackground.BoxPadding.PaddingLeft.Offset + boxBackground.BoxPadding.PaddingRight.Offset + innerBox.BoxPadding.PaddingLeft.Offset + innerBox.BoxPadding.PaddingRight.Offset,1,0)
	textBoxInstance.TextBoxNameText.Size = UDim2.new(1,-(boxBackground.AbsoluteSize.X + 4),1,0)

	return textBox
end

--Fix toggle img it's imported as orange make it white
function elementHandler:ColorWheel(colorWheelName: string, callback): table
	local colorWheel = setmetatable({}, colorWheelHandler)
	local colorWheelInstance = originalElements.ColorWheel:Clone()

	local heading = colorWheelInstance.Heading
	local wheelHolder = colorWheelInstance.WheelHolder
	local valueHolder =wheelHolder.ValueHolder
	local colorInputHolder = valueHolder.ColorInputHolder
	local wheel = wheelHolder.Wheel
	local selector = wheel.Selector
	local slider = valueHolder.ValueSlider
	local sliderBar = slider.SliderBar
	local sliderAbsSize
	local sliderAbsPos
	local wheelRadius

	local dropdownOpenTween = TweenService:Create(colorWheelInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, heading.AbsoluteSize.Y + wheelHolder.AbsoluteSize.Y + 4)})
	local dropdownCloseTween = TweenService:Create(colorWheelInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, heading.AbsoluteSize.Y)})
	local dropdownImageOpenTween = TweenService:Create(heading.BoxBackground.InnerBox.CenterBox.DropdownImage, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Rotation = 0})
	local dropdownImageCloseTween = TweenService:Create(heading.BoxBackground.InnerBox.CenterBox.DropdownImage, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Rotation = 180})

	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = "255"
	textParams.Font = heading.ColorWheelName.FontFace
	textParams.Size = 14
	textParams.Width = 10000

	local requiredRgbTextSize = TextService:GetTextBoundsAsync(textParams)

	local hue, saturation, value = 0, 0, 1

	local function updateVisuals()
		local color = Color3.fromHSV(hue, saturation, value)

		valueHolder.ColorSample.BackgroundColor3 = color
		colorInputHolder.Red.BoxBackground.InnerBox.ColorValue.Text = math.round(color.R * 255)
		colorInputHolder.Green.BoxBackground.InnerBox.ColorValue.Text = math.round(color.G * 255)
		colorInputHolder.Blue.BoxBackground.InnerBox.ColorValue.Text = math.round(color.B * 255)
		callback(color)
	end

	local function updateSlider()
		local sliderAbsPos = slider.AbsolutePosition
		local sliderAbsSize = slider.AbsoluteSize

		if mouse.X - sliderAbsPos.X <= 0 then
			sliderBar.Position = UDim2.new(0,0,0,0)
		elseif mouse.X - sliderAbsPos.X >= sliderAbsSize.X - sliderBar.AbsoluteSize.X then
			sliderBar.Position = UDim2.new(1,-(sliderBar.AbsoluteSize.X),0,0)
		else
			sliderBar.Position = UDim2.new(0,mouse.X - sliderAbsPos.X,0,0)
		end

		local clampedMousePos = math.clamp(mouse.X - sliderAbsPos.X, 0, sliderAbsSize.X - sliderBar.AbsoluteSize.X)
		value = clampedMousePos / (sliderAbsSize.X - sliderBar.AbsoluteSize.X)

		updateVisuals()
	end

	local function updateRing()
		local relativeVector = Vector2.new(mouse.X, mouse.Y) - wheel.AbsolutePosition - wheel.AbsoluteSize / 2
		local radius, angle = toPolar(relativeVector * Vector2.new(1,-1))

		if radius > wheelRadius then
			relativeVector = relativeVector.Unit * wheelRadius
			radius = wheelRadius
		end

		selector.Position = UDim2.new(.5, relativeVector.X, .5, relativeVector.Y)

		hue, saturation = (math.deg(angle) + 180) / 360 , radius / wheelRadius

		updateVisuals()
	end

	local function onDropdownClicked()
		if colorWheel.IsExpanded then
			colorWheel.IsExpanded = false
			dropdownCloseTween:Play()
			dropdownImageCloseTween:Play()
		else
			colorWheel.IsExpanded = true
			dropdownOpenTween:Play()
			dropdownImageOpenTween:Play()
		end
	end

	local function onSliderMouseDown()
		local inputEndedConnection

		updateSlider()

		local mouseMovedConnection = mouse.Move:Connect(function()
			updateSlider()
		end)

		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				inputEndedConnection:Disconnect()
				mouseMovedConnection:Disconnect()
			end
		end)
	end

	local function onWheelMouseDown()
		local inputEndedConnection

		updateRing()

		local mouseMovedConnection = mouse.Move:Connect(function()
			updateRing()
		end)

		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				inputEndedConnection:Disconnect()
				mouseMovedConnection:Disconnect()
			end
		end)
	end

	local function onColorInputTextChanged(textBox: TextBox): nil
		local colorValue = tonumber(textBox.Text)
		if textBox.Text:match("%D") or #textBox.Text > 3 then
			textBox.Text = textBox.Text:sub(1, #textBox.Text - 1)
		elseif colorValue and colorValue > 255 then
			textBox.Text = 255
		end
	end

	local function onColorInputTextLostFocus(textBox: TextBox, textBoxColorAssociated): nil
		local currentColor = Color3.fromHSV(hue, saturation, value)
		local colorTable = {
			Red = {Tag = "R", Color3Value = Color3.fromRGB(tonumber(textBox.Text), currentColor.G * 255, currentColor.B * 255)},
			Green = {Tag = "G", Color3Value = Color3.fromRGB(currentColor.R * 255, tonumber(textBox.Text), currentColor.B * 255)},
			Blue = {Tag = "B", Color3Value = Color3.fromRGB(currentColor.R * 255, currentColor.G * 255, tonumber(textBox.Text))}
		}

		if #textBox.Text == 0 then
			textBox.Text = math.round(currentColor[colorTable[textBoxColorAssociated].Tag] * 255)
		else
			hue, saturation, value = colorTable[textBoxColorAssociated].Color3Value:ToHSV()

			local x, y = toCartesian(saturation, math.rad(hue * 360))

			selector.Position = UDim2.new(.5, -x * wheelRadius, .5, y * wheelRadius)

			updateVisuals()
		end

	end

	colorWheelName = colorWheelName or "N/A"
	callback = callback or function() end

	colorWheel.Type = "ColorWheel"
	colorWheel.IdentifierText = colorWheelName
	colorWheel.IsExpanded = false
	colorWheel.Instance = colorWheelInstance
	colorWheel.GuiToRemove = colorWheelInstance

	heading.MouseButton1Click:Connect(onDropdownClicked)
	slider.MouseButton1Down:Connect(onSliderMouseDown)
	wheel.MouseButton1Down:Connect(onWheelMouseDown)

	heading.ColorWheelName.Text = colorWheelName

	colorWheelInstance.Parent = self.ElementToParentChildren
	heading.ColorWheelName.Size = UDim2.new(1, -(heading.BoxBackground.AbsoluteSize.X + 4),1,0)
	valueHolder.Size = UDim2.new(.9,-(wheel.AbsoluteSize.X + 4),1,0)
	sliderBar.Position = UDim2.new(1,-sliderBar.AbsoluteSize.X,0,0)

	for _, rgbFrame in ipairs(valueHolder.ColorInputHolder:GetChildren()) do
		if rgbFrame:IsA("Frame") then
			local requiredBoxBackgroundXSize = rgbFrame.BoxBackground.BoxPadding.PaddingLeft.Offset + rgbFrame.BoxBackground.BoxPadding.PaddingRight.Offset + rgbFrame.BoxBackground.InnerBox.BoxPadding.PaddingLeft.Offset + rgbFrame.BoxBackground.InnerBox.BoxPadding.PaddingRight.Offset + requiredRgbTextSize.X + 4
			rgbFrame.BoxBackground.Size = UDim2.new(0,requiredBoxBackgroundXSize,1,0)
			rgbFrame.ColorText.Size = UDim2.new(1,-(requiredBoxBackgroundXSize + 2),1,0)
			rgbFrame.BoxBackground.InnerBox.ColorValue:GetPropertyChangedSignal("Text"):Connect(function() onColorInputTextChanged(rgbFrame.BoxBackground.InnerBox.ColorValue) end)
			rgbFrame.BoxBackground.InnerBox.ColorValue.FocusLost:Connect(function() onColorInputTextLostFocus(rgbFrame.BoxBackground.InnerBox.ColorValue, rgbFrame.Name) end)
		end
	end

	wheelRadius = wheel.AbsoluteSize.X / 2

	return colorWheel
end

createOriginialElements()

return Library