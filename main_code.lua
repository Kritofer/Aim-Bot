if AIM_LOADED then
	return
end
pcall(function() getgenv().AIM_LOADED = true end)

local wait, spawn = task.wait, task.spawn

local Localplayer = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local mouse = Localplayer:GetMouse()
local Camera = workspace.CurrentCamera
local espying = true
local spydown = 0.05
local CanAim = false
local fov = 100
local CLR = Color3.new(1,1,1)
local max = 300
local walkspeed = 20
local shooting = {}
local enabledaim = true
local shootteam = false
local advanced = true
local fovoutline = true
local screengui = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or Instance.new("ScreenGui", game:GetService("CoreGui"))
local offset = 0
local functions = {function() UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then CanAim = false end end) UIS.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then CanAim = true shootnearest() end end)end}

functions[1]()

function int(args: {any})
	for _, item in args do
		if typeof(item) == "boolean" then
			if item then
				return 1
			else
				return 0
			end
		end
	end
end

keys = {
	A = false,
	S = false,
	D = false,
	W = false
}

UIS.InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.A then keys.A = true end
	if key.KeyCode == Enum.KeyCode.S then keys.S = true end
	if key.KeyCode == Enum.KeyCode.D then keys.D = true end
	if key.KeyCode == Enum.KeyCode.W then keys.W = true end
end)

UIS.InputEnded:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.A then keys.A = false end
	if key.KeyCode == Enum.KeyCode.S then keys.S = false end
	if key.KeyCode == Enum.KeyCode.D then keys.D = false end
	if key.KeyCode == Enum.KeyCode.W then keys.W = false end
end)

RS.Stepped:Connect(function()
	if enabledaim then
		if CanAim then
			shootnearest()
		end
		if Localplayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping or Localplayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then return end
		if keys.D or keys.A then
			Localplayer.Character.HumanoidRootPart.Velocity += (Localplayer.Character.HumanoidRootPart.CFrame.RightVector * walkspeed) * (int({keys.D}) - int({keys.A}))
		else
			Localplayer.Character.HumanoidRootPart.Velocity += (Localplayer.Character.HumanoidRootPart.CFrame.LookVector * walkspeed) * (int({keys.W}) - int({keys.S}))
		end
	end
end)

