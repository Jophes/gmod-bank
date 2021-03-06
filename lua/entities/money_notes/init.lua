AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

print("money_notes/init.lua")

function ENT:Initialize()
	self:SetModel( "models/props/cs_assault/money.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	phys:Wake()
	phys:SetMass( 50 )   
	
    self:SetMoneyStored(999)
    self:SetStealable(false)
end
 

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
    local ent = ents.Create( "money_notes" )
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
    ent:Spawn()
    ent:Activate()
    return ent
end

function ENT:AcceptInput( Name, Activator, Caller )
	if Name == "Use" and Caller:IsPlayer() and (self:GetStealable() or false) then
		Caller:addMoney(self:GetMoneyStored())
		net.Start("SendHintNotif")
		net.WriteString("You have stolen: "..DarkRP.formatMoney((self:GetMoneyStored() or 0)).." from the Government!")
		net.Send(Caller)
		hook.Run("pd_bank_money_collected",Caller,self:GetMoneyStored())
    	self:Remove() 
	end
end

function ENT:PhysgunPickup(ply)
	if IsAdmin(ply) then 
		return true
	else
		return false
	end
end

function ENT:CanTool(ply, trace, mode)
	if IsAdmin(ply) then 
		return true 
	else
		return false
	end
end


function ENT:Think()

end