local Parser = require("lunarsql/parser")

-- Database class
local Database = {}
Database.__index = Database

function Database.new()
    local self = setmetatable({}, Database)
    self.tables = {}
    return self
end

function Database:create_table(name, data)
    self.tables[name] = data
end

function Database:execute_select(stmt)
    local table_date = self.tables[stmt.table]
    if not table_date then
        error("Table " .. stmt.table .. "does not exist.")
    end

    local results = {}
    for _, row in ipairs(table_date) do
        -- Very simple where clause evaluation
        if stmt.where then
            -- NOTE: This is a simplified version of the where clause evaluation
            -- TODO : properly parse and evaluate the where clause
            local success = load("return " .. stmt.where, nil, "t", row)
            if not success or not success() then
                goto continue
            end
        end

        local result = {}
        for _, col in ipairs(stmt.columns) do
            if col == "*" then
                for k, v in pairs(row) do
                    result[k] = v
                end
            elseif row[col] then
                result[col] = row[col]
            end
        end
        table.insert(results, result)
        ::continue::
    end
    return results
end

-- Example usage
local function execute_query(query, db)
    local lexer = Parser.Lexer.new()
    local parser = Parser.Parser.new(lexer)
    local tokens = lexer:tokenize(query)
    local ast = parser:parse(tokens)
    return db:execute_select(ast)
end
