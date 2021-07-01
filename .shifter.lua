local util = dofile("./.util.lua")

-- bounds
local width = 120
local height = 200

shifter = {}

-- todo: add random pixel shift
shifter.shift_row = function (rowNumber, shiftAmount, img)
    local image = app.activeCel.image:clone() -- todo: hand over
    row = util.get_row(rowNumber, image)

    for i, pixel in pairs(row) do
        pixel = row[i]
        image:drawPixel(i+shiftAmount, rowNumber, pixel)
    end
    app.activeCel.image = image
    app.refresh()
end

shifter.shift_rows = function (lowerRowAmount, upperRowAmount, lowerShiftAmount, upperShiftAmount, img)

    local shiftedImage = app.activeCel.image:clone()
    local rowAmount = math.random(lowerRowAmount, upperRowAmount)
    
    rowsToShift = {}

    for i=1, rowAmount, 1 do

        repeat
            nextRow = math.random(0, shiftedImage.height-1)
            
        until util.contains(rowsToShift, nextRow) == false
        
        table.insert (rowsToShift, nextRow)        
    end

    local rowNumber = -1
    for i=1, rowAmount, 1 do
        -- fix: make this optional, because it leads to cool effects actually
        
        rowNumber = rowsToShift[i]
        
        row = util.get_row(rowNumber, shiftedImage)
        shift_amount = math.random(lowerShiftAmount, upperShiftAmount)
        for j, pixel in pairs(row) do
            pixel = row[j]
           --shift_amount = math.random(lowerShiftAmount, upperShiftAmount) -- this is the culprit, it should not be a different amount for each pixel but for each row
            shiftedImage:drawPixel((j-1)+shift_amount, rowNumber, pixel)
        end
    end
    
    app.activeCel.image = shiftedImage
    app.refresh()
    
end

shifter.show = function(x,y)

    local image = app.activeCel.image
    local backup_img = image:clone()
    

    local dlg = Dialog{
        title="Shift Rows",
        onclose=function()
            if (should_apply == false) then
                -- reset
                app.activeCel.image = backup_img
                app.refresh()
                --app.alert("Restting image")
            else
                should_apply = false
            end
        end
    }

    dlg
        :separator{
        text="Row amount"}

        :radio{
            id="rowRange",
            selected=true,
            label="Type",
            text="Range",
            onclick=function()
                util.toggle_UI_Elements(dlg.data.rowFixed, { "rowAmount" }, dlg)
                util.toggle_UI_Elements(dlg.data.rowRange, { "upperRowAmount", "lowerRowAmount" }, dlg)
            end
        }
        
        :radio{
            id="rowFixed",
            text="Fixed",
            onclick=function()
                util.toggle_UI_Elements(dlg.data.rowFixed, { "rowAmount" }, dlg)
                util.toggle_UI_Elements(dlg.data.rowRange, { "upperRowAmount", "lowerRowAmount" }, dlg)
            end
        }
            
        :slider{
            id="upperRowAmount",
            label="Max",
            min=0,
            max=image.height,
            value=image.height * 0.7}
           
        :slider{
            id="lowerRowAmount",
            label="Min",
            min=0,
            max=image.height,
            value=image.height * 0.3}
            
        :number{
            visible=false,
            id="rowAmount",
            decimals=integer
        }   
            
        :separator{
            text="Shift amount"
        }

        :radio{
            id="shiftRange",
            selected=true,
            label="Type",
            text="Range",
            onclick=function()
                util.toggle_UI_Elements(dlg.data.shiftFixed, { "shiftAmount" }, dlg)
                util.toggle_UI_Elements(dlg.data.shiftRange, { "upperShiftAmount", "lowerShiftAmount" }, dlg)
            end
        }

        :radio{
            id="shiftFixed",
            text="Fixed",
            onclick=function()
                util.toggle_UI_Elements(dlg.data.shiftFixed, { "shiftAmount" }, dlg)
                util.toggle_UI_Elements(dlg.data.shiftRange, { "upperShiftAmount", "lowerShiftAmount" }, dlg)
            end
        }
            
        -- bug: this does not work as expected, because the image of the cell may be smaller than the canvas 
        :slider{
            id="upperShiftAmount",
            label="Max",
            min=-image.width,
            max=image.width,
            value=image.width * 0.2}

        :slider{
            id="lowerShiftAmount",
            label="Min",
            min=-image.width,
            max=image.width,
            value=image.width * -0.2}
            
        :number{ -- todo: indicate that this can also be negative
            visible=false,
            id="shiftAmount",
            decimals=integer
        }

        :button{
            id="preview",
            text="Preview",
            onclick=function()
                -- todo: reset before previewing
                if dlg.data.rowRange then
                    shifter.shift_rows(dlg.data.lowerRowAmount, dlg.data.upperRowAmount, 
                            dlg.data.lowerShiftAmount, dlg.data.upperShiftAmount)
                else
                    -- todo: use user value
                    shifter.shift_row(5,5)
                end
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
    
    return dlg
end

return shifter