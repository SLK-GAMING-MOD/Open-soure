function s:GetIconByName(ab)
if ab==nil then return end
assert(ab,`"Library.GetIconByName". 'string' expected, got {typeof(ab)}`)

if O(ab)or#ab==0 then
return ab
end

local ac=M(ab)

if self.Icons[ac]then
local icon = self.Icons[ac]
return O(icon) and icon or "rbxassetid://"..icon
end

for ad,ae in self.Icons do
if ad:find(ac,1,true)then
return O(ae) and ae or "rbxassetid://"..ae
end
end
end
