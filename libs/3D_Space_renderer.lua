--@name 3D space renderer
--@author Elias & Bullet Paincakes
--@client

render.createRenderer=class("renderer")

function render.createRenderer:initialize(data,parent)
    self.data=data
    
    if !self.data.size then
        throw("Size must be defined in the first Argument of \"render.createRender()\".")
    end
    
    render.createRenderTarget(table.address(self))
    
    self.mat=material.create("UnlitGeneric")
    self.mat:setTextureRenderTarget("$basetexture",table.address(self))
    self.mat:setInt("$flags",256)
    
    self.renderer = holograms.create(self.data.pos or (self.parent:getPos() or Vector()),Angle(),"models/holograms/plane.mdl",Vector(self.data.size))
    self.renderer:setMaterial("!"..self.mat:getName())
    self.renderer:setFilterMin(1)
    self.renderer:setFilterMag(1)

    if parent then
        self.renderer:setParent(parent)
    end
    
    hook.add("think",table.address(self),function()
        self.renderer:setAngles((math.lerpVector(0.2,render.getOrigin(),render.getOrigin()+(player():getVelocity()/100))-self.renderer:getPos()):getAngle()+Angle(90,0,0))
    end)
    
    return self
end

function render.createRenderer:draw(func)
    render.selectRenderTarget(table.address(self))
    
    render.pushViewMatrix({
        type   = "3D",
        origin = render.getOrigin(),
        angles = (self.renderer:getPos()-math.lerpVector(0.2,render.getOrigin(),render.getOrigin()+(player():getVelocity()/100))):getAngle(),
        fov    = 180-((2*(math.deg(math.atan((render.getOrigin():getDistance(self.renderer:getPos()))/(self.data.size*(self.data.scale or 6))))))),
        aspect = 1,
        x = 0,
        y = 0,
        w = 1024,
        h = 1024,
    })
    
    render.enableDepth(true)
    render.clearDepth()
        
    func()
end

function render.createRenderer:toScreen(vector)
    local vec=self.renderer:worldToLocal(trace.intersectRayWithPlane(render.getOrigin(),(vector-render.getOrigin()):getNormalized(),self.renderer:getPos(),self.renderer:getUp())or Vector())*((5/self.data.size)*30/1.8)+Vector(512)
    
    return {
        x=vec[2],
        y=vec[1]
    }
end