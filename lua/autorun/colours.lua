
if CLIENT then
    
    local fontSizes = {12, 14, 16, 18, 20, 24, 26, 28, 32, 38, 42, 46, 78, 86, 96, 108}
    local font = "verdana" --verdana
    local weight = 500
    local blursize = 0
    local scanlines = 0
    local antialias = true
     
    for i,v in pairs(fontSizes) do
        surface.CreateFont("Common_Font_"..v, {
            font = font,
            size = v,
            weight = weight,
            blursize = blursize,
            scanlines = scanlines,
            antialias = antialias
        })
    end
    
end

Colours = {}

Colours.filla = Color(0, 0, 0, 120)
Colours.fillb = Color(0, 0, 0, 60)
Colours.outline = Color(0, 0, 0, 230)
Colours.line = Color(150, 150, 150, 232)
Colours.text = Color(230, 230, 230, 232)

Colours.button = Color(20, 20, 20, 120)
Colours.hover = Color(40, 40, 40, 150)
Colours.click = Color(80, 80, 80, 150)

Colours.friend = Color(40, 200, 40, 232)
Colours.team = Color(255, 255, 255, 255)
    
Colours.positive = Color(20, 200, 20, 232)
Colours.neutral = Color(200, 200, 0, 232)
Colours.negative = Color(200, 20, 20, 232)

Colours.health = Color(150, 40, 40, 100)
Colours.armor = Color(40, 40, 150, 100)

