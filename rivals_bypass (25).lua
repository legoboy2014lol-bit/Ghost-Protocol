--[[ Ghost Protocol | Rivals | Bypass ]]
print("[Ghost Protocol] starting...")
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer


-- ===================== KEY SYSTEM =====================
-- Keys: 32 chars A-Z a-z 0-9. Validated client-side against issued set + local redeem file.
local KEY_FOLDER = "GhostProtocol"
local KEY_REDEEMED = KEY_FOLDER .. "/redeemed.txt"
local VALID_KEYS = {
	-- seed keys (generator produces matching format; paste more here or use dynamic accept of generated pattern)
}
local function gpEnsureKeyFolder()
	pcall(function()
		if isfolder and not isfolder(KEY_FOLDER) then makefolder(KEY_FOLDER) end
	end)
end
local function gpIsKeyFormat(k)
	if type(k) ~= "string" then return false end
	k = k:gsub("%s+", "")
	if #k ~= 32 then return false end
	return k:match("^[A-Za-z0-9]+$") ~= nil
end
local function gpKeyChecksum(k)
	-- lightweight checksum so random 32-char strings aren't all valid — generator uses same
	local sum = 0
	for i = 1, #k do
		sum = sum + string.byte(k, i) * (i % 7 + 1)
	end
	return sum % 97
end
local function gpIsValidKey(k)
	if not gpIsKeyFormat(k) then return false end
	-- accept if checksum matches magic (generator enforces this) OR listed
	if VALID_KEYS[k] then return true end
	return gpKeyChecksum(k) == 23
end
local function gpAlreadyRedeemed()
	gpEnsureKeyFolder()
	local ok, data = pcall(function()
		if isfile and isfile(KEY_REDEEMED) then
			return readfile(KEY_REDEEMED)
		end
		return nil
	end)
	if ok and data and gpIsValidKey(data:gsub("%s+", "")) then
		return true, data:gsub("%s+", "")
	end
	-- also memory for session
	if _G.__gpKeyOk and gpIsValidKey(tostring(_G.__gpKeyOk)) then
		return true, tostring(_G.__gpKeyOk)
	end
	return false, nil
end
local function gpSaveRedeemed(k)
	_G.__gpKeyOk = k
	gpEnsureKeyFolder()
	pcall(function()
		if writefile then writefile(KEY_REDEEMED, k) end
	end)
end

local KEY_UNLOCKED = false
do
	local ok = gpAlreadyRedeemed()
	if ok then KEY_UNLOCKED = true end
end

local function gpShowKeyUI(onSuccess)
	local sg = Instance.new("ScreenGui")
	sg.Name = "GP_KeySystem"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.DisplayOrder = 2000
	pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bg.BackgroundTransparency = 0.35
	bg.BorderSizePixel = 0
	bg.Parent = sg

	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(360, 200)
	card.Position = UDim2.new(0.5, -180, 0.5, -100)
	card.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	card.BorderSizePixel = 0
	card.Parent = bg
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
	local st = Instance.new("UIStroke", card)
	st.Thickness = 1.2
	st.Color = Color3.fromRGB(59, 91, 255)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 28)
	title.Position = UDim2.fromOffset(10, 12)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.Code
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(235, 235, 235)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Ghost Protocol — Key"
	title.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -20, 0, 18)
	sub.Position = UDim2.fromOffset(10, 40)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.Code
	sub.TextSize = 11
	sub.TextColor3 = Color3.fromRGB(150, 150, 150)
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Text = "Enter 32-character key to unlock"
	sub.Parent = card

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -20, 0, 32)
	box.Position = UDim2.fromOffset(10, 70)
	box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	box.BorderSizePixel = 0
	box.Font = Enum.Font.Code
	box.TextSize = 13
	box.TextColor3 = Color3.fromRGB(230, 230, 230)
	box.PlaceholderText = "XXXX... (32 chars)"
	box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
	box.Text = ""
	box.ClearTextOnFocus = false
	box.Parent = card
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, -20, 0, 18)
	status.Position = UDim2.fromOffset(10, 108)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.Code
	status.TextSize = 11
	status.TextColor3 = Color3.fromRGB(200, 120, 120)
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Text = ""
	status.Parent = card

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 34)
	btn.Position = UDim2.fromOffset(10, 138)
	btn.BackgroundColor3 = Color3.fromRGB(59, 91, 255)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Code
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = "Unlock"
	btn.Parent = card
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	local function attempt()
		local k = (box.Text or ""):gsub("%s+", ""):gsub("[^%w]", "")
		box.Text = k
		if not gpIsKeyFormat(k) then
			status.Text = "Key must be exactly 32 letters/numbers (got " .. tostring(#k) .. ")"
			status.TextColor3 = Color3.fromRGB(220, 100, 100)
			return
		end
		if not gpIsValidKey(k) then
			status.Text = "Invalid key (checksum fail)"
			status.TextColor3 = Color3.fromRGB(220, 100, 100)
			return
		end
		gpSaveRedeemed(k)
		KEY_UNLOCKED = true
		status.Text = "Unlocked"
		status.TextColor3 = Color3.fromRGB(100, 220, 140)
		task.delay(0.35, function()
			pcall(function() sg:Destroy() end)
			if onSuccess then onSuccess() end
		end)
	end
	btn.MouseButton1Click:Connect(attempt)
	box.FocusLost:Connect(function(enter)
		if enter then attempt() end
	end)
end
local Camera = workspace.CurrentCamera
local function cam()
	Camera = workspace.CurrentCamera or Camera
	return Camera
end
pcall(function()
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cam)
end)

local CONNECTIONS = {}
local function bind(c)
	table.insert(CONNECTIONS, c)
	return c
end

local UNLOADED = false
local menuVisible = true
local Theme = Color3.fromRGB(59, 91, 255)
local AccentEls = {}
local OutlineEls = {}

local Config = {
	Aimbot = {
		Enabled = false,
		FOV = 120,
		Smooth = 0.18,
		Prediction = 0.06,
		Wallbang = true,
		Sticky = true,
		TeamCheck = true,
		HoldKey = Enum.UserInputType.MouseButton2,
		Part = "Head",
	},
	SilentAim = { Enabled = false },
	Triggerbot = {
		Enabled = false,
		Delay = 0.05,
		FOV = 28,
		Wallbang = false,
		TeamCheck = true,
		Part = "Head",
	},
	UnlockAll = { Enabled = false },
	AntiAim = {
		Enabled = false,
		SpinSpeed = 55,
		Jitter = true,
		Desync = true,
		Underground = false,
		UndergroundDepth = 8,
	},
	VoidSpam = {
		Enabled = false,
		Distance = 250,
		ReturnDelay = 0.08,
		Interval = 0.35,
	},
	Skybox = { Current = "Default" },
	AutoLoadScript = { Enabled = true, Name = "" },
		Ragebot = {
		Enabled = false,
		Mode = "Orbit",
		OrbitRadius = 4.5,
		OrbitSpeed = 10,
		Height = 2.2,
		ShootDelay = 0.05,
		AntiKatana = true,
		AntiDepth = 6,
		NoAnim = true,
		Wallbang = true,
		HeadOnly = true,
		LocalVisualFreeze = false,
		AntiLegitSpeed = 14,
		CameraChaos = false,
		InvertCamera = true,
		CameraRoll = 180,
		CameraSpin = 2.4,
		MultiTarget = true,
		SnapDistance = 1.8,
		MaxRange = 500,
		SideSpeed = 18,
	},
	Fly = { Enabled = false, Speed = 70 },
	Movement = {
		WalkSpeed = 16,
		WalkSpeedEnabled = false,
		JumpPower = 50,
		JumpPowerEnabled = false,
		LongJump = false,
		LongJumpForce = 80,
		NoClip = false,
		InfiniteJump = false,
	},
	AutoLoot = {
		Enabled = false,
		Range = 80,
		Heal = true,
		Ammo = true,
		Interval = 0.35,
	},
	ESP = {
		Enabled = true,
		Boxes = true,
		Names = true,
		Distance = true,
		TeamCheck = true,
		Color = Theme,
		MaxDistance = 1500,
	},
	FOVCircle = {
		Enabled = true,
		Filled = true,
		FillTransparency = 0.75,
		Color = Theme,
		Animate = false,
		SpinSpeed = 1.2,
		Radius = 140,
	},
	Crosshair = {
		Enabled = true,
		Size = 8,
		Gap = 3,
		Thickness = 1,
		SpinSpeed = 2.0,
		Color = Theme,
		Animate = true,
	},
	WireframeWeapons = {
		Enabled = false,
		LocalOnly = true,
		Color = Theme,
		Thickness = 1.5,
	},
	Fullbright = { Enabled = false },
	Ambience = { Enabled = false, Color = Color3.fromRGB(140, 160, 200) },
	Fog = { Enabled = false, Start = 0, End = 500, Color = Color3.fromRGB(80, 80, 100) },
	TimeOfDay = { Enabled = false, Clock = 14 },
	NoFog = { Enabled = false },
	ColorCorrection = { Enabled = false, Saturation = 0.2, Contrast = 0.1, Tint = Color3.fromRGB(255, 255, 255) },
	Bloom = { Enabled = false, Intensity = 0.4, Size = 24 },
	World = {
		NoGrass = false,
		DarkMode = false,
		NeonWorld = false,
	},
	ThirdPerson = { Enabled = false, Distance = 10 },
	Tracers = { Enabled = false, TeamCheck = true, Origin = "Bottom" },
	NoRecoil = { Enabled = false },
	Menu = { Key = Enum.KeyCode.RightShift },
	Binds = {
		Aimbot = nil,
		SilentAim = nil,
		Triggerbot = nil,
		Ragebot = nil,
		Fly = nil,
		ESP = nil,
		NoClip = nil,
	},
	KeybindList = { Enabled = true },
}

local function getChar(p) return p and p.Character end
local function getHum(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP(c)
	if not c then return nil end
	return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
end
local function getPart(c, n)
	if not c then return nil end
	return c:FindFirstChild(n) or getHRP(c)
end
local function alive(p)
	local c = getChar(p)
	local h = getHum(c)
	return c and h and h.Health > 0 and getHRP(c) ~= nil
end
local function isTeammate(p)
	if not Config.Aimbot.TeamCheck then return false end
	if LocalPlayer.Team and p.Team then return LocalPlayer.Team == p.Team end
	return false
end
local function cursor()
	return UserInputService:GetMouseLocation()
end
local function toScreen(w)
	local v, on = cam():WorldToViewportPoint(w)
	return Vector2.new(v.X, v.Y), on, v.Z
end
local function hasLOS(fromPos, toPos, ignore)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local list = { LocalPlayer.Character }
	if ignore then
		for _, v in ipairs(ignore) do
			table.insert(list, v)
		end
	end
	params.FilterDescendantsInstances = list
	params.IgnoreWater = true
	local dir = toPos - fromPos
	local res = workspace:Raycast(fromPos, dir, params)
	if res == nil then
		return true
	end
	-- allow if hit is near target (character accessory/glass)
	if ignore then
		for _, v in ipairs(ignore) do
			if res.Instance and res.Instance:IsDescendantOf(v) then
				return true
			end
		end
	end
	return false
end
local function closestInFOV(fov, partName, wallbang)
	local best, bestD = nil, fov
	local m = cursor()
	local origin = cam().CFrame.Position
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and alive(p) and not isTeammate(p) then
			local char = getChar(p)
			local part = getPart(char, partName or "Head")
			if part then
				local sp, on, z = toScreen(part.Position)
				if on and z > 0 then
					local d = (sp - m).Magnitude
					if d < bestD then
						if wallbang or hasLOS(origin, part.Position, { char }) then
							bestD = d
							best = p
						end
					end
				end
			end
		end
	end
	return best, bestD
end
local function closestEnemy()
	local best, bestD = nil, math.huge
	local my = getHRP(getChar(LocalPlayer))
	if not my then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and alive(p) and not isTeammate(p) then
			local hrp = getHRP(getChar(p))
			if hrp then
				local d = (hrp.Position - my.Position).Magnitude
				if d < bestD and d < 500 then
					bestD = d
					best = p
				end
			end
		end
	end
	return best
end
local function predicted(part, p, pred)
	local hrp = getHRP(getChar(p))
	local vel = Vector3.zero
	if hrp then
		pcall(function()
			vel = hrp.AssemblyLinearVelocity
		end)
	end
	return part.Position + vel * (pred or 0)
end
local function fireClick(silent)
	pcall(function()
		if mouse1press then
			mouse1press()
			task.delay(silent and 0.01 or 0.02, function()
				if mouse1release then
					mouse1release()
				end
			end)
		elseif mouse1click then
			mouse1click()
		end
	end)
end
local function fireClickRage()
	-- multi-tap + alternate APIs for higher hit registration
	pcall(function()
		if mouse1click then
			mouse1click()
		end
	end)
	pcall(function()
		if mouse1press then
			mouse1press()
			if mouse1release then
				mouse1release()
			end
		end
	end)
	task.delay(0.01, function()
		pcall(function()
			if mouse1click then
				mouse1click()
			end
		end)
	end)
end
local function keyName(code)
	if not code then
		return "-"
	end
	if typeof(code) == "EnumItem" then
		return tostring(code):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
	end
	return tostring(code)
end
local function suppressRecoil()
	local char = LocalPlayer.Character
	if not char then
		return
	end
	for _, t in ipairs(char:GetChildren()) do
		if t:IsA("Tool") then
			pcall(function()
				if t:GetAttribute("Recoil") then
					t:SetAttribute("Recoil", 0)
				end
			end)
		end
	end
end

-- Wallbang helper: briefly noclip bullets / local parts (client visual assist)
local wallbangParts = {}
local function setWallbang(on)
	-- soft wallbang: ignore cancollide on nearby thin walls while aiming
	-- real server wallbang depends on game validation; this helps client hitscan paths
end

-- AIMBOT (hold RMB by default — smooth FOV lock + prediction)
local holdingAim = false
local lastAimTarget, lastAimT = nil, 0
bind(UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	local hk = Config.Aimbot.HoldKey or Enum.UserInputType.MouseButton2
	if input.UserInputType == hk or input.KeyCode == hk then
		holdingAim = true
	end
end))
bind(UserInputService.InputEnded:Connect(function(input)
	local hk = Config.Aimbot.HoldKey or Enum.UserInputType.MouseButton2
	if input.UserInputType == hk or input.KeyCode == hk then
		holdingAim = false
	end
end))
bind(RunService.RenderStepped:Connect(function()
	if UNLOADED or not Config.Aimbot.Enabled or not holdingAim then
		return
	end
	if Config.Ragebot.Enabled then
		return
	end
	local partName = Config.Aimbot.Part or "Head"
	local target = closestInFOV(Config.Aimbot.FOV or 120, partName, Config.Aimbot.Wallbang)
	if not target then
		target = closestInFOV(Config.Aimbot.FOV or 120, "HumanoidRootPart", Config.Aimbot.Wallbang)
	end
	if not target and Config.Aimbot.Sticky and lastAimTarget and alive(lastAimTarget) and tick() - lastAimT < 0.4 then
		target = lastAimTarget
	end
	if not target then return end
	lastAimTarget = target
	lastAimT = tick()
	local part = getPart(getChar(target), partName) or getHRP(getChar(target))
	if not part then return end
	local c = cam()
	local pred = predicted(part, target, Config.Aimbot.Prediction or 0.06)
	local goal = CFrame.new(c.CFrame.Position, pred)
	local smooth = Config.Aimbot.Smooth or 0.18
	-- lower smooth = snappier; clamp so it always moves
	local alpha = math.clamp(1 - smooth, 0.2, 1)
	c.CFrame = c.CFrame:Lerp(goal, alpha)
end))

