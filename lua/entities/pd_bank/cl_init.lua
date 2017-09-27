include('shared.lua')
print("pd_bank/cl_init.lua")

    
function ENT:drawBankInfo()
	surface.SetDrawColor(Colours.filla)
	surface.DrawRect(32, 0, 508, 164)
	draw.SimpleTextOutlined( "Government", "Common_Font_86", 286, 0, Colours.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Colours.outline)
	draw.SimpleTextOutlined( "Bank Vault", "Common_Font_86", 286, 68, Colours.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Colours.outline)
	
	surface.SetDrawColor(Colours.filla)
	surface.DrawRect(32, 180, 508, 135)
	
	draw.SimpleTextOutlined( "City Income:", "Common_Font_38", 64, 180, Colours.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Colours.outline)
	draw.SimpleTextOutlined( "+"..DarkRP.formatMoney(self:GetCityIncome() or 0), "Common_Font_38", 508, 180, Colours.positive, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, Colours.outline)
	
	draw.SimpleTextOutlined( "Police Expense:", "Common_Font_38", 64, 225, Colours.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Colours.outline)
	draw.SimpleTextOutlined( "-"..DarkRP.formatMoney(self:GetPoliceExpense() or 0), "Common_Font_38", 508, 225, Colours.negative, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, Colours.outline)
	
	draw.SimpleTextOutlined( "Total Profit:", "Common_Font_38", 64, 270, Colours.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Colours.outline)
	local totalProfit = (self:GetTotalProfit() or 0)
	local cashCol = Colours.positive
	local modifierStr = "+"
	if totalProfit == 0 then
		cashCol = Colours.neutral
		modifierStr = ""
	elseif totalProfit < 0 then
		cashCol = Colours.negative
		totalProfit = -totalProfit
		modifierStr = "-"
	end
	draw.SimpleTextOutlined( modifierStr..DarkRP.formatMoney(totalProfit), "Common_Font_38", 508, 270, cashCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, Colours.outline)
	
	surface.SetDrawColor(Colours.filla)
	surface.DrawRect(32, 331, 508, 45)
	
	draw.SimpleTextOutlined( "Cash Stored:", "Common_Font_38", 64, 331, Colours.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Colours.outline)
	draw.SimpleTextOutlined( DarkRP.formatMoney(self:GetCashStored() or 0), "Common_Font_38", 508, 331, Colours.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, Colours.outline)
	
	surface.SetDrawColor(Colours.filla)
	surface.DrawRect(32, 392, 508, 120)
	
	local robStatus = self:GetRobState()
	if robStatus == ROBSTATE_ROBBABLE then
		draw.SimpleTextOutlined( "The Bank can be robbed!", "Common_Font_46", 286, 425, Colours.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Colours.outline)
	elseif robStatus == ROBSTATE_COOLDOWN then
		draw.SimpleTextOutlined( "Bank can be robbed in:", "Common_Font_46", 286, 400, Colours.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Colours.outline)
	elseif robStatus == ROBSTATE_BEINGROBBED then
		draw.SimpleTextOutlined( "The Bank is being robbed!", "Common_Font_46", 286, 400, Colours.negative, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Colours.outline)
	end
	
	if robStatus == ROBSTATE_COOLDOWN or robStatus == ROBSTATE_BEINGROBBED then
		local minutes = ""..math.floor(self:GetRobTimer()/60)
		if #minutes == 1 then minutes = "0"..minutes end
		local seconds = ""..math.floor(self:GetRobTimer()%60)
		if #seconds == 1 then seconds = "0"..seconds end
		local tmpCol = Colours.text
		if robStatus == ROBSTATE_BEINGROBBED then tmpCol = Colours.negative end
		draw.SimpleTextOutlined( minutes..":"..seconds, "Common_Font_46", 286, 450, tmpCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Colours.outline)
	end
end
	
function ENT:Draw()
	self:DrawModel()
	-- width,height = 572,572   half:286 
	cam.Start3D2D(self:LocalToWorld(Vector(31.5,-29.6,61.5)), self:LocalToWorldAngles(Angle(0,90,90)), 0.1)
		self:drawBankInfo()
	cam.End3D2D()
	--[[
	local cornerMult = 1.2
	local locCorner = Vector(self:OBBMaxs().x*cornerMult,self:OBBMaxs().y*cornerMult,self:OBBMaxs().z*cornerMult)
	local positiveCorner = self:LocalToWorld(locCorner)
	local negativeCorner = self:LocalToWorld(Vector(locCorner.x*-1,locCorner.y*-1,0))
	
	cam.Start3D(EyePos(), EyeAngles())
		render.SetMaterial(Material("particle/Particle_Glow_05"))
    	render.DrawQuadEasy(positiveCorner, EyeAngles():Forward() * -1, 64, 64, Colours.positive, 90)
		render.DrawQuadEasy(negativeCorner, EyeAngles():Forward() * -1, 64, 64, Colours.positive, 90)
	cam.End3D()]]
end

net.Receive("SendPlayerNotifMessage",function(len)
	chat.AddText(unpack(net.ReadTable()))
end)