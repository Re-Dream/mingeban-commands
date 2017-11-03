
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

