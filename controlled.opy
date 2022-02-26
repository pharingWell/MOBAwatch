#!mainFile "main.opy"

#This file handles the bot's actions and is player independent to allow for automation

#!define ifAction(a) @Condition eventPlayer.Actions[a]==true\
    eventPlayer.Actions[a]=false
#!define startAction(a,ref) (ref).Actions[a]=true



rule "On Player Join - Ignores respawn":
    @Event playerJoined
    @Condition eventPlayer.isDummy()
    eventPlayer.Actions=[false,false,false,false,false,false,false,false] #moveToCPos, setTarget, use ability 1, use ability 2,use ultimate, ___ , Attach , Free
    createInWorldText(null if not eventPlayer.isAlive() else getAllPlayers() if not eventPlayer.Hidden else getPlayers(eventPlayer.getTeam()),"{}\n|{}|{}|{}|{}|\n{}".format("            <•>" if not eventPlayer.Hidden else " ", 
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])))), __substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.Health[1])*100%5),(eventPlayer.Health[0]/eventPlayer.Health[1])<0.25), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.Health[1])>0)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1]))),5)),
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.25))),__substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.Health[1])*100%5),(eventPlayer.Health[0]/eventPlayer.Health[1])<0.5 and (eventPlayer.Health[0]/eventPlayer.Health[1])>=0.25), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.Health[1])>=0.25)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.25)),5)),
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.5))), __substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.Health[1])*100%5),(eventPlayer.Health[0]/eventPlayer.Health[1])<0.75 and (eventPlayer.Health[0]/eventPlayer.Health[1])>=0.5), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.Health[1])>=0.5)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.5)),5)),
    "{0}{1}{2}".format(__substring__("IIIII",0,-0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.75))),__substring__("-..::I",ceil((eventPlayer.Health[0]/eventPlayer.Health[1])*100%5),(eventPlayer.Health[0]/eventPlayer.Health[1])<1 and (eventPlayer.Health[0]/eventPlayer.Health[1])>=0.75), __substring__("-----",((eventPlayer.Health[0]/eventPlayer.Health[1])>=0.75)*0.5+min(5,20*max(0,(eventPlayer.Health[0]/eventPlayer.Health[1])-0.75)),5)),
    "{}{}".format("                 \b.|".substring(0, 3 * (max(0, 6.25 - strLen("{0}".format(eventPlayer)) / 2))), "{0}".format(eventPlayer))),updateEveryTick(vect(eventPlayer.getEyePosition().x,eventPlayer.getEyePosition().y+0.0,eventPlayer.getEyePosition().z+0.1)),1,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.GREEN if(localPlayer==eventPlayer.Owner) else Color.TEAM_1 if localPlayer.Owner.Team==1 else Color.TEAM_2,SpecVisibility.NEVER)
    eventPlayer.ControlledRef.Level=1

rule "On Player Join - Pre-spawn":
    @Event eachPlayer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()==false
    @Condition eventPlayer.isAlive()==true
    eventPlayer.CHero=ForcedHero
    eventPlayer.stopForcingCurrentHero()
    wait()
    eventPlayer.startForcingHero(eventPlayer.CHero)
    eventPlayer.CHero_Index=getAllHeroes().index(eventPlayer.CHero)
    eventPlayer.Mana=[HeroSpecs[eventPlayer.CHero_Index][0][1],HeroSpecs[eventPlayer.CHero_Index][0][1],1]
    eventPlayer.Health=[HeroSpecs[eventPlayer.CHero_Index][0][0],HeroSpecs[eventPlayer.CHero_Index][0][0],1]
    eventPlayer.DamageModifiers=HeroSpecs[eventPlayer.CHero_Index][0][3]
    print("{},{},[{},{},{}]".format(eventPlayer.Health[0],eventPlayer.Health[1],eventPlayer.Health[2][0],eventPlayer.Health[2][1],eventPlayer.Health[2][2]))


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


rule "Throttling Bot":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    @Condition getPlayersInRadius(eventPlayer.MovetoPos,0.5,eventPlayer.getTeam(),LosCheck.OFF)
    Throttle()

def Throttle():
    if(eventPlayer.Owner):
        eventPlayer.Owner.MovementGroundCursor = false
    eventPlayer.stopFacing() 
    eventPlayer.stopThrottleInDirection()
    eventPlayer.ArrivedAtM2P=-1

