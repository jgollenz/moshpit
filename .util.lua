util = {}

util.debug = false

util.dprint = function (string)
    if util.debug then print(string) end
end

util.count = function (table)
    local amount = 0
    for _ in pairs(table) do amount = amount + 1 end
    return amount
end

-- exclusive
util.in_range = function (value, lower, upper)
    --dprint(tostring(value)) 
    return (value > lower and value < upper)
end

util.toggle_UI_Elements = function (toggleState, elements, dialog)
    for _,element in pairs(elements) do
        dialog:modify {
            id = element,
            visible=toggleState,
            enabled=toggleState,
        }
    end
end

util.get_row = function (rowNumber, img)
    local row = {}

    for i=0, img.width-1, 1 do
        table.insert(row, img:getPixel(i, rowNumber))
    end

    return row
end

util.contains = function (table, value)
    for _, element in pairs(table) do
        if element == value then
            return true
        end
    end
    
    return false
end

return util