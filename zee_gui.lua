--// DARK GLASS UI
--// Clean purple / black glass interface
--// Full fixed version

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local GUI_NAME = "DarkGlassUI"

local ToggleKey = Enum.KeyCode.RightShift
local ShowHotkeys = true

local GUI_WIDTH = 760
local GUI_HEIGHT = 480

local PURPLE = Color3.fromRGB(145, 75, 255)
local PURPLE_LIGHT = Color3.fromRGB(195, 140, 255)

--==================================================
-- CLEANUP OLD VERSION
--==================================================

local oldGui = PlayerGui:FindFirstChild(GUI_NAME)

if oldGui then
	oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("DarkGlassBlur")

if oldBlur then
	oldBlur:Destroy()
end

--==================================================
-- HELPERS
--==================================================

local function New(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties) do
		object[property] = value
	end

	object.Parent = parent

	return object
end

local function Corner(parent, radius)
	return New("UICorner", {
		CornerRadius = UDim.new(0, radius)
	}, parent)
end

local function Stroke(parent, transparency, thickness)
	return New("UIStroke", {
		Color = Color3.fromRGB(180, 120, 255),
		Transparency = transparency,
		Thickness = thickness
	}, parent)
end

local function Tween(object, properties, duration, style, direction)
	local info = TweenInfo.new(
		duration or 0.3,
		style or Enum.EasingStyle.Quint,
		direction or Enum.EasingDirection.Out
	)

	return TweenService:Create(object, info, properties)
end

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = New("ScreenGui", {
	Name = GUI_NAME,
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

--==================================================
-- BACKGROUND
--==================================================

local Background = New("Frame", {
	Name = "Background",

	Size = UDim2.fromScale(1, 1),

	BackgroundColor3 = Color3.fromRGB(4, 3, 9),

	BackgroundTransparency = 0.08,

	BorderSizePixel = 0,

	ZIndex = 1
}, ScreenGui)

local BackgroundGradient = New("UIGradient", {
	Rotation = 35,

	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(22, 8, 38)
		),

		ColorSequenceKeypoint.new(
			0.5,
			Color3.fromRGB(5, 3, 10)
		),

		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(27, 7, 45)
		)
	})
}, Background)

--==================================================
-- FLASHING STARS
--==================================================

local StarContainer = New("Frame", {
	Name = "Stars",

	Size = UDim2.fromScale(1, 1),

	BackgroundTransparency = 1,

	ClipsDescendants = true,

	ZIndex = 2
}, Background)

local Stars = {}

for i = 1, 85 do

	local size = math.random(1, 3)

	local star = New("Frame", {
		Size = UDim2.fromOffset(
			size,
			size
		),

		Position = UDim2.fromScale(
			math.random(),
			math.random()
		),

		BackgroundColor3 =
			Color3.fromRGB(
				220,
				195,
				255
			),

		BackgroundTransparency =
			math.random(20, 90) / 100,

		BorderSizePixel = 0,

		ZIndex = 2
	}, StarContainer)

	Corner(star, size)

	table.insert(Stars, star)
end

for _, star in ipairs(Stars) do

	task.spawn(function()

		while star.Parent do

			local fadeTime =
				math.random(5, 15) / 10

			Tween(
				star,
				{
					BackgroundTransparency =
						math.random(15, 55) / 100
				},
				fadeTime,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			):Play()

			task.wait(fadeTime)

			Tween(
				star,
				{
					BackgroundTransparency =
						math.random(65, 95) / 100
				},
				fadeTime,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			):Play()

			task.wait(
				fadeTime +
				math.random(1, 15) / 10
			)
		end

	end)

end

--==================================================
-- MOUSE SNOWFLAKE TRAIL
--==================================================

local SnowflakeContainer = New("Frame", {
	Name = "MouseSnowflakes",

	Size = UDim2.fromScale(1, 1),

	BackgroundTransparency = 1,

	ClipsDescendants = true,

	ZIndex = 5
}, ScreenGui)

