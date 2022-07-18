#!mainFile "main.opy"
#This file handles the bot's actions and is player independent to allow for automation

rule "On Controller Detach":
    @Event eachPlayer
    @Condition eventPlayer.isDummy()
    @Condition not entityExists(eventPlayer.Owner)
    
rule "On Controlled Join - Ignores respawn":
    @Event playerJoined
    @Condition eventPlayer.isDummy()
    createInWorldText(null if not eventPlayer.isAlive() else localPlayer if not eventPlayer.Hidden else getPlayers(eventPlayer.getTeam()),"{}\n|{}|{}|{}|{}|\n{}".format("            <•>" if not eventPlayer.Hidden else " ", 
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])))), __substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.Health[1])*100%5),(eventPlayer.Health[0]/eventPlayer.Health[1])<0.25), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.Health[1])>0)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1]))),5)),
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.25))),__substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.Health[1])*100%5),(eventPlayer.Health[0]/eventPlayer.Health[1])<0.5 and (eventPlayer.Health[0]/eventPlayer.Health[1])>=0.25), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.Health[1])>=0.25)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.25)),5)),
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.5))), __substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.Health[1])*100%5),(eventPlayer.Health[0]/eventPlayer.Health[1])<0.75 and (eventPlayer.Health[0]/eventPlayer.Health[1])>=0.5), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.Health[1])>=0.5)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.5)),5)),
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.75))),__substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.Health[1])*100%5),(eventPlayer.Health[0]/eventPlayer.Health[1])<1 and (eventPlayer.Health[0]/eventPlayer.Health[1])>=0.75), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.Health[1])>=0.75)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.75)),5)),
    "{}{}".format("                 \b.|".substring(0, 3 * (max(0, 6.25 - strLen("{0}".format(eventPlayer)) / 2))), "{0}".format(eventPlayer))),updateEveryTick(vect(eventPlayer.getEyePosition().x,eventPlayer.getEyePosition().y+0.0,eventPlayer.getEyePosition().z+0.1)),1,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.GREEN if(localPlayer==eventPlayer.Owner) else Color.TEAM_1 if eventPlayer.Team==1 else Color.TEAM_2,SpecVisibility.NEVER)
    eventPlayer.Level=1
    createEffect(localPlayer if not eventPlayer.Hidden and eventPlayer.isAlive() else getPlayers(eventPlayer.getTeam()),Effect.RING,Color.TEAM_1 if eventPlayer.Team==0 else Color.TEAM_2, updateEveryTick(eventPlayer.getPosition()*vect(1,0,1)),0.7,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

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
    eventPlayer.Resource=[HeroSpecs[eventPlayer.CHero_Index][0][1][0],HeroSpecs[eventPlayer.CHero_Index][0][1][0],1]
    eventPlayer.Health=[HeroSpecs[eventPlayer.CHero_Index][0][0],HeroSpecs[eventPlayer.CHero_Index][0][0],1]
    eventPlayer.DamageModifiers=HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASE][Base.DMGMOD]
    #print("{},{},[{},{},{}]".format(eventPlayer.Health[0],eventPlayer.Health[1],eventPlayer.Health[2][0],eventPlayer.Health[2][1],eventPlayer.Health[2][2]))
    #hudHeader(localPlayer,localPlayer.Team,HudPosition.TOP,0,Color.AQUA,HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR,SpecVisibility.ALWAYS)

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
    #eventPlayer.HealthQueue[0][0] will always be 0
    if(eventPlayer.HealthQueue[1][0].Health):#checks if target is a player
        if(eventPlayer.HealthQueue[1][0].isAlive()):
            if(eventPlayer.HealthQueue[1][1]>0): #damage
                eventPlayer.HealthQueue[1][0].Health[0]-=(eventPlayer.HealthQueue[1][1])*(1-eventPlayer.DamageModifiers[0]/100) * (eventPlayer.DamageModifiers[1] if eventPlayer.DamageModifiers[1]>0 else 1)  * (eventPlayer.HealthQueue[1][0].DamageModifiers[2])
                eventPlayer.HealthQueue[1][0].Health[3]=[eventPlayer,eventPlayer.HealthQueue[1][0].Health[3][1]]
                if(eventPlayer.HealthQueue[1][0].Health[0]<=0):
                    if(eventPlayer.Target==eventPlayer.HealthQueue[1][0]):
                        goto freetarget
            elif(eventPlayer.HealthQueue[1][1]<0): #healing
                eventPlayer.HealthQueue[1][0].Health[0]+=(abs(eventPlayer.HealthQueue[1][1])*eventPlayer.HealingModifiers[0])
                eventPlayer.HealthQueue[1][0].Health[3]=[eventPlayer.HealthQueue[1][0].Health[3][0],eventPlayer]
            else:
                print("{} tried to deal 0 damage to {}".format(eventPlayer,eventPlayer.HealthQueue[1][0]))
        else:
            freetarget:
            #print("{} has died".format(eventPlayer.Target[1]))
            eventPlayer.Target=null
    else:
        if(Minions_HP[Minions_IDs.index(eventPlayer.HealthQueue[1][0])]<=0):
            if(eventPlayer.Target==eventPlayer.HealthQueue[1][0]):
                eventPlayer.Target=null
        elif(eventPlayer.HealthQueue[1][1]>0): #minions cannot be healed
            HealthChange.append(vect(eventPlayer.HealthQueue[1][0],(eventPlayer.HealthQueue[1][1] * (1-eventPlayer.DamageModifiers[2])/100 * (1+eventPlayer.DamageModifiers[3]/100)),eventPlayer.Slot))
    del eventPlayer.HealthQueue[1]




