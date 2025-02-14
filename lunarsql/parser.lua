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

-- Parser struct
local Parser = {}
function Parser.new()
    local self = setmetatable({}, Parser)
    self.current = 1
    return self
end

function Parser:parse(tokens)
    self.tokens = tokens
    self.current = 1
    return self:parse_select()
end

function Parser:match(token_type)
    if self.current <= #self.tokens and self.tokens[self.current].type == token_type then
        self.current = self.current + 1

        return true
    end
    return false
end

function Parser:parse_select()
    if not self:match("SELECT") then
        error("Expected SELECT")
    end

    local columns = self:parse_column_list()

    if not self:match("FROM") then
        error("Expected FROM")
    end

    if self.current > #self.tokens then
        error("Expected table name")
    end

    local table_name = self.tokens[self.current].value
    self.current = self.current + 1

    local where_clause = nil

    if self.current <= #self.tokens and self.tokens[self.current].type == "WHERE" then
        self.current = self.current + 1

        where_clause = self:parse_where_clause()
    end

    return {
        type = "SELECT",
        columns = columns,
        table = table_name,
        where = where_clause
    }
end

function Parser:parse_column_list()
    local columns = {}

    while true do
        if self.current > #self.tokens then
            error("Unexpected end of input")
        end

        if self.tokens[self.current].type == "IDENTIFIER" then
            table.insert(columns, self.tokens[self.current].value)
            self.current = self.current + 1
        end

        if self.current > #self.tokens or self.tokens[self.current].type ~= "COMMA" then
            break
        end
        self.current = self.current + 1
    end
    return columns
end

function Parser:parse_where_clause()
    local clause = {}
    while self.current <= #self.tokens do
        table.insert(clause, self.tokens[self.current].value)
        self.current = self.current + 1
    end
    return table.concat(clause, " ")
end
