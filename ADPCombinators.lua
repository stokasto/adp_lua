
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
    print('partial application to', t[i])
    t[i] = f(t[i])
  end
  return t
end

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
    return concat(a(i,j), b(i,j))
  end
end

local parserChild = function (f, a)
  return function (i, j)
    return map( function (e) 
                    return f(e)
                  --return function (parser)
                  --      return f(e, parser)
                  --end
                end, a(i,j) )
  end
end

local parserSibling = function (a, b) 
  return function(i, j)
    local result = {}
    io.write('parseSibling\n')
    for k=i,j do
      local f = a(i,k)
      local values = b(k+1,j)
      io.write('startIter \t',i, ' ',k ,' ', j,' sizes: ', #f,'', #values,'\n')
      for _,fun in ipairs(f) do
        for _,y in ipairs(values) do
          print('fun=>',fun, 'y=>', y, '=', fun(y))
          table.insert(result, fun(y))
        end
      end
    end
    io.write('resSize ', #result, '\n')
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
      if i == j and string.sub(a, j, j) == c then
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

local evalString = '1+3'

local digit = parserChar(evalString, '1')
local plus = parserChar(evalString, '+')

local function add (a)
    return function(c)
      return function(b)
        return a+b
      end
    end
end

local number =        parserChar(evalString, '1') -iii- parserChar(evalString, '2')
               -iii-  parserChar(evalString, '3') -iii- parserChar(evalString, '4')
               -iii-  parserChar(evalString, '5') -iii- parserChar(evalString, '6')
               -iii-  parserChar(evalString, '7') -iii- parserChar(evalString, '8')
               -iii-  parserChar(evalString, '9') -iii- parserChar(evalString, '0')

local formula = (number) -iii- (add -ttt- number -sss- plus -sss- number)

local allRes = formula(1,3) 

for k,v in ipairs(allRes) do
  print(k,v)
end
