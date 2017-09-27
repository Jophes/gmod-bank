ENT.Base = "base_gmodentity"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "Money Briefcase"
ENT.Author = "Jophes"
ENT.Category = "Other"
ENT.Instructions = "Money Briefcase" 
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "MoneyStored")
	self:NetworkVar("Bool", 0, "Stealable")
	self:NetworkVar("Entity",0, "PDBank")
end 