#!mainFile "main.opy"

#stores variables, global macros and enums

#!define arreplace(value,i,array) (array).slice(0,(i)-1).concat((value)).concat((array).slice((i)+1,len((array))-1))
#!define insert(value,i,array) (array).slice(0,(i)-1).concat((value)).concat((array).slice(i,len((array))-1))

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
#!define waitUntil_verifyCustom(condition,time,error) /**/\
waitUntil((condition)==true,time)\
if(not (condition)):\
    print("{}{}".format("waitUntil_TimedOut: ",(error)))\
    return
#!define distanceToTarget distance(eventPlayer.getPosition(), eventPlayer.Target[1].getPosition() if eventPlayer.Target[1] else vect(Minions_Loc[MinionsLoc(eventPlayer.Target[0])].y,0.5,Minions_Loc[MinionsLoc(eventPlayer.Target[0])].z))
#!define getLocation(a) /*type: id or playerref*/ a.getPosition() if(entityExists(a)) else Minions_Loc[Minions_IDs.index(a)]
#!define deal(target,rawdamage) eventPlayer.HealthQueue = eventPlayer.HealthQueue.concat([[(target),(rawdamage)]]) /*input is target or id. if the input is an id, it is added to heath queue by the player dealing the damage*/\
ProcessHealthQueue()

#!define damageInRadius(radius,position,damagein,falloffAmt) /*.concat([i for i in Minions_Loc.slice((eventPlayer.ControlledRef.Team-1)*48,eventPlayer.ControlledRef.Team*48) if ((abs((positon).x-i.y))**2 + (abs((positon).z-i.z))**2 <= (radius))])*/\
    eventPlayer.Temp_DistanceSort=getPlayersInRadius((position),(radius),getOppositeTeam(eventPlayer.getTeam()),LosCheck.OFF)\
    for eventPlayer.DamageHandler in range(len(eventPlayer.Temp_DistanceSort)):\
        deal(eventPlayer.Temp_DistanceSort[eventPlayer.DamageHandler],(damagein)-(falloffAmt)*(distance((position)*vect(1,0,1),getLocation(eventPlayer.Temp_DistanceSort[eventPlayer.DamageHandler])*vect(1,0,1))/(radius)))

#!define startDoT #
#DamageModifiers #defender armor[],defender dmgtakenmult[], attacker debuffs[], attacker buffs[]
#!define MinionHalfCount (24+1)
#!define MinionsPerWave 6
#must check before passing
#!define MinionSlotFromID(id) Minions_IDs.index(id)
#!define MinionsLoc(id) Minions_Loc[MinionSlotFromID(id)]
#!defineMember id y
#!define PlayerFromID(id) CPlayers[floor(id)-1][(id)%1*100]
#!define getHealthByID(id) PlayerFromID((id)).Health[0] if (id)<10 else Minions_HP[MinionSlotFromID(id)]

##!define getIDNearPos(pos,team) 0 /*gets the nearest enemy or ally to the cursor. Will involve grid TODO*/





#!define arrToString7(arr) ("{},{},{},{},{},{}".format((arr)[0],(arr)[1],(arr)[2],(arr)[3],(arr)[4],(arr)[5],(arr)[6])).replace(",0",",_")

# team = floor()%10, k = ()%1*100
#floor(id/10)
#floor(id) % 10
#id % floor(id)

#!define Abil1_Bind eventPlayer.isHoldingButton(Button.ULTIMATE) /*Q*/
#!define Abil2_Bind eventPlayer.getThrottle().z>0.1 /*W*/
#!define Abil3_Bind eventPlayer.isHoldingButton(Button.ABILITY_2) /*E*/
#!define Abil4_Bind eventPlayer.isHoldingButton(Button.RELOAD) /*R*/

#!define Attack_Bind eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
#!define Move_Bind eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

#!define Attack_Bind eventPlayer.getThrottle().x<-0.1 /*A*/
#!define Stop_Bind eventPlayer.getThrottle().z<-0.1 /*S*/
#!define Item1_Bind eventPlayer.getThrottle().x>0.1 /*D*/
#!define Item2_Bind eventPlayer.isHoldingButton(Button.INTERACT) /*F*/

