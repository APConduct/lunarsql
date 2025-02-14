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

-- Token struct
local Token = {}
Token.__index = Token

function Token.new(type, value)
    return setmetatable({ type = type, value = value }, Token)
end

function Token:__tostring()
    return self.type .. ": " .. self.value
end

function Token:__eq(other)
    return self.type == other.type and self.value == other.value
end

local Lexer = {}
function Lexer.new()
    local self = setmetatable({}, Lexer)
    self.patterns = {
        { type = "SELECT",     pattern = "^[Ss][Ee][Ll][Ee][Cc][Tt]" },
        { type = "FROM",       pattern = "^[Ff][Rr][Oo][Mm]" },
        { type = "WHERE",      pattern = "^[Ww][Hh][Ee][Rr][Ee]" },
        { type = "IDENTIFIER", pattern = "^[A-Za-z_][A-Za-z0-9_]*" },
        { type = "COMMA",      pattern = "^," },
        { type = "OPERATOR",   pattern = "^[=<>]" },
        { type = "NUMBER",     pattern = "^%d+" },
        { type = "WHITESPACE", pattern = "^%s+" }
    }
    return self
end

function Lexer:tokenize(input)
    local tokens = {}
    local pos = 1

    while pos <= #input do
        local matched = false
        for _, pattern in ipairs(self.patterns) do
            local start, finish = string.find(input:sub(pos), pattern.pattern)
            if start == 1 then
                local value = input:sub(pos, pos + finish - 1)
                if pattern.type ~= "WHITESPACE" then
                    table.insert(tokens, Token.new(pattern.type, value))
                end
                pos = pos + finish
                matched = true
                break
            end
        end
        if not matched then
            error("Invalid tokoen at position " .. pos)
        end
    end
    return tokens
end
