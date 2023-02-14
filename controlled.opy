#!mainFile "main.opy"
#This file handles the bot's actions and is player independent to allow for automation
#!define setFacingDir(dir) /**/\
eventPlayer.stopFacing()\
eventPlayer.LookAtDir = dir\
eventPlayer.setFacing(eventPlayer.LookAtDir,Relativity.TO_WORLD)\
wait()\
eventPlayer.startFacing(eventPlayer.LookAtDir,500,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
rule "On Controller Detach":
    @Event eachPlayer
    @Condition eventPlayer.isDummy()
    @Condition not entityExists(eventPlayer.Owner)
    
rule "On Controlled Join - Ignores respawn":
    @Event playerJoined
    @Condition eventPlayer.isDummy()
    createInWorldText(null if not eventPlayer.isAlive() else localPlayer if not eventPlayer.Hidden else getPlayers(eventPlayer.getTeam()),"{}\n|{}|{}|{}|{}|\n{}".format("            <•>" if not eventPlayer.Hidden else " ", 
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])))), __substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])*100%5),(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])<0.25), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])>0)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH]))),5)),
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])-0.25))),__substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])*100%5),(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])<0.5 and (eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])>=0.25), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])>=0.25)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])-0.25)),5)),
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])-0.5))), __substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])*100%5),(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])<0.75 and (eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])>=0.5), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])>=0.5)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])-0.5)),5)),
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])-0.75))),__substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])*100%5),(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])<1 and (eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])>=0.75), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])>=0.75)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.PlayerStats[PStat.HEALTH])-0.75)),5)),
    "{}{}".format("                 \b.|".substring(0, 3 * (max(0, 6.25 - strLen("{0}".format(eventPlayer)) / 2))), "{0}".format(eventPlayer))),updateEveryTick(vect(eventPlayer.getEyePosition().x,eventPlayer.getEyePosition().y+0.0,eventPlayer.getEyePosition().z+0.1)),1,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.GREEN if(localPlayer==eventPlayer.Owner) else eventPlayer.getTeam(),SpecVisibility.NEVER)
    eventPlayer.Level=1
    createEffect(localPlayer if not eventPlayer.Hidden and eventPlayer.isAlive() else getPlayers(eventPlayer.getTeam()),Effect.RING,eventPlayer.getTeam(), updateEveryTick(eventPlayer.getPosition()*vect(1,0,1)),0.7,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    print("{}: {}".format(len(eventPlayer.ActionQueue),arrToString7(eventPlayer.ActionQueue[ActionQueueVal.I0])))

rule "On Controlled Join - Pre-spawn":
    @Event eachPlayer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()==false
    @Condition eventPlayer.isAlive()==true
    if(eventPlayer.getTeam()==Team.1):
        eventPlayer.Team=1
    else:
        eventPlayer.Team=2
    eventPlayer.stopForcingCurrentHero()
    wait()
    eventPlayer.startForcingHero(eventPlayer.CHero)
    eventPlayer.CHero_Index=getAllHeroes().index(eventPlayer.CHero)
    #eventPlayer.Resource=[HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.RESOURCE][Base_Resource.STARTING_AMT],HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.RESOURCE][Base_Resource.STARTING_AMT],1]
    #eventPlayer.Health=[HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.HEALTH],HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.HEALTH],1]
    #eventPlayer.DamageModifiers=HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.DMGMOD]
    #print("{},{},[{},{},{}]".format(eventPlayer.Health[0],eventPlayer.PlayerStats[PStat.HEALTH],eventPlayer.Health[1][0],eventPlayer.Health[1][1],eventPlayer.Health[1][2]))
    #hudHeader(localPlayer,localPlayer.Team,HudPosition.TOP,0,Color.AQUA,HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR,SpecVisibility.ALWAYS)
    eventPlayer.PlayerStats=[0,/*index 0 is left blank*/
    /*health,resource,armor*/HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.HEALTH], HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.RESOURCE][Base_Resource.STARTING_AMT], HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.DMGMOD][Base_Dmgmod.ARMOR],
    /*dealmult(1),movespeed(1),basic range,basic damage,atkspeed(1)*/1,1,HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.DAMAGE],1,
    /*ability info: castmethod, range, cost, cooldown, maxcharges, damage, channel_duration (opt), ability specific variable ((opt))*/
    /*abil 1 info*/[HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL1][Abil.CAST][Abil_Cast.METHOD],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL1][Abil.CAST][Abil_Cast.RANGE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL1][Abil.COST][Abil_Cost.RESOURCE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL1][Abil.COST][Abil_Cost.COOLDOWN],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL1][Abil.COST][Abil_Cost.CHARGES],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL1][Abil.DMG][Abil_Damage.AMOUNT],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL1][Abil.DMG][Abil_Damage.RATE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL1][Abil.USE][Abil_Use.DURATION],0],
    /*abil 2 info*/[HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL2][Abil.CAST][Abil_Cast.METHOD],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL2][Abil.CAST][Abil_Cast.RANGE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL2][Abil.COST][Abil_Cost.RESOURCE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL2][Abil.COST][Abil_Cost.COOLDOWN],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL2][Abil.COST][Abil_Cost.CHARGES],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL2][Abil.DMG][Abil_Damage.AMOUNT],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL2][Abil.DMG][Abil_Damage.RATE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL2][Abil.USE][Abil_Use.DURATION],0],
    /*abil 3 info*/[HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL3][Abil.CAST][Abil_Cast.METHOD],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL3][Abil.CAST][Abil_Cast.RANGE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL3][Abil.COST][Abil_Cost.RESOURCE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL3][Abil.COST][Abil_Cost.COOLDOWN],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL3][Abil.COST][Abil_Cost.CHARGES],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL3][Abil.DMG][Abil_Damage.AMOUNT],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL3][Abil.DMG][Abil_Damage.RATE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL3][Abil.USE][Abil_Use.DURATION],0],
    /*abil 4 info*/[HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL4][Abil.CAST][Abil_Cast.METHOD],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL4][Abil.CAST][Abil_Cast.RANGE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL4][Abil.COST][Abil_Cost.RESOURCE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL4][Abil.COST][Abil_Cost.COOLDOWN],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL4][Abil.COST][Abil_Cost.CHARGES],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL4][Abil.DMG][Abil_Damage.AMOUNT],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL4][Abil.DMG][Abil_Damage.RATE],HeroSpecs[eventPlayer.CHero_Index][HeroStat.ABIL4][Abil.USE][Abil_Use.DURATION],0]
    ]
    
