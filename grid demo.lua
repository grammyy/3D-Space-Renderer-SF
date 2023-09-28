--@name 3d grid demo
--@author Elias
--@include libs/3D_Space_renderer.lua
--@client

require("libs/3D_Space_renderer.lua")

local space=renderer:new(chip():getPos(),"3d",15,chip(),true)

space.renderhook=function()
    render.setColor(Color(210,210,210))
    render.draw3DWireframeBox(chip():getPos(),chip():getAngles(),Vector(-3,-3,0),Vector(3,3,0.1))
    
    render.setColor(Color(timer.realtime()*30,1,1):hsvToRGB())

    for i=1, 4 do
        render.setColor(Color(timer.realtime()*30,1,1):hsvToRGB())
        render.draw3DWireframeBox(chip():getPos(),chip():getAngles(),Vector(-3+i,-3,0),Vector(3-i,3,0.1))
        render.draw3DWireframeBox(chip():getPos(),chip():getAngles(),Vector(-3,-3+i,0),Vector(3,3-i,0.1))
    end
end
