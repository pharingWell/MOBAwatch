#!mainFile "../main.opy"

#This file is used for things regarding any hero and the player's input

#!define Ability(button,cost) eventPlayer.AbilityUse[0]=button\
AbilityProcess()

#!define addUI(UI_id,DestroyAt) eventPlayer.Ability_UI[DestroyAt]=eventPlayer.Ability_UI[DestroyAt].concat(UI_id)
#!define AreaHighlight(effect,radius) createEffect(eventPlayer.Owner,effect,Color.GREEN,updateEveryTick(eventPlayer.Owner.cursor),(radius),EffectReeval.VISIBILITY_POSITION_AND_RADIUS)\
addUI(getLastCreatedEntity(),AbilityStage.MOVETO)
#!defineMember damageInRadius(radius,positon,damagein) /**/\
    eventPlayer.Temp_DistanceSort=getPlayersInRadius((positon),(radius),getOppositeTeam(eventPlayer.getTeam()),LosCheck.OFF)\
    for eventPlayer.DamageHandler in range(len(eventPlayer.Temp_DistanceSort)):\
        damage(eventPlayer.Temp_DistanceSort[eventPlayer.DamageHandler],eventPlayer.Owner,(damagein))\
    eventPlayer.Temp_DistanceSort=[i for i in NonPlayer_Loc.slice((eventPlayer.ControlledRef.Team-1)*48,eventPlayer.ControlledRef.Team*48) if ((abs((positon).x-i.y))**2 + (abs((positon).z-i.z))**2 <= (radius))]\
    for eventPlayer.DamageHandler in range(len(eventPlayer.Temp_DistanceSort)):\
        HealthChange.append([eventPlayer.Temp_DistanceSort[eventPlayer.DamageHandler].x,(damagein),eventPlayer])

