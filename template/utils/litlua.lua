
table.insert(package.loaders or package.searchers, function(name)
  local dirsep = "/"
  local file_path = name:gsub("%.", dirsep) .. '.lua.md'
  if not love.filesystem.exists(file_path) then
    return nil, "Could not find .lua.md file"
  end

  local code, inCodeBlock = "", false
  for line in love.filesystem.lines(file_path) do
    if inCodeBlock then
      if line:startsWith("```") then inCodeBlock = false
      else code = code .. line .. "\n" end
    end

    if not inCodeBlock then
      code = code .. "-- " .. line .. "\n"
      if line:startsWith("```lua") then inCodeBlock = true end
    end
  end

  -- Return the module, or report an error.
  local res, err = loadstring(code, file_path)
  if not res then error(file_path .. ": " .. err) end
  return res
end)