#!define Ability_Used(button,abilitynum) eventPlayer.AbilityUse=[(button),(abilitynum)]\
AbilityTrigger()\
    eventPlayer.AbilityUse=[]
def AbilityTrigger(): /*use ability is run as the ref, and can be used while automating eventPlayer.AbilityUsfacine[0]=button,eventPlayer.AbilityUse[1]=abilitynum*/    
    if((eventPlayer.getAbilityCooldown(eventPlayer.AbilityUse[0])<=0.1 or eventPlayer.getAbilityCharge(eventPlayer.AbilityUse[0])>0) or (eventPlayer.getUltCharge()>99.5 and (eventPlayer.AbilityUse[0])==Button.ULTIMATE)):
        if(eventPlayer.Resource[0]>=HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.COST][Abil_Cost.RESOURCE] or not HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.COST][Abil_Cost.RESOURCE]): # mana
            if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.RANGE]>0 and distance(eventPlayer.CPos,eventPlayer.getPosition())>HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.RANGE]):#if abil has range and cast point is out if range
                eventPlayer.MovetoPos=eventPlayer.CPos+directionTowards(eventPlayer.CPos,eventPlayer)*(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.RANGE]+1)/*starts at cpos and moves player to closest point within range*/
                eventPlayer.Hero_Ability[0]=AbilityStage.MOVETO
                if(eventPlayer.Actions==eventPlayer.Hero_Ability[1]+0.15):
                    eventPlayer.Actions=0.15 #sets action to movement and as actions is set, prohibits interaction except by cancelling 
                else:
                    goto cancelled
                waitUntil(eventPlayer.Actions!=0.15 or evalOnce(eventPlayer.MovetoPos)!=eventPlayer.MovetoPos,100) #move to pos changing hopefully overwrites any repositioning. This should also have a waituntil_verify, but it cannot because of how evalonce works
                if(not eventPlayer.Actions):
                    eventPlayer.Actions=eventPlayer.Hero_Ability[1]+0.15 #resumes ability use
                else: #if the actions gets overridden/movement is redirrected
                    goto cancelled
                if(eventPlayer.Hero_Ability[0]!=AbilityStage.MOVETO):
                    goto cancelled
            eventPlayer.MovetoPos=eventPlayer.getPosition()
            if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.MODE]==CastMode.GROUND): /*is ability looking at ground*/
                eventPlayer.LookAtDir=directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.CPos.x,0,eventPlayer.CPos.z))
                eventPlayer.setFacing(eventPlayer.LookAtDir,Relativity.TO_WORLD)
            elif(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.MODE]==CastMode.DIRECTION): /*is ability looking at ground*/
                if(eventPlayer.Owner):
                    eventPlayer.CPos=eventPlayer.Owner.cursor
                eventPlayer.LookAtDir=(directionTowards(eventPlayer.getEyePosition(),eventPlayer.CPos*vect(1,0,1)+vect(0,eventPlayer.getEyePosition().y,0))*30) #,Relativity.TO_WORLD)
                eventPlayer.setFacing(eventPlayer.LookAtDir,Relativity.TO_WORLD)
                wait(angleDifference(horizontalAngleOfDirection(eventPlayer.LookAtDir),eventPlayer.getHorizontalFacingAngle())/1000)
            elif(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][0][2]!=TargetState.NONE): /*is targeted*/ 
                /*if(HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][0][2]=TargetState.ENEMY)*/
                if(floor(eventPlayer.Target[0].x/10)==HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.TARGET] and distance(vect(eventPlayer.x,0,eventPlayer.z),vect(eventPlayer.Target[0].y,0,eventPlayer.Target[0].z))<=HeroSpecs[eventPlayer.CHero_Index][eventPlayer.AbilityUse[1]][Abil.CAST][Abil_Cast.RANGE]):
                    smallMessage(eventPlayer,"Targeted Ability{0} Activated".format(eventPlayer.AbilityUse[1]))
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
        eventPlayer.Actions=0
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
    for eventPlayer.Target_i in range(0,len(CPlayers[2-eventPlayer.Team])):
        eventPlayer.Temp_DistanceSort[eventPlayer.Target_i]=(vect(3-eventPlayer.Team+eventPlayer.Target_i/100,CPlayers[2-eventPlayer.Team][eventPlayer.Target_i].getPosition().x,CPlayers[2-eventPlayer.Team][eventPlayer.Target_i].getPosition().z))
    eventPlayer.Temp_DistanceSort=sorted(eventPlayer.Temp_DistanceSort.concat(random.shuffle(NonPlayer_Loc.slice((2-eventPlayer.Team)*30,30))), lambda i: (abs(eventPlayer.TargetHandling[0].x-i.y))**2 + (abs(eventPlayer.TargetHandling[0].z-i.z))**2)
    for eventPlayer.Target_i in range(0,3):
        if((getHealthByID(eventPlayer.Temp_DistanceSort[eventPlayer.Target_i].x))<=0):
            continue
        if((abs(eventPlayer.TargetHandling[0].x-eventPlayer.Temp_DistanceSort[eventPlayer.Target_i].y))**2 + (abs(eventPlayer.TargetHandling[0].z-eventPlayer.Temp_DistanceSort[eventPlayer.Target_i].z))**2<abs(eventPlayer.TargetHandling[1])**2):
            eventPlayer.Target[0]=eventPlayer.Temp_DistanceSort[eventPlayer.Target_i]
            if(eventPlayer.Temp_DistanceSort[eventPlayer.Target_i].x<10):
                eventPlayer.Target[1] = PlayerFromID(eventPlayer.Temp_DistanceSort[eventPlayer.Target_i].x)
            else:
                eventPlayer.Target[1]=null
            return
        else:
            if(eventPlayer.TargetHandling[1]>0): #If not in attack move mode, as the closest object to the cursor is further than the limit, move on
                return
            else:
                goto attackMove
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
    if(RULE_CONDITION):
        goto RULE_START

