# Guild Wars 1 skill build/equipment template parser

Author: Johnt Knoxville

A script for parsing Guild Wars 1 skill/build and equipment template codes.

Template code format for skills is explained [here](https://wiki.guildwars.com/wiki/Skill_template_format).
Template code format for equipment is explained [here](https://wiki.guildwars.com/wiki/Equipment_template_format).

# Usage

Skill template decoding:
```lua
local p = require("gw_build_template_parser")

local t = p.parse("OwpiMypMBg1cxcBAMBdmtIKAA")
print(t.profession, ":", b)
for att, lvl in pairs(t.attributes) do
    print(att, ":", lvl)
end
for i, skill in ipairs(t.skills) do
    print(i, ":", skill)
end
```

Equipment template decoding:
```lua
local p = require("gw_equipment_template_parser")

local t = ep.parse("Pk5BAcn0UDAa1qGh5ITxOj5IHLhi5IDbfg5IRhvh5IDL")
print("Equipment", ":", e)
for i, item in pairs(t.items) do
    print(item.slot, ":", item.id, "(", item.color, ")")
    for m, mod in pairs(item.mods) do
        print(m, ":", mod)
    end
end
```

For usage see [example file](/example.lua).

# License

See [license file](/LICENSE).
