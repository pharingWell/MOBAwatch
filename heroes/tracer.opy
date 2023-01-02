#!mainFile "../main.opy"
#you can declare hero specific variables here. Do not make them global
#!define TracerRecall HeroSpecificVar1 /*[health,anything else]*/
#!define PreviousThrottle HeroSpecificVar2
rule "Tracer - Init ":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    
    
    eventPlayer.TracerRecall=[HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH],HeroSpecs[Heroes.TRACER][Base.HEALTH]] #array with length 30, each for a 0.1s time interval

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
        case AbilID.ABIL1:
            break
        */
        /*
        case AbilID.ABIL2:
            break
        */
        /*
        case AbilID.ABIL3:
            break
        */
        /*
        case AbilID.ABIL4:
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
        case AbilID.ABIL1:
            eventPlayer.startForcingThrottle(1,1,0,0,0,0)
            eventPlayer.MovementGroundCursor = true
            eventPlayer.MovetoPos=eventPlayer.LookAtDir*50+eventPlayer.getPosition()
            Ability(Button.ABILITY_1)
            #eventPlayer.stopForcingThrottle()
            #eventPlayer.Actions=0
            
            # if(eventPlayer.Owner):
            #     if(eventPlayer.Owner.isHoldingButton(Button.SECONDARY_FIRE)):
            #         eventPlayer.MovetoPos=eventPlayer.LookAtDir*25+eventPlayer.getPosition()
            #     else:
            #         
            #         eventPlayer.MovetoPos=eventPlayer.getPosition()
            #     if(eventPlayer.Owner.CamAttach):
            #         eventPlayer.Owner.CamLoc=vect(eventPlayer.getPosition().x,eventPlayer.Owner.CamLoc.y,eventPlayer.getPosition().z)
            #     startAction(0,eventPlayer)
            break
        case AbilID.ABIL2:
            Ability(Button.ABILITY_2)
            wait(0.6)
            eventPlayer.MovetoPos=(eventPlayer.getPosition())
            if(eventPlayer.Owner):
                eventPlayer.Owner.CamLoc=vect(eventPlayer.getPosition().x,eventPlayer.Owner.CamLoc.y,eventPlayer.getPosition().z)
            wait(0.65)
            eventPlayer.Health[0]=sorted(eventPlayer.TracerRecall,lambda x: eventPlayer.Health[1]-x[0])[0][0]
            break
        case AbilID.ABIL3:
            Ability(Button.RELOAD)
            break
        case AbilID.ABIL4:
            Ability(Button.ULTIMATE)
            damageInRadius(5,eventPlayer.getPosition(),HeroSpecs[Heroes.TRACER][HeroStat.ABIL4][Abil.DMG][Abil_Damage.AMOUNT],280)
            break
    eventPlayer.Hero_Ability[0]=AbilityStage.COMPLETE


rule "Tracer - Complete":
    @Event eachPlayer
    @Hero tracer
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.COMPLETE 
    clearEffectUI()
    eventPlayer.Hero_Ability[0]=AbilityStage.NONE
    switch eventPlayer.Hero_Ability[1]:
        case AbilID.ABIL1:
            wait(0.1)
            if(eventPlayer.Hero_Ability[1]!=0.15):
                eventPlayer.stopForcingThrottle()
                StopThrottle()
            break