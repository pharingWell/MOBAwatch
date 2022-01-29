#!mainFile "main.opy"

#!define ifAction(a) @Condition eventPlayer.Actions[a]==true\
    eventPlayer.Actions[a]=false
#!define startAction(a,ref) (ref).Actions[a]=true

rule "On Player Join":
    @Event playerJoined
    @Condition eventPlayer.isDummy()
    eventPlayer.Actions=[false,false,false,false,false,false,false,false] #moveToCPos, setTarget, use ability 1, use ability 2,use ultimate, 


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

rule "MoveToCPos":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(0)
    if(eventPlayer.Owner != "null" and eventPlayer.Owner != 0):
        async(moveCameraWithPlayer,AsyncBehavior.RESTART)
    eventPlayer.startThrottleInDirection(vectorTowards(eventPlayer.getEyePosition(), eventPlayer.CPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.startFacing(vectorTowards(vect(eventPlayer.getEyePosition().x,eventPlayer.getEyePosition().y,eventPlayer.getEyePosition().z),vect(eventPlayer.CPos.x,eventPlayer.getEyePosition().y,eventPlayer.CPos.z)),400,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
    

rule "Target":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    ifAction(1)
    #getAllHeroes().index(eventPlayer.CHero)
    eventPlayer.startFacing(vectorTowards(vect(eventPlayer.getEyePosition().x,eventPlayer.getEyePosition().y,eventPlayer.getEyePosition().z),vect(eventPlayer.Target.y,eventPlayer.getEyePosition().y,eventPlayer.Target.z)),400,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
    if(distance(eventPlayer,eventPlayer.Owner.cursor)>HeroSpecs[0][2]):
        eventPlayer.CPos=directionTowards(eventPlayer.Owner.cursor,eventPlayer)*HeroSpecs[0][2]+eventPlayer.Owner.cursor
        startAction(0,eventPlayer.ControlledRef)