#!define Queue_Bind eventPlayer.isHoldingButton(Button.ABILITY_1) /*L Shift*/
#!define Talents_Bind eventPlayer.isHoldingButton(Button.CROUCH) /*Ctrl*/
#!define Camera_Bind eventPlayer.isHoldingButton(Button.JUMP) /*Space*/
#!define Mount_Bind eventPlayer.isHoldingButton(Button.MELEE) /*V*/ /*when channeled, causes you to hearth*/
#!define Settings_Bind (eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ABILITY_1)) /*Ctrl+F*/


globalvar CPlayers
globalvar Players
globalvar TeamSize
globalvar ScreenLimits
globalvar Characters
#...
globalvar Grid #Stores ids and locations for cheaper access of arrays (grid of squares)
globalvar GridStatic
globalvar GridTemp
#database
globalvar dbKeys
globalvar dbPRS
globalvar dbRPT
#...
#Structures
globalvar Structures_IDs
globalvar Structures_Active
globalvar Structures_Health
globalvar Structures_Loc
globalvar StructuresMP #midpoint of structure (id,x,z)
globalvar StructuresWH #width and height (id,w,h)
#Temp
globalvar Slot_Temp
globalvar Temp_ID
globalvar PrintText_Temp
globalvar Temp_Slot
#General variables
globalvar ThreadClear #is thread clear for damaging minions 
#UI 
globalvar UIContainer
#...
globalvar DoT_In
#...
globalvar Ready
#Players
globalvar CD_Buttons
globalvar HeroSpecs
globalvar FunctionToggle #used for debugging for optimization
#!define TICK_LENGTH 1
#Minion Array
globalvar MinionPool #Pool of initialized minions 
globalvar Minions_Active
globalvar Minions_IDs #Key array for minions. Holds id at the given slot
globalvar Minions_Target #Stores target id
globalvar Minions_HP #health
globalvar Minions_Visibility #is set to the minion's team number per tick and then is incremented by 1 conditionally (if () elif () elif () elif ())
globalvar Minions_Distances #tbd
globalvar Minions_Info #Minion class [team (1-2),class,wave,count]
globalvar Minions_DLoc #location change. vect3(MinionID, x change, z change)
globalvar HealthChange #(id, health change amt (+ = dmg, - = healing), damage dealer id)
globalvar Minions_Loc #(x,id,z) minions are registered as 1[team].[2 digit id], structures are 2[team].[2 digit id] (e.g. 12.34, 21.24)
#!define MinionClass_Names ["ι","Minion","ί","Mage","ϊ","Seige","ΐ","Brute"]
#!define MinionClass_Ranges [1,6,12,3]
#!define MinionClass_Damage [10,16,40,80]
#!define MinionClass_BaseHP [80,60,150,400]
#Minion Waves
globalvar MinionWaves #value 0 is total wave count
globalvar MinionCounts #[team 1 minions, team 2 minions]
#Projectiles
globalvar ProjectilePool
#!define PROJECTILE_POOLSIZE 48
globalvar Projectile_Active
globalvar ProjectileTemp
globalvar ProjectileTempID
globalvar Projectile_IDs
globalvar Projectile_Velocity #movement in one tick
globalvar Projectile_Accel #this may not be needed if accel is constant
globalvar Projectile_Position #for checks ofc
globalvar Projectile_Lifetime #used for projectiles that despawn
globalvar Projectile_Tile #which tile(s) the projectile is on
#settings
globalvar mousetoggle
globalvar Setting_CamSpeed
globalvar Setting_Mode
globalvar tickCt





globalvar Iter
#!define forGlobal(index,startval,max)/**/\
Iter[(index)] = startval\
while(Iter[(index)]<(max))
#!define forEndG(index) Iter[(index)]+=1
#Iter[forG]
enum forG:
    PLAYERNAME_SETUP,
    GRID_RENDERER,
    MINION_WAVEITER_TEAM,
    MINION_WAVEITER_TYPE,
    TEAMSETUP,
    MINIONSMOVE,
    MINIONSMOVEFLOOR,
    MINIONSINIT_TEAM,
    MINIONSINIT_TYPE,
    MINIONSINIT_SLOT,
    MINIONS_PRINTPOOL,

