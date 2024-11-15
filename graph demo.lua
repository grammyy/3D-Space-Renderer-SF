--@name 3D Graph demo
--@author Elias
--@include libs/3D_Space_renderer.lua
--@client

require("libs/3D_Space_renderer.lua")

local space=render.createRenderer:new({
    type="3d",
    size=2,
    scale=6,
    pos=chip():getPos(),
},chip())
local data={}
local thread=nil

hook.add("think","",function()
    data={}
    
    for i=1, 250 do 
        data[#data+1]=Vector(5*math.sin(i-timer.realtime()),5*math.cos(i-timer.realtime()),((6/250)*i)-3)
    end
end)

hook.add("renderoffscreen","",function()
    if !thread then
        thread=coroutine.create(function()
            space:draw(function()
                render.clear(Color(0,0,0,0))
                
                for _,vec in pairs(data) do
                    render.setColor(Color(timer.realtime()*50+(vec[3]*20),1,1):hsvToRGB())
                    render.draw3DBox(localToWorld(vec,Angle(),chip():getPos(),chip():getAngles()),Angle(),Vector(-0.1),Vector(0.1))
                end
            
                render.setColor(Color(210,210,210))
                render.draw3DWireframeBox(chip():getPos(),chip():getAngles(),Vector(-5),Vector(5), false)
                
                coroutine.yield()
            end)
        end)
    end

    if coroutine.status(thread)=="suspended" and quotaAverage()<0.006*0.5 then
        coroutine.resume(thread)
    end
    
    if coroutine.status(thread)=="dead" then
        thread=nil
    end
end)