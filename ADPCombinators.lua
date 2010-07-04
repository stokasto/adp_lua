
-- This is a little hack to get infix operators taken from the lua wiki
local function infix(f)
  local mt = { __sub = function(self, b) return f(self[1], b) end }
  return setmetatable({}, { __sub = function(a, _) return setmetatable({ a }, mt) end })
end
--[[  It can be used like this:
      local shl = infix(function(a, b) return a*(2^b) end)
--]]
-- add map functionality to lua
local function map (f, t)
  res = {}
  for i, v in ipairs(t) do
    --print('partial application to', t[i])
    res[i] = f(t[i])
  end
  return res
end

-- some more helpers

local function concat(t1,t2)
  local idx = 1
  local result = {}
  for _,v in ipairs(t1) do
    result[idx]=v
    idx = idx + 1
  end
  for _,v in ipairs(t2) do
    result[idx]=v
    idx = idx + 1
  end
  return result
end

--[[
  The actual implementation
--]]

local parserConcat = function (a, b)
  return function(i, j)
    local res = concat(a(i,j), b(i,j))
    --io.write('concat!! ' .. #res .. ' \n')
    return res
  end
end

local parserChild = function (f, a)
  return function (i, j)
    return map( function (e) 
                    return f(e)
                end, a(i,j) )
  end
end

local parserSibling = function (a, b) 
  return function(i, j)
    local result = {}
    if i >= j then return result end
    --io.write('parseSibling ' .. i .. ' ' .. j .. ' \n')
    for k=i,j do
      --print('startIter \t',i, ' ',k, ' ', a, ' ', b, '\n' )
      local f = a(i,k)
      local values = b(k+1,j)
      --io.write('startIter \t' .. i .. ' ' .. k  .. ' ' .. j .. ' sizes: ' .. #f ..' ' .. #values ..'\n')
      for _,fun in ipairs(f) do
        for _,y in ipairs(values) do
        --  print('fun=>',fun, 'y=>', y, '=', fun(y))
          table.insert(result, fun(y))
        end
      end
    end
    --io.write('resSize ', #result, '\n')
    return result
  end
end

local parserSingleSiblingR = function (a, b)
  return function(i,j)
    local result = {}
    if i >= j then return result end
    local f = a(i,j-1)
    local values = b(j,j)
    for _,fun in ipairs(f) do
        for _,y in ipairs(values) do
          table.insert(result, fun(y))
        end
    end
    return result
  end
end

local parserSingleSiblingL = function (a, b)
  return function(i,j)
    local result = {}
    if i >= j then return result end
    local f = a(i,i)
    local values = b(i+1,j)
    for _,fun in ipairs(f) do
        for _,y in ipairs(values) do
          table.insert(result, fun(y))
        end
    end
    return result
  end
end

local parserChoice = function (a, h)
  return function(i,j)
    return h ( a(i,j) )
  end
end

local parserEmpty = function (i, j)
  if i == j then
    return {'empty'}
  else
    return {}
  end
end

-- define operators for exporting

parserChar = function (a, c) 
  return function (i,j) 
      if i == j and string.sub(a, j, j) == c then
        return {c}
      else
        return {}
      end
    end
end

tabulate = function (a, tab, n) 
  return function (i,j) 
    if tab[i * n + j] then
      --print('get',tab[i..''..j][1])
      return tab[i * n + j]
    else
      tab[i * n + j] = a(i,j)
      --print('set',tab[i..''..j][1])
      return tab[i * n + j]
    end
  end
end

iii = infix(parserConcat)
ttt = infix(parserChild)
sss = infix(parserSibling)
ssr = infix(parserSingleSiblingR)
lss = infix(parserSingleSiblingL)
ccc = infix(parserChoice)
empty = infix(parserEmpty)

-- and some useful functions
function list_max(l)
  if #l < 1 then 
    return 0 
  else
    local best = l[1]
    for i,v in ipairs(l) do
      if v > best then
        best = v
      end
    end
    return best
  end
end  

function list_min(l)
  if #l < 1 then 
    return 0 
  else
    local best = l[1]
    for i,v in ipairs(l) do
      if v < best then
        best = v
      end
    end
    return best
  end
end  
