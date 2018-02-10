-- commands which relate to lua

tetra.commands.register("docs,glua,gluadocs", function(caller, line)
	tetra.url(caller, "https://samuelmaddock.github.io/glua-docs/#?q=%s", tetra.urlEscape(line))
end, "user")

:setFullName("GLua Documentation")
:setDescription("Open the documentation for a specific part of GLua.")
:setSilent(true)

:addArgument(TETRA_ARG_STRING)
	:setName("Item")
	:setDescription("Item to open the page for in the docs.")


tetra.commands.register("lmfind", function(caller, line)
	tetra.rpc(caller, "tetra.findInGR", line)
end, "superadmin")

:setFullName("Client Lua Find")
:setDescription("Scans your global Lua state for a string, (roughly) equivelent to 'lua_find_cl X'.")
:setConsoleAllowed(true)


tetra.commands.register("lfind", function(caller, line)
	tetra.findInGR(line)
end, "superadmin")

:setFullName("Lua Find")
:setDescription("Scans the global Lua state for a string, (roughly) equivelent to 'lua_find X'.")
:setConsoleAllowed(true)
