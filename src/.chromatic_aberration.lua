chroma = {}

chroma.aberration = function () 
    
    img = app.activeCel.image:clone()

    for it in img:pixels() do
        local red = 0--app.pixelColor.rgbaR(it())
        local green = 0--app.pixelColor.rgbaG(it())
        local blue =  app.pixelColor.rgbaB(it())
        local alpha = app.pixelColor.rgbaA(it())
        img:drawPixel(it.x,it.y, app.pixelColor.rgba(red, green, blue, alpha))
    end

    app.activeCel.image = img
    app:refresh()
    
    -- todo: this is done by making the layers additive
    
end

return chroma