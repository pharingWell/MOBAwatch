#!mainFile "main.opy"
rule "Movement Automation":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() and not eventPlayer.Owner
    eventPlayer.ArrivedAtM2P=0
    eventPlayer.MovetoPos=vect(random.randint(10,-10),0,random.randint(10,-10))
    #startAction(0,eventPlayer)
    wait(random.randint(1,100)/100)
    #eventPlayer.startThrottleInDirection(vectorTowards(eventPlayer.getEyePosition(), eventPlayer.MovetoPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    waitUntil(eventPlayer.ArrivedAtM2P==-1,99)
    top

rule "Idle Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.getSpeed()<0.1
    @Condition false
    eventPlayer.TargetHandling=[eventPlayer.getPosition(),HeroSpecs[eventPlayer.CHero_Index][2][0]**2]
    Target()
    if(eventPlayer.Target[0]):
        eventPlayer.Target[2]=[false,false]
        startAction(2,eventPlayer)
