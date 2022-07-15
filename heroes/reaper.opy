#!mainFile "../main.opy"
#you can declare hero specific variables here. Do not make them global
rule "Reaper - Init":
    @Event eachPlayer
    @Hero reaper
    @Condition eventPlayer.isDummy()
    #print("{}, {}".format(eventPlayer.Hero_Ability[0],eventPlayer.Hero_Ability[1]))
    
rule "Reaper - UI Prep":
    @Event eachPlayer
    @Hero reaper
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.PREP #show ui for
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:

        /*
        case AbilID.ABIL1:
            break
        */
        
        case AbilID.ABIL2:
            AreaHighlight(Effect.RING,1)
            defaultEffectUI()
            break
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

rule "Reaper - UI MoveTo":
    @Event eachPlayer
    @Hero reaper
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.MOVETO #show ui for
    clearEffectUI()

rule "Reaper - Cast":
    @Event eachPlayer
    @Hero reaper
    @Condition eventPlayer.isDummy() 
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.CAST #otherwise show ui
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:
        case AbilID.ABIL1: 
            Ability(Button.ABILITY_1)
            waitUntil(not eventPlayer.isUsingAbility1() or eventPlayer.Hero_Ability[0]==AbilityStage.CANCELLED,3)#runs until cancelled
            break
        case AbilID.ABIL2:
            Ability(Button.ABILITY_2)
            wait()
            eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
            wait(1) #teleport camera to player after 1 sec
            if(eventPlayer.Owner and eventPlayer.isUsingAbility2() and eventPlayer.Owner.CamAttach):
                eventPlayer.Owner.CamLoc=vect(eventPlayer.CPos.x,eventPlayer.Owner.CamLoc.y,eventPlayer.CPos.z)
            break
        case AbilID.ABIL4:
            Ability(Button.ULTIMATE)
            wait()
            if(eventPlayer.isUsingUltimate()):
                createEffect(getAllPlayers(),Effect.RING,(Color.TEAM_1 if eventPlayer.getTeam()==Team.1 else Color.TEAM_2),updateEveryTick(vect(eventPlayer.getEyePosition().x,0,eventPlayer.getEyePosition().z)), 8, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                addUI(getLastCreatedEntity(),AbilityStage.COMPLETE)
                eventPlayer.TimerHandler=evalOnce(getTotalTimeElapsed())+HeroSpecs[Heroes.REAPER][HeroStat.ABIL4][Abil.USE][Abil_Use.DURATION]
                while(eventPlayer.TimerHandler > getTotalTimeElapsed()):
                    wait(HeroSpecs[Heroes.REAPER][HeroStat.ABIL4][Abil.DMG][Abil_Damage.RATE])
                    damageInRadius(8,eventPlayer.getPosition(),HeroSpecs[Heroes.REAPER][HeroStat.ABIL4][Abil.DMG][Abil_Damage.AMOUNT],0)
                    
            break
    eventPlayer.Hero_Ability[0]=AbilityStage.COMPLETE

rule "Reaper - Complete":
    @Event eachPlayer
    @Hero reaper
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.COMPLETE 
    clearEffectUI()
    eventPlayer.Hero_Ability[0]=AbilityStage.NONE