-- TRIGGERBOT (fires when enemy head is under crosshair FOV)
local lastTrig = 0
bind(RunService.RenderStepped:Connect(function()
	if UNLOADED or not Config.Triggerbot.Enabled then
		return
	end
	if Config.Ragebot.Enabled then return end
	if tick() - lastTrig < (Config.Triggerbot.Delay or 0.05) then
		return
	end
	local partName = Config.Triggerbot.Part or "Head"
	local wall = Config.Triggerbot.Wallbang
	if wall == nil then wall = false end
	local t, d = closestInFOV(Config.Triggerbot.FOV or 28, partName, wall)
	if t and d and d <= (Config.Triggerbot.FOV or 28) then
		-- require roughly on-screen center
		fireClick(false)
		lastTrig = tick()
	end
end))


-- SILENT AIM (metatable, safe)
local silentPart = nil
local silentTarget = nil
bind(RunService.Heartbeat:Connect(function()
	if true then silentPart=nil silentTarget=nil return end -- silent removed
	if UNLOADED or not Config.SilentAim.Enabled then
		silentPart = nil
		silentTarget = nil
		return
	end
	local t = closestInFOV(Config.SilentAim.FOV, Config.SilentAim.Part or "Head", Config.SilentAim.Wallbang)
	if t and math.random(1, 100) <= (Config.SilentAim.HitChance or 100) then
		silentTarget = t
		silentPart = getPart(getChar(t), Config.SilentAim.Part or "Head") or getHRP(getChar(t))
	else
		silentPart = nil
		silentTarget = nil
	end
end))
pcall(function()
	if not getrawmetatable then
		return
	end
	local wrap = newcclosure or function(f)
		return f
	end
	local mt = getrawmetatable(game)
	if not mt then
		return
	end
	local oldIndex = mt.__index
	setreadonly(mt, false)
	mt.__index = wrap(function(self, key)
		if not UNLOADED and Config.SilentAim.Enabled and silentPart and silentPart.Parent then
			if typeof(self) == "Instance" and self:IsA("Camera") then
				if key == "CFrame" or key == "CoordinateFrame" then
					local cf = oldIndex(self, "CFrame")
					return CFrame.new(cf.Position, silentPart.Position)
				end
			end
		end
		return oldIndex(self, key)
	end)
	setreadonly(mt, true)
end)
pcall(function()
	if not getrawmetatable then
		return
	end
	local wrap = newcclosure or function(f)
		return f
	end
	local mouse = LocalPlayer:GetMouse()
	local mt = getrawmetatable(mouse)
	if not mt then
		return
	end
	local oldIndex = mt.__index
	setreadonly(mt, false)
	mt.__index = wrap(function(self, key)
		if not UNLOADED and Config.SilentAim.Enabled and silentPart and silentPart.Parent then
			if key == "Hit" then
				return CFrame.new(silentPart.Position)
			elseif key == "Target" then
				return silentPart
			elseif key == "UnitRay" then
				local origin = cam().CFrame.Position
				local dir = (silentPart.Position - origin).Unit
				return Ray.new(origin, dir * 1000)
			end
		end
		return oldIndex(self, key)
	end)
	setreadonly(mt, true)
end)

-- UNLOCK ALL (client cosmetics / locked items where possible)
local function runUnlockAll()
	pcall(function()
		for _, v in ipairs(game:GetDescendants()) do
			if v:IsA("BoolValue") or v:IsA("NumberValue") or v:IsA("StringValue") then
				local n = string.lower(v.Name)
				if n:find("lock") or n:find("owned") or n:find("unlock") or n:find("premium") then
					if v:IsA("BoolValue") then
						pcall(function()
							v.Value = true
						end)
					end
				end
			end
		end
	end)
	pcall(function()
		local ps = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts")
		if ps then
			for _, v in ipairs(ps:GetDescendants()) do
				if v:IsA("ModuleScript") then
					-- leave modules; just flag unlock attempt
				end
			end
		end
	end)
	print("[Ghost Protocol] unlock-all pass done")
end

-- FLY
local flyBV, flyBG
local keys = { W = false, A = false, S = false, D = false, Space = false, LeftControl = false, C = false }
bind(UserInputService.InputBegan:Connect(function(i, g)
	if g then
		return
	end
	local k = i.KeyCode
	if k == Enum.KeyCode.W then
		keys.W = true
	elseif k == Enum.KeyCode.A then
		keys.A = true
	elseif k == Enum.KeyCode.S then
		keys.S = true
	elseif k == Enum.KeyCode.D then
		keys.D = true
	elseif k == Enum.KeyCode.Space then
		keys.Space = true
	elseif k == Enum.KeyCode.LeftControl then
		keys.LeftControl = true
	elseif k == Enum.KeyCode.C then
		keys.C = true
	end
end))
bind(UserInputService.InputEnded:Connect(function(i)
	local k = i.KeyCode
	if k == Enum.KeyCode.W then
		keys.W = false
	elseif k == Enum.KeyCode.A then
		keys.A = false
	elseif k == Enum.KeyCode.S then
		keys.S = false
	elseif k == Enum.KeyCode.D then
		keys.D = false
	elseif k == Enum.KeyCode.Space then
		keys.Space = false
	elseif k == Enum.KeyCode.LeftControl then
		keys.LeftControl = false
	elseif k == Enum.KeyCode.C then
		keys.C = false
	end
end))
local function stopFly()
	if flyBV then
		pcall(function()
			flyBV:Destroy()
		end)
		flyBV = nil
	end
	if flyBG then
		pcall(function()
			flyBG:Destroy()
		end)
		flyBG = nil
	end
	local hum = getHum(getChar(LocalPlayer))
	if hum then
		hum.PlatformStand = false
	end
end
local function startFly()
	stopFly()
	local hrp = getHRP(getChar(LocalPlayer))
	local hum = getHum(getChar(LocalPlayer))
	if not hrp or not hum then
		return
	end
	hum.PlatformStand = true
	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(9e4, 9e4, 9e4)
	flyBV.Velocity = Vector3.zero
	flyBV.Parent = hrp
	flyBG = Instance.new("BodyGyro")
	flyBG.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
	flyBG.P = 2500
	flyBG.CFrame = hrp.CFrame
	flyBG.Parent = hrp
end
bind(RunService.RenderStepped:Connect(function()
	if UNLOADED then
		return
	end
	if Config.Fly.Enabled then
		local hrp = getHRP(getChar(LocalPlayer))
		if not hrp then
			return
		end
		if not flyBV or not flyBV.Parent then
			startFly()
		end
		local cf = cam().CFrame
		-- horizontal only from camera look (flattened) — no look-up/down vertical
		local flatLook = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
		if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
		local flatRight = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
		if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
		local dir = Vector3.zero
		if keys.W then dir = dir + flatLook end
		if keys.S then dir = dir - flatLook end
		if keys.A then dir = dir - flatRight end
		if keys.D then dir = dir + flatRight end
		-- vertical: Space up, C (or Ctrl) down
		if keys.Space then dir = dir + Vector3.yAxis end
		if keys.C or keys.LeftControl then dir = dir - Vector3.yAxis end
		if dir.Magnitude > 0 then
			flyBV.Velocity = dir.Unit * Config.Fly.Speed
		else
			flyBV.Velocity = Vector3.zero
		end
		-- keep body upright, yaw from camera
		local yaw = math.atan2(-flatLook.X, -flatLook.Z)
		flyBG.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0)
	else
		if flyBV or flyBG then
			stopFly()
		end
	end
	local hum = getHum(getChar(LocalPlayer))
	if hum then
		if Config.Movement.WalkSpeedEnabled then
			hum.WalkSpeed = Config.Movement.WalkSpeed
		end
		if Config.Movement.JumpPowerEnabled then
			pcall(function()
				hum.JumpPower = Config.Movement.JumpPower
			end)
		end
	end
end))

local noclipConn
local function setNoClip(on)
	if noclipConn then
		pcall(function()
			noclipConn:Disconnect()
		end)
		noclipConn = nil
	end
	if not on then
		local char = LocalPlayer.Character
		if char then
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then
					p.CanCollide = true
				end
			end
		end
		return
	end
	noclipConn = RunService.Stepped:Connect(function()
		if UNLOADED or not Config.Movement.NoClip then
			return
		end
		local char = LocalPlayer.Character
		if not char then
			return
		end
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end)
	table.insert(CONNECTIONS, noclipConn)
end

bind(UserInputService.JumpRequest:Connect(function()
	if UNLOADED then
		return
	end
	local hum = getHum(getChar(LocalPlayer))
	local hrp = getHRP(getChar(LocalPlayer))
	if Config.Movement.InfiniteJump and hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
	if Config.Movement.LongJump and hrp then
		local look = cam().CFrame.LookVector
		hrp.AssemblyLinearVelocity = Vector3.new(look.X * Config.Movement.LongJumpForce, Config.Movement.JumpPower, look.Z * Config.Movement.LongJumpForce)
	end
end))

-- RAGE — camera chaos + destroy
local rageAngle, lastRageShot = 0, 0
local function targetHoldingKatana(plr)
	local char = getChar(plr)
	if not char then return false end
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return false end
	local n = string.lower(tool.Name)
	return n:find("katana") ~= nil or n:find("saber") ~= nil
end
local function setCharCF(myHRP, cf)
	pcall(function()
		if myHRP.Parent and myHRP.Parent:IsA("Model") then
			myHRP.Parent:PivotTo(cf)
		else
			myHRP.CFrame = cf
		end
	end)
	pcall(function()
		myHRP.AssemblyLinearVelocity = Vector3.zero
		myHRP.AssemblyAngularVelocity = Vector3.zero
	end)
end

bind(RunService.Heartbeat:Connect(function(dt)
	if UNLOADED then return end
	if not Config.Ragebot.Enabled then
		return
	end
	local myHRP = getHRP(getChar(LocalPlayer))
	local myHum = getHum(getChar(LocalPlayer))
	if not myHRP or not myHum or myHum.Health <= 0 then return end

	-- multi-target: keep nuking nearest, then next
	local targets = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and alive(p) and not isTeammate(p) then
			local hrp = getHRP(getChar(p))
			if hrp then
				local d = (hrp.Position - myHRP.Position).Magnitude
				if d < 500 then
					table.insert(targets, { p = p, d = d, hrp = hrp })
				end
			end
		end
	end
	table.sort(targets, function(a, b) return a.d < b.d end)
	if #targets == 0 then return end

	local target = targets[1].p
	local tHRP = targets[1].hrp
	local aimPart = getPart(getChar(target), "Head") or tHRP
	if not aimPart then return end

	local anti = Config.Ragebot.AntiKatana and targetHoldingKatana(target)
	local mode = Config.Ragebot.Mode or "Orbit"
	local speed = (Config.Ragebot.OrbitSpeed or 22) * (anti and 1.6 or 1)
	local r = (Config.Ragebot.OrbitRadius or 4) * (anti and 1.2 or 1)
	local h = (Config.Ragebot.Height or 2.2) + (anti and 2 or 0)
	rageAngle = rageAngle + speed * dt

	local destCF
	if mode == "SideTP" then
		local side = (math.sin(rageAngle) > 0) and 1 or -1
		destCF = CFrame.new(tHRP.Position + tHRP.CFrame.RightVector * side * 3.2 + Vector3.new(0, 1.4, 0), aimPart.Position)
	elseif mode == "AntiLegit" then
		local depth = Config.Ragebot.AntiDepth or 6
		destCF = CFrame.new(tHRP.Position - Vector3.new(0, depth, 0) + Vector3.new(math.cos(rageAngle) * 2, 0, math.sin(rageAngle) * 2), aimPart.Position)
	else
		-- default orbit tight on head
		destCF = CFrame.new(tHRP.Position + Vector3.new(math.cos(rageAngle) * r, h, math.sin(rageAngle) * r), aimPart.Position)
	end

	-- put you on target for hitreg
	setCharCF(myHRP, destCF)

	-- aim assist toward head (no camera flip here — done on RenderStepped)
	if menuVisible then return end
	if Config.Ragebot.NoAnim then suppressRecoil() end

	-- always keep true aim CF toward head for bullets (invert is visual-only later)
	local c = cam()
	local trueAim = CFrame.new(c.CFrame.Position, aimPart.Position)
	_G.__gpRageTrueAim = trueAim
	_G.__gpRageAimPart = aimPart
	c.CFrame = trueAim

	local delay = math.min(Config.Ragebot.ShootDelay or 0.05, 0.08)
	if anti then delay = delay + 0.03 end
	if tick() - lastRageShot >= delay then
		local snap = Config.Ragebot.SnapDistance or 1.8
		pcall(function()
			local toward = (aimPart.Position - myHRP.Position)
			if toward.Magnitude > snap + 0.5 then
				local closePos = aimPart.Position - toward.Unit * snap
				if mode ~= "AntiLegit" then
					setCharCF(myHRP, CFrame.new(closePos, aimPart.Position))
				end
			end
		end)
		-- aim camera at head RIGHT before click so pellets register
		pcall(function()
			local cc = cam()
			cc.CFrame = CFrame.new(cc.CFrame.Position, aimPart.Position)
			_G.__gpRageTrueAim = cc.CFrame
		end)
		if fireClickRage then
			fireClickRage()
		else
			fireClick(true)
		end
		-- second click a frame later still aimed
		task.defer(function()
			pcall(function()
				local cc = cam()
				local ap = _G.__gpRageAimPart
				if ap and ap.Parent then
					cc.CFrame = CFrame.new(cc.CFrame.Position, ap.Position)
				end
			end)
			if fireClick then fireClick(true) end
		end)
		if Config.Ragebot.MultiTarget ~= false and #targets >= 2 and targets[2].d < 35 then
			fireClick(true)
		end
		lastRageShot = tick()
	end
end))


-- RAGE camera invert (RenderStepped so it wins over other camera writes)
-- Visual-only invert: keep LookVector on target so bullets still go where you aim
bind(RunService:BindToRenderStep("GP_RageInvert", Enum.RenderPriority.Camera.Value + 5, function()
	if UNLOADED or not Config.Ragebot.Enabled then return end
	if Config.Ragebot.InvertCamera == false then return end
	local c = cam()
	if not c then return end
	local aimPart = _G.__gpRageAimPart
	local pos = c.CFrame.Position
	local lookAt
	if aimPart and aimPart.Parent then
		lookAt = aimPart.Position
	elseif _G.__gpRageTrueAim then
		lookAt = (_G.__gpRageTrueAim).Position + (_G.__gpRageTrueAim).LookVector * 50
	else
		lookAt = pos + c.CFrame.LookVector * 50
	end
	-- look AT target, then roll 180 so view is upside-down but aim direction unchanged
	local base = CFrame.new(pos, lookAt)
	c.CFrame = base * CFrame.Angles(0, 0, math.pi)
end))

