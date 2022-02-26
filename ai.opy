#!mainFile "main.opy"
rule "Movement Automation":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() and not eventPlayer.Owner
    eventPlayer.MovetoPos=vect(random.randint(10,-10),0,random.randint(10,-10))
    waitUntil(eventPlayer.ArrivedAtM2P==-1,99)

rule "Idle Basic Attack":
    @Event eachPlayer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    @Condition Ready
    @Condition eventPlayer.getSpeed()<0.5
    @Condition not eventPlayer.Target[0]
    waitUntil(eventPlayer.getSpeed()>0.5,0.1)
    if(eventPlayer.getSpeed()<0.5 and not eventPlayer.Target[0] and not HeroSpecs[eventPlayer.CHero_Index][2][3]):
        eventPlayer.Temp_DistanceSort=[]
        for eventPlayer.Target_i in range(0,len(CPlayers[1-eventPlayer.Team])):
            eventPlayer.Temp_DistanceSort[eventPlayer.Target_i]=(vect(1-eventPlayer.Team+eventPlayer.Target_i/100,CPlayers[1-eventPlayer.Team][eventPlayer.Target_i].getPosition().x,CPlayers[1-eventPlayer.Team][eventPlayer.Target_i].getPosition().z))
        eventPlayer.Temp_DistanceSort=sorted(eventPlayer.Temp_DistanceSort.concat(random.shuffle(NonPlayer_Loc.slice((eventPlayer.Team-1)*48,eventPlayer.Team*48))), lambda i: (abs(eventPlayer.getPosition().x-i.y))**2 + (abs(eventPlayer.getPosition().z-i.z))**2)
        if((abs(eventPlayer.getPosition().x-eventPlayer.Temp_DistanceSort[0].y))**2 + (abs(eventPlayer.getPosition().z-eventPlayer.Temp_DistanceSort[0].z))**2<HeroSpecs[eventPlayer.CHero_Index][2][0]**2):
            if(eventPlayer.Temp_DistanceSort[0].x<10):
                eventPlayer.Target[3] = [true,CPlayers[floor(eventPlayer.Temp_DistanceSort[0].x)][eventPlayer.Temp_DistanceSort[0].x%1*100],eventPlayer.Temp_DistanceSort[0]]
            else:
                eventPlayer.Target[3] = [true,null,eventPlayer.Temp_DistanceSort[0]]#if minion

            while(eventPlayer.Target[3][1].isAlive() if eventPlayer.Target[3][1] else MinionByID(eventPlayer.Target[3][2].x)[4]==true if (eventPlayer.Target[3][2].x<12) else false):
                if(eventPlayer.Target[3][1]):
                    eventPlayer.CPos=eventPlayer.Target[3][1].getPosition()
                    if(not eventPlayer.CPos):
                        println("Error with entity in Target ref (Idle)")
                        return
                elif(eventPlayer.Target[3][2].x>=10):
                    eventPlayer.CPos=vect(NonPlayer_Loc[NonPLoc(eventPlayer.Target[3][2].x)].y,0,NonPlayer_Loc[NonPLoc(eventPlayer.Target[3][2].x)].z) #turns id to coords
                else:
                    println("Entity has broken ref or id. Id of >10 missing entity ref (Idle)")
                if(distance(eventPlayer.getPosition(),eventPlayer.CPos)<HeroSpecs[eventPlayer.CHero_Index][2][0]+0.5):
                    if(eventPlayer.Target[3][1]):
                        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(),vect(eventPlayer.Target[3][1].getEyePosition().x,eventPlayer.Target[3][1].getEyePosition().y/([eventPlayer.CHero_Index][2][0]),eventPlayer.Target[3][1].getEyePosition().z)),Relativity.TO_WORLD)
                    else:
                        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(),eventPlayer.CPos),Relativity.TO_WORLD)
                    if(not eventPlayer.Target[3][1] or eventPlayer.isInViewAngle(eventPlayer.CPos,45)):
                        if(eventPlayer.CHero in BasicAttackExceptions):
                            eventPlayer.Hero_Ability[1]=0
                            eventPlayer.Hero_Ability[0]=AbilityStage.CAST
                        else:
                            if(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)):
                                eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
                        deal((eventPlayer.Target[3][1] if eventPlayer.Target[3][1] else eventPlayer.Target[3][2].x),HeroSpecs[eventPlayer.CHero_Index][2][1])
                        waitUntil(not eventPlayer.Target[3][2].x>0,1/HeroSpecs[eventPlayer.CHero_Index][2][2]*1)
                    else:
                        wait(0.01)
                if(not eventPlayer.Target[3][0]):
                    return
        wait(0.1)
        if(RULE_CONDITION):
            goto RULE_START
        
