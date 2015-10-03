if GetObjectName(GetMyHero()) ~= "Veigar" then return end

require("Inspired")
require("IOW")
require("Collision")

local Config = Menu("Veigar", "Veigar")
Config:SubMenu("c", "Combo")
Config.c:Boolean("Q", "Use Q", true)
Config.c:Boolean("W", "Use W", true)
Config.c:Boolean("AW", "Auto W on immobile", true)
Config.c:Boolean("E", "Use E", true)
Config.c:Boolean("R", "Use R", true)

Config:SubMenu("f", "Farm")
Config.f:Boolean("AQ", "Auto Q farm", true)

--Config:SubMenu("m", "Misc")
--Config.m.Boolean("D","Enable Drawings",true)


local myHero=GetMyHero()

OnLoop(function (myHero)
	if not IsDead(myHero) then
		AutoW()
		Combo()
		FarmQ()
		drawDmg()
	end
end)


function Combo()
	local unit=GetCurrentTarget()
	if IOW:Mode() == "Combo" then
		if Config.c.Q:Value() and CanUseSpell(myHero,_Q) == READY and GoS:ValidTarget(unit, GetCastRange(myHero,_Q)) then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),1200,GetCastRange(myHero,_Q),550,80,true,false)
			if QPred.HitChance == 1 then				
				CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
			end
		end	
		
		if Config.c.W:Value() and CanUseSpell(myHero,_W) == READY and GoS:ValidTarget(unit, GetCastRange(myHero,_W)) then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),math.huge,GetCastRange(myHero,_W),550,80,false,false)
			if WPred.HitChance == 1 then				
				CastSkillShot(_W,WPred.PredPos.x,WPred.PredPos.y,WPred.PredPos.z)
			end
		end	
		
		if Config.c.E:Value() and CanUseSpell(myHero,_E) == READY and GoS:ValidTarget(unit, GetCastRange(myHero,_E)) then
			local EPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),math.huge,GetCastRange(myHero,_E),550,80,false,false)
			if EPred.HitChance == 1 then				
				CastSkillShot(_E,EPred.PredPos.x,EPred.PredPos.y,EPred.PredPos.z)
			end
		end
		
		if Config.c.R:Value() and CanUseSpell(myHero,_R) == READY and GoS:ValidTarget(unit, GetCastRange(myHero,_R)) then
			local RPercent=GetCurrentHP(unit)/GoS:CalcDamage(myHero, unit, 0, (125*GetCastLevel(myHero,_R)+GetBonusAP(myHero)+125+GetBonusAP(unit)*0.8))
			if RPercent<1 and RPercent>0.2 then 
				CastTargetSpell(unit,_R)
			end
		end	
	end
end

function AutoW()
	local unit=GetCurrentTarget()
	if Config.c.AW:Value() and GoS:ValidTarget(unit,GetCastRange(myHero,_W)) and GotBuff(unit, "veigareventhorizonstun") > 0 and (GotBuff(unit, "snare") > 0 or GotBuff(unit, "taunt") > 0 or GotBuff(unit, "suppression") > 0 or GotBuff(unit, "stun")) then
	local WPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),math.huge,GetCastRange(myHero,_W),550,80,false,false)
		if WPred.HitChance == 1 then
			CastSkillShot(_W,WPred.PredPos.x,WPred.PredPos.y,WPred.PredPos.z)
		end
	end
end

function castE()
end

function drawDmg()
	if CanUseSpell(myHero,_R)==READY then
		local unit=GetCurrentTarget()
		local RDmg=GoS:CalcDamage(myHero, unit, 0, (125*GetCastLevel(myHero,_R) + 125 + (GetBonusAP(myHero) + 0.8*(GetBonusAP(unit)))))
		DrawDmgOverHpBar(unit,GetCurrentHP(unit),0,RDmg,0xffffffff)
	end
end

function FarmQ()
	if Config.f.AQ:Value() and CanUseSpell(myHero,_Q)==READY and IOW:Mode() ~= "Combo" then
		for i,creep in pairs(GoS:GetAllMinions(MINION_ENEMY)) do
			if GoS:ValidTarget(creep,GetCastRange(myHero,_Q)) and GetCurrentHP(creep)<GoS:CalcDamage(myHero, creep, 0, (45*GetCastLevel(myHero,_Q)+30+GetBonusAP(myHero)*0.6)) then
				CreepOrigin=GetOrigin(creep)
				DrawCircle(CreepOrigin.x,CreepOrigin.y,CreepOrigin.z,75,0,3,0xffffffff) 
				QCol=Collision(GetCastRange(myHero,_Q),1200,925,70)
				local state,Objects=QCol:__GetMinionCollision(myHero,creep,ENEMY)
				local hitcount=0
				
				for i,unit in ipairs(Objects) do 
					hitcount=hitcount+1
				end
							
				if hitcount<=1 then
				CastSkillShot(_Q,CreepOrigin.x,CreepOrigin.y,CreepOrigin.z)
				end
			end
		end
	end
end

print("Veigar injected")