rule "Bot - Hero Connection":
    @Event eachPlayer
    @Condition eventPlayer.isDummy()
    if(eventPlayer.Owner):
        eventPlayer.startForcingHero(eventPlayer.Owner.CHero)
        if(eventPlayer.Hidden):
            eventPlayer.setInvisibility(Invis.ENEMIES)
        else:
            eventPlayer.setInvisibility(Invis.NONE)
    wait(1)
    eventPlayer.disableNameplatesFor(getAllPlayers())
    #eventPlayer.startForcingOutlineFor()
    goto RULE_START

def ProcessHealthQueue(): #Called by deal, processes health queue
    print(evalOnce("[{},{},{},{}]".format(eventPlayer.HealthQueue[0][0],eventPlayer.HealthQueue[0][1],eventPlayer.HealthQueue[0][2],eventPlayer.HealthQueue[0][3])))
    if(eventPlayer.HealthQueue[0][0].Health):#checks if target is a player
        if(eventPlayer.HealthQueue[0][0].isAlive()):
            if(eventPlayer.HealthQueue[0][1]>0): #damage
                eventPlayer.HealthQueue[0][0].Health[0]-=(eventPlayer.HealthQueue[0][1])*(1-eventPlayer.DamageModifiers[0]/100) * (eventPlayer.DamageModifiers[1] if eventPlayer.DamageModifiers[1]>0 else 1)  * (eventPlayer.HealthQueue[0][0].DamageModifiers[2])
                eventPlayer.HealthQueue[0][0].Health[2]=[eventPlayer,eventPlayer.HealthQueue[0][0].Health[2][1]]
                if(eventPlayer.HealthQueue[0][0].Health[0]<=0):
                    if(eventPlayer.Target==eventPlayer.HealthQueue[0][0]):
                        goto freetarget
            elif(eventPlayer.HealthQueue[0][1]<0): #healing
                eventPlayer.HealthQueue[0][0].Health[0]+=(abs(eventPlayer.HealthQueue[0][1])*eventPlayer.HealingModifiers[0])
                eventPlayer.HealthQueue[0][0].Health[2]=[eventPlayer.HealthQueue[0][0].Health[2][0],eventPlayer]
            else:
                print("{} tried to deal 0 damage to {}".format(eventPlayer,eventPlayer.HealthQueue[0][0]))
        else:
            freetarget:
            #print("{} has died".format(eventPlayer.Target[1]))
            eventPlayer.Target=null
    else:
        if(Minions_HP[Minions_IDs.index(eventPlayer.HealthQueue[0][0])]<=0):
            if(eventPlayer.Target==eventPlayer.HealthQueue[0][0]):
                eventPlayer.Target=null
        elif(eventPlayer.HealthQueue[0][1]>0): #minions cannot be healed
            HealthChange.append(vect(eventPlayer.HealthQueue[0][0],(eventPlayer.HealthQueue[0][1] * (1-eventPlayer.DamageModifiers[2])/100 * (1+eventPlayer.DamageModifiers[3]/100)),eventPlayer.Slot))
    del eventPlayer.HealthQueue[0]




