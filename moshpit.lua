local util = dofile("./.util.lua")
local hsl = dofile("./.hsl.lua")
local shifter = dofile("./.shifter.lua")

local cel = app.activeCel
if not cel then
    return app.alert("There is no active image")
end

-- starting position / dimensions
local xAnchor = 100
local yAnchor = 50
local dialog_width = 160
local dialog_height = 80

local should_apply = false
sub_dialogs = {}

--local threshholdPreview = Sprite(app.activeSprite)

local dlg = Dialog{ 
    title="Moshpit", 
    onclose=function()
        if (should_apply == false) then
            --cel.image = backupImg
            app.refresh()
            --app.alert("Resetting image")
        else
            should_apply = false
        end
        
        for _, sub_dialog in pairs(sub_dialogs) do
            sub_dialog:close()
        end
    end}

dlg
    
--[[    :check{
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

    :entry{
        id="test",
        label="test",
        visible=false
    }]]

    :button{ 
        id="sort", 
        text="Pixel Sort", 
        onclick=function()
            if sub_dialogs.sorter_dialog == nil then
                local bounds = dlg.bounds
                sub_dialogs.sorter_dialog = sorter.show(bounds.x, bounds.y+bounds.height)
            else
                sub_dialogs.sorter_dialog:close()
                --sub_dialogs.sorter_dialog = nil
            end
        end}
        
--[[    :button{
        id="apply",
        text="Apply",
        onclick=function()
            should_apply = true
            dlg:close()
        end}]]
     
    :newrow()
    
    -- todo: 1. not dry 2. stays open when other dialog is opened. should prob. close
    :button{
        id="shift",
        text="Pixel Shift",
        onclick=function()
            if sub_dialogs.shifter_dialog == nil then
                local bounds = dlg.bounds
                sub_dialogs.shifter_dialog = shifter.show(bounds.x, bounds.y+bounds.height)
            else
                sub_dialogs.shifter_dialog:close()                
            end
        end
}

    :show {
        wait=false,
        bounds=Rectangle(xAnchor,yAnchor, dialog_width, dialog_height); 
    }   

--cutoff(dlg.data.lower, dlg.data.upper)
