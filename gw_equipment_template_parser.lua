--[[
   This is the table represent the order of bits and their value.
   Bits are acquired by base64 decoding the template code.
   Bits are stored in little endian.
   
   +=========================+=====================================+
   | Number of bits in order |                Value                |
   +=========================+=====================================+
   | 4                       | "This is an equipment template" (15)|
   +-------------------------+-------------------------------------+
   | 4                       | Version (4 zeroes)                  |
   +-------------------------+-------------------------------------+
   | 4                       | Item id bit length (il)             |
   +-------------------------+-------------------------------------+
   | 4                       | Modifier id bit length (ml)         |
   +-------------------------+-------------------------------------+
   | 3                       | Item count (ic)                     |
   +-------------------------+-------------------------------------+
   | repeat ic times         |                                     |
   +-------------------------+-------------------------------------+
   | 3                       | Equipment slot                      |
   +-------------------------+-------------------------------------+
   | il                      | Item id                             |
   +-------------------------+-------------------------------------+
   | 2                       | Modifier count (mc)                 |
   +-------------------------+-------------------------------------+
   | 4                       | Color                               |
   +-------------------------+-------------------------------------+
   | repeat mc times         |                                     |
   +-------------------------+-------------------------------------+
   | ml                      | Modifier id                         |
   +-------------------------+-------------------------------------+
   | ---------------         |                                     |
   +-------------------------+-------------------------------------+
   | ---------------         |                                     |
   +-------------------------+-------------------------------------+
]]
local M = {_NAME="gw_equipment_template_parser"}

require("common")

local items_table = require("data/items")
local modifiers_table = require("data/modifiers")

local slot_table = {
   [0] = "Weapon",
   [1] = "Off-hand",
   [2] = "Chest",
   [3] = "Legs",
   [4] = "Head",
   [5] = "Feet",
   [6] = "Hands",
}

local color_table = {
   [0] = "N/A",
   [1] = "N/A",
   [2] = "Blue",
   [3] = "Green",
   [4] = "Purple",
   [5] = "Red",
   [6] = "Yellow",
   [7] = "Brown",
   [8] = "Orange",
   [9] = "Grey",
}

local function populate(T)
   local item_len = bin_to_dec(T(9, 12))
   local mod_len = bin_to_dec(T(13, 16))
   local item_count = bin_to_dec(T(17, 19))
   local base = 20

   T.items = {}
   for i = 1, item_count do
      local I = {}
      I.mods = {}

      I.slot = slot_table[bin_to_dec(T(base, base + 2))]
      base = base + 3
      I.id = items_table[bin_to_dec(T(base, base + item_len - 1))]
      base = base + item_len
      local mod_count = bin_to_dec(T(base, base + 1))
      base = base + 2
      I.color = color_table[bin_to_dec(T(base, base + 3))]
      base = base + 4

      for m = 1, mod_count do
         local a = T(base, base + mod_len - 1)
         local b = bin_to_dec(a)
         local c = modifiers_table[b]

         I.mods[m] = modifiers_table[bin_to_dec(T(base, base + mod_len - 1))]
         base = base + mod_len
      end

      T.items[i] = I
   end
end

function M.parse(T_text)
   local T = init(T_text)

   populate(T)

   return T
end

return M
