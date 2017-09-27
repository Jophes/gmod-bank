include('shared.lua')
print("money_briefcase/cl_init.lua")

function ENT:drawMoneyInfo()
    surface.SetDrawColor(Colours.filla)
    surface.DrawRect(0,0,80,36)
    draw.SimpleTextOutlined( DarkRP.formatMoney((self:GetMoneyStored() or 0)), "Common_Font_32", 40, 18, Colours.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Colours.outline)
end

function ENT:Draw()
    self:DrawModel()
    cam.Start3D2D(self:LocalToWorld(Vector(-4,1.8,1)), self:LocalToWorldAngles(Angle(0,0,0)), 0.1)
        self:drawMoneyInfo()
	cam.End3D2D()
    
    cam.Start3D2D(self:LocalToWorld(Vector(4,1.8,0)), self:LocalToWorldAngles(Angle(180,0,0)), 0.1)
        self:drawMoneyInfo()
	cam.End3D2D()
    
    local partGlowCol = Colours.negative
    if self:GetStealable() ~= nil and self:GetStealable() then
        partGlowCol = Colours.positive
    end
    cam.Start3D(EyePos(), EyeAngles())
        local obbsMaxs = self:OBBMaxs() 
        render.SetMaterial(Material("particle/Particle_Glow_05"))
        for i=0,1 do
            local valx = (1 - i*2)
            for j=0,1 do
                local valy = (1 - j*2)
                for k=0,1 do
                    local valz = (1 - k*2)
                    local locCorner = Vector(obbsMaxs.x*valx,obbsMaxs.y*valy,0.5)
                    render.DrawQuadEasy(self:LocalToWorld(locCorner), EyeAngles():Forward() * -1, 6, 6, partGlowCol, 90)
                end
            end
        end
	cam.End3D()
end