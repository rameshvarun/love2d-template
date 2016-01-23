-- Lua startsWith and endsWith functions, from http://lua-users.org/wiki/StringRecipes
function string.startsWith(str, start)
   return string.sub(str, 1, string.len(start)) == start
end
function string.endsWith(str, suffix)
   return suffix == '' or string.sub(str, -string.len(suffix)) == suffix
end

-- String split (taken from Penlight).
function string.split(s, re, plain, n)
  local i1, ls = 1, {}
  if not re then re = '%s+' end
  if re == '' then return {s} end
  while true do
    local i2, i3 = s:find(re, i1, plain)
    if not i2 then
    local last = s:sub(i1)
    if last ~= '' then table.insert(ls, last) end
    if #ls == 1 and ls[1] == '' then
        return {}
    else
        return ls
    end
  end
  table.insert(ls, s:sub(i1,i2-1))
  if n and #ls == n then
    ls[#ls] = s:sub(i1)
    return ls
  end
    i1 = i3+1
  end
end
