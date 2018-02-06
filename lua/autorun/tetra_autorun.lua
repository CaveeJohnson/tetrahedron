tetra = tetra or {}

local function incl_sh(path)
	AddCSLuaFile(path)
	return include(path)
end

local function incl_cl(path)
	AddCSLuaFile(path)
	return CLIENT and include(path)
end

incl_sh("tetra/libs/cami.lua")
incl_sh("tetra/libs/luafuzz.lua")

incl_sh("tetra/util.lua")
incl_sh("tetra/class.lua")

incl_sh("tetra/commands.lua")

incl_cl("tetra/client.lua")

if CLIENT then return end

include("tetra/rpc.lua")

include("tetra/logging.lua")
include("tetra/player_find.lua")

include("tetra/usergroups.lua")
include("tetra/privs.lua")
include("tetra/commands_sv.lua")

include("tetra/wrappers/aowl.lua")

include("tetra/commands/test.lua")

tetra.logf("startup done!")