#!define startDoT #
#!include "heroes/reaper.opy"
#!include "heroes/tracer.opy"



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
                        #[base hp,base mana,damage type, [base armor,dmgtakenmult,damagedealtmult]],levelrate[[hp,mana],basic atk[range,damage,shots per second,autotarget?],ability[ cast[cast mode, cast type, target, range] cost[mana] use[channel, duration, delay] damage[damage, rate]]
    HeroSpecs=[        #0                                1  2        3  0                               4  0                                                       5    6  0                                1    2                         3
    /*Reaper*/         [[250,0,DType.PHYSICAL,[0,1,1]],[],[2,30,2],[ [CastMode.QUICK,CastType.SELF] ],[ [CastMode.CONFIRM,CastType.GROUND,TargetState.NONE,10] ],null,[  [CastMode.RELEASE,CastType.SELF],null,[AbilityType.CHANNEL,3], [2.4,0.016]  ]], #
    /*Tracer*/         [[150,0,DType.PHYSICAL,[0,1,1]],[],[5,3,20,true],[ [CastMode.QUICK,CastType.DIRECTION] ],[ [CastMode.QUICK,CastType.SELF] ],null,[ [CastMode.RELEASE,CastType.DIRECTION],null,[AbilityType.NORMAL] ] ], #tracer's ult is thrown where she is looking, so ground is the closest target
    /*Mercy*/          /*[[200,100,DType.MAGICAL,[0,1,1]],[],[10,12,5],[[]],[[]],[[]],[["By PharingWell"]]],/*
    /*Hanzo*/          [],
    /*Torbjörn*/       [],
    /*Reinhardt*/      [],
    /*Pharah*/         [],
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

#!define attachControlled \
    createDummy(eventPlayer.CHero, eventPlayer.getTeam(), TeamSize+eventPlayer.Slot, vect(0,0,0),vect(0,0,0))\
    CPlayers[eventPlayer.Team-1]=insert(getLastCreatedEntity(),eventPlayer.Slot,CPlayers[eventPlayer.Team-1])\
    eventPlayer.ControlledRef=CPlayers[eventPlayer.Team-1][eventPlayer.Slot]\
    eventPlayer.ControlledRef.startForcingPosition(vect(0,100,0),true)\
    eventPlayer.ControlledRef.stopForcingPosition()\
    eventPlayer.ControlledRef.Owner = eventPlayer\
    eventPlayer.ControlledRef.startForcingName("{}".format(eventPlayer))\
    eventPlayer.startForcingName("{}".format("_--_"))\
    eventPlayer.ControlledRef.CHero=eventPlayer.CHero\
    eventPlayer.ControlledRef.setDamageDealt(0)\
    eventPlayer.ControlledRef.setDamageReceived(0)\
    eventPlayer.setDamageReceived(0)\
    eventPlayer.ControlledRef.Slot=(eventPlayer.Team)+eventPlayer.Slot/100\
    
rule "On Game Enter":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition not eventPlayer.hasSpawned()
    eventPlayer.setAllowedHeroes([elem for elem, index in getAllHeroes() if HeroSpecs[index][0]])

rule "Check Hero Change":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    eventPlayer.startFacing(vect(0,0,1),100000,Relativity.TO_WORLD,FacingReeval.NONE)
    OnSpawn()

def OnSpawn():
    print(eventPlayer.ControlledRef.AttackMove)
    eventPlayer.disableScoreboard()
    eventPlayer.CHero = eventPlayer.getCurrentHero()
    if(eventPlayer.Team!=0): #catches team switch as team should be zero right now
        startAction(8,eventPlayer.ControlledRef)
    if(eventPlayer.getTeam()==Team.1):
        eventPlayer.Team=1
    else:
        eventPlayer.Team=2
    eventPlayer.Slot=eventPlayer.getSlot()
    Players[eventPlayer.Team-1]=replace(eventPlayer,eventPlayer.Slot,Players[eventPlayer.Team-1])
    attachControlled
    eventPlayer.startForcingHero(eventPlayer.ControlledRef.CHero)
    wait()
    CameraSetup()
    OnHero()
    wait()
    UI_Setup()
    waitUntil(eventPlayer.ControlledRef.hasSpawned()==true,1000)
    wait()
    eventPlayer.CamAttach=true
    moveCameraWithPlayer()
    wait()
    
    async(UI_Process,AsyncBehavior.NOOP)
    eventPlayer.enableScoreboard()
    if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][2][3]):
        createEffect(eventPlayer if eventPlayer.ControlledRef.Target else null,Effect.RING,Color.BLUE,vect(NonPlayer_Loc[NonPLoc(eventPlayer.ControlledRef.Target[0].x)].y,0,NonPlayer_Loc[NonPLoc(eventPlayer.ControlledRef.Target[0].x)].z) if (eventPlayer.ControlledRef.Target[0].x and not eventPlayer.ControlledRef.Target[1]) else eventPlayer.ControlledRef.Target[1].getPosition(),eventPlayer.ControlledRef.Target[1]*0.5+1.2,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.stopFacing()
    eventPlayer.Ready=true

def OnHero():
    #Replace their UI with in-game progress bar
    eventPlayer.disallowButton(Button.ULTIMATE)

rule "Controlled Died":
    @Event eachPlayer
    @Condition Ready==true
    @Condition not eventPlayer.isDummy()
    @Condition not eventPlayer.ControlledRef.isAlive()
    eventPlayer.ClearAllUI=true
    clearEffectUI()
    eventPlayer.disableHeroHUD()
    eventPlayer().UIContainer=[Color.GRAY,null]
    eventPlayer.MovementGroundCursor=false
    wait(1)
    eventPlayer.MovementGroundCursor=false

rule "Controlled Spawned":
    @Event eachPlayer
    @Condition Ready==true
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.ControlledRef.isAlive()
    createEffect(eventPlayer if eventPlayer.ControlledRef.isInViewAngle(eventPlayer.ControlledRef.CPos,90) else null,Effect.SPHERE,Color.WHITE,eventPlayer.ControlledRef,0.25,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    if(eventPlayer.CamAttach):
        chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z),duration=1,ChaseReeval.DESTINATION_AND_DURATION)
    eventPlayer.enableHeroHud()
    if(eventPlayer.getTeam()==Team.1):
        eventPlayer().UIContainer=[Color.TEAM_1,Color.TEAM_1]
    else:
        eventPlayer().UIContainer=[Color.TEAM_2,Color.TEAM_2]
    wait(0.5)
    moveCameraWithPlayer()
    
