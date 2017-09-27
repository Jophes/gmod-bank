AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

print("pd_bank/init.lua")

local cooldownTimer = 300
local robTimer = 260
local noOfCopsRequired = 0
local copJobs = {"Police Constable","Soldier","MI5","Chief Superintendent","Armed Response Unit"}

function ENT:Initialize()
	self:SetModel( "models/props/cs_assault/MoneyPallet.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	phys:Wake()
	phys:SetMass( 200 )
	
	timer.Create("bank_vault_money_timer_"..self:GetCreationID(),(160*0.2),0,function() self:MoneyTick() end)
	
	self:SetCashStored(75000)
	self:UpdateIncomes()
	
	self:SetRobState(ROBSTATE_ROBBABLE)
	self:SetRobTimer(0)
	
	hook.Add("PlayerSpawn", "pd_bank_"..self:GetCreationID(), function (ply) MsgN( ply:Nick() .. " has spawned!" );self:UpdateIncomes() end)
	hook.Add("OnPlayerChangedTeam", "pd_bank_"..self:GetCreationID(), function () self:UpdateIncomes() end)
end

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
    local ent = ents.Create( "pd_bank" )
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
    ent:Spawn()
    ent:Activate()
    return ent
end

function IsAdmin(ply)
	local UG =  {"superadmin","admin"}
	for k,v in pairs(UG) do
		if ply:IsUserGroup(v) then
			return true
		end
	end
	return false
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

local cornerMult = 1.3
function ENT:Think()
	local locCorner = Vector(self:OBBMaxs().x*cornerMult,self:OBBMaxs().y*cornerMult,self:OBBMaxs().z*cornerMult)
	local positiveCorner = self:LocalToWorld(locCorner)
	local negativeCorner = self:LocalToWorld(Vector(locCorner.x*-1,locCorner.y*-1,0))
	local entsAroundBank = ents.FindInBox(negativeCorner,positiveCorner)
	for k,v in pairs(entsAroundBank) do
		if v:GetClass() == "money_box" or v:GetClass() == "money_briefcase" or v:GetClass() == "money_notes" then
			self:SetCashStored(self:GetCashStored()+v:GetMoneyStored())
			v:Remove()
		end
	end
end

util.AddNetworkString("SendPlayerNotifMessage")

function ENT:AcceptInput( Name, Activator, Caller )
	if Name == "Use" and Caller:IsPlayer() then
		if self:GetRobState() == ROBSTATE_ROBBABLE then
			if Caller:getJobTable().category == "Criminals" then
				local noOfCopsOnline = 0
				for k,v in pairs(player:GetAll()) do
					for j,i in pairs(copJobs) do
						if v:getJobTable().name == i then
							noOfCopsOnline = noOfCopsOnline + 1
							break
						end
					end
				end
				if noOfCopsOnline >= noOfCopsRequired then
					net.Start("SendPlayerNotifMessage")
						net.WriteTable({Caller:getJobTable().color,Caller:GetName(),Colours.text," has begun robbing the bank!"})
					net.Broadcast()
					self:SetRobState(ROBSTATE_BEINGROBBED)
					self:SetRobTimer(robTimer) -- rob timer in seconds
					self.beforeRobberyCashStored = self:GetCashStored()
					self.activeRobbers = {}
					self.allRobbers = {}
					if Caller ~= nil and Caller:IsPlayer() then
						--self.robberPly:wanted(nil,"Bank Robbery",robTimer+60)
						makePlayerWanted(Caller,"Bank Robbery",robTimer+60)
					end
					-- -359.033417 1975.385498 -75.106140	
					-- -687.718750 1610.089722 -195.955460
					if game.GetMap() == "rp_downtown_v4c_v2_drp_ext" then
						local entsInBox = ents.FindInBox(Vector(-688,1610,-196),Vector(-359,1975,-75))
						for k,v in pairs(entsInBox) do
							if v:IsPlayer() and v ~= Caller and v:getJobTable().category ~= "The Government" then
								--v:wanted(nil,"Suspected Bank Robber",robTimer+60)
								makePlayerWanted(v,"Suspected Bank Robber",robTimer+60)
							end
						end 
					else
						local entsInBox = ents.FindInSphere(self:GetPos(),500) 
						for k,v in pairs(entsInBox) do
							if v:IsPlayer() and v ~= Caller and v:getJobTable().category ~= "The Government" then
								--v:wanted(nil,"Suspected Bank Robber",robTimer+60)
								makePlayerWanted(v,"Suspected Bank Robber",robTimer+60)
							end
						end 
					end
					--sound.Play("music/hl2_song20_submix0.mp3",self:GetPos(), 180, 100, 1)
					--sound.Play( "music/hl2_song20_submix0.mp3",self:GetPos(), 180, 100, 1 )
					timer.Create("bank_vault_rob_timer_"..self:GetCreationID(),1,0,function() self:RobTick() end)
					hook.Add("PlayerDeath","pd_bank_"..self:GetCreationID(),function(victim,inflictor,attacker) self:CancelRobber(victim,"been killed") end)
					hook.Add("PlayerDisconnected","pd_bank_"..self:GetCreationID(),function(ply) self:CancelRobber(ply,"disconnected") end)
					hook.Add("playerArrested","pd_bank_"..self:GetCreationID(), function (criminal, time, actor) self:CancelRobber(criminal,"been arrested") end)
				else
					net.Start("SendPlayerNotifMessage")
						net.WriteTable({Colours.text,"Not enough cops online to rob the bank!"})
					net.Send(Caller)
				end
			else
				net.Start("SendPlayerNotifMessage")
					net.WriteTable({Colours.text,"You must be a Criminal job to rob the bank!"})
				net.Send(Caller)
			end
		elseif self:GetRobState() == ROBSTATE_BEINGROBBED then
			if Caller:getJobTable().category == "Criminals" and self:GetCashStored() > 1 then
				table.insert(self.activeRobbers,Caller)
				local playerInTable = false
				for k,v in pairs(self.allRobbers) do
					if v == Caller then 
						playerInTable = true;
						break
					end
				end
				if not playerInTable then
					table.insert(self.allRobbers,Caller)
				end
				
				local amountInBank = self:GetCashStored()
				local amountToSteal = 0
				local ent
				if amountInBank > 50000 then
					amountToSteal = 50000 - math.floor(math.Rand(9999,1))
					ent = ents.Create("money_box")
				elseif amountInBank > 5000 then
					amountToSteal = 5000 - math.floor(math.Rand(999,1))
					ent = ents.Create("money_briefcase")
				elseif amountInBank > 999 then
					amountToSteal = 999 - math.floor(math.Rand(499,1))
					ent = ents.Create("money_notes")
				else
					amountToSteal = amountInBank
					ent = ents.Create("money_notes")
				end
				ent:SetPos(self:LocalToWorld(Vector(100,0,25))) 
				ent:Spawn()
				ent:Activate()
				ent:SetMoneyStored(amountToSteal)
				if Caller["amountStolenFromBank_"..self:GetCreationID()] == nil then
					Caller["amountStolenFromBank_"..self:GetCreationID()] = amountToSteal
				else
					Caller["amountStolenFromBank_"..self:GetCreationID()] = amountToSteal + Caller["amountStolenFromBank_"..self:GetCreationID()]
				end
				if Caller["totalStolenFromBank"..self:GetCreationID()] == nil then
					Caller["totalStolenFromBank"..self:GetCreationID()] = amountToSteal
				else
					Caller["totalStolenFromBank"..self:GetCreationID()] = amountToSteal + Caller["totalStolenFromBank"..self:GetCreationID()]
				end
				ent:SetPDBank(self)
				if ent:GetClass() == "money_notes" then
					ent:SetStealable(true)
				end
				self:SetCashStored(amountInBank - amountToSteal)
				
				net.Start("SendPlayerNotifMessage")
					net.WriteTable({Caller:getJobTable().color,Caller:GetName(),Colours.text," has stolen ",Colours.negative,DarkRP.formatMoney(amountToSteal),Colours.text," from the bank!"})
				net.Broadcast()
				
				if self:GetCashStored() <= 0 then
					self:CompleteRobbery("all the money has been stolen.")
				end
			else
				net.Start("SendPlayerNotifMessage")
					net.WriteTable({Colours.text,"You must be a Criminal to rob the bank!"})
				net.Send(Caller)
			end
		end
	end
end

function ENT:CompleteRobbery(message)
	self:SetRobState(ROBSTATE_COOLDOWN)
	
	net.Start("SendPlayerNotifMessage")
		net.WriteTable({Colours.text,"The robbery is over, ",message})
	net.Broadcast()
	net.Start("SendPlayerNotifMessage")
		net.WriteTable({Colours.text,"Here is a summary of what was stolen and by whom."})
	net.Broadcast()
	local totalStolen = 0
	for k,v in pairs(self.allRobbers) do
		net.Start("SendPlayerNotifMessage")
			net.WriteTable({v:getJobTable().color,v:GetName(),Colours.text," stole ",Colours.negative,DarkRP.formatMoney(v["totalStolenFromBank"..self:GetCreationID()]),Colours.text," from the bank."})
		net.Broadcast()
		totalStolen = totalStolen + v["totalStolenFromBank"..self:GetCreationID()]
		v["amountStolenFromBank_"..self:GetCreationID()] = 0
		v["totalStolenFromBank"..self:GetCreationID()] = 0
	end
	net.Start("SendPlayerNotifMessage")
		net.WriteTable({Colours.text,"In total, ",Colours.negative,DarkRP.formatMoney(totalStolen),Colours.text," was stolen from the bank."})
	net.Broadcast()
	self:SetRobTimer(cooldownTimer)
	hook.Remove("PlayerDisconnected","pd_bank_"..self:GetCreationID())
	hook.Remove("PlayerDeath","pd_bank_"..self:GetCreationID())
	hook.Remove("playerArrested","pd_bank_"..self:GetCreationID())
	timer.Remove("bank_vault_rob_timer_"..self:GetCreationID()) 
	timer.Create("bank_vault_cooldown_timer_"..self:GetCreationID(),1,0,function() self:CooldownTick() end)
end

function ENT:CancelRobber(player,message)
	for k,v in pairs(self.activeRobbers) do
		if player == v then
			net.Start("SendPlayerNotifMessage")
				net.WriteTable({v:getJobTable().color,v:GetName(),Colours.text," has ",message," while robbing the bank!"})
			net.Broadcast()
			net.Start("SendPlayerNotifMessage")
				net.WriteTable({Colours.text,"He stole ",Colours.negative,DarkRP.formatMoney(v["amountStolenFromBank_"..self:GetCreationID()]),Colours.text," from the bank!"})
			net.Broadcast()
			v["amountStolenFromBank_"..self:GetCreationID()] = 0
			table.remove(self.activeRobbers,k)
		end
	end
	if #self.activeRobbers <= 0 then
		self:CompleteRobbery("all the robbers have either been killed, left or been Arrested.")
	end
end

function ENT:RobTick()
	if self:GetRobTimer() <= 0 then
		self:CompleteRobbery("the robbers ran out of time and did not steal all the money.")
	else
		self:SetRobTimer(self:GetRobTimer() - 1)
		--print(self:GetPos():Distance(self.robberPly:GetPos()))
		--[[if game.GetMap() == "rp_downtown_v4c_v2_drp_ext" then
			local entsInBox = ents.FindInBox(Vector(-704,968,-196),Vector(-16,2029,98))
			local plyInBank = false
			for k,v in pairs(entsInBox) do
				if v:IsPlayer() and v == self.robberPly then
					plyInBank = true
					break
				end
			end 
			if plyInBank == false then
				self:CancelRobbery(self.robberPly,"run off")
			end
		else
			if self:GetPos():Distance(self.robberPly:GetPos()) > 500 then
				self:CancelRobbery(self.robberPly,"run off")
			end
		end]]
	end
end

function ENT:CooldownTick()
	if self:GetRobTimer() <= 0 then
		self:SetRobState(ROBSTATE_ROBBABLE)
		self:SetRobTimer(0)
		timer.Remove("bank_vault_cooldown_timer_"..self:GetCreationID())
	else
		self:SetRobTimer(self:GetRobTimer() - 1)
	end
end

function ENT:OnRemove()
	if self.allRobbers ~= nil then
		for k,v in pairs(self.allRobbers) do
			self.allRobbers["totalStolenFromBank_"..self:GetCreationID()] = 0
			self.allRobbers["amountStolenFromBank_"..self:GetCreationID()] = 0
		end
	end
	timer.Remove("bank_vault_money_timer_"..self:GetCreationID()) 
	timer.Remove("bank_vault_rob_timer_"..self:GetCreationID()) 
	timer.Remove("bank_vault_cooldown_timer_"..self:GetCreationID())
	hook.Remove("PlayerDisconnected","pd_bank_"..self:GetCreationID())
	hook.Remove("PlayerSpawn", "pd_bank_"..self:GetCreationID())
	hook.Remove("OnPlayerChangedTeam", "pd_bank_"..self:GetCreationID())
	hook.Remove("PlayerDeath","pd_bank_"..self:GetCreationID())
	hook.Remove("playerArrested","pd_bank_"..self:GetCreationID())
end

function ENT:MoneyTick()
	self:SetCashStored(self:GetCashStored()+self:GetTotalProfit())
	if self:GetCashStored() < 0 then self:SetCashStored(0)
	elseif self:GetCashStored() > 1000000000 then self:SetCashStored(1000000000) end
end

function ENT:UpdateIncomes()
	self:SetCityIncome(0)
	self:SetPoliceExpense(0)
	for k,v in pairs(player.GetAll()) do
		if v:getJobTable() ~= nil and v:getJobTable().category ~= nil then
			if v:getJobTable().category ~= "The Government" then -- remove admin job
				self:SetCityIncome(self:GetCityIncome()+v:getJobTable().salary)
			else
				self:SetPoliceExpense(self:GetPoliceExpense()+v:getJobTable().salary)
			end
		end
	end
	self:SetTotalProfit(self:GetCityIncome()-self:GetPoliceExpense())
end


function makePlayerWanted(wantedPlayer,reason,lengthOfTime)
    wantedPlayer:setDarkRPVar("wanted", true)
    wantedPlayer:setDarkRPVar("wantedReason", reason)
    --for _,ply in pairs(player.GetAll()) do
    --    ply:PrintMessage(HUD_PRINTCENTER, attacker:Nick().." is wanted by the police!\nReason: Attacking a "..team.GetName( victim:Team() )..".")
    --end
    timer.Create(wantedPlayer:UniqueID() .. " wantedtimer", lengthOfTime or GAMEMODE.Config.wantedtime, 1, function()
        if not IsValid(wantedPlayer) then return end
        wantedPlayer:unWanted()
    end)
	hook.Run("MakePlayerWanted",wantedPlayer,reason,lengthOfTime)
end

local function doWantedShit(victim, attacker)
    if !attacker:IsPlayer() or !victim:IsPlayer() then return end
    if victim:isCP() and not attacker:isCP() then
        makePlayerWanted(attacker, "Attacking a "..team.GetName( victim:Team() ), GAMEMODE.Config.wantedtime)
        --attacker:setDarkRPVar("wanted", true)
        --attacker:setDarkRPVar("wantedReason", "Attacking a "..team.GetName( victim:Team() ))
        --for _,ply in pairs(player.GetAll()) do
        --    ply:PrintMessage(HUD_PRINTCENTER, attacker:Nick().." is wanted by the police!\nReason: Attacking a "..team.GetName( victim:Team() )..".")
        --end
        --timer.Create(attacker:UniqueID() .. " wantedtimer", time or GAMEMODE.Config.wantedtime, 1, function()
			--if not IsValid(attacker) then return end
			--attacker:unWanted()
		--end)
    end
end
hook.Add("PlayerHurt", "wantedShitDo", doWantedShit)