-- ESP simple boxes
local espStore = {}
local function getEspParent()
	if rootGui and rootGui.Parent then
		return rootGui
	end
	local cg = game:GetService("CoreGui")
	local existing = cg:FindFirstChild("BypassPremium")
	return existing or cg
end
local function clearESP(plr)
	local o = espStore[plr]
	if o then
		for _, v in pairs(o) do
			pcall(function()
				v:Destroy()
			end)
		end
		espStore[plr] = nil
	end
end
local function makeESP(plr)
	if espStore[plr] then
		return espStore[plr]
	end
	local o = {}
	local function mk()
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.BackgroundColor3 = Theme
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Visible = false
		f.ZIndex = 20
		f.Parent = getEspParent()
		return f
	end
	o.top = mk()
	o.bot = mk()
	o.left = mk()
	o.right = mk()
	o.name = Instance.new("TextLabel")
	o.name.BackgroundTransparency = 1
	o.name.Font = Enum.Font.Code
	o.name.TextSize = 12
	o.name.TextColor3 = Theme
	o.name.TextStrokeTransparency = 0.5
	o.name.Visible = false
	o.name.ZIndex = 21
	o.name.Parent = getEspParent()
	o.dist = Instance.new("TextLabel")
	o.dist.BackgroundTransparency = 1
	o.dist.Font = Enum.Font.Code
	o.dist.TextSize = 11
	o.dist.TextColor3 = Color3.fromRGB(200, 200, 200)
	o.dist.TextStrokeTransparency = 0.5
	o.dist.Visible = false
	o.dist.ZIndex = 21
	o.dist.Parent = getEspParent()
	espStore[plr] = o
	return o
end
local function hideBox(o)
	o.top.Visible = false
	o.bot.Visible = false
	o.left.Visible = false
	o.right.Visible = false
	o.name.Visible = false
	o.dist.Visible = false
end
local function setBox(o, x, y, w, h, col)
	local t = 1
	o.top.Size = UDim2.fromOffset(w, t)
	o.top.Position = UDim2.fromOffset(x + w / 2, y)
	o.top.BackgroundColor3 = col
	o.top.Visible = true
	o.bot.Size = UDim2.fromOffset(w, t)
	o.bot.Position = UDim2.fromOffset(x + w / 2, y + h)
	o.bot.BackgroundColor3 = col
	o.bot.Visible = true
	o.left.Size = UDim2.fromOffset(t, h)
	o.left.Position = UDim2.fromOffset(x, y + h / 2)
	o.left.BackgroundColor3 = col
	o.left.Visible = true
	o.right.Size = UDim2.fromOffset(t, h)
	o.right.Position = UDim2.fromOffset(x + w, y + h / 2)
	o.right.BackgroundColor3 = col
	o.right.Visible = true
end

-- UI root first so ESP can parent
local rootGui = Instance.new("ScreenGui")
rootGui.Name = "BypassPremium"
rootGui.ResetOnSpawn = false
rootGui.IgnoreGuiInset = true
rootGui.DisplayOrder = 999
pcall(function()
	rootGui.Parent = CoreGui
end)
if not rootGui.Parent then
	rootGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ===== Wireframe / Fullbright / Tracers / ThirdPerson / NoRecoil =====
local wireStore = {} -- [Instance] = Highlight
local tracerStore = {} -- [Player] = Beam/line
local fullbrightBackup = nil

function clearWireframe()
	for inst, h in pairs(wireStore) do
		pcall(function()
			if h then h:Destroy() end
		end)
		wireStore[inst] = nil
	end
end

local function applyWireToTool(tool)
	if not tool or wireStore[tool] then
		return
	end
	local ok, h = pcall(function()
		local hl = Instance.new("Highlight")
		hl.Name = "BP_Wireframe"
		hl.Adornee = tool
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = 1
		hl.OutlineTransparency = 0
		hl.OutlineColor = Config.WireframeWeapons.Color or Theme
		hl.Parent = tool
		return hl
	end)
	if ok and h then
		wireStore[tool] = h
	else
		-- fallback materials
		for _, d in ipairs(tool:GetDescendants()) do
			if d:IsA("BasePart") then
				pcall(function()
					d.Material = Enum.Material.ForceField
					d.Color = Config.WireframeWeapons.Color or Theme
				end)
			end
		end
	end
end

local function refreshWireframe()
	if not Config.WireframeWeapons.Enabled then
		return
	end
	local function scan(char)
		if not char then return end
		for _, ch in ipairs(char:GetChildren()) do
			if ch:IsA("Tool") or ch:IsA("Model") then
				if ch.Name:lower():find("gun") or ch:IsA("Tool") or ch:FindFirstChildWhichIsA("BasePart") then
					if ch:IsA("Tool") then
						applyWireToTool(ch)
					end
				end
			end
		end
		for _, d in ipairs(char:GetDescendants()) do
			if d:IsA("Tool") then
				applyWireToTool(d)
			end
		end
	end
	scan(getChar(LocalPlayer))
	if not Config.WireframeWeapons.LocalOnly then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				scan(getChar(plr))
			end
		end
	end
	-- backpack tools
	pcall(function()
		local bp = LocalPlayer:FindFirstChild("Backpack")
		if bp then
			for _, t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") then
					applyWireToTool(t)
				end
			end
		end
	end)
end

function applyFullbright(on)
	if on then
		if not fullbrightBackup then
			fullbrightBackup = {
				Brightness = Lighting.Brightness,
				ClockTime = Lighting.ClockTime,
				FogEnd = Lighting.FogEnd,
				GlobalShadows = Lighting.GlobalShadows,
				Ambient = Lighting.Ambient,
			}
		end
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(200, 200, 200)
	else
		if fullbrightBackup then
			for k, v in pairs(fullbrightBackup) do
				pcall(function()
					Lighting[k] = v
				end)
			end
		end
	end
end

function clearTracers()
	for p, obj in pairs(tracerStore) do
		pcall(function()
			if obj then obj:Destroy() end
		end)
		tracerStore[p] = nil
	end
end

local tracerFolder = Instance.new("Folder")
tracerFolder.Name = "BP_Tracers"
tracerFolder.Parent = rootGui

local function updateTracers()
	if not Config.Tracers.Enabled then
		return
	end
	local myHRP = getHRP(getChar(LocalPlayer))
	if not myHRP then return end
	local origin = Vector2.new(cam().ViewportSize.X / 2, cam().ViewportSize.Y)
	if Config.Tracers.Origin == "Center" then
		origin = Vector2.new(cam().ViewportSize.X / 2, cam().ViewportSize.Y / 2)
	end
	local live = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and alive(plr) then
			if not (Config.Tracers.TeamCheck and isTeammate(plr)) then
				local hrp = getHRP(getChar(plr))
				if hrp then
					local pos, on = toScreen(hrp.Position)
					if on then
						live[plr] = true
						local line = tracerStore[plr]
						if not line then
							line = Instance.new("Frame")
							line.Name = "tracer"
							line.AnchorPoint = Vector2.new(0.5, 0.5)
							line.BorderSizePixel = 0
							line.BackgroundColor3 = Theme
							line.BackgroundTransparency = 0.25
							line.ZIndex = 40
							line.Parent = tracerFolder
							tracerStore[plr] = line
						end
						local dx = pos.X - origin.X
						local dy = pos.Y - origin.Y
						local dist = math.sqrt(dx * dx + dy * dy)
						local angle = math.deg(math.atan2(dy, dx))
						line.Size = UDim2.fromOffset(dist, 1)
						line.Position = UDim2.fromOffset((origin.X + pos.X) / 2, (origin.Y + pos.Y) / 2)
						line.Rotation = angle
						line.Visible = true
					end
				end
			end
		end
	end
	for p, line in pairs(tracerStore) do
		if not live[p] then
			pcall(function() line:Destroy() end)
			tracerStore[p] = nil
		end
	end
end

bind(RunService.RenderStepped:Connect(function()
	if UNLOADED then return end
	if Config.WireframeWeapons.Enabled then
		refreshWireframe()
		for tool, h in pairs(wireStore) do
			if h and h.Parent then
				h.OutlineColor = Config.WireframeWeapons.Color or Theme
			elseif not tool or not tool.Parent then
				pcall(function() if h then h:Destroy() end end)
				wireStore[tool] = nil
			end
		end
	end
	if Config.Fullbright.Enabled then
		applyFullbright(true)
	end
	if Config.ThirdPerson.Enabled then
		pcall(function()
			local char = getChar(LocalPlayer)
			local hum = getHum(char)
			local hrp = getHRP(char)
			if not hum or not hrp then return end
			LocalPlayer.CameraMode = Enum.CameraMode.Classic
			LocalPlayer.CameraMinZoomDistance = 0.5
			LocalPlayer.CameraMaxZoomDistance = 128
			local c = cam()
			c.CameraType = Enum.CameraType.Custom
			c.CameraSubject = hum
			-- force zoom distance every frame
			local dist = Config.ThirdPerson.Distance or 10
			local look = c.CFrame.LookVector
			local targetPos = hrp.Position + Vector3.new(0, 1.5, 0)
			local camPos = targetPos - look * dist + Vector3.new(0, dist * 0.15, 0)
			c.CFrame = CFrame.new(camPos, targetPos)
		end)
	else
		pcall(function()
			LocalPlayer.CameraMinZoomDistance = 0.5
			LocalPlayer.CameraMaxZoomDistance = 128
		end)
	end
	if Config.NoRecoil.Enabled then
		pcall(function()
			local char = getChar(LocalPlayer)
			if not char then return end
			for _, v in ipairs(char:GetDescendants()) do
				if v:IsA("NumberValue") or v:IsA("NumberAttribute") then
					-- skip
				end
				local n = string.lower(v.Name)
				if (v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("NumberValue")) and (n:find("recoil") or n:find("spread") or n:find("kick")) then
					v.Value = 0
				end
			end
			local tool = char:FindFirstChildOfClass("Tool")
			if tool then
				for _, v in ipairs(tool:GetDescendants()) do
					local n = string.lower(v.Name)
					if (v:IsA("NumberValue") or v:IsA("IntValue")) and (n:find("recoil") or n:find("spread") or n:find("kick")) then
						v.Value = 0
					end
				end
			end
		end)
	end
	updateTracers()
end))



bind(RunService:BindToRenderStep("BP_ESP", Enum.RenderPriority.Camera.Value + 1, function()
	if UNLOADED then
		return
	end
	if not Config.ESP.Enabled then
		for p in pairs(espStore) do
			clearESP(p)
		end
		return
	end
	local myHRP = getHRP(getChar(LocalPlayer))
	local live = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if not (not alive(plr) or (Config.ESP.TeamCheck and isTeammate(plr))) then
				local char = getChar(plr)
				local hrp = getHRP(char)
				local head = getPart(char, "Head")
				if hrp and head then
					local topPos = head.Position + Vector3.new(0, 0.55, 0)
					local botPos = hrp.Position - Vector3.new(0, 3, 0)
					local top, topOn, topZ = toScreen(topPos)
					local bot = toScreen(botPos)
					local mid, midOn, midZ = toScreen(hrp.Position)
					local dist = myHRP and (hrp.Position - myHRP.Position).Magnitude or 0
					local o = makeESP(plr)
					live[plr] = true
					if (midOn or topOn) and midZ > 0 and dist <= Config.ESP.MaxDistance then
						local height = math.max(math.abs(top.Y - bot.Y), 18)
						local width = height * 0.5
						local x = mid.X - width / 2
						local y = math.min(top.Y, bot.Y)
						if Config.ESP.Boxes then
							setBox(o, x, y, width, height, Config.ESP.Color)
						else
							hideBox(o)
						end
						if Config.ESP.Names then
							o.name.Text = (plr.DisplayName ~= "" and plr.DisplayName) or plr.Name
							o.name.Size = UDim2.fromOffset(160, 16)
							o.name.Position = UDim2.fromOffset(mid.X - 80, y - 18)
							o.name.TextColor3 = Theme
							o.name.Visible = true
						else
							o.name.Visible = false
						end
						if Config.ESP.Distance and myHRP then
							o.dist.Text = string.format("%dm", math.floor(dist))
							o.dist.Size = UDim2.fromOffset(80, 14)
							o.dist.Position = UDim2.fromOffset(mid.X - 40, y + height + 2)
							o.dist.Visible = true
						else
							o.dist.Visible = false
						end
					else
						hideBox(o)
					end
				else
					clearESP(plr)
				end
			else
				clearESP(plr)
			end
		end
	end
	for p in pairs(espStore) do
		if not live[p] then
			clearESP(p)
		end
	end
end))
bind(Players.PlayerRemoving:Connect(clearESP))

-- FOV (animated filled) + spinning bar crosshair
local fovRing = Instance.new("Frame")
fovRing.AnchorPoint = Vector2.new(0.5, 0.5)
fovRing.BackgroundColor3 = Theme
fovRing.BackgroundTransparency = 0.75
fovRing.Visible = false
fovRing.ZIndex = 5
fovRing.Parent = rootGui
local fovCorner = Instance.new("UICorner", fovRing)
fovCorner.CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovRing)
fovStroke.Thickness = 1.5
fovStroke.Color = Theme

-- crosshair: 4 bars only
local crossRoot = Instance.new("Frame")
crossRoot.Name = "Crosshair"
crossRoot.AnchorPoint = Vector2.new(0.5, 0.5)
crossRoot.Size = UDim2.fromOffset(40, 40)
crossRoot.BackgroundTransparency = 1
crossRoot.Visible = false
crossRoot.ZIndex = 6
crossRoot.Parent = rootGui
local function makeBar()
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Theme
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.ZIndex = 7
	f.Parent = crossRoot
	return f
end
local barN, barS, barE, barW = makeBar(), makeBar(), makeBar(), makeBar()

local function layoutCrosshair()
	local size = Config.Crosshair.Size or 8
	local gap = Config.Crosshair.Gap or 3
	local th = Config.Crosshair.Thickness or 1
	barN.Size = UDim2.fromOffset(th, size)
	barS.Size = UDim2.fromOffset(th, size)
	barE.Size = UDim2.fromOffset(size, th)
	barW.Size = UDim2.fromOffset(size, th)
	barN.Position = UDim2.fromOffset(20, 20 - gap - size / 2)
	barS.Position = UDim2.fromOffset(20, 20 + gap + size / 2)
	barE.Position = UDim2.fromOffset(20 + gap + size / 2, 20)
	barW.Position = UDim2.fromOffset(20 - gap - size / 2, 20)
end
layoutCrosshair()

