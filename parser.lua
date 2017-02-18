#! /usr/bin/env lua

--[[
    OggjcpZroSPGWi4aLGzk5ipiYMA
    bits in order
    4: "This is a build" 1110 (14)
    4: version, all zero 0000
    2: profession bit length, (p)
    2p+4: primary profession
    2p+4: secondary profession
    4: number of attributes (N)
    4: attribute bit length (a_len)
    {
        a_len+4: attribute 1 ID
        4: attribute 1 rank
    } repeat N times
    4:  number of bits to represent skill codes (S)
    {
        S: skill id
    } repeat 8 times

]]


local skill_table = require("skilltable")
local attribute_table = require("attributes")

local base64_to_dec = {
    ["A"] =  0,["B"] =  1,["C"] =  2,["D"] =  3,
    ["E"] =  4,["F"] =  5,["G"] =  6,["H"] =  7,
    ["I"] =  8,["J"] =  9,["K"] = 10,["L"] = 11,
    ["M"] = 12,["N"] = 13,["O"] = 14,["P"] = 15,
    ["Q"] = 16,["R"] = 17,["S"] = 18,["T"] = 19,
    ["U"] = 20,["V"] = 21,["W"] = 22,["X"] = 23,
    ["Y"] = 24,["Z"] = 25,
    ["a"] = 26,["b"] = 27,["c"] = 28,["d"] = 29,
    ["e"] = 30,["f"] = 31,["g"] = 32,["h"] = 33,
    ["i"] = 34,["j"] = 35,["k"] = 36,["l"] = 37,
    ["m"] = 38,["n"] = 39,["o"] = 40,["p"] = 41,
    ["q"] = 42,["r"] = 43,["s"] = 44,["t"] = 45,
    ["u"] = 46,["v"] = 47,["w"] = 48,["x"] = 49,
    ["y"] = 50,["z"] = 51,
    ["0"] = 52,["1"] = 53,["2"] = 54,["3"] = 55,
    ["4"] = 56,["5"] = 57,["6"] = 58,["7"] = 59,
    ["8"] = 60,["9"] = 61,
    ["+"] = 62,["/"] = 63
}


local oct_bin = {
    ["0"] = "000", ["1"] = "001", ["2"] = "010",
    ["3"] = "011", ["4"] = "100", ["5"] = "101",
    ["6"] = "110", ["7"] = "111"
}
function oct_to_bin(i) return oct_bin[i] end

function dec_to_bin(n)
    local s = string.format("%o", n)
    s = s:gsub("%d", oct_to_bin)
    return string.reverse(s)
end

function bin_to_dec(bin_str)
    local bin = bin_str
    local sum = 0
    for i = 1, #bin do
        local n = string.sub(bin, i, i)
        sum = sum + n * math.pow(2, i-1)
    end
    return sum
end













local professions = {
   [0] =   "", [1] = "Wa", [ 2] =  "R", [3] = "Mo",
   [4] = "Ne", [5] = "Me", [ 6] =  "E", [7] =  "A",
   [8] = "Rt", [9] =  "P", [10] =  "D"
}


local function get_professions(T)
    -- profession length (in bits)
    local plen = 2*bin_to_dec(T(9,10)) + 4
    T.plen = plen
    local base = 11
    local prim = bin_to_dec(T(base, base+plen - 1))
    base = base + plen
    local sec =  bin_to_dec(T(base, base+plen - 1))
    T.primary = professions[prim]
    T.secondary = professions[sec]
    T.profession = T.primary
    if T.secondary ~= "" then
        T.profession = T.primary .. "/" .. T.secondary
    end
end


local function get_attributes(T)
    T.attributes = {}

    local base = 11 + 2*T.plen
    -- # of attributes
    local n_a = bin_to_dec(T(base, base+3))
    base = base + 4
    -- attribute bit length
    local a_len = bin_to_dec(T(base, base+3)) + 4
    base = base + 4

    for a = 0, n_a-1 do
        local start = base + a*a_len + a*4
        local stop = start + a_len-1
        local att = bin_to_dec(T(start, stop))
        local lvl = bin_to_dec(T(stop+1, stop+4))
        T.attributes[attribute_table[att]] = lvl
    end
    T.__skill_ptr = base + n_a*a_len + n_a*4
end




local function get_skills(T)
    T.skills = {}
    local base = T.__skill_ptr
    -- skill bin length
    local s_len = bin_to_dec(T(base, base+3)) + 8
    base = base + 4
    for s = 0, 7 do
        local start = base + s*s_len
        local stop = start + s_len-1
        local skill = bin_to_dec(T(start, stop))
        T.skills[s+1] = skill_table[skill]
    end
end



function parse(T_text)
    local T = {txt = T_text}
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
        if #b == 3 then
            T.bin = T.bin .. b .. "000"
        else
            T.bin = T.bin .. b
        end
    end

    --populate
    get_professions(T)
    get_attributes(T)
    get_skills(T)

    return T
end


local builds = {
    "OwpiMypMBg1cxcBAMBdmtIKAA",
    "OwBj0xf4oOlZ/n2D3RAdZSQ9HA",
    "OAKjYxiM5Q2ktlYMeTXMQHXTDg",
    "OQBDApwTOhwcgM4mmBaCeAUA",
    "OggjcpZroSPGWi4aLGzk5ipiYMA"
}

for _, b in pairs(builds) do
    print("---------------------------------------")
    local t = parse(b)
    print(t.profession, ":", b)
    for att, lvl in pairs(t.attributes) do
        print(att, ":", lvl)
    end
    for i, skill in ipairs(t.skills) do
        print(i, ":", skill)
    end
end
