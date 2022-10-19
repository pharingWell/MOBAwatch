#!mainFile "../main.opy"

#This file is used for things regarding any hero and the player's input

#!define attachControlled \
    createDummy(eventPlayer.CHero, eventPlayer.getTeam(), TeamSize+eventPlayer.Slot, vect(0,0,0),vect(0,0,0))\
    CPlayers[eventPlayer.Team-1]=insert(getLastCreatedEntity(),eventPlayer.Slot,CPlayers[eventPlayer.Team-1])\
    eventPlayer.ControlledRef=CPlayers[eventPlayer.Team-1][eventPlayer.Slot]\
    eventPlayer.ControlledRef.startForcingPosition(vect(0,100,0),true)\
    eventPlayer.ControlledRef.stopForcingPosition()\
    eventPlayer.ControlledRef.Owner = eventPlayer\
    eventPlayer.ControlledRef.startForcingName("_{}_".format(eventPlayer))\
    eventPlayer.startForcingName("{}".format("_--_"))\
    eventPlayer.ControlledRef.CHero=eventPlayer.CHero\
    eventPlayer.ControlledRef.setDamageDealt(0)\
    eventPlayer.ControlledRef.setDamageReceived(0)\
    eventPlayer.setDamageReceived(0)\
    eventPlayer.ControlledRef.Slot=(eventPlayer.Team)+eventPlayer.Slot/100 /*sets player id*/\
    
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
    eventPlayer.disableScoreboard()
    eventPlayer.CHero = eventPlayer.getCurrentHero()
    if(eventPlayer.Team!=0): #catches team switch as team should be zero right now
        startAction(8,eventPlayer.ControlledRef)
    if(eventPlayer.getTeam()==Team.1):
        eventPlayer.Team=1
    else:
        eventPlayer.Team=2
    eventPlayer.Slot=eventPlayer.getSlot()
    Players[eventPlayer.Team-1]=arreplace(eventPlayer,eventPlayer.Slot,Players[eventPlayer.Team-1])
    attachControlled
    eventPlayer.startForcingHero(eventPlayer.ControlledRef.CHero)
    wait()
    OnHero()
    wait()
    UI_Setup()
    waitUntil(eventPlayer.ControlledRef.hasSpawned()==true,1000)
    wait()
    eventPlayer.CamAttach=true
    moveCameraWithPlayer()
    wait()
    #eventPlayer.disableHeroHUD()
    async(UI_Process,AsyncBehavior.NOOP)
    eventPlayer.enableScoreboard()
    if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][HeroStat.BASIC][Basic.AUTOTARGET]):
        createEffect(eventPlayer if eventPlayer.ControlledRef.Target else null,Effect.RING,Color.AQUA,getLocation(eventPlayer.ControlledRef.Target[1]),eventPlayer.ControlledRef.Target[1]*0.5+1.2,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.stopFacing()
    eventPlayer.Ready=true

rule "Camera Update":
    @Event eachPlayer
    @Condition Ready==true
    @Condition not eventPlayer.isDummy()
    @Condition getTotalTimeElapsed()%1==0


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

rule "Controlled Spawned":
    @Event eachPlayer
    @Condition Ready==true
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.ControlledRef.isAlive()
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
    eventPlayer.ControlledRef.setFacing(eventPlayer.ControlledRef.LookAtDir,Relativity.TO_WORLD)
    eventPlayer.ControlledRef.MovetoPos =  eventPlayer.cursor
    startAction(0,eventPlayer.ControlledRef)
    eventPlayer.ControlledRef.setFacing(eventPlayer.ControlledRef.LookAtDir,Relativity.TO_WORLD)
    waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE),0.5)
    while(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)):
        eventPlayer.ControlledRef.MovetoPos = eventPlayer.cursor
        if(eventPlayer.ControlledRef.Actions==0):
            startAction(0,eventPlayer.ControlledRef)
        waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), 0.25)    

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
        Target_Func()
        if(eventPlayer.Target[0]):
            eventPlayer.ControlledRef.Target=eventPlayer.Target
            eventPlayer.UICursorStyles[0]=Color.RED
            wait(0.1)
            eventPlayer.UICursorStyles[0]=Color.WHITE
            eventPlayer.ControlledRef.Target[2]=[true,not HeroSpecs[eventPlayer.ControlledRef.CHero_Index][HeroStat.BASIC][Basic.AUTOTARGET]]
            startAction(2,eventPlayer.ControlledRef)
        elif(eventPlayer.AttackMove):
            eventPlayer.UICursorStyles[0]=rgb(238,148,148)
            wait(0.1)
            eventPlayer.UICursorStyles[0]=Color.WHITE
            eventPlayer.ControlledRef.AttackMove=eventPlayer.AttackMove #Convert target return data to controlled ref data
            eventPlayer.AttackMove=0 #clear self data
            eventPlayer.ControlledRef.MovetoPos=eventPlayer.ControlledRef.AttackMove
            startAction(0,eventPlayer.ControlledRef)