local crossAngle = 0
local fovPulse = 0
bind(RunService:BindToRenderStep("BP_FOV", Enum.RenderPriority.Camera.Value + 2, function(dt)
	if UNLOADED then
		return
	end
	local m = cursor()
	-- FOV
	local showFov = Config.FOVCircle.Enabled and not Config.Ragebot.Enabled
	if showFov then
		local r = 120
		if Config.Triggerbot and Config.Triggerbot.Enabled then
			r = math.max(r, Config.Triggerbot.FOV or 22)
		end
		-- use a readable default radius; scale slightly with pulse
		r = (Config.FOVCircle.Radius or 140)
		-- no pulse — solid static FOV
		local diam = r * 2
		fovRing.Size = UDim2.fromOffset(diam, diam)
		fovRing.Position = UDim2.fromOffset(m.X, m.Y)
		local col = Config.FOVCircle.Color or Theme
		fovStroke.Color = col
		if Config.FOVCircle.Filled then
			local baseT = Config.FOVCircle.FillTransparency or 0.75
			fovRing.BackgroundColor3 = col
			fovRing.BackgroundTransparency = math.clamp(baseT, 0.4, 0.92)
		else
			fovRing.BackgroundTransparency = 1
		end
		fovRing.Visible = true
	else
		fovRing.Visible = false
	end
	-- Crosshair bars
	if Config.Crosshair.Enabled then
		crossRoot.Position = UDim2.fromOffset(m.X, m.Y)
		crossRoot.Visible = true
		layoutCrosshair()
		local col = Config.Crosshair.Color or Theme
		for _, b in ipairs({ barN, barS, barE, barW }) do
			b.BackgroundColor3 = col
		end
		if Config.Crosshair.Animate then
			crossAngle = crossAngle + (dt or 0.016) * (Config.Crosshair.SpinSpeed or 2.5)
			crossRoot.Rotation = math.deg(crossAngle)
		else
			crossRoot.Rotation = 0
		end
	else
		crossRoot.Visible = false
	end
end))

-- THEME / OUTLINES
local function registerOutline(st)
	table.insert(OutlineEls, st)
end
local function addOutline(gui, thickness)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness or 1
	s.Color = Theme
	pcall(function()
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end)
	s.Parent = gui
	registerOutline(s)
	return s
end
local function applyTheme(col)
	Theme = col
	Config.ESP.Color = col
	Config.FOVCircle.Color = col
	Config.Crosshair.Color = col
	Config.WireframeWeapons.Color = col
	for _, st in ipairs(OutlineEls) do
		pcall(function()
			st.Color = col
		end)
	end
	for _, el in ipairs(AccentEls) do
		pcall(function()
			if not el or not el.Parent then return end
			if el:IsA("TextLabel") or el:IsA("TextButton") then
				el.TextColor3 = col
				-- ON text toggles OR pill switches (empty text + knob child)
				if el:IsA("TextButton") then
					if el.Text == "ON" then
						el.BackgroundColor3 = col
					elseif el.Text == "" and el:FindFirstChildWhichIsA("Frame") then
						-- only repaint if currently "on" (knob on right)
						local k = el:FindFirstChildWhichIsA("Frame")
						if k and k.Position.X.Scale >= 0.5 then
							el.BackgroundColor3 = col
						end
					end
				end
			elseif el:IsA("Frame") then
				el.BackgroundColor3 = col
			elseif el:IsA("UIStroke") then
				el.Color = col
			end
		end)
	end
	pcall(function()
		if fovStroke then fovStroke.Color = col end
		if fovRing then fovRing.BackgroundColor3 = col end
	end)
	pcall(function()
		if kbTitle then kbTitle.TextColor3 = col end
	end)
	-- rebuild keybind list so all labels pick up Theme
	pcall(function()
		if refreshKeybindOverlay then refreshKeybindOverlay() end
	end)
end


-- ===================== ANTI AIM — disconnect & throw body parts =====================
local aaAngle = 0
local aaMotorCache = {} -- [Motor6D] = {Part0, Part1, C0, C1}
local aaDisconnected = false

local function aaCacheMotors(char)
	aaMotorCache = {}
	if not char then return end
	for _, m in ipairs(char:GetDescendants()) do
		if m:IsA("Motor6D") then
			aaMotorCache[m] = {
				Part0 = m.Part0,
				Part1 = m.Part1,
				C0 = m.C0,
				C1 = m.C1,
			}
		end
	end
end

local function aaBreakMotors(char)
	if not char then return end
	if not next(aaMotorCache) then
		aaCacheMotors(char)
	end
	for m, _ in pairs(aaMotorCache) do
		pcall(function()
			if m and m.Parent then
				m.Part0 = nil
				m.Part1 = nil
			end
		end)
	end
	aaDisconnected = true
end

local function aaRestoreMotors()
	for m, data in pairs(aaMotorCache) do
		pcall(function()
			if m and m.Parent then
				m.Part0 = data.Part0
				m.Part1 = data.Part1
				m.C0 = data.C0
				m.C1 = data.C1
			end
		end)
	end
	aaDisconnected = false
end

-- restore on disable / character respawn
bind(LocalPlayer.CharacterAdded:Connect(function(char)
	aaMotorCache = {}
	aaDisconnected = false
	task.delay(0.4, function()
		aaCacheMotors(char)
	end)
end))

bind(RunService.Heartbeat:Connect(function(dt)
	if UNLOADED then return end
	if not Config.AntiAim.Enabled then
		if aaDisconnected then
			aaRestoreMotors()
		end
		return
	end
	if Config.Ragebot.Enabled then
		return
	end
	local char = LocalPlayer.Character
	local hrp = getHRP(char)
	local hum = getHum(char)
	if not hrp or not hum or hum.Health <= 0 then
		return
	end

	aaAngle = aaAngle + (Config.AntiAim.SpinSpeed or 55) * dt
	local base = hrp.Position
	if Config.AntiAim.Underground then
		base = base - Vector3.new(0, Config.AntiAim.UndergroundDepth or 8, 0)
	end
	local jitter = 0
	if Config.AntiAim.Jitter then
		jitter = (math.noise(tick() * 14) - 0.5) * math.pi * 1.4
	end
	local yaw = aaAngle + jitter

	-- DISCONNECT all joints then fling every part
	if Config.AntiAim.Desync then
		if not aaDisconnected then
			aaBreakMotors(char)
		end
		local t = tick()
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				pcall(function()
					-- throw around in expanding orbit + chaos
					local seed = part.Size.X * 7.1 + part.Size.Y * 3.3 + part.Size.Z * 1.7
					local radius = 3 + (math.sin(t * 2 + seed) * 0.5 + 0.5) * 10
					local speed = aaAngle * (1.5 + (seed % 3) * 0.4)
					local ox = math.cos(speed + seed) * radius
					local oy = math.sin(speed * 1.3 + seed * 0.5) * (radius * 0.7) + 2
					local oz = math.sin(speed + seed * 1.1) * radius
					part.CFrame = CFrame.new(base + Vector3.new(ox, oy, oz))
						* CFrame.Angles(speed * 2.2, yaw + seed, speed * 1.7)
					part.AssemblyLinearVelocity = Vector3.new(
						math.sin(t * 8 + seed) * 40,
						math.cos(t * 6 + seed) * 35,
						math.cos(t * 7 + seed) * 40
					)
					part.AssemblyAngularVelocity = Vector3.new(
						math.sin(t * 5 + seed) * 25,
						math.cos(t * 4 + seed) * 30,
						math.sin(t * 6 + seed) * 25
					)
					part.CanCollide = false
				end)
			end
		end
		-- accessories too
		for _, acc in ipairs(char:GetChildren()) do
			if acc:IsA("Accessory") then
				local handle = acc:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					pcall(function()
						local seed = handle.Size.Magnitude * 9
						local radius = 6 + math.sin(tick() * 3 + seed) * 5
						handle.CFrame = CFrame.new(base + Vector3.new(
							math.cos(aaAngle * 2 + seed) * radius,
							4 + math.sin(aaAngle + seed) * 3,
							math.sin(aaAngle * 2 + seed) * radius
						)) * CFrame.Angles(aaAngle * 3, aaAngle, aaAngle * 2)
						handle.CanCollide = false
					end)
				end
			end
		end
	end

	local spinCF = CFrame.new(base) * CFrame.Angles(0, yaw, 0)
	pcall(function()
		hrp.CFrame = spinCF
		hrp.AssemblyAngularVelocity = Vector3.new(0, Config.AntiAim.SpinSpeed or 55, 0)
	end)
end))


-- ===================== VOID SPAM =====================
local lastVoid = 0
local voidReturnAt = 0
local voidOrigin = nil
bind(RunService.Heartbeat:Connect(function()
	if UNLOADED or not Config.VoidSpam.Enabled then
		return
	end
	-- void spam is a rage feature
	if not Config.Ragebot.Enabled then
		return
	end
	local hrp = getHRP(getChar(LocalPlayer))
	if not hrp then
		return
	end
	local now = tick()
	if voidOrigin and now >= voidReturnAt then
		pcall(function()
			if hrp.Parent and hrp.Parent:IsA("Model") then
				hrp.Parent:PivotTo(voidOrigin)
			else
				hrp.CFrame = voidOrigin
			end
		end)
		voidOrigin = nil
		return
	end
	if voidOrigin then
		return
	end
	if now - lastVoid < (Config.VoidSpam.Interval or 0.35) then
		return
	end
	lastVoid = now
	voidOrigin = hrp.CFrame
	local dist = Config.VoidSpam.Distance or 250
	local away = voidOrigin.Position + Vector3.new(
		(math.random() - 0.5) * dist,
		-math.abs(dist),
		(math.random() - 0.5) * dist
	)
	pcall(function()
		if hrp.Parent and hrp.Parent:IsA("Model") then
			hrp.Parent:PivotTo(CFrame.new(away))
		else
			hrp.CFrame = CFrame.new(away)
		end
	end)
	voidReturnAt = now + (Config.VoidSpam.ReturnDelay or 0.08)
end))

-- ===================== SKYBOX =====================
local function applySkybox(name)
	Config.Skybox.Current = name
	for _, ch in ipairs(Lighting:GetChildren()) do
		if ch:IsA("Sky") then
			ch:Destroy()
		end
	end
	if name == "Default" then
		return
	end
	local ids = {
		Nebula = { "159454299", "159454296", "159454293", "159454286", "159454300", "159454288" },
		Night = { "12064107", "12064152", "12064121", "12063984", "12064115", "12064131" },
		Pink = { "271042516", "271077243", "271042556", "271042310", "271042467", "271077958" },
		Space = { "159454286", "159454299", "159454288", "159454293", "159454300", "159454296" },
	}
	local d = ids[name]
	if not d then
		return
	end
	local sky = Instance.new("Sky")
	sky.SkyboxBk = "rbxassetid://" .. d[1]
	sky.SkyboxDn = "rbxassetid://" .. d[2]
	sky.SkyboxFt = "rbxassetid://" .. d[3]
	sky.SkyboxLf = "rbxassetid://" .. d[4]
	sky.SkyboxRt = "rbxassetid://" .. d[5]
	sky.SkyboxUp = "rbxassetid://" .. d[6]
	sky.Parent = Lighting
end

-- ===================== CONFIG SAVE / AUTOLOAD =====================
local CONFIG_FOLDER = "BypassPremium"
local CONFIG_INDEX = CONFIG_FOLDER .. "/index.json"
local AUTOLOAD_FILE = CONFIG_FOLDER .. "/autoload.txt"
local function ensureFolder()
	if isfolder and not isfolder(CONFIG_FOLDER) then
		makefolder(CONFIG_FOLDER)
	end
end
local function readIndex()
	ensureFolder()
	if not isfile or not isfile(CONFIG_INDEX) then
		return {}
	end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(CONFIG_INDEX))
	end)
	return ok and data or {}
end
local function writeIndex(list)
	ensureFolder()
	if writefile then
		writefile(CONFIG_INDEX, game:GetService("HttpService"):JSONEncode(list))
	end
end
local function serializeConfig()
	return {
		Ragebot = Config.Ragebot,
		Fly = Config.Fly,
		Movement = Config.Movement,
		AutoLoot = Config.AutoLoot,
		ESP = Config.ESP,
		AntiAim = Config.AntiAim,
		VoidSpam = Config.VoidSpam,
		Skybox = Config.Skybox,
		Triggerbot = Config.Triggerbot,
		Theme = { R = Theme.R, G = Theme.G, B = Theme.B },
	}
end
local function applyConfig(data)
	if not data then
		return
	end
	local function merge(dst, src)
		if type(src) ~= "table" or type(dst) ~= "table" then
			return
		end
		for k, v in pairs(src) do
			if type(v) == "table" and type(dst[k]) == "table" then
				merge(dst[k], v)
			else
				dst[k] = v
			end
		end
	end
	merge(Config.Ragebot, data.Ragebot)
	merge(Config.Fly, data.Fly)
	merge(Config.Movement, data.Movement)
	merge(Config.AutoLoot, data.AutoLoot)
	merge(Config.ESP, data.ESP)
	merge(Config.AntiAim, data.AntiAim)
	merge(Config.VoidSpam, data.VoidSpam)
	merge(Config.Skybox, data.Skybox)
	merge(Config.Triggerbot, data.Triggerbot)
	if data.Theme then
		applyTheme(Color3.new(data.Theme.R or Theme.R, data.Theme.G or Theme.G, data.Theme.B or Theme.B))
	end
	if data.Skybox and data.Skybox.Current then
		applySkybox(data.Skybox.Current)
	end
end
local function saveConfig(name)
	if not name or name == "" then
		return false
	end
	ensureFolder()
	if not writefile then
		return false
	end
	writefile(CONFIG_FOLDER .. "/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(serializeConfig()))
	local idx = readIndex()
	local found = false
	for _, n in ipairs(idx) do
		if n == name then
			found = true
			break
		end
	end
	if not found then
		table.insert(idx, name)
		writeIndex(idx)
	end
	return true
end
local function loadConfig(name)
	if not name or not isfile then
		return false
	end
	local path = CONFIG_FOLDER .. "/" .. name .. ".json"
	if not isfile(path) then
		return false
	end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(path))
	end)
	if ok and data then
		applyConfig(data)
		return true
	end
	return false
