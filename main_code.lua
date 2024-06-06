local wait, spawn = task.wait, task.spawn

local Localplayer = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local mouse = Localplayer:GetMouse()
local Camera = workspace.CurrentCamera
local CanAim = false
local fov = 100
local CLR = Color3.new(1,1,1)
local max = 300
local walkspeed = 23
local shooting = {}
local enabledaim = true
local shootteam = false
local advanced = false
local fovoutline = true
local screengui = nil
local functions = {function() UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then CanAim = false end end) UIS.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then CanAim = true shootnearest() end end)end}
functions[1]()

if Localplayer.PlayerGui:FindFirstChild("ScreenGui") then
	screengui = Localplayer.PlayerGui:FindFirstChild("ScreenGui")
	screengui.Enabled = true
else
	screengui = Instance.new("ScreenGui", Localplayer.PlayerGui)
	screengui.Name = "ScreenGui"
	screengui.Enabled = true
end
Localplayer.Character.Humanoid.WalkSpeed = walkspeed

RS.Heartbeat:Connect(function()
	if CanAim and enabledaim then
		shootnearest()
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
	gui.Parent = char:FindFirstChild("Head") or char:WaitForChild("Head")
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
	newpart.BorderColor3 = player.TeamColor.Color
	newpart.Transparency = 0.50
	newpart.BackgroundColor3 = player.TeamColor.Color
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
	FovChanger.Position = UDim2.new(0.06, 0.00, 0.33, 0.00)
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
	
	gui()
	
	mouse.Move:Connect(function()
		local x = mouse.X
		local y = mouse.Y
		
		for _, frame:Frame in screengui:GetChildren() do
			if frame.Name == "FovOutLine" or frame.Name == "FovOutLine-Dot" then
				frame.Position = UDim2.new(frame.Position.X.Scale, x, frame.Position.Y.Scale, y)
			end
		end
	end)
	if not Localplayer.Character then
		repeat wait() until Localplayer.Character
	end
	Localplayer.CharacterAdded:Connect(function()
		for _, frame:Frame in screengui:GetChildren() do
			if frame.Name == "FovOutLine" then
				return
			end
		end
		if not screengui:FindFirstChild("main") then
			gui()
		end
        Localplayer.Character.Humanoid.WalkSpeed = walkspeed
	end)
end

if enabledaim then
	main()
end
