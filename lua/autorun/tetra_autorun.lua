tetra = tetra or {}

local function incl_sh(path)
	AddCSLuaFile(path)
	return include(path)
end

local function incl_cl(path)
	AddCSLuaFile(path)
	return CLIENT and include(path)
end

local function incl_sv(path)
	return SERVER and include(path)
end

do
	incl_sh("tetra/libs/cami.lua")
	incl_sh("tetra/libs/luafuzz.lua")

	incl_sh("tetra/util.lua")
	incl_sh("tetra/class.lua")

	incl_sh("tetra/logging.lua")

	incl_sh("tetra/player_find.lua")
	incl_sh("tetra/commands.lua")

	incl_sh("tetra/usergroups.lua")
	incl_sh("tetra/privs.lua")

	incl_sh("tetra/cami_support.lua")

	incl_sh("tetra/lua_find.lua")
end

do
	incl_cl("tetra/client.lua")

	incl_cl("tetra/spectate/cl_spectate.lua")
	incl_cl("tetra/countdown/cl_countdown.lua")
end

do
	incl_sv("tetra/rpc.lua")

	incl_sv("tetra/usergroups_sv.lua")
	incl_sv("tetra/commands_sv.lua")

	incl_sv("tetra/wrappers/aowl.lua")

	incl_sv("tetra/spectate/sv_spectate.lua")
	incl_sv("tetra/countdown/sv_countdown.lua")
end

local files = file.Find("tetra/commands/*.lua", "LUA")
for _, v in ipairs(files) do
	incl_sh("tetra/commands/" .. v)
	tetra.logf("loaded %s command file", v:gsub("%.lua", ""))
end

local function tetra_init()
	hook.Run("Tetra_Startup")
	tetra.logf("startup done!")
end
timer.Simple(1, tetra_init)