local function CreateSnowflake(position)

	local size = math.random(3, 6)

	local snowflake = New("TextLabel", {

		Size = UDim2.fromOffset(
			size * 3,
			size * 3
		),

		AnchorPoint =
			Vector2.new(0.5, 0.5),

		Position = position,

		BackgroundTransparency = 1,

		Text = "✦",

		TextColor3 = PURPLE_LIGHT,

		TextTransparency = 0.15,

		TextSize = size * 2,

		Font = Enum.Font.GothamBold,

		ZIndex = 5

	}, SnowflakeContainer)

	Tween(
		snowflake,
		{
			Position = UDim2.fromOffset(
				position.X.Offset +
					math.random(-18, 18),

				position.Y.Offset -
					math.random(15, 35)
			),

			TextTransparency = 1,

			Rotation =
				math.random(-120, 120)
		},
		0.7,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out
	):Play()

	task.delay(0.75, function()

		if snowflake then
			snowflake:Destroy()
		end

	end)
end

local lastMousePosition =
	UserInputService:GetMouseLocation()

local snowflakeTimer = 0

RunService.RenderStepped:Connect(function(deltaTime)

	local currentMouse =
		UserInputService:GetMouseLocation()

	local distance =
		(currentMouse - lastMousePosition).Magnitude

	snowflakeTimer += deltaTime

	if distance > 3
		and snowflakeTimer >= 0.035
	then

		CreateSnowflake(
			UDim2.fromOffset(
				currentMouse.X,
				currentMouse.Y
			)
		)

		snowflakeTimer = 0
	end

	lastMousePosition = currentMouse
end)

--==================================================
-- BLUR
--==================================================

local Blur = New("BlurEffect", {
	Name = "DarkGlassBlur",

	Size = 12
}, Lighting)

--==================================================
-- MAIN WINDOW
--==================================================

local Main = New("Frame", {

	Name = "Main",

	Size = UDim2.fromOffset(
		GUI_WIDTH,
		GUI_HEIGHT
	),

	Position = UDim2.fromScale(
		0.5,
		0.5
	),

	AnchorPoint = Vector2.new(
		0.5,
		0.5
	),

	BackgroundColor3 =
		Color3.fromRGB(
			9,
			6,
			15
		),

	BackgroundTransparency = 0.04,

	BorderSizePixel = 0,

	ZIndex = 10

}, ScreenGui)

Corner(Main, 20)

Stroke(Main, 0.72, 1)

--==================================================
-- TOP HIGHLIGHT
--==================================================

local TopHighlight = New("Frame", {

	Size = UDim2.new(
		1,
		-40,
		0,
		1
	),

	Position = UDim2.fromOffset(
		20,
		1
	),

	BackgroundColor3 =
		Color3.fromRGB(
			195,
			140,
			255
		),

	BackgroundTransparency = 0.5,

	BorderSizePixel = 0,

	ZIndex = 11

}, Main)

Corner(TopHighlight, 1)

--==================================================
-- TOP BAR
--==================================================

local TopBar = New("Frame", {

	Size = UDim2.new(
		1,
		-30,
		0,
		62
	),

	Position = UDim2.fromOffset(
		15,
		10
	),

	BackgroundTransparency = 1,

	ZIndex = 12

}, Main)

local Title = New("TextLabel", {

	Size = UDim2.fromOffset(
		400,
		27
	),

	Position = UDim2.fromOffset(
		8,
		3
	),

	BackgroundTransparency = 1,

	Text = "DARK GLASS",

	TextColor3 =
		Color3.fromRGB(
			245,
			238,
			250
		),

	TextSize = 20,

	Font = Enum.Font.GothamBold,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 13

}, TopBar)

local Subtitle = New("TextLabel", {

	Size = UDim2.fromOffset(
		400,
		20
	),

	Position = UDim2.fromOffset(
		9,
		30
	),

	BackgroundTransparency = 1,

	Text = "CONTROL CENTER",

	TextColor3 =
		Color3.fromRGB(
			145,
			125,
			165
		),

	TextSize = 9,

	Font = Enum.Font.GothamMedium,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 13

}, TopBar)

--==================================================
-- CLOSE BUTTON
--==================================================

local Close = New("TextButton", {

	Size = UDim2.fromOffset(
		34,
		34
	),

	Position = UDim2.new(
		1,
		-34,
		0,
		7
	),

	BackgroundColor3 =
		Color3.fromRGB(
			145,
			45,
			175
		),

	BackgroundTransparency = 0.2,

	BorderSizePixel = 0,

	Text = "×",

	TextColor3 =
		Color3.fromRGB(
			255,
			245,
			255
		),

	TextSize = 20,

	Font = Enum.Font.GothamBold,

	AutoButtonColor = false,

	ZIndex = 15

}, TopBar)

