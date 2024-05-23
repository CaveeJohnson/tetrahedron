local warps = {
    ["gm_excess_construct_13"] = {
        island = Vector(-1088, -11255, -7),
        spawn  = Vector(929, 2364, 1),
        desert = Vector(-9175, 9949, 401),
    }
}

hook.Add("EntityTakeDamage", "tetra.warps", function(ply)
    if IsValid(ply) and ply:IsPlayer() then ply.tetra_warp_cd = math.max(ply.tetra_warp_cd or 0, CurTime() + 15) end
end)

warps = warps[game.GetMap()] or nil
local cooldown = 60
local free_warp = 1000
local base_cost = 250
local warp_string = warps and table.concat(table.GetKeys(warps), ", ")

tetra.commands.register("warp,fasttravel", function(caller, _, warp)
    if not warps then return false, "map doesn't have any warp points" end

    local now = CurTime()
    if caller.tetra_warp_cd and caller.tetra_warp_cd > now then return false, "on cooldown, " .. math.ceil(caller.tetra_warp_cd - now) .. " seconds left" end

    local warp = warp:lower():Trim()
    if warp == "list" then return false, "\nwarp list:\n" .. warp_string end

    local pos  = warps[warp]
    if not pos then return false, "\nwarp point not found! available:\n" .. warp_string end

    if caller.GetMoney and caller.TakeMoney then
        local cost = "free"
        if caller:GetMoney() >= free_warp then
            local scalar = (caller:GetMoney()^1.1 / free_warp)
            cost = base_cost + (scalar - (scalar % base_cost))
            caller:TakeMoney(cost)

            if BaseWars then cost = BaseWars.NumberFormat(cost) end
            cost = "$" .. cost
        end
        tetra.chat(caller, tetra.string_color, "Warped for ", tetra.number_color, cost, tetra.string_color, ".")
    end

    tetra.teleport.doTeleport(caller, nil, caller:GetPos(), pos)
    tetra.chat(caller, tetra.string_color, "Warped to ", tetra.number_color, warp, tetra.string_color, ", now on a ", tetra.number_color, cooldown, tetra.string_color, " second cooldown.")

    caller.tetra_warp_cd = now + cooldown
end, "user")

:setFullName("Warp")
:setDescription("Teleport yourself to a warp location.")

:addArgument(TETRA_ARG_STRING)
	:setName("Warp")
	:setDescription("The warp location to teleport to.")
