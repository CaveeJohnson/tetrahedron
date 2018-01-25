tetra = tetra or {}

include("tetra/cami.lua")

if CLIENT then
	include("tetra/client.lua")

	return
end
AddCSLuaFile("tetra/client.lua")

include("tetra/util.lua")
include("tetra/class.lua")
include("tetra/logging.lua")
include("tetra/luafuzz.lua")
include("tetra/player_find.lua")

include("tetra/privs.lua")
include("tetra/commands.lua")

include("tetra/aowl.lua")


include("tetra/commands/test.lua")