Corner(Close, 9)

--==================================================
-- BODY
--==================================================

local Body = New("Frame", {

	Size = UDim2.new(
		1,
		-30,
		1,
		-82
	),

	Position = UDim2.fromOffset(
		15,
		72
	),

	BackgroundTransparency = 1,

	ZIndex = 12

}, Main)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = New("Frame", {

	Size = UDim2.new(
		0,
		175,
		1,
		0
	),

	Position = UDim2.fromOffset(
		0,
		0
	),

	BackgroundColor3 =
		Color3.fromRGB(
			16,
			10,
			24
		),

	BackgroundTransparency = 0.1,

	BorderSizePixel = 0,

	ZIndex = 13

}, Body)

Corner(Sidebar, 15)

Stroke(Sidebar, 0.91, 1)

--==================================================
-- CONTENT
--==================================================

local Content = New("Frame", {

	Size = UDim2.new(
		1,
		-190,
		1,
		0
	),

	Position = UDim2.fromOffset(
		190,
		0
	),

	BackgroundTransparency = 1,

	ClipsDescendants = true,

	ZIndex = 13

}, Body)

--==================================================
-- TABS
--==================================================

local TabNames = {
	"Home",
	"Players",
	"Visuals",
	"Misc",
	"Settings"
}

local TabButtons = {}
local Pages = {}

for index, name in ipairs(TabNames) do

	--==================================================
	-- TAB BUTTON
	--==================================================

	local button = New("TextButton", {

		-- Move the entire button away from the left edge
		Size = UDim2.new(
			1,
			-32,
			0,
			43
		),

		Position = UDim2.fromOffset(
			22,
			12 + ((index - 1) * 50)
		),

		BackgroundColor3 = PURPLE,

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		Text = name,

		TextColor3 =
			Color3.fromRGB(
				145,
				135,
				160
			),

		TextSize = 12,

		Font = Enum.Font.GothamMedium,

		-- Text is positioned naturally inside the button
		TextXAlignment =
			Enum.TextXAlignment.Left,

		AutoButtonColor = false,

		ZIndex = 15

	}, Sidebar)

	Corner(button, 10)

	-- Give the text its own safe space
	New("UIPadding", {

		PaddingLeft =
			UDim.new(0, 16)

	}, button)

	--==================================================
	-- ACTIVE INDICATOR
	--==================================================
	-- IMPORTANT:
	-- This is a SIBLING of the button, not a child.
	-- Therefore it can NEVER overlap the text.

	local indicator = New("Frame", {

		Size = UDim2.fromOffset(
			3,
			18
		),

		Position = UDim2.new(
			0,
			8,
			0,
			25 + ((index - 1) * 50)
		),

		BackgroundColor3 =
			PURPLE_LIGHT,

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		ZIndex = 20

	}, Sidebar)

	Corner(indicator, 3)

	TabButtons[name] = {
		Button = button,
		Indicator = indicator
	}

	--==================================================
	-- PAGE
	--==================================================

	local page = New("Frame", {

		Name = name,

		Size = UDim2.fromScale(
			1,
			1
		),

		BackgroundTransparency = 1,

		Visible = false,

		ZIndex = 14

	}, Content)

	Pages[name] = page
end

--==================================================
-- PAGE TITLE
--==================================================

local function PageTitle(
	page,
	title,
	description
)

	New("TextLabel", {

		Size = UDim2.new(
			1,
			-20,
			0,
			28
		),

		Position = UDim2.fromOffset(
			10,
			7
		),

		BackgroundTransparency = 1,

		Text = title,

		TextColor3 =
			Color3.fromRGB(
				245,
				240,
				250
			),

		TextSize = 21,

		Font = Enum.Font.GothamBold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex = 15

	}, page)

	New("TextLabel", {

		Size = UDim2.new(
			1,
			-20,
			0,
			22
		),

		Position = UDim2.fromOffset(
			10,
			35
		),

		BackgroundTransparency = 1,

		Text = description,

		TextColor3 =
			Color3.fromRGB(
				135,
				120,
				150
			),

		TextSize = 10,

		Font = Enum.Font.GothamMedium,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex = 15

	}, page)
end

--==================================================
-- CARD
--==================================================