#!define Ability_Used(button,abilitynum) eventPlayer.AbilityUse=[(button),(abilitynum)]\
        AbilityTrigger()\
        eventPlayer.AbilityUse=[]
def AbilityTrigger(): /*use ability is run as the ref, and can be used while automating eventPlayer.AbilityUsfacine[0]=button,eventPlayer.AbilityUse[1]=abilitynum*/
    if((eventPlayer.getAbilityCooldown(eventPlayer.AbilityUse[0])<=0 and (eventPlayer.PlayerStats[PStat.ABIL+eventPlayer.AbilityUse[1]-1][PStatAbil.MAXCHARGES]==0 or eventPlayer.getAbilityCharge(eventPlayer.AbilityUse[0])>0)) or (eventPlayer.getUltCharge()>99.5 and (eventPlayer.AbilityUse[0])==Button.ULTIMATE)):
        if(eventPlayer.Resource[0]>=HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.COST][Abil_Cost.RESOURCE] or not HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.COST][Abil_Cost.RESOURCE]): # mana
            if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.RANGE]>0): #if the ability doesn't have range, there's no need to chase target
                if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.MODE] == CastMode.GROUND): #This is a defined position: Add a move action to be in range of that location and queue ability there
                    if(distance(eventPlayer.CPos,eventPlayer.getPosition())>HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.RANGE]):
                        #!define moveToGroundCast eventPlayer.CPos+directionTowards(eventPlayer.CPos,eventPlayer)*(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.RANGE]+1)/*starts at cpos and moves player to closest point within range*/
                        #
                        #TODO
                        #

            eventPlayer.Hero_Ability[0]=AbilityStage.PRECAST
            eventPlayer.MovetoPos=eventPlayer.getPosition()
            if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.MODE]==CastMode.GROUND): /*is ability looking at ground*/
                setFacingDir(directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.CPos.x,0,eventPlayer.CPos.z)))
            elif(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.MODE]==CastMode.DIRECTION): /*is ability looking at ground*/
                if(eventPlayer.Owner):
                    eventPlayer.CPos=eventPlayer.Owner.cursor
                setFacingDir(directionTowards(eventPlayer.getEyePosition(),eventPlayer.CPos*vect(1,0,1)+vect(0,eventPlayer.getEyePosition().y,0)))
            elif(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][0][2]!=TargetState.NONE): /*is targeted*/ 
                /*if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][0][2]=TargetState.ENEMY)*/
                if(floor(eventPlayer.Target[0].x/10)==HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.TARGET] and distance(vect(eventPlayer.x,0,eventPlayer.z),vect(eventPlayer.Target[0].y,0,eventPlayer.Target[0].z))<=HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.RANGE]):
                    smallMessage(eventPlayer,"Targeted Ability {0} Activated".format(eventPlayer.AbilityUse[1]))
            if(eventPlayer.Hero_Ability[0]!=AbilityStage.MOVETO):/*ensures any onmove ui removal still takes place*/
                eventPlayer.Hero_Ability[0]=AbilityStage.MOVETO
                clearEffectUI()
            if(not HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.COST][Abil_Cost.RESOURCE] or eventPlayer.Resource[0]-HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.COST][Abil_Cost.RESOURCE]>0):
                eventPlayer.Resource[0]-=HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.COST][Abil_Cost.RESOURCE]
            else:
                goto cancelled
            eventPlayer.Hero_Ability[0]=AbilityStage.CAST
            wait()
        else:
            if(eventPlayer.Owner):
                smallMessage(eventPlayer.Owner, "Error: Ability costs a resource you don't use" if HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.RESOURCE][Base_Resource.TYPE]==ResourceType.NONE else "Out of mana" if HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.RESOURCE][Base_Resource.TYPE]==ResourceType.MANA else "Out of energy" if HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.RESOURCE][Base_Resource.TYPE]==ResourceType.ENERGY else "Resource Type doesn't exist")
            goto cancelled
    return
    cancelled:
        eventPlayer.Owner.AbilityVerify=[true,true]
        eventPlayer.Hero_Ability=[]
        eventPlayer.ClearAllUI=true
        clearEffectUI()
        eventPlayer.Owner.AbilityVerify=[false,false]