rule "Move To":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition not eventPlayer.isDummy()
    @Condition distance(vect(eventPlayer.ControlledRef.getPosition().x,0,eventPlayer.ControlledRef.getPosition().z),eventPlayer.cursor)>1
    eventPlayer.ControlledRef.AttackMove=0
    if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][2][3]):
        eventPlayer.ControlledRef.Target=null
    eventPlayer.ControlledRef.MovetoPos =  eventPlayer.cursor
    startAction(0,eventPlayer.ControlledRef)
    eventPlayer.MovementGroundCursor = true
    waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE),0.5)
    while(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)):
        eventPlayer.MovementGroundCursor = false
        eventPlayer.ControlledRef.MovetoPos = eventPlayer.cursor
        startAction(1,eventPlayer.ControlledRef)
        if(getTotalTimeElapsed()%2<0.5):
            startAction(0,eventPlayer.ControlledRef)
        waitUntil(not(eventPlayer.isUsingAbility1() or eventPlayer.isUsingAbility2() or eventPlayer.isUsingUltimate())==true,1)
        wait(0.128)
    eventPlayer.MovementGroundCursor = true

rule "Set Target to Cursor/Ability Verify":
    @Event eachPlayer
    @Condition Ready==true
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) #**2 **2
    eventPlayer.ControlledRef.AttackMove=null
    eventPlayer.CPos = eventPlayer.cursor
    if(eventPlayer.AbilityVerify[0]):
        eventPlayer.AbilityVerify=[false,false,null]
    else:
        eventPlayer.Target=null
        eventPlayer.TargetHandling=[eventPlayer.cursor,-1.25] #negative value indicates that we move player to the position selected first
        Target()
        if(eventPlayer.Target[0]):
            eventPlayer.ControlledRef.Target=eventPlayer.Target
            eventPlayer.UICursorStyles[0]=Color.RED
            wait(0.1)
            eventPlayer.UICursorStyles[0]=Color.WHITE
            eventPlayer.ControlledRef.Target[2]=[true,not HeroSpecs[eventPlayer.ControlledRef.CHero_Index][2][3]]
            startAction(2,eventPlayer.ControlledRef)
        elif(eventPlayer.AttackMove):
            eventPlayer.UICursorStyles[0]=rgb(238,148,148)
            wait(0.1)
            eventPlayer.UICursorStyles[0]=Color.WHITE
            eventPlayer.ControlledRef.AttackMove=eventPlayer.AttackMove #Convert target return data to controlled ref data
            eventPlayer.AttackMove=0 #clear self data
            eventPlayer.ControlledRef.MovetoPos=eventPlayer.ControlledRef.AttackMove
            eventPlayer.MovementGroundCursor=true
            startAction(0,eventPlayer.ControlledRef)

