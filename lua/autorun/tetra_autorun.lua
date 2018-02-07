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

	incl_sh("tetra/commands/core.lua")
	incl_sh("tetra/commands/test.lua")
end

do
	incl_cl("tetra/client.lua")
end

do
	incl_sv("tetra/rpc.lua")
	incl_sv("tetra/commands_sv.lua")

	incl_sv("tetra/wrappers/aowl.lua")
end

tetra.logf("startup done!")