#!define Ability(button) eventPlayer.AbilityUse[0]=button\
    AbilityUse()
def AbilityUse():
    if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.COST][Abil_Cost.RESOURCE]):
        eventPlayer.Resource[0]-=HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.COST][Abil_Cost.RESOURCE]
    eventPlayer.startForcingButton(eventPlayer.AbilityUse[0])
    eventPlayer.stopForcingButton(eventPlayer.AbilityUse[0])
    wait(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.USE][Abil_Use.DURATION])
    


def Target_Func():
    eventPlayer.Temp_DistanceSort=[]
    forPlayer(TARGET_ITER,0,len(CPlayers[2-eventPlayer.Team])):
        eventPlayer.Temp_DistanceSort[eventPlayer.Iter[forP.TARGET_ITER]]=(vect(3-eventPlayer.Team+eventPlayer.Iter[forP.TARGET_ITER]/100,CPlayers[2-eventPlayer.Team][eventPlayer.Iter[forP.TARGET_ITER]].getPosition().x,CPlayers[2-eventPlayer.Team][eventPlayer.Iter[forP.TARGET_ITER]].getPosition().z))
        forEndP(TARGET_ITER)
    eventPlayer.Temp_DistanceSort=sorted(eventPlayer.Temp_DistanceSort.concat(random.shuffle(Minions_Loc.slice((2-eventPlayer.Team)*30,30))), lambda i: (abs(eventPlayer.TargetHandling[0].x-i.y))**2 + (abs(eventPlayer.TargetHandling[0].z-i.z))**2)
    forPlayer(TARGET_ITER,0,3):
        if((getHealthByID(eventPlayer.Temp_DistanceSort[eventPlayer.Iter[forP.TARGET_ITER]].x))<=0):
            forEndP(TARGET_ITER)
            continue
        if((abs(eventPlayer.TargetHandling[0].x-eventPlayer.Temp_DistanceSort[eventPlayer.Iter[forP.TARGET_ITER]].y))**2 + (abs(eventPlayer.TargetHandling[0].z-eventPlayer.Temp_DistanceSort[eventPlayer.Iter[forP.TARGET_ITER]].z))**2<abs(eventPlayer.TargetHandling[1])**2):
            eventPlayer.Target[0]=eventPlayer.Temp_DistanceSort[eventPlayer.Iter[forP.TARGET_ITER]]
            if(eventPlayer.Temp_DistanceSort[eventPlayer.Iter[forP.TARGET_ITER]].x<30): #assuming 10-15, 20-25 for player ids. Minions should be 1000+
                eventPlayer.Target[1] = PlayerFromID(eventPlayer.Temp_DistanceSort[eventPlayer.Iter[forP.TARGET_ITER]].x)
            else:
                eventPlayer.Target[1]= eventPlayer.Target[0].x
            return
        else:
            if(eventPlayer.TargetHandling[1]>0): #If not in attack move mode, as the closest object to the cursor is further than the limit, move on
                return
            else:
                goto attackMove
        forEndP(TARGET_ITER)
    return
    attackMove:
    if(eventPlayer.TargetHandling[1]<0):
        eventPlayer.Target=null
        eventPlayer.AttackMove=eventPlayer.TargetHandling[0]
    return


