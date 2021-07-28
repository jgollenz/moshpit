local util = dofile("./.util.lua")
local hsl = dofile("./.hsl.lua")
local shifter = dofile("./.shifter.lua")
local sorter = dofile("./.pixel_sorter.lua")

local cel = app.activeCel
if not cel then
    return app.alert("There is no active image")
end

glob = {}
glob.rgba = app.pixelColor.rgba

-- starting position / dimensions
-- todo: how can this be made adaptive?
local xAnchor = 100
local yAnchor = 50
local dialog_width = 160
local dialog_height = 60

local should_apply = false
sub_dialogs = {}

local dlg = Dialog{ 
    title="Moshpit", 
    onclose=function()
        if (should_apply == false) then
            app.refresh()
        else
            should_apply = false
        end
        
        for _, sub_dialog in pairs(sub_dialogs) do
            sub_dialog:close()
        end
    end}

dlg
    :button{
        id="sort",
        text="Pixel Sort",
        onclick=function()
            if sub_dialogs.sorter_dialog == nil then
                local bounds = dlg.bounds
                sub_dialogs.sorter_dialog = sorter.show(bounds.x, bounds.y+bounds.height)
            else
                sub_dialogs.sorter_dialog:close()
            end
        end
    }

    :newrow()

-- todo: 1. not DRY 2. stays open when other dialog is opened. should prob. close
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