local function CreateCard(
	page,
	position,
	size
)

	local card = New("Frame", {

		Size = size,

		Position = position,

		BackgroundColor3 =
			Color3.fromRGB(
				18,
				11,
				27
			),

		BackgroundTransparency = 0.08,

		BorderSizePixel = 0,

		ZIndex = 15

	}, page)

	Corner(card, 13)

	Stroke(card, 0.91, 1)

	return card
end

--==================================================
-- HOME
--==================================================

local Home = Pages.Home

PageTitle(
	Home,
	"Welcome",
	"Your dark glass control center."
)

local Welcome = CreateCard(
	Home,
	UDim2.fromOffset(
		10,
		72
	),
	UDim2.new(
		1,
		-20,
		0,
		115
	)
)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-30,
		0,
		25
	),

	Position = UDim2.fromOffset(
		15,
		14
	),

	BackgroundTransparency = 1,

	Text = "DARK GLASS",

	TextColor3 =
		Color3.fromRGB(
			235,
			220,
			255
		),

	TextSize = 15,

	Font = Enum.Font.GothamBold,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, Welcome)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-30,
		0,
		45
	),

	Position = UDim2.fromOffset(
		15,
		44
	),

	BackgroundTransparency = 1,

	Text =
		"A clean purple and black interface with subtle animated stars and glass effects.",

	TextColor3 =
		Color3.fromRGB(
			145,
			130,
			160
		),

	TextSize = 11,

	Font = Enum.Font.GothamMedium,

	TextWrapped = true,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	TextYAlignment =
		Enum.TextYAlignment.Top,

	ZIndex = 16

}, Welcome)

--==================================================
-- PLAYERS
--==================================================

local PlayersPage = Pages.Players

PageTitle(
	PlayersPage,
	"Players",
	"Player management."
)

local PlayersCard = CreateCard(
	PlayersPage,
	UDim2.fromOffset(
		10,
		72
	),
	UDim2.new(
		1,
		-20,
		0,
		100
	)
)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-30,
		0,
		25
	),

	Position = UDim2.fromOffset(
		15,
		14
	),

	BackgroundTransparency = 1,

	Text = "PLAYER SYSTEM",

	TextColor3 =
		Color3.fromRGB(
			235,
			220,
			255
		),

	TextSize = 14,

	Font = Enum.Font.GothamBold,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, PlayersCard)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-30,
		0,
		30
	),

	Position = UDim2.fromOffset(
		15,
		44
	),

	BackgroundTransparency = 1,

	Text =
		"Player functionality can be added here.",

	TextColor3 =
		Color3.fromRGB(
			140,
			125,
			155
		),

	TextSize = 10,

	Font = Enum.Font.GothamMedium,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, PlayersCard)

--==================================================
-- VISUALS
--==================================================

local Visuals = Pages.Visuals

PageTitle(
	Visuals,
	"Visuals",
	"Visual controls and effects."
)

local VisualCard = CreateCard(
	Visuals,
	UDim2.fromOffset(
		10,
		72
	),
	UDim2.new(
		1,
		-20,
		0,
		100
	)
)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-30,
		0,
		25
	),

	Position = UDim2.fromOffset(
		15,
		14
	),

	BackgroundTransparency = 1,

	Text = "VISUAL SYSTEM",

	TextColor3 =
		Color3.fromRGB(
			235,
			220,
			255
		),

	TextSize = 14,

	Font = Enum.Font.GothamBold,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, VisualCard)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-30,
		0,
		30
	),

	Position = UDim2.fromOffset(
		15,
		44
	),

	BackgroundTransparency = 1,

	Text =
		"Visual features can be added here.",

	TextColor3 =
		Color3.fromRGB(
			140,
			125,
			155
		),

	TextSize = 10,

	Font = Enum.Font.GothamMedium,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, VisualCard)

--==================================================
-- MISC
--==================================================

local Misc = Pages.Misc

PageTitle(
	Misc,
	"Misc",
	"Additional options."
)

local MiscCard = CreateCard(
	Misc,
	UDim2.fromOffset(
		10,
		72
	),
	UDim2.new(
		1,
		-20,
		0,
		100
	)
)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-30,
		0,
		25
	),

	Position = UDim2.fromOffset(
		15,
		14
	),

	BackgroundTransparency = 1,

	Text = "MISCELLANEOUS",

	TextColor3 =
		Color3.fromRGB(
			235,
			220,
			255
		),

	TextSize = 14,

	Font = Enum.Font.GothamBold,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, MiscCard)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-30,
		0,
		30
	),

	Position = UDim2.fromOffset(
		15,
		44
	),

	BackgroundTransparency = 1,

	Text =
		"Additional options can be placed here.",

	TextColor3 =
		Color3.fromRGB(
			140,
			125,
			155
		),

	TextSize = 10,

	Font = Enum.Font.GothamMedium,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, MiscCard)

