
if CLIENT then return end

pcall(function()
	if not system.IsLinux() then return end

	require("cllup")

	function RefreshLua(line)
		if not isstring(line) then return false, "Invalid path" end
		line = line:Trim()
		if line == "" or not line:match("%.lua$") then return false, "Invalid file extension" end

		local path = line:match(".+/") or ""
		local filename = line:match("([^/]+)%.lua$")

		local _, folders = file.Find("addons/*", "GAME")
		for _, folder in next, folders do
			local _path = "addons/" .. folder .. "/lua/" .. path .. filename .. ".lua"
			if file.Exists(_path, "GAME") then
				path = _path:match(".+/")
				break
			end
		end

		if path:Trim() == "" then return false, "Doesn't exist" end

		local exists = file.Exists((path:match("lua/(.+)") or path) .. filename .. ".lua", "LUA")
		if not exists then return false, "Doesn't exist" end

		Msg("[RefreshLua] ") print("Updating " .. path .. filename .. ".lua...")
		return HandleChange_Lua(path .. "/", filename, "lua")
	end

	mingeban.CreateCommand("refreshlua", function(caller, line)
		return RefreshLua(line)
	end)
end)

mingeban.CreateCommand("lfind", function(caller, line)
	RunConsoleCommand("lua_find", line)
end)

mingeban.CreateCommand("lmfind", function(caller, line)
	caller:ConCommand("lua_find_cl " .. line)
end):SetAllowConsole(false)

mingeban.CreateCommand("glua", function(caller, line)
	local urlencode = url and url.escape or string.urlencode
	if not urlencode then return false, "no url encode function" end

	caller:OpenURL("https://samuelmaddock.github.io/glua-docs/#?q=" .. urlencode(line))
end):SetAllowConsole(false)
mingeban.CreateCommand("gwiki", function(caller, line)
	local urlencode = url and url.escape or string.urlencode
	if not urlencode then return false, "no url encode function" end

	caller:OpenURL("http://wiki.garrysmod.com/page/Special:Search?search=" .. urlencode(line) .. "&fulltext=Search")
end):SetAllowConsole(false)

mingeban.commands.pm = mingeban.commands.pm2

