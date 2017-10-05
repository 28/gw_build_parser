local p = require("gw_build_parser")

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

function parse_builds(builds)
   for _, b in pairs(builds) do
      print("---------------------------------------")
      local t = p.parse(b)
      print(t.profession, ":", b)
      for att, lvl in pairs(t.attributes) do
         print(att, ":", lvl)
      end
      for i, skill in ipairs(t.skills) do
         print(i, ":", skill)
      end
   end
end

parse_builds(sample_builds)
