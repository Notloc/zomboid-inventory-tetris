FormattedLuaWriter = {}

local function indent(level)
    local indent = "";
    for i=1,level do
        indent = indent .. "\t";
    end
    return indent;
end

local function createLine(text, indentLevel)
    return "\r\n"..indent(indentLevel) .. text;
end

function FormattedLuaWriter.formatLocalVariable(name, object, indentLevel)
    local text = createLine("local " .. name .. " = ", indentLevel);
    return text .. FormattedLuaWriter.formatVariable(object, indentLevel);
end

function FormattedLuaWriter.formatVariable(object, indentLevel)
    if type(object) == "table" then
        return FormattedLuaWriter.formatTable(object, indentLevel);
    elseif type(object) == "string" then
        return string.format("\"%s\"", object);
    elseif type(object) == "number" then
        return string.format("%d", object);
    elseif type(object) == "boolean" then
        return string.format("%s", tostring(object));
    else
        return "nil";
    end
end

function FormattedLuaWriter.formatTable(tableObj, indentLevel)
    local text = "{";
    for k,v in pairs(tableObj) do
        text = text .. createLine("[" .. FormattedLuaWriter.formatVariable(k, 0) .. "] = ", indentLevel + 1);
        text = text .. FormattedLuaWriter.formatVariable(v, indentLevel + 1);
        text = text .. ",";
    end
    text = text .. createLine("}", indentLevel);
    return text;
end
