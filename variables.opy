#!mainFile "main.opy"

#stores variables, global macros and enums

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
#!define clamp(val,min_,max_) max((min_),min((val),(max_)))

enum CastMode:
    NULL,
    CONFIRM,
    QUICK,
    RELEASE
enum CastType:
    SELF,
    DIRECTION,
    GROUND,
    CURSOR,
    TARGET
enum TargetState:
    NONE,
    SELF,
    ALLY,
    ENEMY,
enum AbilityType:
    NORMAL,
    CHANNEL,
enum AbilityStage:
    NONE,
    PREP,
    MOVETO,
    CAST,
    COMPLETE,
enum Activation:
    NONE,
    M1 #TODO: good way to handle activation


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
globalvar CD_Buttons
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
playervar CD_i
playervar Actions
playervar ControlledSlot
playervar Level
playervar Health #current,max,[regen/dots,duration,rate], normalized
playervar Mana #current,max
playervar CPos
playervar MovetoPos
playervar Alive
playervar CHero
playervar CHero_Index
playervar Owner
playervar AbilityUse #passes vars to Ability_Used function
playervar ArrivedAtM2P
playervar Hidden
playervar Team #1 or 2 
playervar Target
playervar AbilityVerify #[waiting for ability verify, cancelled]
playervar Hero_Ability #casts ability from the perspective of the hero. e.g: ability1 is called with eventPlayer.ControlledRef as the event player with Ability Verify. It is then cast to the specific hero based on this variable
playervar HA_temp
playervar MoveAbilityCancel #cancel planned cast on move
playervar Ability_UI
playervar TargetHandling
playervar Temp_DistanceSort
playervar ClearAllUI
playervar UltCD
playervar DamageHandler
playervar TimerHandler 
playervar Disabled #[m1,m2,abilities[0]]
#Subroutine names

subroutine CameraSetup 
subroutine UI_Process 
subroutine UI_Setup 
subroutine moveCameraWithPlayer
subroutine teleportCamera
subroutine chaseCursorValues
subroutine CastConfirm 
subroutine OnHero 
subroutine Minions_Main
subroutine Minions_Init
subroutine HealthHandle
subroutine Minion_Wave 
subroutine Minions_Move 
subroutine Ready
subroutine PrintMinions
subroutine Left
subroutine defaultEffectUI
subroutine clearEffectUI
subroutine AbilityUsedFunc
subroutine AbilityProcess