#!define cast(abilitynum,button) /*as owner, this is used to handle inputs that we dont want the ai to have to deal with while automating*/\
    eventPlayer.ControlledRef.Hero_Ability[1]=abilitynum\
    eventPlayer.ControlledRef.Hero_Ability[2]=(button)\
    eventPlayer.ControlledRef.Hero_Ability[2]=abilitynum-2\
    if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilitynum]):/*if exists*/\
        if(eventPlayer.ControlledRef.Hero_Ability[0]==AbilityStage.CAST and HeroSpecs[eventPlayer.ControlledRef.CHero_Index][eventPlayer.ControlledRef.Hero_Ability[1]][Abil.USE][Abil_Use.TYPE]==UseType.CANCELABLE):\
            startAction(1,eventPlayer.ControlledRef)\
        eventPlayer.ControlledRef.CPos=eventPlayer.cursor\
        if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilitynum][Abil.CAST][Abil_Cast.METHOD]==CastMethod.QUICK):\
            startAction(abilitynum,eventPlayer.ControlledRef)\
        elif(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilitynum][Abil.CAST][Abil_Cast.METHOD]==CastMethod.RELEASE):\
            eventPlayer.ControlledRef.Hero_Ability=[AbilityStage.PREP,abilitynum,0]\
            waitUntil_verify(not eventPlayer.isHoldingButton(button))\
            startAction(abilitynum,eventPlayer.ControlledRef)\
        elif(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][abilitynum][Abil.CAST][Abil_Cast.METHOD]==CastMethod.CONFIRM):\
            eventPlayer.ControlledRef.Hero_Ability=[AbilityStage.PREP,abilitynum,(button)]\
            async(CastConfirm,AsyncBehavior.NOOP)\
        else:\
            print("Cast called with no mode")\


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
    waitUntil_verify(not eventPlayer.AbilityVerify[0])
    clearEffectUI()
    if(not eventPlayer.AbilityVerify[1]):
        eventPlayer.ControlledRef.CPos=eventPlayer.cursor
        startAction(eventPlayer.ControlledRef.Hero_Ability[1],eventPlayer.ControlledRef)
        eventPlayer.AbilityVerify=[]
    else:
        eventPlayer.AbilityVerify=[]
        eventPlayer.ControlledRef.Actions = 0
        return /*ability cast cancelled*/

/*GENERIC UI, Run as controlled*/

#!define addUI(UI_id,DestroyAt) eventPlayer.Ability_UI[DestroyAt]=eventPlayer.Ability_UI[DestroyAt].concat(UI_id)
#!define AreaHighlight(effect,radius) createEffect(eventPlayer.Owner,effect,Color.GREEN,updateEveryTick(eventPlayer.Owner.cursor),(radius),EffectReeval.VISIBILITY_POSITION_AND_RADIUS)\
addUI(getLastCreatedEntity(),eventPlayer.Hero_Ability[0]+1)

def defaultEffectUI():
    if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.Hero_Ability[1]]): #does referenced ability number even exist
        if(HeroSpecs[eventPlayer.CHero_Index][evalOnce(eventPlayer.Hero_Ability[1])][Abil.CAST][Abil_Cast.RANGE]>0):
            createEffect(eventPlayer.Owner,Effect.RING,Color.YELLOW,updateEveryTick(vect(eventPlayer.getEyePosition().x,0,eventPlayer.getEyePosition().z)), HeroSpecs[eventPlayer.CHero_Index][evalOnce(eventPlayer.Hero_Ability[1])][Abil.CAST][Abil_Cast.RANGE], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            addUI(getLastCreatedEntity(),eventPlayer.Hero_Ability[0]+1)

def clearEffectUI():
    if(eventPlayer.ClearAllUI):
        eventPlayer.ClearAllUI=false
        forPlayer(forP.EACHABILITYSTAGEUI,eventPlayer,0,len(eventPlayer.Ability_UI)):
            forPlayer(forP.EACHABILITYSTAGEUIEFFECT,eventPlayer,0,len(eventPlayer.Ability_UI[eventPlayer.Iter[forP.EACHABILITYSTAGEUI]])):
                destroyEffect(eventPlayer.Ability_UI[eventPlayer.Iter[forP.EACHABILITYSTAGEUI]][forP.EACHABILITYSTAGEUIEFFECT])
                forEndP(forP.EACHABILITYSTAGEUIEFFECT,eventPlayer)
            forEndP(forP.EACHABILITYSTAGEUI,eventPlayer)
        eventPlayer.Ability_UI[evalOnce(eventPlayer.Hero_Ability[0])]=[]
    else:
        forPlayer(forP.EACHABILITYSTAGEUIEFFECT,eventPlayer,0,len(eventPlayer.Ability_UI[evalOnce(eventPlayer.Hero_Ability[0])])):
            destroyEffect(eventPlayer.Ability_UI[evalOnce(eventPlayer.Hero_Ability[0])][eventPlayer.Iter[forP.EACHABILITYSTAGEUI]])
            forEndP(forP.EACHABILITYSTAGEUIEFFECT,eventPlayer)
        eventPlayer.Ability_UI[evalOnce(eventPlayer.Hero_Ability[0])]=[] 


        