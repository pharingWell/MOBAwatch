#!mainFile "main.opy"

#!defineMember replace(value,i,array) (array).slice(0,(i)-1).concat(value).concat((array).slice((i)+1,len(array)-1))
#!defineMember insert(value,i,array) (array).slice(0,(i)-1).concat(value).concat((array).slice(i,len(array)-1))

#!define loopt if(RULE_CONDITION):\
    goto RULE_START
#!define loopf if(not RULE_CONDITION):\
    goto RULE_START
#!define top goto RULE_START
#!define println(a) enableInspector()\
    printLog(a)\
    #disableInspector()


#!define attachControlled createDummy(eventPlayer.CHero, eventPlayer.getTeam(), TeamSize+eventPlayer.Slot, vect(0,0,0),vect(0,0,0))\
    CPlayers[eventPlayer.Team-1]=insert(getLastCreatedEntity(),eventPlayer.Slot,CPlayers[eventPlayer.Team-1])\
    eventPlayer.ControlledRef=CPlayers[eventPlayer.Team-1][eventPlayer.Slot]\
    eventPlayer.ControlledRef.startForcingPosition(vect(0,100,0),true)\
    eventPlayer.ControlledRef.stopForcingPosition()\
    eventPlayer.startForcingPosition(vect(eventPlayer.ControlledRef.getPosition().x,-10,eventPlayer.ControlledRef.getPosition().z),true)\
    eventPlayer.ControlledRef.Owner = eventPlayer\
    #eventPlayer.ControlledRef.startForcingName(eventPlayer)\
    eventPlayer.startForcingHero(eventPlayer.CHero)\






globalvar CPlayers
globalvar Players
globalvar TeamSize
globalvar ScreenLimits
globalvar Characters
globalvar Minions
globalvar LocationChange #vect3(MinionID, x change, z change)
globalvar HealthChange #(id, health change amt (+ = dmg, - = healing), damage dealer)
globalvar NonPlayer_Loc #(id,x,z) minions are registered as 1,[team][2 digit id], structures are 2.[team][2 digit id] (e.g. 1.234, 2.124)
#...
#Structures
globalvar Structures #id, health, blank
globalvar StructuresMP #midpoint of structure (id,x,z)
globalvar StructuresWH #width and height (id,w,h)
#Minions
globalvar M_tTemp
globalvar M_DataTemp
globalvar MA_Temp #Minions Array Temp
globalvar PA_Temp #Player Array Temp
globalvar MR_Temp #Minion ranges temp array
globalvar Temp_ID
globalvar MinionQualities
globalvar MinionTypes
globalvar MWeapons
globalvar MinionTypesQualities
#Minion Waves
globalvar MinionWaves
globalvar MinionRenders
#General variables
globalvar ThreadClear #is thread clear for damaging minions 
globalvar i
globalvar j
globalvar k
globalvar l
#PrintLn
globalvar PrintText_Temp
globalvar PrintData_Temp
#UI 
globalvar UIContainer
#...
globalvar DoT_In
#...
globalvar LocTemp_var
globalvar LocTemp_i

globalvar Ready
#Players
globalvar PlayerLeft_i
globalvar HeroSpecs



#settings

globalvar Setting_CamSpeed
globalvar Setting_Mode



#Player variables

playervar Slot #P
playervar CamLoc #P
playervar CamAttach #P
playervar ControlledRef #P
playervar MovementGroundCursor #P
playervar cursorNew #P
playervar cursor #P
playervar eyeAxis #P
playervar UIContainer #P
playervar UIIstanceHandler #P
playervar UICursorStyles #P

playervar Actions
playervar ControlledSlot
playervar CPos
playervar Alive
playervar CHero
playervar Owner
playervar i
playervar Hidden
playervar Team #1 or 2 
playervar Target
#playervar 
playervar TargetHandling
playervar Temp_DistanceSort


#Subroutine names

subroutine CameraSetup 
subroutine UI_Process 
subroutine UI_Setup 
subroutine moveCameraWithPlayer 
subroutine chaseCursorValues 
subroutine OnHero 
subroutine Minions_Main
subroutine Minions_Init
subroutine HealthHandle
subroutine Minion_Wave 
subroutine Minions_Move 
subroutine Ready
subroutine PrintMinions
subroutine Left

