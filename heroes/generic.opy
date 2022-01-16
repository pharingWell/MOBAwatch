#!mainFile "../main.opy"

rule "Heroes_Init":
    HeroSpecs=[100,100,10]#hp,mana,range

rule "Target":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    @Condition not eventPlayer.isDummy()
    eventPlayer.UICursorStyles[0]=Color.RED
    eventPlayer.Temp_DistanceSort=sorted(NonPlayer_Loc, lambda elem: (evalOnce(eventPlayer.cursor.x)-elem.y)**2 + (evalOnce(eventPlayer.cursor.z)+elem.z)**2)
    println(eventPlayer.Temp_DistanceSort)
