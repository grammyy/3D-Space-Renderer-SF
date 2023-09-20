--@name 3d space hitboxes demo
--@author Elias
--@include lib/3D_Space_renderer.lua

if SERVER then
    
    lastSync={}
    waitList={}
    
    function queue(time,func,data)
        if !waitList[time] then
            waitList[time]={}
            local list=waitList[time]
                
            func()
                
            timer.create("waitList_"..time,time,0,function()
                if list[#waitList[time]] then
                    list[#waitList[time]]()
                    waitList[time][#waitList[time]]=nil
                else
                    timer.remove("waitList_"..time)
                    waitList[time]=nil
                end
            end)
        else
            table.insert(waitList[time],1,func)
        end
    end
    
    hook.add("think","",function()
        local sync=find.inBox(chip():getPos()+Vector(-200),chip():getPos()+Vector(200))
        
        if lastSync!=sync then
            lastSync=sync
                
            queue(1/5,function()
                net.start("cl_entities")
                net.writeTable(lastSync)
                net.send()
            end)
        end
    end)

else
    
    require("lib/3D_Space_renderer.lua")
    
    local sync={}
    
    local size=3
    local space=renderer:new(chip():getPos(),"3d",size,chip(),true) --false,chip():getAngles()
    
    space:setViewScale(6)
    
    net.receive("cl_entities",function()
        sync=net.readTable()
    end)
    
    space.renderhook=function()
        
        render.draw3DWireframeBox(chip():getPos(),space.space:getAngles(),Vector(-size*(5+(3/4)),-size*(5+(3/4)),0),Vector(size*(5+(3/4)),size*(5+(3/4)),1))
         
        for _,entity in pairs(sync) do
            try(function()
                if entity:isValid() and entity!=player() and entity:getClass()!="viewmodel" and entity:getClass()!="physgun_beam" then
                    boneCount=entity:getHitBoxCount(0)
                    
                    render.setColor(Color(timer.realtime()*40+entity:getPos()[3]*2,1,1):hsvToRGB()) 
                    render.draw3DWireframeBox(entity:getPos(),entity:getAngles(),entity:obbMins(),entity:obbMaxs())
                    
                    for i=0,boneCount do
                        min,max,_=entity:getHitBoxBounds(i,0)
                        pos,ang=entity:getBonePosition(entity:getHitBoxBone(i,0))
        
                        render.setColor(Color(timer.realtime()*40+i+pos.z*2,1,1):hsvToRGB()) 
                        render.draw3DWireframeBox(pos,ang,min,max)
                        render.draw3DBeam(pos,entity:getBonePosition(entity:getHitBoxBone(i+1,0)),0.5,0,0)
                    end
                end
            end)
        end
        
        render.popViewMatrix()

        for _,entity in pairs(sync) do
            try(function()
--[[
                for i=0,boneCount,1 do
                    local pos,_=entity:getBonePosition(entity:getHitBoxBone(i,0))
                    local bonePos = pos:toScreen()
                    local boneID=entity:getBoneName(entity:getHitBoxBone(i,0))
        
                    render.setColor(Color(pos.z+i*5,1,1):hsvToRGB()) 
                    render.drawText(bonePos.x,bonePos.y,boneID,1) ---string.len(boneID)*2
                end
]]
                local bonePos = (entity:getPos()):toScreen()
                
                render.setColor(Color(timer.realtime()*40+entity:getPos()[3]*2+127,1,1):hsvToRGB()) 
                render.drawText(bonePos.x-450,bonePos.y-40,entity:getClass(),1)
            end)
        end
    end
end