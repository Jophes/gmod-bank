--ENT.Base = "base_ai"
ENT.Base = "base_gmodentity"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "Police Bank Thing"
ENT.Author = "Jophes"
ENT.Category = "Other"
ENT.Instructions = "Goverments money storage" 
ENT.Spawnable = true
ENT.AdminSpawnable = true

ROBSTATE_ROBBABLE = 0
ROBSTATE_COOLDOWN = 1
ROBSTATE_BEINGROBBED = 2

DistanceToTakeMoney = 1500

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "CityIncome")
	self:NetworkVar("Int", 1, "PoliceExpense")
	self:NetworkVar("Int", 2, "TotalProfit")
	self:NetworkVar("Int", 3, "CashStored")
	self:NetworkVar("Int", 4, "RobState")
    self:NetworkVar("Int", 5, "RobTimer")
end