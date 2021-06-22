local cel = app.activeCel
if not cel then
  return app.alert("There is no active image")
end

function lightness_from_rgb(r, g, b)

    R = r / 255
    G = g / 255
    B = b / 255
    
    min = math.min(R,G,B)
    max = math.max(R,G,B)
    
    local lightness = ((min+max) / 2) * 100
    return lightness
end

function cutoff(lower, upper)
    local img = cel.image:clone()
    
    -- 1. go through all pixels
    for pixel in img:pixels() do
        local rgba = app.pixelColor.rgba
        local actualPixel = pixel()

        -- 2. get pixel lightness
        local red = app.pixelColor.rgbaR(pixel())
        local green = app.pixelColor.rgbaG(pixel())
        local blue = app.pixelColor.rgbaB(pixel())
        local lightness = lightness_from_rgb(red, green, blue)
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

function apply()

end

--[[
local dlg = Dialog("Cutoff")
dlg:slider{ id="upper", label="Upper threshhold", min=60, max=100, value=80 }
dlg:slider{ id="lower", label="lower threshhold", min=0, max=40, value=20 } 
dlg:entry{ id="user_value", label="User Value:", text="Default User" }
dlg:button{ id="apply", text="apply", onclick=apply}
dlg:show()--{ wait=false }
local data = dlg.data
if data.ok then
    cutoff(data.lower, data.upper)
else
    print("data nicht ok")
end 
]]--

local dlg = Dialog("Cufoff")
dlg:slider{ id="upper", label="Upper threshhold", min=60, max=100, value=80 }
dlg:slider{ id="lower", label="lower threshhold", min=0, max=40, value=20 } 
--dlg:entry{ id="user_value", label="User Value:", text="Default User" }
dlg:button{ id="ok", text="OK" }
dlg:button{ id="cancel", text="Cancel" }
dlg:show()
local data = dlg.data
if data.ok then
--  app.alert("The given value is '" .. data.user_value .. "'")
    cutoff(data.lower, data.upper)
else
    print("nicht ok")
end 