--==================================================
-- SETTINGS
--==================================================

local Settings = Pages.Settings

PageTitle(
	Settings,
	"Settings",
	"Customize your interface."
)

--==================================================
-- KEYBIND CARD
--==================================================

local KeybindCard = CreateCard(
	Settings,
	UDim2.fromOffset(
		10,
		72
	),
	UDim2.new(
		1,
		-20,
		0,
		105
	)
)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-165,
		0,
		23
	),

	Position = UDim2.fromOffset(
		15,
		14
	),

	BackgroundTransparency = 1,

	Text = "Toggle Keybind",

	TextColor3 =
		Color3.fromRGB(
			235,
			220,
			255
		),

	TextSize = 14,

	Font = Enum.Font.GothamBold,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, KeybindCard)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-165,
		0,
		35
	),

	Position = UDim2.fromOffset(
		15,
		43
	),

	BackgroundTransparency = 1,

	Text =
		"Change the keyboard key used to open or close the menu.",

	TextColor3 =
		Color3.fromRGB(
			140,
			125,
			155
		),

	TextSize = 10,

	Font = Enum.Font.GothamMedium,

	TextWrapped = true,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	TextYAlignment =
		Enum.TextYAlignment.Top,

	ZIndex = 16

}, KeybindCard)

local KeybindButton = New("TextButton", {

	Size = UDim2.fromOffset(
		115,
		38
	),

	Position = UDim2.new(
		1,
		-130,
		0.5,
		-19
	),

	BackgroundColor3 = PURPLE,

	BackgroundTransparency = 0.18,

	BorderSizePixel = 0,

	Text = ToggleKey.Name,

	TextColor3 =
		Color3.fromRGB(
			255,
			250,
			255
		),

	TextSize = 11,

	Font = Enum.Font.GothamBold,

	AutoButtonColor = false,

	ZIndex = 17

}, KeybindCard)

Corner(KeybindButton, 9)

--==================================================
-- SHOW HOTKEYS CARD
--==================================================

local HotkeyCard = CreateCard(
	Settings,
	UDim2.fromOffset(
		10,
		188
	),
	UDim2.new(
		1,
		-20,
		0,
		78
	)
)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-100,
		0,
		23
	),

	Position = UDim2.fromOffset(
		15,
		13
	),

	BackgroundTransparency = 1,

	Text = "Show Hotkeys",

	TextColor3 =
		Color3.fromRGB(
			235,
			220,
			255
		),

	TextSize = 14,

	Font = Enum.Font.GothamBold,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, HotkeyCard)

New("TextLabel", {

	Size = UDim2.new(
		1,
		-100,
		0,
		20
	),

	Position = UDim2.fromOffset(
		15,
		40
	),

	BackgroundTransparency = 1,

	Text =
		"Display the current menu keybind.",

	TextColor3 =
		Color3.fromRGB(
			140,
			125,
			155
		),

	TextSize = 10,

	Font = Enum.Font.GothamMedium,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 16

}, HotkeyCard)

local HotkeyToggle = New("TextButton", {

	Size = UDim2.fromOffset(
		48,
		26
	),

	Position = UDim2.new(
		1,
		-63,
		0.5,
		-13
	),

	BackgroundColor3 = PURPLE,

	BackgroundTransparency = 0.15,

	BorderSizePixel = 0,

	Text = "",

	AutoButtonColor = false,

	ZIndex = 17

}, HotkeyCard)

Corner(HotkeyToggle, 13)

local ToggleCircle = New("Frame", {

	Size = UDim2.fromOffset(
		20,
		20
	),

	Position = UDim2.new(
		1,
		-23,
		0.5,
		-10
	),

	BackgroundColor3 =
		Color3.fromRGB(
			255,
			255,
			255
		),

	BorderSizePixel = 0,

	ZIndex = 18

}, HotkeyToggle)

Corner(ToggleCircle, 20)

--==================================================
-- GUI STATE
--==================================================

local GUIVisible = true

--==================================================
-- HOTKEY DISPLAY
--==================================================

