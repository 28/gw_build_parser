local bp = require("gw_build_template_parser")
local ep = require("gw_equipment_template_parser")

local sample_builds = {
   "OwpiMypMBg1cxcBAMBdmtIKAA",
   "OwBj0xf4oOlZ/n2D3RAdZSQ9HA",
   "OAKjYxiM5Q2ktlYMeTXMQHXTDg",
   "OQBDApwTOhwcgM4mmBaCeAUA",
   "OggjcpZroSPGWi4aLGzk5ipiYMA",
   "OQYTgmIT5xvAY4bGmpGf1wmDBA",
   "OQYTkmIP5ZsAWWKMlWBf1wuVAA",
   "OgSjQoqK7OvXDBU9+OfJ3IY1LA",
   "OABDUjxHT5B2B7OJglBWCfCVVA",
   "OgcTY1L25xhxwOYEfhDuh2krBA"
}

local sample_equipment = {
   "Pk5BAcn0UDAa1qGh5ITxOj5IHLhi5IDbfg5IRhvh5IDL",
   "PkpRhuSQl+oQnVOVxUnVJLLriFJDbPn1IBrTnVP/EA"
}

function parse_builds(builds)
   for _, b in pairs(builds) do
      print("---------------------------------------")
      local t = bp.parse(b)
      print(t.profession, ":", b)
      for att, lvl in pairs(t.attributes) do
         print(att, ":", lvl)
      end
      for i, skill in ipairs(t.skills) do
         print(i, ":", skill)
      end
   end
end

function parse_equipment(eq)
   for _, e in pairs(eq) do
      print("---------------------------------------")
      local t = ep.parse(e)
      print("Equipment", ":", e)
      for i, item in pairs(t.items) do
         print()
         print(item.slot, ":", item.id, "(", item.color, ")")
         for m, mod in pairs(item.mods) do
            print(m, ":", mod)
         end
      end
   end
end

parse_builds(sample_builds)
parse_equipment(sample_equipment)