def StopThrottle():
    if(eventPlayer.Owner):
        eventPlayer.Owner.MovementGroundCursor = false
    eventPlayer.MovetoPos = eventPlayer.getPosition()
    eventPlayer.stopThrottleInDirection()
    endAbilityAction(0)

### 0 ###
rule "MoveToCPos":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(0)
    if(eventPlayer.Owner != "null" and eventPlayer.Owner != 0):
        async(moveCameraWithPlayer,AsyncBehavior.RESTART)
    if(distance(eventPlayer.getPosition(),eventPlayer.MovetoPos)>1):
        eventPlayer.startThrottleInDirection(vectorTowards(eventPlayer.getPosition(), eventPlayer.MovetoPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    else:
        endAbilityAction(0)

rule "Look While Moving":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.NONE
    @Condition distance(eventPlayer.MovetoPos,eventPlayer.getPosition())>0.5
    #@Condition false
    if(not (HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.AUTOTARGET] and (distanceToTarget<=HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE] and eventPlayer.Target))):
        eventPlayer.LookAtDir = (directionTowards(eventPlayer.getPosition(),vect(eventPlayer.MovetoPos.x,eventPlayer.getPosition().y,eventPlayer.MovetoPos.z)))
        waitUntil(angleBetweenVectors(eventPlayer.getFacingDirection(),eventPlayer.LookAtDir)>30,0.064)
        wait()
        if(RULE_CONDITION):
            goto RULE_START

