local clock = os.clock

local profile = {}

-- function labels
local _labeled = {}
-- function definitions
local _defined = {}
-- time of last call
local _tcalled = {}
-- total execution time
local _telapsed = {}
-- number of calls
local _ncalls = {}
-- list of internal profiler functions
local _internal = {}

local getInfo=debug.getinfo
function profile.hooker(event, line, info)
	info = info or getInfo(2, 'fnS')
	local f = info.func
	-- ignore the profiler itself
	if _internal[f] or info.what ~= "Lua" then
		return
	end
	-- get the function name if available
	if info.name then
		_labeled[f] = info.name
	end
	-- find the line definition
	if not _defined[f] then
		_defined[f] = info.short_src..":"..info.linedefined
		_ncalls[f] = 0
		_telapsed[f] = 0
	end
	if _tcalled[f] then
		local dt = clock() - _tcalled[f]
		_telapsed[f] = _telapsed[f] + dt
		_tcalled[f] = nil
	end
	if event == "tail call" then
		local prev = getInfo(3, 'fnS')
		profile.hooker("return", line, prev)
		profile.hooker("call", line, info)
	elseif event == 'call' then
		_tcalled[f] = clock()
	else
		_ncalls[f] = _ncalls[f] + 1
	end
end

--- Sets a clock function to be used by the profiler.
-- @param f Clock function that returns a number
function profile.setclock(f)
	assert(type(f) == "function", "clock must be a function")
	clock = f
end

--- Starts collecting data.
function profile.start()
	if rawget(_G, 'jit') then
		jit.off()
		jit.flush()
	end
	debug.sethook(profile.hooker, "cr")
end

--- Stops collecting data.
function profile.stop()
	debug.sethook()
	for f in next,_tcalled do
		local dt = clock() - _tcalled[f]
		_telapsed[f] = _telapsed[f] + dt
		_tcalled[f] = nil
	end
	-- merge closures
	local lookup = {}
	for f, d in next,_defined do
		local id = (_labeled[f] or '?')..d
		local f2 = lookup[id]
		if f2 then
			_ncalls[f2] = _ncalls[f2] + (_ncalls[f] or 0)
			_telapsed[f2] = _telapsed[f2] + (_telapsed[f] or 0)
			_defined[f], _labeled[f] = nil, nil
			_ncalls[f], _telapsed[f] = nil, nil
		else
			lookup[id] = f
		end
	end
	collectgarbage('collect')
end

--- Resets all collected data.
function profile.reset()
	for f in next,_ncalls do
		_ncalls[f] = 0
	end
	for f in next,_telapsed do
		_telapsed[f] = 0
	end
	for f in next,_tcalled do
		_tcalled[f] = nil
	end
	collectgarbage('collect')
end

function profile.comp(a, b)
	local dt = _telapsed[b] - _telapsed[a]
	if dt == 0 then
		return _ncalls[b] < _ncalls[a]
	end
	return dt < 0
end

--- Iterates all functions that have been called since the profile was started.
-- @param n Number of results (optional)
function profile.query(limit)
	local t = {}
	for f, n in next,_ncalls do
		if n > 0 then
			t[#t + 1] = f
		end
	end
	table.sort(t, profile.comp)
	if limit then
		while #t > limit do
			table.remove(t)
		end
	end
	for i, f in ipairs(t) do
		local dt = 0
		if _tcalled[f] then
			dt = clock() - _tcalled[f]
		end
		t[i] = { i, _labeled[f] or '?', _ncalls[f], _telapsed[f] + dt, _defined[f] }
	end
	return t
end

local cols = { 3, 29, 11, 24, 32 }
function profile.report(n)
	local out = {}
	local report = profile.query(n)
	for i, row in ipairs(report) do
		for j = 1, 5 do
			local s = row[j]
			local l2 = cols[j]
			s = tostring(s)
			local l1 = s:len()
			if l1 < l2 then
				s = s..(' '):rep(l2-l1)
			elseif l1 > l2 then
				s = s:sub(l1 - l2 + 1, l1)
			end
			row[j] = s
		end
		out[i] = table.concat(row, ' | ')
	end

	local row = " +-----+-------------------------------+-------------+--------------------------+----------------------------------+ \n"
	local col = " | #   | Function                      | Calls       | Time                     | Code                             | \n"
	local sz = row..col..row
	if #out > 0 then
		sz = sz..' | '..table.concat(out, ' | \n | ')..' | \n'
	end
	return '\n'..sz..row
end

local switch=false
function profile.switch()
	if switch then
		profile.stop()
		love.system.setClipboardText(PROFILE.report())
		PROFILE.reset()
		LOG.print("profile report copied!")
	else
		PROFILE.start()
		LOG.print("profile start!")
	end
	switch=not switch
end

-- store all internal profiler functions
for _, v in next,profile do
	if type(v) == "function" then
		_internal[v] = true
	end
end

return profile