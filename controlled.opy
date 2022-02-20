#!mainFile "main.opy"

#This file handles the bot's actions and is player independent to allow for automation

#!define ifAction(a) @Condition eventPlayer.Actions[a]==true\
    eventPlayer.Actions[a]=false
#!define startAction(a,ref) (ref).Actions[a]=true



rule "On Player Join":
    @Event playerJoined
    @Condition eventPlayer.isDummy()
    eventPlayer.Actions=[false,false,false,false,false,false,false,false] #moveToCPos, setTarget, use ability 1, use ability 2,use ultimate, ___ , Attach , Free
    
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
    goto RULE_START


rule "Throttling Bot":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    @Condition getPlayersInRadius(eventPlayer.MovetoPos,0.5,Team.ALL,LosCheck.OFF)
    if(eventPlayer.Owner):
        eventPlayer.Owner.MovementGroundCursor = false
    eventPlayer.stopFacing() 
    eventPlayer.stopThrottleInDirection()
    eventPlayer.ArrivedAtM2P=-1

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
                    startAction(0,eventPlayer)
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
                if(floor(eventPlayer.Target.x/10)==HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][2] and distance(vect(eventPlayer.x,0,eventPlayer.z),vect(eventPlayer.Target.y,0,eventPlayer.Target.z))<=HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][0][0]):
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


def AbilityProcess():
    if(HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][1][0]):
        eventPlayer.Mana[0]-=HeroSpecs[eventPlayer.CHero_Index][(eventPlayer.AbilityUse[1])+2][1][0]
    eventPlayer.startForcingButton(eventPlayer.AbilityUse[0])

### 0 ###
rule "MoveToCPos":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(0)
    
    if(eventPlayer.Owner != "null" and eventPlayer.Owner != 0):
        async(moveCameraWithPlayer,AsyncBehavior.RESTART)
    if(distance(eventPlayer.getPosition(),eventPlayer.MovetoPos)>1):
        eventPlayer.startThrottleInDirection(vectorTowards(eventPlayer.getEyePosition(), eventPlayer.MovetoPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.startFacing(vectorTowards(vect(eventPlayer.getEyePosition().x,eventPlayer.getEyePosition().y,eventPlayer.getEyePosition().z),vect(eventPlayer.MovetoPos.x,eventPlayer.getEyePosition().y,eventPlayer.MovetoPos.z)),600,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
    
### 1 ###
rule "Target":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(1)
    #


    #getClosestPlayer(eventPlayer.CPos, )

### 2 ###
rule "Use Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(2)
    while(eventPlayer.Target):
        if(eventPlayer.Target<1):
            #if(distance(eventPlayer.getPosition(),CPlayers[]))
  

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
    Ability_Used(Button.SECONDARY_FIRE,4)

### 6 ###
rule "Use Ult":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(6)
    Ability_Used(Button.ULTIMATE,4)         

#!include "ai.opy"          

                

