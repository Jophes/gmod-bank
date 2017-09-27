include('shared.lua')
print("money_briefcase/cl_init.lua")

function ENT:drawMoneyInfo()
    surface.SetDrawColor(Colours.filla)
    -- 384x235 -- center
    --local height = 160
    --local width = 240
    --surface.DrawRect(0,0,width,height)
    surface.DrawRect(0, 0, 240, 46)
    draw.SimpleTextOutlined( "Stolen Money", "Common_Font_38", 120, 21, Colours.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Colours.outline)
	
    surface.DrawRect(0, 46+8, 240, 106)
    draw.SimpleTextOutlined( DarkRP.formatMoney((self:GetMoneyStored() or 0)), "Common_Font_78", 120, 107-4, Colours.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Colours.outline)
     
    --surface.DrawRect(0, 0, 240, 127+46+8)
    --draw.SimpleTextOutlined( DarkRP.formatMoney((self:GetMoneyStored() or 0)), "Common_Font_108", 120, 117.5-4-23, Colours.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Colours.outline)
    
    --surface.DrawRect(0, 46+8, 384, 127+46+8)
    --draw.SimpleTextOutlined( DarkRP.formatMoney((self:GetMoneyStored() or 0)), "Common_Font_108", 120, 117.5-4+23, Colours.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Colours.outline)
     
    --surface.DrawRect(0, 235-46, 384, 46)
    --draw.SimpleTextOutlined( "Get away from the bank!", "Common_Font_32", 120, 212, Colours.negative, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Colours.outline)
	--draw.SimpleTextOutlined( "Steal the money!", "Common_Font_32", 120, 212, Colours.positive, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Colours.outline)
end

function ENT:Draw()
    self:DrawModel()
    cam.Start3D2D(self:LocalToWorld(Vector(-12,-3.6,-1.5)), self:LocalToWorldAngles(Angle(0,0,90)), 0.1)
        self:drawMoneyInfo()
	cam.End3D2D()
    
    cam.Start3D2D(self:LocalToWorld(Vector(12,3.6,-1.5)), self:LocalToWorldAngles(Angle(0,180,90)), 0.1)
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
                    local locCorner = Vector(obbsMaxs.x*valx,obbsMaxs.y*valy,obbsMaxs.z*valz*8.5-9)
                    render.DrawQuadEasy(self:LocalToWorld(locCorner), EyeAngles():Forward() * -1, 24, 24, partGlowCol, 90)
                end
            end
        end
	cam.End3D()
end