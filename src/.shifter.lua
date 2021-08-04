local dialog = -1

-- bounds
local width = 120
local height = 200

shifter = {}

-- todo: add random pixel shift
shifter.shift_rows = function (lower_row_amount, upper_row_amount, lower_shift_amount, upper_shift_amount)
    
    local shifted_image = app.activeCel.image:clone()
    local row_amount = math.random(lower_row_amount, upper_row_amount)
    
    rows_to_shift = {}

    -- get rows that will be shifted
    for i=1, row_amount, 1 do
        repeat
            next_row = math.random(0, shifted_image.height - 1)
        until util.contains(rows_to_shift, next_row) == false
        
        table.insert (rows_to_shift, nextRow)        
    end

    local row_number = -1
    for i=1, row_amount, 1 do
        -- fix: make this optional, because it leads to cool effects actually
        row_number = rows_to_shift[i]
        row = util.get_row(row_number, shifted_image)
        shift_amount = math.random(lower_shift_amount, upper_shift_amount)
        
        for x, pixel in pairs(row) do
            pixel = row[x]
           --shift_amount = math.random(lowerShiftAmount, upperShiftAmount) -- this is the culprit, it should not be a different amount for each pixel but for each row
            shifted_image:drawPixel((x - 1) + shift_amount, row_number, pixel)
        end
    end
    
    app.activeCel.image = shifted_image
    app.refresh()
end

shifter.show = function(x,y)

    local image = app.activeCel.image
    local backup_img = image:clone()
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
            
        -- bug: this does not work as expected, because the image of the cell may be smaller than the canvas 
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
            
        :number{ -- todo: indicate that this can also be negative
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