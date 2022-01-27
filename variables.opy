#!mainFile "main.opy"
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
#--settings--#
globalvar Setting_CamSpeed

#Player variables

playervar Slot
playervar ControlledSlot
playervar CPos
playervar CamLoc
playervar CamAttach
playervar ControlledRef
playervar Alive
playervar CHero
playervar Owner
playervar MovementGroundCursor
playervar cursorNew
playervar cursor
playervar eyeAxis
playervar UIContainer
playervar UIIstanceHandler
playervar UICursorStyles
playervar i
playervar Hidden
playervar Team #1 or 2
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