playervar Iter
#!define forPlayer(index,player,startval,max)/**/\
(player).Iter[(index)] = startval\
while((player).Iter[(index)]<(max))
#!define forEndP(index,player) (player).Iter[(index)]+=1\

#wait(0.016)
#eventPlayer.Iter[forP]
enum forP:
    EACHABILITYSTAGEUI,
    EACHABILITYSTAGEUIEFFECT,
    TARGET_ITER,
    COOLDOWNS,
    DBINDEX,
    RENDERUPDATE_TILES,
    RENDERUPDATE_ELEMENT,
    RENDERUPDATE_ARRAY,
    RENDERUPDATE_OBJECT,
    TILEADD_GRABFROMARRAY,
    TILEADD_TOADD,
    TILEADD_GRIDDARRAY_OBJ,
    TILEADD_RENDERRANGE_BOTTOM,
    TILEREMOVE,
    GRIDAUTO_UNINQUEADD,
    TILEAUTO


playervar Temp
#!define pTemp(enumvalue) eventPlayer.Temp[tempP.enumvalue] 
enum tempP:
    TILEOPERATION_ADD,
    TILEOPERATION_REMOVE,
    TILEOPERATION_OBJECT,
    RENDEROPERATION_OBJECTSWAP,
    TILEAUTO_QUEUE,
    TILEAUTO_ITER,
    TILEADD_GRIDDARRAY_OBJ,
    GENERIC_CAST_LOC,
    RUNACTION_ENSURE_TARGET,

#Player variables

playervar Slot #Controlled slot holds ID
playervar CamLoc #P
playervar CamAttach #P
playervar ControlledRef #P
playervar MovementGroundCursor #P
playervar Ready
playervar Hidden
playervar TilesTouched 
playervar TilesTouched_RenderRanges

#Personal Grid
playervar playerGrid
playervar updateCamera #boolean
#Render slots
playervar RenderIDs
playervar Render_Minions
#!define RENDERSIZE_MINIONS 48
playervar Render_Map
#!define RENDERSIZE_MAP RENDERSIZE_MINIONS+0
playervar Render_StaticTexts #includes position of text, as it doesnt need to be updated frquently
#!define RENDERSIZE_STEXTS RENDERSIZE_STEXTS+0
playervar Render_StaticEffects #includes position of effects, as they dont need to be updated [includes all walls]
#!define RENDERSIZE_SEFFECTS RENDERSIZE_STEXTS+0
playervar Render_CustProjectiles 
#!define RENDERSIZE_CUSTPROJ RENDERSIZE_SEFFECTS+0


# PStat structure:
# [HEALTH,RESOURCE,ARMOR,DEALMULT,MOVESPEED,BASIC_RANGE,BASIC_DAMAGE,ATTACKSPEED,[PStatAbil],[PStatAbil],[PStatAbil],[PStatAbil],[PStatAbil]]
playervar showStats #[true/false, ref]
playervar PlayerStats
enum PStat:
    NULL,
    HEALTH,
    RESOURCE,
    ARMOR,
    DEALMULT,
    MOVESPEED,
    BASIC_RANGE,
    BASIC_DAMAGE,
    ATTACKSPEED, /*multiplier of inital shots per second*/
    ABIL
enum PStatAbil:
    CASTMETHOD,
    RANGE,
    COST,
    COOLDOWN,
    MAXCHARGES,
    DAMAGE,
    DAMAGERATE,
    DURATION,
    ABILSPECIFICVAR 



playervar dbIndex

playervar cursorAngles
playervar cursor
playervar UIContainer #P
playervar UIIstanceHandler #P
playervar UICursorStyles #P
playervar DamageModifiers #defender armor[],defender dmgtakenmult[], attacker debuffs[], attacker buffs[]
playervar HealingModifiers #[healing mult]
playervar HealthQueue #list of health changes that are applied in chronological order, [health_change,source/id,is source?]
playervar Action
playervar ControlledSlot
playervar Level
playervar Health #current,[regen/dots,duration,rate], [damager,healer]
playervar Resource #current, charges
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
playervar SnapLook
playervar Team #1 or 2 
playervar Target #[vect(id,posx,posz),ref,[engage,pursue]]
playervar AbilityVerify #[waiting for ability verify, cancelled, button, abilitynum]
playervar Hero_Ability #casts ability from the perspective of the hero. e.g: ability1 is called with eventPlayer.ControlledRef as the event player with Ability Verify. It is then cast to the specific hero based on this variable
playervar Ability_UI
playervar TargetHandling
playervar Temp_DistanceSort
playervar ClearAllUI
playervar UltCD
playervar DamageHandler
playervar TimerHandler
playervar Disabled #[m1,m2,abilities[0]]
playervar Settings
enum PlayerSettings:
    NULL,
    CAMERA_NUDGE,

