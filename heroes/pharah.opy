#!mainFile "../main.opy"

rule "Pharah - Init":
    @Event eachPlayer
    @Hero pharah
    @Condition eventPlayer.isDummy()
    
rule "Pharah - UI Prep":
    @Event eachPlayer
    @Hero pharah
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

rule "Pharah - UI MoveTo":
    @Event eachPlayer
    @Hero pharah
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.MOVETO #show ui for
    clearEffectUI()
    #does not pass to cast for obvious reasons

rule "Pharah - Cast":
    @Event eachPlayer
    @Hero pharah
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.CAST #otherwise show ui
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:
        case 1: 
            Ability(Button.ABILITY_1)
            break
        case 2:
            Ability(Button.ABILITY_2)
            break
        case 3:
            Ability(Button.RELOAD)
            break
        case 4:
            Ability(Button.ULTIMATE)
            break
    eventPlayer.Hero_Ability[0]=AbilityStage.COMPLETE

rule "Pharah - Complete":
    @Event eachPlayer
    @Hero pharah
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.COMPLETE 
    clearEffectUI()
    eventPlayer.Hero_Ability[0]=AbilityStage.NONE
