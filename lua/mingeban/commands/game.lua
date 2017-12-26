
if SERVER then
	util.AddNetworkString("mingeban_command_kill")
	local kill = mingeban.CreateCommand({"kill", "wrist", "suicide"}, function(caller, line, maxVel, maxAngVel)
		local ok = hook.Run("CanPlayerSuicide", ply)
		if ok == false then
			return false, "Can't suicide"
		end

		caller:KillSilent()
		caller:CreateRagdoll()
		net.Start("mingeban_command_kill")
			net.WriteEntity(caller)
			net.WriteFloat(CurTime())
			net.WriteInt(maxVel or 0, 16)
			net.WriteInt(maxAngVel or 0, 16)
		net.Broadcast()
	end)
	kill:SetAllowConsole(false)
	kill:AddArgument(ARGTYPE_NUMBER)
		:SetOptional(true)
		:SetName("max velocity")
	kill:AddArgument(ARGTYPE_NUMBER)
		:SetOptional(true)
		:SetName("max angle velocity")

	local revive = mingeban.CreateCommand({"revive", "respawn"}, function(caller)
		if caller:Alive() then return end

		local oldPos, oldAng = caller:GetPos(), caller:EyeAngles()
		caller:Spawn()
		caller:SetPos(oldPos)
		caller:SetEyeAngles(oldAng)
	end)
	revive:SetAllowConsole(false)
	revive:SetHideChat(true)

	local cmd = mingeban.CreateCommand("cmd", function(caller, line)
		caller:SendLua(string.format("LocalPlayer():ConCommand(%q)", line))
	end)
	cmd:SetAllowConsole(false)

	local vol = mingeban.CreateCommand({"vol", "volume"}, function(caller, line)
		caller:ConCommand("mingeban cmd volume " .. line)
	end)
	vol:SetAllowConsole(false)

	local retry = mingeban.CreateCommand("retry", function(caller)
		caller:ConCommand("retry")
	end)
	retry:SetAllowConsole(false)

	local maps = mingeban.CreateCommand("maps", function(caller)
		for _, map in next, (file.Find("maps/*.bsp", "GAME")) do
			caller:PrintMessage(HUD_PRINTCONSOLE, map)
		end
	end)
	maps:SetAllowConsole(false)

	local noclip = mingeban.CreateCommand("noclip", function(caller)
		caller:ConCommand("noclip")
	end)
	noclip:SetAllowConsole(false)

	-- TODO: better clientside command system

	util.AddNetworkString("mingeban_command_tool")
	local tool = mingeban.CreateCommand("tool", function(caller, line, tool)
		net.Start("mingeban_command_tool")
			net.WriteString(tool)
		net.Send(caller)
	end)
	tool:SetAllowConsole(false)
	tool:AddArgument(ARGTYPE_STRING)
		:SetName("tool")

	util.AddNetworkString("mingeban_command_fps")
	local fps = mingeban.CreateCommand("fps", function(caller)
		net.Start("mingeban_command_fps")
		net.Send(caller)
	end)
	fps:SetAllowConsole(false)
	fps:SetHideChat(true)
	net.Receive("mingeban_command_fps", function(_, ply)
		local fps = math.ceil(net.ReadFloat())

		local col
		if fps >= 45 then
			col = Color(64, 255, 64)
		elseif fps < 45 and fps > 25 then
			col = Color(255, 255, 64)
		else
			col = Color(255, 64, 64)
		end

		local svfps = math.ceil(engine.ServerFPS())
		ChatAddText(col, ply:Nick(), "'s FPS: ", fps, ", server: ", svfps)
	end)

	local giveammo = mingeban.CreateCommand("giveammo", function(caller, line, amount)
		local wep = caller:GetActiveWeapon()
		amount = amount or 500

		if not IsValid(wep) then return end

		if wep:GetPrimaryAmmoType() ~= -1 then
			caller:GiveAmmo(amount, wep:GetPrimaryAmmoType())
		end

		if wep:GetSecondaryAmmoType() ~= -1 then
			caller:GiveAmmo(amount, wep:GetSecondaryAmmoType())
		end
	end)
	giveammo:SetAllowConsole(false)
	giveammo:AddArgument(ARGTYPE_NUMBER)
		:SetName("amount")
		:SetOptional(true)

	local exit = mingeban.CreateCommand({"exit", "quit"}, function(caller, line, ply, reason)
		if ply ~= caller and not caller:IsAdmin() then return false, "you can only exit other players if you are an admin" end
		if ply:IsBot() then ply:Kick(reason or "byebye!!") return end

		ply:SendLua[[RunConsoleCommand("gamemenucommand", "quit")]]
		timer.Simple(0.24, function()
			ply:Kick(reason:Trim() or "Disconnected by user.")
		end)
	end)
	exit:AddArgument(ARGTYPE_PLAYER)
	exit:AddArgument(ARGTYPE_STRING)
		:SetOptional(true)
		:SetName("reason")
	exit:SetAllowConsole(false)

	local PLAYER = FindMetaTable("Player")

	util.AddNetworkString("mingeban_command_ignorepac")
	local ignorepac = mingeban.CreateCommand("ignorepac", function(caller, line, ply)
		net.Start("mingeban_command_ignorepac")
			net.WriteEntity(ply)
		net.Send(caller)
	end)
	ignorepac:AddArgument(ARGTYPE_PLAYER)
	ignorepac:SetHideChat(true)

	hook.Add("Initialize", "mingeban_command_stormfox", function()
		if not StormFox then return end

		local validWeathers = {}
		for _, weather in pairs(StormFox.GetWeathers()) do
			validWeathers[weather] = true
		end

		local weather = mingeban.CreateCommand("weather", function(caller, line, weather, intensity)
			if validWeathers[weather:lower()] then
				StormFox.SetWeather(weather, intensity or 1)
			else
				local weathersStr = table.concat(table.GetKeys(), ", ")
				return false, "invalid weather type (valid types: " .. weathersStr .. ")"
			end
		end)
		weather:AddArgument(ARGTYPE_STRING)
		weather:AddArgument(ARGTYPE_NUMBER)
			:SetOptional(true)

		local time = mingeban.CreateCommand("time", function(caller, line, time)
			if time > 24 or time < 0 then return false, "invalid time" end

			StormFox.SetTime(time * 60)
		end)
		time:AddArgument(ARGTYPE_NUMBER)

		local temperature = mingeban.CreateCommand("temperature", function(caller, line, tempareture)
			StormFox.SetNetworkData("Temperature", temperature)
		end)
		temperature:AddArgument(ARGTYPE_NUMBER)
	end)
