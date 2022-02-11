#!mainFile "../main.opy"

#This file is used for things regarding any hero and the player's input

#!define Ability(button,activate) /*[activate?,activatebutton]*/\
eventPlayer.forceButtonPress(button)\
if(activate[0]):\
    wait()\
    if(len(activate)>1):\
        eventPlayer.forceButtonPress(activate[1])\
    else:\
        eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
#!define addUI(UI_id,DestroyAt) eventPlayer.Ability_UI[DestroyAt]=eventPlayer.Ability_UI[DestroyAt].concat(UI_id)
#!define AreaHighlight(effect,radius) createEffect(eventPlayer.Owner,effect,Color.GREEN,updateEveryTick(eventPlayer.Owner.cursor),(radius),EffectReeval.VISIBILITY_POSITION_AND_RADIUS)\
addUI(getLastCreatedEntity(),AbilityState.MOVETO)


#!include "heroes/reaper.opy"
#!include "heroes/tracer.opy"



rule "Heroes_Init":                                            #range to end of ability, look off ground?, target needed (-1: nothing, 0: Player, 1:Minion, 2: Structure)
    #[hp,mana],other,basic atk[range,dmg],ability[cast mode, cast type, [optional] range, [optional] target], 
    

    HeroSpecs=[
    /*Reaper*/         [[250,-1],"other",[2,30],[CastMode.QUICK,CastType.SELF,TargetState.NONE],[CastMode.CONFIRM,CastType.GROUND,TargetState.NONE,10],null,[CastMode.RELEASE,CastType.SELF,TargetState.NONE]], #
    /*Tracer*/         [[150,100],"other",[8,8],[CastMode.QUICK,CastType.DIRECTION,TargetState.NONE],[CastMode.QUICK,CastType.SELF,TargetState.NONE],null,[CastMode.RELEASE,CastType.DIRECTION,TargetState.NONE]], #tracer's ult is thrown where she is looking, so ground is the closest target
    /*Mercy*/          [],
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
#!define attachControlled createDummy(eventPlayer.CHero, eventPlayer.getTeam(), TeamSize+eventPlayer.Slot, vect(0,0,0),vect(0,0,0))\
    CPlayers[eventPlayer.Team-1]=insert(getLastCreatedEntity(),eventPlayer.Slot,CPlayers[eventPlayer.Team-1])\
    eventPlayer.ControlledRef=CPlayers[eventPlayer.Team-1][eventPlayer.Slot]\
    eventPlayer.ControlledRef.startForcingPosition(vect(0,100,0),true)\
    eventPlayer.ControlledRef.stopForcingPosition()\
    eventPlayer.startForcingPosition(vect(eventPlayer.ControlledRef.getPosition().x,-10,eventPlayer.ControlledRef.getPosition().z),true)\
    eventPlayer.ControlledRef.Owner = eventPlayer\
    eventPlayer.ControlledRef.startForcingName(eventPlayer)\
    eventPlayer.ControlledRef.CHero=eventPlayer.CHero\
    eventPlayer.ControlledRef.CHero_Index=getAllHeroes().index(eventPlayer.ControlledRef.CHero)\
    eventPlayer.ControlledRef.startForcingHero(eventPlayer.ControlledRef.CHero)\

rule "Check Hero Change":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    eventPlayer.disableScoreboard()
    eventPlayer.CHero = eventPlayer.getCurrentHero()
    wait(0.1)
    ###INIT BOT###
    if(eventPlayer.getCurrentHero()!=eventPlayer.CHero and Ready):
        if(eventPlayer.getTeam()==Team.1):
            eventPlayer.Team=1
            eventPlayer().UIContainer=[Color.BLUE]
        else:
            eventPlayer.Team=2
            eventPlayer().UIContainer=[Color.RED]
        eventPlayer.Slot=eventPlayer.getSlot()
        Players[eventPlayer.Team-1]=replace(eventPlayer,eventPlayer.Slot,Players[eventPlayer.Team-1])
        if(eventPlayer.ControlledRef.CHero==0):
            eventPlayer.CHero=eventPlayer.getCurrentHero()
        else:
            eventPlayer.startForcingHero(eventPlayer.ControlledRef.CHero)
        attachControlled
        CameraSetup()
        OnHero()
        UI_Setup()
        async(UI_Process,AsyncBehavior.NOOP)
        waitUntil(eventPlayer.cursor!=vect(0,0.01,0),1000)
        wait(0.5)
        eventPlayer.CamAttach=true
        moveCameraWithPlayer()
        eventPlayer.enableScoreboard()
    else:
        top


def OnHero():
    if(eventPlayer.CHero not in [Hero.MOIRA,Hero.BRIGITTE,Hero.WIDOWMAKER,Hero.TORBJORN]): #Replace their UI with in-game progress bar
        eventPlayer.disallowButton(Button.ULTIMATE)
    

rule "Target":
    @Event eachPlayer
    @Condition Ready==true
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) #**2 **2
    eventPlayer.CPos = eventPlayer.cursor
    if(eventPlayer.AbilityVerify[0]):
        eventPlayer.AbilityVerify[0]=false
        eventPlayer.AbilityVerify[1]=false
    else:
        for i in range(TeamSize):
            if(i==0):
                    eventPlayer.Temp_DistanceSort=vect(eventPlayer.ControlledRef.Team,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().x,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().z)
            else:
                eventPlayer.Temp_DistanceSort.append(vect(eventPlayer.ControlledRef.Team,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().x,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().z))
        eventPlayer.Temp_DistanceSort=sorted(random.shuffle(NonPlayer_Loc.slice((eventPlayer.ControlledRef.Team-1)*48,eventPlayer.ControlledRef.Team*48).concat(eventPlayer.Temp_DistanceSort)), lambda i: (abs(eventPlayer.cursor.x-i.y))**2 + (abs(eventPlayer.cursor.z-i.z))**2)
        #sorted([vect((eventPlayer.cursor.x-i.y)**2 + (eventPlayer.cursor.z-i.z)**2,i.x,0) for i in random.shuffle(NonPlayer_Loc)], lambda elem: elem.x)
        if((abs(eventPlayer.cursor.x-eventPlayer.Temp_DistanceSort[0].y))**2 + (abs(eventPlayer.cursor.z-eventPlayer.Temp_DistanceSort[0].z))**2<0.866):
            eventPlayer.ControlledRef.Target=eventPlayer.Temp_DistanceSort[0]
            startAction(1,eventPlayer.ControlledRef)
            println("{0}, {1}".format(eventPlayer.Temp_DistanceSort[0],eventPlayer.cursor))
            eventPlayer.UICursorStyles[0]=Color.RED
            wait(0.1)
            eventPlayer.UICursorStyles[0]=Color.WHITE

