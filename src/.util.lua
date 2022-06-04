util = {}

util.debug = false

util.dprint = function(string)
    if util.debug then
        print(string)
    end
end

util.count = function(table)
    local amount = 0
    for _ in pairs(table) do
        amount = amount + 1
    end
    return amount
end

-- exclusive
util.in_range = function(value, lower, upper)
    return (value > lower and value < upper)
end

util.toggle_ui_elements = function(toggle_state, elements, dialog)
    for _, element in pairs(elements) do
        dialog:modify({
            id = element,
            visible = toggle_state,
            enabled = toggle_state,
        })
    end
end

-- todo: put image first
-- returns a table where each element is a pixel of a row
util.get_row = function(row_number, image)
    local row = {}

    for x = 0, image.width - 1, 1 do
        table.insert(row, image:getPixel(x, row_number))
    end

    return row
end

-- returns a table where each element is a table representing a row
util.get_rows = function(starting_row, row_amount, image)
    local rows = {}
    for row_number = starting_row, starting_row + (row_amount - 1), 1 do
        table.insert(rows, util.get_row(row_number, image))
    end

    return rows
end

util.contains = function(table, value)
    for _, element in pairs(table) do
        if element == value then
            return true
        end
    end

    return false
end

return util
