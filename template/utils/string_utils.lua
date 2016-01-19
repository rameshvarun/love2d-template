function string.startsWith(str, start)
   return string.sub(str, 1, string.len(start)) == start
end

function string.endsWith(str, suffix)
   return suffix == '' or string.sub(str, -string.len(suffix)) == suffix
end
