local dialog = -1

-- bounds
local width = 120
local height = 150
local cutoff_sprite
local cutoff_sprite_opened = false

sorter = {}

function open_cutoff_sprite()

    -- create a new sprite to preview the cutoff
    cutoff_sprite = Sprite(app.activeSprite.width, app.activeSprite.height)
    cutoff_sprite_opened = true
    app.command.FitScreen()
    sorter.cutoff(dialog.data.lower, dialog.data.upper)
    
end

sorter.sort_row = function(row, attribute)

    local keys = {}
    local positions = {}
    local key_values = {}
    for i, pixel in pairs(row) do
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
        if util.in_range(constraint(pixel), lower, upper) then
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
    
    if cutoff_sprite_opened then 
        app.activeSprite:close()
        cutoff_sprite_opened = false
    end
    
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
        row = sorter.filter_row(row, hsl.lightness_from_pixel, lower, upper)
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

local sorter_backup_img = app.activeCel.image:clone()

sorter.cutoff = function (lower, upper)

    if not cutoff_sprite_opened then
        open_cutoff_sprite()
    end

    local img = app.activeCel.image:clone()

    -- 1. go through all pixels
    for pixel in sorter_backup_img:pixels() do
        local rgba = app.pixelColor.rgba
        local actual_pixel = pixel()

        -- 2. get pixel lightness
        local red = app.pixelColor.rgbaR(pixel())
        local green = app.pixelColor.rgbaG(pixel())
        local blue = app.pixelColor.rgbaB(pixel())
        local lightness = hsl.lightness_from_pixel(actual_pixel)
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
    
    -- todo: not DRY. Think about at get_sub_dialog() function
    dialog = Dialog{
        title="Sort Pixels",
        onclose=function()
            if (should_apply == false) then
                -- reset
                app.activeCel.image = backup_img
                app.refresh()
            else
                should_apply = false
            end

            sub_dialogs.sorter_dialog = nil
        end
    }
    
    dialog

        :separator{
            text="Treshold"}
            
        :slider{
            id="upper",
            label="Max",
            min=0,
            max=100,
            value=70,
            onchange=function()
                sorter.cutoff(dialog.data.lower, dialog.data.upper)
            end
        }
        
        :slider{
            id="lower",
            label="Min",
            min=0,
            max=100,
            value=30,
            onchange=function()
                sorter.cutoff(dialog.data.lower, dialog.data.upper)
            end
        }
            
        :button{
            id="preview",
            text="Preview",
            onclick=function()  
                sorter.pixel_sort(dialog.data.lower, dialog.data.upper)
            end
        }

        :newrow()

        :button{
            id="reset",
            text="Reset",
            onclick=function()
                app.activeCel.image = sorter_backup_img
                app.refresh()
            end
        }

        :button{
            id="apply",
            text="Apply",
            onclick=function()
                sorter_backup_img = app.activeCel.image:clone()
            end
        }
            
        :show{
            wait=false,
            bounds=Rectangle(x,y,width,height);
        }

    open_cutoff_sprite()
    
    return dialog
end

return sorter