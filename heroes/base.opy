#!mainFile "../main.opy"
#you can declare hero specific variables here. Do not make them global
rule "Hero - Init":
    @Event eachPlayer
    @Hero CHANGEME
    @Condition eventPlayer.isDummy()
    
rule "Hero - UI Prep":
    @Event eachPlayer
    @Hero CHANGEME
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityState.PREP #show ui for
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
    @Hero CHANGEME
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityState.MOVETO #show ui for
    clearEffectUI()
    #does not pass to cast for obvious reasons

rule "Hero - Cast":
    @Event eachPlayer
    @Hero CHANGEME
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityState.CAST #otherwise show ui
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:
        case 1: 
            Ability(Button.ABILITY_1,false)
            break
        case 2:
            Ability(Button.ABILITY_2,false)
            break
        case 3:
            Ability(Button.RELOAD,false)
            break
        case 4:
            Ability(Button.ULTIMATE,false)
            break
    eventPlayer.Hero_Ability[0]=AbilityState.COMPLETE


rule "Hero - Complete":
    @Event eachPlayer
    @Hero CHANGEME
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityState.COMPLETE 
    clearEffectUI()
    eventPlayer.Hero_Ability[0]=AbilityState.NONE
