if SERVER then
	util.AddNetworkString("mingeban_command_ytplay")

	local ytplay = mingeban.CreateCommand("ytplay", function(ply, line)
		local query = line

		local unsuccessful = false
		local notfound = false

		if query:match("youtu.be") or query:match("youtube.com/watch") then
			local url = query

			url = string.Replace(url, "youtu.be/", "www.youtube.com/watch?v=")

			net.Start("mingeban_command_ytplay")
				net.WriteString(url)
			net.Send(ply)
			return
		end

		ply:ChatPrint("Finding the video, please wait...")

		YT.Search(query, function(body, len, headers)
			if not body then
				ply:ChatPrint("unsuccessful")
				unsuccessful = true
				return
			end

			local json = util.JSONToTable(body)

			if json.error then
				MsgC(Color(255, 0, 0), "[YouTube] Error: code - " .. json.error.code .. ", message - " .. json.error.message .. ".")
				ply:ChatPrint("unsuccessful")
				unsuccessful = true
				return
			end

			if json.items[1] == nil then
				ply:ChatPrint("not found")
				notfound = true
				return
			end

			local id = json.items[1].id.videoId
			if not id then ply:ChatPrint("unsuccessful") unsuccessful = true return end

			net.Start("mingeban_command_ytplay")
				net.WriteString("https://youtube.com/watch?v=" .. id)
			net.Send(ply)
		end)

		if notfound then
			return false, "Not found"
		end

		if unsuccessful then
			return false, "Unsuccessful"
		end
	end)
	ytplay:SetAllowConsole(false)
	ytplay:AddArgument(ARGTYPE_STRING)
		:SetName("url")

	local geoip = mingeban.CreateCommand({"geoip", "geo", "loc"}, function(caller, line, ply)
		if not GeoIP then pcall(require, "GeoIP") end

		local colors = {Color(64, 255, 64), Color(255, 255, 64), Color(255, 64, 64)}
		local data = GeoIP.Get(ply:IPAddress():Split(':')[1])
		local requestBy = ""
		local output

		if data.city then
			output = data.city .. ", " .. data.country_name
		else
			output = data.country_name
		end

		if ply ~= caller then
			requestBy = " (requested by " .. caller:Name() .. ")"
		end

		ChatAddText(colors[math.random(#colors)], ply:Name(), " is located in ", output, whatshouldicallthis)
	end)
	geoip:AddArgument(ARGTYPE_PLAYER)
	geoip:SetAllowConsole(false)
	geoip:SetHideChat(true)

	local encode = url.escape or string.urlencode
	local udapi = 'http://api.urbandictionary.com/v0/define?term='

	local cooldown = 0
	local define = mingeban.CreateCommand({'define', 'whatis', 'ud', 'urban', 'urbandictionary'}, function(caller, line)
		if CurTime() < cooldown and not caller:IsAdmin() then
			ChatAddText(Color(127, 159, 255), '[Urban] Command is on cooldown. (', math.floor(cooldown - CurTime()), ' seconds left.', ')')
			return
		end

		cooldown = CurTime() + 60

		local encoded = encode(line)
		http.Fetch(udapi .. encoded, function(body)
			local data = util.JSONToTable(body)
			if not data.list[1] then return end

			local result = data.list[1]
			if result.definition:len() >= 500 or result.example:len() >= 500 then
				ChatAddText(Color(127, 159, 255), '[Urban] Too long.')
				return
			end

			ChatAddText(
				Color(127, 159, 255), '[Urban] ',
				Color(255, 191, 0),
				result.word, ' - ', result.permalink, ' (author: ', result.author, ')',
				'\n', Color(63,127,127),
				result.definition,
				'\n\n',
				result.example
			)
		end)
	end)
	define:SetAllowConsole(false)
else
	net.Receive("mingeban_command_ytplay", function()
		local url = net.ReadString()

		local mp = table.GetFirstValue(MP.List)
		if mp then
			local result = MP.Request(mp, url)
		end
	end)

	hook.Add("OnPlayerChat", "mingeban_command_me", function(caller, line)
		local me = line:Trim():match("^%*(.*)%*$")
		if me then
			chat.AddText(Color(160, 170, 220), "* ", caller, Color(160, 170, 220), " ", me:Trim(), ".")
			return true
		end
	end)
end

if CLIENT then return end

local w = Color(194, 210, 225)
local g = Color(127, 255, 127)
local function doLinkOpenFunc(link)
	return function(caller)
		if not caller.ChatAddText or not caller.OpenURL then
			return false, "ChatAddText / OpenURL missing?"
		end

		caller:ChatAddText(g, link, w, " opened in the ", g, "Steam Overlay", w, "!")
		caller:OpenURL(link)
	end
end

mingeban.CreateCommand({"steam", "steamgroup"}, doLinkOpenFunc("https://steamcommunity.com/groups/Re-Dream")):SetAllowConsole(false)
mingeban.CreateCommand({"rocket", "liftoff"}, doLinkOpenFunc("https://re-dream.org/rcon")):SetAllowConsole(false)
mingeban.CreateCommand("discord", doLinkOpenFunc("https://discord.gg/9Gc8DeA")):SetAllowConsole(false)
mingeban.CreateCommand("github", doLinkOpenFunc("https://github.com/Re-Dream")):SetAllowConsole(false)
mingeban.CreateCommand("collection", doLinkOpenFunc("http://steamcommunity.com/sharedfiles/filedetails/?id=880121123")):SetAllowConsole(false)
mingeban.CreateCommand("website", doLinkOpenFunc("https://re-dream.org")):SetAllowConsole(false)
mingeban.CreateCommand("motd", doLinkOpenFunc("https://re-dream.org/loading")):SetAllowConsole(false)

local me = mingeban.CreateCommand("me", function(caller, line)
	ChatAddText(Color(160, 170, 220), "* ", caller, Color(160, 170, 220), " ", line, ".")
end)
me:SetAllowConsole(false)
me:SetHideChat(true)

