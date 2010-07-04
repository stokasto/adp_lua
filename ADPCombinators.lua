
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

local function concat(t1,t2)
  idx = 1
  result = {}
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
    return concat(a(i,j), b(i,j))
  end
end

local parserChild = function (f, a)
  return function (i, j)
    return map( function (e) 
                  return function (...)
                        callArgs = concat({e}, arg)
                        return f(callArgs)
                  end
                end, a(i,j) )
  end
end

local parserSibling = function (a, b) 
  return function(i, j)
    result = {}
    --print('i',i,'j',j)
    for k=i,j do
      local f = a(i,k)
      local values = b(k,j)
      for _,fun in ipairs(f) do
        for _,y in ipairs(values) do
          table.insert(result, fun(y))
        end
      end
    end
    return result
  end
end

local parserEmpty = function (i, j)
  if i == j then
    return {'empty'}
  else
    return {}
  end
end

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

local function add (args)
    for k,v in ipairs(args) do
      print('pos:',k,'=>',v)
    end
    return 0
end

local formula = (number) -iii- (add -ttt- number -sss- plus -sss- number)

for k,v in ipairs(formula(0,3)) do
  print(k,v)
end

