#!mainFile "main.opy"
# rule "Movement Automation":
#     @Event eachPlayer
#     @Condition eventPlayer.isDummy() and not eventPlayer.Owner
#     eventPlayer.ArrivedAtM2P=0
#     eventPlayer.MovetoPos=vect(random.randint(10,-10),0,random.randint(10,-10))
#     startAction(0,eventPlayer)
#     wait(random.randint(1,10)/100)
#     #eventPlayer.startThrottleInDirection(vectorTowards(eventPlayer.getEyePosition(), eventPlayer.MovetoPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
#     waitUntil(eventPlayer.ArrivedAtM2P==-1,99)
#     top

rule "Idle Basic Attack":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
    @Condition (not eventPlayer.Target) or (distanceToTarget>HeroSpecs[eventPlayer.CHero_Index][2][0])
    @Condition eventPlayer.getSpeed()==0 or eventPlayer.AttackMove
    eventPlayer.TargetHandling=[eventPlayer.getPosition(),(HeroSpecs[eventPlayer.CHero_Index][2][0])]
    # Target_Func()
    # if(eventPlayer.Target[0]):
    #     StopThrottle()
    #     eventPlayer.Target[2]=[false,false]
    #     wait(0.3)
    #     #startAction(2,eventPlayer)
    #     waitUntil(not eventPlayer.Target,99)
    # if(eventPlayer.AttackMove):
    #     eventPlayer.MovetoPos=eventPlayer.AttackMove
    #     startAction(0,eventPlayer)
    # wait()
    # if(RULE_CONDITION):
    #     goto RULE_START
        /*
        else:
        for(eventPlayer.Target_i in range(len(0,CPlayers[2-eventPlayer.Team]))):
            if(distance(CPlayers[][eventPlayer.Target_i],eventPlayer)<10
    if(RULE_CONDITION):
        goto RULE_START*/

# rule "Drop idle-target on distance":
#     @Event eachPlayer
#     @Condition Ready==true
#     @Condition eventPlayer.isDummy()
#     @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
#     @Condition (distanceToTarget>HeroSpecs[eventPlayer.CHero_Index][HeroStat.BASIC][0]*1.5 and eventPlayer.Target)
#     wait(0.1)
#     if(eventPlayer.Target[2]==[false,false]):
#         eventPlayer.Target=null


rule "Run Action Queue":
    #this processes the first item in the action queue, replacing the index with false afterwards
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
    @Condition eventPlayer.Action == 0
    @Condition len(eventPlayer.ActionQueue[ActionQueueVal.I0])>ActionQueueVal.I0
    eventPlayer.Action = eventPlayer.ActionQueue[ActionQueueVal.I0][ActionInfo.NUMBER]
    eventPlayer.ActionQueue[ActionQueueVal.LASTABILTIME] = getTotalTimeElapsed()
    waitUntil(eventPlayer.Hero_Ability[0]==AbilityStage.COMPLETE or eventPlayer.clearQueue,100)
    waitUntil(eventPlayer.ActionQueue[ActionQueueVal.I0][ActionInfo.ABILMINTIME]+eventPlayer.ActionQueue[ActionQueueVal.LASTABILTIME] < getTotalTimeElapsed(),100)
    #waits min time elapsed
    if(eventPlayer.clearQueue):
        smallMessage(hostPlayer,"Cancelled")
    else:
        del eventPlayer.ActionQueue[ActionQueueVal.I0]
    eventPlayer.Action = 0
    wait()
    if(RULE_CONDITION):
        goto RULE_START
