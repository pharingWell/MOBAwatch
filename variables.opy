#!mainFile "main.opy"

#stores variables, global macros and enums

#!defineMember replace(value,i,array) (array).slice(0,(i)-1).concat((value)).concat((array).slice((i)+1,len((array))-1))
#!defineMember insert(value,i,array) (array).slice(0,(i)-1).concat((value)).concat((array).slice(i,len((array))-1))

#!define loopt if(RULE_CONDITION):\
    goto RULE_START
#!define loopf if(not RULE_CONDITION):\
    goto RULE_START
#!define top goto RULE_START
#!define println(a) enableInspector()\
    printLog(a)\
    disableInspector()
#!define clamp(val,min_,max_) max((min_),min((val),(max_)))
#!define waitUntil_verify(condition) /**/\
waitUntil((condition)==true,100)\
if(not (condition)):\
    printLog("waitUntil_TimedOut")\
    return
#!define distanceToTarget distance(eventPlayer.getPosition(), eventPlayer.Target[1].getPosition() if eventPlayer.Target[1] else vect(NonPlayer_Loc[NonPLoc(eventPlayer.Target[0])].y,0.5,NonPlayer_Loc[NonPLoc(eventPlayer.Target[0])].z))
#!define getLocation(a) /*type: id or playerref*/ a.getPosition() if(entityExists(a)) else NonPlayer_Loc[Minions_IDs.index(a)]
#!defineMember deal(target,rawdamage) eventPlayer.HealthQueue.append([[(target),(rawdamage)]]) /*input is target or id. if the input is an id, it is added to heath queue by the player dealing the damage*/\
ProcessHealthQueue()

#!defineMember damageInRadius(radius,positon,damagein,falloff) /**/\
    eventPlayer.Temp_DistanceSort=getPlayersInRadius((positon),(radius),getOppositeTeam(eventPlayer.getTeam()),LosCheck.OFF).concat([i for i in NonPlayer_Loc.slice((eventPlayer.ControlledRef.Team-1)*48,eventPlayer.ControlledRef.Team*48) if ((abs((positon).x-i.y))**2 + (abs((positon).z-i.z))**2 <= (radius))])\
    for eventPlayer.DamageHandler in range(len(eventPlayer.Temp_DistanceSort)):\
        deal(eventPlayer.Temp_DistanceSort[eventPlayer.DamageHandler],((damagein)-(falloff)*(distance(eventPlayer.getPosition(),getLocation(eventPlayer.Temp_DistanceSort[eventPlayer.DamageHandler]))/(radius))))\ 

#!define startDoT #
#DamageModifiers #defender armor[],defender dmgtakenmult[], attacker debuffs[], attacker buffs[]
#!define MinionHalfCount (24+1)
#!define MinionsPerWave 6
#must check before passing
#!define MinionSlotFromID(id) Minions_IDs.index(id)
#!define NonPLoc(id) NonPlayer_Loc[MinionSlotFromID(id)]
#!defineMember id y
#!define PlayerFromID(id) CPlayers[floor(id)-1][(id)%1*100]
#!define getHealthByID(id) PlayerFromID((id)).Health[0] if (id)<10 else Minions_HP[MinionSlotFromID(id)]

#!define startAction(a,ref) (ref).Actions=(a)+0.15 if eventPlayer.Hero_Ability[0]!=AbilityStage.CAST else (ref).Actions
#!define ifAction(a) @Condition eventPlayer.Actions==((a)+0.15) /*0.15 is used to differentiate 0 from null*/\
waitUntil_verify(eventPlayer.Actions==(a)+0.15 )\
smallMessage(localPlayer,"event {} trigged".format(a))


#!define endAbilityAction(a) /**/\
    if(eventPlayer.Actions==(a)+0.15):\
        waitUntil_verify(eventPlayer.Hero_Ability[0]!=AbilityStage.CAST)\
        eventPlayer.Actions=0\
    #print("Stopped")

# team = floor()%10, k = ()%1*100
#floor(id/10)
#floor(id) % 10
#id % floor(id)



globalvar CPlayers
globalvar Players
globalvar TeamSize
globalvar ScreenLimits
globalvar Characters
#...
#database
globalvar dbKeys
globalvar dbPRS
globalvar dbRPT
#...
#Structures
globalvar Structures #id, health, blank
globalvar StructuresMP #midpoint of structure (id,x,z)
globalvar StructuresWH #width and height (id,w,h)
#Temp
globalvar M_tTemp
globalvar Slot_Temp
globalvar MA_Temp #Minions Array Temp
globalvar PA_Temp #Player Array Temp
globalvar Temp_ID
globalvar PrintText_Temp
globalvar PrintData_Temp
globalvar LocTemp_var
globalvar LocTemp_i
globalvar Temp_Slot
#General variables
globalvar ThreadClear #is thread clear for damaging minions 
globalvar i
globalvar k_
globalvar j
globalvar l
#UI 
globalvar UIContainer
#...
globalvar DoT_In
#...
globalvar Ready
#Players
globalvar CD_Buttons
globalvar PlayerLeft_i
globalvar HeroSpecs
globalvar FunctionToggle #used for debugging for optimization

