if not easylua then return end

easylua.StartEntity("tetra_watermelon")
ENT.PrintName = "Watermelon"
ENT.model  = "models/props_junk/watermelon01.mdl"

ENT.health    = 5
ENT.speed     = 800
ENT.jumpForce = 4000

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:Activate()
		self:PhysWake()

		self:SetHealth(self.health)
	end

	function ENT:PhysicsUpdate(phys)
		local owner = self.owner

		if IsValid(owner) then
			owner:SetPos(self:GetPos())
		end
	end

	function ENT:Think()
		local phys = self:GetPhysicsObject()
		if not IsValid(phys) then return end

		local owner = self.owner

		if not (IsValid(owner) and owner:IsPlayer()) then
			self.owner = nil
			return
		end

		if not owner:Alive() then
			self:resetOwner(owner, false)
			self:doBreak()
			return
		end

		local vec = Vector()

		local ang    = owner:EyeAngles()
		local vR, vF = ang:Right(), ang:Forward()
		local vU     = ang:Up()

		local speed  = self.speed

		local kL, kR = owner:KeyDown(IN_MOVELEFT), owner:KeyDown(IN_MOVERIGHT)
		local kF, kB = owner:KeyDown(IN_FORWARD), owner:KeyDown(IN_BACK)
		local kU     = owner:KeyDown(IN_JUMP)

		if kL and not kR then
			vec = vec - vR * speed
		elseif kR and not kL then
			vec = vec + vR * speed
		end

		if kF and not kB then
			vec = vec + vF * speed
		elseif kB and not kF then
			vec = vec - vF * speed
		end

		if kU then
			if not self.jumped and (self:traceGround() or self:WaterLevel() > 0) then
				self.jumped = true
				vec = vec + vU * self.jumpForce
				self:EmitSound("npc/fast_zombie/claw_miss1.wav")
			end
		else
			if self.jumped then
				self.jumped = nil
			end
		end

		phys:ApplyForceCenter(vec)
	end

	function ENT:OnTakeDamage(dmg)
		self:SetHealth(self:Health() - dmg:GetDamage())

		if self:Health() <= 0 then self:doBreak() end
	end

	local res = {}

	local tr = {output = res}

	local down = Vector(0, 0, -24)
	function ENT:traceGround()
		tr.start  = self:GetPos()
		tr.endpos = tr.start + down
		tr.mask   = MASK_SOLID_BRUSHONLY

		util.TraceLine(tr)

		return res.HitWorld
	end

	function ENT:focus(ply)
		self.owner = ply
		ply.melon  = self

		ply:StripWeapons()
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(self)
	end

	function ENT:doBreak()
		if self.broken then return end
		self.broken = true

		local owner = self.owner

		self:SetNoDraw(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)

		local ent = ents.Create("prop_physics")
		ent:SetModel(self.model)
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:Activate()
		ent:Spawn()
		ent:Fire("break")

		self:EmitSound(")physics/flesh/flesh_squishy_impact_hard3.wav", 70)
		SafeRemoveEntityDelayed(self, 0.1)

		if IsValid(owner) and owner:IsPlayer() and owner:Alive() then
			self:resetOwner(owner)
			self.owner = nil
		end
	end

	function ENT:resetOwner(owner, respawn)
		owner.melon = nil

		local pos, ang = self:GetPos(), self:GetAngles()
		owner:UnSpectate()
		owner:KillSilent()
		if respawn ~= false then
			owner:Spawn()
			owner:SetPos(pos)
			owner:SetAngles(ang)
		end
	end

	function ENT:OnRemove()
		self:doBreak()
	end
end
easylua.EndEntity()

do
	tetra.commands.register("watermelonize,watermelon,melonize,melon", function(caller, _, target)
		local players = target.players

		for _, ply in ipairs(players) do
			local ent = ents.Create("tetra_watermelon")
				ent:SetPos(ply:GetPos() + Vector(0, 0, 32))
			ent:Spawn()
			ent:DropToFloor()
			ent:focus(ply)
			ent:EmitSound("garrysmod/save_load2.wav")
		end

		tetra.echo(nil, caller, " watermelonized ", target, ".")
	end, "admin")

	:setFullName("Watermelonize")
	:setDescription("Watermelonizes players.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to watermelonize.")
		:setFilter(function(_, plyObj)
		    if not plyObj:filter(function(ply)
		        return not IsValid(ply.melon) and ply:Alive()
		    end) then return "did not match any suitable players" end
		end)
		:setDefaultToCaller(true)
end

do
	tetra.commands.register("dewatermelonize,demelonize,dewatermelon,demelon,unwatermelonize,unmelonize,unwatermelon,unmelon", function(caller, _, target)
		local players = target.players

		for _, ply in ipairs(players) do
			ply.melon:doBreak()
		end

		tetra.echo(nil, caller, " de-watermelonized ", target, ".")
	end, "admin")

	:setFullName("De-watermelonize")
	:setDescription("De-watermelonizes players.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to de-watermelonize.")
		:setFilter(function(_, plyObj)
		    if not plyObj:filter(function(ply)
		        return IsValid(ply.melon)
		    end) then return "did not match any suitable players" end
		end)
		:setDefaultToCaller(true)
end
