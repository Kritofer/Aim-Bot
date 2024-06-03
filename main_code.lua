local wait, spawn = task.wait, task.spawn

print("Executing")

local Localplayer = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local mouse = Localplayer:GetMouse()
local Camera = workspace.CurrentCamera
local CanAim = false
local fov = Config.Fov or 100
local CLR = Config.Color or Color3.new(1,1,1)
local shooting = {}
local functions = {function() UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then CanAim = false end end) UIS.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then CanAim = true shootnearest() end end)end}
functions[1]()

RS.Heartbeat:Connect(function()
	if CanAim and Config.Enabled then
		shootnearest()
	end
end)

function shootnearest()
	table.clear(shooting)
	for _,player in game.Players:GetPlayers() do
		if player == Localplayer then continue end
		if player.Character and player.Character:FindFirstChild("Head") then
			local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(Camera:WorldToScreenPoint(player.Character.Head.Position).X, Camera:WorldToScreenPoint(player.Character.Head.Position).Y)).Magnitude
			shooting[distance] = player
		end
	end
	local shortest = math.huge
	for distance, player in shooting do
		local check = (player.Team ~= Localplayer.Team)
		if player.Team == nil then check = true end
		if Config.ShootTeam then check = true end 
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
	if Config.Advanced then
		lookto = CFrame.lookAt(Camera.CFrame.Position + Localplayer.Character.HumanoidRootPart.Velocity * (0.1 + (Localplayer:GetNetworkPing() * 5)), player.Character.HumanoidRootPart.Position + (player.Character.HumanoidRootPart.Velocity * (0.25 + (Localplayer:GetNetworkPing() * 7))))
		print("ping:", Localplayer:GetNetworkPing() * 7)
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
	local screengui = Localplayer.PlayerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui")
	screengui.Parent = Localplayer.PlayerGui
	for i = 0, math.pi*2, increment do
		local x = math.cos(i)*radius
		local y = math.sin(i)*radius
		table.insert(points, Vector2.new(x,y))
	end
	for _, GuiItem in screengui:GetDescendants() do
		if GuiItem:IsA("Frame") and GuiItem.Name == "AimBot-Decal" then
			GuiItem:Destroy()
		end
	end
	for i = 1, #points do
		local p1 = points[i]
		local line = Instance.new("Frame")
		line.Size = UDim2.new(0, 5, 0, 5)
		line.Position = UDim2.new(0.5, p1.X, 0.4789, p1.Y)
		line.AnchorPoint = Vector2.new(0.5, 0.4789)
		line.BackgroundColor3 = color
		line.BorderSizePixel = 0
		line.Parent = screengui
		line.Name = "AimBot-Decal"
		local clone = line:Clone()
		clone.Parent = game.StarterGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui")
		clone.Parent.Parent = game.StarterGui
	end
end

function drawDot(color)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 5, 0, 5)
	dot.Position = UDim2.new(0.5, 0, 0.4789, 0)
	dot.AnchorPoint = Vector2.new(0.5,0.4789)
	dot.BackgroundColor3 = color
	dot.BorderSizePixel = 0
	dot.Parent = Localplayer.PlayerGui.ScreenGui
	dot.Name = "AimBot-Decal"
	local clone = dot:Clone()
	clone.Parent = game.StarterGui.ScreenGui

end

drawCircle(fov, CLR)
drawDot(CLR)

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