end
local memoryAutoload = ""
local function setAutoload(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	memoryAutoload = name
	Config.AutoLoadScript.Name = name
	ensureFolder()
	pcall(function()
		if writefile then
			writefile(AUTOLOAD_FILE, name)
		end
	end)
	print("[Ghost Protocol] autoload set:", name ~= "" and name or "(none)")
end
local function getAutoload()
	-- prefer memory, then config, then file
	if memoryAutoload and memoryAutoload ~= "" then
		return memoryAutoload
	end
	if Config.AutoLoadScript and Config.AutoLoadScript.Name and Config.AutoLoadScript.Name ~= "" then
		return Config.AutoLoadScript.Name
	end
	local ok, data = pcall(function()
		if isfile and isfile(AUTOLOAD_FILE) then
			return readfile(AUTOLOAD_FILE)
		end
		return ""
	end)
	if ok and data and data ~= "" then
		memoryAutoload = data
		return data
	end
	return ""
end
-- no config on script load — defaults only until match autoload or manual load
pcall(function()
	local auto = getAutoload()
	if auto and auto ~= "" then
		memoryAutoload = auto
		Config.AutoLoadScript.Name = auto
		print("[Ghost Protocol] autoload name ready (not applied until match):", auto)
	end
end)

-- Auto-load config once when you queue into a match
local wasInMatch = false
local matchLoadDone = false
local lastAutoTry = 0
local function detectInMatch()
	local char = LocalPlayer.Character
	if not char then return false end
	local hum = getHum(char)
	local my = getHRP(char)
	if not hum or not my then return false end
	if char:FindFirstChildOfClass("Tool") then return true end
	local bp = LocalPlayer:FindFirstChild("Backpack")
	if bp then
		for _, tool in ipairs(bp:GetChildren()) do
			if tool:IsA("Tool") then
				return true -- any tool in backpack = loaded into round kit
			end
		end
	end
	local near = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and alive(plr) then
			local h = getHRP(getChar(plr))
			if h and (h.Position - my.Position).Magnitude < 500 then
				near = near + 1
			end
		end
	end
	if near >= 1 then return true end
	if hum.Health > 0 and hum.Health < 100 then return true end
	-- place id / teleport style: if player count high enough
	if #Players:GetPlayers() >= 4 then return true end
	return false
end
local function tryMatchAutoload(reason)
	if UNLOADED or not Config.AutoLoadScript.Enabled then return end
	if matchLoadDone then return end
	local auto = getAutoload()
	if not auto or auto == "" then
		print("[Ghost Protocol] autoload skipped — no config name set (use Set autoload)")
		matchLoadDone = true
		return
	end
	local ok = loadConfig(auto)
	matchLoadDone = true
	print("[Ghost Protocol] autoload (" .. tostring(reason) .. "):", auto, ok and "OK" or "FAIL")
end
bind(RunService.Heartbeat:Connect(function()
	if UNLOADED or not Config.AutoLoadScript.Enabled then
		return
	end
	if tick() - lastAutoTry < 0.5 then return end
	lastAutoTry = tick()
	local inMatch = detectInMatch()
	if inMatch and not wasInMatch then
		matchLoadDone = false
	end
	if inMatch then
		tryMatchAutoload("match")
	else
		matchLoadDone = false
	end
	wasInMatch = inMatch
end))
bind(LocalPlayer.CharacterAdded:Connect(function()
	if UNLOADED or not Config.AutoLoadScript.Enabled then return end
	matchLoadDone = false
	task.delay(0.8, function()
		if UNLOADED then return end
		if detectInMatch() then
			tryMatchAutoload("spawn")
		end
	end)
	task.delay(2.5, function()
		if UNLOADED then return end
		if detectInMatch() then
			matchLoadDone = false
			tryMatchAutoload("spawn-retry")
		end
	end)
end))



LocalPlayer.CharacterAdded:Connect(function()
	task.delay(0.5, function()
		if UNLOADED then return end
		local want = Config.Skybox and Config.Skybox.Current
		if want and want ~= "Default" then
			applySkybox(want)
		end
	end)
end)


-- keep skybox across lobby -> match transitions
local lastSkyCheck = 0
bind(RunService.Heartbeat:Connect(function()
	if UNLOADED then return end
	if tick() - lastSkyCheck < 1.5 then return end
	lastSkyCheck = tick()
	local want = Config.Skybox and Config.Skybox.Current
	if not want or want == "Default" then return end
	local has = false
	for _, ch in ipairs(Lighting:GetChildren()) do
		if ch:IsA("Sky") then has = true break end
	end
	if not has then
		applySkybox(want)
	end
end))



-- ===================== AUTO LOOT / HEAL / AMMO (FFA) =====================
local lastLoot = 0
local function tryUseTool(nameHints)
	local char = getChar(LocalPlayer)
	local bp = LocalPlayer:FindFirstChild("Backpack")
	local lists = {}
	if char then table.insert(lists, char) end
	if bp then table.insert(lists, bp) end
	for _, parent in ipairs(lists) do
		for _, t in ipairs(parent:GetChildren()) do
			if t:IsA("Tool") then
				local n = string.lower(t.Name)
				for _, h in ipairs(nameHints) do
					if n:find(h) then
						pcall(function()
							local hum = getHum(char)
							if hum and bp and t.Parent == bp then
								hum:EquipTool(t)
							end
						end)
						pcall(function()
							t:Activate()
						end)
						return true
					end
				end
			end
		end
	end
	return false
end
local function pickupNearby()
	local my = getHRP(getChar(LocalPlayer))
	if not my then return end
	local range = Config.AutoLoot.Range or 80
	local candidates = {}
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("BasePart") or inst:IsA("MeshPart") then
			local n = string.lower(inst.Name)
			local parentN = inst.Parent and string.lower(inst.Parent.Name) or ""
			local isLoot = n:find("ammo") or n:find("heal") or n:find("med") or n:find("kit")
				or n:find("bandage") or n:find("armor") or n:find("shield") or n:find("pickup")
				or n:find("loot") or n:find("crate") or n:find("drop") or n:find("weapon")
				or parentN:find("ammo") or parentN:find("heal") or parentN:find("loot") or parentN:find("pickup")
			if isLoot then
				local pos = inst.Position
				local d = (pos - my.Position).Magnitude
				if d <= range then
					table.insert(candidates, { inst = inst, d = d })
				end
			end
		elseif inst:IsA("ProximityPrompt") then
			local part = inst.Parent
			if part and part:IsA("BasePart") then
				local d = (part.Position - my.Position).Magnitude
				if d <= range then
					pcall(function()
						if fireproximityprompt then
							fireproximityprompt(inst)
						end
					end)
				end
			end
		end
	end
	table.sort(candidates, function(a, b) return a.d < b.d end)
	for i = 1, math.min(6, #candidates) do
		local inst = candidates[i].inst
		pcall(function()
			-- touch interest / bring to player
			inst.CFrame = my.CFrame
			if firetouchinterest and getHRP(getChar(LocalPlayer)) then
				firetouchinterest(inst, my, 0)
				firetouchinterest(inst, my, 1)
			end
		end)
	end
end
bind(RunService.Heartbeat:Connect(function()
	if UNLOADED or not Config.AutoLoot.Enabled then return end
	if tick() - lastLoot < (Config.AutoLoot.Interval or 0.35) then return end
	lastLoot = tick()
	pickupNearby()
	local hum = getHum(getChar(LocalPlayer))
	if Config.AutoLoot.Heal and hum and hum.Health > 0 and hum.Health < hum.MaxHealth * 0.92 then
		tryUseTool({ "heal", "med", "kit", "bandage", "syringe", "potion", "health", "stim" })
	end
	if Config.AutoLoot.Ammo then
		tryUseTool({ "ammo", "reload", "mag", "refill", "shell", "bullet" })
		-- also try common attribute / remote style client heal-ammo values
		pcall(function()
			local char = getChar(LocalPlayer)
			if not char then return end
			for _, v in ipairs(char:GetDescendants()) do
				local n = string.lower(v.Name)
				if (v:IsA("IntValue") or v:IsA("NumberValue")) and (n:find("ammo") or n:find("mag") or n:find("clip")) then
					if v.Value < 10 then
						v.Value = math.max(v.Value, 30)
					end
				end
			end
			local tool = char:FindFirstChildOfClass("Tool")
			if tool then
				for _, v in ipairs(tool:GetDescendants()) do
					local n = string.lower(v.Name)
					if (v:IsA("IntValue") or v:IsA("NumberValue")) and (n:find("ammo") or n:find("mag") or n:find("clip") or n:find("shell")) then
						if v.Value < 8 then
							v.Value = math.max(v.Value, 24)
						end
					end
				end
			end
		end)
	end
end))


-- ===================== HIT NOTIFICATIONS (rage) =====================
local hitNotifFolder = Instance.new("Folder")
hitNotifFolder.Name = "GP_HitNotifs"
hitNotifFolder.Parent = rootGui
local hitNotifStack = {}
local healthCache = {} -- [Player] = lastHealth

local function pushHitNotif(name, dmg)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromOffset(170, 16)
	label.AnchorPoint = Vector2.new(1, 1)
	label.Position = UDim2.new(1, -12, 1, -14)
	label.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	label.BackgroundTransparency = 0.3
	label.BorderSizePixel = 0
	label.Font = Enum.Font.Code
	label.TextSize = 11
	label.TextColor3 = Theme
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.Text = string.format("HIT %s FOR %d", tostring(name), math.floor(dmg + 0.5))
	label.ZIndex = 90
	label.TextTransparency = 0
	label.Parent = hitNotifFolder
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 2)
		c.Parent = label
	end
	do
		local p = Instance.new("UIPadding")
		p.PaddingRight = UDim.new(0, 6)
		p.PaddingLeft = UDim.new(0, 6)
		p.Parent = label
	end
	-- theme outline
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.2
	stroke.Color = Theme
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = label
	table.insert(OutlineEls, stroke)
	table.insert(hitNotifStack, 1, label)
	-- stack upward from bottom-right
	for i, lab in ipairs(hitNotifStack) do
		lab.Position = UDim2.new(1, -12, 1, -14 - (i - 1) * 18)
	end
	task.spawn(function()
		task.wait(1.6)
		for i = 1, 8 do
			if not label.Parent then break end
			label.TextTransparency = i / 8
			label.BackgroundTransparency = 0.3 + (i / 8) * 0.7
			if stroke then stroke.Transparency = i / 8 end
			task.wait(0.025)
		end
		pcall(function() label:Destroy() end)
		for i = #hitNotifStack, 1, -1 do
			if hitNotifStack[i] == label or not hitNotifStack[i].Parent then
				table.remove(hitNotifStack, i)
			end
		end
		for i, lab in ipairs(hitNotifStack) do
			lab.Position = UDim2.new(1, -12, 1, -14 - (i - 1) * 18)
		end
	end)
end

-- track health drops while raging
bind(RunService.Heartbeat:Connect(function()
	if UNLOADED then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local hum = getHum(getChar(plr))
			if hum then
				local hp = hum.Health
				local prev = healthCache[plr]
				if prev and hp < prev - 0.5 then
					local dmg = prev - hp
					if Config.Ragebot.Enabled then
						-- only players in your match (nearby)
						local my = getHRP(getChar(LocalPlayer))
						local their = getHRP(getChar(plr))
						local inMatch = false
						if my and their then
							local d = (my.Position - their.Position).Magnitude
							if d < 350 then inMatch = true end
						end
						if inMatch then
							local nm = (plr.DisplayName and plr.DisplayName ~= "" and plr.DisplayName) or plr.Name
							pushHitNotif(nm, dmg)
						end
					end
				end
				healthCache[plr] = hp
			else
				healthCache[plr] = nil
			end
		end
	end
end))
bind(Players.PlayerRemoving:Connect(function(plr)
	healthCache[plr] = nil
end))



-- Key gate: block UI until unlocked
if not KEY_UNLOCKED then
	local done = false
	gpShowKeyUI(function()
		done = true
	end)
	repeat task.wait(0.1) until done or KEY_UNLOCKED
	KEY_UNLOCKED = true
end

-- MENU — Unnamed Enhancement style (exact layout)
-- title centered, taller window, Code font, dark panels, two-column settings
local menu = Instance.new("Frame")
menu.Name = "BPMenu"
menu.Size = UDim2.fromOffset(500, 540)
menu.Position = UDim2.new(0.5, -250, 0.5, -270)
menu.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
menu.BorderSizePixel = 0
menu.ZIndex = 50
menu.Active = true
menu.Parent = rootGui
do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = menu
end
local menuShadow = Instance.new("ImageLabel")
menuShadow.Name = "Shadow"
menuShadow.BackgroundTransparency = 1
menuShadow.Image = "rbxassetid://6014261993"
menuShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
menuShadow.ImageTransparency = 0.55
menuShadow.ScaleType = Enum.ScaleType.Slice
menuShadow.SliceCenter = Rect.new(49, 49, 450, 450)
menuShadow.Size = UDim2.new(1, 24, 1, 24)
menuShadow.Position = UDim2.fromOffset(-12, -12)
menuShadow.ZIndex = 49
menuShadow.Parent = menu

addOutline(menu, 1)

-- top title bar (centered title like Unnamed)
local topBar = Instance.new("TextButton")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 24)
topBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
topBar.BorderSizePixel = 0
topBar.Text = ""
topBar.AutoButtonColor = false
topBar.ZIndex = 51
topBar.Parent = menu

local titleMain = Instance.new("TextLabel")
titleMain.Size = UDim2.new(1, -40, 1, 0)
titleMain.Position = UDim2.fromOffset(0, 0)
titleMain.BackgroundTransparency = 1
titleMain.Font = Enum.Font.Code
titleMain.TextSize = 12
titleMain.TextColor3 = Color3.fromRGB(220, 220, 220)
titleMain.TextXAlignment = Enum.TextXAlignment.Center
titleMain.Text = "Ghost Protocol - discord.gg/enhancementrivals"
titleMain.ZIndex = 52
titleMain.Parent = topBar

local rivalsTag = Instance.new("TextLabel")
rivalsTag.Size = UDim2.fromOffset(52, 18)
rivalsTag.Position = UDim2.new(1, -56, 0.5, -9)
rivalsTag.BackgroundTransparency = 1
rivalsTag.Font = Enum.Font.Code
rivalsTag.TextSize = 12
rivalsTag.TextColor3 = Theme
rivalsTag.Text = "Rivals"
rivalsTag.TextXAlignment = Enum.TextXAlignment.Right
rivalsTag.ZIndex = 53
rivalsTag.Parent = topBar
table.insert(AccentEls, rivalsTag)

-- tab strip
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, 0, 0, 22)
tabBar.Position = UDim2.fromOffset(0, 24)
tabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 51
tabBar.Parent = menu

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 0)
tabLayout.Parent = tabBar

local tabNames = { "main", "world", "esp", "visuals", "character", "misc", "settings" }
local tabLabels = {
	main = "main",
	world = "world",
	esp = "esp",
	visuals = "visuals",
	character = "character",
	misc = "misc",
	settings = "settings",
}
local tabButtons, pages = {}, {}

local contentHost = Instance.new("Frame")
contentHost.Size = UDim2.new(1, -10, 1, -50)
contentHost.Position = UDim2.fromOffset(5, 46)
contentHost.BackgroundTransparency = 1
contentHost.ClipsDescendants = true
contentHost.ZIndex = 51
contentHost.Parent = menu

local function switchTab(id)
	for k, pg in pairs(pages) do
		pg.Visible = (k == id)
	end
	for k, b in pairs(tabButtons) do
		local on = (k == id)
		b.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
		b.BackgroundColor3 = on and Color3.fromRGB(28, 28, 28) or Color3.fromRGB(14, 14, 14)
	end
end

