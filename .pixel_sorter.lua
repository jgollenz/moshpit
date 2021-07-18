local dialog = -1

-- bounds
local width = 120
local height = 200

sorter = {}

sorter.sort_row = function(row, attribute)

    local keys = {}
    local positions = {}
    local key_values = {}
    for i, pixel in pairs(row) do
        util.dprint(i)
        util.dprint(tostring(pixel))
        local key = attribute(pixel)
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

sorter.filter_row = function(row, constraint, lower, upper)
    
    local filtered_row = {}

    for i, pixel in pairs(row) do
        -- todo: not given that we have rgb. Just hand over the pixel itself
        local red = app.pixelColor.rgbaR(pixel)
        local green = app.pixelColor.rgbaG(pixel)
        local blue = app.pixelColor.rgbaB(pixel)
        if util.in_range(constraint(red, green, blue), lower, upper) then
            filtered_row[i] = pixel
        end
    end

    return filtered_row
end

sorter.pixel_sort = function (lower,upper)

    if lower >= upper then
        app.alert("lower threshold must be less than upper threshold")
        return
    end

    math.randomseed(os.time())

    local img = app.activeCel.image:clone()
    local row_count = img.height - 1

    local color_mode
    if img.colorMode == ColorMode.RGB then
        color_mode = app.pixelColor.rgba
    elseif img.colorMode == ColorMode.GRAY then
        color_mode = app.pixelColor.graya
    end

    for row_number = 0, row_count, 1 do
        row = util.get_row(row_number, img)
        --row = sorter.filter_row(row, hsl.lightness_from_rgb, lower, upper)
        -- todo: get this hue outta here
        for i, hue, position, pixel in sorter.sort_row(row, hsl.hue_from_pixel) do

            if (img.colorMode == ColorMode.INDEXED) then
                img:drawPixel(position-1, row_number, pixel)
            else
                local red = app.pixelColor.rgbaR(pixel)
                local green = app.pixelColor.rgbaG(pixel)
                local blue = app.pixelColor.rgbaB(pixel)
                local alpha = app.pixelColor.rgbaA(pixel)
                -- todo: this should work with just handing over pixel. but it doesn't
                img:drawPixel(position-1, row_number, color_mode(red, green, blue, alpha))    
            end
        end
    end

    app.activeCel.image = img
    app.refresh()
    
end

local backup_img = app.activeCel.image:clone()

sorter.cutoff = function (lower, upper)

    local img = app.activeCel.image:clone()

    -- 1. go through all pixels
    for pixel in backup_img:pixels() do
        local rgba = app.pixelColor.rgba
        local actual_pixel = pixel()

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

    app.activeCel.image = img
    app.refresh()
end

sorter.show = function(x,y)  
    
    local image = app.activeCel.image
    local backup_img = image:clone()
    -- todo: not dry conform
    local new_dialog = Dialog{
        title="Sort Pixels",
        onclose=function()
            if (should_apply == false) then
                -- reset
                app.activeCel.image = backup_img
                app.refresh()
                --app.alert("Restting image")
            else
                should_apply = false
            end
            
            sub_dialogs.sorter_dialog = nil
        end
    }
    
    dialog = new_dialog
    
    dialog 
            
        :check{
            id="debug",
            label="debug",
            selected=false,
            onclick=function()
                util.debug=dialog.data.debug
            end
        }

        :slider{
            id="upper",
            label="Upper threshold",
            min=0,
            max=100,
            value=70,
            onchange=function()
                sorter.cutoff(dialog.data.lower, dialog.data.upper)
            end
        }
        
        :slider{
            id="lower",
            label="lower threshold",
            min=0,
            max=100,
            value=30,
            onchange=function()
                sorter.cutoff(dialog.data.lower, dialog.data.upper)
            end
        }
            
        :button{
            id="sort",
            text="Sort",
            onclick=function()  
                sorter.pixel_sort(dialog.data.lower, dialog.data.upper)
            end
        }
            

        :show{
            wait=false,
            bounds=Rectangle(x,y,width,height);
        }
    
    return dialog
end

return sorter