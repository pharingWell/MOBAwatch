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
    eventPlayer.startForcingHero(eventPlayer.CHero.Owner)
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
    destroyInWorldText(eventPlayer.Owner.MovementGroundCursor)
    eventPlayer.stopFacing() 
    eventPlayer.stopThrottleInDirection()
    eventPlayer.i=-1


### 0 ###
rule "MoveToCPos":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(0)
    if(eventPlayer.Owner != "null" and eventPlayer.Owner != 0):
        async(moveCameraWithPlayer,AsyncBehavior.RESTART)
    eventPlayer.startThrottleInDirection(vectorTowards(eventPlayer.getEyePosition(), eventPlayer.MovetoPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.startFacing(vectorTowards(vect(eventPlayer.getEyePosition().x,eventPlayer.getEyePosition().y,eventPlayer.getEyePosition().z),vect(eventPlayer.MovetoPos.x,eventPlayer.getEyePosition().y,eventPlayer.MovetoPos.z)),400,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
    
### 1 ###
rule "Target":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(1)
    #
    eventPlayer.startFacing(vectorTowards(vect(eventPlayer.getEyePosition().x,eventPlayer.getEyePosition().y,eventPlayer.getEyePosition().z),vect(eventPlayer.Target.y,eventPlayer.getEyePosition().y,eventPlayer.Target.z)),400,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
    if(distance(eventPlayer,eventPlayer.Owner.cursor)>HeroSpecs[eventPlayer.CHero_Index][2]):
        eventPlayer.MovetoPos=directionTowards(eventPlayer.Owner.cursor,eventPlayer)*HeroSpecs[eventPlayer.CHero_Index][2]+eventPlayer.Owner.cursor
        startAction(0,eventPlayer.ControlledRef)

#!defineMember Ability_Cast(button,abilitynum) /*use ability is run as the ref, and can be used while automating*/\
    if((eventPlayer.getAbilityCooldown(button)<=0.1 and not (button)==Button.ULTIMATE) or (eventPlayer.getUltCharge()>99.5 and (button)==Button.ULTIMATE)):\
        if(HeroSpecs[eventPlayer.CHero_Index][(abilitynum)+2][3]>0 and distance(eventPlayer.CPos,eventPlayer)>HeroSpecs[eventPlayer.CHero_Index][(abilitynum)+2][3]):\
            eventPlayer.i=0\
            eventPlayer.MovetoPos=eventPlayer.CPos+directionTowards(eventPlayer.CPos,eventPlayer)*HeroSpecs[eventPlayer.CHero_Index][(abilitynum)+2][3]/*starts at cpos and moves player to closest point within range*/\
                startAction(0,eventPlayer)\
                waitUntil(eventPlayer.i==-1,99)\
        if(HeroSpecs[eventPlayer.CHero_Index][(abilitynum)+2][1]==CastType.GROUND): /*is ability looking at ground*/\
            eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.CPos.x,0,eventPlayer.CPos.z)),9999,Relativity.TO_WORLD,FacingReeval.NONE)\
        elif(HeroSpecs[eventPlayer.CHero_Index][(abilitynum)+2][2]!=TargetState.NONE): /*is targeted*/ \
            /*if(HeroSpecs[eventPlayer.CHero_Index][(abilitynum)+2][2]=TargetState.ENEMY)*/\
            if(floor(eventPlayer.Target.x/10)==HeroSpecs[eventPlayer.CHero_Index][(abilitynum)+2][2] and distance(vect(eventPlayer.x,0,eventPlayer.z),vect(eventPlayer.Target.y,0,eventPlayer.Target.z))<=HeroSpecs[eventPlayer.CHero_Index][(abilitynum)+2][0]):\
                smallMessage(eventPlayer,"Targeted Ability{0} Activated".format(abilitynum))\
        eventPlayer.Hero_Ability[0]=AbilityState.CAST\
        eventPlayer.Hero_Ability[1]=abilitynum\
        wait(0.1)\
        eventPlayer.stopFacing()\

### 2 ###
rule "Use Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(2)
    print("basic")               

### 3 ###
rule "Use Ability 1":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(3)
    Ability_Cast(Button.ABILITY_1,1)
    
### 4 ###
rule "Use Ability 2":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(4)
    Ability_Cast(Button.ABILITY_2,2)   
### 5 ###
rule "Use Ult":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(5)
    Ability_Cast(Button.ULTIMATE,3)         

            

                

