
if SERVER then
	util.AddNetworkString("mingeban-command-kill")
	local kill = mingeban.CreateCommand({"kill", "wrist", "suicide"}, function(caller, line, maxVel, maxAngVel)
		local ok = hook.Run("CanPlayerSuicide", ply)
		if ok == false then
			return false, "Can't suicide"
		end

		caller:KillSilent()
		caller:CreateRagdoll()
		net.Start("mingeban-command-kill")
			net.WriteEntity(caller)
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
	local function rand(i)
		return util.SharedRandom(tostring(CurTime()) .. "_" .. i, -1, 1)
	end
	net.Receive("mingeban-command-kill", function()
		local ply = net.ReadEntity()
		local maxVel = net.ReadInt(16)
		local maxAngVel = net.ReadInt(16)
		if maxVel == 0 and maxAngVel == 0 then return end

		local vel = ply:GetAimVector() * maxVel
		local angVel = Vector(rand("x") * maxAngVel, rand("y") * maxAngVel, rand("z") * maxAngVel)

		local hookId = "_" .. ply:EntIndex() .. "_ragdoll"
		hook.Add("OnEntityCreated", hookId, function(ent)
			if ent:GetClass() == "class C_HL2MPRagdoll" then
				local rag = ply:GetRagdollEntity()
				hook.Add("Think", hookId, function()
					if IsValid(rag) and rag == ent then
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

