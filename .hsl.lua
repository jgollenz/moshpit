hsl = {}

hsl.hue_from_pixel = function(pixel)
    
    local color = 0

    if app.activeCel.image.colorMode == ColorMode.GRAY then
        app.alert("Hue cannot be calculated from grayscale image")
        return color
    end

    if app.activeCel.image.colorMode == ColorMode.INDEXED then
        local palette = app.activeSprite.palettes[1]        
        color = palette:getColor(pixel)
        
        return color.hue;
    end
    
    if app.activeCel.image.colorMode == ColorMode.RGB then
        color = Color(pixel)
        
        return color.hue      
    end
end

hsl.hue_from_rgb = function (r, g, b)

    min = math.min(r,g,b)
    max = math.max(r,g,b)

    -- handle the rare case that all three values are equal
    if min == max then return 0 end

    minMaxDiff = max-min

    if max == r then
        hue = (g-b) / minMaxDiff
    elseif max == g then
        hue = 2 + (b-r) / minMaxDiff
    elseif max == b then
        hue = 4 + (r-g) / minMaxDiff
    else
        print("ERROR: min/max not working in hue_from_rgb")
    end

    hue = hue * 60
    if hue < 0 then
        hue = hue + 360
    end

    return hue
end

hsl.lightness_from_rgb = function (r, g, b)

    R = r / 255
    G = g / 255
    B = b / 255

    min = math.min(R,G,B)
    max = math.max(R,G,B)

    local lightness = ((min+max) / 2) * 100
    return lightness
end

return hsl