rule "Stop Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Target==null
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)

rule "Arrived":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    @Condition distance(eventPlayer.MovetoPos,eventPlayer)<0.6
    async(StopThrottle,AsyncBehavior.NOOP)
    if(eventPlayer.Hero_Ability[1] == 1):
        eventPlayer.Hero_Ability[0] = AbilityStage.COMPLETE
    smallMessage(eventPlayer.Owner,"Arrived.")
    # wait()
    # if(RULE_CONDITION):
    #     goto RULE_START

def StopThrottle():
    if(eventPlayer.Owner):
        eventPlayer.Owner.MovementGroundCursor = false
    eventPlayer.MovetoPos = eventPlayer.getPosition()
    eventPlayer.stopThrottleInDirection()

### -1 ###
rule "Cancel Action Rule":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.clearQueue
    eventPlayer.clearQueue = false
    CancelAction()

def CancelAction():
    #This waits until the action's minimum ability time has elapsed while also throwing an error if it fails
    #assumes that no ability is supposed to wait longer than 5 seconds
    waitUntil_verifyCustom(getTotalTimeElapsed()>eventPlayer.ActionQueue[ActionQueueVal.LASTABILTIME]+eventPlayer.ActionQueue[ActionQueueVal.I0][ActionQueueInfo.ABILMINTIME],5,"{} {} {} {}".format("Cancel Action Failed with action",eventPlayer.ActionQueue[ActionQueueVal.I0][ActionQueueInfo.NUMBER],"for Controlled",eventPlayer))
    eventPlayer.ActionQueue = eventPlayer.ActionQueue.slice(0,ActionQueueVal.I0)
    eventPlayer.Action = []
    StopThrottle()


### 0 ###

#no action is being executed


def ChaseTarget():
    #subroutine that moves player towards target until sucessful completetion of action
    #For example, chasing a player to get an auto attack, or getting an ability off
    #Repeats until action is 0

### 1 ###
rule "MoveToCPos":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(1)
    smallMessage(hostPlayer,"--")
    eventPlayer.Hero_Ability = [AbilityStage.MOVETO,1,Button.SECONDARY_FIRE]
    if(not HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.AUTOTARGET]):
        eventPlayer.Target=null
    if(eventPlayer.Owner != "null" and eventPlayer.Owner != 0):
        async(moveCameraWithPlayer,AsyncBehavior.RESTART)
    if(distance(eventPlayer.getPosition(),eventPlayer.MovetoPos)>1):
        eventPlayer.startThrottleInDirection(vectorTowards(eventPlayer.getPosition(), eventPlayer.MovetoPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)


rule "Look While Moving":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Action[ActionInfo.NUMBER] == 1
    @Condition distance(eventPlayer.MovetoPos,eventPlayer.getPosition())>0.5
    #@Condition false
    if(HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.AUTOTARGET] and (distanceToTarget)<=HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE] and eventPlayer.Target):
        eventPlayer.LookAtDir = (directionTowards(eventPlayer.getPosition()*vect(1,0,1),(eventPlayer.Target[1] if eventPlayer.Target[1] else MinionsLoc[slot(eventPlayer.Target[0].x)])*vect(1,0,1)))
    else:
        eventPlayer.LookAtDir = (directionTowards(eventPlayer.getPosition()*vect(1,0,1),eventPlayer.MovetoPos*vect(1,0,1)))
    waitUntil(angleBetweenVectors(eventPlayer.getFacingDirection(),eventPlayer.LookAtDir)>5,0.016)
    wait()
    if(RULE_CONDITION):
        goto RULE_START