for _, name in ipairs(tabNames) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1 / #tabNames, 0, 1, 0)
	b.BackgroundColor3 = (name == "settings") and Color3.fromRGB(28, 28, 28) or Color3.fromRGB(14, 14, 14)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.Code
	b.TextSize = 12
	b.Text = tabLabels[name] or name
	b.TextColor3 = (name == "settings") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
	b.ZIndex = 52
	b.AutoButtonColor = false
	b.Parent = tabBar
	tabButtons[name] = b

	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
	page.CanvasSize = UDim2.fromOffset(0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = (name == "settings")
	page.ZIndex = 52
	page.ScrollingEnabled = true
	page.Parent = contentHost
	local pad = Instance.new("UIPadding", page)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.PaddingTop = UDim.new(0, 2)
	pad.PaddingLeft = UDim.new(0, 0)
	pad.PaddingRight = UDim.new(0, 0)
	pages[name] = page

	local left = Instance.new("Frame")
	left.Name = "Left"
	left.Size = UDim2.new(0.5, -4, 0, 0)
	left.AutomaticSize = Enum.AutomaticSize.Y
	left.BackgroundTransparency = 1
	left.ZIndex = 53
	left.Parent = page
	Instance.new("UIListLayout", left).Padding = UDim.new(0, 5)

	local right = Instance.new("Frame")
	right.Name = "Right"
	right.Size = UDim2.new(0.5, -4, 0, 0)
	right.Position = UDim2.new(0.5, 4, 0, 0)
	right.AutomaticSize = Enum.AutomaticSize.Y
	right.BackgroundTransparency = 1
	right.ZIndex = 53
	right.Parent = page
	Instance.new("UIListLayout", right).Padding = UDim.new(0, 4)

	b.MouseButton1Click:Connect(function()
		switchTab(name)
	end)
end

local function L(page)
	return page:FindFirstChild("Left")
end
local function R(page)
	return page:FindFirstChild("Right")
end

local function group(parent, titleText)
	local g = Instance.new("Frame")
	g.Size = UDim2.new(1, 0, 0, 0)
	g.AutomaticSize = Enum.AutomaticSize.Y
	g.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	g.BorderSizePixel = 0
	g.ZIndex = 54
	g.Parent = parent
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 2)
		c.Parent = g
	end
	addOutline(g, 1)
	local h = Instance.new("TextLabel")
	h.Size = UDim2.new(1, -8, 0, 16)
	h.Position = UDim2.fromOffset(6, 3)
	h.BackgroundTransparency = 1
	h.Font = Enum.Font.Code
	h.TextSize = 11
	h.TextColor3 = Color3.fromRGB(225, 225, 225)
	h.TextXAlignment = Enum.TextXAlignment.Left
	h.Text = titleText
	h.ZIndex = 55
	h.Parent = g
	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, -10, 0, 0)
	body.Position = UDim2.fromOffset(5, 18)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.BackgroundTransparency = 1
	body.ZIndex = 55
	body.Parent = g
	Instance.new("UIListLayout", body).Padding = UDim.new(0, 2)
	local pad = Instance.new("UIPadding", g)
	pad.PaddingBottom = UDim.new(0, 5)
	return body
end

local function rowToggle(parent, label, get, set)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.ZIndex = 56
	row.Parent = parent
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -48, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.TextColor3 = Color3.fromRGB(205, 205, 205)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = label
	lbl.ZIndex = 57
	lbl.Parent = row

	-- premium pill switch
	local track = Instance.new("TextButton")
	track.Size = UDim2.fromOffset(36, 16)
	track.Position = UDim2.new(1, -36, 0.5, -8)
	track.BackgroundColor3 = get() and Theme or Color3.fromRGB(42, 42, 42)
	track.BorderSizePixel = 0
	track.Text = ""
	track.AutoButtonColor = false
	track.ZIndex = 57
	track.Parent = row
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = track
	end
	addOutline(track, 1)
	table.insert(AccentEls, track)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(12, 12)
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = get() and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	knob.BorderSizePixel = 0
	knob.ZIndex = 58
	knob.Parent = track
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = knob
	end

	local function paint(on)
		track.BackgroundColor3 = on and Theme or Color3.fromRGB(42, 42, 42)
		knob.Position = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
	end

	track.MouseButton1Click:Connect(function()
		local v = not get()
		set(v)
		paint(v)
		if label == "Fly" and not v then
			stopFly()
		end
		if label == "NoClip" then
			setNoClip(v)
		end
		if refreshKeybindOverlay then
			refreshKeybindOverlay()
		end
	end)
end

local function rowBtn(parent, label, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 20)
	b.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.Code
	b.TextSize = 11
	b.TextColor3 = Color3.fromRGB(215, 215, 215)
	b.Text = label
	b.AutoButtonColor = false
	b.ZIndex = 56
	b.Parent = parent
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 3)
		c.Parent = b
	end
	addOutline(b, 1)
	b.MouseEnter:Connect(function()
		b.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	end)
	b.MouseLeave:Connect(function()
		b.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	end)
	b.MouseButton1Click:Connect(cb)
	return b
end

local function rowSlider(parent, label, minV, maxV, get, set)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundTransparency = 1
	row.ZIndex = 56
	row.Parent = parent
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 12)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 11
	lbl.TextColor3 = Color3.fromRGB(195, 195, 195)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	local function fmt(v)
		if math.abs(v - math.floor(v)) < 0.001 then
			return tostring(math.floor(v))
		end
		return string.format("%.2f", v)
	end
	lbl.Text = label .. ": " .. fmt(get())
	lbl.ZIndex = 57
	lbl.Parent = row
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 8)
	bar.Position = UDim2.fromOffset(0, 15)
	bar.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	bar.BorderSizePixel = 0
	bar.ZIndex = 57
	bar.Active = true
	bar.Parent = row
	addOutline(bar, 1)
	local fill = Instance.new("Frame")
	local initRel = math.clamp((get() - minV) / math.max(maxV - minV, 1e-6), 0, 1)
	fill.Size = UDim2.new(initRel, 0, 1, 0)
	fill.BackgroundColor3 = Theme
	fill.BorderSizePixel = 0
	fill.ZIndex = 58
	fill.Parent = bar
	table.insert(AccentEls, fill)
	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(10, 10)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(initRel, 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	knob.BorderSizePixel = 0
	knob.ZIndex = 59
	knob.Parent = bar
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = knob
	end
	local dragging = false
	local function apply(rel)
		rel = math.clamp(rel, 0, 1)
		local val = minV + (maxV - minV) * rel
		set(val)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		lbl.Text = label .. ": " .. fmt(val)
	end
	local function fromInput(x)
		local abs = bar.AbsolutePosition.X
		local size = bar.AbsoluteSize.X
		if size <= 0 then return end
		apply((x - abs) / size)
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromInput(i.Position.X)
		end
	end)
	bar.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	knob.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	bind(UserInputService.InputChanged:Connect(function(i)
		if not dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			fromInput(i.Position.X)
		end
	end))
	bind(UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

local function rowBind(parent, label, key)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 17)
	row.BackgroundTransparency = 1
	row.ZIndex = 56
	row.Parent = parent
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.52, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = label
	lbl.ZIndex = 57
	lbl.Parent = row
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.48, -2, 0, 18)
	btn.Position = UDim2.new(0.52, 2, 0.5, -9)
	btn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Code
	btn.TextSize = 11
	btn.TextColor3 = Theme
	btn.Text = keyName(Config.Binds[key])
	btn.ZIndex = 57
	btn.Parent = row
	addOutline(btn, 1)
	local listening = false
	btn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		btn.Text = "..."
		local conn
		conn = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					Config.Binds[key] = nil
				else
					Config.Binds[key] = input.KeyCode
				end
				btn.Text = keyName(Config.Binds[key])
				listening = false
				conn:Disconnect()
				if refreshKeybindOverlay then refreshKeybindOverlay() end
			end
		end)
	end)
end

local function rowColor(parent, label, getCol, setCol)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 17)
	row.BackgroundTransparency = 1
	row.ZIndex = 56
	row.Parent = parent
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -28, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 11
	lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = label
	lbl.ZIndex = 57
	lbl.Parent = row
	local swatch = Instance.new("TextButton")
	swatch.Size = UDim2.fromOffset(22, 14)
	swatch.Position = UDim2.new(1, -22, 0.5, -7)
	swatch.BackgroundColor3 = getCol()
	swatch.BorderSizePixel = 0
	swatch.Text = ""
	swatch.ZIndex = 57
	swatch.Parent = row
	addOutline(swatch, 1)
	local pickerOpen = false
	local pickerFrame = nil
	swatch.MouseButton1Click:Connect(function()
		if pickerOpen and pickerFrame then
			pickerFrame:Destroy()
			pickerFrame = nil
			pickerOpen = false
			return
		end
		pickerOpen = true
		pickerFrame = Instance.new("Frame")
		pickerFrame.Size = UDim2.fromOffset(160, 118)
		pickerFrame.Position = UDim2.fromOffset(swatch.AbsolutePosition.X - menu.AbsolutePosition.X - 130, swatch.AbsolutePosition.Y - menu.AbsolutePosition.Y + 18)
		pickerFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		pickerFrame.BorderSizePixel = 0
		pickerFrame.ZIndex = 80
		pickerFrame.Parent = menu
		addOutline(pickerFrame, 1)
		do
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 3)
			c.Parent = pickerFrame
		end
		local cur = getCol()
		local channels = {
			{ "R", cur.R },
			{ "G", cur.G },
			{ "B", cur.B },
		}
		local fills = {}
		local function commit()
			local ncol = Color3.new(channels[1][2], channels[2][2], channels[3][2])
			setCol(ncol)
			swatch.BackgroundColor3 = ncol
			applyTheme(ncol)
		end
		for i, ch in ipairs(channels) do
			local y = 6 + (i - 1) * 28
			local tl = Instance.new("TextLabel")
			tl.Size = UDim2.fromOffset(14, 14)
			tl.Position = UDim2.fromOffset(6, y)
			tl.BackgroundTransparency = 1
			tl.Font = Enum.Font.Code
			tl.TextSize = 11
			tl.TextColor3 = Color3.fromRGB(200, 200, 200)
			tl.Text = ch[1]
			tl.ZIndex = 81
			tl.Parent = pickerFrame
			local bar = Instance.new("Frame")
			bar.Size = UDim2.fromOffset(110, 8)
			bar.Position = UDim2.fromOffset(24, y + 3)
			bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			bar.BorderSizePixel = 0
			bar.ZIndex = 81
			bar.Parent = pickerFrame
			addOutline(bar, 1)
			local fill = Instance.new("Frame")
			fill.Size = UDim2.new(ch[2], 0, 1, 0)
			fill.BackgroundColor3 = Theme
			fill.BorderSizePixel = 0
			fill.ZIndex = 82
			fill.Parent = bar
			fills[i] = fill
			local dragging = false
			local function upd(x)
				local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
				channels[i][2] = rel
				fill.Size = UDim2.new(rel, 0, 1, 0)
				commit()
			end
			bar.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					upd(inp.Position.X)
				end
			end)
			bar.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			bind(UserInputService.InputChanged:Connect(function(inp)
				if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
					upd(inp.Position.X)
				end
			end))
		end
		local closeP = Instance.new("TextButton")
		closeP.Size = UDim2.new(1, -12, 0, 18)
		closeP.Position = UDim2.fromOffset(6, 94)
		closeP.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		closeP.BorderSizePixel = 0
		closeP.Font = Enum.Font.Code
		closeP.TextSize = 11
		closeP.TextColor3 = Color3.fromRGB(220, 220, 220)
		closeP.Text = "done"
		closeP.ZIndex = 81
		closeP.Parent = pickerFrame
		addOutline(closeP, 1)
		closeP.MouseButton1Click:Connect(function()
			if pickerFrame then pickerFrame:Destroy() end
			pickerFrame = nil
			pickerOpen = false
		end)
	end)
	return swatch
end

-- ===================== MAIN =====================
do
	local g = group(L(pages.main), "Menu")
	local menuKeyRow = Instance.new("Frame")
	menuKeyRow.Size = UDim2.new(1, 0, 0, 19)
	menuKeyRow.BackgroundTransparency = 1
	menuKeyRow.ZIndex = 56
	menuKeyRow.Parent = g
	local mkLbl = Instance.new("TextLabel")
	mkLbl.Size = UDim2.new(0.55, 0, 1, 0)
	mkLbl.BackgroundTransparency = 1
	mkLbl.Font = Enum.Font.Code
	mkLbl.TextSize = 12
	mkLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	mkLbl.TextXAlignment = Enum.TextXAlignment.Left
	mkLbl.Text = "Menu bind"
	mkLbl.ZIndex = 57
	mkLbl.Parent = menuKeyRow
	local mkBtn = Instance.new("TextButton")
	mkBtn.Size = UDim2.new(0.45, -2, 0, 18)
	mkBtn.Position = UDim2.new(0.55, 2, 0.5, -9)
	mkBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	mkBtn.BorderSizePixel = 0
	mkBtn.Font = Enum.Font.Code
	mkBtn.TextSize = 11
	mkBtn.TextColor3 = Theme
	mkBtn.Text = keyName(Config.Menu.Key)
	mkBtn.ZIndex = 57
	mkBtn.Parent = menuKeyRow
	addOutline(mkBtn, 1)
	local listeningMenu = false
	mkBtn.MouseButton1Click:Connect(function()
		if listeningMenu then return end
		listeningMenu = true
		mkBtn.Text = "..."
		local conn
		conn = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode ~= Enum.KeyCode.Escape then
					Config.Menu.Key = input.KeyCode
				end
				mkBtn.Text = keyName(Config.Menu.Key)
				listeningMenu = false
				conn:Disconnect()
			end
		end)
	end)
	rowSlider(g, "Menu transparency", 0, 100, function()
		return 100
	end, function(v)
		menu.BackgroundTransparency = math.clamp(1 - (v / 100), 0, 0.85)
	end)
	rowToggle(g, "Keybind Menu Mode", function()
		return Config.KeybindList.Enabled
	end, function(v)
		Config.KeybindList.Enabled = v
		if kbOverlay then kbOverlay.Visible = v end
	end)
	rowToggle(g, "Toggled", function()
		return menuVisible
	end, function(v)
		menuVisible = v
		menu.Visible = v
	end)

	local gN = group(R(pages.main), "Notifications")
	rowToggle(gN, "Enabled", function() return true end, function() end)
end