function shootnearest()
	table.clear(shooting)
	for _,player in game.Players:GetPlayers() do
		if player == Localplayer then continue end
		if player.Character and player.Character:FindFirstChild("Head") then
			local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(Camera:WorldToScreenPoint(player.Character.Head.Position).X, Camera:WorldToScreenPoint(player.Character.Head.Position).Y)).Magnitude
			if advanced then if ((Localplayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude > max) then continue end end
			shooting[distance] = player
		end
	end
	local shortest = math.huge
	for distance, player in shooting do
		local check = (player.Team ~= Localplayer.Team)
		if player.Team == nil then check = true end
		if shootteam then check = true end 
		if distance < shortest and check then
			if player.Character.Humanoid.Health == 0 then continue end
			local ray = Ray.new(Camera.CFrame.Position, (player.Character.Head.Position - Camera.CFrame.Position).Unit * 200)
			local part = workspace:FindPartOnRayWithIgnoreList(ray, {Localplayer.Character})
			if part and (part:IsDescendantOf(player.Character) or not part.CanCollide) then
				shortest = distance
			end
		end
	end
	if shortest <= fov and shortest >= 0 then
		shoot(shooting[shortest])
	end
end

function shoot(player: Player)
	local lookto = CFrame.lookAt(Camera.CFrame.Position, player.Character.Head.Position)
	if advanced then
		local distance = ((Localplayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position) / (max * 1.2)).Magnitude / 2
		local vel = (player.Character.HumanoidRootPart.Velocity * (0.20 + (Localplayer:GetNetworkPing() * (5 + distance))))
		local vel = Vector3.new(vel.x, vel.y / 6, vel.z)
		lookto = CFrame.lookAt(Camera.CFrame.Position, player.Character.HumanoidRootPart.Position + vel)
	end
	Camera.CFrame = lookto
end

function esp(char: Model)
	local player = game.Players:GetPlayerFromCharacter(char)
	local newpart = Instance.new("Frame")
	local gui = char:FindFirstChild("Esp-Decal") or Instance.new("BillboardGui")
	for _, part in gui:GetChildren() do part:Destroy() end
	gui.Parent = screengui
	-- esp's the player's head --
	gui.Name = "Esp-Decal"
	gui.Size = UDim2.new(1,0,1,0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.MaxDistance = 1000
	gui.SizeOffset = Vector2.new(0,0)
	gui.ExtentsOffset = Vector3.new(0,0,0)
	gui.Adornee = char:FindFirstChild("Head") or char:WaitForChild("Head")
	gui.Active = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ResetOnSpawn = false
	gui.ClipsDescendants = false
	newpart.Parent = gui
	newpart.ZIndex = 9999
	newpart.Size = UDim2.new(1,0,1,0)
	newpart.BorderColor3 = CLR
	newpart.BackgroundColor3 = CLR
	spawn(function()
		while player.Character do
			if Localplayer.Team == player.Team and Localplayer.Team ~= nil then newpart.Transparency = 1 else newpart.Transparency = 0.5 end
			task.wait(2)
		end
	end)
end

function temp_esp(char: Model)
	local player = game.Players:GetPlayerFromCharacter(char)
	if not player then return end
	if not char.Head then return end
	local new = Instance.new("Frame")
	local dist = (Localplayer.Character.Position - char.Position).Magnitude
	new.Name = "Esp-Temp"
	new.Size = UDim2.new(0, 10, 0, 10)
	new.BorderColor3 = CLR
	new.BackgroundColor3 = CLR
	new.Parent = screengui
	new.ZIndex = 9999
	new.Size = UDim2.fromOffset(100/dist, 100/dist)
	new.Position = UDim2.new(0, Camera:WorldToScreenPoint(char.Head.Position).X, 0, Camera:WorldToScreenPoint(char.Head.Position).Y)
	if Localplayer.Team == player.Team and Localplayer.Team ~= nil then new.Transparency = 1 else new.Transparency = 0.5 end
	game.Debris:AddItem(new, spydown)
end

function drawCircle(fov, color)
	local radius = fov
	local segments = fov*2
	local increment = math.pi*2/segments
	local points = {}
	for i = 0, math.pi*2, increment do
		local x = math.cos(i)*radius
		local y = math.sin(i)*radius
		table.insert(points, Vector2.new(x,y))
	end
	for _, GuiItem in screengui:GetDescendants() do
		if GuiItem:IsA("Frame") and GuiItem.Name == "FovOutLine" then
			GuiItem:Destroy()
		end
	end
	for i = 1, #points do
		local p1 = points[i]
		local line = Instance.new("Frame")
		local size = math.clamp((fov / 100)*3, 2.5, 5)
		line.Size = UDim2.new(0, size, 0, size)
		line.Position = UDim2.new(p1.X/screengui.AbsoluteSize.X, mouse.X, p1.Y/screengui.AbsoluteSize.Y, mouse.Y)
		line.BackgroundColor3 = color
		line.BorderSizePixel = 0
		line.Parent = screengui
		line.Name = "FovOutLine"
	end
	screengui.Changed:Connect(function()
		for _, GuiItem in screengui:GetDescendants() do
			if GuiItem:IsA("Frame") and GuiItem.Name == "FovOutLine" then
				GuiItem:Destroy()
			end
		end
		for i = 1, #points do
			local p1 = points[i]
			local line = Instance.new("Frame")
			local size = math.clamp((fov / 100)*3, 2.5, 5)
			line.Size = UDim2.new(0, size, 0, size)
			line.Position = UDim2.new(p1.X/screengui.AbsoluteSize.X, mouse.X, p1.Y/screengui.AbsoluteSize.Y, mouse.Y)
			line.BackgroundColor3 = color
			line.BorderSizePixel = 0
			line.Parent = screengui
			line.Name = "FovOutLine"
		end
	end)
end

function drawDot(color)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 5, 0, 5)
	dot.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	dot.BackgroundColor3 = color
	dot.BorderSizePixel = 0
	dot.Parent = screengui
	dot.Name = "FovOutLine-Dot"
end

function drawMain(CLR)
	local main = Instance.new("Frame")
	main.Name = "main"
	main.Size = UDim2.new(0.00, 276.00, 0.00, 383.00)
	main.BorderColor3 = CLR
	main.Position = UDim2.new(0.38, 0.00, 0.18, 0.00)
	main.BackgroundColor3 = Color3.new(0.16, 0.16, 0.16)
	main.Parent = screengui

	local name = Instance.new("TextLabel")
	name.Name = "name"
	name.TextWrapped = true
	name.TextScaled = true
	name.BackgroundColor3 = Color3.new(0.24, 0.24, 0.24)
	name.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
	name.TextSize = 20
	name.Size = UDim2.new(0.85, 0.00, 0.07, 0.00)
	name.BorderColor3 = CLR
	name.Text = "Kritofer's hub"
	name.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	name.Parent = main

	local exit = Instance.new("TextButton")
	exit.Name = "exit"
	exit.BackgroundColor3 = Color3.new(0.55, 0.00, 0.00)
	exit.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	exit.TextSize = 20
	exit.Size = UDim2.new(0.00, 41.00, 0.07, 0.00)
	exit.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	exit.BorderColor3 = CLR
	exit.Text = "X"
	exit.Position = UDim2.new(0.85, 0.00, 0.00, 0.00)
	exit.Parent = main

	local ENABLED = Instance.new("BoolValue")
	ENABLED.Name = "ENABLED"
	ENABLED.Value = true
	ENABLED.Parent = main

	local FOVOUTLINE = Instance.new("BoolValue")
	FOVOUTLINE.Name = "FOVOUTLINE"
	FOVOUTLINE.Value = true
	FOVOUTLINE.Parent = main

	local Enabled = Instance.new("TextButton")
	Enabled.Name = "Enabled"
	Enabled.BackgroundColor3 = Color3.new(0.24, 0.24, 0.24)
	Enabled.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Enabled.TextSize = 14
	Enabled.Size = UDim2.new(0.10, 0.00, 0.08, 0.00)
	Enabled.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	Enabled.BorderColor3 = CLR
	Enabled.Text = "✓"
	Enabled.Position = UDim2.new(0.06, 0.00, 0.12, 0.00)
	Enabled.Parent = main

	local tagE = Instance.new("TextLabel")
	tagE.Name = "tagE"
	tagE.TextWrapped = true
	tagE.TextScaled = true
	tagE.BackgroundColor3 = Color3.new(0.24, 0.24, 0.24)
	tagE.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
	tagE.TextSize = 14
	tagE.Size = UDim2.new(6.99, 0.00, 0.97, 0.00)
	tagE.BorderColor3 = CLR
	tagE.Text = "Enabled"
	tagE.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	tagE.Position = UDim2.new(1.70, 0.00, 0.00, 0.00)
	tagE.Parent = Enabled

	local FovOutline = Instance.new("TextButton")
	FovOutline.Name = "FovOutline"
	FovOutline.BackgroundColor3 = Color3.new(0.24, 0.24, 0.24)
	FovOutline.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	FovOutline.TextSize = 14
	FovOutline.Size = UDim2.new(0.10, 0.00, 0.08, 0.00)
	FovOutline.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	FovOutline.BorderColor3 = CLR
	FovOutline.Text = "✓"
	FovOutline.Position = UDim2.new(0.06, 0.00, 0.22, 0.00)
	FovOutline.Parent = main

	local tagFO = Instance.new("TextLabel")
	tagFO.Name = "tagFO"
	tagFO.TextWrapped = true
	tagFO.TextScaled = true
	tagFO.BackgroundColor3 = Color3.new(0.24, 0.24, 0.24)
	tagFO.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
	tagFO.TextSize = 14
	tagFO.Size = UDim2.new(6.99, 0.00, 0.98, 0.00)
	tagFO.BorderColor3 = CLR
	tagFO.Text = "FovOutline"
	tagFO.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	tagFO.Position = UDim2.new(1.70, 0.00, 0.00, 0.00)
	tagFO.Parent = FovOutline

	local FovChanger = Instance.new("Frame")
	FovChanger.Name = "FovChanger"
	FovChanger.Size = UDim2.new(0.00, 240.00, 0.00, 31.00)
	FovChanger.BorderColor3 = CLR
	FovChanger.Position = UDim2.new(0.06, 0.00, 0.46, 0.00)
	FovChanger.BackgroundColor3 = Color3.new(0.24, 0.24, 0.24)
	FovChanger.Parent = main

	local tagFC = Instance.new("TextLabel")
	tagFC.Name = "tagFC"
	tagFC.TextWrapped = true
	tagFC.ZIndex = 2
	tagFC.BorderSizePixel = 0
	tagFC.TextScaled = true
	tagFC.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	tagFC.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
	tagFC.TextSize = 14
	tagFC.Size = UDim2.new(0.00, 75.00, 0.00, 34.00)
	tagFC.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	tagFC.Text = "Fov:"
	tagFC.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	tagFC.BackgroundTransparency = 1
	tagFC.Position = UDim2.new(0.00, 0.00, -0.11, 0.00)
	tagFC.Parent = FovChanger

	local FOV = Instance.new("NumberValue")
	FOV.Name = "FOV"
	FOV.Value = 100
	FOV.Parent = FovChanger

	local FovControl = Instance.new("TextBox")
	FovControl.Name = "FovControl"
	FovControl.TextWrapped = true
	FovControl.BorderSizePixel = 0
	FovControl.TextScaled = true
	FovControl.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	FovControl.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
	FovControl.TextSize = 14
	FovControl.Size = UDim2.new(0.00, 152.00, 0.00, 31.00)
	FovControl.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	FovControl.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	FovControl.Text = "100"
	FovControl.BackgroundTransparency = 1
	FovControl.Position = UDim2.new(0.28, 0.00, 0.00, 0.00)
	FovControl.Parent = FovChanger

	local WalkSpeedChanger = Instance.new("Frame")
	WalkSpeedChanger.Name = "WalkSpeedChanger"
	WalkSpeedChanger.Size = UDim2.new(0.00, 240.00, 0.00, 31.00)
	WalkSpeedChanger.BorderColor3 = Color3.new(1.00, 1.00, 1.00)
	WalkSpeedChanger.Position = UDim2.new(0.06, 0.00, 0.33, 0.00)
	WalkSpeedChanger.BackgroundColor3 = Color3.new(0.24, 0.24, 0.24)
	WalkSpeedChanger.Parent = main

	local tagWSC = Instance.new("TextLabel")
	tagWSC.Name = "tagWSC"
	tagWSC.TextWrapped = true
	tagWSC.ZIndex = 2
	tagWSC.BorderSizePixel = 0
	tagWSC.TextScaled = true
	tagWSC.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	tagWSC.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
	tagWSC.TextSize = 14
	tagWSC.Size = UDim2.new(0.00, 111.00, 0.00, 34.00)
	tagWSC.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	tagWSC.Text = "WalkSpeed:"
	tagWSC.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	tagWSC.BackgroundTransparency = 1
	tagWSC.Position = UDim2.new(0.00, 0.00, -0.11, 0.00)
	tagWSC.Parent = WalkSpeedChanger

	local WalkSpeed = Instance.new("NumberValue")
	WalkSpeed.Name = "WalkSpeed"
	WalkSpeed.Value = 20
	WalkSpeed.Parent = WalkSpeedChanger

	local WalkSpeedControl = Instance.new("TextBox")
	WalkSpeedControl.Name = "WalkSpeedControl"
	WalkSpeedControl.TextWrapped = true
	WalkSpeedControl.BorderSizePixel = 0
	WalkSpeedControl.TextScaled = true
	WalkSpeedControl.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	WalkSpeedControl.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
	WalkSpeedControl.TextSize = 14
	WalkSpeedControl.Size = UDim2.new(0.00, 118.00, 0.00, 31.00)
	WalkSpeedControl.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	WalkSpeedControl.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	WalkSpeedControl.Text = "20"
	WalkSpeedControl.BackgroundTransparency = 1
	WalkSpeedControl.Position = UDim2.new(0.51, 0.00, 0.00, 0.00)
	WalkSpeedControl.Parent = WalkSpeedChanger

	ENABLED.Changed:Connect(function(newval)
		if newval == true then
			Enabled.Text = "✓"
		else
			Enabled.Text = "X"
		end
		enabledaim = newval
	end)
	FOVOUTLINE.Changed:Connect(function(newval)
		if newval == true then
			FovOutline.Text = "✓"
		else
			FovOutline.Text = "X"
		end
		fovoutline = newval
	end)
	FOV.Changed:Connect(function(new)
		fov = new
	end)
	WalkSpeed.Changed:Connect(function(value: number) 
		walkspeed = value
	end)
	WalkSpeedControl.FocusLost:Connect(function(enterpress)
		if enterpress then
			WalkSpeed.Value = math.clamp(tonumber(WalkSpeedControl.Text), 20, 100) - 15
			WalkSpeedControl.Text = tostring(WalkSpeed.Value + 15)
		end
	end)
	FovControl.FocusLost:Connect(function(enterpress)
		if enterpress then
			FOV.Value = math.clamp(tonumber(FovControl.Text), 10, 400)
			FovControl.Text = tostring(FOV.Value)
			drawCircle(fov, CLR)
			drawDot(CLR)
		end
	end)
	Enabled.MouseButton1Click:Connect(function()
		ENABLED.Value = not ENABLED.Value
	end)
	FovOutline.MouseButton1Click:Connect(function()
		FOVOUTLINE.Value = not FOVOUTLINE.Value
		for _, part in screengui:GetChildren() do
			if part.Name == "FovOutLine" or part.Name == "FovOutLine-Dot" then
				part.Visible = fovoutline
			end
		end
	end)
	exit.MouseButton1Click:Connect(function()
		main:Destroy()
		for _, part in screengui:GetChildren() do
			if part.Name == "FovOutLine" or part.Name == "FovOutLine-Dot" then
				part:Destroy()
			end
		end
	end)

	main.Draggable = true
	main.Active = true
end

function gui()
	drawCircle(fov, CLR)
	drawDot(CLR)
	drawMain(CLR)
end

function main()
	if espying then
		for _, player in game.Players:GetPlayers() do
			if player == Localplayer then continue end
			if player.Character then
				esp(player.Character)
			else
				spawn(function()
					player.CharacterAdded:Once(esp)
				end)
			end
			player.CharacterAdded:Connect(esp)
		end

		game.Players.PlayerAdded:Connect(function(player)
			if player == Localplayer then return end
			local char = player.Character or player.CharacterAdded:Wait()
			esp(player.Character)
			player.CharacterAdded:Connect(esp)
		end)
	else
		for _, player in game.Players:GetPlayers() do
			if player == Localplayer then continue end
			if player.Character then
				spawn(function()
					while player.Character.Humanoid.Health > 0 do
						temp_esp(player.Character)
						wait(spydown)
					end
				end)
			end
		end
	end

	gui()

	mouse.Move:Connect(function()
		local x = mouse.X
		local y = mouse.Y + offset

		for _, frame:Frame in screengui:GetChildren() do
			if frame.Name == "FovOutLine" or frame.Name == "FovOutLine-Dot" then
				frame.Position = UDim2.new(frame.Position.X.Scale, x, frame.Position.Y.Scale, y)
			end
		end
	end)
end

if enabledaim then
	main()
end
