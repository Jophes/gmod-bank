AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

print("money_briefcase/init.lua")

function ENT:Initialize()
	self:SetModel( "models/props_c17/SuitCase_Passenger_Physics.mdl" )--models/props/cs_assault/money.mdl
	self:PhysicsInit(SOLID_VPHYSICS) 
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	phys:Wake()
	phys:SetMass( 50 )
    
    self:SetMoneyStored(5000)
    self:SetStealable(false)
end
 

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
    local ent = ents.Create( "money_briefcase" )
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
	if self:GetPDBank() ~= nil and IsValid(self:GetPDBank()) then
		local distToBank = self:GetPDBank():GetPos():Distance(self:GetPos())
		if distToBank < DistanceToTakeMoney then
			self:SetStealable(false)
		elseif distToBank > DistanceToTakeMoney then
			self:SetStealable(true)
		end
	end
end