elseif CLIENT then
	local function rand(i)
		return util.SharedRandom(i, -1, 1)
	end
	net.Receive("mingeban_command_kill", function()
		local ply = net.ReadEntity()
		local time = net.ReadFloat()
		local maxVel = net.ReadInt(16)
		local maxAngVel = net.ReadInt(16)
		if maxVel == 0 and maxAngVel == 0 then return end
		if not ply.GetAimVector then return end

		local vel = ply:GetAimVector() * maxVel
		local angVel = Vector(rand(time .. "_x") * maxAngVel, rand(time .. "_y") * maxAngVel, rand(time .. "_z") * maxAngVel)

		local hookId = "_" .. ply:EntIndex() .. "_kill_ragdoll"
		hook.Add("OnEntityCreated", hookId, function(ent)
			if ent:GetClass() == "class C_HL2MPRagdoll" then
				local rag = ply:GetRagdollEntity()
				hook.Add("Think", hookId, function()
					if IsValid(rag) and IsValid(ent) and rag == ent then
						for i = 0, rag:GetPhysicsObjectCount() - 1 do
							local phys = rag:GetPhysicsObjectNum(i)
							if IsValid(phys) then
								phys:SetVelocity(vel)
								phys:AddAngleVelocity(angVel)
							end
						end
						local phys = rag:GetPhysicsObject()
						if IsValid(phys) then
							phys:SetVelocity(vel)
							phys:AddAngleVelocity(angVel)
							hook.Remove("Think", hookId)
						end
					end
					hook.Remove("OnEntityCreated", hookId)
				end)
			end
		end)
	end)

	net.Receive("mingeban_command_tool", function()
		local name = net.ReadString()

		local _tools = weapons.Get("gmod_tool").Tool
		local tools = {}
		for mode, _ in next, _tools do
			tools[#tools + 1] = mode
		end
		table.sort(tools, function(a, b)
			return #a < #b
		end)
		for _, mode in next, tools do
			local tool = _tools[mode]
			local toolName = language.GetPhrase(tool.Name and tool.Name:gsub("^#", "") or mode)
			if toolName:lower():find(name:lower()) then
				LocalPlayer():ConCommand("gmod_tool " .. mode)

				chat.AddText(color_white, "Found tool: " .. toolName)
				surface.PlaySound("garrysmod/content_downloaded.wav")
				return
			end
		end
	end)

	net.Receive("mingeban_command_fps", function()
		net.Start("mingeban_command_fps")
			net.WriteFloat(1 / FrameTime())
		net.SendToServer()
	end)

	net.Receive("mingeban_command_ignorepac", function()
		local ply = net.ReadEntity()
		if not ply.PacIgnored then
			chat.AddText(Color(208, 135, 112), "Ignoring pac of ", Color(163, 190, 140), ply:Name(), ".")
			pac.IgnoreEntity(ply)
			ply.PacIgnored = true
		else
			chat.AddText(Color(208, 135, 112), "Unignoring pac of ", Color(163, 190, 140), ply:Name(), ".")
			pac.UnIgnoreEntity(ply)
			ply.PacIgnored = false
		end
	end)
end

