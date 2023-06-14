-- Written by Rabia Alhaffar in 24/February/2021
-- polyfill.lua, Polyfills for Lua and LuaJIT in one file!
-- Updated: 11/April/2021
--[[
MIT License

Copyright (c) 2021 - 2022 Rabia Alhaffar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

-- require
if (not require) and package then
  require = function(p)
    if package.loaded[p] then
      return package.loaded[p]
    else
      return package.searchpath(p, "./?/?.lua;./?.lua;./?.lc;./"..package.loaddir.."/?/init.lua"..";./"..package.loaddir.."/?.lua")
    end
  end
end

local polyfill = {
  _VERSION = 0.1,
  _AUTHOR = "Rabia Alhaffar (steria773/@Rabios)",
  _AUTHOR_URL = "https://github.com/Rabios",
  _URL = "https://github.com/Rabios/polyfill.lua",
  _LICENSE = "MIT",
  _DATE = "3/March/2021",
  _LUAJIT = ((require("jit") or jit) and true or false),
}

local ffi = ((require("ffi") or require("luaffi") or ffi) or nil)  --> Do we have FFI?

if not _VERSION then
  _VERSION = "Lua 5.1"
end

-- module: ffi
-- Partial FFI polyfill for LuaJIT (And PUC-RIO's Lua if yours have FFI installed)
if ffi then
  -- ffi.string
  if not ffi.string then
    ffi.string = function(s)
      local str = ffi.new("char[?]", #s)
      ffi.copy(str, s)
      return str
    end
  end
  
  -- ffi.os
  if polyfill._LUAJIT then
    if not ffi.os then
      ffi.os = (require("jit").os or jit.os)
    end
  end
  
  -- ffi.arch
  if not ffi.arch then
    if (0xfffffffff == 0xffffffff) then
      ffi.arch = "x86"
    else
      ffi.arch = "x64"
    end
  end
end

-- module: Runtime (Global functions)
-- Functions
-- setglobal
if not setglobal then
  setglobal = function(var, val)
    _G[var] = val
  end
end

-- getglobal
if not getglobal then
  getglobal = function(var)
    return _G[var]
  end
end

-- rawgetglobal
if not rawgetglobal then
  rawgetglobal = function(var)
    return _G[var]
  end
end

-- rawsetglobal
if not rawsetglobal then
  rawsetglobal = function(var, val)
    _G[var] = val
  end
end

-- globals
if not globals then
  globals = function(t)
    if not t then
      return _G
    else
      _G = t
    end
  end
end

-- newtag
if not newtag then
  newtag = function()
    return { __index = self }
  end
end

-- setfallback
if not setfallback then
  setfallback = function(fname, f)
    _G[fname] = f
  end
end

-- select
if not select then
  select = function(n, ...)
    local args = { ... }
    return args[n]
  end
end

-- _ALERT
if not _ALERT then
  _ALERT = function(msg)
    local n = select("#", msg)
    for i = 1, n do
      local v = tostring(select(i, msg))
      io.stderr:write(v)
      if i ~= n then
        io.stderr:write("\t")
      end
    end
    io.stderr:write("\n")
    io.stderr:flush()
  end
end

-- error
if not error then
  error = function(msg)
    coroutine.yield(msg)
  end
end

-- print
if not print then
  print = function(...)
    local n = select("#", ...)
    for i = 1, n do
      local v = tostring(select(i, ...))
      io.write(v)
      if i ~= n then
        io.write("\t")
      end
    end
    io.write("\n")
    io.flush()
  end
end

-- next
if not next then
  next = function(t, k)
    local m = getmetatable(t)
    local n = m and m.__next or next
    return n(t, k)
  end
end

-- nextvar
if not nextvar then
  nextvar = function(name)
    local m = _G[name]
    local n = m and m.__next or nextvar
    return n(_G, name)
  end
end

-- tostring
if not tostring then
  tostring = function(n)
    return "\""..(n).."\""
  end
end

-- tonumber (Requires FFI for atof function)
if not tonumber then
  if ffi then
    ffi.cdef("float atof(const char *_Str);")
    tonumber = function(s)
      return ffi.C.atof(s)
    end
  end
end

-- ipairs
if not ipairs then
  iterate = function(t, i)
    i = i + 1
    local v = t[i]
    if v then
      return i, v
    end
  end
  
  ipairs = function(t)
    return iterate, t, 0
  end
end

-- pairs
if not pairs then
  pairs = function(t)
    return next, t, nil
  end
end

-- foreach
if not foreach then
  foreach = function(t, f)
    for k, v in pairs(t) do
      f(k, v)
    end
  end
end

-- foreachi
if not foreachi then
  foreachi = function(t, f)
    for k, v in ipairs(t) do
      f(k, v)
    end
  end
end

-- foreachvar
if not foreachvar then
  foreachvar = function(f)
    local n, v = nextvar(nil)
    while n do
      local res = f(n, v)
      if res then
        return res
      end
      n, v = nextvar(n)
    end
  end
end

-- gcinfo
if not gcinfo then
  gcinfo = function()
    return collectgarbage("count")
  end
end

-- settag
if not settag then
  settag = function(t, tag)
    setmetatable(t, tag)
  end
end

-- assert
if not assert then
  assert = function(v, m)
    if not v then
      m = m or ""
      error("assertion failed!  " .. m)
    end
  end
end

-- loadfile
if not loadfile then
  loadfile = function(src)
    local file = io.open(src)
    content = ""
    if not (_VERSION == "Lua 5.4" or _VERSION == "Lua 5.3") then
      content = file:read("*all")
    else
      content = file:read("*a")
    end
    file:close()
    return function()
      if assert(load(content), "Loading code string failed!") then
        return load(content)
      end
    end
  end
end

-- loadstring
if not loadstring then
  loadstring = function(str)
    if assert(load(str), "Loading code string failed!") then
      return load(str)
    end
  end
end

-- dofile
if not dofile then
  dofile = function(path)
    if assert(loadfile(path), "Loading file " .. path .. " failed!\n") then
      return loadfile(path)()
    end
  end
end

-- dostring
if not dostring then
  dostring = function(str)
    if assert(load(str), "Loading code string failed!") then
      return load(str)
    end
  end
end

-- loadlib
if not loadlib then
  if package.loadlib then
    loadlib = function(lib, fname)
      return package.loadlib(lib, fname)
    end
  end
end

-- rawlen
if not rawlen then
  rawlen = function(o)
    if o then
      return #o
    end
  end
end

-- rawget
if not rawget then
  rawget = function(t, i)
    if t then
      return t[i]
    end
  end
end

-- rawset
if not rawset then
  rawset = function(t, i, v)
    if t then
      t[i] = v
    end
  end
end

-- rawequal
if not rawequal then
  rawequal = function(a, b)
    if (a and type(a) == "table") and (b and type(b) == "table") then
      return (#a == #b)
    end
  end
end

-- copytagmethods
if not copytagmethods then
  copytagmethods = function(from, to)
    local funcs = {}
    for k, v in pairs(getmetatable(from)) do
      if (type(v) == "function") then
        funcs[k] = v
      end
    end
    for k, v in pairs(getmetatable(to)) do
      getmetatable(to)[k] = funcs[k]
    end
  end
end

-- gettagmethod
if not gettagmethod then
  gettagmethod = function(tag, method)
    return getmetatable(tag)[method]
  end
end

-- settagmethod
if not settagmethod then
  settagmethod = function(tag, event, newmethod)
    getmetatable(tag)[event] = newmethod or function() end
  end
end

-- call
if not call then
  call = function(f, args)
    if (type(f) == "function") then
      return f(table.unpack(args))
    end
  end
end

-- pcall
if not pcall then
  pcall = function(f, ...)
    local args = { ... }
    local co = coroutine.create(f)
    local err = coroutine.resume(co, table.unpack(args))
    if (coroutine.status == "dead") then
      return true
    else
      return false, err
    end
  end
end

-- xpcall
if not xpcall then
  xpcall = function(f, msgh, ...)
    local args = { ... }
    local co = coroutine.create(f)
    local err = coroutine.resume(co, table.unpack(args))
    if (coroutine.status == "dead") then
      return true
    else
      return false, "Error: " .. msgh
    end
  end
end

-- setenv
if not setenv then
  setenv = function(t)
    _ENV = t
    --_G = t
  end
end

-- getinfo
if not getinfo then
  getinfo = debug.getinfo
end

-- getlocal
if not getlocal then
  getlocal = debug.getlocal
end

-- setlocal
if not setlocal then
  setlocal = debug.setlocal
end

-- getlinehook
if not getlinehook then
  getlinehook = debug.gethook
end

-- setlinehook
if not setlinehook then
  setlinehook = debug.sethook
end

-- rawgettable
if not rawgettable then
  rawgettable = rawget
end

-- rawsettable
if not rawsettable then
  rawsettable = rawset
end

-- debug.debug
if type(debug) == "function" then
  local df = debug
  debug = {}
  debug.debug = df
end

-- module: table
table = require("table") or {}

-- Functions
-- table.insert
if not table.insert then
  table.insert = function(t, i, v)
    if not v then
      t[#t + 1] = i
    else
      t[i] = v
    end
  end
end

-- tinsert
if not tinsert then
  tinsert = function(t, i, v)
    if not v then
      t[#t + 1] = i
    else
      t[i] = v
    end
  end
end

-- table.remove
if not table.remove then
  table.remove = function(t, i)
    if not i then
      i = #t
    end
    local result = t[i]
    t[i] = nil
    return result
  end
end

-- tremove
if not tremove then
  tremove = function(t, i)
    if not i then
      i = #t
    end
    local result = t[i]
    t[i] = nil
    return result
  end
end

-- table.concat
if not table.concat then
  table.concat = function(t, s)
    local result = ""
    for str in ipairs(t, str) do
      if (type(t[str]) == "string") then
        if (str == #t) then s = "" end
        result = result..(t[str]..s)
      elseif (type(t[str]) == "number") then
        if (str == #t) then s = "" end
        result = result..(tostring(t[str])..s)
      end
    end
    return result
  end
end

-- table.unpack
if not table.unpack then
  table.unpack = function(t, i)
    i = i or 1
    if (i <= #t) then
      return t[i], table.unpack(t, i + 1)
    end
  end
end

-- unpack
if not unpack then
  unpack = function(t, i)
    i = i or 1
    if (t[i] ~= nil) then
      return t[i], unpack(t, i + 1)
    end
  end
end

-- table.pack
if not table.pack then
  table.pack = function(...)
    local t = { ... }
    t.n = #t
    return t
  end
end

-- table.move
if not table.move then
  table.move = function(t1, f, e, t, t2)
    local nums = (e - 1)
    for i = 0, nums, 1 do
      t2[t + i] = t1[f + i]
    end
  end
end

-- table.sort
if not table.sort then
  table.sort = function(t, f)
    f = f or nil
    if #t < 2 then
      return t
    end
    local pivot = t[1]
    if (type(pivot) == "string") then
      pivot = #t[1]
    end
    local a, b, c = {}, {}, {}
    for _, v in ipairs(t) do
      if (type(f) == "function") then
        if (type(v) == "number") then
          if (f(v, pivot) == true) then
            a[#a + 1] = v
          elseif(f(v, pivot) == false) then
            c[#c + 1] = v
          elseif (type(f(v, pivot)) ~= "boolean") then
            b[#b + 1] = v
          end
        end
      else
        if (type(v) == "number") then
          if v < pivot then
            a[#a + 1] = v
          elseif v > pivot then
            c[#c + 1] = v
          else
            b[#b + 1] = v
          end
        elseif (type(v) == "string") then
          if #v < pivot then
            a[#a + 1] = v
          elseif #v > pivot then
            c[#c + 1] = v
          else
            b[#b + 1] = v
          end
        end
      end
    end
    a = table.sort(a)
    c = table.sort(c)
    for _, v in ipairs(b) do a[#a + 1] = v end
    for _, v in ipairs(c) do a[#a + 1] = v end
    return a
  end
end

-- sort
if not sort then
  sort = function(t, f)
    f = f or nil
    if #t < 2 then
      return t
    end
    local pivot = t[1]
    if (type(pivot) == "string") then
      pivot = #t[1]
    end
    local a, b, c = {}, {}, {}
    for _, v in ipairs(t) do
      if (type(f) == "function") then
        if (type(v) == "number") then
          if (f(v, pivot) == true) then
            a[#a + 1] = v
          elseif(f(v, pivot) == false) then
            c[#c + 1] = v
          elseif (type(f(v, pivot)) ~= "boolean") then
            b[#b + 1] = v
          end
        end
      else
        if (type(v) == "number") then
          if v < pivot then
            a[#a + 1] = v
          elseif v > pivot then
            c[#c + 1] = v
          else
            b[#b + 1] = v
          end
        elseif (type(v) == "string") then
          if #v < pivot then
            a[#a + 1] = v
          elseif #v > pivot then
            c[#c + 1] = v
          else
            b[#b + 1] = v
          end
        end
      end
    end
    a = sort(a)
    c = sort(c)
    for _, v in ipairs(b) do a[#a + 1] = v end
    for _, v in ipairs(c) do a[#a + 1] = v end
    return a
  end
end

-- table.getn
if not table.getn then
  table.getn = function(t)
    if type(t.n) == "number" then
      return t.n
    end
    local m = 0
    for i, _ in t do
      if (type(i) == "number" and i > max) then
        m = i
      end
    end
    return m
  end
end

-- getn
if not getn then
  getn = function(t)
    if type(t.n) == "number" then
      return t.n
    end
    local m = 0
    for i, _ in t do
      if (type(i) == "number" and i > max) then
        m = i
      end
    end
    return m
  end
end

-- table.setn
if not table.setn then
  table.setn = function(t, n)
    setmetatable(t, {
      __len = function()
        return n
      end
    })
  end
end

-- table.foreach
if not table.foreach then
  table.foreach = function(t, f)
    for k, v in pairs(t) do
      if (type(f) == "function") then
        f(k, v)
      end
    end
  end
end

-- table.foreachi
if not table.foreachi then
  table.foreachi = function(t, f)
    for k, v in pairs(t) do
      if (type(f) == "function") then
        if (type(k) == "number") then
          f(k, v)
        end
      end
    end
  end
end

-- table.maxn
if not table.maxn then
  table.maxn = function(t)
    local result = 0
    for i, k in ipairs(t) do
      if (i > result) then
        result = i
      end
    end
    return result
  end
end

-- table_ext_solar2d.lua
-- Written by Rabia Alhaffar in 11/March/2021
-- Polyfill for some table functions from Corona SDK/Solar2D
-- Updated: 27/March/2021
if CoronaPrototype then

  -- table.indexOf
  if not table.indexOf then
    table.indexOf = function(arr, elem)
      for i = 1, #arr do
        if arr[i] == elem then
          return i
        end
      end
    end
  end

  -- table.copy
  if not table.copy then
    table.copy = function(...)
      local arg = { ... }
      local result = {}
      if #arg == 1 then
        return arg[1]
      else
        for i = 1, #arg do
          for j = 1, #arg[i] do
            table.insert(result, arg[i][j])
          end
        end
      end
      return result
    end
  end

end

-- table_ext_amulet.lua
-- Written by Rabia Alhaffar in 11/March/2021
-- Polyfill for some table functions from Amulet
-- Updated: 27/March/2021
if (type(am) == "table") then

  -- table.search
  if not table.search then
    table.search = function(arr, elem)
      for i = 1, #arr do
        if arr[i] == elem then
          return i
        end
      end
    end
  end

  -- table.clear
  if not table.clear then
    table.clear = function(t)
      for k, v in pairs(t) do
        if t[k] then
          t[k] = nil
        end
      end
    end
  end

  -- table.remove_all
  if not table.remove_all then
    table.remove_all = function(arr, elem)
      for i = 1, #arr do
        if arr[i] == elem then
          arr[i] = nil
        end
      end
    end
  end

  -- table.append
  if not table.append then
    table.append = function(t1, t2)
      for i = 1, #t2 do
        table.insert(t1, t2[i])
      end
    end
  end

  -- table.merge
  if not table.merge then
    table.merge = function(t1, t2)
      for k, v in pairs(t2) do
        t1[k] = t2[k]
      end
    end
  end

  -- table.keys
  if not table.keys then
    table.keys = function(t)
      local result = {}
      for k in pairs(t) do
        table.insert(result, k)
      end
    end
    return result
  end

  -- table.values
  if not table.values then
    table.values = function(t)
      local result = {}
      for k, v in pairs(t) do
        table.insert(result, v)
      end
    end
    return result
  end

  -- table.count
  if not table.count then
    table.count = function(t)
      local result = 0
      for k, v in pairs(t) do
        if t[k] then
          result = result + 1
        end
      end
      return result
    end
  end

  -- table.filter
  if not table.filter then
    table.filter = function(t, f)
      local result = {}
      for i = 1, #t do
        local a = t[i]
        local b = t[i + 1] or t[i]
        if (f(a, b) == true) then
          t[i] = a
          t[i + 1] = b
        else
          t[i] = b
          t[i + 1] = a
        end
      end
      return result
    end
  end

  -- table.tostring
  if not table.tostring then
    table.tostring = function(t)
      local result = "{"
      for k, v in pairs(t) do
        if assert(type(tonumber(k)) == "number") then
          result = result .. v .. ","
        else
          result = result .. "\"" .. k .. "\"" .. " = " .. v .. ","
        end
      end
      result = result .. "}"
      return result
    end
  end

  -- table.shuffle
  if not table.shuffle then
    table.shuffle = function(t, r)
      math.randomseed(os.time())
      for i = #t, 2, -1 do
        local j = r or math.random(i)
        t[i], t[j] = t[j], t[i]
      end
      return t
    end
  end
  
end

-- module: package (Config for require function polyfill)
if package then
  if ffi then
    if not package.loaddir then
      package.loaddir = "lualibs"
    end
    if not package.config then
      if (ffi.os == "Windows") then
        package.config = "\\\n;\n?\n!\n-"
      else
        package.config = "///n;/n?/n!/n-"
      end
    end
  end
end

-- module: os (Requires FFI)
os = require("os") or {}

if ffi then
  if ffi.arch == "x86" then
    ffi.cdef([[
      typedef long __time32_t;
      typedef __time32_t time_t;
    ]])
  elseif ffi.arch == "x64" then
    ffi.cdef([[
      typedef __int64 __time64_t;
      typedef __time64_t time_t;
    ]])
  end
  ffi.cdef([[
    typedef long clock_t;
    time_t time(time_t *_Time);
    char * ctime(const time_t *_Time);
    int system(const char *_Command);
    void exit(int _Code);
    int rename(const char *_OldFilename, const char *_NewFilename);
    int remove(const char *_Filename);
    char* setlocale(int _Category, const char *_Locale);
    char* getenv(const char *_VarName);
    double difftime(time_t _Time1, time_t _Time2);
    char tmpnam(char *_Buffer);
    char *_strdate(char *_Buffer);
    clock_t clock(void);
  ]])
end

-- os.time
if not os.time then
  if ffi then
    os.time = function()
      return ffi.C.time(ffi.new("time_t *"))
    end
  end
end

-- os.execute
if not os.execute then
  if ffi then
    os.execute = function(cmd)
      return (ffi.C.system(cmd) == 0)
    end
  end
end

-- execute
if not execute then
  if ffi then
    execute = function(cmd)
      return (ffi.C.system(cmd) == 0)
    end
  end
end

-- os.exit
if not os.exit then
  if ffi then
    os.exit = function(c)
      return ffi.C.exit(c or 0)
    end
  end
end

-- exit
if not exit then
  if ffi then
    exit = function(c)
      return ffi.C.exit(c or 0)
    end
  end
end

-- os.rename
if not os.rename then
  if ffi then
    os.rename = function(o, n)
      return (ffi.C.rename(o, n) == 0)
    end
  end
end

-- rename
if not rename then
  if ffi then
    rename = function(o, n)
      return (ffi.C.rename(o, n) == 0)
    end
  end
end

-- os.remove
if not os.remove then
  if ffi then
    os.remove = function(f)
      return (ffi.C.remove(f) == 0)
    end
  end
end

-- remove
if not remove then
  if ffi then
    remove = function(f)
      return (ffi.C.remove(f) == 0)
    end
  end
end

-- os.setlocale
if not os.setlocale then
  if ffi then
    os.setlocale = function(v)
      return ffi.string(ffi.C.setlocale(v))
    end
  end
end

-- setlocale
if not setlocale then
  if ffi then
    setlocale = function(v)
      return ffi.string(ffi.C.setlocale(v))
    end
  end
end

-- os.getenv
if not os.getenv then
  if ffi then
    os.getenv = function(v)
      return ffi.string(ffi.C.getenv(v))
    end
  end
end

-- getenv
if not getenv then
  if ffi then
    getenv = function(v)
      return ffi.string(ffi.C.getenv(v))
    end
  end
end

-- os.difftime
if not os.difftime then
  if ffi then
    os.difftime = function(t1, t2)
      return ffi.C.difftime(t1, t2)
    end
  end
end

-- os.tmpname
if not os.tmpname then
  if ffi then
    os.tmpname = function(str)
      return ffi.string(ffi.C.tmpnam(str))
    end
  end
end

-- os.date
if not os.date == "nil" then
  if ffi then
    os.date = function(form)
      return ffi.string(ffi.C._strdate(form))
    end
  end
end

-- date
if not date == "nil" then
  if ffi then
    date = function(form)
      return ffi.string(ffi.C._strdate(form))
    end
  end
end

-- os.clock
if not os.clock then
  if ffi then
    os.clock = function()
      return ffi.C.clock()
    end
  end
end

-- clock
if not clock then
  if ffi then
    clock = function()
      return ffi.C.clock()
    end
  end
end

-- module: math
math = require("math") or {}

-- Variables
-- math.pi
if not math.pi then
  math.pi = 3.14159265358979323846
end

-- PI
if not PI then
  PI = 3.14159265358979323846
end

-- math.huge
if not math.huge then
  math.huge = 1 / 0
end

-- math.mininteger
if not math.mininteger then
  math.mininteger = -2147483648
end

-- math.maxinteger
if not math.maxinteger then
  math.maxinteger = 2147483647
end

-- Functions
-- math.sqrt
if not math.sqrt then
  if ffi then
    ffi.cdef("double sqrt(double);")
    math.sqrt = function(n)
      return ffi.C.sqrt(n)
    end
  end
end

-- sqrt
if not sqrt then
  if ffi then
    ffi.cdef("double sqrt(double);")
    sqrt = function(n)
      return ffi.C.sqrt(n)
    end
  end
end

-- math.sinh
if not math.sinh then
  if ffi then
    ffi.cdef("double sinh(double);")
    math.sinh = function(n)
      return ffi.C.sinh(n)
    end
  end
end

-- math.cosh
if not math.cosh then
  if ffi then
    ffi.cdef("double cosh(double);")
    math.cosh = function(n)
      return ffi.C.cosh(n)
    end
  end
end

-- math.tanh
if not math.tanh then
  if ffi then
    ffi.cdef("double tanh(double);")
    math.tanh = function(n)
      return ffi.C.tanh(n)
    end
  end
end

-- math.asin
if not math.asin then
  if ffi then
    ffi.cdef("double asin(double);")
    math.asin = function(n)
      return ffi.C.asin(n)
    end
  else
    math.asin = function(n)
      return (n + (1 / 2) * (math.pow(n, 3) / 3) + ((1 * 3) / (2 * 4)) * (math.pow(n, 5) / 5) + ((1 * 3 * 5) / (2 * 4 * 6)) * (math.pow(n, 7) / 7))
    end
  end
end

-- asin
if not asin then
  if ffi then
    ffi.cdef("double asin(double);")
    asin = function(n)
      return ffi.C.asin(n)
    end
  else
    asin = function(n)
      return (n + (1 / 2) * (math.pow(n, 3) / 3) + ((1 * 3) / (2 * 4)) * (math.pow(n, 5) / 5) + ((1 * 3 * 5) / (2 * 4 * 6)) * (math.pow(n, 7) / 7))
    end
  end
end

-- math.acos
if not math.acos then
  if ffi then
    ffi.cdef("double acos(double);")
    math.acos = function(n)
      return ffi.C.acos(n)
    end
  else
    math.acos = function(n)
      return (-0.69813170079773212 * n * n - 0.87266462599716477) * n + 1.5707963267948966
    end
  end
end

-- acos
if not acos then
  if ffi then
    ffi.cdef("double acos(double);")
    acos = function(n)
      return ffi.C.acos(n)
    end
  else
    acos = function(n)
      return (-0.69813170079773212 * n * n - 0.87266462599716477) * n + 1.5707963267948966
    end
  end
end

-- math.atan
if not math.atan then
  if ffi then
    math.atan = function(...)
      local args = { ... }
      if (#args == 1) then
        ffi.cdef("double atan(double);")
        return ffi.C.atan(args[1])
      elseif (#args == 2) then
        ffi.cdef("double atan2(double, double);")
        return ffi.C.atan2(args[1], args[2])
      end
    end
  end
end

-- atan
if not atan then
  if ffi then
   atan = function(...)
      local args = { ... }
      if (#args == 1) then
        ffi.cdef("double atan(double);")
        return ffi.C.atan(args[1])
      elseif (#args == 2) then
        ffi.cdef("double atan2(double, double);")
        return ffi.C.atan2(args[1], args[2])
      end
    end
  end
end

-- math.atan2
if not math.atan2 then
  if ffi then
    ffi.cdef("double atan2(double, double);")
    math.atan2 = function(x, y)
       return ffi.C.atan2(args[1], args[2])
    end
  end
end

-- atan2
if not atan2 then
  if ffi then
    ffi.cdef("double atan2(double, double);")
    atan2 = function(x, y)
       return ffi.C.atan2(args[1], args[2])
    end
  end
end

-- math.exp
if not math.exp then
  if ffi then
    ffi.cdef("double exp(double);")
    math.exp = function(n)
      return ffi.C.exp(n)
    end
  end
end

-- exp
if not exp then
  if ffi then
    ffi.cdef("double exp(double);")
    exp = function(n)
      return ffi.C.exp(n)
    end
  end
end

-- math.log
if not math.log then
  if ffi then
    ffi.cdef("double log(double);")
    math.log = function(n)
      return ffi.C.log(n)
    end
  end
end

-- log
if not log then
  if ffi then
    ffi.cdef("double log(double);")
    log = function(n)
      return ffi.C.log(n)
    end
  end
end

-- math.log10
if not math.log10 then
  if ffi then
    ffi.cdef("double log10(double);")
    math.log10 = function(n)
      return ffi.C.log10(n)
    end
  end
end

-- log10
if not log10 then
  if ffi then
    ffi.cdef("double log10(double);")
    log10 = function(n)
      return ffi.C.log10(n)
    end
  end
end

-- math.ldexp
if not math.ldexp then
  if ffi then
    ffi.cdef("double ldexp(double, int);")
    math.ldexp = function(x, y)
      return ffi.C.ldexp(x, y)
    end
  end
end

-- ldexp
if not ldexp then
  if ffi then
    ffi.cdef("double ldexp(double, int);")
    ldexp = function(x, y)
      return ffi.C.ldexp(x, y)
    end
  end
end

-- math.frexp
if not math.frexp then
  if ffi then
    ffi.cdef("double frexp(double, int*);")
    math.frexp = function(x, y)
      return ffi.C.frexp(x, y)
    end
  end
end

-- frexp
if not frexp then
  if ffi then
    ffi.cdef("double frexp(double, int*);")
    frexp = function(x, y)
      return ffi.C.frexp(x, y)
    end
  end
end

-- math.modf
if not math.modf then
  if ffi then
    ffi.cdef("double modf(double, double*);")
    math.modf = function(x, y)
      return ffi.C.modf(x, y)
    end
  end
end

-- math.mod
if not math.mod then
  if ffi then
    ffi.cdef("double fmod(double, double);")
    math.mod = function(x, y)
      return ffi.C.fmod(x, y)
    end
  end
end

-- math.fmod
if not math.fmod then
  if ffi then
    ffi.cdef("double fmod(double, double);")
    math.fmod = function(x, y)
      return ffi.C.fmod(x, y)
    end
  end
end

-- mod
if not mod then
  if ffi then
    ffi.cdef("double fmod(double, double);")
    mod = function(x, y)
      return ffi.C.fmod(x, y)
    end
  end
end

-- math.pow
if not math.pow then
  if ffi then
    ffi.cdef("double pow(double, double);")
    math.pow = function(n, p)
      return ffi.C.pow(n, p)
    end
  else
    math.pow = function(n, p)
      local e = n
      if (p == 0) then
        return 1
      end
      if (p < 0) then
        p = p * -1
      end
      for c = p, 2, -1 do
        e = e * n
      end
      return e
    end
  end
end

-- math.abs
if not math.abs then
  math.abs = function(n)
    if (n < 0) then
      return -n
    else
      return n
    end
  end
end

-- abs
if not abs then
  abs = function(n)
    if (n < 0) then
      return -n
    else
      return n
    end
  end
end

-- math.deg
if not math.deg then
  math.deg = function(n)
    return n * (180 / math.pi)
  end
end

-- deg
if not deg then
  deg = function(n)
    return n * (180 / math.pi)
  end
end

-- math.rad
if not math.rad then
  math.rad = function(d)
    return d * (math.pi / 180)
  end
end

-- rad
if not rad then
  rad = function(d)
    return d * (math.pi / 180)
  end
end

-- math.min
if not math.min then
  math.min = function(x, y)
    if x < y then
      return x
    else
      return y
    end
  end
end

-- min
if not min then
  min = function(x, y)
    if x < y then
      return x
    else
      return y
    end
  end
end

-- math.max
if not math.max then
  math.max = function(x, y)
    if x > y then
      return x
    else
      return y
    end
  end
end

-- max
if not max then
  max = function(x, y)
    if x > y then
      return x
    else
      return y
    end
  end
end

-- math.tointeger
if not math.tointeger then
  math.tointeger = function(n)
    return math.floor(n)
  end
end

-- math.hypot
if not math.hypot then
  if ffi then
    ffi.cdef("double hypot(double, double);")
    math.hypot = function(x, y)
      return ffi.C.hypot(x, y)
    end
  else
    math.hypot = function(x, y)
      return math.sqrt(math.pow(x, 2) + math.pow(y, 2))
    end
  end
end

-- math.sin
if not math.sin then
  if ffi then
    ffi.cdef("double sin(double);")
    math.sin = function(n)
      return ffi.C.sin(n)
    end
  end
end

-- sin
if not sin then
  if ffi then
    ffi.cdef("double sin(double);")
    sin = function(n)
      return ffi.C.sin(n)
    end
  end
end

-- math.cos
if not math.cos then
  if ffi then
    ffi.cdef("double cos(double);")
    math.cos = function(n)
      return ffi.C.cos(n)
    end
  else
    function fact(a)
      if (a == 1) or (a == 0) then
        return 1
      end
      local e = 1
      for c = a, 1, -1 do
        e = e * c
      end
      return e
    end

    function correctRadians(v)
      while v > math.pi * 2 do
        v = v - math.pi * 2
      end
      while v < -math.pi * 2 do
        v = v + math.pi * 2
      end
      return v
    end
  
    math.cos = function(a, b)
      local e = 1 
      a = correctRadians(a) 
      b = b or 10
      for i = 1, b do
        e = e + (math.pow(-1, i) * math.pow(a, 2 * i) / fact(2 * i))
      end
      return e
    end
  end
end

-- cos
if not cos then
  if ffi then
    ffi.cdef("double cos(double);")
    cos = function(n)
      return ffi.C.cos(n)
    end
  else
    function fact(a)
      if (a == 1) or (a == 0) then
        return 1
      end
      local e = 1
      for c = a, 1, -1 do
        e = e * c
      end
      return e
    end

    function correctRadians(v)
      while v > math.pi * 2 do
        v = v - math.pi * 2
      end
      while v < -math.pi * 2 do
        v = v + math.pi * 2
      end
      return v
    end
  
    cos = function(a, b)
      local e = 1 
      a = correctRadians(a) 
      b = b or 10
      for i = 1, b do
        e = e + (math.pow(-1, i) * math.pow(a, 2 * i) / fact(2 * i))
      end
      return e
    end
  end
end

-- math.tan
if not math.tan then
  if ffi then
    ffi.cdef("double tan(double);")
    math.tan = function(n)
      return ffi.C.tan(n)
    end
  end
end

-- tan
if not tan then
  if ffi then
    ffi.cdef("double tan(double);")
    tan = function(n)
      return ffi.C.tan(n)
    end
  end
end

-- math.ult
if not math.ult then
  if ffi then
    math.ult = function(x, y)
      return (ffi.cast("unsigned int", x) < ffi.cast("unsigned int", y))
    end
  end
end

-- math.ceil
if not math.ceil then
  if ffi then
    math.ceil = function(n)
      ffi.cdef("double ceil(double);")
      return ffi.C.ceil(n)
    end
  end
end

-- ceil
if not ceil then
  if ffi then
    ceil = function(n)
      ffi.cdef("double ceil(double);")
      return ffi.C.ceil(n)
    end
  end
end

-- math.round
if not math.round then
  if ffi then
    math.round = function(n)
      ffi.cdef("double round(double);")
      return ffi.C.round(n)
    end
  end
end

-- round
if not round then
  if ffi then
    round = function(n)
      ffi.cdef("double round(double);")
      return ffi.C.round(n)
    end
  end
end

-- math.floor
if not math.floor then
  if ffi then
    math.floor = function(n)
      ffi.cdef("double floor(double);")
      return ffi.C.floor(n)
    end
  end
end

-- floor
if not floor then
  if ffi then
    floor = function(n)
      ffi.cdef("double floor(double);")
      return ffi.C.floor(n)
    end
  end
end

-- math.randomseed
if not math.randomseed then
  if ffi then
    ffi.cdef("void srand(unsigned int _Seed);")
    math.randomseed = function(n)
      ffi.C.srand(n)
    end
  end
end

-- randomseed
if not randomseed then
  if ffi then
    ffi.cdef("void srand(unsigned int _Seed);")
    randomseed = function(n)
      ffi.C.srand(n)
    end
  end
end

-- math.random
if not math.random then
  if ffi then
    ffi.cdef("int rand(void);")
    math.random = function(...)
      local pownum = 100000
      local n = { ... }
      if (#n == 0) then
        return (ffi.C.rand() / pownum)
      elseif (#n == 1) then
        local num = (n[1] * (n[1] - 2))
        local result = math.floor((ffi.C.rand() / pownum) * num)
        if (result > n[1]) then
          return n[1]
        end
        return result
      elseif (#n == 2) then
        local num1 = (n[1] * (n[1] - 2))
        local num2 = (n[2] * (n[2] - 2))
        local result = math.floor((ffi.C.rand() / pownum) * (num2 - num1) + num1)
        if (result > n[2]) then
          return n[2]
        end
        if (result < n[1]) then
          return n[1]
        end
        return result
      end
    end
  end
end

-- random
if not random then
  if ffi then
    ffi.cdef("int rand(void);")
    random = function(...)
      local pownum = 100000
      local n = { ... }
      if (#n == 0) then
        return (ffi.C.rand() / pownum)
      elseif (#n == 1) then
        local num = (n[1] * (n[1] - 2))
        local result = math.floor((ffi.C.rand() / pownum) * num)
        if (result > n[1]) then
          return n[1]
        end
        return result
      elseif (#n == 2) then
        local num1 = (n[1] * (n[1] - 2))
        local num2 = (n[2] * (n[2] - 2))
        local result = math.floor((ffi.C.rand() / pownum) * (num2 - num1) + num1)
        if (result > n[2]) then
          return n[2]
        end
        if (result < n[1]) then
          return n[1]
        end
        return result
      end
    end
  end
end

-- module: bit32
bit32 = bit32 or {}

bit32.bits = 32
bit32.powtab = { 1 }

for b = 1, bit32.bits - 1 do
  bit32.powtab[#bit32.powtab + 1] = math.pow(2, b)
end

-- Functions
-- bit32.band
if not bit32.band then
  bit32.band = function(a, b)
    local result = 0
    for x = 1, bit32.bits do
      result = result + result
      if (a < 0) then
        if (b < 0) then
          result = result + 1
        end
      end
      a = a + a
      b = b + b
    end
    return result
  end
end

-- bit32.bor
if not bit32.bor then
  bit32.bor = function(a, b)
    local result = 0
    for x = 1, bit32.bits do
      result = result + result
      if (a < 0) then
        result = result + 1
      elseif (b < 0) then
        result = result + 1
      end
      a = a + a
      b = b + b
    end
    return result
  end
end

-- bit32.bnot
if not bit32.bnot then
  bit32.bnot = function(x)
    return bit32.bxor(x, math.pow((bit32.bits or math.floor(math.log(x, 2))), 2) - 1)
  end
end

-- bit32.lshift
if not bit32.lshift then
  bit32.lshift = function(a, n)
    if (n > bit32.bits) then
      a = 0
    else
      a = a * bit32.powtab[n]
    end
    return a
  end
end

-- bit32.rshift
if not bit32.rshift then
  bit32.rshift = function(a, n)
    if (n > bit32.bits) then
      a = 0
    elseif (n > 0) then
      if (a < 0) then
        a = a - bit32.powtab[#bit32.powtab]
        a = a / bit32.powtab[n]
        a = a + bit32.powtab[bit32.bits - n]
      else
        a = a / bit32.powtab[n]
      end
    end
    return a
  end
end

-- bit32.arshift
if not bit32.arshift then
  bit32.arshift = function(a, n)
    if (n >= bit32.bits) then
      if (a < 0) then
        a = -1
      else
        a = 0
      end
    elseif (n > 0) then
      if (a < 0) then
        a = a - bit32.powtab[#bit32.powtab]
        a = a / bit32.powtab[n]
        a = a - bit32.powtab[bit32.bits - n]
      else
        a = a / bit32.powtab[n]
      end
    end
    return a
  end
end

-- bit32.bxor
if not bit32.bxor then
  bit32.bxor = function(a, b)
    local result = 0
    for x = 1, bit32.bits, 1 do
      result = result + result
      if (a < 0) then
        if (b >= 0) then
          result = result + 1
        end
      elseif (b < 0) then
        result = result + 1
      end
      a = a + a
      b = b + b
    end
    return result
  end
end

-- bit32.btest
if not bit32.btest then
  bit32.btest = function(a, b)
    return (bit32.band(a, b) ~= 0)
  end
end

-- bit32.lrotate
if not bit32.lrotate then
  bit32.lrotate = function(a, b)
    local bits = bit32.band(b, bit32.bits - 1)
    a = bit32.band(a, 0xffffffff)
    a = bit32.bor(bit32.lshift(a, b), bit32.rshift(a, ((bit32.bits - 1) - b)))
    return bit32.band(n, 0xffffffff)
  end
end

-- bit32.rrotate
if not bit32.rrotate then
  bit32.rrotate = function(a, b)
    return bit32.lrotate(a, -b)
  end
end

-- bit32.extract
if not bit32.extract then
  bit32.extract = function(a, b, c)
    c = c or 1
    return bit32.band(bit32.rshift(a, b, c), math.pow(b, 2) - 1)
  end
end

-- bit32.replace
if not bit32.replace then
  bit32.replace = function(a, b, c, d)
    d = d or 1
    local mask1 = math.pow(d, 2) -1
    b = bit32.band(b, mask1)
    local mask = bit32.bnot(bit32.lshift(mask1, c))
    return bit32.band(n, mask) + bit32.lshift(b, c)
  end
end

-- module: bit
bit = bit or {}

bit.bits = 32
bit.powtab = { 1 }

for b = 1, bit.bits - 1 do
  bit.powtab[#bit.powtab + 1] = math.pow(2, b)
end

-- Functions
-- bit.band
if not bit.band then
  bit.band = function(a, b)
    local result = 0
    for x = 1, bit.bits do
      result = result + result
      if (a < 0) then
        if (b < 0) then
          result = result + 1
        end
      end
      a = a + a
      b = b + b
    end
    return result
  end
end

-- bit.bor
if not bit.bor then
  bit.bor = function(a, b)
    local result = 0
    for x = 1, bit.bits do
      result = result + result
      if (a < 0) then
        result = result + 1
      elseif (b < 0) then
        result = result + 1
      end
      a = a + a
      b = b + b
    end
    return result
  end
end

-- bit.bnot
if not bit.bnot then
  bit.bnot = function(x)
    return bit.bxor(x, math.pow((bit.bits or math.floor(math.log(x, 2))), 2) - 1)
  end
end

-- bit.lshift
if not bit.lshift then
  bit.lshift = function(a, n)
    if (n > bit.bits) then
      a = 0
    else
      a = a * bit.powtab[n]
    end
    return a
  end
end

-- bit.rshift
if not bit.rshift then
  bit.rshift = function(a, n)
    if (n > bit.bits) then
      a = 0
    elseif (n > 0) then
      if (a < 0) then
        a = a - bit.powtab[#bit.powtab]
        a = a / bit.powtab[n]
        a = a + bit.powtab[bit.bits - n]
      else
        a = a / bit.powtab[n]
      end
    end
    return a
  end
end

-- bit.arshift
if not bit.arshift then
  bit.arshift = function(a, n)
    if (n >= bit.bits) then
      if (a < 0) then
        a = -1
      else
        a = 0
      end
    elseif (n > 0) then
      if (a < 0) then
        a = a - bit.powtab[#bit.powtab]
        a = a / bit.powtab[n]
        a = a - bit.powtab[bit.bits - n]
      else
        a = a / bit.powtab[n]
      end
    end
    return a
  end
end

-- bit.bxor
if not bit.bxor then
  bit.bxor = function(a, b)
    local result = 0
    for x = 1, bit.bits, 1 do
      result = result + result
      if (a < 0) then
        if (b >= 0) then
          result = result + 1
        end
      elseif (b < 0) then
        result = result + 1
      end
      a = a + a
      b = b + b
    end
    return result
  end
end

-- bit.rol
if not bit.rol then
  bit.rol = function(a, b)
    local bits = bit.band(b, bit.bits - 1)
    a = bit.band(a,0xffffffff)
    a = bit.bor(bit.lshift(a, b), bit.rshift(a, ((bit.bits - 1) - b)))
    return bit.band(n, 0xffffffff)
  end
end

-- bit.ror
if not bit.ror then
  bit.ror = function(a, b)
    return bit.rol(a, -b)
  end
end

-- bit.bswap
if not bit.bswap then
  bit.bswap = function(n)
    local a = bit.band(n, 0xff)
    n = bit.rshift(n, 8)
    local b = bit.band(n, 0xff)
    n = bit.rshift(n, 8)
    local c = bit.band(n, 0xff)
    n = bit.rshift(n, 8)
    local d = bit.band(n, 0xff)
    return bit.lshift(bit.lshift(bit.lshift(a, 8) + b, 8) + c, 8) + d
  end
end

-- bit.tobit
if not bit.tobit then
  bit.tobit = function(n)
    local MOD = 2^32
    n = n % MOD
    if (n >= 0x80000000) then
      n = n - MOD
    end
    return n
  end
end

-- bit.tohex
if not bit.tohex then
  bit.tohex = function(x, n)
    n = n or 8
    local up
    if n <= 0 then
      if n == 0 then
        return ''
      end
      up = true
      n = -n
    end
    x = bit.band(x, 16^n-1)
    return ('%0'..n..(up and 'X' or 'x')):format(x)
  end
end

-- module: io
io = require("io") or {}

if not _INPUT then
  _INPUT = io.stdin
end

if not _OUTPUT then
  _OUTPUT = io.stdout
end

if not _STDIN then
  _STDIN = io.stdin
end

if not _STDOUT then
  _STDOUT = io.stdout
end

if not _STDERR then
  _STDERR = io.stderr
end

-- Used by io.input and io.output, And works as usable file with IO functions lol
io.__DEFAULT__INPUT__FILE__  = nil
io.__DEFAULT__OUTPUT__FILE__ = nil

if ffi then
  ffi.cdef([[
    struct _iobuf {
        char *_ptr;
        int _cnt;
        char *_base;
        int _flag;
        int _file;
        int _charbuf;
        int _bufsiz;
        char *_tmpfname;
    };
    typedef struct _iobuf FILE;
    typedef struct SExIO_Stream {
        FILE *f;  /* stream (NULL for incompletely created streams) */
    } SExIO_Stream;
  ]])
end

-- Native file type
_FILE = {}

function _FILE:new(f, m, s)
  o = {}
  setmetatable(o, self)
  self.__index = self
  self.__FILE = f
  self.__MODE = m
  self.__STATE = "file"
  self.__SRC = s
  return o
end

function _FILE:close()
  if ffi then
    ffi.cdef("int fclose(FILE *_File);")
    local result = (ffi.C.fclose(self.__FILE) == 0)
    if result then
      self.__STATE = "closed file"
    end
  end
end

function _FILE:flush()
  if ffi then
    ffi.cdef("int fflush(FILE *_File);")
    return (ffi.C.flush(self.__FILE) == 0)
  end
end

function _FILE:seek(w, o)
  if ffi then
    ffi.cdef("int fseek(FILE *stream, long int offset, int whence);")
    if (w == "set") then
      return ffi.C.fseek(self.__FILE, o, 0)
    elseif (w == "cur") then
      return ffi.C.fseek(self.__FILE, o, 1)
    elseif (w == "end") then
      return ffi.C.fseek(self.__FILE, o, 2)
    else
      return ffi.C.fseek(self.__FILE, o, w)
    end
  end
end

function _FILE:read(t)
  if (t == "*all" or t == "*a") then
    while not cast("bool", ffi.C.feof(f)) do
      local content = "" 
      local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(f)))
      if (ch ~= nil) then
        content = content .. ch
      end
    end
  elseif (t == "*line" or t == "*l") then
    if not cast("bool", ffi.C.feof(f)) then
      local line = ""
      while not cast("bool", ffi.C.feof(f)) do
        local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(f)))
        if (ch == "\n") then
          break
        else
          line = line .. ch
        end
      end
      return line
    end
  elseif (t == "*number" or t == "*n") then
    local line = ""
    while not cast("bool", ffi.C.feof(f)) do
      local ch = tonumber(ffi.string(ffi.cast("char", ffi.C.fgetc(f))))
      if not ch then
        break
      else
        line = line .. ch
      end
    end
    return line
  elseif (type(t) == "number") then
    if not cast("bool", ffi.C.feof(f)) then
      local line = ffi.new("char[?]", t)
      return ffi.string(ffi.C.fgets(line, t, f))
    end
  end
end

function _FILE:write(...)
  if ffi then
    ffi.cdef("int fprintf(FILE *stream, const char *format, ...);")
    local args = { ... }
    if (#args == 0) then
      args[1] = f
    end
    local form = args[1]
    table.remove(args, 1)
    if (#args == 0) then
      ffi.C.fprintf(f.__FILE, form)
    else
      ffi.C.fprintf(f.__FILE, form, table.unpack(args))
    end
  end
end

function _FILE:setvbuf(m, s)
  if ffi then
    ffi.cdef("int setvbuf(FILE *stream, char *buffer, int mode, size_t size);")
    if (m == "no") then
      return (ffi.C.setvbuf(self.__FILE, nil, 0x0004, s) == 0)
    elseif (m == "full") then
      return (ffi.C.setvbuf(self.__FILE, nil, 0x0000, s) == 0)
    elseif (m == "line") then
      return (ffi.C.setvbuf(self.__FILE, nil, 0x0040, s) == 0)
    end
  end
end

function _FILE:lines()
  if ffi then
    local lines = {}
    local line = ""
    while not cast("bool", ffi.C.feof(self.__FILE)) do
      local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(self.__FILE)))
      if (ch == "\n") then
        lines[#lines + 1] = line
        line = ""
      else
        line = line .. ch
      end
    end
    return ipairs(lines)
  end
end

-- Functions and Variables
-- io.tmpfile
if not io.tmpfile then
  io.tmpfile = function()
    if ffi then
      ffi.cdef("FILE *tmpfile(void);")
      return _FILE:new(ffi.C.tmpfile(), nil, nil)
    end
  end
end

-- tmpfile
if not tmpfile then
  tmpfile = function()
    if ffi then
      ffi.cdef("FILE *tmpfile(void);")
      return _FILE:new(ffi.C.tmpfile(), nil, nil)
    end
  end
end

-- io.open
if not io.open then
  if ffi then
    io.open = function(s, m)
      ffi.cdef("FILE *fopen(const char *_Filename,const char *_Mode);")
      return _FILE:new(ffi.C.fopen(s, m), m, s)
    end
  end
end

-- openfile
if not openfile then
  if ffi then
    openfile = function(s, m)
      ffi.cdef("FILE *fopen(const char *_Filename,const char *_Mode);")
      return _FILE:new(ffi.C.fopen(s, m), m, s)
    end
  end
end

-- io.write
if not io.write then
  if ffi then
    io.write = function(f, ...)
      ffi.cdef("int fprintf(FILE *stream, const char *format, ...);")
      local args = { ... }
      if ((#args == 0) and (io.__DEFAULT__OUTPUT__FILE__)) then
        args[1] = f
        return (ffi.C.fprintf(io.__DEFAULT__OUTPUT__FILE__, args[1]) == 0)
      elseif (f.__FILE) then
        local form = args[1]
        table.remove(args, 1)
        return (ffi.C.fprintf(f.__FILE, form, table.unpack(args)) == 0)
      end
    end
  end
end

-- write
if not write then
  if ffi then
    write = function(f, ...)
      ffi.cdef("int fprintf(FILE *stream, const char *format, ...);")
      local args = { ... }
      if ((#args == 0) and (io.__DEFAULT__OUTPUT__FILE__)) then
        args[1] = f
        return (ffi.C.fprintf(io.__DEFAULT__OUTPUT__FILE__, args[1]) == 0)
      elseif (f.__FILE) then
        local form = args[1]
        table.remove(args, 1)
        return (ffi.C.fprintf(f.__FILE, form, table.unpack(args)) == 0)
      end
    end
  end
end

-- io.seek
if not io.seek then
  if ffi then
    io.seek = function(f, w, o)
      ffi.cdef("int fseek(FILE *stream, long int offset, int whence);")
      if (w == "set") then
        return ffi.C.fseek(f, o, 0)
      elseif (w == "cur") then
        return ffi.C.fseek(f, o, 1)
      elseif (w == "end") then
        return ffi.C.fseek(f, o, 2)
      else
        return ffi.C.fseek(f, o, w)
      end
    end
  end
end

-- seek
if not seek then
  if ffi then
    seek = function(f, w, o)
      ffi.cdef("int fseek(FILE *stream, long int offset, int whence);")
      if (w == "set") then
        return ffi.C.fseek(f, o, 0)
      elseif (w == "cur") then
        return ffi.C.fseek(f, o, 1)
      elseif (w == "end") then
        return ffi.C.fseek(f, o, 2)
      else
        return ffi.C.fseek(f, o, w)
      end
    end
  end
end

-- io.read
if not io.read then
  if ffi then
    io.read = function(f, t)
      ffi.cdef([[
        char *fgets(char *str, int n, FILE *stream);
        int fgetc(FILE *stream);
        int feof(FILE *stream);
        int scanf(const char *format, ...);
      ]])
      if t and f then
        if (t == "*all" or t == "*a") then
          while not cast("bool", ffi.C.feof(f)) do
            local content = "" 
            local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(f)))
            if (ch ~= nil) then
               content = content .. ch
            end
          end
        elseif (t == "*line" or t == "*l") then
          if not cast("bool", ffi.C.feof(f)) then
            local line = ""
            while not cast("bool", ffi.C.feof(f)) do
              local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(f)))
              if (ch == "\n") then
                break
              else
                line = line .. ch
              end
            end
            return line
          end
        elseif (t == "*number" or t == "*n") then
          local line = ""
          while not cast("bool", ffi.C.feof(f)) do
            local ch = tonumber(ffi.string(ffi.cast("char", ffi.C.fgetc(f))))
            if not ch then
              break
            else
              line = line .. ch
            end
          end
          return line
        elseif (type(t) == "number") then
          if not cast("bool", ffi.C.feof(f)) then
            local line = ffi.new("char[?]", t)
            return ffi.string(ffi.C.fgets(line, t, f))
          end
        elseif io.__DEFAULT__INPUT__FILE__ then
        --if not cast("bool", ffi.C.feof(io.__DEFAULT__INPUT__FILE__)) then
          --local line = ffi.new("char[?]", 512)
          local line = ""
          while not cast("bool", ffi.C.feof(io.__DEFAULT__INPUT__FILE__)) do
            local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(io.__DEFAULT__INPUT__FILE__)))
            if (ch == "\n") then
              break
            else
              line = line .. ch
            end
          end
          return line
          --return ffi.string(ffi.C.fgets(line, 512, io.__DEFAULT__INPUT__FILE__))
        else
          local input = ffi.new("char[?]", 512)
          local execution_code = ffi.C.scanf("%s\0", input)
          return input, (execution_code == 0)
        end
      end
    end
  end
end

-- read
if not read then
  if ffi then
    read = function(f, t)
      ffi.cdef([[
        char *fgets(char *str, int n, FILE *stream);
        int fgetc(FILE *stream);
        int feof(FILE *stream);
        int scanf(const char *format, ...);
      ]])
      if t and f then
        if (t == "*all" or t == "*a") then
          while not cast("bool", ffi.C.feof(f)) do
            local content = "" 
            local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(f)))
            if (ch ~= nil) then
               content = content .. ch
            end
          end
        elseif (t == "*line" or t == "*l") then
          if not cast("bool", ffi.C.feof(f)) then
            local line = ""
            while not cast("bool", ffi.C.feof(f)) do
              local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(f)))
              if (ch == "\n") then
                break
              else
                line = line .. ch
              end
            end
            return line
          end
        elseif (t == "*number" or t == "*n") then
          local line = ""
          while not cast("bool", ffi.C.feof(f)) do
            local ch = tonumber(ffi.string(ffi.cast("char", ffi.C.fgetc(f))))
            if not ch then
              break
            else
              line = line .. ch
            end
          end
          return line
        elseif (type(t) == "number") then
          if not cast("bool", ffi.C.feof(f)) then
            local line = ffi.new("char[?]", t)
            return ffi.string(ffi.C.fgets(line, t, f))
          end
        elseif io.__DEFAULT__INPUT__FILE__ then
        --if not cast("bool", ffi.C.feof(io.__DEFAULT__INPUT__FILE__)) then
          --local line = ffi.new("char[?]", 512)
          local line = ""
          while not cast("bool", ffi.C.feof(io.__DEFAULT__INPUT__FILE__)) do
            local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(io.__DEFAULT__INPUT__FILE__)))
            if (ch == "\n") then
              break
            else
              line = line .. ch
            end
          end
          return line
          --return ffi.string(ffi.C.fgets(line, 512, io.__DEFAULT__INPUT__FILE__))
        else
          local input = ffi.new("char[?]", 512)
          local execution_code = ffi.C.scanf("%s\0", input)
          return input, (execution_code == 0)
        end
      end
    end
  end
end

-- io.close
if not io.close then
  if ffi then
    io.close = function(f)
      if f and (f.__FILE or f.__STATE) then
        ffi.cdef("int fclose(FILE *_File);")
        local result = (ffi.C.fclose(f.__FILE) == 0)
        if result then
          f.__STATE = "closed file"
        end
      end
    end
  end
end

-- closefile
if not closefile then
  if ffi then
    closefile = function(f)
      if f and (f.__FILE or f.__STATE) then
        ffi.cdef("int fclose(FILE *_File);")
        local result = (ffi.C.fclose(f.__FILE) == 0)
        if result then
          f.__STATE = "closed file"
        end
      end
    end
  end
end

-- io.flush
if not io.flush then
  if ffi then
    io.flush = function(f)
      ffi.cdef("int fflush(FILE *_File);")
      return (ffi.C.fflush(f or io.stdout) == 0)
    end
  end
end

-- flush
if not flush then
  if ffi then
    flush = function(f)
      ffi.cdef("int fflush(FILE *_File);")
      return (ffi.C.fflush(f or io.stdout) == 0)
    end
  end
end

-- io.type
if not io.type then
  io.type = function(f)
    if f and f.__STATE and ffi.istype("FILE", f) then
      return f.__STATE
    else
      return nil
    end
  end
end

-- io.input
if not io.input then
  io.input = function(f)
    if f and (f.__FILE or f.__STATE) then
      if (f.__FILE or f.__MODE or f.__STATE) then
        io.__DEFAULT__INPUT__FILE__ = f
      end
    end
  end
end

-- readfrom
if not readfrom then
  readfrom = function(f)
    if f and (f.__FILE or f.__STATE) then
      if (f.__FILE or f.__MODE or f.__STATE) then
        io.__DEFAULT__OUTPUT__FILE__ = f
      end
    end
  end
end

-- io.output
if not io.output then
  io.output = function(f)
    if f and (f.__FILE or f.__STATE) then
      if (f.__FILE or f.__MODE or f.__STATE) then
        io.__DEFAULT__OUTPUT__FILE__ = f
      end
    end
  end
end

-- writeto
if not writeto then
  writeto = function(f)
    if f and (f.__FILE or f.__STATE) then
      if (f.__FILE or f.__MODE or f.__STATE) then
        io.__DEFAULT__OUTPUT__FILE__ = f
      end
    end
  end
end

-- appendto
if not appendto then
  appendto = function(f)
    if f and (f.__FILE or f.__STATE) then
      if (f.__FILE or f.__MODE or f.__STATE) then
        io.__DEFAULT__OUTPUT__FILE__ = f
      end
    end
  end
end

-- io.popen
if not io.popen then
  if ffi then
    io.popen = function(c, m)
      ffi.cdef("FILE *_popen(const char *_Command, const char *_Mode);")
      return _FILE:new(ffi.C._popen(c, m), m, nil)
    end
  end
end

-- io.lines
if not io.lines then
  if ffi then
    io.lines = function(filename)
      local lines = {}
      local line = ""
      local file = nil
      if (not filename) and io.__DEFAULT__INPUT__FILE__ and io.__DEFAULT__INPUT__FILE__.__FILE then
        filename = io.__DEFAULT__INPUT__FILE__
        file = io.__DEFAULT__INPUT__FILE__.__FILE
      else
        file = io.open(filename, "r")
      end
      while not cast("bool", ffi.C.feof(file)) do
        local ch = ffi.string(ffi.cast("char", ffi.C.fgetc(file)))
        if (ch == "\n") then
          lines[#lines + 1] = line
          line = ""
        else
          line = line .. ch
        end
      end
      return ipairs(lines)
    end
  end
end

-- io.stdin
if not io.stdin then
  if ffi then
    io.stdin = _FILE:new(io.open("stdin", "w"), "w", "stdin")
  end
end

-- io.stdout
if not io.stdout then
  if ffi then
    io.stdout = _FILE:new(io.open("stdout", "w"), "w", "stdout")
  end
end

-- io.stderr
if not io.stderr then
  if ffi then
    io.stderr = _FILE:new(io.open("stderr", "w"), "w", "stderr")
  end
end

-- module: string
-- Functions
string = require("string") or {}

string.chars = {}
string.chars["a"] = 97
string.chars["b"] = 98
string.chars["c"] = 99
string.chars["d"] = 100
string.chars["e"] = 101
string.chars["f"] = 102
string.chars["g"] = 103
string.chars["h"] = 104
string.chars["i"] = 105
string.chars["j"] = 106
string.chars["k"] = 107
string.chars["l"] = 108
string.chars["m"] = 109
string.chars["n"] = 110
string.chars["o"] = 111
string.chars["p"] = 112
string.chars["q"] = 113
string.chars["r"] = 114
string.chars["s"] = 115
string.chars["t"] = 116
string.chars["u"] = 117
string.chars["v"] = 118
string.chars["w"] = 119
string.chars["x"] = 120
string.chars["y"] = 121
string.chars["z"] = 122
string.chars["0"] = 48
string.chars["1"] = 49
string.chars["2"] = 50
string.chars["3"] = 51
string.chars["4"] = 52
string.chars["5"] = 53
string.chars["6"] = 54
string.chars["7"] = 55
string.chars["8"] = 56
string.chars["9"] = 57
string.chars["!"] = 33
string.chars["@"] = 64
string.chars["#"] = 35
string.chars["$"] = 36
string.chars["%"] = 37
string.chars["^"] = 94
string.chars["&"] = 38
string.chars["*"] = 42
string.chars["("] = 40
string.chars[")"] = 41
string.chars["-"] = 45
string.chars["+"] = 43
string.chars["_"] = 95
string.chars["="] = 61
string.chars["{"] = 123
string.chars["}"] = 125
string.chars["["] = 91
string.chars["]"] = 93
string.chars[":"] = 58
string.chars["'"] = 39
string.chars["\""] = 34
string.chars[";"] = 95
string.chars["/"] = 47
string.chars["`"] = 96
string.chars["~"] = 126
string.chars["|"] = 124
string.chars["\\"] = 92
string.chars[","] = 44
string.chars["."] = 46
string.chars["<"] = 60
string.chars[">"] = 62
string.chars["?"] = 63

-- string.split
if not string.split then
  string.split = function(s, sep)
    local result = {}
    local line = ""
    for i = 1, #s do
      if (string.char(string.byte(s, i)) == sep) then
        result[#result + 1] = line
        line = ""
      else
        line = line .. string.char(string.byte(s, i))
      end
    end
    return result
  end
end

-- string.rep
if not string.rep then
  string.rep = function(s, n, sep)
    local str = ""
    local sp = sep or ""
    for i = 1, n, 1 do
      if (i == n) then
        sp = ""
      end
      str = str .. s .. sp
    end
    return str
  end
end

-- strrep
if not strrep then
  strrep = function(s, n, sep)
    local str = ""
    local sp = sep or ""
    for i = 1, n, 1 do
      if (i == n) then
        sp = ""
      end
      str = str .. s .. sp
    end
    return str
  end
end

-- string.len
if not string.len then
  string.len = function(s)
    if not ffi then
      return #n
    else
      ffi.cdef("size_t strlen(const char *_Str);")
      return ffi.cast("int", ffi.C.strlen(s))
    end
  end
end

-- strlen
if not strlen then
  strlen = function(s)
    if not ffi then
      return #n
    else
      ffi.cdef("size_t strlen(const char *_Str);")
      return ffi.cast("int", ffi.C.strlen(s))
    end
  end
end

-- string.byte
if not string.byte then
  if (type(ffi) == "string") then
    string.byte = function(s, i)
      i = i or 1
      local strarr = ffi.new("char[?]", #s)
      ffi.copy(strarr, s)
      return ffi.cast("int", strarr[i])
    end
  end
end

-- strbyte
if not strbyte then
  if (type(ffi) == "string") then
    strbyte = function(s, i)
      i = i or 1
      local strarr = ffi.new("char[?]", #s)
      ffi.copy(strarr, s)
      return ffi.cast("int", strarr[i])
    end
  end
end

-- string.char
if not string.char then
  string.char = function(...)
    local args = { ... }
    local str = ""
    for i = 1, #args do
      for k, v in pairs(string.chars) do
        if (v == args[i]) then
          str = str .. k
        end
      end
    end
    return str
  end
end

-- strchar
if not strchar then
  strchar = function(...)
    local args = { ... }
    local str = ""
    for i = 1, #args do
      for k, v in pairs(string.chars) do
        if (v == args[i]) then
          str = str .. k
        end
      end
    end
    return str
  end
end

-- string.upper
if not string.upper then
  if ffi then
    string.upper = function(s)
      ffi.cdef("int toupper(int _C);")
      local result = {}
      local t = ffi.new("char[?]", #s)
      ffi.copy(t, s)
      for i = 1, #s, 1 do
        result[i] = ffi.C.toupper(string.char(ffi.cast("int", t[i])))
      end
      return table.concat(result, "")
    end
  end
end

-- strupper
if not strupper then
  if ffi then
    strupper = function(s)
      ffi.cdef("int toupper(int _C);")
      local result = {}
      local t = ffi.new("char[?]", #s)
      ffi.copy(t, s)
      for i = 1, #s, 1 do
        result[i] = ffi.C.toupper(string.char(ffi.cast("int", t[i])))
      end
      return table.concat(result, "")
    end
  end
end

-- string.lower
if not string.lower then
  if ffi then
    string.lower = function(s)
      ffi.cdef("int tolower(int _C);")
      local result = {}
      local t = ffi.new("char[?]", #s)
      ffi.copy(t, s)
      for i = 1, #s, 1 do
        result[i] = ffi.C.tolower(string.char(ffi.cast("int", t[i])))
      end
      return table.concat(result, "")
    end
  end
end

-- strlower
if not strlower then
  if ffi then
    string.lower = function(s)
      ffi.cdef("int tolower(int _C);")
      local result = {}
      local t = ffi.new("char[?]", #s)
      ffi.copy(t, s)
      for i = 1, #s, 1 do
        result[i] = ffi.C.tolower(string.char(ffi.cast("int", t[i])))
      end
      return table.concat(result, "")
    end
  end
end

-- string.pack
if not string.pack then
  if ffi then
    string.pack = function(f, ...)
      local packtype = string.char(string.byte(f, 1))
      local arrtype = ""
      local arrsize = 0
      if packtype == "i" then
        arrtype = "int"
        arrsize = 2
      elseif packtype == "f" then
        arrtype = "float"
        arrsize = 4
      elseif packtype == "d" then
        arrtype = "double"
        arrsize = 8
      elseif packtype == "c" then
        arrtype = "char" -- char could be int?
        arrsize = 1
      end
      local occurences = string.match(args[1], packtype)
      local args = { ... }
      return ffi.string(ffi.new(arrtype.."[?]", #args, args), arrsize * #args)
    end
  end
end

-- string.unpack
if not string.unpack then
  if ffi then
    string.unpack = function(f, s, o)
      local packtype = string.char(string.byte(f, 1))
      local arrtype = ""
      local arrsize = 0
      if packtype == "i" then
        arrtype = "int"
        arrsize = 2
      elseif packtype == "f" then
        arrtype = "float"
        arrsize = 4
      elseif packtype == "d" then
        arrtype = "double"
        arrsize = 8
      elseif packtype == "c" then
        arrtype = "char" -- char could be int?
        arrsize = 1
      end
      local str = ffi.cast(arrtype .. "*", ffi.new("char[?]", #str, str))
      local t = {}
      for i = o, #str / arrsize do
         t[#t + 1] = str[#t]
      end
      return table.concat(t)
    end
  end
end

-- string.packsize
if not string.packsize then
  if ffi then
    string.packsize = function(str)
      if str[1] then
        return #str
      end
    end
  end
end

-- string.sub
if not string.sub then
  string.sub = function(s, f, t)
    t = t or #s
    local result = ""
    for i = f, t do
      result = result .. string.char(string.byte(s, i))
    end
    return result
  end
end

-- strsub
if not strsub then
  strsub = function(s, f, t)
    t = t or #s
    local result = ""
    for i = f, t do
      result = result .. string.char(string.byte(s, i))
    end
    return result
  end
end

-- string.format
if not string.format then
  if ffi then
    string.format = function(...)
      ffi.cdef("int sprintf(char *str, const char *format, ...);")
      local args = { ... }
      local str = ""
      ffi.C.sprintf(str, table.unpack(args))
      return ffi.string(str)
    end
  end
end

-- format
if not format then
  if ffi then
    format = function(...)
      ffi.cdef("int sprintf(char *str, const char *format, ...);")
      local args = { ... }
      local str = ""
      ffi.C.sprintf(str, table.unpack(args))
      return ffi.string(str)
    end
  end
end

-- string.match
if not string.match then
  if ffi then
    string.match = function(s1, s2, init)
      ffi.cdef("char* strstr(const char*, const char*);")
      init = init or 0
      local occurences = 0
      local count = 0
      local ptr = s1
      local lastfind = nil
      while (ffi.C.strstr(ptr, s2) ~= nil) do
        lastfind = ffi.C.strstr(ptr, s2)
        ptr = lastfind + 1
        if (occurences >= init) then
          count = count + 1
        end
        occurences = occurences + 1
      end
      if (occurences > 1) then
        return (occurences * #s2) - 1, #s2
      else
        return occurences, #s2
      end
    end
  end
end

-- string.gmatch
if not string.gmatch then
  if ffi then
    string.gmatch = function(s1, s2)
      ffi.cdef("char* strstr(const char*, const char*);")
      local occurences = {}
      local ptr = s1
      local lastfind = nil
      while (ffi.C.strstr(ptr, s2) ~= nil) do
        lastfind = ffi.C.strstr(ptr, s2)
        ptr = lastfind + 1
        occurences[#occurences + 1] = lastfind
      end
      return ipairs(occurences)
    end
  end
end

-- string.find
if not string.find then
  if ffi then
    string.find = function(s1, s2, init)
      ffi.cdef("char* strstr(const char*, const char*);")
      init = init or 0
      local occurences = 0
      local count = 0
      local ptr = s1
      local lastfind = nil
      while (ffi.C.strstr(ptr, s2) ~= nil) do
        lastfind = ffi.C.strstr(ptr, s2)
        ptr = lastfind + 1
        if (occurences >= init) then
          count = count + 1
        end
        occurences = occurences + 1
      end
      return occurences, #s2
    end
  end
end

-- strfind
if not strfind then
  if ffi then
    strfind = function(s1, s2, init)
      ffi.cdef("char* strstr(const char*, const char*);")
      init = init or 0
      local occurences = 0
      local count = 0
      local ptr = s1
      local lastfind = nil
      while (ffi.C.strstr(ptr, s2) ~= nil) do
        lastfind = ffi.C.strstr(ptr, s2)
        ptr = lastfind + 1
        if (occurences >= init) then
          count = count + 1
        end
        occurences = occurences + 1
      end
      return occurences, #s2
    end
  end
end

-- string.gfind
if not string.gfind then
  if ffi then
    string.gfind = function(s1, s2)
      ffi.cdef("char* strstr(const char*, const char*);")
      local occurences = {}
      local ptr = s1
      local lastfind = nil
      while (ffi.C.strstr(ptr, s2) ~= nil) do
        lastfind = strstr(ptr, s2)
        ptr = lastfind + 1
        occurences[#occurences + 1] = lastfind
      end
      return ipairs(occurences)
    end
  end
end

return polyfill
