#!mainFile "main.opy"
rule "Movement Automation":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() and not eventPlayer.Owner
    eventPlayer.ArrivedAtM2P=0
    eventPlayer.MovetoPos=vect(random.randint(10,-10),0,random.randint(10,-10))
    startAction(0,eventPlayer)
    wait(random.randint(1,10)/100)
    #eventPlayer.startThrottleInDirection(vectorTowards(eventPlayer.getEyePosition(), eventPlayer.MovetoPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    waitUntil(eventPlayer.ArrivedAtM2P==-1,99)
    top

rule "Idle Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
    @Condition (not eventPlayer.Target) or (distanceToTarget>HeroSpecs[eventPlayer.CHero_Index][2][0])
    @Condition eventPlayer.getSpeed()==0
    eventPlayer.TargetHandling=[eventPlayer.getPosition(),(HeroSpecs[eventPlayer.CHero_Index][2][0])]
    Target()
    if(eventPlayer.Target[0]):
        eventPlayer.Target[2]=[false,false]
        wait(0.3)
        startAction(2,eventPlayer)
        waitUntil(not eventPlayer.Target,99)
    
        /*
        else:
        for(eventPlayer.Target_i in range(len(0,CPlayers[2-eventPlayer.Team]))):
            if(distance(CPlayers[][eventPlayer.Target_i],eventPlayer)<10
    if(RULE_CONDITION):
        goto RULE_START*/