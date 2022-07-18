#!mainFile "../main.opy"
#you can declare hero specific variables here. Do not make them global
rule "Hero - Init":
    @Event eachPlayer
    @Hero changeme
    @Condition eventPlayer.isDummy()
    
rule "Hero - UI Prep":
    @Event eachPlayer
    @Hero changeme
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

rule "Hero - UI MoveTo":
    @Event eachPlayer
    @Hero changeme
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.MOVETO #show ui for
    clearEffectUI()
    #does not pass to cast for obvious reasons

rule "Hero - Cast":
    @Event eachPlayer
    @Hero changeme
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.CAST #otherwise show ui
    clearEffectUI()
    switch eventPlayer.Hero_Ability[1]:
        case AbilID.ABIL1: 
            Ability(Button.ABILITY_1)
            break
        case AbilID.ABIL2:
            Ability(Button.ABILITY_2)
            break
        case AbilID.ABIL3:
            Ability(Button.RELOAD)
            break
        case AbilID.ABIL4:
            Ability(Button.ULTIMATE)
            break
    eventPlayer.Hero_Ability[0]=AbilityStage.COMPLETE

rule "Hero - Complete":
    @Event eachPlayer
    @Hero changeme
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.Hero_Ability[0]==AbilityStage.COMPLETE 
    clearEffectUI()
    eventPlayer.Hero_Ability[0]=AbilityStage.NONE
    endAbilityAction(eventPlayer.Hero_Ability[1])
    
    switch eventPlayer.Hero_Ability[1]:
        default:
            break
    