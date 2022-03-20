#!mainFile "../main.opy"
#you can declare hero specific variables here. Do not make them global
rule "Hero - Init":
    @Event eachPlayer
    @Hero reaper
    @Condition eventPlayer.isDummy()
    #print("{}, {}".format(eventPlayer.Hero_Ability[0],eventPlayer.Hero_Ability[1]))
    
rule "Hero - UI Prep":
    @Event eachPlayer
    @Hero reaper
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.PREP #show ui for
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:

        /*
        case 1:
            break
        */
        
        case 2:
            AreaHighlight(Effect.RING,1)
            #eventPlayer.Owner.cursorNew=eventPlayer.MovetoPos
            defaultEffectUI()
            break
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
    @Hero reaper
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.MOVETO #show ui for
    clearEffectUI()

rule "Hero - Cast":
    @Event eachPlayer
    @Hero reaper
    @Condition eventPlayer.isDummy() 
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.CAST #otherwise show ui
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:
        case 1: 
            Ability(Button.ABILITY_1,false)
            break
        case 2:
            Ability(Button.ABILITY_2,false)
            wait()
            eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
            wait(1) #teleport camera to player after 1 sec
            if(eventPlayer.Owner and eventPlayer.isUsingAbility2() and eventPlayer.Owner.CamAttach):
                eventPlayer.Owner.CamLoc=vect(eventPlayer.CPos.x,eventPlayer.Owner.CamLoc.y,eventPlayer.CPos.z)
            break
        case 4:
            Ability(Button.ULTIMATE,false)
            wait()
            if(eventPlayer.isUsingUltimate()):
                createEffect(getAllPlayers(),Effect.RING,(Color.TEAM_1 if eventPlayer.getTeam()==Team.1 else Color.TEAM_2),updateEveryTick(vect(eventPlayer.getEyePosition().x,0,eventPlayer.getEyePosition().z)), 8, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                addUI(getLastCreatedEntity(),AbilityStage.COMPLETE)
                eventPlayer.TimerHandler=evalOnce(getTotalTimeElapsed())+HeroSpecs[0][6][2][1]
                while(eventPlayer.TimerHandler > getTotalTimeElapsed()):
                    wait(HeroSpecs[0][6][3][1])
                    damageInRadius(8,eventPlayer.getPosition(),HeroSpecs[0][6][3][0])
                    
            break
    eventPlayer.Hero_Ability[0]=AbilityStage.COMPLETE

rule "Hero - Complete":
    @Event eachPlayer
    @Hero reaper
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.COMPLETE 
    clearEffectUI()
    eventPlayer.Hero_Ability[0]=AbilityStage.NONE