#Minion Array
globalvar MinionPool #Pool of initialized minions 
globalvar Minions_IDs #Key array for minions. Holds id at the given slot
globalvar Minions_Target #Stores target id
globalvar Minions_HP #health
globalvar Minions_Visibility #is set to the minion's team number per tick and then is incremented by 1 conditionally (if () elif () elif () elif ())
globalvar Minions_Distances #tbd
globalvar Minions_Info #Minion class [team (1-2),class,wave,count]
globalvar Minions_DLoc #location change. vect3(MinionID, x change, z change)
globalvar Minions_Render #[text id, entity id]
globalvar HealthChange #(id, health change amt (+ = dmg, - = healing), damage dealer id)
globalvar NonPlayer_Loc #(x,id,z) minions are registered as 1[team].[2 digit id], structures are 2[team].[2 digit id] (e.g. 12.34, 21.24)
#!define MinionClass_Names ["ι","Minion","ί","Mage","ϊ","Seige","ΐ","Brute"]
#!define MinionClass_Ranges [1,6,12,3]
#!define MinionClass_Damage [10,16,40,80]
#!define MinionClass_BaseHP [80,60,150,400]
#Minion Waves
globalvar MinionWaves #value 0 is total wave count
globalvar MinionCounts #[team 1 minions, team 2 minions]
#settings
globalvar mousetoggle
globalvar Setting_CamSpeed
globalvar Setting_Mode



#Player variables

playervar Slot #Controlled slot holds ID
playervar CamLoc #P
playervar CamAttach #P
playervar ControlledRef #P
playervar MovementGroundCursor #P
playervar Ready
playervar Hidden
playervar dbIndex
playervar cursorAngles
playervar cursor
playervar UIContainer #P
playervar UIIstanceHandler #P
playervar UICursorStyles #P
playervar CD_i
playervar Target_i
playervar DamageModifiers #defender armor[],defender dmgtakenmult[], attacker debuffs[], attacker buffs[]
playervar HealingModifiers #[healing mult]
playervar HealthQueue #list of health changes that are applied in chronological order, [health_change,source/id,is source?]
playervar Actions
playervar ControlledSlot
playervar Level
playervar Health #current,max,[regen/dots,duration,rate], [damager,healer]
playervar Resource #current,max
playervar CPos
playervar MovetoPos
playervar AttackMove #value that dictates whether to use overriding movement or attacking moving attacking moving movement, true if it has a value, false if its zero
playervar LookAtDir
playervar Alive
playervar CHero
playervar CHero_Index
playervar Owner
playervar AbilityUse #passes vars to Ability_Used function
playervar ArrivedAtM2P

playervar Team #1 or 2 
playervar Target #[vect(id,posx,posz),ref,[engage,pursue]]
playervar AbilityVerify #[waiting for ability verify, cancelled, button, abilitynum]
playervar Hero_Ability #casts ability from the perspective of the hero. e.g: ability1 is called with eventPlayer.ControlledRef as the event player with Ability Verify. It is then cast to the specific hero based on this variable
playervar HA_temp
playervar Ability_UI
playervar TargetHandling
playervar Temp_DistanceSort
playervar ClearAllUI
playervar UltCD
playervar DamageHandler
playervar TimerHandler
playervar Temp
playervar Disabled #[m1,m2,abilities[0]]
playervar Settings
enum PlayerSettings:
    NULL,
    CAMERA_NUDGE,

playervar HeroSpecificVar1
playervar HeroSpecificVar2

#Subroutine names
subroutine CameraSetup 
subroutine UI_Process 
subroutine UI_Setup 
subroutine moveCameraWithPlayer
subroutine teleportCamera
subroutine chaseCursorValues
subroutine CastConfirm
subroutine CancelCurrent
subroutine OnSpawn
subroutine OnHero 
subroutine Minions_Main
subroutine Minions_Init
subroutine Minions_Wave 
subroutine Minions_Move 
subroutine HealthHandle
subroutine Ready
subroutine PrintMinions
subroutine Left
subroutine ProcessHealthQueue
subroutine defaultEffectUI
subroutine clearEffectUI
subroutine AbilityTrigger
subroutine AbilityUse
subroutine StopThrottle
subroutine CalcDealt
subroutine Minion_setNullStats
subroutine Target_Func