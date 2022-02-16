#!mainFile "../main.opy"
#you can declare hero specific variables here. Do not make them global
rule "Hero - Init":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    
rule "Hero - UI Prep":
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

rule "Hero - UI MoveTo":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.MOVETO #show ui for
    clearEffectUI()
    #does not pass to cast for obvious reasons

rule "Hero - Cast":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.CAST #otherwise show ui
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:
        case 1:
            
            eventPlayer.startThrottleInDirection(eventPlayer.getFacingDirection(),1,Relativity.TO_WORLD,Throttle.REPLACE_EXISTING,ThrottleReeval.NONE)
            Ability(Button.ABILITY_1,false)
            wait(0.1)
            if(eventPlayer.Owner):
                if(not eventPlayer.Owner.isHoldingButton(Button.SECONDARY_FIRE)):
                    eventPlayer.stopThrottleInDirection()
                eventPlayer.Owner.MovementGroundCursor=false
                eventPlayer.Owner.CamLoc=vect(eventPlayer.getPosition().x,eventPlayer.Owner.CamLoc.y,eventPlayer.getPosition().z)
            break
        case 2:
            Ability(Button.ABILITY_2,false)
            wait(0.6)
            eventPlayer.MovetoPos=(eventPlayer.getPosition())
            if(eventPlayer.Owner):
                eventPlayer.Owner.CamLoc=vect(eventPlayer.getPosition().x,eventPlayer.Owner.CamLoc.y,eventPlayer.getPosition().z)
            break
        case 3:
            Ability(Button.RELOAD,false)
            break
        case 4:
            Ability(Button.ULTIMATE,false)
            break


rule "Hero - Complete":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.COMPLETE 
    clearEffectUI()
    eventPlayer.Hero_Ability[0]=AbilityStage.NONE
