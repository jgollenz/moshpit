local util = dofile("./.util.lua")

-- bounds
local width = 200
local height = 200

shifter = {}

-- todo: add random pixel shift

shifter["shift_row"] = function (rowNumber, shiftAmount, img)
    local image = app.activeCel.image:clone() -- todo: hand over
    row = util.get_row(rowNumber, image)

    for i, pixel in pairs(row) do
        pixel = row[i]
        image:drawPixel(i+shiftAmount, rowNumber, pixel)
    end
    app.activeCel.image = image
    app.refresh()
end

shifter["shift_rows"] = function (lowerRowAmount, upperRowAmount, lowerShiftAmount, upperShiftAmount, img)

    local image = app.activeCel.image:clone()
    local rowNumbers = math.random(lowerRowAmount, upperRowAmount)

    for i=0, rowNumbers, 1 do
        -- bug: can lead to shifting of same line multiple times
        -- fix: make this optional, because it leads to cool effects actually
        local rowNumber = math.random(0, image.height) 
        row = util.get_row(rowNumber, image)
        for i, pixel in pairs(row) do
            pixel = row[i]
            shift_amount = math.random(lowerShiftAmount, upperShiftAmount)
            image:drawPixel(i+shift_amount, rowNumber, pixel)
        end
    end
    
    app.activeCel.image = image
    app.refresh()
    
end

shifter["show"] = function(x,y)

    local backup_img = app.activeCel.image:clone()

    local dlg = Dialog{
        title="Shift Rows",
        onclose=function()
            if (should_apply == false) then
                app.activeCel.image = backup_img
                app.refresh()
                app.alert("Restting image")
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
            text="Range"
        }
        
        :radio{
            id="rowFixed",
            text="Fixed"
        }
            
        :slider{
            id="upperRowAmount",
            label="Max",
            min=0,
            max=app.activeCel.image.height,
            value=70}
           

        :slider{
            id="lowerRowAmount",
            label="Min",
            min=0,
            max=app.activeCel.image.height,
            value=30}
           
            
        :separator{
            text="Shift amount"
        }

        :radio{
            id="shiftRange",
            selected=true,
            label="Type",
            text="Range"
        }

        :radio{
            id="shiftFixed",
            text="Fixed"
        }
            
        -- bug: this does not work as expected, because the image of the cell may be smaller than the canvas 
        :slider{
            id="upperShiftAmount",
            label="Max",
            min=-app.activeCel.image.width,
            max=app.activeCel.image.width,
            value=5}

        :slider{
            id="lowerShiftAmount",
            label="Min",
            min=-app.activeCel.image.width,
            max=app.activeCel.image.width,
            value=-5}
            
        :number{
            id="shift_amount",
            decimals=integer
        }

        :button{
            id="preview",
            label="Preview",
            onclick=function()
                -- todo: reset before previewing
                if dlg.data.rowRange then
                    shifter.shift_rows(dlg.data.lowerRowAmount, dlg.data.upperRowAmount, dlg.data.lowerShiftAmount, dlg.data.upperShiftAmount)
                else
                    shifter.shift_row(5,5)
                end
            end}

        :show{
            wait=false,
            bounds=Rectangle(x,y,width,height); 
        }
end

return shifter