### 1 ###
rule "Cancel Current Ability":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    ifAction(1)
    CancelCurrent()
    endAbilityAction(1)

def CancelCurrent():
    eventPlayer.AbilityUse[0]=AbilityStage.CANCELLED
    waitUntil_verify(eventPlayer.AbilityUse[0]==AbilityStage.NONE)
    

### 2 ###
#!define BasicAttackExceptions []
rule "Use Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(2)
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
                    eventPlayer.CPos=vect(NonPlayer_Loc[NonPLoc(eventPlayer.Target[0].x)].y,0,NonPlayer_Loc[NonPLoc(eventPlayer.Target[0].x)].z) #turns id to coords
                else:
                    print("Entity has broken ref or id. Id of >10 missing entity ref")
                    return #for some reason, the dummy bot was deleted and we have a broken ref
                eventPlayer.MovetoPos=eventPlayer.CPos+directionTowards(eventPlayer.CPos,eventPlayer.getPosition())*(HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE]-1)/*starts at cpos and moves player to closest point within range*/
                startAction(0,eventPlayer)
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
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.Target[1].getEyePosition().x,eventPlayer.Target[1].getEyePosition().y/(HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][Basic.RANGE]),eventPlayer.Target[1].getEyePosition().z)),Relativity.TO_WORLD)
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
    endAbilityAction(2)

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
            Players[floor(eventPlayer.Slot)-1]=replace(null,(eventPlayer.Slot)%1*100,Players[floor(eventPlayer.Slot)-1])
    eventPlayer.Owner=null
    endAbilityAction(8)
    

rule "dmg/heal OT on":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    @Condition  eventPlayer.Health[2][1]>0
    wait(0.2)
    if(not eventPlayer.Health[2][2]):
        eventPlayer.Health[2]=[eventPlayer.Health[2][0],eventPlayer.Health[2][1],eventPlayer.Health[2][0]/eventPlayer.Health[2][1]]
    eventPlayer.Health[2]=[eventPlayer.Health[2][2]*(eventPlayer.Health[2][1]-0.2),eventPlayer.Health[2][1]-0.2,eventPlayer.Health[2][2]]
    if(eventPlayer.Health[0]+eventPlayer.Health[2][2]/5<eventPlayer.Health[1]):
        eventPlayer.Health[0]+=(eventPlayer.Health[2][2]/5)
    loopt

rule "dmg/heal OT off":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    @Condition  eventPlayer.Health[2][1]<=0
    eventPlayer.Health[2]=null

rule "(Re)spawn":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    eventPlayer.Health[0]=max(10,eventPlayer.Health[1])




    eventPlayer.Health[1]=max(100,eventPlayer.Health[1])
    eventPlayer.Health[4]=[null,null]
    eventPlayer.startFacing(eventPlayer.LookAtDir,1000,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
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
    eventPlayer.Actions=0
    eventPlayer.stopFacing()
    eventPlayer.setRespawnTime(eventPlayer.Level*2+4)
    eventPlayer.setDamageReceived(1)
    kill(eventPlayer,eventPlayer.Health[3][0].Owner)
    eventPlayer.setDamageReceived(0)

       


#!include "ai.opy"          

                

