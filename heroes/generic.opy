#!mainFile "../main.opy"

rule "Heroes_Init":
    HeroSpecs=[100,100,10]#hp,mana,range

rule "Target":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    @Condition not eventPlayer.isDummy()
    eventPlayer.Temp_DistanceSort=[vect((eventPlayer.cursor.x-i.y)**2 + (eventPlayer.cursor.z-i.z)**2,i.y,i.z) for i in random.shuffle(NonPlayer_Loc)]
    #sorted([vect((eventPlayer.cursor.x-i.y)**2 + (eventPlayer.cursor.z-i.z)**2,i.x,0) for i in random.shuffle(NonPlayer_Loc)], lambda elem: elem.x)
    if(eventPlayer.Temp_DistanceSort[0].x<0.5):
        println("{0}, {1}".format(eventPlayer.Temp_DistanceSort[0],eventPlayer.cursor))
        eventPlayer.UICursorStyles[0]=Color.RED
        wait(0.5)
        eventPlayer.UICursorStyles[0]=Color.WHITE