local dialog = -1

-- bounds
local width = 120
local height = 200

shifter = {}

-- refactor: move to util?
shifter.expand_cel_bounds = function (cel, width, height, x_image_target, y_image_target, x_origin, y_origin)
    -- todo: undoing this bound extending is a pain. Need to find a way to do it better
    local expanded_image = Image(width, height, cel.image.colorMode)
    expanded_image:drawImage(cel.image, x_image_target, y_image_target)
    cel.image = expanded_image
    cel.position = Point(x_origin, y_origin) -- undoable action
    
    return cel
end

--[[
    Returns a table of {row_amount} random indices of rows, non-duplicate 
]]
shifter.get_row_indices = function (row_amount, image_height)
    local row_indices = {}

    -- perf: not really happy with this solution
    for i = 1, row_amount, 1 do
        local next_row
        repeat
            next_row = math.random(0, image_height - 1)
        until util.contains(row_indices, next_row) == false
        table.insert (row_indices, next_row)
    end
    
    return row_indices
end

-- feat: add random pixel shift
shifter.shift_rows = function (lower_row_amount, upper_row_amount, lower_shift_amount, upper_shift_amount)
    local shifted_image;
    local active_cel = app.activeCel
    if (active_cel.image.width < app.activeSprite.width) then
        -- extend cel bounds, to allow shifted pixels to have x positions outside the original width of the image
        shifted_image = shifter.expand_cel_bounds(active_cel,
                app.activeSprite.width, active_cel.image.height, 
                active_cel.position.x, 0, 
                0, active_cel.position.y).image
    else
        shifted_image = active_cel.image:clone()
    end
    
    local row_amount = math.random(lower_row_amount, upper_row_amount)
    local rows_to_shift = shifter.get_row_indices(row_amount, shifted_image.height)

    local row_number = -1
    for i=1, row_amount, 1 do
        -- feat: make this optional, because it leads to cool effects actually
        row_number = rows_to_shift[i]
        -- feat: expose magic number to users
        local slice = util.get_rows(row_number, 1, shifted_image)
        local shift_amount = math.random(lower_shift_amount, upper_shift_amount)
        for y, row in pairs(slice) do 
            for x, pixel in pairs(row) do
                -- this is the culprit, it should not be a different amount for each pixel but for each row
                --shift_amount = math.random(lowerShiftAmount, upperShiftAmount) 
                shifted_image:drawPixel((x - 1) + shift_amount, row_number + (y - 1), pixel)
            end
        end
    end
    
    app.activeCel.image = shifted_image
    app.refresh()
end

shifter.show = function(x,y)

    local image = app.activeCel.image
    local backup_img = image:clone() -- bug: save all cels + original position
    local new_dialog = Dialog{
        title="Shift Rows",
        onclose=function()
            if (should_apply == false) then
                app.activeCel.image = backup_img
                app.refresh()
            else
                should_apply = false
            end

            sub_dialogs.shifter_dialog = nil
        end
    }
    
    dialog = new_dialog

    dialog
        :separator{
        text="Row amount"}

        :radio{
            id="row_range",
            selected=true,
            label="Type",
            text="Range",
            onclick=function()
                util.toggle_ui_elements(dialog.data.row_fixed, { "fixed_row_amount" }, dialog)
                util.toggle_ui_elements(dialog.data.row_range, { "upper_row_amount", "lower_row_amount" }, dialog)
            end
        }
        
        :radio{
            id="row_fixed",
            text="Fixed",
            onclick=function()
                util.toggle_ui_elements(dialog.data.row_fixed, { "fixed_row_amount" }, dialog)
                util.toggle_ui_elements(dialog.data.row_range, { "upper_row_amount", "lower_row_amount" }, dialog)
            end
        }
            
        :slider{
            id="upper_row_amount",
            label="Max",
            min=1,
            max=image.height, 
            value=image.height * 0.7} 
           
        :slider{
            id="lower_row_amount",
            label="Min",
            min=1,
            max=image.height,
            value=image.height * 0.3}
            
        :number{
            visible=false,
            id="fixed_row_amount",
            decimals=integer
        }   
            
        :separator{
            text="Shift amount"
        }

        :radio{
            id="shift_range",
            selected=true,
            label="Type",
            text="Range",
            onclick=function()
                util.toggle_ui_elements(dialog.data.shift_fixed, { "fixed_shift_amount" }, dialog)
                util.toggle_ui_elements(dialog.data.shift_range, { "upper_shift_amount", "lower_shift_amount" }, dialog)
            end
        }

        :radio{
            id="shift_fixed",
            text="Fixed",
            onclick=function()
                util.toggle_ui_elements(dialog.data.shift_fixed, { "fixed_shift_amount" }, dialog)
                util.toggle_ui_elements(dialog.data.shift_range, { "upper_shift_amount", "lower_shift_amount" }, dialog)
            end
        }
            
        :slider{
            id="upper_shift_amount",
            label="Max",
            min=-image.width,
            max=image.width,
            value=5}

        :slider{
            id="lower_shift_amount",
            label="Min",
            min=-image.width,
            max=image.width,
            value=-5}
            
        :number{ -- feat: indicate that this can also be negative
            visible=false,
            id="fixed_shift_amount",
            decimals=integer
        }

        :button{
            id="preview",
            text="Preview",
            onclick=function()
                local min_rows, max_rows
                local min_shift, max_shift
                
                if dialog.data.row_range then
                    min_rows = dialog.data.lower_row_amount
                    max_rows = dialog.data.upper_row_amount
                else
                    min_rows = dialog.data.fixed_row_amount
                    max_rows = dialog.data.fixed_row_amount
                end

                if dialog.data.shift_range then
                    min_shift = dialog.data.lower_shift_amount                    
                    max_shift = dialog.data.upper_shift_amount                    
                else                             
                    min_shift = dialog.data.fixed_shift_amount
                    max_shift = dialog.data.fixed_shift_amount
                end
                
                shifter.shift_rows(min_rows, max_rows, min_shift, max_shift)
            end}
            
        :newrow()
            
        :button{
            id="reset",
            text="Reset",
            onclick=function()
                app.activeCel.image = backup_img
                app.refresh()
            end}

        :button{
            id="apply",
            text="Apply",
            onclick=function()
                backup_img = app.activeCel.image:clone()
            end}

        :show{
            wait=false,
            bounds=Rectangle(x,y,width,height); 
        }
    
    return dialog
end

return shifter