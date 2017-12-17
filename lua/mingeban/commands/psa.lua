
if SERVER then
	util.AddNetworkString("mingeban_command_psa")

	local psa = mingeban.CreateCommand("psa", function(caller, msg)
		net.Start("mingeban_command_psa")
			net.WriteString(msg)
		net.Broadcast()
	end)
	psa:SetHideChat(true)
end

if CLIENT then
	surface.CreateFont("psa", {
		font = "Roboto",
		extended = true,
		size = 35,
		weight = 200,
		antialias = true
	})

	local targetY = 35
	net.Receive("mingeban_command_psa", function()
		local text = net.ReadString()

		local scroll = text:len() > 107
		local x = scroll and ScrW() or ScrW() * 0.5
		local time = SysTime()

		hook.Add("HUDPaint", "psa", function()
			local timeEx = SysTime() - time
			if timeEx > 5 then
				timeEx = -timeEx
				timeEx = timeEx + 10
			end

			local textY = math.Clamp(math.EaseInOut((timeEx * 50) * -1, targetY, 0), 0, targetY + 7)
			local bgY = math.Clamp(math.EaseInOut((timeEx * 50) * -1, targetY, 0), -16, targetY)

			-- bg
			surface.SetDrawColor(Color(50, 50, 50, 255))
			surface.DrawRect(0, bgY - 40, ScrW(), 55)

			-- text
			if scroll then
				x = x - 6
			end
			draw.Text({
				text = text,
				font = "psa",
				pos = { x, textY },
				xalign = scroll and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_BOTTOM,
				color = Color(255, 255, 255, 255)
			})

			-- "PSA" text
	   		surface.DrawRect(0, bgY - 40, 80, 55)
			surface.SetDrawColor(Color(255, 255, 255, 255))
			surface.DrawLine(80, bgY - 30, 80, bgY + 7.5)
			draw.Text({
				text = "PSA",
				font = "psa",
				pos = { 15, textY },
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_BOTTOM,
				color = Color(255,255,255,255)
			})
		end)

		surface.PlaySound("buttons/button3.wav")
	end)
end

