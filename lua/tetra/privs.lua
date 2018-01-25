tetra.privs = {}

local privs = {}
tetra.privs.list = privs

-- this is bare bones as fuck and resembles CAMI to save pain when making them play nice

local translate = {
	player     = "user",
	players    = "user",

	admins     = "admin",

	developer  = "superadmin",
	developers = "superadmin",
	owners     = "superadmin",
}

function tetra.privs.register(priv)
	priv.root = translate[priv.root] or priv.root
	privs[priv.name] = priv
end

function tetra.privs.has(caller, priv, callback)
	-- handle cami

	if not privs[priv] then return callback(true) end -- doesn't exist? fuck it
	if not IsValid(caller) then return callback(true) end -- console? fuck it

	local root = privs[priv].root
	if root == "superadmin" and not caller:IsSuperAdmin() then
		return callback(false)
	elseif root == "admin" and not caller:IsAdmin() then
		return callback(false)
	end

	callback(true)
end
