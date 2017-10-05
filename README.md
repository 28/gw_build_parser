# Guild Wars 1 build template parser

A script for parsing Guild Wars 1 skill template codes.
Template code format is explained [here](https://wiki.guildwars.com/wiki/Skill_template_format).

# Usage

Skill template decoding:
```lua
local p = require("gw_build_parser")

local t = p.parse("OwpiMypMBg1cxcBAMBdmtIKAA")
print(t.profession, ":", b)
for att, lvl in pairs(t.attributes) do
    print(att, ":", lvl)
end
for i, skill in ipairs(t.skills) do
    print(i, ":", skill)
end
```

For usage see [example file](/example.lua).

# License

See [license file](/LICENSE).
