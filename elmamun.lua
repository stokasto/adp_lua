require 'ADPCombinators'

--[[-- Test with ElMamuns --]]--

local evalString = '1+2*3+8*4'

-- define the problem
bill_algebra = {}
bill_algebra['__call'] = function (self,i,j, n) 
  -- define functions and tables
  local add = self.add
  local mult = self.mult
  local h = self.h
  local tab = {}
  
  -- this is the grammar
  local digit = parserChar(evalString, '1')
  local plus = parserChar(evalString, '+')
  local times = parserChar(evalString, '*')
  local number =        parserChar(evalString, '1') -iii- parserChar(evalString, '2')
                 -iii-  parserChar(evalString, '3') -iii- parserChar(evalString, '4')
                 -iii-  parserChar(evalString, '5') -iii- parserChar(evalString, '6')
                 -iii-  parserChar(evalString, '7') -iii- parserChar(evalString, '8')
                 -iii-  parserChar(evalString, '9') -iii- parserChar(evalString, '0')


  -- special treatment of the starting symbol
  local function formula(i,j)
                return  tabulate( ((number) 
                     -iii- (add -ttt- formula -ssr- plus -sss- formula)
                     -iii- (mult -ttt- formula -ssr- times -sss- formula)) -ccc- h, tab, n )(i,j)
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

local sellerRes = seller(1,9, 9) 
local buyerRes = buyer(1,9, 9) 

-- print the examples

io.write('evaluating: ' .. evalString .. '\n')
io.write('Buyer:\n')
for k,v in ipairs(buyerRes) do
  print(v)
end

io.write('Seller:\n')
for k,v in ipairs(sellerRes) do
  print(v)
end