playervar HeroSpecificVar1
playervar HeroSpecificVar2

playervar clearQueue
playervar ActionQueue




#!define ifAction(a) @Condition eventPlayer.Action[ActionInfo.NUMBER] == (a)\
smallMessage(eventPlayer.Owner,"event {} trigged".format(a))
enum ActionInfo:
    #When an action is queued, the information needed to replicate it is stored
    #This enum is for the location in the ref.Action array
    #The data stored in each slot should be sufficient to trigger an replicate an ability
    #And adapt to the current state/location of the player
    NULL,
    NUMBER,
    MODE,
    TARGET,

#!define queueAction(a,ref,location, castmode) (ref).ActionQueue.append([[null,a,false,0.1,location,castmode]]) \
    smallMessage((ref),"___")

enum ActionQueueInfo:
    NULL,
    #such as 0 for move, 3 for abil1
    NUMBER, 
    #If this is a channel, anything being added with trigger ability interrupt
    ISCHANNEL, 
    #Ability minimum time (the ability will not cancel until it has gone on for this duration)
    ABILMINTIME,
    TARGET,
    MODE,


#The action queue is structured as such:
#0: Last Ability Time. This is updated with the current time when an action goes to slot 0. 
#                      It is used for AbilMinTime, the value here + the AbilMinTime is used for the wait

enum ActionQueueVal: #make sure to update the action queue initalizer in (Re)spawn of controlled.opy
    LASTABILTIME,
    I0 #index 0

enum AbilID:
    ABIL1=3,
    ABIL2,
    ABIL3,
    ABIL4

enum ResourceType:
    NONE,
    MANA,
    ENERGY
enum CastMethod:
    NULL,
    CONFIRM,
    QUICK,
    RELEASE
enum CastMode:
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
enum UseType:
    NORMAL,
    CHANNEL,
    CANCELABLE 
enum DamageType:
    UNKNOWN,
    PHYSICAL,
    MAGICAL 
enum AbilityStage:
    NONE,
    PREP,
    MOVETO,
    PRECAST,
    CAST,
    CANCELLED,
    COMPLETE,
enum Activation:
    NONE,
    M1 #TODO: good way to handle activation

    

enum HeroStat:
    BASE,
    LEVELRATE,
    BASIC,
    ABIL1,
    ABIL2,
    ABIL3,
    ABIL4

enum Base:
    HEALTH,
    RESOURCE,
    DMGMOD,

enum Base_Resource:
    TYPE,
    STARTING_AMT

enum Base_Dmgmod:
    ARMOR,
    TAKENMULT,
    DEALTMULT

enum Basic:
    RANGE,
    DAMAGE,
    SHOTSPERSEC,
    AUTOTARGET #Y/N

enum Abil:
    CAST,
    COST,
    USE,
    DMG

enum Abil_Cast:
    METHOD,
    MODE,
    TARGET,
    RANGE

enum Abil_Cost:
    COOLDOWN,
    RESOURCE,
    CHARGES,
    
enum Abil_Use:
    TYPE,
    DURATION,
    DELAY

enum Abil_Damage:
    AMOUNT,
    RATE
    

