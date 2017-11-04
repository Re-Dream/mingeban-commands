
if SERVER then
	util.AddNetworkString("mingeban-ytplay")

	local ytplay = mingeban.CreateCommand("ytplay", function(ply, line)
		local query = line

		local unsuccessful = false
		local notfound = false

		if query:match("youtu.be") or query:match("youtube.com/watch") then
			local url = query

			url = string.Replace(url, "youtu.be/", "www.youtube.com/watch?v=")

			net.Start("mingeban-ytplay")
				net.WriteString(url)
			net.Send(ply)
			return
		end

		ply:ChatPrint("Finding the video, please wait...")

		YT.Search(query, function(body, len, headers)
			if not body then
				unsuccessful = true
				return
			end

			local json = util.JSONToTable(body)

			if json.error then
				MsgC(Color(255, 0, 0), "[YouTube] Error: code - " .. json.error.code .. ", message - " .. json.error.message .. ".")
				unsuccessful = true
				return
			end

			if json.items == {} then
				notfound = true
			end

			local id = json.items[1].id.videoId
			if not id then unsuccessful = true return end

			net.Start("mingeban-ytplay")
				net.WriteString("https://youtube.com/watch?v="..id)
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
else
	net.Receive("mingeban-ytplay", function()
		local url = net.ReadString()

		MP.Request(table.GetFirstValue(MP.List).Entity, url)
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
mingeban.CreateCommand({"rocket", "liftoff"}, doLinkOpenFunc("https://gmlounge.us/redream/rcon")):SetAllowConsole(false)
mingeban.CreateCommand("discord", doLinkOpenFunc("https://discord.gg/9Gc8DeA")):SetAllowConsole(false)
mingeban.CreateCommand("github", doLinkOpenFunc("https://github.com/Re-Dream")):SetAllowConsole(false)
mingeban.CreateCommand("collection", doLinkOpenFunc("http://steamcommunity.com/sharedfiles/filedetails/?id=880121123")):SetAllowConsole(false)
mingeban.CreateCommand("website", doLinkOpenFunc("https://gmlounge.us/redream")):SetAllowConsole(false)
mingeban.CreateCommand("motd", doLinkOpenFunc("https://gmlounge.us/redream/loading")):SetAllowConsole(false)