#!define cast(abilityplus2,button) /*as owner, this is used to handle inputs that we dont want the ai to have to deal with while automating*/\
    if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilityplus2]):/*if exists*/\
        if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilityplus2][0][0]==CastMode.QUICK):\
            startAction(abilityplus2,eventPlayer.ControlledRef)\
        elif(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilityplus2][0][0]==CastMode.RELEASE):\
            eventPlayer.ControlledRef.Hero_Ability=[AbilityStage.PREP,abilityplus2-2,0]\
            waitUntil(eventPlayer.isHoldingButton(button)==false,99)\
            startAction(abilityplus2,eventPlayer.ControlledRef)\
        elif(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilityplus2][0][0]==CastMode.CONFIRM):\
            eventPlayer.ControlledRef.Hero_Ability=[AbilityStage.PREP,abilityplus2-2,0]\
            eventPlayer.AbilityVerify[2]=(button)\
            eventPlayer.AbilityVerify[3]=abilityplus2\
            async(CastConfirm,AsyncBehavior.RESTART)\
        else:\
            eventPlayer.CPos=eventPlayer.cursor\
            startAction(abilityplus2,eventPlayer.ControlledRef)\


rule "Use Ability":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isHoldingButton(Button.ABILITY_2) or eventPlayer.isHoldingButton(Button.RELOAD) or eventPlayer.isHoldingButton(Button.ULTIMATE)
    if(eventPlayer.AbilityVerify[0]):
        eventPlayer.AbilityVerify=[false,true,null]
    if(eventPlayer.isHoldingButton(Button.ABILITY_1)):
        cast(3,Button.ABILITY_1)
    elif(eventPlayer.isHoldingButton(Button.ABILITY_2)):
        cast(4,Button.ABILITY_2)
    elif(eventPlayer.isHoldingButton(Button.RELOAD)):
        cast(5,Button.RELOAD)
    elif(eventPlayer.isHoldingButton(Button.ULTIMATE)):
        cast(6,Button.ULTIMATE)

def CastConfirm():
    #this has to be async because of the waitUntil
    eventPlayer.AbilityVerify[0]=true
    eventPlayer.AbilityVerify[1]=true
    waitUntil(eventPlayer.AbilityVerify[0]==false,15)
    clearEffectUI()
    if(not eventPlayer.AbilityVerify[1]):
        eventPlayer.ControlledRef.CPos=eventPlayer.cursor
        startAction(eventPlayer.AbilityVerify[3],eventPlayer.ControlledRef)
        eventPlayer.AbilityVerify=[]
    else:
        eventPlayer.AbilityVerify=[]
        return /*ability cast cancelled*/



def defaultEffectUI():
    if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.Hero_Ability[1]+2] and eventPlayer.Hero_Ability[1]!=0): #does referenced ability number even exist
        if(HeroSpecs[eventPlayer.CHero_Index][evalOnce(eventPlayer.Hero_Ability[1])+2][0][3]>0):
            createEffect(eventPlayer.Owner,Effect.RING,Color.YELLOW,updateEveryTick(vect(eventPlayer.getEyePosition().x,0,eventPlayer.getEyePosition().z)), HeroSpecs[eventPlayer.CHero_Index][evalOnce(eventPlayer.Hero_Ability[1])+2][0][3], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            addUI(getLastCreatedEntity(),AbilityStage.MOVETO)

def clearEffectUI():
    if(eventPlayer.ClearAllUI):
        eventPlayer.ClearAllUI=false
        for eventPlayer.ArrivedAtM2P in range(len(eventPlayer.Ability_UI)):
            for eventPlayer.HA_temp in range(len(eventPlayer.Ability_UI[eventPlayer.ArrivedAtM2P])):
                destroyEffect(eventPlayer.Ability_UI[eventPlayer.ArrivedAtM2P][eventPlayer.HA_temp])
        eventPlayer.Ability_UI[evalOnce(eventPlayer.Hero_Ability[0])]=[]
    else:
        for eventPlayer.HA_temp in range(len(eventPlayer.Ability_UI[evalOnce(eventPlayer.Hero_Ability[0])])):
            destroyEffect(eventPlayer.Ability_UI[evalOnce(eventPlayer.Hero_Ability[0])][eventPlayer.HA_temp])
        eventPlayer.Ability_UI[evalOnce(eventPlayer.Hero_Ability[0])]=[] 