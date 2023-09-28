--@name 3D space renderer
--@author Elias & Bullet Paincakes
--@client

local FPS = 60

local next_frame = 0 
local fps_delta = 1/FPS

renderer=class("renderer")

local function lockView(space)
    hook.add("think","space"..table.address(space),function()
        space.space:setAngles((render.getOrigin()-space.space:getPos()):getAngle()+Angle(90,0,0))
    end)
end

function renderer:calcuFov()
    return 180-((self.lock and 1 or -1)*(2*(math.deg(math.atan((render.getOrigin():getDistance(self.space:getPos()))/(self.size*self.viewScale))))))
end

function renderer:pushRendererMatrix()
    render.pushViewMatrix({
        type   = "3D",
        origin = self.lock and render.getOrigin() or self.space:getPos()+self.space:getUp()*(render.getOrigin():getDistance(self.space:getPos())),
        angles = self.lock and (self.space:getPos()-math.lerpVector(0.2,render.getOrigin(),render.getOrigin()+(player():getVelocity()/100))):getAngle() or self.space:getAngles()+Angle(90,0,0),
        fov    = self:calcuFov(),
        aspect = 1,
        x = 0,
        y = 0,
        w = 1024,
        h = 1024,
    })
end

function renderer:toScreen(pos)
    local r=self.space:worldToLocal(trace.intersectRayWithPlane(render.getOrigin(),(pos-render.getOrigin()):getNormalized(), self.space:getPos(), self.space:getUp()))*28.5+Vector(512)
    
    return {
        x=r[2],
        y=r[1]
    }
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
    
    hook.add("renderoffscreen","space"..table.address(self),function()
        local now = timer.systime()
        
        if next_frame > now then 
            return 
        end
        
        next_frame = now + fps_delta
        scrW, scrH = render.getGameResolution()
    
        render.selectRenderTarget(name)
        
        render.clear(Color(0,0,0,0))
        
        self:pushRendererMatrix()   
        
        if self.renderhook then
            self.renderhook()
        end
    end)
    
    self.space = holograms.create(pos, parent and parent:localToWorldAngles(Angle(90,-90,0)) or angles+Angle(90,-90,0), "models/holograms/plane.mdl",Vector(self.size))
    self.space:setMaterial("!" .. self.mat:getName())
    self.space:setFilterMin(1)
    self.space:setFilterMag(1)
    
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
        hook.remove("think","space"..table.address(self))
    end
end