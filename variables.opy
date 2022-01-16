#!mainFile "main.opy"
globalvar Minions 5
globalvar LocationChange 6 #vect3(MinionID, x change, z change)
globalvar HealthChange 7 #(id, health change amt (+ = dmg, - = healing), damage dealer)
globalvar NonPlayer_Loc 8 #(id,x,z) minions are registered as 1,[team][2 digit id], structures are 2.[team][2 digit id] (e.g. 1.234, 2.124)
#...
#Structures
globalvar Structures 10 #id, health, blank
globalvar StructuresMP 11 #midpoint of structure (id,x,z)
globalvar StructuresWH 12 #width and height (id,w,h)
#Generic
globalvar ThreadClear 13 #is thread clear for damaging minions 
globalvar M_tTemp 14
globalvar M_DataTemp 15
globalvar MA_Temp 16 #Minions Array Temp
globalvar PA_Temp 17 #Player Array Temp
globalvar MR_Temp 18 #Minion ranges temp array
globalvar Temp_ID 19
#Minion Waves
globalvar MinionWaves 33
globalvar MinionRenders 34
#PrintLn
globalvar PrintText_Temp 36
globalvar PrintData_Temp 37
#...
globalvar DoT_In 39
#...
globalvar LocTemp_var 45
globalvar LocTemp_i 46

globalvar Ready 49
#50-80 Players

subroutine Minions_Main 6
subroutine Minions_Init 7
#subroutine HealthHandle 8
subroutine Minion_Wave 9
subroutine Minions_Move 10
subroutine PrintMinions 35


#Global variables

globalvar Team1 0
globalvar Team2 1
globalvar TeamSize 2
globalvar ScreenLimits 3
globalvar Characters 4
globalvar MinionQualities 20
globalvar MinionTypes 21
globalvar MWeapons 22
globalvar MinionTypesQualities 23
globalvar i 28
globalvar j 29
globalvar k 30
globalvar l 31
globalvar textcount 32
#--settings--#
globalvar Setting_CamSpeed 120

#Player variables

playervar Slot 0
playervar ControlledSlot 1
playervar CPos 2
playervar CamLoc 3
playervar CamAttach 4
playervar ControlledRef 5
playervar Alive 6
playervar CHero 7
playervar Owner 8
playervar MovementGroundCursor 10
playervar cursorNew 11
playervar cursor 12  
playervar eyeAxis 13
playervar UIContainer 17
playervar UIIstanceHandler 18
playervar UICursorStyles 19
playervar i 20
playervar Hidden 21
globalvar HeroSpecs 50

playervar TargetHandling 25
playervar Temp_DistanceSort 26


#Subroutine names

subroutine CameraSetup 0
subroutine UI_Process 1
subroutine UI_Setup 2
subroutine moveCameraWithPlayer 3
subroutine chaseCursorValues 4
subroutine OnHero 5 
subroutine Minions_Main 6
subroutine Minions_Init 7
subroutine HealthHandle 8
subroutine Minion_Wave 9
subroutine Minions_Move 10
subroutine PrintMinions 35