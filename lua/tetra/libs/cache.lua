local cacheMeta = {}
do
	tetra.cacheMeta = cacheMeta

	tetra.getSet(cacheMeta, "dataProvider", "function")
	tetra.getSet(cacheMeta, "onMiss", "function")
	tetra.getSet(cacheMeta, "lastProvided", "number")

	function cacheMeta:get(key, ttl)
		local now = CurTime()

		local ttlMiss = self.data and self:getLastProvided() + ttl <= now
		if not (self.data and self.data[key]) or ttlMiss then
			if ttlMiss or not self.data then
				self.data = {} -- ttl based miss, clean data
			end

			local onMiss = self:getOnMiss()
			if onMiss then pcall(onMiss, key) end

			local dataProvider = self:getDataProvider()
			if not dataProvider then error("cache: no data provider?!?!") end

			self.data[key] = dataProvider(key)
			self:setLastProvided(now)
		end

		return self.data[key]
	end

	function cacheMeta:invalidate()
		self.data = nil
	end

	tetra.caches = tetra.caches or {}
	function tetra.cache(name)
		return tetra.caches[name] or setmetatable({}, {__index = cacheMeta})
	end
end
