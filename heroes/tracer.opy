#!mainFile "../main.opy"
#you can declare hero specific variables here. Do not make them global
#!define TracerRecall HeroSpecificVar1 /*[health,anything else]*/
rule "Tracer - Init ":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    eventPlayer.TracerRecall=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] #array with length 30, each for a 0.1s time interval

rule "Tracer - Recall ":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    @Condition getTotalTimeElapsed()%0.1==0
    eventPlayer.TracerRecall[30]=[eventPlayer.Health,1]
    eventPlayer.TracerRecall=eventPlayer.TracerRecall.slice(1,30)
    
rule "Tracer - UI Prep":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.PREP #show ui for
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:
        /*
        case 1:
            break
        */
        /*
        case 2:
            break
        */
        /*
        case 3:
            break
        */
        /*
        case 4:
            break
        */  
        default:
            defaultEffectUI()

rule "Tracer - UI MoveTo":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.MOVETO #show ui for
    clearEffectUI()
    #does not pass to cast for obvious reasons

rule "Tracer - Cast":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.CAST #otherwise show ui
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:
        case 1:
            eventPlayer.startThrottleInDirection(eventPlayer.LookAtPos,1,Relativity.TO_WORLD,Throttle.REPLACE_EXISTING,ThrottleReeval.NONE)
            Ability(Button.ABILITY_1)
            wait()
            if(eventPlayer.Owner):
                if(not eventPlayer.Owner.isHoldingButton(Button.SECONDARY_FIRE)):
                    eventPlayer.stopThrottleInDirection()
                eventPlayer.Owner.MovementGroundCursor=false
                if(eventPlayer.Owner.CamAttach):
                    eventPlayer.Owner.CamLoc=vect(eventPlayer.getPosition().x,eventPlayer.Owner.CamLoc.y,eventPlayer.getPosition().z)
            else:
                eventPlayer.stopThrottleInDirection()
            break
        case 2:
            Ability(Button.ABILITY_2)
            wait(0.6)
            eventPlayer.MovetoPos=(eventPlayer.getPosition())
            if(eventPlayer.Owner):
                eventPlayer.Owner.CamLoc=vect(eventPlayer.getPosition().x,eventPlayer.Owner.CamLoc.y,eventPlayer.getPosition().z)
            wait(0.65)
            eventPlayer.Health[0]=sorted(eventPlayer.TracerRecall,lambda x: eventPlayer.Health[1]-x[0])[0][0]
            break
        case 3:
            Ability(Button.RELOAD)
            break
        case 4:
            Ability(Button.ULTIMATE)
            break


rule "Tracer - Complete":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.COMPLETE 
    clearEffectUI()
    eventPlayer.Hero_Ability[0]=AbilityStage.NONE
