--@name 3D Space renderer
--@author Elias & Bullet Paincakes
--@client

local FPS = 60

local next_frame = 0 
local fps_delta = 1/FPS

renderer=class("renderer")

--[[
function await(name,var,func)
    hook.add("think",name,function()
        if function() return var() end then
            func()
                    
            hook.remove("think",name)
        end 
    end)
end
]]
local function lockView(space)
    hook.add("think","space_"..table.address(space),function()
        space.space:setAngles((player():getEyePos()-space.space:getPos()):getAngle()+Angle(90,0,0))
    end)
end

function renderer:initialize(pos,name,size,parent,lock,angles)
    self.pos=pos
    self.size=size
    self.viewScale=3
    self.name=name
    self.lock=lock
    
    render.createRenderTarget(self.name)

    self.mat = material.create("UnlitGeneric") 
    self.mat:setTextureRenderTarget("$basetexture",name)
    self.mat:setInt("$flags", 0)   
    self.mat:setInt("$flags",256) 
    
    hook.add("renderoffscreen","space_"..table.address(self),function()
        
        local now = timer.systime()
        
        if next_frame > now then 
            return 
        end
        
        next_frame = now + fps_delta
    
        render.selectRenderTarget(name)
        
        render.clear(Color(0,0,0,0))
        
        render.pushViewMatrix({
            type   = "3D",
            origin = self.lock and render.getOrigin() or self.space:getPos()+self.space:getUp()*(player():getEyePos():getDistance(self.space:getPos())), --screenEnt:localToWorld(screenEnt:worldToLocal(render.getOrigin()) * Vector(1, 1, -1))
            angles = self.lock and (self.space:getPos()-math.lerpVector(0.2,player():getEyePos(),player():getEyePos()+(player():getVelocity()/100))):getAngle() or self.space:getAngles()+Angle(90,0,0),
            fov    = 180-((self.lock and 1 or -1)*(2*(math.deg(math.atan((player():getEyePos():getDistance(self.space:getPos()))/(self.size*self.viewScale)))))), --(pla0yer():getPos():getDistance(space:getPos()))
            aspect = 1,
        })   
        

--[[
        render.pushViewMatrix({
            type   = "3D",
            origin = self.space:getPos()+self.space:getUp()*(player():getEyePos():getDistance(self.space:getPos())), --screenEnt:localToWorld(screenEnt:worldToLocal(render.getOrigin()) * Vector(1, 1, -1))
            angles = self.space:getAngles()+Angle(90,0,0),
            fov    = 180+(2*(math.deg(math.atan((player():getEyePos():getDistance(self.space:getPos()))/(self.size*self.viewScale))))), --(pla0yer():getPos():getDistance(space:getPos()))
            aspect = 1,
        })   
]]

        
        if self.renderhook then
            self.renderhook()
        end
    end)
    
    self.space = holograms.create(pos, parent and parent:localToWorldAngles(Angle(90,-90,0)) or angles+Angle(90,-90,0), "models/holograms/plane.mdl",Vector(self.size))
    self.space:setMaterial("!" .. self.mat:getName())
    
    if parent then
        self.space:setParent(parent)
    end

    if self.lock then
        lockView(self)
    end
    
    return self
end

function renderer:setViewScale(viewScale)
    self.viewScale=viewScale
end

function renderer:setLock(bool)
    self.lock=bool
    
    if bool then
        self.lockView(self)
    else
        hook.remove("think","space_"..table.address(self))
    end
end