def CalcDealt():
    #eventPlayer.HealthQueue[0][0] will always be 0
    if(eventPlayer.HealthQueue[1][0].Health):#checks if target is a player
        if(eventPlayer.HealthQueue[1][0].isAlive()):
            if(eventPlayer.HealthQueue[1][1]>0): #damage
                eventPlayer.HealthQueue[1][0].Health[0]-=(eventPlayer.HealthQueue[1][1])*(1-eventPlayer.DamageModifiers[0]/100) * (eventPlayer.DamageModifiers[1] if eventPlayer.DamageModifiers[1]>0 else 1)  * (1-eventPlayer.HealthQueue[1][0].DamageModifiers[2]/100) * (1+eventPlayer.HealthQueue[1][0].DamageModifiers[3]/100)
                eventPlayer.HealthQueue[1][0].Health[3]=[eventPlayer,eventPlayer.HealthQueue[1][0].Health[3][1]]
                if(eventPlayer.HealthQueue[1][0].Health[0]<1):
                    goto freetarget
            elif(eventPlayer.HealthQueue[1][1]<0): #healing
                eventPlayer.HealthQueue[1][0].Health[0]+=(abs(eventPlayer.HealthQueue[1][1])*eventPlayer.HealingModifiers[0])
                eventPlayer.HealthQueue[1][0].Health[3]=[eventPlayer.HealthQueue[1][0].Health[3][0],eventPlayer]
            else:
                println("{} tried to deal 0 damage to {}".format(eventPlayer,eventPlayer.HealthQueue[1][0]))
        else:
            freetarget:
            eventPlayer.Target=null
    else:
        #thing to disconnect minions as targets goes here
        if(eventPlayer.HealthQueue[1][1]>0): #minions cannot be healed
            HealthChange.append(vect(eventPlayer.HealthQueue[1][0],(eventPlayer.HealthQueue[1][1] * (1-eventPlayer.DamageModifiers[2])/100 * (1+eventPlayer.DamageModifiers[3]/100)),eventPlayer.Slot))
    del eventPlayer.HealthQueue[1]

#!define Ability_Used(button,abilitynum) eventPlayer.AbilityUse=[(button),(abilitynum)]\
    AbilityUsedFunc()\
    eventPlayer.AbilityUse=[]
def AbilityUsedFunc(): /*use ability is run as the ref, and can be used while automating eventPlayer.AbilityUse[0]=button,eventPlayer.AbilityUse[1]=abilitynum*/
    if(((eventPlayer.getAbilityCooldown(eventPlayer.AbilityUse[0])<=0.1 or eventPlayer.getAbilityCharge(eventPlayer.AbilityUse[0])>0) or not eventPlayer.AbilityUse[0]==Button.ULTIMATE) or (eventPlayer.getUltCharge()>99.5 and (eventPlayer.AbilityUse[0])==Button.ULTIMATE)):
        if(eventPlayer.Mana[0]>=HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][1][0] or not HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][1][0]): # mana
            if(HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][3]>0 and distance(eventPlayer.CPos,eventPlayer)>HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][3]):
                eventPlayer.ArrivedAtM2P=1
                eventPlayer.MovetoPos=eventPlayer.CPos+directionTowards(eventPlayer.CPos,eventPlayer)*HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][3]/*starts at cpos and moves player to closest point within range*/
                    eventPlayer.Hero_Ability[0]=AbilityStage.MOVETO
                    startAction(1,eventPlayer)
                    waitUntil(eventPlayer.ArrivedAtM2P==-1 or eventPlayer.MoveAbilityCancel,99)
            if(HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][1]==CastType.GROUND): /*is ability looking at ground*/
                eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.CPos.x,0,eventPlayer.CPos.z)),9999,Relativity.TO_WORLD,FacingReeval.NONE)
            elif(HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][1]==CastType.DIRECTION): /*is ability looking at ground*/
                if(eventPlayer.Owner):
                    eventPlayer.CPos=eventPlayer.Owner.cursor
                eventPlayer.stopFacing()
                eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.CPos.x,eventPlayer.getEyePosition().y,eventPlayer.CPos.z)),Relativity.TO_WORLD)
            elif(HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][2]!=TargetState.NONE): /*is targeted*/ 
                /*if(HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][2]=TargetState.ENEMY)*/
                if(floor(eventPlayer.Target[0].x/10)==HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][2] and distance(vect(eventPlayer.x,0,eventPlayer.z),vect(eventPlayer.Target[0].y,0,eventPlayer.Target[0].z))<=HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][0]):
                    smallMessage(eventPlayer,"Targeted Ability{0} Activated".format(eventPlayer.AbilityUse[1]))
            if(eventPlayer.MoveAbilityCancel==false):
                if(eventPlayer.Hero_Ability[0]!=AbilityStage.MOVETO):/*ensures any onmove ui removal still takes place*/
                    eventPlayer.Hero_Ability[0]=AbilityStage.MOVETO
                    wait()
                if(not HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][1][0] or eventPlayer.Mana[0]-HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][1][0]>0):
                    eventPlayer.Mana[0]-=HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][1][0]
                else:
                    goto cancelled
                eventPlayer.Hero_Ability[1]=eventPlayer.AbilityUse[1]
                eventPlayer.Hero_Ability[0]=AbilityStage.CAST
                
            else:
                goto cancelled
            wait(0.1)
            eventPlayer.stopFacing()
        else:
            if(eventPlayer.Owner):
                smallMessage(eventPlayer.Owner,"Out of mana")
            goto cancelled
    return
    cancelled:
        eventPlayer.MoveAbilityCancel=false
        eventPlayer.AbilityVerify=[true,true]
        eventPlayer.Hero_Ability[0]=AbilityStage.NONE
        eventPlayer.ClearAllUI=true
        clearEffectUI()
        eventPlayer.AbilityVerify=[false,false]