#!define cast(abilityplus2,button) /*as owner, this is used to handle inputs that we dont want the ai to have to deal with while automating*/\
    if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilityplus2]):/*if exists*/\
        if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilityplus2][0]==CastMode.QUICK):\
            startAction(abilityplus2,eventPlayer.ControlledRef)\
        elif(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilityplus2][0]==CastMode.RELEASE):\
            eventPlayer.ControlledRef.Hero_Ability=[AbilityState.PREP,abilityplus2-2,0]\
            waitUntil(eventPlayer.isHoldingButton(button)==false,99)\
            startAction(abilityplus2,eventPlayer.ControlledRef)\
        elif(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilityplus2][0]==CastMode.CONFIRM):\
            eventPlayer.ControlledRef.Hero_Ability=[AbilityState.PREP,abilityplus2-2,0]\
            eventPlayer.AbilityVerify[2]=(button)\
            eventPlayer.AbilityVerify[3]=abilityplus2\
            async(AbilityConfirm,AsyncBehavior.RESTART)\
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

def AbilityConfirm():
    #this has to be async because of the waitUntil
    eventPlayer.AbilityVerify[0]=true
    eventPlayer.AbilityVerify[1]=true
    waitUntil(eventPlayer.AbilityVerify[0]==false,15)
    destroyEffect(eventPlayer.ControlledRef.Hero_Ability[0][1])
    if(not eventPlayer.AbilityVerify[1]):
        eventPlayer.ControlledRef.CPos=eventPlayer.cursor
        startAction(eventPlayer.AbilityVerify[3],eventPlayer.ControlledRef)
        eventPlayer.AbilityVerify=[]
    else:
        eventPlayer.AbilityVerify=[]
        return /*ability cast cancelled*/


def defaultEffectUI():
    if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.Hero_Ability[1]+2]!=[]): #does referenced ability number even exist
        if(HeroSpecs[eventPlayer.CHero_Index][evalOnce(eventPlayer.Hero_Ability[1])+2][3]>0):
            createEffect(eventPlayer.Owner,Effect.RING,Color.YELLOW,updateEveryTick(vect(eventPlayer.getEyePosition().x,0,eventPlayer.getEyePosition().z)), HeroSpecs[eventPlayer.CHero_Index][evalOnce(eventPlayer.Hero_Ability[1])+2][3], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            addUI(getLastCreatedEntity(),AbilityState.MOVETO)

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