
if SERVER then
	util.AddNetworkString("mingeban_ytplay")

	local a = mingeban.CreateCommand("ytplay", function(ply, line, query)
		local unsuccessful = false
		local notfound = false

		if string.find(query, "youtu.be") or string.find(query, "youtube.com/watch") then
			local url = query

			url = string.Replace(url,"youtu.be/","www.youtube.com/watch?v=")

			net.Start("mingeban_ytplay")
			net.WriteString(url)
			net.Send(ply)
			return
		end

		ply:ChatPrint("Finding the video, please wait...")

		YT.Search(query, function(body,len,headers)
			if not body then
				unsuccessful = true
				return
			end
			
			local ass = util.JSONToTable(body)
			
			if ass.error then
				MsgC(Color(255,0,0), "YT - Error: code - "..ass.error.code..", message - "..ass.error.message..".")
				unsuccessful = true
				return
			end

			if ass.items == {} then
				notfound = true
			end

			local id = ass.items[1].id.videoId
			if(id == nil) then unsuccessful = true return end

			net.Start("mingeban_ytplay")
			net.WriteString("https://youtube.com/watch?v="..id)
			net.Send(ply)
		end)
		
		if notfound then
			return false,"Not found"
		end

		if unsuccessful then
			return false,"Unsuccessful"
		end


	end)
	a:AddArgument(ARGTYPE_STRING)
else
	net.Receive("mingeban_ytplay", function()
		local url = net.ReadString()

		MP.Request(table.GetFirstValue(MP.List).Entity,url)
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