### 2 ###
#!define BasicAttackExceptions []
rule "Use Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(2)
    print("2 triggered")
    return
    wait()
    eventPlayer.Hero_Ability[0]=AbilityStage.COMPLETE
    wait(0.132)
    eventPlayer.Hero_Ability[0]=AbilityStage.NONE
/*

    eventPlayer.setAmmo(0,2000)
    while(eventPlayer.Target[0].x>0):
        if(eventPlayer.Target[2][0] or eventPlayer.Target[2][1]):
            while(not eventPlayer.Target[0].x>0 or distanceToTarget>HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE]):
                if(eventPlayer.Target[1]):
                    eventPlayer.CPos=vect(eventPlayer.Target[1].getEyePosition().x,eventPlayer.Target[1].getEyePosition().y/(HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE]),eventPlayer.Target[1].getEyePosition().z)
                    if(not eventPlayer.CPos):
                        print("Error with entity in Target ref")
                        return
                elif(eventPlayer.Target[0].x>=10):
                    eventPlayer.CPos=vect(Minions_Loc[MinionsLoc(eventPlayer.Target[0].x)].y,0,Minions_Loc[MinionsLoc(eventPlayer.Target[0].x)].z) #turns id to coords
                else:
                    print("Entity has broken ref or id. Id of >10 missing entity ref")
                    return #for some reason, the dummy bot was deleted and we have a broken ref
                eventPlayer.MovetoPos=eventPlayer.CPos+directionTowards(eventPlayer.CPos,eventPlayer.getPosition())*(HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE]-1)//starts at cpos and moves player to closest point within range
                wait(0.03)
            if(not eventPlayer.Target[0].x>0):
                eventPlayer.Target=null
                return
            if(distanceToTarget>HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE]):
                wait(0.2)
        if(not (HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.AUTOTARGET] and (distanceToTarget>HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE] and eventPlayer.Target))):
            if(eventPlayer.Target[1]):
                eventPlayer.LookAtDir = directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.Target[1].getEyePosition().x,eventPlayer.Target[1].getEyePosition().y,eventPlayer.Target[1].getEyePosition().z))
                #eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.Target[1].getEyePosition().x,eventPlayer.Target[1].getEyePosition().y/([eventPlayer.CHero_Index][2][0]),eventPlayer.Target[1].getEyePosition().z)),Relativity.TO_WORLD)
            else:
                eventPlayer.LookAtDir = directionTowards(eventPlayer.getEyePosition(),eventPlayer.CPos)
                
                #eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(),eventPlayer.CPos),Relativity.TO_WORLD)
        waitUntil(abs(angleBetweenVectors(angleToDirection(eventPlayer.getHorizontalFacingAngle(),0),directionTowards(eventPlayer.getEyePosition()+angleToDirection(eventPlayer.getHorizontalFacingAngle(),0),eventPlayer.LookAtDir)))<15,1)
        setFacingDir(directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.Target[1].getEyePosition().x,eventPlayer.Target[1].getEyePosition().y/(HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE]),eventPlayer.Target[1].getEyePosition().z)))
        if(distanceToTarget<=HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE]):
            if(eventPlayer.Target[2][0]):
                eventPlayer.Target[2]=[false,eventPlayer.Target[2][1]]
            if(eventPlayer.CHero in BasicAttackExceptions):
                eventPlayer.Hero_Ability[1]=0
                eventPlayer.Hero_Ability[0]=AbilityStage.CAST
            else:
                eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
            
            deal(eventPlayer.Target[1] if eventPlayer.Target[1] else eventPlayer.Target[0].x,HeroSpecs[eventPlayer.CHero_Index][2][1])
            waitUntil(not eventPlayer.Target[0].x>0,1/HeroSpecs[eventPlayer.CHero_Index][2][2]*1)
            
        else:
            wait(0.03)
            continue

*/
    ### 3 ###
