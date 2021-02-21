-- ls.lua - List files
--
-- dofile("ls.lua")

do
  local k,v,l,s

  for k,v in pairs(file.list()) do
    l = string.format("%-15s",k)
    s = string.format("%5d",v)
    print(l.."   "..s.." bytes")
  end
end
