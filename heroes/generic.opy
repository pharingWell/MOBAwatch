#!mainFile "../main.opy"

rule "Heroes_Init":
    HeroSpecs=[[100,100,10]]#hp,mana,range
    createEffect(getAllPlayers(),Effect.RING,Color.WHITE,vect(0,0,0.01),0.75,EffectReeval.VISIBILITY)
    waitUntil(Ready==true,999)


rule "Check Hero Change":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    eventPlayer.disableScoreboard()
    eventPlayer.CHero = eventPlayer.getCurrentHero()
    wait(0.1)
    ###INIT BOT###
    if(eventPlayer.getCurrentHero()!=eventPlayer.CHero and Ready):
        if(eventPlayer.getTeam()==Team.1):
            eventPlayer.Team=1
            eventPlayer().UIContainer=[Color.BLUE]
        else:
            eventPlayer.Team=2
            eventPlayer().UIContainer=[Color.RED]
        eventPlayer.Slot=eventPlayer.getSlot()
        Players[eventPlayer.Team-1]=replace(eventPlayer,eventPlayer.Slot,Players[eventPlayer.Team-1])
        eventPlayer.CHero=eventPlayer.getCurrentHero()
        attachControlled
        CameraSetup()
        OnHero()
        UI_Setup()
        async(UI_Process,AsyncBehavior.NOOP)
        waitUntil(eventPlayer.cursor!=vect(0,0.01,0),1000)
        wait(0.5)
        eventPlayer.CamAttach=true
        moveCameraWithPlayer()
        eventPlayer.enableScoreboard()
    else:
        top


def OnHero():
    #disabled hero ults from the player's perspective
    if(eventPlayer.CHero not in [Hero.MOIRA,Hero.BRIGITTE,Hero.WIDOWMAKER,Hero.TORBJORN]):
        eventPlayer.disallowButton(Button.ULTIMATE)

    #!define updateCooldown(button) eventPlayer.setAbilityCooldown(button,eventPlayer.ControlledRef.getAbilityCooldown(button))

rule "Target":
    @Event eachPlayer
    @Condition Ready==true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) #**2 **2
    @Condition not eventPlayer.isDummy()

    for i in range(TeamSize):
        if(i==0):
                eventPlayer.Temp_DistanceSort=vect(eventPlayer.ControlledRef.Team,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().x,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().z)
        else:
            eventPlayer.Temp_DistanceSort.append(vect(eventPlayer.ControlledRef.Team,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().x,CPlayers[eventPlayer.ControlledRef.Team-1][0].getPosition().z))
    eventPlayer.Temp_DistanceSort=sorted(random.shuffle(NonPlayer_Loc.slice((eventPlayer.ControlledRef.Team-1)*48,eventPlayer.ControlledRef.Team*48).concat(eventPlayer.Temp_DistanceSort)), lambda i: (abs(eventPlayer.cursor.x-i.y))**2 + (abs(eventPlayer.cursor.z-i.z))**2)
    #sorted([vect((eventPlayer.cursor.x-i.y)**2 + (eventPlayer.cursor.z-i.z)**2,i.x,0) for i in random.shuffle(NonPlayer_Loc)], lambda elem: elem.x)
    if((abs(eventPlayer.cursor.x-eventPlayer.Temp_DistanceSort[0].y))**2 + (abs(eventPlayer.cursor.z-eventPlayer.Temp_DistanceSort[0].z))**2<0.866):
        eventPlayer.ControlledRef.Target=eventPlayer.Temp_DistanceSort[0]
        startAction(1,eventPlayer.ControlledRef)
        println("{0}, {1}".format(eventPlayer.Temp_DistanceSort[0],eventPlayer.cursor))
        eventPlayer.UICursorStyles[0]=Color.RED
        wait(0.1)
        eventPlayer.UICursorStyles[0]=Color.WHITE
        

rule "Mode":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    if(Setting_Mode==1): #Standalone
        hudSubtext(getAllPlayers(),"MOBAwatch: Standalone",HudPosition.TOP,0,Color.ORANGE,HudReeval.VISIBILITY)
    else:
        hudSubtext(getAllPlayers(),"MOBAwatch: Open",HudPosition.TOP,0,Color.VIOLET,HudReeval.VISIBILITY)
    eventPlayer.i = getLastCreatedText()
    wait(15)
    destroyHudText(eventPlayer.i)