rule "Use Ability 1":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(3)
    Ability_Used(Button.ABILITY_1,3)
    
### 4 ###
rule "Use Ability 2":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(4)
    Ability_Used(Button.ABILITY_2,4)

### 5 ###
rule "Use Secondary (e)":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(5)
    Ability_Used(Button.SECONDARY_FIRE,5)

### 6 ###
rule "Use Ult":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(6)
    if(eventPlayer.CHero not in [Hero.MOIRA,Hero.BRIGITTE,Hero.WIDOWMAKER,Hero.TORBJORN]):
        Ability_Used(Button.ULTIMATE,6)

### 8 ### 
rule "Controller Left":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(8)
    eventPlayer.stopForcingName()
    wait()
    eventPlayer.startForcingName("«{}»".format(eventPlayer.getCurrentHero()))
    wait()
    if(eventPlayer.Owner):
        if(Setting_Mode==1):
            #prsChange[eventPlayer.Slot] = -50
        eventPlayer.stopForcingOutlineFor(eventPlayer.Owner)
        eventPlayer.Owner.ControlledRef=null
        if(Players[floor(eventPlayer.Slot)-1][(eventPlayer.Slot)%1*100]==eventPlayer.Owner):
            Players[floor(eventPlayer.Slot)-1]=arreplace(null,(eventPlayer.Slot)%1*100,Players[floor(eventPlayer.Slot)-1])
    eventPlayer.Owner=null
    

rule "dmg/heal OT on":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    @Condition  eventPlayer.Health[1][1]>0
    wait(0.2)
    if(not eventPlayer.Health[1][2]):
        eventPlayer.Health[1]=[eventPlayer.Health[1][0],eventPlayer.Health[1][1],eventPlayer.Health[1][0]/eventPlayer.Health[1][1]]
    eventPlayer.Health[1]=[eventPlayer.Health[1][2]*(eventPlayer.Health[1][1]-0.2),eventPlayer.Health[1][1]-0.2,eventPlayer.Health[1][2]]
    if(eventPlayer.Health[0]+eventPlayer.Health[1][2]/5<eventPlayer.PlayerStats[PStat.HEALTH]):
        eventPlayer.Health[0]+=(eventPlayer.Health[1][2]/5)
    loopt

rule "dmg/heal OT off":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    @Condition  eventPlayer.Health[1][1]<=0
    eventPlayer.Health[1]=null

rule "(Re)spawn":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    eventPlayer.Health[0]=max(10,eventPlayer.PlayerStats[PStat.HEALTH])
    eventPlayer.Action = []
    eventPlayer.ActionQueue = [getTotalTimeElapsed()] 
    setFacingDir(vect(0,0,1))
    chase(eventPlayer.CamLoc,toCamLoc,duration=0.2,ChaseReeval.DESTINATION_AND_DURATION)
    
### Death ###
rule "Is Dead":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.Health[0]<=0
    #eventPlayer.Hidden=true
    eventPlayer.Target=null
    StopThrottle()
    eventPlayer.stopFacing()
    eventPlayer.setRespawnTime(eventPlayer.Level*2+4)
    eventPlayer.setDamageReceived(1)
    kill(eventPlayer,eventPlayer.Health[2][0].Owner)
    eventPlayer.setDamageReceived(0)

       


#!include "ai.opy"          

                