-- ===================== WORLD =====================
do
	local g = group(L(pages.world), "Lighting")
	rowToggle(g, "Fullbright", function()
		return Config.Fullbright.Enabled
	end, function(v)
		Config.Fullbright.Enabled = v
		applyFullbright(v)
	end)
	rowToggle(g, "No fog", function()
		return Config.NoFog and Config.NoFog.Enabled
	end, function(v)
		Config.NoFog = Config.NoFog or {}
		Config.NoFog.Enabled = v
		if v then
			Lighting.FogEnd = 1e6
			Lighting.FogStart = 0
		end
	end)
	rowToggle(g, "Custom time", function()
		return Config.TimeOfDay and Config.TimeOfDay.Enabled
	end, function(v)
		Config.TimeOfDay = Config.TimeOfDay or { Clock = 14 }
		Config.TimeOfDay.Enabled = v
		if v then Lighting.ClockTime = Config.TimeOfDay.Clock or 14 end
	end)
	rowSlider(g, "Clock time", 0, 24, function()
		return (Config.TimeOfDay and Config.TimeOfDay.Clock) or 14
	end, function(v)
		Config.TimeOfDay = Config.TimeOfDay or {}
		Config.TimeOfDay.Clock = v
		if Config.TimeOfDay.Enabled then Lighting.ClockTime = v end
	end)
	rowToggle(g, "Fog control", function()
		return Config.Fog and Config.Fog.Enabled
	end, function(v)
		Config.Fog = Config.Fog or {}
		Config.Fog.Enabled = v
	end)
	rowSlider(g, "Fog end", 50, 2000, function()
		return (Config.Fog and Config.Fog.End) or 500
	end, function(v)
		Config.Fog = Config.Fog or {}
		Config.Fog.End = v
		if Config.Fog.Enabled then Lighting.FogEnd = v end
	end)

	local gFx = group(L(pages.world), "Effects")
	rowToggle(gFx, "Bloom", function()
		return Config.Bloom and Config.Bloom.Enabled
	end, function(v)
		Config.Bloom = Config.Bloom or {}
		Config.Bloom.Enabled = v
		pcall(function()
			local b = Lighting:FindFirstChild("GP_Bloom")
			if v then
				if not b then
					b = Instance.new("BloomEffect")
					b.Name = "GP_Bloom"
					b.Parent = Lighting
				end
				b.Intensity = Config.Bloom.Intensity or 0.4
				b.Size = Config.Bloom.Size or 24
				b.Enabled = true
			elseif b then
				b.Enabled = false
			end
		end)
	end)
	rowSlider(gFx, "Bloom intensity", 0, 2, function()
		return (Config.Bloom and Config.Bloom.Intensity) or 0.4
	end, function(v)
		Config.Bloom = Config.Bloom or {}
		Config.Bloom.Intensity = v
		local b = Lighting:FindFirstChild("GP_Bloom")
		if b then b.Intensity = v end
	end)
	rowToggle(gFx, "Color grade", function()
		return Config.ColorCorrection and Config.ColorCorrection.Enabled
	end, function(v)
		Config.ColorCorrection = Config.ColorCorrection or {}
		Config.ColorCorrection.Enabled = v
		pcall(function()
			local cc = Lighting:FindFirstChild("GP_CC")
			if v then
				if not cc then
					cc = Instance.new("ColorCorrectionEffect")
					cc.Name = "GP_CC"
					cc.Parent = Lighting
				end
				cc.Saturation = Config.ColorCorrection.Saturation or 0.2
				cc.Contrast = Config.ColorCorrection.Contrast or 0.1
				cc.Enabled = true
			elseif cc then
				cc.Enabled = false
			end
		end)
	end)
	rowSlider(gFx, "Saturation", -1, 1, function()
		return (Config.ColorCorrection and Config.ColorCorrection.Saturation) or 0.2
	end, function(v)
		Config.ColorCorrection = Config.ColorCorrection or {}
		Config.ColorCorrection.Saturation = v
		local cc = Lighting:FindFirstChild("GP_CC")
		if cc then cc.Saturation = v end
	end)

	local gSky = group(R(pages.world), "Skybox")
	for _, name in ipairs({ "Default", "Nebula", "Night", "Pink", "Space" }) do
		rowBtn(gSky, name, function() applySkybox(name) end)
	end

	local gW = group(R(pages.world), "World style")
	rowToggle(gW, "Dark mode", function()
		return Config.World and Config.World.DarkMode
	end, function(v)
		Config.World = Config.World or {}
		Config.World.DarkMode = v
		if v then
			Lighting.Brightness = 0.5
			Lighting.Ambient = Color3.fromRGB(40, 40, 55)
			Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 40)
			Lighting.ClockTime = 0
		end
	end)
	rowToggle(gW, "Neon world", function()
		return Config.World and Config.World.NeonWorld
	end, function(v)
		Config.World = Config.World or {}
		Config.World.NeonWorld = v
		if v then
			Lighting.Ambient = Color3.fromRGB(80, 40, 120)
			Lighting.OutdoorAmbient = Color3.fromRGB(60, 20, 100)
			Lighting.Brightness = 1.5
		end
	end)
	rowBtn(gW, "Reset lighting", function()
		pcall(function()
			Config.Fullbright.Enabled = false
			applyFullbright(false)
			Config.NoFog = Config.NoFog or {}; Config.NoFog.Enabled = false
			Config.TimeOfDay = Config.TimeOfDay or {}; Config.TimeOfDay.Enabled = false
			Config.Fog = Config.Fog or {}; Config.Fog.Enabled = false
			Config.World = Config.World or {}
			Config.World.DarkMode = false
			Config.World.NeonWorld = false
			local b = Lighting:FindFirstChild("GP_Bloom"); if b then b.Enabled = false end
			local cc = Lighting:FindFirstChild("GP_CC"); if cc then cc.Enabled = false end
			applySkybox("Default")
		end)
	end)
end

-- ===================== ESP =====================
do
	local g = group(L(pages.esp), "ESP")
	rowToggle(g, "Enabled", function() return Config.ESP.Enabled end, function(v) Config.ESP.Enabled = v end)
	rowToggle(g, "Boxes", function() return Config.ESP.Boxes end, function(v) Config.ESP.Boxes = v end)
	rowToggle(g, "Names", function() return Config.ESP.Names end, function(v) Config.ESP.Names = v end)
	rowToggle(g, "Distance", function() return Config.ESP.Distance end, function(v) Config.ESP.Distance = v end)
	rowToggle(g, "Team check", function() return Config.ESP.TeamCheck end, function(v) Config.ESP.TeamCheck = v end)
	rowSlider(g, "Max distance", 200, 2500, function() return Config.ESP.MaxDistance end, function(v) Config.ESP.MaxDistance = v end)

	local gT = group(R(pages.esp), "Tracers")
	rowToggle(gT, "Enabled", function() return Config.Tracers.Enabled end, function(v)
		Config.Tracers.Enabled = v
		if not v then clearTracers() end
	end)
	rowToggle(gT, "Team check", function() return Config.Tracers.TeamCheck end, function(v) Config.Tracers.TeamCheck = v end)
end

-- ===================== VISUALS =====================
do
	local g = group(L(pages.visuals), "FOV")
	rowToggle(g, "Enabled", function() return Config.FOVCircle.Enabled end, function(v) Config.FOVCircle.Enabled = v end)
	rowToggle(g, "Filled", function() return Config.FOVCircle.Filled end, function(v) Config.FOVCircle.Filled = v end)
	rowToggle(g, "Animate", function() return Config.FOVCircle.Animate end, function(v) Config.FOVCircle.Animate = v end)
	rowSlider(g, "Radius", 40, 300, function() return Config.FOVCircle.Radius or 140 end, function(v) Config.FOVCircle.Radius = v end)
	rowSlider(g, "Fill transparency", 0.3, 0.95, function() return Config.FOVCircle.FillTransparency or 0.75 end, function(v) Config.FOVCircle.FillTransparency = v end)

	local gC = group(R(pages.visuals), "Crosshair")
	rowToggle(gC, "Enabled", function() return Config.Crosshair.Enabled end, function(v) Config.Crosshair.Enabled = v end)
	rowToggle(gC, "Spin", function() return Config.Crosshair.Animate end, function(v) Config.Crosshair.Animate = v end)
	rowSlider(gC, "Size", 6, 30, function() return Config.Crosshair.Size or 14 end, function(v) Config.Crosshair.Size = v end)
	rowSlider(gC, "Gap", 0, 16, function() return Config.Crosshair.Gap or 5 end, function(v) Config.Crosshair.Gap = v end)
	rowSlider(gC, "Thickness", 1, 5, function() return Config.Crosshair.Thickness or 2 end, function(v) Config.Crosshair.Thickness = v end)
	rowSlider(gC, "Spin speed", 0.5, 8, function() return Config.Crosshair.SpinSpeed or 2.5 end, function(v) Config.Crosshair.SpinSpeed = v end)

	local gW = group(L(pages.visuals), "Wireframe Weapons")
	rowToggle(gW, "Enabled", function() return Config.WireframeWeapons.Enabled end, function(v)
		Config.WireframeWeapons.Enabled = v
		if not v then clearWireframe() end
	end)
	rowToggle(gW, "Local only", function() return Config.WireframeWeapons.LocalOnly end, function(v) Config.WireframeWeapons.LocalOnly = v end)
end

-- ===================== CHARACTER =====================
do
	local g = group(L(pages.character), "Movement")
	rowToggle(g, "Fly", function() return Config.Fly.Enabled end, function(v)
		Config.Fly.Enabled = v
		if not v then stopFly() end
	end)
	rowSlider(g, "Fly speed", 20, 200, function() return Config.Fly.Speed end, function(v) Config.Fly.Speed = v end)
	rowToggle(g, "WalkSpeed", function() return Config.Movement.WalkSpeedEnabled end, function(v) Config.Movement.WalkSpeedEnabled = v end)
	rowSlider(g, "Walk speed", 16, 100, function() return Config.Movement.WalkSpeed end, function(v) Config.Movement.WalkSpeed = v end)
	rowToggle(g, "NoClip", function() return Config.Movement.NoClip end, function(v)
		Config.Movement.NoClip = v
		setNoClip(v)
	end)
	rowToggle(g, "Infinite jump", function() return Config.Movement.InfiniteJump end, function(v) Config.Movement.InfiniteJump = v end)
	rowToggle(g, "Long jump", function() return Config.Movement.LongJump end, function(v) Config.Movement.LongJump = v end)

	local g2 = group(R(pages.character), "Camera / Gun")
	rowToggle(g2, "Third person", function() return Config.ThirdPerson.Enabled end, function(v) Config.ThirdPerson.Enabled = v end)
	rowSlider(g2, "Distance", 4, 20, function() return Config.ThirdPerson.Distance end, function(v) Config.ThirdPerson.Distance = v end)
	rowToggle(g2, "No recoil", function() return Config.NoRecoil.Enabled end, function(v) Config.NoRecoil.Enabled = v end)

	
local gLoot = group(R(pages.character), "Auto Loot (FFA)")
	rowToggle(gLoot, "Enabled", function() return Config.AutoLoot.Enabled end, function(v) Config.AutoLoot.Enabled = v end)
	rowToggle(gLoot, "Auto heal", function() return Config.AutoLoot.Heal ~= false end, function(v) Config.AutoLoot.Heal = v end)
	rowToggle(gLoot, "Auto ammo", function() return Config.AutoLoot.Ammo ~= false end, function(v) Config.AutoLoot.Ammo = v end)
	rowSlider(gLoot, "Range", 20, 200, function() return Config.AutoLoot.Range or 80 end, function(v) Config.AutoLoot.Range = v end)
	rowSlider(gLoot, "Interval", 0.15, 1, function() return Config.AutoLoot.Interval or 0.35 end, function(v) Config.AutoLoot.Interval = v end)

