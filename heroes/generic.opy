#!mainFile "../main.opy"

rule "Heroes_Init":
    HeroSpecs=[100,100,10]#hp,mana,range
    createEffect(getAllPlayers(),Effect.RING,Color.WHITE,vect(0,0,0.01),0.75,EffectReeval.VISIBILITY)

rule "Target":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) #**2 **2
    @Condition not eventPlayer.isDummy()
    
    for i in range(TeamSize):
        if(i==0):
                eventPlayer.Temp_DistanceSort=vect(eventPlayer.ControlledRef.Team,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().x,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().z)
        else:
            eventPlayer.Temp_DistanceSort.append(vect(eventPlayer.ControlledRef.Team,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().x,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().z))
    eventPlayer.Temp_DistanceSort=sorted(random.shuffle(NonPlayer_Loc.slice((eventPlayer.ControlledRef.Team-1)*48,eventPlayer.ControlledRef.Team*48).concat(eventPlayer.Temp_DistanceSort)), lambda i: (abs(eventPlayer.cursor.x-i.y))**2 + (abs(eventPlayer.cursor.z-i.z))**2)
    #sorted([vect((eventPlayer.cursor.x-i.y)**2 + (eventPlayer.cursor.z-i.z)**2,i.x,0) for i in random.shuffle(NonPlayer_Loc)], lambda elem: elem.x)
    if((abs(eventPlayer.cursor.x-eventPlayer.Temp_DistanceSort[0].y))**2 + (abs(eventPlayer.cursor.z-eventPlayer.Temp_DistanceSort[0].z))**2<0.866):
        println("{0}, {1}".format(eventPlayer.Temp_DistanceSort[0],eventPlayer.cursor))
        eventPlayer.UICursorStyles[0]=Color.RED
        wait(0.1) 
        eventPlayer.UICursorStyles[0]=Color.WHITE
        eventPlayer.ControlledRef.startThrottleInDirection(vectorTowards(eventPlayer.ControlledRef.getPosition(),eventPlayer.Temp_DistanceSort[0]), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
        