local util = dofile("./.util.lua")
local hsl = dofile("./.hsl.lua")

local cel = app.activeCel
if not cel then
    return app.alert("There is no active image")
end

local should_apply = false

local backupImg = cel.image:clone()

function get_row(rowNumber, img)
    local row = {}

    for i=0, img.width-1, 1 do
        table.insert(row, img:getPixel(i, rowNumber))
    end

    return row
end

function filter_row(row, constraint, lower, upper)
    local filtered_row = {}

    for i, pixel in pairs(row) do
        local red = app.pixelColor.rgbaR(pixel)
        local green = app.pixelColor.rgbaG(pixel)
        local blue = app.pixelColor.rgbaB(pixel)
        if util.in_range(constraint(red, green, blue), lower, upper) then
            filtered_row[i] = pixel
            --table.insert(filtered_row, {i = pixel})
            --util.dprint("yes")
        else
            --util.dprint("no")
        end
    end

    --[[
    for k, v in pairs(filtered_row) do 
        print(k)
        print(v)
    end
    ]]--
    return filtered_row 
end

function sort_row(row, attribute)

    local keys = {}        
    local positions = {}
    local key_values = {}
    for i, pixel in pairs(row) do
        util.dprint(i)
        util.dprint(tostring(pixel))
        local red = app.pixelColor.rgbaR(pixel)
        local green = app.pixelColor.rgbaG(pixel)
        local blue = app.pixelColor.rgbaB(pixel)
        local alpha = app.pixelColor.rgbaA(pixel)
        local key = attribute(red, green, blue)
        if key ~= key then 
            print("ERROR: key was NaN")
            key = 0 
        end
        keys[#keys+1] = key
        positions[#positions+1] = i
        key_values[key] = pixel
    end

    table.sort(keys)
    table.sort(positions)

    local i = 0
    return function()
        i = i + 1 
        if keys[i] then
            return i, keys[i], positions[i], key_values[keys[i]]
        end
    end
end

function pixel_sort(lower, upper)

    if lower >= upper then
        app.alert("lower threshold must be lower than upper threshold")
        return
    end

    math.randomseed(os.time())

    local img = cel.image:clone()
    local row_count = img.height
    local row_width = img.width


    if img.colorMode == ColorMode.RGB then
        local rgba = app.pixelColor.rgba
        for rowNumber=0, row_count, 1 do
            row = get_row(rowNumber, img)
            row = filter_row(row, hsl.lightness_from_rgb, lower, upper)
            for i, hue, position, pixel in sort_row(row, hsl.hue_from_rgb) do
                local red = app.pixelColor.rgbaR(pixel)
                local green = app.pixelColor.rgbaG(pixel)
                local blue = app.pixelColor.rgbaB(pixel)
                local alpha = app.pixelColor.rgbaA(pixel)
                img:drawPixel(position-1,rowNumber, rgba(red, green, blue, alpha))
            end
        end
    else
        print(string.format("No support for %s yet", tostring(img.colorMode)))
    end


    cel.image = img

    app.refresh()

end

function cutoff(lower, upper)

    local img = cel.image:clone()

    -- 1. go through all pixels
    for pixel in backupImg:pixels() do
        local rgba = app.pixelColor.rgba
        local actualPixel = pixel()

        -- 2. get pixel lightness
        local red = app.pixelColor.rgbaR(pixel())
        local green = app.pixelColor.rgbaG(pixel())
        local blue = app.pixelColor.rgbaB(pixel())
        local lightness = hsl.lightness_from_rgb(red, green, blue)
        local alpha = app.pixelColor.rgbaA(pixel())
        if lightness > upper or lightness < lower then
            -- 3. make pixel black
            img:drawPixel(pixel.x, pixel.y, rgba(0, 0, 0, alpha))
        else 
            -- 4. make pixel white
            img:drawPixel(pixel.x, pixel.y, rgba(255, 255, 255, alpha))
        end
    end

    cel.image = img
    app.refresh()
end

--local threshholdPreview = Sprite(app.activeSprite)

local dlg = Dialog{ 
    title="Moshpit", 
    onclose=function()
        if (should_apply == false) then
            cel.image = backupImg
            app.refresh()
            app.alert("Resetting image")
        else
            should_apply = false
        end
    end}

dlg
    
    :check{
        id="debug",
        label="debug",
        selected=false,
        onclick=function()
            util.debug=dlg.data.debug
        end} 

    :slider{ 
        id="upper", 
        label="Upper threshold", 
        min=0, 
        max=100, 
        value=70,
        onchange=function()
            cutoff(dlg.data.lower, dlg.data.upper)
        end}

    :slider{ 
        id="lower", 
        label="lower threshold", 
        min=0, 
        max=100, 
        value=30,
        onchange=function()
            cutoff(dlg.data.lower, dlg.data.upper)
        end} 

--[[    :check{ 
        id="check", 
        label="show", 
        selected=false, 
        onclick=function()
            toggleUIElements(dlg.data.check, { "test" }, dlg)
        end } ]]--

    :entry{
        id="test",
        label="test",
        visible=false
    }

    :button{ 
        id="sort", 
        text="sort", 
        onclick=function()
            --cel.image = backupImg
            pixel_sort(dlg.data.lower, dlg.data.upper)
        end}
        
    :button{
        id="apply",
        text="Apply",
        onclick=function()
            should_apply = true
            dlg:close()
        end}


    :show {
        --wait=false
        bounds=Rectangle(75,50,120,100);
    }   

--cutoff(dlg.data.lower, dlg.data.upper)