local g3 = group(L(pages.character), "Anti Aim")
	rowToggle(g3, "Enabled", function() return Config.AntiAim.Enabled end, function(v) Config.AntiAim.Enabled = v end)
	rowToggle(g3, "Jitter", function() return Config.AntiAim.Jitter end, function(v) Config.AntiAim.Jitter = v end)
	rowToggle(g3, "Desync limbs", function() return Config.AntiAim.Desync end, function(v) Config.AntiAim.Desync = v end)
	rowToggle(g3, "Underground", function() return Config.AntiAim.Underground end, function(v) Config.AntiAim.Underground = v end)
	rowSlider(g3, "Spin speed", 10, 120, function() return Config.AntiAim.SpinSpeed end, function(v) Config.AntiAim.SpinSpeed = v end)
	rowSlider(g3, "Under depth", 2, 20, function() return Config.AntiAim.UndergroundDepth end, function(v) Config.AntiAim.UndergroundDepth = v end)

	local g4 = group(R(pages.character), "Ragebot")
	rowToggle(g4, "Enabled", function() return Config.Ragebot.Enabled end, function(v) Config.Ragebot.Enabled = v end)
	rowToggle(g4, "Wallbang", function() return Config.Ragebot.Wallbang end, function(v) Config.Ragebot.Wallbang = v end)
	rowToggle(g4, "Anti katana", function() return Config.Ragebot.AntiKatana end, function(v) Config.Ragebot.AntiKatana = v end)
	rowToggle(g4, "No anim", function() return Config.Ragebot.NoAnim end, function(v) Config.Ragebot.NoAnim = v end)
	rowToggle(g4, "Headshots only", function() return Config.Ragebot.HeadOnly end, function(v) Config.Ragebot.HeadOnly = v end)
	rowToggle(g4, "Invert camera", function() return Config.Ragebot.InvertCamera ~= false end, function(v) Config.Ragebot.InvertCamera = v end)
	rowToggle(g4, "Multi target", function() return Config.Ragebot.MultiTarget ~= false end, function(v) Config.Ragebot.MultiTarget = v end)
	rowSlider(g4, "Orbit speed", 4, 40, function() return Config.Ragebot.OrbitSpeed end, function(v) Config.Ragebot.OrbitSpeed = v end)
	rowSlider(g4, "Orbit radius", 1.5, 12, function() return Config.Ragebot.OrbitRadius end, function(v) Config.Ragebot.OrbitRadius = v end)
	rowSlider(g4, "Height", 0.5, 8, function() return Config.Ragebot.Height or 2 end, function(v) Config.Ragebot.Height = v end)
	rowSlider(g4, "Shoot delay", 0.01, 0.15, function() return Config.Ragebot.ShootDelay end, function(v) Config.Ragebot.ShootDelay = v end)
	rowSlider(g4, "Snap distance", 0.8, 4, function() return Config.Ragebot.SnapDistance or 1.8 end, function(v) Config.Ragebot.SnapDistance = v end)
	rowSlider(g4, "Max range", 50, 800, function() return Config.Ragebot.MaxRange or 500 end, function(v) Config.Ragebot.MaxRange = v end)
	rowSlider(g4, "AntiLegit speed", 4, 40, function() return Config.Ragebot.AntiLegitSpeed or 14 end, function(v) Config.Ragebot.AntiLegitSpeed = v end)
	rowSlider(g4, "Anti depth", 2, 20, function() return Config.Ragebot.AntiDepth or 6 end, function(v) Config.Ragebot.AntiDepth = v end)
	local modeBtn
	modeBtn = rowBtn(g4, "Mode: " .. (Config.Ragebot.Mode or "Orbit"), function()
		local modes = { "Orbit", "SideTP", "AntiLegit" }
		local i = table.find(modes, Config.Ragebot.Mode) or 1
		Config.Ragebot.Mode = modes[(i % #modes) + 1]
		modeBtn.Text = "Mode: " .. Config.Ragebot.Mode
	end)

local gAim = group(L(pages.character), "Aimbot")
	rowToggle(gAim, "Enabled", function() return Config.Aimbot.Enabled end, function(v) Config.Aimbot.Enabled = v end)
	rowToggle(gAim, "Wallbang", function() return Config.Aimbot.Wallbang end, function(v) Config.Aimbot.Wallbang = v end)
	rowToggle(gAim, "Sticky", function() return Config.Aimbot.Sticky end, function(v) Config.Aimbot.Sticky = v end)
	rowSlider(gAim, "FOV", 40, 300, function() return Config.Aimbot.FOV or 120 end, function(v) Config.Aimbot.FOV = v end)
	rowSlider(gAim, "Smooth", 0.02, 0.6, function() return Config.Aimbot.Smooth or 0.18 end, function(v) Config.Aimbot.Smooth = v end)
	rowSlider(gAim, "Prediction", 0, 0.2, function() return Config.Aimbot.Prediction or 0.06 end, function(v) Config.Aimbot.Prediction = v end)

local g5 = group(L(pages.character), "Triggerbot")
	rowToggle(g5, "Enabled", function() return Config.Triggerbot.Enabled end, function(v) Config.Triggerbot.Enabled = v end)
	rowToggle(g5, "Wallbang", function() return Config.Triggerbot.Wallbang end, function(v) Config.Triggerbot.Wallbang = v end)
	rowSlider(g5, "Delay", 0.01, 0.2, function() return Config.Triggerbot.Delay or 0.05 end, function(v) Config.Triggerbot.Delay = v end)
	rowSlider(g5, "FOV", 5, 80, function() return Config.Triggerbot.FOV or 28 end, function(v) Config.Triggerbot.FOV = v end)

	local g6 = group(R(pages.character), "Void Spam")
	rowToggle(g6, "Enabled", function() return Config.VoidSpam.Enabled end, function(v) Config.VoidSpam.Enabled = v end)
	rowSlider(g6, "Distance", 50, 500, function() return Config.VoidSpam.Distance end, function(v) Config.VoidSpam.Distance = v end)
	rowSlider(g6, "Return delay", 0.02, 0.3, function() return Config.VoidSpam.ReturnDelay end, function(v) Config.VoidSpam.ReturnDelay = v end)
	rowSlider(g6, "Interval", 0.1, 1, function() return Config.VoidSpam.Interval end, function(v) Config.VoidSpam.Interval = v end)
end

-- ===================== MISC =====================
do
	local g = group(L(pages.misc), "Keybinds")
	rowBind(g, "Ragebot", "Ragebot")
	rowBind(g, "Fly", "Fly")
	rowBind(g, "ESP", "ESP")
	rowBind(g, "NoClip", "NoClip")
	rowBind(g, "Triggerbot", "Triggerbot")

	local g2 = group(R(pages.misc), "Utility")
	rowBtn(g2, "Unlock All (client)", function() runUnlockAll() end)
	rowBtn(g2, "Unload", function()
		UNLOADED = true
		pcall(function() aaRestoreMotors() end)
		for _, c in ipairs(CONNECTIONS) do
			pcall(function() c:Disconnect() end)
		end
		pcall(function() rootGui:Destroy() end)
		print("[Ghost Protocol] unloaded")
	end)
end

-- ===================== SETTINGS — exact Unnamed layout =====================
do
	-- LEFT column
	local gMenu = group(L(pages.settings), "Menu")
	local menuKeyRow = Instance.new("Frame")
	menuKeyRow.Size = UDim2.new(1, 0, 0, 19)
	menuKeyRow.BackgroundTransparency = 1
	menuKeyRow.ZIndex = 56
	menuKeyRow.Parent = gMenu
	local mkLbl = Instance.new("TextLabel")
	mkLbl.Size = UDim2.new(0.55, 0, 1, 0)
	mkLbl.BackgroundTransparency = 1
	mkLbl.Font = Enum.Font.Code
	mkLbl.TextSize = 12
	mkLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	mkLbl.TextXAlignment = Enum.TextXAlignment.Left
	mkLbl.Text = "Menu bind"
	mkLbl.ZIndex = 57
	mkLbl.Parent = menuKeyRow
	local mkBtn = Instance.new("TextButton")
	mkBtn.Size = UDim2.new(0.45, -2, 0, 18)
	mkBtn.Position = UDim2.new(0.55, 2, 0.5, -9)
	mkBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	mkBtn.BorderSizePixel = 0
	mkBtn.Font = Enum.Font.Code
	mkBtn.TextSize = 11
	mkBtn.TextColor3 = Theme
	mkBtn.Text = keyName(Config.Menu.Key)
	mkBtn.ZIndex = 57
	mkBtn.Parent = menuKeyRow
	addOutline(mkBtn, 1)
	local listeningMenu2 = false
	mkBtn.MouseButton1Click:Connect(function()
		if listeningMenu2 then return end
		listeningMenu2 = true
		mkBtn.Text = "..."
		local conn
		conn = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode ~= Enum.KeyCode.Escape then
					Config.Menu.Key = input.KeyCode
				end
				mkBtn.Text = keyName(Config.Menu.Key)
				listeningMenu2 = false
				conn:Disconnect()
			end
		end)
	end)
	rowSlider(gMenu, "Menu transparency", 0, 100, function() return 100 end, function(v)
		menu.BackgroundTransparency = math.clamp(1 - (v / 100), 0, 0.85)
	end)
	rowToggle(gMenu, "Keybind Menu Mode", function()
		return Config.KeybindList.Enabled
	end, function(v)
		Config.KeybindList.Enabled = v
		if kbOverlay then kbOverlay.Visible = v end
	end)
	rowToggle(gMenu, "Toggled", function()
		return menuVisible
	end, function(v)
		menuVisible = v
		menu.Visible = v
	end)

	local gTheme = group(L(pages.settings), "Themes")
	rowColor(gTheme, "Main Color", function() return Theme end, function(c) applyTheme(c) end)
	rowColor(gTheme, "Accent Color", function() return Theme end, function(c) applyTheme(c) end)
	rowColor(gTheme, "Background Color", function()
		return Color3.fromRGB(20, 20, 20)
	end, function(c)
		menu.BackgroundColor3 = c
	end)
	rowColor(gTheme, "Outline Color", function()
		return Theme
	end, function(c)
		for _, st in ipairs(OutlineEls) do
			pcall(function() st.Color = c end)
		end
	end)
	rowColor(gTheme, "Text Color", function()
		return Color3.fromRGB(230, 230, 230)
	end, function(c)
		titleMain.TextColor3 = c
	end)
	rowColor(gTheme, "Risk Text Color", function()
		return Color3.fromRGB(255, 80, 80)
	end, function(c) end)

	rowBtn(gTheme, "Theme list", function() end)
	rowBtn(gTheme, "Default", function() end)
	rowBtn(gTheme, "Default", function() end)
	rowBtn(gTheme, "Set Default", function()
		applyTheme(Color3.fromRGB(59, 91, 255))
	end)
	rowBtn(gTheme, "Custom theme name", function() end)
	rowBtn(gTheme, "Create theme", function() end)
	rowBtn(gTheme, "Custom themes", function() end)
	rowBtn(gTheme, "...", function() end)
	rowBtn(gTheme, "Load theme", function() end)
	rowBtn(gTheme, "Overwrite Theme", function() end)
	rowBtn(gTheme, "Delete Theme", function() end)
	rowBtn(gTheme, "Set Default", function()
		applyTheme(Color3.fromRGB(59, 91, 255))
	end)
	rowBtn(gTheme, "Reset Default", function()
		applyTheme(Color3.fromRGB(59, 91, 255))
	end)
	rowBtn(gTheme, "Refresh", function() end)

	-- RIGHT column
	local gCfg = group(R(pages.settings), "Configuration")
	local nameBox = Instance.new("TextBox")
	nameBox.Size = UDim2.new(1, 0, 0, 18)
	nameBox.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	nameBox.BorderSizePixel = 0
	nameBox.Font = Enum.Font.Code
	nameBox.TextSize = 12
	nameBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	nameBox.PlaceholderText = "Config name"
	nameBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
	nameBox.Text = ""
	nameBox.ClearTextOnFocus = false
	nameBox.ZIndex = 58
	nameBox.Parent = gCfg
	addOutline(nameBox, 1)

	local statusLbl = Instance.new("TextLabel")
	statusLbl.Size = UDim2.new(1, 0, 0, 16)
	statusLbl.BackgroundTransparency = 1
	statusLbl.Font = Enum.Font.Code
	statusLbl.TextSize = 11
	statusLbl.TextColor3 = Color3.fromRGB(160, 160, 160)
	statusLbl.TextXAlignment = Enum.TextXAlignment.Left
	statusLbl.Text = "Current autoload config: " .. (getAutoload() ~= "" and getAutoload() or "(none)")
	statusLbl.ZIndex = 57
	statusLbl.Parent = gCfg

	rowBtn(gCfg, "Create config", function()
		local n = nameBox.Text
		if n == "" then n = "default" end
		if saveConfig(n) then
			statusLbl.Text = "created " .. n
		else
			statusLbl.Text = "create failed (no FS)"
		end
	end)
	rowBtn(gCfg, "Load config", function()
		local n = nameBox.Text
		if n == "" then n = getAutoload() end
		if loadConfig(n) then
			statusLbl.Text = "loaded " .. n
		else
			statusLbl.Text = "load failed"
		end
	end)
	rowBtn(gCfg, "Overwrite config", function()
		local n = nameBox.Text
		if n == "" then return end
		if saveConfig(n) then
			statusLbl.Text = "overwrote " .. n
		else
			statusLbl.Text = "overwrite failed"
		end
	end)
	rowBtn(gCfg, "Delete config", function()
		local n = nameBox.Text
		if n == "" or not isfile then return end
		local path = CONFIG_FOLDER .. "/" .. n .. ".json"
		if isfile(path) and delfile then
			pcall(function() delfile(path) end)
			statusLbl.Text = "deleted " .. n
		end
	end)
	rowBtn(gCfg, "Refresh list", function()
		statusLbl.Text = "refreshed"
	end)
	rowBtn(gCfg, "Set autoload", function()
		local n = nameBox.Text
		if n == "" then
			statusLbl.Text = "type a config name first"
			return
		end
		-- save current settings under that name then set autoload
		saveConfig(n)
		setAutoload(n)
		statusLbl.Text = "Current autoload config: " .. n
		print("[Ghost Protocol] Set autoload + saved:", n)
	end)
	rowBtn(gCfg, "Remove autoload", function()
		setAutoload("")
		statusLbl.Text = "Current autoload config: (none)"
	end)

	local gList = group(R(pages.settings), "config list")
	rowBtn(gList, "[LEGIT] Rem's Config", function()
		nameBox.Text = "Rem's Config"
		if loadConfig("Rem's Config") then
			statusLbl.Text = "loaded Rem's Config"
		end
	end)
	rowBtn(gList, "load config", function()
		local n = nameBox.Text
		if loadConfig(n) then
			statusLbl.Text = "loaded " .. n
		else
			statusLbl.Text = "load failed"
		end
	end)

	local gLua = group(R(pages.settings), "lua")
	local luaLbl = Instance.new("TextLabel")
	luaLbl.Size = UDim2.new(1, 0, 0, 16)
	luaLbl.BackgroundTransparency = 1
	luaLbl.Font = Enum.Font.Code
	luaLbl.TextSize = 11
	luaLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
	luaLbl.TextXAlignment = Enum.TextXAlignment.Left
	luaLbl.Text = "in development"
	luaLbl.ZIndex = 57
	luaLbl.Parent = gLua

	local gComm = group(R(pages.settings), "community configs")
	rowBtn(gComm, "browse (stub)", function()
		statusLbl.Text = "community configs coming"
	end)
end

switchTab("settings")

-- KEYBIND OVERLAY (draggable, no watermark)
local kbOverlay = Instance.new("Frame")
kbOverlay.Name = "KeybindOverlay"
kbOverlay.Size = UDim2.fromOffset(160, 0)
kbOverlay.AutomaticSize = Enum.AutomaticSize.Y
kbOverlay.Position = UDim2.fromOffset(12, 120)
kbOverlay.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
kbOverlay.BorderSizePixel = 0
kbOverlay.ZIndex = 40
kbOverlay.Active = true
kbOverlay.Visible = Config.KeybindList.Enabled
kbOverlay.Parent = rootGui
addOutline(kbOverlay, 1)
local kbPad = Instance.new("UIPadding", kbOverlay)
kbPad.PaddingTop = UDim.new(0, 6)
kbPad.PaddingBottom = UDim.new(0, 6)
kbPad.PaddingLeft = UDim.new(0, 8)
kbPad.PaddingRight = UDim.new(0, 8)
local kbLayout = Instance.new("UIListLayout", kbOverlay)
kbLayout.Padding = UDim.new(0, 2)
local kbTitle = Instance.new("TextLabel")
kbTitle.Size = UDim2.new(1, 0, 0, 18)
kbTitle.BackgroundTransparency = 1
kbTitle.Font = Enum.Font.Code
kbTitle.TextSize = 12
kbTitle.TextColor3 = Theme
kbTitle.TextXAlignment = Enum.TextXAlignment.Left
kbTitle.Text = "keybinds"
kbTitle.ZIndex = 41
kbTitle.Parent = kbOverlay
table.insert(AccentEls, kbTitle)
local kbRows = {}

function refreshKeybindOverlay()
	for _, r in ipairs(kbRows) do
		pcall(function()
			r:Destroy()
		end)
	end
	kbRows = {}
	local function add(name, key)
		if not key or key == "-" then
			return
		end
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 16)
		row.BackgroundTransparency = 1
		row.ZIndex = 41
		row.Parent = kbOverlay
		local n = Instance.new("TextLabel")
		n.Size = UDim2.new(0.55, 0, 1, 0)
		n.BackgroundTransparency = 1
		n.Font = Enum.Font.Code
		n.TextSize = 11
		n.TextColor3 = Theme
		n.TextXAlignment = Enum.TextXAlignment.Left
		n.Text = name
		n.ZIndex = 42
		n.Parent = row
		local k = Instance.new("TextLabel")
		k.Size = UDim2.new(0.45, 0, 1, 0)
		k.Position = UDim2.new(0.55, 0, 0, 0)
		k.BackgroundTransparency = 1
		k.Font = Enum.Font.Code
		k.TextSize = 11
		k.TextColor3 = Theme
		k.TextXAlignment = Enum.TextXAlignment.Right
		k.Text = key
		k.ZIndex = 42
		k.Parent = row
		table.insert(kbRows, row)
	end
	add("menu", "RSHIFT")
	add("aimbot", keyName(Config.Binds.Aimbot))
	add("silent", keyName(Config.Binds.SilentAim))
	add("trigger", keyName(Config.Binds.Triggerbot))
	add("rage", keyName(Config.Binds.Ragebot))
	add("fly", keyName(Config.Binds.Fly))
	add("esp", keyName(Config.Binds.ESP))
	add("noclip", keyName(Config.Binds.NoClip))
end
refreshKeybindOverlay()

-- drag keybind list
do
	local drag, start, pos
	kbOverlay.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag, start, pos = true, i.Position, kbOverlay.Position
		end
	end)
	kbOverlay.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = false
		end
	end)
	bind(UserInputService.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - start
			kbOverlay.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
		end
	end))
end

-- drag menu
do
	local drag, start, pos
	topBar.MouseButton1Down:Connect(function()
		drag = true
		start = UserInputService:GetMouseLocation()
		pos = menu.Position
	end)
	bind(UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = false
		end
	end))
	bind(UserInputService.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local m = UserInputService:GetMouseLocation()
			local d = m - start
			menu.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
		end
	end))
end

-- keybind toggles
bind(UserInputService.InputBegan:Connect(function(input, gpe)
	if UNLOADED then
		return
	end
	-- menu toggle must work even if game sinks input
	if input.KeyCode == Config.Menu.Key or input.KeyCode == Enum.KeyCode.RightControl then
		menuVisible = not menuVisible
		menu.Visible = menuVisible
		return
	end
	if gpe then
		return
	end
	local function toggle(mod)
		if mod == "Aimbot" then
			Config.Aimbot.Enabled = not Config.Aimbot.Enabled
		elseif mod == "SilentAim" then
			Config.SilentAim.Enabled = not Config.SilentAim.Enabled
		elseif mod == "Triggerbot" then
			Config.Triggerbot.Enabled = not Config.Triggerbot.Enabled
		elseif mod == "Ragebot" then
			Config.Ragebot.Enabled = not Config.Ragebot.Enabled
		elseif mod == "Fly" then
			Config.Fly.Enabled = not Config.Fly.Enabled
			if not Config.Fly.Enabled then
				stopFly()
			end
		elseif mod == "ESP" then
			Config.ESP.Enabled = not Config.ESP.Enabled
		elseif mod == "NoClip" then
			Config.Movement.NoClip = not Config.Movement.NoClip
			setNoClip(Config.Movement.NoClip)
		end
		if refreshKeybindOverlay then
			refreshKeybindOverlay()
		end
	end
	for name, code in pairs(Config.Binds) do
		if code and input.KeyCode == code then
			toggle(name)
		end
	end
end))

print("[Ghost Protocol] loaded - menu: RSHIFT or RCTRL")
menu.Visible = true
menuVisible = true
