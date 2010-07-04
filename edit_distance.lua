require 'ADPCombinators'

--[[-- Test with the edit distance problem --]]--

local evalString = 'darling$enilria'

-- define the problem
edit_algebra = {}
edit_algebra['__call'] = function (self, i, j, n) 
  -- define functions and tables
  local delete = self.delete
  local insert = self.insert
  local replace = self.replace
  local null = self.null
  local h = self.h
  local tab = {}
  
  -- this is the grammar
  local dollar = parserChar(evalString, '$')
  local achar = parserAnyChar(evalString)
  
  -- special treatment of the starting symbol
  local function alignment(i,j)
                return  tabulate(
                  (        (null -ttt- dollar)
                     -iii- (delete -ttt- achar -_ss- alignment )
                     -iii- (insert -ttt-             alignment -ss_- achar )
                     -iii- (replace -ttt- achar -_ss- alignment -ss_- achar )) -ccc- h, tab, n )(i,j)
  end
  return alignment(i,j)
end

-- the unitDistance algebra
local unitDistance = {}

unitDistance.null = function (a)
    return 0
end

unitDistance.delete = function (x)
  return function (s)
    return s + 1
  end
end

unitDistance.insert = function (s)
  return function (y)
    return s + 1
  end
end

unitDistance.replace = function (x)
  return function (s)
    return function (y)
      if x == y then
        return s
      else
        return s + 1
      end
    end
  end
end

unitDistance.h = function (candidates)
  return {list_min(candidates)}
end

-- make the unitDistance algebra a proper edit_algebra
setmetatable(unitDistance, edit_algebra)

-- start the calculation
local unitDistanceRes = unitDistance(1, #evalString, #evalString) 

-- print the examples

io.write('evaluating: ' .. evalString .. '\n')
io.write('unitDistance:\n')
for k,v in ipairs(unitDistanceRes) do
  print(v)
end