local HotkeyDisplay = New("Frame", {

	Name = "HotkeyDisplay",

	Size = UDim2.fromOffset(
		155,
		36
	),

	AnchorPoint = Vector2.new(
		1,
		0
	),

	-- Top-right, with some space from the edge
	Position = UDim2.new(
		1,
		-20,
		0,
		24
	),

	BackgroundColor3 =
		Color3.fromRGB(
			15,
			9,
			23
		),

	BackgroundTransparency = 0.08,

	BorderSizePixel = 0,

	Visible = ShowHotkeys and not GUIVisible,

	ZIndex = 50

}, ScreenGui)

Corner(HotkeyDisplay, 10)

Stroke(
	HotkeyDisplay,
	0.88,
	1
)

local HotkeyText = New("TextLabel", {

	Size = UDim2.new(
		1,
		-16,
		1,
		0
	),

	Position = UDim2.fromOffset(
		8,
		0
	),

	BackgroundTransparency = 1,

	Text =
		"MENU  •  " .. ToggleKey.Name,

	TextColor3 =
		Color3.fromRGB(
			195,
			175,
			220
		),

	TextSize = 10,

	Font = Enum.Font.GothamMedium,

	TextXAlignment =
		Enum.TextXAlignment.Center,

	ZIndex = 51

}, HotkeyDisplay)

--==================================================
-- HOTKEY DISPLAY UPDATE
--==================================================

local function UpdateHotkeyDisplay()

	HotkeyText.Text =
		"MENU  •  " .. ToggleKey.Name

	HotkeyDisplay.Visible =
		ShowHotkeys and not GUIVisible

	if ShowHotkeys then

		Tween(
			ToggleCircle,
			{
				Position = UDim2.new(
					1,
					-23,
					0.5,
					-10
				)
			},
			0.2
		):Play()

	else

		Tween(
			ToggleCircle,
			{
				Position = UDim2.new(
					0,
					3,
					0.5,
					-10
				)
			},
			0.2
		):Play()

	end
end

--==================================================
-- SHOW HOTKEYS TOGGLE
--==================================================

HotkeyToggle.MouseButton1Click:Connect(function()

	ShowHotkeys = not ShowHotkeys

	if ShowHotkeys then

		Tween(
			HotkeyToggle,
			{
				BackgroundColor3 = PURPLE
			},
			0.2
		):Play()

	else

		Tween(
			HotkeyToggle,
			{
				BackgroundColor3 =
					Color3.fromRGB(
						60,
						50,
						70
					)
			},
			0.2
		):Play()

	end

	UpdateHotkeyDisplay()
end)

--==================================================
-- TAB SYSTEM
--==================================================

local ActiveTab = nil

local function SelectTab(name)

	ActiveTab = name

	for tabName, data in pairs(TabButtons) do

		local active =
			tabName == name

		Tween(
			data.Button,
			{
				BackgroundTransparency =
					active and 0.84 or 1,

				TextColor3 =
					active
					and Color3.fromRGB(
						235,
						220,
						255
					)
					or Color3.fromRGB(
						145,
						135,
						160
					)
			},
			0.2
		):Play()

		Tween(
			data.Indicator,
			{
				BackgroundTransparency =
					active and 0 or 1
			},
			0.2
		):Play()
	end

	for pageName, page in pairs(Pages) do

		page.Visible =
			pageName == name
	end
end

for name, data in pairs(TabButtons) do

	data.Button.MouseButton1Click:Connect(function()
		SelectTab(name)
	end)

	data.Button.MouseEnter:Connect(function()

		if ActiveTab ~= name then

			Tween(
				data.Button,
				{
					BackgroundTransparency = 0.94
				},
				0.15
			):Play()

		end
	end)

	data.Button.MouseLeave:Connect(function()

		if ActiveTab ~= name then

			Tween(
				data.Button,
				{
					BackgroundTransparency = 1
				},
				0.15
			):Play()

		end
	end)
end

SelectTab("Home")

--==================================================
-- KEYBIND CHANGING
--==================================================

local ListeningForKey = false

KeybindButton.MouseButton1Click:Connect(function()

	if ListeningForKey then
		return
	end

	ListeningForKey = true

	KeybindButton.Text = "PRESS KEY"

	Tween(
		KeybindButton,
		{
			BackgroundTransparency = 0
		},
		0.2
	):Play()
end)

--==================================================
-- GUI TOGGLE
--==================================================

