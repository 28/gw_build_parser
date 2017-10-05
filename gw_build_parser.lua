--[[
   This is the table represent the order of bits and their value.
   Bits are acquired by base64 decoding the template code.
   Bits are stored in little endian.

   +=========================+===========================================+
   | Number of bits in order |                   Value                   |
   +=========================+===========================================+
   | 4                       | "This is a build" (14)                    |
   +-------------------------+-------------------------------------------+
   | 4                       | Version (4 zeroes)                        |
   +-------------------------+-------------------------------------------+
   | 2                       | Profession bit length (p)                 |
   +-------------------------+-------------------------------------------+
   | 2*p+4                   | Primary profession                        |
   +-------------------------+-------------------------------------------+
   | 2*p+4                   | Secondary proffesion                      |
   +-------------------------+-------------------------------------------+
   | 4                       | Number of attributes (an)                 |
   +-------------------------+-------------------------------------------+
   | 4                       | Attribute bit length (al)                 |
   +-------------------------+-------------------------------------------+
   | repeat an times         |                                           |
   +-------------------------+-------------------------------------------+
   | al+4                    | Attribute id                              |
   +-------------------------+-------------------------------------------+
   | 4                       | Attribute rank                            |
   +-------------------------+-------------------------------------------+
   | ---------------         |                                           |
   +-------------------------+-------------------------------------------+
   | 4                       | Number of bits to represent skill code(s) |
   +-------------------------+-------------------------------------------+
   | repeat 8 times          |                                           |
   +-------------------------+-------------------------------------------+
   | s                       | Skill id                                  |
   +-------------------------+-------------------------------------------+
   | --------------          |                                           |
   +-------------------------+-------------------------------------------+
]]

local M = {_NAME="gw_build_parser"}

local skills_table = require("data/skills")
local attributes_table = require("data/attributes")
local professions_table = require("data/professions")
local base64_to_dec = require("data/base64")

local function zero_pad_to(n, l)
   if #n >= l then return n end
   local p = l - #n
   local r = n
   for i = 1, p do
      r = "0" .. r
   end
   return r
end

local function dec_to_bin(n)
   local num = tonumber(n)
   local s = ""

   repeat
      local b = num % 2
      s = b .. s
      local q = math.floor(num / 2)
      num = q
   until (num == 0)

   return string.reverse(zero_pad_to(s, 6))
end

local function bin_to_dec(bin_str)
   local bin = bin_str
   local sum = 0
   for i = 1, #bin do
      local n = string.sub(bin, i, i)
      sum = sum + n * math.pow(2, i - 1)
   end
   return sum
end

local function get_professions(T)
   -- Profession length (in bits)
   local plen = 2 * bin_to_dec(T(9, 10)) + 4
   T.plen = plen
   local base = 11
   local prim = bin_to_dec(T(base, base + plen - 1))
   base = base + plen
   local sec = bin_to_dec(T(base, base + plen - 1))
   T.primary = professions_table[prim]
   T.secondary = professions_table[sec]
   T.profession = T.primary
   if T.secondary ~= "" then
      T.profession = T.primary .. "/" .. T.secondary
   end
end

local function get_attributes(T)
   T.attributes = {}

   local base = 11 + 2 * T.plen
   -- Number of attributes
   local n_a = bin_to_dec(T(base, base + 3))
   base = base + 4
   -- Attribute bit length
   local a_len = bin_to_dec(T(base, base + 3)) + 4
   base = base + 4

   for a = 0, n_a - 1 do
      local start = base + a * a_len + a * 4
      local stop = start + a_len - 1
      local att = bin_to_dec(T(start, stop))
      local lvl = bin_to_dec(T(stop + 1, stop + 4))
      T.attributes[attributes_table[att]] = lvl
   end
   T.__skill_ptr = base + n_a * a_len + n_a * 4
end

local function get_skills(T)
   T.skills = {}
   local base = T.__skill_ptr
   -- Skill bit length
   local s_len = bin_to_dec(T(base, base + 3)) + 8
   base = base + 4
   for s = 0, 7 do
      local start = base + s * s_len
      local stop = start + s_len - 1
      local skill = bin_to_dec(T(start, stop))
      T.skills[s + 1] = skills_table[skill]
   end
end

function M.parse(T_text)
   local T = { txt = T_text}
   -- Add subscript indexing
   setmetatable(T, {
                   __index = function(self, i)
                      return string.sub(self.txt, i, i)
                   end,
                   __call = function(self, i, j)
                      if j then
                         return string.sub(self.bin, i, j)
                      else
                         return string.sub(self.bin, i, i)
                      end
                   end
   })

   T.bin = ""
   for i = 1, #T.txt do
      local c = T[i]
      local n = base64_to_dec[c]
      local b = dec_to_bin(n)
      T.bin = T.bin .. b
   end

   -- Populate
   get_professions(T)
   get_attributes(T)
   get_skills(T)

   return T
end

return M