rule "Heroes_Init":                                            
        /*
        Ability Description:
        Cast: 
            Cast Mode dictates how and when the ability is cast, whether immediately after pressing the button, when releasing, or after an additional input to confirm
            Cast Type dictates either where the ability will be cast (towards the cursor, at the cursor, or on the ground) or who the ability can be cast on. Who is only used for abilities with targets
            These targets are defined by Target State
        Cost: 
            When using this ability, this value is checked in relation to the hero's given cost requirements. So far, this only means mana
        Use:
            This dictates how the ability acts, whether it is channeled, or if something else occurs, such as a delay before activating. Channel specifically means that it can be interrupted
        Damage:
            This shows how much damage the ability does with an optional rate per tick
        */

                        #range to end of ability, look off ground?, target needed (-1: nothing, 0: Player, 1:Minion, 2: Structure)
                        #[base hp,base mana,damage type, [basDamagee armor,damagedealtmult]],levelrate[hp,mana],basic atk[range,damage,shots per second,autotarget?],ability[ cast[cast mode, cast type, target, range] cost[cooldown,charges,mana] use[abilityType, duration, delay] damage[damage, rate]]
    HeroSpecs=[        #0                               1  2        3  0                               4  0                                                       5    6  0                                1    2                         3
    /*Reaper*/         [[250,[],DamageType.PHYSICAL,[0,1,1]],[],[2,30,2],[ [CastMethod.QUICK,CastMode.SELF],[3],[UseType.CANCELABLE] ],[ [CastMethod.CONFIRM,CastMode.GROUND,TargetState.NONE,10] ],[null],[  [CastMethod.RELEASE,CastMode.SELF],[null],[UseType.CHANNEL,3], [34,0.2]  ]], #
    /*Tracer*/         [[150,[],DamageType.PHYSICAL,[0,1,1]],[],[5,3,20,true],[ [CastMethod.QUICK,CastMode.DIRECTION] ],[ [CastMethod.QUICK,CastMode.SELF] ],[null],[ [CastMethod.RELEASE,CastMode.DIRECTION],[null],[UseType.NORMAL], [350,1] ] ], #tracer's ult is thrown where she is looking, so ground is the closest target
    /*Mercy*/          [],/*[[200,100,DType.MAGICAL,[0,1,1]],[],[10,12,5],[[]],[[]],[[]],[["By PharingWell"]]],/*
    /*Hanzo*/          [],
    /*Torbjörn*/       [],
    /*Reinhardt*/      [],
    /*Pharah*/         [[200,[ResourceType.ENERGY,1],0,[0,1,1]],[],[6,40,1],[ [CastMethod.QUICK,CastMode.SELF],  ],/*projectile*/],
    /*Winston*/        [],
    /*Widowmaker*/     [],
    /*Bastion*/        [],
    /*Symmetra*/       [],
    /*Zenyatta*/       [],
    /*Genji*/          [],
    /*Roadhog*/        [],
    /*Cassidy*/        [],
    /*Junkrat*/        [],
    /*Zarya*/          [],
    /*Soldier: 76*/    [],
    /*Lúcio*/          [],
    /*D.Va*/           [],
    /*Mei*/            [],
    /*Sombra*/         [],
    /*Doomfist*/       [],
    /*Ana*/            [],
    /*Orisa*/          [],
    /*Brigitte*/       [],
    /*Moira*/          [],
    /*Wrecking Ball*/  [],
    /*Ashe*/           [],
    /*Echo*/           [],
    /*Baptiste*/       [],
    /*Sigma*/          [],
    ]
enum Heroes:
    REAPER,        
    TRACER,        
    MERCY,         
    HANZO,         
    TORBJORN,      
    REINHARDT,     
    PHARAH,        
    WINSTON,       
    WIDOWMAKER,    
    BASTION,       
    SYMMETRA,      
    ZENYATTA,      
    GENJI,         
    ROADHOG,       
    CASSIDY,       
    JUNKRAT,       
    ZARYA,         
    SOLDIER76,   
    LUCIO,         
    DVA,          
    MEI,           
    SOMBRA,        
    DOOMFIST,      
    ANA,           
    ORISA,         
    BRIGITTE,      
    MOIRA,         
    WRECKING BALL, 
    ASHE,          
    ECHO,          
    BAPTISTE,      
    SIGMA

#Subroutine names
subroutine TileReset 
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
subroutine ReleaseToProjPool
subroutine AddTile
subroutine RemoveTile
subroutine MoveToRender
subroutine AddToRender
subroutine RemoveFromRender
subroutine CancelAction
subroutine ChaseTarget