local function SetGUIVisible(visible)

	GUIVisible = visible

	if visible then

		Main.Visible = true
		Background.Visible = true

		-- Hide hotkey while GUI is open
		HotkeyDisplay.Visible = false

		Tween(
			Main,
			{
				Size = UDim2.fromOffset(
					GUI_WIDTH,
					GUI_HEIGHT
				),

				BackgroundTransparency = 0.04
			},
			0.4
		):Play()

		Tween(
			Blur,
			{
				Size = 12
			},
			0.35
		):Play()

	else

		Tween(
			Main,
			{
				Size = UDim2.fromOffset(
					GUI_WIDTH,
					0
				),

				BackgroundTransparency = 1
			},
			0.3,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.In
		):Play()

		Tween(
			Blur,
			{
				Size = 0
			},
			0.3
		):Play()

		-- Show hotkey immediately when GUI closes
		HotkeyDisplay.Visible =
			ShowHotkeys

		task.delay(0.3, function()

			if not GUIVisible then

				Main.Visible = false
				Background.Visible = false

				HotkeyDisplay.Visible =
					ShowHotkeys
			end

		end)
	end
end

--==================================================
-- INPUT
--==================================================

UserInputService.InputBegan:Connect(function(
	input,
	gameProcessed
)

	if gameProcessed then
		return
	end

	-- Rebinding
	if ListeningForKey then

		if input.UserInputType ==
			Enum.UserInputType.Keyboard then

			if input.KeyCode ~=
				Enum.KeyCode.Unknown then

				ToggleKey =
					input.KeyCode

				KeybindButton.Text =
					ToggleKey.Name

				ListeningForKey = false

				UpdateHotkeyDisplay()

				Tween(
					KeybindButton,
					{
						BackgroundTransparency =
							0.18
					},
					0.2
				):Play()
			end
		end

		return
	end

	-- Toggle menu
	if input.UserInputType ==
		Enum.UserInputType.Keyboard then

		if input.KeyCode ==
			ToggleKey then

			SetGUIVisible(
				not GUIVisible
			)
		end
	end
end)

--==================================================
-- CLOSE BUTTON
--==================================================

Close.MouseButton1Click:Connect(function()

	GUIVisible = false

	HotkeyDisplay.Visible =
		ShowHotkeys

	Tween(
		Main,
		{
			Size = UDim2.fromOffset(
				GUI_WIDTH,
				0
			),

			BackgroundTransparency = 1
		},
		0.35,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.In
	):Play()

	Tween(
		Blur,
		{
			Size = 0
		},
		0.3
	):Play()

	task.delay(0.4, function()

		if Blur then
			Blur:Destroy()
		end

		if ScreenGui then

			-- Keep only the hotkey alive after closing
			Background:Destroy()
			Main:Destroy()
			SnowflakeContainer:Destroy()

		end
	end)
end)

--==================================================
-- HOVER EFFECTS
--==================================================

local function Hover(
	button,
	normal,
	hover
)

	button.MouseEnter:Connect(function()

		Tween(
			button,
			{
				BackgroundTransparency =
					hover
			},
			0.15
		):Play()
	end)

	button.MouseLeave:Connect(function()

		Tween(
			button,
			{
				BackgroundTransparency =
					normal
			},
			0.15
		):Play()
	end)
end

Hover(
	Close,
	0.2,
	0.05
)

Hover(
	KeybindButton,
	0.18,
	0.05
)

--==================================================
-- INITIALIZE HOTKEY SWITCH
--==================================================

if ShowHotkeys then

	HotkeyToggle.BackgroundColor3 =
		PURPLE

	ToggleCircle.Position =
		UDim2.new(
			1,
			-23,
			0.5,
			-10
		)

else

	HotkeyToggle.BackgroundColor3 =
		Color3.fromRGB(
			60,
			50,
			70
		)

	ToggleCircle.Position =
		UDim2.new(
			0,
			3,
			0.5,
			-10
		)
end

--==================================================
-- INITIALIZE
--==================================================

Main.Size = UDim2.fromOffset(
	GUI_WIDTH,
	0
)

HotkeyDisplay.Visible = false

Tween(
	Main,
	{
		Size = UDim2.fromOffset(
			GUI_WIDTH,
			GUI_HEIGHT
		)
	},
	0.55
):Play()

print("[DarkGlassUI] Loaded")
print("[DarkGlassUI] Toggle:", ToggleKey.Name)