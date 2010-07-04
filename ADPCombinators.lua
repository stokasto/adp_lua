
-- This is a little hack to get infix operators
local function infix(f)
  local mt = { __sub = function(self, b) return f(self[1], b) end }
  return setmetatable({}, { __sub = function(a, _) return setmetatable({ a }, mt) end })
end
--[[  It can be used like this:
      local shl = infix(function(a, b) return a*(2^b) end)
--]]
-- add map functionality to lua
local function map (f, t)
  for i, v in ipairs(t) do
    --print('partial application to', t[i])
    t[i] = f(t[i])
  end
  return t
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

local function list_max(l)
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

local function list_min(l)
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
local iii = infix(parserConcat)
local ttt = infix(parserChild)
local sss = infix(parserSibling)
local ssr = infix(parserSingleSiblingR)
local lss = infix(parserSingleSiblingL)
local ccc = infix(parserChoice)
local empty = infix(parserEmpty)

--[[-- Test with ElMammuns --]]--

local evalString = '1+2*3'

-- define the problem
bill_algebra = {}
bill_algebra['__call'] = function (self,i,j) 
  local add = self.add
  local mult = self.mult
  local h = self.h
  
  local digit = parserChar(evalString, '1')
  local plus = parserChar(evalString, '+')
  local times = parserChar(evalString, '*')
  local number =        parserChar(evalString, '1') -iii- parserChar(evalString, '2')
                 -iii-  parserChar(evalString, '3') -iii- parserChar(evalString, '4')
                 -iii-  parserChar(evalString, '5') -iii- parserChar(evalString, '6')
                 -iii-  parserChar(evalString, '7') -iii- parserChar(evalString, '8')
                 -iii-  parserChar(evalString, '9') -iii- parserChar(evalString, '0')


  local function formula(i,j)
                return  ( ((number) 
                     -iii- (add -ttt- formula -ssr- plus -sss- formula)
                     -iii- (mult -ttt- formula -ssr- times -sss- formula)) -ccc- h )(i,j)
  end
  return formula(i,j)
end

-- the seller algebra
local seller = {}

seller.add = function (a)
    return function(c)
      return function(b)
        return a+b
      end
    end
end

seller.mult = function (a)
    return function(c)
      return function(b)
        return a*b
      end
    end
end

seller.h = function (candidates)
  return {list_max(candidates)}
end

seller['__index'] = seller

-- make the seller algebra a proper bill_algebra
setmetatable(seller, bill_algebra)

-- the buyer algebra
local buyer = {}

buyer.add = function (a)
    return function(c)
      return function(b)
        return a+b
      end
    end
end

buyer.mult = function (a)
    return function(c)
      return function(b)
        return a*b
      end
    end
end

buyer.h = function (candidates)
  return {list_min(candidates)}
end

buyer['__index'] = buyer

-- make the buyer algebra a proper bill_algebra
setmetatable(buyer, bill_algebra)

-- start the calculation

local sellerRes = seller(1,5) 
local buyerRes = buyer(1,5) 

for k,v in ipairs(buyerRes) do
  print(v)
end
