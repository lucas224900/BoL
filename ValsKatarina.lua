local Version = "8.4.1"
local Name = 'Vals Katarina'
local Author = 'Valdorian'

local autoupdateenabled = true
local UPDATE_SCRIPT_NAME = "Vals Katarina"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/lucas224900/BoL/master/ValsKatarina.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local ServerData
if autoupdateenabled then
	GetAsyncWebResult(UPDATE_HOST, UPDATE_PATH, function(d) ServerData = d end)
	function update()
		if ServerData ~= nil then
			local ServerVersion
			local send, tmp, sstart = nil, string.find(ServerData, "local version = \"")
			if sstart then
				send, tmp = string.find(ServerData, "\"", sstart+1)
			end
			if send then
				ServerVersion = tonumber(string.sub(ServerData, sstart+1, send-1))
			end

			if ServerVersion ~= nil and tonumber(ServerVersion) ~= nil and tonumber(ServerVersion) > tonumber(version) then
				DownloadFile(UPDATE_URL.."?nocache"..myHero.charName..os.clock(), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> successfully updated. Reload (double F9) Please. ("..version.." => "..ServerVersion..")</font>") end)     
			elseif ServerVersion then
				print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> You have got the latest version: <u><b>"..ServerVersion.."</b></u></font>")
			end		
			ServerData = nil
		end
	end
	AddTickCallback(update)
end

require 'winapi'
require 'vals_lib'
require 'SKeys'
require 'runrunrun'
require 'spell_damage'
local uiconfig = require 'uiconfig'
local send = require 'SendInputScheduled'
local Q,W,E,R = 'Q','W','E','R'
local KSK = {}
local Btimer = GetClock()
local locus,Combo_,Harass_ = false,false,false
local Rtimer = GetClock()
local wUsedAt,vUsedAt,Pot_Timer,bluePill = 0,0,os.clock(),nil
local Minions = {}
local SORT_CUSTOM = function(a,b) return a.maxHealth and b.maxHealth and a.maxHealth<b.maxHealth end
local Dodgeversion = '1.15 No Dodge'
local skillshotArray = {}
local colorcyan,coloryellow,cc = 0xFF00FFFF,0xFFFFFF00,0
	
	CFG, menu = uiconfig.add_menu('Vals Katarina Config', 225)
	local submenu = menu.submenu('1. Hotkeys', 240)
	submenu.keydown('Combo', 'Combo', Keys.X)
	submenu.label('lb1_1', '- Items/Q/W/E/R -')
	submenu.keydown('Harass', 'Harass', Keys.Y)
	submenu.label('lb1_2', '- Q/W/E -')
	submenu.keydown('Farm', 'Lasthit', Keys.T)
	submenu.keydown('Espell', 'Espell', Keys.E)
	submenu.label('lb1_3', '- Jump to the spot nearest your')
	submenu.label('lb1_4', '  mouse cursor when you press the hotkey -')
	
	local submenu = menu.submenu('2. Main options', 425)
	submenu.checkbox('Killsteal', 'Killsteal', true)
	submenu.label('lb2_1', '- Auto kill enemies -')
	submenu.checkbox('Move_Mouse', 'MoveToMouse', true)
	submenu.label('lb2_2', '- Move towards your mouse cursor when you press combo/harass hotkey -')
	submenu.checkbox('Auto_Zonyas', 'Auto Zonyas', true)
	submenu.slider('healthpercent', 'Min. health% to use auto Zonyas', 0, 100, 25)
	submenu.label('lb2_3', '- Use Zonyas/Wooglets when you have low health -')
	submenu.checkbox('Auto_W', 'Auto W', true)
	submenu.label('lb2_4', '- Automatically use W when in range -')

	local submenu = menu.submenu('3. Draw options', 425)
	submenu.checkbox('Draw_Stuns', 'Draw Stuns', true)
	submenu.label('lb3_1', '- Draw a yellow sphere over their head when they can break your ult -')
	submenu.checkbox('Draw_Escapes', 'Draw Escapes', true)
	submenu.label('lb3_2', '- Draw a purple sphere over their head when they can escape -')
	submenu.checkbox('E_helper', 'Use E helper', true)
	submenu.label('lb3_3', '- Draw a yellow circle around possible jump spots -')
	submenu.checkbox('Roamhelper', 'Roamhelper', true)
	submenu.label('lb3_4', '- Roamhelper -')
	submenu.checkbox('Healthpercent', 'Draw health %', true)
	submenu.label('lb3_5', '- Draws the enemy life in percent after you would use your harass/combo -')
	submenu.checkbox('Show_ranges', 'Show your own range', true)
	submenu.checkbox('Show_target', 'Show your current target', true)
	submenu.checkbox('DrawLS', 'Draw Lasthits Notes on minions', true)
	submenu.checkbox('Show_Skillshots', 'Draw enemy skillshots', true)
	
	local submenu = menu.submenu('4. Misc options', 400)
	submenu.checkbox('BreakUltKS', 'Break ult for Killsteal', true)
	submenu.label('lb4_1', '- Stop your ult when you can kill someone in range -')
	submenu.checkbox('StopUlt', 'Stop ult when nobody is in range', false)
	submenu.checkbox('UseItemsCombo', 'Auto cast Items during combo', true)
	submenu.label('lb4_2', ' ')
	submenu.label('lb4_3', '- Move delay to humanize the script -')
	submenu.slider('Movedelay', 'Humanize Movement', 1, 500, 1)
	submenu.slider('CalcR', 'Calculated R hits', 0, 10, 5)
	submenu.label('lb4_4', '- How many ult hits should be considered for damage calculations? -')
	submenu.slider('tick', 'SetScriptTimer', 10, 100, 10)
	submenu.label('lb4_5', '- Dont change without a reason -')
	submenu.slider('Ehelper_range', 'Max. range for E-helper', 0, 2000, 800)
	
	local submenu = menu.submenu('5. Mastery options', 200)
	submenu.slider('DES', 'Double-Edged Sword', 0, 1, 1, nil)
	submenu.slider('EXE', 'Executioner', 0, 3, 3, nil)
	
	local submenu = menu.submenu('6. AutoLevel', 200)
	submenu.checkbox('AutoLevel', 'Auto level spells', false)
	submenu.slider('Spellorder', 'Spell order', 1, 2, 1, {'Q,E,W,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E','Q,E,W,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E'})
	
	local submenu = menu.submenu('7. Auto potions', 200)
	submenu.checkbutton('Health_Potion', 'Health Potions', true)
	submenu.checkbutton('Chrystalline_Flask', 'Chrystalline Flask', true)
	submenu.checkbutton('Elixir_of_Fortitude', 'Elixir of Fortitude', true)
	submenu.checkbutton('Biscuit', 'Biscuit', true)
	submenu.slider('Health_Potion_Value', 'Health Potion Value', 0, 100, 75)
	submenu.slider('Chrystalline_Flask_Value', 'Chrystalline Flask Value', 0, 100, 75)
	submenu.slider('Elixir_of_Fortitude_Value', 'Elixir of Fortitude Value', 0, 100, 30)
	submenu.slider('Biscuit_Value', 'Biscuit Value', 0, 100, 60)
	
	local submenu = menu.submenu('8. Experimental options', 200)
	submenu.slider('Harass_method', 'Harass method', 1, 2, 1, {'Simple','Advanced'})
	submenu.slider('Combo_method', 'Combo method', 1, 2, 1, {'Simple','Advanced'})
	submenu.slider('KS_method', 'Killsteal method', 1, 2, 1, {'Full Speed','Full Damage'})
	
	menu.label('lb01', ' ')
	menu.label('lb02', 'Vals Katarina Version '..tostring(Version) ..' by Valdorian')

function Main()
	SetScriptTimer(CFG['4. Misc options'].tick)
	if IsLolActive() then
		GetCD()
		Draw()
		CheckItemCD()
		SetVariables()
		if CFG['8. Experimental options'].KS_method==1 then Killsteal_Speed() else Killsteal_Damage() end
		AutoPotions()
		if not Combo_ or Harass_ and not KeyDown(88) and not KeyDown(89) then Farm() end
		if locus then DrawTextObject('locus',myHero,Color.Yellow) end
		if CFG['6. AutoLevel'].AutoLevel then AutoLevel() end
		if CFG['3. Draw options'].Draw_Stuns then StunDraw() end
		if CFG['3. Draw options'].Draw_Escapes then EscapeDraw() end
		if CFG['3. Draw options'].Show_Skillshots then ShowSkillshots() end
		E_NEAREST()
		if (CFG['1. Hotkeys'].Combo or CFG['1. Hotkeys'].Harass) and not (Combo_ or Harass_) and not locus and target==nil and CFG['2. Main options'].Move_Mouse then run_every(CFG['4. Misc options'].Movedelay/1000,Move) end
		if Combo_ then Combo(target) end
		if Harass_ then Harass(target) end
		if CFG['2. Main options'].Auto_Zonyas then AutoZonyas() end
		if CFG['2. Main options'].Auto_W then AutoW() end
		if CFG['3. Draw options'].Roamhelper then Roamhelper() end
		if locus and CountEnemyInRange(550)==0 and (QRDY==1 or WRDY==1 or ERDY==1) and CFG['4. Misc options'].StopUlt then
			MoveToXYZ(myHero.x+10,0,myHero.z)
			locus = false
		end
		if locus or target==nil or myHero.dead==1 or Buff1(target) then _Q_ = false end
		if CheckVersion==nil or CheckVersion<1 then DrawTextObject('Update vals_lib',myHero,Color.Yellow) end
	end
	send.tick()
end

function ShowSkillshots()
	if cc<151 then cc=cc+1 else cc = 151 end
	if (cc==150) then LoadTable() end
	for i=1, #skillshotArray, 1 do
		if skillshotArray[i].shot == 1 then
			local radius = skillshotArray[i].radius
			local color = skillshotArray[i].color
			if skillshotArray[i].isline == false then
				for number, point in pairs(skillshotArray[i].skillshotpoint) do
					DrawCircle(point.x, point.y, point.z, radius, color)
				end
			else
				startVector = Vector(skillshotArray[i].p1x,skillshotArray[i].p1y,skillshotArray[i].p1z)
				endVector = Vector(skillshotArray[i].p2x,skillshotArray[i].p2y,skillshotArray[i].p2z)
				directionVector = (endVector-startVector):normalized()
				local angle=0
				if (math.abs(directionVector.x)<.00001) then
					if directionVector.z > 0 then angle=90
					elseif directionVector.z < 0 then angle=270
					else angle=0
					end
				else
					local theta = math.deg(math.atan(directionVector.z / directionVector.x))
					if directionVector.x < 0 then theta = theta + 180 end
					if theta < 0 then theta = theta + 360 end
					angle=theta
				end
				angle=((90-angle)*2*math.pi)/360
				DrawLine(startVector.x, startVector.y, startVector.z, GetDistance(startVector, endVector)+170, 1,angle,radius)
			end
		end
	end
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then skillshotArray[i].shot = 0 end
	end
end

function Farm()
	 for i, minion in pairs(Minions) do
        if minion~=nil and minion.visible==1 and minion.dead==0 then
            local xQ = CalcDamRoam((getDmg('Q',minion,myHero,1)*QRDY),minion)
            local xQ2 = CalcDamRoam((getDmg('Q',minion,myHero,2)),minion)
            local xW = CalcDamRoam((getDmg('W',minion,myHero)*WRDY),minion)
            local xA = CalcDamRoam((getDmg('AD',minion,myHero)),minion)        
            
            if CFG['3. Draw options'].DrawLS then
                if IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ+xQ2 and minion.health<xW+xQ2 and minion.health<xA+xQ2 then DrawTextObject('Q/W/AA',minion,Color.Yellow)
                elseif IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ+xQ2 and minion.health>xW+xQ2 and minion.health<xA+xQ2 then DrawTextObject('Q/AA',minion,Color.Yellow)
                elseif IsBuffed(minion,'katarina_daggered',0) and minion.health>xQ+xQ2 and minion.health<xW+xQ2 and minion.health<xA+xQ2 then DrawTextObject('W/AA',minion,Color.Yellow)
                elseif IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ+xQ2 and minion.health<xW+xQ2 and minion.health>xA+xQ2 then DrawTextObject('Q/W',minion,Color.Yellow)
                elseif IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ+xQ2 and minion.health>xW+xQ2 and minion.health>xA+xQ2 then DrawTextObject('Q',minion,Color.Yellow)
                elseif IsBuffed(minion,'katarina_daggered',0) and minion.health>xQ+xQ2 and minion.health<xW+xQ2 and minion.health>xA+xQ2 then DrawTextObject('W',minion,Color.Yellow)
                elseif IsBuffed(minion,'katarina_daggered',0) and minion.health>xQ+xQ2 and minion.health>xW+xQ2 and minion.health<xA+xQ2 then DrawTextObject('AA',minion,Color.Yellow)
                elseif not IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ and minion.health<xW and minion.health<xA then DrawTextObject('Q/W/AA',minion,Color.Yellow)
                elseif not IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ and minion.health>xW and minion.health<xA then DrawTextObject('Q/AA',minion,Color.Yellow)
                elseif not IsBuffed(minion,'katarina_daggered',0) and minion.health>xQ and minion.health<xW and minion.health<xA then DrawTextObject('W/AA',minion,Color.Yellow)
                elseif not IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ and minion.health<xW and minion.health>xA then DrawTextObject('Q/W',minion,Color.Yellow)
                elseif not IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ and minion.health>xW and minion.health>xA then DrawTextObject('Q',minion,Color.Yellow)
                elseif not IsBuffed(minion,'katarina_daggered',0) and minion.health>xQ and minion.health<xW and minion.health>xA then DrawTextObject('W',minion,Color.Yellow)
                elseif not IsBuffed(minion,'katarina_daggered',0) and minion.health>xQ and minion.health>xW and minion.health<xA then DrawTextObject('AA',minion,Color.Yellow)
                end
            end
            
            if CFG['1. Hotkeys'].Farm then
                if ((IsBuffed(minion,'katarina_daggered',0) and minion.health<xA+xQ2) or (not IsBuffed(minion,'katarina_daggered',0) and minion.health<xA)) and GetDistance(minion)<210 then AttackTarget(minion)
                elseif ((IsBuffed(minion,'katarina_daggered',0) and minion.health<xW+xQ2) or (not IsBuffed(minion,'katarina_daggered',0) and minion.health<xW)) and GetDistance(minion)<375 and
                    not (((IsBuffed(minion,'katarina_daggered',0) and minion.health<xA+xQ2) or (not IsBuffed(minion,'katarina_daggered',0) and minion.health<xA)) and GetDistance(minion)<210) then
                    CastSpellTarget('W',myHero)
                elseif ((IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ+xQ2) or (not IsBuffed(minion,'katarina_daggered',0) and minion.health<xQ)) and GetDistance(minion)<675 and
                    not (((IsBuffed(minion,'katarina_daggered',0) and minion.health<xA+xQ2) or (not IsBuffed(minion,'katarina_daggered',0) and minion.health<xA)) and GetDistance(minion)<210) and
                    not (((IsBuffed(minion,'katarina_daggered',0) and minion.health<xW+xQ2) or (not IsBuffed(minion,'katarina_daggered',0) and minion.health<xW)) and GetDistance(minion)<375) then
                    CastSpellTarget('Q',minion)
				end
            end
        end
    end
end

function AutoPotions()
	if bluePill==nil and not locus then
		if CFG['7. Auto potions'].Health_Potion and myHero.health<myHero.maxHealth*(CFG['7. Auto potions'].Health_Potion_Value/100) and GetClock()>wUsedAt+15000 then
			UseItemOnTarget(2003,myHero)
			wUsedAt = GetClock()
		elseif CFG['7. Auto potions'].Chrystalline_Flask and myHero.health<myHero.maxHealth*(CFG['7. Auto potions'].Chrystalline_Flask_Value/100) and GetClock()>vUsedAt+10000 then 
			UseItemOnTarget(2041,myHero)
			vUsedAt = GetClock()
		elseif CFG['7. Auto potions'].Biscuit and myHero.health<myHero.maxHealth*(CFG['7. Auto potions'].Biscuit_Value/100) then UseItemOnTarget(2009,myHero)
		elseif CFG['7. Auto potions'].Elixir_of_Fortitude and myHero.health<myHero.maxHealth*(CFG['7. Auto potions'].Elixir_of_Fortitude_Value/100) then UseItemOnTarget(2037,myHero)
		end
	end
	if (os.clock()<Pot_Timer+5000) then bluePill = nil end
end

function Level_Spell(letter)  
     if letter == Q then send.key_press(0x69)
     elseif letter == W then send.key_press(0x6a)
     elseif letter == E then send.key_press(0x6b)
     elseif letter == R then send.key_press(0x6c) 
	 end
end
local metakey,attempts,lastAttempt = SKeys.Control,0,0
function AutoLevel()
	if CFG['6. AutoLevel'].Spellorder==1 then
		skillingOrder = {Q,E,W,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E}
	else
		skillingOrder = {Q,E,W,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E}
	end
	spellLevelSum = (GetSpellLevel(Q) + GetSpellLevel(W) + GetSpellLevel(E) + GetSpellLevel(R))
	if attempts <= 10 or (attempts > 10 and GetTickCount() > lastAttempt+1500) then
		if spellLevelSum < myHero.selflevel then
			if lastSpellLevelSum ~= spellLevelSum then attempts = 0 end
			letter = skillingOrder[spellLevelSum+1]
			Level_Spell(letter, spellLevelSum)
			attempts = attempts+1
			lastAttempt = GetTickCount()
			lastSpellLevelSum = spellLevelSum
		else
			attempts = 0
		end
	end
end
		
function Move()
	MoveToMouse()
end

function AutoZonyas()
	if not locus and myHero.health < myHero.maxHealth*CFG['2. Main options'].healthpercent/100 and CountEnemyInRange(1000)>0 then
		UseItemOnTarget(3157,myHero)
		UseItemOnTarget(3090,myHero)
	end
end

function Wspell()
	CastSpellTarget('W',myHero)
end

function AutoW()
	local target2 = GetWeakEnemy('MAGIC',375)
	if target2~=nil and target2.visible==1 and target2.dead==0 and target2.invulnerable==0 and not locus and CD(0,1,n,n,n,n) and (not _Q_ or Buff1(target2)) then run_every(.1,Wspell) end
end

function Harass(target)
    if target~=nil and target.visible==1 and target.dead==0 and target.invulnerable==0 then
		if CFG['8. Experimental options'].Harass_method==1 then
			if 	CD(n,n,1,n,n,n) and not (CD(n,0,1,n,n,n) and _Q_) and GetDistance(target)<700 then CastSpellTarget('E',target)
			elseif	CD(1,n,0,n,n,n) and GetDistance(target)<675 then CastSpellTarget('Q',target)
			elseif	CD(0,1,0,n,n,n) and not _Q_ and GetDistance(target)<375 then CastSpellTarget('W',myHero)
			elseif	CD(n,0,0,n,n,n) and Buff1(target) and GetDistance(target)<210 then AttackTarget(target)
			end
		else
			if      CD(n,1,1,n,n,n) and GetDistance(target)<700 then CastSpellTarget('E',target)
			elseif  CD(1,1,0,n,n,n) and GetDistance(target)<675 then CastSpellTarget('Q',target)
			elseif  CD(0,1,0,n,n,n) and not _Q_ and GetDistance(target)<375 then CastSpellTarget('W',myHero)
			elseif  CD(1,0,n,n,n,n) and GetDistance(target)<675 then CastSpellTarget('Q',target,0)
			elseif  CD(0,0,1,n,n,n) and not _Q_ and GetDistance(target)<700 then CastSpellTarget('E',target)
			elseif  CD(0,0,0,n,n,n) and IsBuffed(target,'katarina_daggered',0) and GetDistance(target)<210 then AttackTarget(target)
			end
		end
    end
end

function Combo(target)
    if target~=nil and target.visible==1 and target.dead==0 and target.invulnerable==0 then
		if CFG['8. Experimental options'].Combo_method==1 then
			if    ((CD(1,1,1,n,n,n) and GetDistance(target)<700) or (CD(n,n,n,1,n,n) and GetDistance(target)<425)) and (DFG==1 or BFT==1) and CFG['4. Misc options'].UseItemsCombo then UseAllItems(target)
			elseif	CD(n,n,1,n,n,n) and not (CD(n,0,1,0,n,n) and _Q_) and GetDistance(target)<=700 then CastSpellTarget('E',target)
			elseif	CD(1,n,n,n,n,n) and GetDistance(target)<=675 then CastSpellTarget('Q',target)
			elseif	CD(0,1,0,n,n,n) and not (CD(0,1,0,0,n,n) and _Q_) and GetDistance(target)<=375 then CastSpellTarget('W',myHero)
			elseif	CD(0,0,0,1,n,n) and GetDistance(target)<=425 then CastSpellTarget('R',myHero)
			elseif	CD(n,0,0,0,n,n) and Buff1(target) and GetDistance(target)<210 then AttackTarget(target)
			end
		else
			if	  ((CD(1,1,1,n,n,n) and GetDistance(target)<700) or (CD(n,n,n,1) and GetDistance(target)<400)) and (DFG==1 or BFT==1) then UseAllItems(target)
			elseif  CD(n,1,1,0,n,n) and GetDistance(target)<700 then CastSpellTarget('E',target)
			elseif  CD(1,1,0,0,n,n) and GetDistance(target)<675 then CastSpellTarget('Q',target)
			elseif  CD(0,1,0,0,n,n) and not _Q_ and GetDistance(target)<375 then run_every(.1,Wspell)
			elseif  CD(1,0,n,0,n,n) and GetDistance(target)<675 then CastSpellTarget('Q',target)
			elseif  CD(0,0,1,0,n,n) and not _Q_ and GetDistance(target)<700 then CastSpellTarget('E',target)
			elseif  CD(n,n,1,1,n,n) and GetDistance(target)<700 then CastSpellTarget('E',target)
			elseif  CD(1,n,0,1,n,n) and GetDistance(target)<675 then CastSpellTarget('Q',target)
			elseif  CD(0,1,0,1,n,n) and GetDistance(target)<375 then CastSpellTarget('W',myHero)
			elseif  CD(0,0,0,1,n,n) and GetDistance(target)<375 then CastSpellTarget('R',myHero)
			elseif  CD(0,0,0,0,n,n) and IsBuffed(target,'katarina_daggered',0) and GetDistance(target)<210 then AttackTarget(target)
			end
		end
    end
end

function E_NEAREST()
	if ERDY==1 then
		local a
		local b = math.huge
		for i = 1, objManager:GetMaxObjects(), 1 do
			local obj = objManager:GetObject(i)
			if obj~=nil and GetDistance(obj)<CFG['4. Misc options'].Ehelper_range and (obj.type==12 or obj.type==20) and obj.charName~=myHero.charName then
				if 	(string.find(obj.name,'Ward') or obj.name=='OdinNeutralGuardian') or
					((string.find(obj.name,'inion') or obj.name=='Golem' or obj.name=='Lizard' or obj.name=='Wraith' or obj.name=='Dragon' or 
					obj.name=='Wolf' or obj.name=='Tibbers' or obj.name=='Voidling' or obj.name=='TeemoMushroom' or obj.name=='HeimerTYellow' or obj.name=='HeimerTBlue' or 
					obj.name=='JarvanIVStandard' or obj.name=='ZyraThornPlant' or obj.name=='ZyraGraspingPlant' or obj.name=='Spiderling' or obj.type==20) and obj.visible==1 and obj.dead==0) then
					local dist = GetDistanceSqr(mousePos, obj)
					if dist<b then
						b = dist
						a = obj
					end
				end
			end
		end
		if a~=nil then 
			if CFG['3. Draw options'].E_helper then CustomCircle(50,15,0,a) end
			if CFG['1. Hotkeys'].Espell then CastSpellTarget('E',a) end
		end
	end
end

local Enemies = {}
local EnemyIndex = 1
for i = 1, objManager:GetMaxHeroes(), 1 do
	Hero = objManager:GetHero(i)
	if Hero~=nil and Hero.team~=myHero.team then
		if Enemies[Hero.name] == nil then
			Enemies[Hero.name] = { Unit = Hero, Number = EnemyIndex }
			EnemyIndex = EnemyIndex+1
		end
	end
end
 
function Roamhelper()
	for i, Enemy in pairs(Enemies) do
		if Enemy~=nil then
			Hero = Enemy.Unit
			if (IsBuffed(Hero,'katarina_daggered',0) or IsBuffed(Hero,'katarina_bouncingBlades_mis',700)) or QRDY==1 then xQ2RDY=1 else xQ2RDY=0 end
			local PosX = (13.3/16)*GetScreenX()
			local GSY = GetScreenY()
			local xQ = CalcDamRoam(getDmg('Q',Hero,myHero,1),Hero)*QRDY
			local xQ2 = CalcDamRoam(getDmg('Q',Hero,myHero,2),Hero)*xQ2RDY
			local xW = CalcDamRoam(getDmg('W',Hero,myHero),Hero)*WRDY
			local xE = CalcDamRoam(getDmg('E',Hero,myHero),Hero)*ERDY
			local xR = CalcDamRoam(getDmg('R',Hero,myHero),Hero)*CFG['4. Misc options'].CalcR*RRDY
			local xBC = CalcDamRoam(getDmg('BWC',Hero,myHero),Hero)*BC
			local xHG = CalcDamRoam(getDmg('HXG',Hero,myHero),Hero)*HG
			local xDFG = CalcDamRoam(getDmg('DFG',Hero,myHero),Hero)*DFG
			local xBFT = CalcDamRoam(getDmg('BLACKFIRE',Hero,myHero),Hero)*BFT
			local xIGN = getDmg('IGNITE',Hero,myHero)*IGN
			local Damage = Round(xQ+xQ2+xW+xE+xR+xBC+xHG+xIGN+xBFT+xDFG+((xQ+xQ2+xW+xE+xR+xBC+xHG)*(.2*(BFT+DFG))),0)

			DrawText("Champion: "..Hero.name,PosX, ((15/900)*GSY)*Enemy.Number+((53/90)*GSY),Color.SkyBlue)
			if Hero.visible==1 and Hero.dead~=1 then
				if Damage<Hero.health then DrawText("DMG "..Damage,PosX+150,((15/900)*GSY)*Enemy.Number+((53/90)*GSY),Color.Yellow)
				elseif Damage > Hero.health then DrawText("Killable!",PosX + 150,((15/900)*GSY)*Enemy.Number+((53/90)*GSY),Color.Red) end
			end
			if Hero.visible==0 and Hero.dead ~= 1 then DrawText("MIA",PosX+150,((15/900)*GSY)*Enemy.Number+((53/90)*GSY),Color.Orange)
			elseif Hero.dead == 1 then DrawText("Dead", PosX+150,((15/900)*GSY)*Enemy.Number+((53/90)*GSY),Color.Green)
			end
		end
	end
end

function CalcDamRoam(dam,target)
	Adam = dam
	Bdam = (Adam/50)*CFG['5. Mastery options'].DES
	if CFG['5. Mastery options'].EXE == 0 then _EXE = 100
	elseif CFG['5. Mastery options'].EXE == 1 then _EXE = 20/100
	elseif CFG['5. Mastery options'].EXE == 2 then _EXE = 35/100
	elseif CFG['5. Mastery options'].EXE == 3 then _EXE = 50/100
	end
	if ValidTarget(target) and target.health<target.maxHealth*_EXE then Cdam = Adam/20 else Cdam = 0 end
	return (Adam+Bdam+Cdam)
end

function Killsteal_Speed()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if enemy~=nil and enemy.visible==1 and enemy.dead==0 and enemy.team~=myHero.team then
			if (Buff1(enemy) or _Q_) or QRDY==1 then Q2RDY=1 else Q2RDY=0 end
            local effh = (enemy.health)*(1+((((enemy.magicArmor-(20*TrueMG))*myHero.magicPenPercent)-myHero.magicPen)/100))
            local effhmax = (enemy.maxHealth)*(1+((((enemy.magicArmor-(20*TrueMG))*myHero.magicPenPercent)-myHero.magicPen)/100))
            
			if QRDY==1 then xQ = CalcDam(35,myHero.SpellLevelQ,25,.45,0,enemy) else xQ = 0 end
			if Q2RDY==1 and (WRDY==1 or ERDY==1) then xQ2 = CalcDam(0,myHero.SpellLevelQ,15,.15,0,enemy) else xQ2 = 0 end
			if WRDY==1 then xW = CalcDam(5,myHero.SpellLevelW,35,.25,.6,enemy) else xW = 0 end
			if ERDY==1 then xE = CalcDam(35,myHero.SpellLevelE,25,.4,0,enemy) else xE = 0 end
			if RRDY==1 then xR = CalcDam(22.5,myHero.SpellLevelR,17.5,.25,.375,enemy)*CFG['4. Misc options'].CalcR else xR = 0 end

			if DFG==1 or IsBuffed(myHero,'deathFireGrasp_mis',700) then xDFG = CalcDam(15*enemy.maxHealth/100,0,0,0,0,enemy)
			elseif DFG==0 and IsBuffed(enemy,'obj_DeathfireGrasp_debuff',0) then xDFG = 0 
			else xDFG = 0 end
			if BFT==1 or IsBuffed(myHero,'ItemBlackfireTorch_mis',700) then aBFT = CalcDam((20*enemy.maxHealth/100)/4,0,0,0,0,enemy)
			elseif BFT==0 and IsBuffed(enemy,'TT_BlackfireTorch',0) then aBFT = 0 
			else aBFT = 0 end
			
			for i = 1, objManager:GetMaxNewObjects(), 1 do
				local obj = objManager:GetNewObject(i)
				if obj ~= nil and GetDistance(enemy,obj)<125 and obj.charName == 'TT_BlackfireTorch.troy' and BFT==0 then Btimer = GetTickCount() end
			end
			if BFT==1 or GetTickCount()+1000<Btimer then xBFT = aBFT*4
			elseif GetTickCount()+1000>Btimer and BFT==0 then xBFT = aBFT*3
			elseif GetTickCount()+2000>Btimer and BFT==0 then xBFT = aBFT*2
			elseif GetTickCount()+3000>Btimer and BFT==0 then xBFT = aBFT
			elseif GetTickCount()+4000>Btimer and BFT==0 then xBFT = 0 end
			
			xI = xBFT+xDFG
			xAA = CalcDam(myHero.baseDamage+myHero.addDamage,0,0,0,0,enemy)

			KSK[1]  = {a=n,b=1,c=n,d=n,e=n,f=n, dist=375 , spell='_W', buff=n, dam=xW} 										-- xW
			KSK[2]  = {a=n,b=n,c=1,d=n,e=n,f=n, dist=700 , spell='_E', buff=n, dam=xE} 										-- xE
			KSK[3]  = {a=n,b=1,c=1,d=n,e=n,f=n, dist=700 , spell='_E', buff=n, dam=xW+xE} 									-- EW
			KSK[4]  = {a=1,b=n,c=n,d=n,e=n,f=n, dist=675 , spell='_Q', buff=n, dam=xQ} 										-- xQ
			KSK[5]  = {a=1,b=n,c=1,d=n,e=n,f=n, dist=700 , spell='_E', buff=n, dam=xQ+xE} 									-- EQ
			KSK[6]  = {a=1,b=1,c=n,d=n,e=n,f=n, dist=375 , spell='_W', buff=n, dam=xQ+xW}									-- WQ
			KSK[7]  = {a=1,b=1,c=1,d=n,e=n,f=n, dist=700 , spell='_E', buff=n, dam=xQ+xW+xE} 								-- EWQ
			KSK[8]  = {a=1,b=n,c=1,d=n,e=1,f=n, dist=675 , spell='_Q', buff=n, dam=xQ+xQ2+xE} 	
			KSK[9]  = {a=n,b=n,c=1,d=n,e=1,f=n, dist=700 , spell='_E', buff=1, dam=xQ2+xE} 									-- QEx2
			KSK[10] = {a=1,b=1,c=n,d=n,e=1,f=n, dist=375 , spell='_Q', buff=n, dam=xQ+xQ2+xW} 		
			KSK[11] = {a=n,b=1,c=n,d=n,e=1,f=n, dist=375 , spell='_W', buff=1, dam=xQ2+xW} 									-- QWx2
			KSK[12] = {a=1,b=1,c=1,d=n,e=1,f=n, dist=700 , spell='_E', buff=n, dam=xQ+xQ2+xW+xE} 	
			KSK[13] = {a=1,b=1,c=n,d=n,e=1,f=n, dist=675 , spell='_Q', buff=n, dam=xQ2+xW}		
		  --KSK[] = {a=n,b=1,c=n,d=n,e=1,f=n, dist=375 , spell='_W', buff=1, dam=xQ2+xW} 									-- EQWx2
			KSK[14] = {a=n,b=1,c=1,d=n,e=n,f=n, dist=1075, spell='_J', buff=n, dam=xW} 										-- xW long
			KSK[15] = {a=1,b=n,c=1,d=n,e=n,f=n, dist=1375, spell='_J', buff=n, dam=xQ} 										-- xQ long
			KSK[16] = {a=1,b=1,c=1,d=n,e=n,f=n, dist=1075, spell='_J', buff=n, dam=xQ+xW} 									-- WQ long
			KSK[17] = {a=1,b=1,c=1,d=n,e=1,f=n, dist=1075, spell='_J', buff=n, dam=xQ+xQ2+xW} 								-- QW long
			KSK[18] = {a=0,b=0,c=0,d=n,e=n,f=n, dist=210,  spell='_A', buff=n, dam=xAA} 									-- AA
			KSK[19] = {a=0,b=0,c=0,d=n,e=n,f=n, dist=210,  spell='_A', buff=1, dam=xAA+xQ2} 								-- AA*2
			KSK[20] = {a=0,b=0,c=0,d=n,e=n,f=n, dist=910,  spell='_J', buff=n, dam=xAA} 									-- AA long
			KSK[21] = {a=0,b=0,c=0,d=n,e=n,f=n, dist=910,  spell='_J', buff=1, dam=xAA+xQ2}									-- AA*2 long
			KSK[22] = {a=1,b=1,c=1,d=n,e=n,f=1, dist=700,  spell='_E', buff=n, dam=((xQ+xQ2+xW)*1.2)+xE+xI, dam2=xQ+xQ2+xW+xE}
			KSK[23] = {a=1,b=1,c=n,d=n,e=n,f=1, dist=375,  spell='_B', buff=n, dam=((xQ+xQ2+xW)*1.2)+xI, dam2=xQ+xQ2+xW}
			KSK[24] = {a=1,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_Q', buff=3, dam=((xQ+xQ2+xW)*1.2)+xI}
			KSK[25] = {a=n,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_W', buff=4, dam=((xQ2+xW)*1.2)+xI} 						-- IEQWx2 -E
			KSK[26] = {a=1,b=1,c=1,d=n,e=n,f=1, dist=700,  spell='_E', buff=n, dam=((xQ+xW)*1.2)+xE+xI, dam2=xQ+xW+xE}
			KSK[27] = {a=1,b=1,c=n,d=n,e=n,f=1, dist=375,  spell='_B', buff=n, dam=((xQ+xW)*1.2)+xI, dam2=xQ+xW}
			KSK[28] = {a=1,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_W', buff=2, dam=((xQ+xW)*1.2)+xI}
			KSK[29] = {a=1,b=n,c=n,d=n,e=n,f=0, dist=675,  spell='_Q', buff=2, dam=(xQ*1.2)+xI}								-- IEWQ -E
			KSK[30] = {a=1,b=n,c=1,d=n,e=n,f=1, dist=700,  spell='_E', buff=n, dam=(xQ*1.2)+xE+xI, dam2=xQ+xE}
			KSK[31] = {a=1,b=n,c=n,d=n,e=n,f=1, dist=625,  spell='_B', buff=n, dam=(xQ*1.2)+xI, dam2=xQ}
		  --KSK[] = {a=1,b=n,c=n,d=n,e=n,f=0, dist=675,  spell='_Q', buff=2, dam=(xQ*1.2)+xI} 								-- IEQ -E
			KSK[32] = {a=n,b=1,c=1,d=n,e=n,f=1, dist=700,  spell='_E', buff=n, dam=(xW*1.2)+xE+xI, dam2=xW+xE}
			KSK[33] = {a=n,b=1,c=n,d=n,e=n,f=1, dist=375,  spell='_B', buff=n, dam=(xW*1.2)+xI, dam2=xW}
			KSK[34] = {a=n,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_W', buff=2, dam=(xW*1.2)+xI} 							-- IEW -E
		  --KSK[] = {a=1,b=1,c=n,d=n,e=n,f=1, dist=375,  spell='_B', buff=n, dam=((xQ+xW)*1.2)+xI, dam2=xQ+xW}
		  --KSK[] = {a=1,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_W', buff=2, dam=((xQ+xW)*1.2)+xI}
		  --KSK[] = {a=1,b=n,c=n,d=n,e=n,f=0, dist=675,  spell='_Q', buff=2, dam=(xQ*1.2)+xI} 								-- IWQ
		  --KSK[] = {a=1,b=1,c=n,d=n,e=n,f=1, dist=375,  spell='_B', buff=n, dam=((xQ+xQ2+xW)*1.2)+xI, dam2=xQ+xQ2+xW}
		  --KSK[] = {a=1,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_Q', buff=3, dam=((xQ+xQ2+xW)*1.2)+xI}
		  --KSK[] = {a=n,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_W', buff=4, dam=((xQ2+xW)*1.2)+xI} 						-- IQWx2 
			KSK[35] = {a=1,b=1,c=1,d=n,e=n,f=1, dist=625,  spell='_B', buff=n, dam=((xQ+xQ2+xW+xE)*1.2)+xI, dam2=xQ+xQ2+xW+xE}
			KSK[36] = {a=1,b=1,c=1,d=n,e=n,f=0, dist=675,  spell='_Q', buff=3, dam=(xQ+xQ2+xW+xE*1.2)+xI}
			KSK[37] = {a=n,b=1,c=1,d=n,e=n,f=0, dist=700,  spell='_E', buff=2, dam=((xQ2+xW+xE)*1.2)+xI}
		  --KSK[] = {a=n,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_W', buff=4, dam=((xQ2+xW)*1.2)+xI} 						-- IQEWx2
			KSK[38] = {a=1,b=n,c=1,d=n,e=n,f=1, dist=625,  spell='_B', buff=n, dam=((xQ+xQ2+xE)*1.2)+xI, dam2=xQ+xQ2+xE}
			KSK[39] = {a=1,b=n,c=1,d=n,e=n,f=0, dist=675,  spell='_Q', buff=3, dam=((xQ+xQ2+xE)*1.2)+xI}
			KSK[40] = {a=n,b=n,c=1,d=n,e=n,f=0, dist=700,  spell='_E', buff=4, dam=((xQ2+xE)*1.2)+xI} 						-- IQEx2
			KSK[41] = {a=1,b=1,c=1,d=n,e=n,f=1, dist=625,  spell='_B', buff=n, dam=((xQ+xW+xE)*1.2)+xI, dam2=xQ+xW+xE}
			KSK[42] = {a=1,b=1,c=1,d=n,e=n,f=0, dist=700,  spell='_E', buff=2, dam=((xQ+xW+xE)*1.2)+xI}
		  --KSK[] = {a=1,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_W', buff=2, dam=((xQ+xW)*1.2)+xI}
		  --KSK[] = {a=1,b=n,c=n,d=n,e=n,f=0, dist=675,  spell='_Q', buff=2, dam=(xQ*1.2)+xI} 								-- IEWQ
			KSK[43] = {a=1,b=n,c=1,d=n,e=n,f=1, dist=625,  spell='_B', buff=n, dam=((xQ+xE)*1.2)+xI, dam2=xQ+xE} 
			KSK[44] = {a=1,b=n,c=1,d=n,e=n,f=0, dist=700,  spell='_E', buff=2, dam=((xQ+xE)*1.2)+xI}
		  --KSK[] = {a=1,b=n,c=n,d=n,e=n,f=0, dist=675,  spell='_Q', buff=2, dam=(xQ*1.2)+xI} 								-- IEQ
		  --KSK[] = {a=n,b=1,c=n,d=n,e=n,f=1, dist=375,  spell='_B', buff=n, dam=(xW*1.2)+xI, dam2=xW}
		  --KSK[] = {a=n,b=1,c=n,d=n,e=n,f=0, dist=375,  spell='_W', buff=2, dam=(xW*1.2)+xI} 								-- IW
		  --KSK[] = {a=1,b=n,c=n,d=n,e=n,f=1, dist=625,  spell='_B', buff=n, dam=(xQ*1.2)+xI, dam2=xQ}
		  --KSK[] = {a=1,b=n,c=n,d=n,e=n,f=0, dist=675,  spell='_Q', buff=2, dam=(xQ*1.2)+xI} 								-- IQ
			KSK[45] = {a=n,b=n,c=1,d=n,e=n,f=1, dist=625,  spell='_B', buff=n, dam=(xE*1.2)+xI, dam2=xE}
			KSK[46] = {a=n,b=n,c=1,d=n,e=n,f=0, dist=700,  spell='_E', buff=2, dam=(xE*1.2)+xI} 							-- IE
			KSK[47] = {a=n,b=1,c=1,d=n,e=n,f=1, dist=1075, spell='_J', buff=n, dam=(xW*1.2)+xI, dam2=xW} 					-- IW long
			KSK[48] = {a=1,b=n,c=1,d=n,e=n,f=1, dist=1375, spell='_J', buff=n, dam=(xQ*1.2)+xI, dam2=xQ} 					-- IQ long
			KSK[49] = {a=1,b=1,c=1,d=n,e=n,f=1, dist=1075, spell='_J', buff=n, dam=((xQ+xW)*1.2)+xI, dam2=xQ+xW} 			-- IWQ long
			KSK[50] = {a=1,b=1,c=1,d=n,e=1,f=1, dist=1075, spell='_J', buff=n, dam=((xQ+xQ2+xW)*1.2)+xI, dam2=xQ+xQ2+xW} 	-- IQW long
			
			for v=1,50 do
				if CFG['2. Main options'].Killsteal then
						if enemy.invulnerable==0  then
							if not locus or CFG['4. Misc options'].BreakUltKS then
								if CD(KSK[v].a,KSK[v].b,KSK[v].c,KSK[v].d,KSK[v].e,KSK[v].f) then
									if GetDistance(enemy)<KSK[v].dist then
										if effh<KSK[v].dam and (KSK[v].dam2 == nil or effh>KSK[v].dam2) then 
											if  ((KSK[v].buff==1 and IsBuffed(enemy,'katarina_daggered',0)) or
												(KSK[v].buff==2 and (IsBuffed(enemy,'TT_BlackfireTorch',0) or IsBuffed(enemy,'obj_DeathfireGrasp_debuff',0))) or
												(KSK[v].buff==3 and (IsBuffed(enemy,'ItemBlackfireTorch_mis',700) or IsBuffed(enemy,'deathFireGrasp_mis',700))) or
												((KSK[v].buff==4 and IsBuffed(enemy,'katarina_daggered',0)) and (IsBuffed(enemy,'TT_BlackfireTorch',0) or IsBuffed(enemy,'obj_DeathfireGrasp_debuff',0))) or KSK[v].buff==n) then
												if KSK[v].spell == '_B' then
													UseItemOnTarget(3188, enemy)
													UseItemOnTarget(3128, enemy)
												elseif KSK[v].spell == '_Q' then CastSpellTarget('Q',enemy)
												elseif KSK[v].spell == '_W' then run_every(.1,Wspell)
												elseif KSK[v].spell == '_E' then CastSpellTarget('E',enemy)
												elseif KSK[v].spell == '_A' then AttackTarget(enemy)
												elseif KSK[v].spell == '_J' then
													for i = 1, objManager:GetMaxObjects(), 1 do
														local object = objManager:GetObject(i)
														if object~=nil and GetDistance(object)<700 and (object.type==20 or object.type==12) then
															for i, spot in pairs(TargetableSpots) do
																if (string.find(object.name,spot) or object.type==20) and object.charName~=myHero.charName and GetDistance(object,enemy)<(KSK[v].dist-700) and GetDistance(object)<700 then
																	CastSpellTarget('E',object)
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
					end
				end
			end
			
			if CFG['3. Draw options'].Healthpercent then
				Damage_A = round(((effh-((xQ+xQ2+xW+xE)+((xQ+xQ2+xW+xE)*(.2*(BFT+DFG)))+xI))/effhmax*100),0)
				Damage_B = round(((effh-(xQ+xQ2+xW+xE+xR))/effhmax*100),0)
				if Damage_A<0 then Damage_C = 'KILL' else Damage_C = Damage_A..'% , ' end
				if Damage_B<0 then Damage_D = 'KILL' else Damage_D = Damage_B..'%' end
				if Damage_A<0 then DrawTextObject(Damage_C,enemy,Color.Red)
				elseif Damage_B<0 then DrawTextObject(Damage_C..Damage_D,enemy,Color.Yellow)
				else
					if RRDY==0 then DrawTextObject(Damage_C,enemy,Color.Cyan)
					else DrawTextObject(Damage_C..Damage_D,enemy,Color.Cyan) end
				end
			end
		end
	end
end

function Killsteal_Damage()
    for i = 1, objManager:GetMaxHeroes() do
        local enemy = objManager:GetHero(i)
        if ValidTarget(enemy) and enemy.team~=myHero.team then
            if IsBuffed(enemy,'katarina_daggered',0) or _Q_ or QRDY==1 then Q2RDY=1 else Q2RDY=0 end
            
            if QRDY==1 then xQ = getDmg('Q',enemy,myHero,1) else xQ = 0 end
            if Q2RDY==1 and (WRDY==1 or ERDY==1) then xQ2 = getDmg('Q',enemy,myHero,2) else xQ2 = 0 end
            if WRDY==1 then xW = getDmg('W',enemy,myHero) else xW = 0 end
            if ERDY==1 then xE = getDmg('E',enemy,myHero) else xE = 0 end
            if RRDY==1 then xR = getDmg('R',enemy,myHero)*5 else xR = 0 end
			if DFG==1 or IsBuffed(myHero,'deathFireGrasp_mis',700) then xDFG = getDmg('DFG',enemy,myHero)
			elseif DFG==0 and IsBuffed(enemy,'obj_DeathfireGrasp_debuff',0) then xDFG = 0 
			else xDFG = 0 end
			if BFT==1 or IsBuffed(myHero,'ItemBlackfireTorch_mis',700) then xBFT = getDmg('BLACKFIRE',enemy,myHero)
			elseif BFT==0 and IsBuffed(enemy,'TT_BlackfireTorch',0) then xBFT = 0 
			else xBFT = 0 end
			xI = xBFT+xDFG
			if IGN==1 then xIGN = getDmg('IGNITE',enemy,myHero) else xIGN = 0 end
            
            if enemy.health<xQ and ERDY==1 then distance = 1375 else distance = 1075 end
			
			if CFG['2. Main options'].Killsteal then
				if (enemy.health<xQ and ERDY==1 and GetDistance(enemy)<distance and GetDistance(enemy)>distance-700) or (enemy.health<xQ+xQ2+xW and ERDY==1 and GetDistance(enemy)<distance and GetDistance(enemy)>distance-700) then
					for i = 1, objManager:GetMaxObjects(), 1 do
						local object = objManager:GetObject(i)
						if object~=nil and GetDistance(object)<700 and (object.type==20 or object.type==12) then
							for i, spot in pairs(TargetableSpots) do
								if (string.find(object.name,spot) or object.type==20) and object.charName~=myHero.charName and GetDistance(object,enemy)<distance-700 and GetDistance(object)<700 then 
									if not locus or CFG['4. Misc options'].BreakUltKS then CastSpellTarget('E',object,0) end
								end
							end
						end
					end
				elseif enemy.health<xQ+xQ2+xW+xE+xI+xIGN and GetDistance(enemy)<math.max(QRDY*600,WRDY*375,ERDY*700) then
					if not locus or CFG['4. Misc options'].BreakUltKS then
						if myHero.SummonerD == 'summonerdot' then CastSpellTarget('D',target)
						elseif myHero.SummonerF == 'summonerdot' then CastSpellTarget('F',target)
						end
						if (DFG==1 or BFT==1) then UseAllItems(target) end
						if DFG+BFT==0 and not Buff3(enemy) then Harass(enemy) end
					end
				elseif enemy.health<xQ+xQ2+xW+xE+xIGN and enemy.health>xQ+xQ2+xW+xE+xIGN and GetDistance(enemy)<math.max(QRDY*600,WRDY*375,ERDY*700) then
					if not locus or CFG['4. Misc options'].BreakUltKS then
						if myHero.SummonerD == 'summonerdot' then CastSpellTarget('D',target)
						elseif myHero.SummonerF == 'summonerdot' then CastSpellTarget('F',target)
						end
						Harass(enemy)
					end
				elseif enemy.health<xQ+xQ2+xW+xE+xI and enemy.health>xQ+xQ2+xW+xE and GetDistance(enemy)<math.max(QRDY*675,WRDY*375,ERDY*700) then
					if not locus or CFG['4. Misc options'].BreakUltKS then
						if (DFG==1 or BFT==1) then UseAllItems(target) end
						if DFG+BFT==0 and not Buff3(enemy) then Harass(enemy) end
					end
				elseif enemy.health<xQ+xQ2+xW+xE and GetDistance(enemy)<math.max(QRDY*675,WRDY*375,ERDY*700) then 
					if not locus or CFG['4. Misc options'].BreakUltKS then Harass(enemy) end
				end
			end
			
			if CFG['3. Draw options'].Healthpercent then
				Damage_A = round(((enemy.health-(xIGN+((xQ+xQ2+xW+xE)+((xQ+xQ2+xW+xE)*(.2*(BFT+DFG)))+xI)))/enemy.maxHealth*100),0)
				Damage_B = round(((enemy.health-(xIGN+((xQ+xQ2+xW+xE+xR)+((xQ+xQ2+xW+xE+xR)*(.2*(BFT+DFG)))+xI)))/enemy.maxHealth*100),0)
				if Damage_A<0 then Damage_C = 'KILL' else Damage_C = Damage_A..'% , ' end
				if Damage_B<0 then Damage_D = 'KILL' else Damage_D = Damage_B..'%' end
				if Damage_A<0 then DrawTextObject(Damage_C,enemy,Color.Red)
				elseif Damage_B<0 then DrawTextObject(Damage_C..Damage_D,enemy,Color.Yellow)
				else
					if RRDY==0 then DrawTextObject(Damage_C,enemy,Color.Cyan)
					else DrawTextObject(Damage_C..Damage_D,enemy,Color.Cyan) end
				end
			end
        end
    end
end

function Buff1(target)
	if IsBuffed(target,'katarina_daggered',0) then return true end
end
function Buff2(target)
	if IsBuffed(target,'TT_BlackfireTorch',0) or IsBuffed(target,'obj_DeathfireGrasp_debuff',0) then return true end
end
function Buff3(target)
	if IsBuffed(target,'ItemBlackfireTorch_mis',700) or IsBuffed(target,'deathFireGrasp_mis',700) then return true end
end
function Buff4(target)
	if IsBuffed(enemy,'katarina_daggered',0) and (IsBuffed(enemy,'TT_BlackfireTorch',0) or IsBuffed(enemy,'obj_DeathfireGrasp_debuff',0)) then return true end
end
function Buff5(target)
	if IsBuffed(target,'katarina_bouncingBlades_mis',700) then return true end
end

function CD(a,b,c,d,e,f)
	if (QRDY == a or a == n) and (WRDY == b or b == n) and (ERDY == c or c == n) and (RRDY == d or d == n) and ((Q2RDY~=nil and Q2RDY == e) or e == n) and (BFT+DFG == f or f == n) then return true end
end

function OnCreateObj(obj)
	if obj~=nil then 
		if obj.charName == 'Katarina_deathLotus_empty.troy' and GetDistance(obj)==0 then locus = false end
		if GetDistance(obj)<100 and string.find(obj.charName,'FountainHeal') then 
			Pot_Timer=os.clock()
			bluePill = object
		end
	end
end

function OnProcessSpell(unit , spell)
	if unit ~= nil and spell ~= nil and unit.team == myHero.team and unit.name == myHero.name then
		if spell.name == "KatarinaQ" and target~=nil and spell.target then _Q_ = true end
		if spell.name == "KatarinaR" then
			Rtimer = GetClock()
			locus = true
		end
	end
	local P1 = spell.startPos
	local P2 = spell.endPos
	local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
	if string.find(unit.name,'Minion_') == nil and string.find(unit.name,'Turret_') == nil then
		if (unit.team ~= myHero.team or (show_allies==1)) and string.find(spell.name,'Basic') == nil then
			for i=1, #skillshotArray, 1 do
				local maxdist
				local dodgeradius
				dodgeradius = math.max(skillshotArray[i].radius,100)
				maxdist = skillshotArray[i].maxdistance+150
				if spell.name == skillshotArray[i].name then
					skillshotArray[i].shot = 1
					skillshotArray[i].lastshot = os.clock()
					if skillshotArray[i].type == 1 then
						maxdist = skillshotArray[i].maxdistance+150
						skillshotArray[i].p1x = unit.x
						skillshotArray[i].p1y = unit.y
						skillshotArray[i].p1z = unit.z
						skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
						skillshotArray[i].p2y = P2.y
						skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
					elseif skillshotArray[i].type == 2 then
						skillshotArray[i].px = P2.x
						skillshotArray[i].py = P2.y
						skillshotArray[i].pz = P2.z
						dodgelinepoint(unit, P2, dodgeradius)
					elseif skillshotArray[i].type == 3 then
						skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
					elseif skillshotArray[i].type == 4 then
						skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
						skillshotArray[i].py = P2.y
						skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
					elseif skillshotArray[i].type == 5 then
						maxdist = skillshotArray[i].maxdistance
						skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
					end
				end
			end
		end
	end
end

function SetVariables()
	if myHero.SpellTimeE<(((13.5-(myHero.SpellLevelW*1.5))+((13.5-(myHero.SpellLevelW*1.5))*myHero.cdr))*(-1))+1 and myHero.SpellLevelQ>0 then Q3RDY=1 else Q3RDY=0 end
	target = GetWeakEnemy('MAGIC',math.max(QRDY*700,WRDY*375,ERDY*700,RRDY*550,Q3RDY*700),'NEARMOUSE')
	Minions = GetEnemyMinions(SORT_CUSTOM)
	if not locus and ValidTarget(target) and CFG['1. Hotkeys'].Combo then Combo_ = true
	elseif locus or not ValidTarget(target) or myHero.dead==1 or CD(0,0,0,0,n,n) then Combo_ = false end
	if not locus and ValidTarget(target) and CFG['1. Hotkeys'].Harass then Harass_ = true
	elseif locus or not ValidTarget(target) or myHero.dead==1 or CD(0,0,0,n,n,n) then Harass_ = false end
	if GetInventorySlot(3001)~=nil then TrueMG = 1 else TrueMG = 0 end
	if GetClock()-Rtimer>2750 or myHero.dead==1 then locus = false end
	
	for i = 1, objManager:GetMaxDelObjects(), 1 do
		local object = {objManager:GetDelObject(i)}
		local ret={}
		ret.index=object[1]
		ret.name=object[2]
		ret.charName=object[3]
		ret.x=object[4]
		ret.y=object[5]
		ret.z=object[6]
		if ret.charName~=nil and (ret.charName == 'Katarina_deathLotus_cas.troy' or ret.charName == 'Katarina_deathLotus_empty.troy') and GetDistance(ret)==0 then locus = false end
	end
end

function Draw()
	if myHero.dead==0 then 
		if CFG['3. Draw options'].Show_ranges then CustomCircle(math.max(QRDY*675,WRDY*375,ERDY*700,RRDY*550),1,2,myHero) end
		if ValidTarget(target) and CFG['3. Draw options'].Show_target then CustomCircle(75,25,2,target) end
		--if Combo_ or CFG['1. Hotkeys'].Combo then DrawTextObject('Combo',myHero,Color.Yellow) end
		--if Harass_ or CFG['1. Hotkeys'].Harass then DrawTextObject('Harass',myHero,Color.Yellow) end
	end
end

function CalcDam(a,spell,b,c,d,target)
    Adam = a+(spell*b)+(myHero.ap*c)+(myHero.addDamage*d)
	Bdam = (Adam/50)*CFG['5. Mastery options'].DES
	if CFG['5. Mastery options'].EXE == 0 then _EXE = 100
	elseif CFG['5. Mastery options'].EXE == 1 then _EXE = 20/100
	elseif CFG['5. Mastery options'].EXE == 2 then _EXE = 35/100
	elseif CFG['5. Mastery options'].EXE == 3 then _EXE = 50/100
	end
	if ValidTarget(target) and target.health<target.maxHealth*_EXE then Cdam = Adam/20 else Cdam = 0 end
	return (Adam+Bdam+Cdam)*.999
end

TargetableSpots = {	
	'Minion','Superminion','Ward','Golem','Lizard','Wraith','Dragon','Wolf','Tibbers','HeimerTYellow','HeimerTBlue','JarvanIVStandard','Voidling',
	'OdinNeutralGuardian','TeemoMushroom','ZyraThornPlant','ZyraGraspingPlant','Spiderling','Golem','Wolf','Wraith','Lizard','Worm','Dragon'}
	
function calculateLinepass(pos1, pos2, spacing, maxDist)
	local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
	local line = {}
	local point1 = {}
	point1.x = pos1.x
	point1.y = pos1.y
	point1.z = pos1.z
	local point2 = {}
	point1.x = pos1.x + (maxDist)/calc*(pos2.x-pos1.x)
	point1.y = pos2.y
	point1.z = pos1.z + (maxDist)/calc*(pos2.z-pos1.z)
	table.insert(line, point2)
	table.insert(line, point1)
	return line
end

function calculateLineaoe(pos1, pos2, maxDist)
	local line = {}
	local point = {}
	point.x = pos2.x
	point.y = pos2.y
	point.z = pos2.z
	table.insert(line, point)
	return line
end

function calculateLineaoe2(pos1, pos2, maxDist)
	local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
	local line = {}
	local point = {}
		if calc < maxDist then
		point.x = pos2.x
		point.y = pos2.y
		point.z = pos2.z
		table.insert(line, point)
	else
		point.x = pos1.x + maxDist/calc*(pos2.x-pos1.x)
		point.z = pos1.z + maxDist/calc*(pos2.z-pos1.z)
		point.y = pos2.y
		table.insert(line, point)
	end
	return line
end

function calculateLinepoint(pos1, pos2, spacing, maxDist)
	local line = {}
	local point1 = {}
	point1.x = pos1.x
	point1.y = pos1.y
	point1.z = pos1.z
	local point2 = {}
	point1.x = pos2.x
	point1.y = pos2.y
	point1.z = pos2.z
	table.insert(line, point2)
	table.insert(line, point1)
	return line
end

function LoadTable()
	print("table loaded::")
	for i = 1, objManager:GetMaxHeroes() do
		local ee = objManager:GetHero(i)
		if ee~=nil and ee.team~=myHero.team then
			if ee.name == 'Aatrox' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=600,type=3,radius=200,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=120,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Ahri' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=880,type=1,radius=105,color=colorcyan,time=((880/1.7)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=975,type=1,radius=70,color=colorcyan,time=((975/1.5)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Amumu' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=1,radius=90,color=colorcyan,time=((1100/2)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Anivia' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=1,radius=90,color=colorcyan,time=2,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Ashe' then
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=10000,type=1,radius=120,color=colorcyan,time=4,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Blitzcrank' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=925,type=1,radius=80,color=colorcyan,time=((925/1.7)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Brand' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1050,type=1,radius=85,color=colorcyan,time=((1050/1.6)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameW,shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=3,radius=250,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Braum' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=100,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Cassiopeia' then
				table.insert(skillshotArray,{name=ee.SpellNameW,shot=0,lastshot=0,skillshotpoint={},maxdistance=850,type=3,radius=175,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=850,type=3,radius=75,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Caitlyn' then -- need width + speed
				--table.insert(skillshotArray,{name='CaitlynEntrapmentMissile',shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=50,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1300,type=1,radius=150,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Chogath' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=950,type=3,radius=275,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Corki' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=800,type=1,radius=150,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1225,type=1,radius=50,color=colorcyan,time=((1225/2)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Diana' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=1,radius=205,color=colorcyan,time=((830/1.4)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'DrMundo' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=80,color=colorcyan,time=((1000/2)+160)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			
			end
			if ee.name == 'Draven' then
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1050,type=1,radius=135,color=colorcyan,time=((1050/1.4)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=5000,type=1,radius=125,color=colorcyan,time=4,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Elise' then
				table.insert(skillshotArray,{name='EliseHumanE',shot=0,lastshot=0,skillshotpoint={},maxdistance=1075,type=1,radius=80,color=colorcyan,time=((1075/1.5)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Ezreal' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=1,radius=100,color=colorcyan,time=((1100/2)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='EzrealEssenceFluxMissile',shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=1,radius=100,color=colorcyan,time=((900/1.5)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=10000,type=1,radius=175,color=colorcyan,time=4,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Fizz' then
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=400,type=3,radius=270,color=coloryellow,time=0.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1275,type=1,radius=100,color=colorcyan,time=((1275/1.3)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'FiddleSticks' then
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=800,type=3,radius=600,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Galio' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=905,type=3,radius=200,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=120,color=colorcyan,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Gnar' then
				table.insert(skillshotArray,{name='gnarqmissile',shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=1,radius=90,color=coloryellow,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='GnarBigQMissile',shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=1,radius=90,color=coloryellow,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='gnarbige',shot=0,lastshot=0,skillshotpoint={},maxdistance=475,type=3,radius=160,color=coloryellow,time=0.8,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Gragas' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=3,radius=320,color=coloryellow,time=2.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=650,type=1,radius=60,color=colorcyan,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1050,type=3,radius=400,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Graves' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=110,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=100,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Heimerdinger' then
				table.insert(skillshotArray,{name=ee.SpellNameW,shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=1,radius=100,color=colorcyan,time=((1100/1.4)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=950,type=3,radius=180,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='heimerdingereult',shot=0,lastshot=0,skillshotpoint={},maxdistance=950,type=3,radius=180,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})		
			end
			if ee.name == 'Irelia' then
				--table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1200,type=1,radius=150,color=colorcyan,time=0.8,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Janna' then
				table.insert(skillshotArray,{name='HowlingGale',shot=0,lastshot=0,skillshotpoint={},maxdistance=1700,type=1,radius=215,color=colorcyan,time=((1700/.9)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'JarvanIV' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=770,type=1,radius=70,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=830,type=3,radius=150,color=coloryellow,time=2,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Jayce' then
				table.insert(skillshotArray,{name='jayceshockblast',shot=0,lastshot=0,skillshotpoint={},maxdistance=1470,type=1,radius=100,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Jinx' then
				table.insert(skillshotArray,{name=ee.SpellNameW,shot=0,lastshot=0,skillshotpoint={},maxdistance=1500,type=1,radius=70,color=colorcyan,time=((1500/3.3)+600)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=10000,type=1,radius=145,color=colorcyan,time=4,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Karma' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=950,type=1,radius=100,color=colorcyan,time=((950/1.7)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Karthus' then
				table.insert(skillshotArray,{name='karthuslaywastea2',shot=0,lastshot=0,skillshotpoint={},maxdistance=875,type=3,radius=165,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Kennen' then
				table.insert(skillshotArray,{name='KennenShurikenHurlMissile1',shot=0,lastshot=0,skillshotpoint={},maxdistance=1050,type=1,radius=60,color=colorcyan,time=((1050/1.6)+160)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Khazix' then
				table.insert(skillshotArray,{name='KhazixW',shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=70,color=coloryellow,time=((1000/1.7)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='KhazixE',shot=0,lastshot=0,skillshotpoint={},maxdistance=600,type=3,radius=250,color=coloryellow,time=0.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='khazixelong',shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=3,radius=250,color=coloryellow,time=1.2,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'KogMaw' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=80,color=colorcyan,time=((1000/1.6)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})			
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1280,type=1,radius=130,color=colorcyan,time=((1280/1.4)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1800,type=3,radius=230,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Leblanc' then
				table.insert(skillshotArray,{name='LeblancSlide',shot=0,lastshot=0,skillshotpoint={},maxdistance=600,type=3,radius=250,color=coloryellow,time=0.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='LeblancSlideM',shot=0,lastshot=0,skillshotpoint={},maxdistance=600,type=3,radius=250,color=coloryellow,time=0.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=950,type=1,radius=80,color=colorcyan,time=((950/1.6)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'LeeSin' then
				table.insert(skillshotArray,{name='BlindMonkQOne',shot=0,lastshot=0,skillshotpoint={},maxdistance=975,type=1,radius=70,color=colorcyan,time=((975/1.8)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Leona' then -- Don't ownt his champ
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=700,type=1,radius=120,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1200,type=3,radius=250,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Lissandra' then -- Don't own this champ
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=725,type=1,radius=100,color=coloryellow,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1050,type=1,radius=100,color=coloryellow,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Lucian' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1110,type=1,radius=70,color=colorcyan,time=.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=90,color=colorcyan,time=((1000/1.6)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Lux' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1175,type=1,radius=90,color=colorcyan,time=((1175/1.2)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=3,radius=285,color=coloryellow,time=2.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=3340,type=1,radius=150,color=colorcyan,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Lulu' then -- Don't own this champ
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=925,type=1,radius=50,color=colorcyan,time=1,isline=true,px=0,py=0,pz=0,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Maokai' then -- Don't own this champ
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=600,type=1,radius=100,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Malzahar' then
				table.insert(skillshotArray,{name=ee.SpellNameW,shot=0,lastshot=0,skillshotpoint={},maxdistance=800,type=3,radius=250,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'MissFortune' then
				table.insert(skillshotArray,{name='MissFortuneScattershot',shot=0,lastshot=0,skillshotpoint={},maxdistance=800,type=3,radius=400,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Morgana' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1175,type=1,radius=80,color=colorcyan,time=((1175/1.2)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameW,shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=3,radius=295,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Nami' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=875,type=3,radius=210,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=2550,type=1,radius=350,color=colorcyan,time=3,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Nautilus' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=950,type=1,radius=100,color=colorcyan,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Nidalee' then
				table.insert(skillshotArray,{name='JavelinToss',shot=0,lastshot=0,skillshotpoint={},maxdistance=1500,type=1,radius=30,color=colorcyan,time=((1500/1.3)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Nocturne' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1200,type=1,radius=70,color=colorcyan,time=((1200/1.4)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Olaf' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=100,color=colorcyan,time=((1000/1.6)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Orianna' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=825,type=3,radius=150,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Quinn' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1025,type=1,radius=40,color=coloryellow,time=((1025/1.6)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Renekton' then
				table.insert(skillshotArray,{name='RenektonSliceAndDice',shot=0,lastshot=0,skillshotpoint={},maxdistance=450,type=1,radius=150,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='renektondice',shot=0,lastshot=0,skillshotpoint={},maxdistance=450,type=1,radius=150,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Rengar' then
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=80,color=coloryellow,time=((1000/1.5)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Rumble' then
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=850,type=1,radius=100,color=colorcyan,time=((850/2)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Sejuani' then
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1150,type=1,radius=125,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Sivir' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1075,type=1,radius=100,color=colorcyan,time=((1075/1.3)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Shen' then
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=600,type=1,radius=150,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Shyvana' then -- Don't own this champ
				table.insert(skillshotArray,{name='ShyvanaTransformLeap',shot=0,lastshot=0,skillshotpoint={},maxdistance=925,type=1,radius=150,color=colorcyan,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='ShyvanaFireballMissile',shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=150,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Skarner' then -- Don't own this champ
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=600,type=1,radius=100,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Sona' then
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=150,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Soraka' then
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=925,type=3,radius=290,color=coloryellow,time=2,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=950,type=3,radius=260,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Syndra' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=800,type=3,radius=150,color=colorcyan,time=2,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='syndrawcast',shot=0,lastshot=0,skillshotpoint={},maxdistance=950,type=3,radius=150,color=colorcyan,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Swain' then
				table.insert(skillshotArray,{name=ee.SpellNameW,shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=3,radius=265,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Thresh' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=1,radius=100,color=coloryellow,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=400,type=1,radius=300,color=coloryellow,time=0.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Tryndamere' then
				table.insert(skillshotArray,{name='Slash',shot=0,lastshot=0,skillshotpoint={},maxdistance=600,type=1,radius=100,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Tristana' then
				table.insert(skillshotArray,{name=ee.SpellNameW,shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=3,radius=200,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'TwistedFate' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1450,type=1,radius=80,color=colorcyan,time=5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Urgot' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=1,radius=80,color=colorcyan,time=0.8,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=950,type=3,radius=300,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Varus' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=1475,type=1,radius=50,color=coloryellow,time=1})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=1075,type=1,radius=125,color=colorcyan,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Veigar' then
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=3,radius=225,color=coloryellow,time=2,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameW,shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=3,radius=200,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Vi' then
				table.insert(skillshotArray,{name='ViQ',shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=1,radius=150,color=coloryellow,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Viktor' then
				--table.insert(skillshotArray,{name='ViktorDeathRay',shot=0,lastshot=0,skillshotpoint={},maxdistance=700,type=1,radius=150,color=coloryellow,time=2})
			end
			if ee.name == 'Velkoz' then
				table.insert(skillshotArray,{name='VelkozQ',shot=0,lastshot=0,skillshotpoint={},maxdistance=1050,type=1,radius=90,color=coloryellow,time=2,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='VelkozW',shot=0,lastshot=0,skillshotpoint={},maxdistance=1050,type=1,radius=130,color=coloryellow,time=2,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='VelkozE',shot=0,lastshot=0,skillshotpoint={},maxdistance=850,type=3,radius=200,color=coloryellow,time=1.2,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Xerath' then
				table.insert(skillshotArray,{name='xeratharcanopulse2',shot=0,lastshot=0,skillshotpoint={},maxdistance=1400,type=1,radius=100,color=colorcyan,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='XerathMageSpear',shot=0,lastshot=0,skillshotpoint={},maxdistance=1050,type=1,radius=80,color=colorcyan,time=((1050/1.4)+260)/1000,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='XeratharcaneBarrage2',shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=3,radius=260,color=coloryellow,time=1.5,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='xerathrmissilewrapper',shot=0,lastshot=0,skillshotpoint={},maxdistance=5600,type=3,radius=210,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Yasuo' then
				table.insert(skillshotArray,{name='yasuoq3',shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=1,radius=110,color=coloryellow,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Zac' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=550,type=1,radius=100,color=coloryellow,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1550,type=3,radius=200,color=colorcyan,time=2,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Zed' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=900,type=1,radius=100,color=coloryellow,time=1,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Ziggs' then
				table.insert(skillshotArray,{name='ZiggsQ',shot=0,lastshot=0,skillshotpoint={},maxdistance=850,type=1,radius=100,color=coloryellow,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='ZiggsW',shot=0,lastshot=0,skillshotpoint={},maxdistance=1000,type=3,radius=225,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name='ZiggsR',shot=0,lastshot=0,skillshotpoint={},maxdistance=5300,type=3,radius=550,color=coloryellow,time=3,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
			if ee.name == 'Zyra' then
				table.insert(skillshotArray,{name=ee.SpellNameQ,shot=0,lastshot=0,skillshotpoint={},maxdistance=800,type=3,radius=250,color=coloryellow,time=1,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameE,shot=0,lastshot=0,skillshotpoint={},maxdistance=1100,type=1,radius=100,color=colorcyan,time=1.5,isline=true,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
				table.insert(skillshotArray,{name=ee.SpellNameR,shot=0,lastshot=0,skillshotpoint={},maxdistance=700,type=3,radius=550,color=coloryellow,time=2,isline=false,p1x=0,p1y=0,p1z=0,p2x=0,p2y=0,p2z=0})
			end
		end
	end
end

SetTimerCallback('Main')