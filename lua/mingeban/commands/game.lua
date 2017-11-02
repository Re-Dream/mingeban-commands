
if SERVER then
	local kill = mingeban.CreateCommand({"kill", "wrist", "suicide"}, function(caller, line)
		local ok = hook.Run("CanPlayerSuicide", ply)
		if ok == false then
			return false, "Can't suicide"
		end

		caller:KillSilent()
		caller:CreateRagdoll()
	end)
	kill:SetAllowConsole(false)

	local revive = mingeban.CreateCommand({"revive", "respawn"}, function(caller)
		local oldPos, oldAng = caller:GetPos(), caller:EyeAngles()
		caller:Spawn()
		caller:SetPos(oldPos)
		caller:SetEyeAngles(oldAng)
	end)
	revive:SetAllowConsole(false)

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

	-- TODO: better clientside command system

	util.AddNetworkString("mingeban-command-tool")
	local tool = mingeban.CreateCommand("tool", function(caller, line, tool)
		net.Start("mingeban-command-tool")
			net.WriteString(tool)
		net.Send(caller)
	end)
	tool:SetAllowConsole(false)
	tool:AddArgument(ARGTYPE_STRING)
		:SetName("tool")

	util.AddNetworkString("mingeban-command-fps")
	local fps = mingeban.CreateCommand("fps", function(caller)
		net.Start("mingeban-command-fps")
		net.Send(caller)
	end)
	fps:SetAllowConsole(false)
	fps:SetHideChat(true)
	net.Receive("mingeban-command-fps", function(_, ply)
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
elseif CLIENT then
	net.Receive("mingeban-command-tool", function()
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

	net.Receive("mingeban-command-fps", function()
		net.Start("mingeban-command-fps")
			net.WriteFloat(1 / FrameTime())
		net.SendToServer()
	end)
end