def AbilityProcess():
    if(HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][1][0]):
        eventPlayer.Mana[0]-=HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][1][0]
    eventPlayer.startForcingButton(eventPlayer.AbilityUse[0])

rule "Reset Actions":
    @Event eachPlayer
    @Condition Ready==true
    @Condition any(eventPlayer.Actions)
    #stop basic attack
    if(not eventPlayer.Actions[0]):
        eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    wait(0.2)
    eventPlayer.Actions=[]

rule "Stop Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.Target==null
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)

### 0 ###
rule "MoveToCPos - Internal":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(0)
    if(eventPlayer.Owner != "null" and eventPlayer.Owner != 0):
        async(moveCameraWithPlayer,AsyncBehavior.RESTART)
    if(distance(eventPlayer.getPosition(),eventPlayer.MovetoPos)>1):
        eventPlayer.startThrottleInDirection(vectorTowards(eventPlayer.getEyePosition(), eventPlayer.MovetoPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    if(not HeroSpecs[eventPlayer.CHero_Index][2][3]):
        eventPlayer.startFacing(vectorTowards(eventPlayer.getEyePosition(),vect(eventPlayer.MovetoPos.x,eventPlayer.getEyePosition().y,eventPlayer.MovetoPos.z)),450+200*(distance(eventPlayer.getPosition(),eventPlayer.MovetoPos) < 3),Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
### 1 ###
rule "MoveToCPos - Normal Call":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(1)
    if(eventPlayer.ControlledRef.ArrivedAtM2P==1):
        eventPlayer.ControlledRef.ArrivedAtM2P=0
        eventPlayer.ControlledRef.MoveAbilityCancel=true
        return
    #if auto lock is on and within range
    startAction(0,eventPlayer)
    if(not HeroSpecs[eventPlayer.CHero_Index][2][3]):
        eventPlayer.Target=null
        eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    else:
        if(not eventPlayer.Target or distance(eventPlayer.CPos,eventPlayer.getPosition())>HeroSpecs[eventPlayer.CHero_Index][2][0]+0.5):
            eventPlayer.startFacing(vectorTowards(eventPlayer.getEyePosition(),vect(eventPlayer.MovetoPos.x,eventPlayer.getEyePosition().y,eventPlayer.MovetoPos.z)),450+200*(distance(eventPlayer.getPosition(),eventPlayer.MovetoPos) < 3),Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE) 
            eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
        elif(distance(eventPlayer.Target[1].getPosition(),eventPlayer.getPosition())<=HeroSpecs[eventPlayer.CHero_Index][2][0]-0.5):
            eventPlayer.startFacing(vectorTowards(eventPlayer.getEyePosition(),vect(eventPlayer.CPos.x,eventPlayer.Target[1].getEyePosition().y/([eventPlayer.CHero_Index][2][0]) if eventPlayer.Target[1] else 0,eventPlayer.CPos.z)),450,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE) 

#!define BasicAttackExceptions []

### 2 ###
rule "Use Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(2)
    eventPlayer.setAmmo(0,2000)
    while(eventPlayer.Target[0].x>0):
        
        if(eventPlayer.Target[1]):
            eventPlayer.CPos=eventPlayer.Target[1].getPosition()
            if(not eventPlayer.CPos):
                println("Error with entity in Target ref")
                return
        elif(eventPlayer.Target[0].x>=10)::
            eventPlayer.CPos=vect(NonPlayer_Loc[NonPLoc(eventPlayer.Target[0].x)].y,0,NonPlayer_Loc[NonPLoc(eventPlayer.Target[0].x)].z) #turns id to coords
        else:
            println("Entity has broken ref or id. Id of >10 missing entity ref")
            return #for some reason, the dummy bot was deleted and we have a broken ref
        eventPlayer.stopFacing()
        if(not HeroSpecs[eventPlayer.CHero_Index][2][3]):
            if(distance(eventPlayer.getPosition(),eventPlayer.CPos)>HeroSpecs[eventPlayer.CHero_Index][2][0]-0.5):
                eventPlayer.MovetoPos=eventPlayer.CPos+directionTowards(eventPlayer.CPos,eventPlayer.getPosition())*(HeroSpecs[eventPlayer.CHero_Index][2][0]-0.5)/*starts at cpos and moves player to closest point within range*/
                startAction(0,eventPlayer)
            else:
                eventPlayer.setFacing(directionTowards(eventPlayer.CPos,eventPlayer.getEyePosition()),Relativity.TO_WORLD)
            #eventPlayer.startFacing(directionTowards(eventPlayer.CPos,eventPlayer.getEyePosition()),600,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
        waitUntil(not eventPlayer.Target[0].x>0 or distance(eventPlayer.getPosition(), eventPlayer.Target[1].getPosition() if eventPlayer.Target[1] else vect(NonPlayer_Loc[NonPLoc(eventPlayer.Target[0])].y,0.5,NonPlayer_Loc[NonPLoc(eventPlayer.Target[0])].z))<=HeroSpecs[eventPlayer.CHero_Index][2][0]+0.6,9999)
        if(not eventPlayer.Target[0].x>0):
            eventPlayer.Target=null
            return 
        #if we have made it this far, we are in range or 170 minutes have passed
        if(eventPlayer.Target[1]):
            eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.Target[1].getEyePosition().x,eventPlayer.Target[1].getEyePosition().y/([eventPlayer.CHero_Index][2][0]),eventPlayer.Target[1].getEyePosition().z)),Relativity.TO_WORLD)
        else:
            eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(),eventPlayer.CPos),Relativity.TO_WORLD)
        if(not eventPlayer.Target[1] or eventPlayer.isInViewAngle(eventPlayer.CPos,45)):
            if(eventPlayer.CHero in BasicAttackExceptions):
                eventPlayer.Hero_Ability[1]=0
                eventPlayer.Hero_Ability[0]=AbilityStage.CAST
            else:
                if(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)):
                    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
            deal(eventPlayer.Target[1] if eventPlayer.Target[1] else eventPlayer.Target[0].x,HeroSpecs[eventPlayer.CHero_Index][2][1])
            waitUntil(not eventPlayer.Target[0].x>0,1/HeroSpecs[eventPlayer.CHero_Index][2][2]*1)
        else:
            wait(0.01)
        

