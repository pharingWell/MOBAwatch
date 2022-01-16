#!mainFile "../main.opy"



rule "Heroes_Init":
    HeroSpecs=[100,100,10]#hp,mana,range

rule "Target":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    @Condition not eventPlayer.isDummy()
    eventPlayer.UICursorStyles[0]=Color.RED
    #Temp_DistanceSort=[elem for elem in if ]


