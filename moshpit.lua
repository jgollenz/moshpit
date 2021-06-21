local cel = app.activeCel
if not cel then
  return app.alert("There is no active image")
end

function count(table)
    local amount = 0 
    for _ in pairs(table) do amount = amount + 1 end
    return amount
end

function get_row(rowNumber, img)
    local row = {}

    for i=0, img.width-1, 1 do
        table.insert(row, img:getPixel(i, rowNumber))
    end

    return row
end

function hue_from_rgb(r, g, b)

    hue = 0

    min = math.min(r,g,b)
    max = math.max(r,g,b)

    -- handle the rare case that all three values are equal
    if min == max then return hue end

    minMaxDiff = max-min

    if max == r then
        hue = (g-b) / minMaxDiff
    elseif max == g then
        hue = 2 + (b-r) / minMaxDiff
    elseif max == b then
        hue = 4 + (r-g) / minMaxDiff
    else
        print("ERROR: min/max not working in hue_from_rgb")
    end

    hue = hue * 60
    if hue < 0 then
        hue = hue + 360
    end

    return hue 
end

function sort_row(row)

    local keys = {}        
    local key_values = {}
    for _,pixel in pairs(row) do
        local red = app.pixelColor.rgbaR(pixel)
        local green = app.pixelColor.rgbaG(pixel)
        local blue = app.pixelColor.rgbaB(pixel)
        local alpha = app.pixelColor.rgbaA(pixel)
        local key = hue_from_rgb(red, green, blue)
        if key ~= key then 
            print("ERROR: key was NaN")
            key = 0 
        end
        keys[#keys+1] = key
        key_values[key] = pixel
    end

    table.sort(keys)

    local i = 0
    return function()
        i = i + 1 
        if keys[i] then
            return i, keys[i], key_values[keys[i]]
        end
    end
end

function mosh()
    math.randomseed(os.time())

    local img = cel.image:clone()
    local row_count = img.height
    local row_width = img.width
    if img.colorMode == ColorMode.RGB then
        local rgba = app.pixelColor.rgba
        local rgbaA = app.pixelColor.rgbaA
        local rowNumber = 0
        for i=0, img.height, 1 do
            rowNumber = i
            row = get_row(rowNumber, img)
            for i, hue, pixel in sort_row(row) do
                local red = app.pixelColor.rgbaR(pixel)
                local green = app.pixelColor.rgbaG(pixel)
                local blue = app.pixelColor.rgbaB(pixel)
                local alpha = app.pixelColor.rgbaA(pixel)
                img:drawPixel(i-1,rowNumber, rgba(red, green, blue, alpha))
            end
        end
    end

    cel.image = img

    app.refresh()

end

local dlg = Dialog("Moshpit")
dlg:button{ id="apply", text="sort", onclick=mosh}
dlg:show{ wait=false }
