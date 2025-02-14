-- Utility to split a string into a table of substrings
local function split(str, sep)
    local parts = {}
    for part in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(parts, part)
    end
    return parts
end

-- Utility to join a table of strings into a single string
local function join(parts, sep)
    local result = ""
    for i, part in ipairs(parts) do
        result = result .. part
        if i < #parts then
            result = result .. sep
        end
    end
    return result
end