### 3 ###
rule "Use Ability 1":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(3)
    Ability_Used(Button.ABILITY_1,1)
    
### 4 ###
rule "Use Ability 2":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(4)
    Ability_Used(Button.ABILITY_2,2)

### 5 ###
rule "Use Secondary (e)":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(5)
    Ability_Used(Button.SECONDARY_FIRE,3)

### 6 ###
rule "Use Ult":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(6)
    if(eventPlayer.CHero not in [Hero.MOIRA,Hero.BRIGITTE,Hero.WIDOWMAKER,Hero.TORBJORN]):
        Ability_Used(Button.ULTIMATE,4)         


rule "dmg/heal OT":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    wait(0.2)
    if(eventPlayer.Health[2][1]>0):
        if(not eventPlayer.Health[2][2]):
            eventPlayer.Health[2]=[eventPlayer.Health[2][0],eventPlayer.Health[2][1],eventPlayer.Health[2][0]/eventPlayer.Health[2][1]]
        eventPlayer.Health[2]=[eventPlayer.Health[2][2]*(eventPlayer.Health[2][1]-0.2),eventPlayer.Health[2][1]-0.2,eventPlayer.Health[2][2]]
        if(eventPlayer.Health[0]+eventPlayer.Health[2][2]/5<eventPlayer.Health[1]):
            eventPlayer.Health[0]+=(eventPlayer.Health[2][2]/5)

    else:
        eventPlayer.Health[2]=null
    top
    

rule "(Re)spawn":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    eventPlayer.Health[0]=eventPlayer.Health[1]
    eventPlayer.Health[4]=[null,null]
    
### Death ###
rule "Is Dead":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.Health[0]<=0
    #eventPlayer.Hidden=true
    eventPlayer.Target=null
    eventPlayer.stopThrottleInDirection()
    eventPlayer.stopFacing()
    eventPlayer.setRespawnTime(eventPlayer.Level*2+4)
    eventPlayer.setDamageReceived(1)
    kill(eventPlayer,eventPlayer.Health[3][0].Owner)
    eventPlayer.setDamageReceived(0)


#!include "ai.opy"          

                

