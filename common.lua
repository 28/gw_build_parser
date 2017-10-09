base64_to_dec = require("data/base64")

function zero_pad_to(n, l)
   if #n >= l then return n end
   local p = l - #n
   local r = n
   for i = 1, p do
      r = "0" .. r
   end
   return r
end

function dec_to_bin(n)
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

function bin_to_dec(bin_str)
   local bin = bin_str
   local sum = 0
   for i = 1, #bin do
      local n = string.sub(bin, i, i)
      sum = sum + n * math.pow(2, i - 1)
   end
   return sum
end

function init(template)
   local T = { txt = template}
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

   return T
end
