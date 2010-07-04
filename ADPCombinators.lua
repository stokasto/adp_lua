
-- This is a little hack to get infix operators
local sm = setmetatable
local function infix(f)
  local mt = { __sub = function(self, b) return f(self[1], b) end }
  return sm({}, { __sub = function(a, _) return sm({ a }, mt) end })
end
--[[  It can be used like this:
      local shl = infix(function(a, b) return a*(2^b) end)
--]]
-- add map functionality to lua
local function map (f, t)
  for i, v in ipairs(t) do
    t[i] = f(t[i])
  end
  return t
end
-- add a simple closure construct 
local function closure2(f) 
  return function(a,b)
    return function(i,j)
      --local i = i
      --local j = j
      return f(a,b,i,j)
    end
  end
end

local function closure1(f) 
  return function(a)
    return function(i,j)
      --local i = i
      --local j = j
      return f(a,i,j)
    end
  end
end

local function closure0(f) 
  return function()
    return function(i,j)
      --local i = i
      --local j = j
      return f(i,j)
    end
  end
end

--[[
  The actual implementation
--]]

local parserConcat = closure2 (function (a, b, i, j)
  return table.concat(a(i,j), b(i,j))
end )

local parserChild = closure2 (function (f, a, i, j)
  return map( function (e) 
                return function (parser)
                      return f(e, parser)
                end
              end, a(i,j) )
end )

local parserSibling = closure2 (function (a, b, i, j)
  result = {}
  print('i',i,'j',j)
  for k=i,j do
    local f = a(i,k)
    local y = b(k,j)
    table.insert(result, f(y))
  end
  return result
end )

local parserEmpty = closure0 (function (i, j)
  if i == j then
    return {'empty'}
  else
    return {}
  end
end )

local parserChar = function (a, c) 
  return function (i,j) 
      if i+1 == j and string.sub(a, j, j) == c then
        return {c}
      else
        return {}
      end
    end
end

-- define operators
local iii = infix(parserConcat);
local ttt = infix(parserChild);
local sss = infix(parserSibling);
local empty = infix(parserEmpty);

local evalString = '1+1'

local number = parserChar(evalString, '1')
local plus = parserChar(evalString, '+')

local function add (a,b)
    return a+b
end

local formula = number -iii- add -ttt- number -- -sss- plus -sss- number)

for k,v in ipairs(formula(0,1)) do
  print(k,v)
end

