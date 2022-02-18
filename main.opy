# #!obfuscate noConstantObfuscation 

settings {
    "main": {
        "description": "MOBA (WIP)",
        "modeName": "MOBAwatch"
    },
    "lobby": {
        "mapRotation": "paused",
        "spectatorSlots": 0,
        "returnToLobby": "afterGame",
        "team1Slots": 4,
        "team2Slots": 4
    },
    "gamemodes": {
        "tdm": {
            "enabledMaps": [
                "workshopExpanseNight"

            ],
            "gameLengthInMn": 15,
            "enableMercyRezKillCancel": false,
            "scoreToWin": 100
        },
        "general": {
            "enableSkins": false,
            "gamemodeStartTrigger": "immediately",
            "enableSelfInitiatedRespawn": false
        }
    },
    "heroes": {
        "allTeams": {
            "general": {
                "enableInfiniteAmmo": false,
                "enableSpawningWithUlt": true
            }
        }
    }
}



#Activated extensions

#!extension beamSounds
#!extension playMoreEffects
#!extension spawnMoreDummyBots
#!extension beamEffects
#!include "variables.opy"
#!include "minions.opy"
#!include "controlled.opy"
#!include "ui.opy"

#!include "heroes/generic.opy"




rule "Set setting vars":
    Setting_CamSpeed=createWorkshopSetting(float[0.0:1.0],"Cosmetic","Unbound Camera Speed",0.5,23)
    Setting_Mode=createWorkshopSetting(enum["Open","Standalone"],"Significant","Open: Allow players to join mid-game, Standalone: Full match",1,63)
    
    
rule "InitiateGame":
    @Condition len(CPlayers[0]) + len(CPlayers[1]) < len(getAllPlayers())
    if(getNumberOfSlots(Team.ALL)/2!=getNumberOfSlots(Team.1) or (not getAllPlayers()[0] == hostPlayer and not len(getAllPlayers()) == 1)):
        wait(2)
        returnToLobby()
    hudHeader(getAllPlayers(),w"Loading...",HudPosition.TOP,1,Color.RED,HudReeval.NONE)
    Ready=getLastCreatedText()-3
    Minions=[[-1],[-1]] 
    Players=[-1]
    createDummy(Hero.ROADHOG,Team.2,-1,vect(2,0,2),vect(0,0,0))
    CPlayers[1]=[getLastCreatedEntity()]
    createDummy(Hero.TORBJORN,Team.2,-1,vect(-2,0,2),vect(0,0,0))
    CPlayers[1]=[CPlayers[1][0],getLastCreatedEntity()]
    ScreenLimits = [1.3,1.40]
    ThreadClear=true
    TeamSize = getNumberOfSlots(Team.1)
    for i in range(TeamSize):
        if(i==0):
            Players[0]=["null"] 
            Players[1]=["null"]
        else:
            Players[0].append(["null"])
            Players[1].append(["null"])
    Minions_Init()
    async(HealthHandle(),AsyncBehavior.NOOP)
    setMatchTime(0) #change to 15 later
    wait(15)
    pauseMatchTime()
    wait(1)
    disableAnnouncer()
    if(Setting_Mode==1): #Standalone
        unpauseMatchTime()
        setMatchTime(2700)
    else:
        disableGamemodeCompletion()


    
def Ready():
    destroyHudText(Ready+3)
    Ready=true

rule "Inspector":
    @Condition Ready == true
    disableInspector()
    wait(1)
    enableInspector()
    top    

rule "Display server performance characteristics":
    /*
    hudHeader(getAllPlayers(), l"{0}: {1}".format(l"Server Load", l"{0}%".format(getServerLoad())), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers(), l"{0}: {1}".format(l"Server Load Average", l"{0}%".format(getAverageServerLoad())), HudPosition.TOP, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers(), l"{0}: {1}".format(l"Server Load Peak", l"{0}%".format(getPeakServerLoad())), HudPosition.TOP, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    */ 

rule "Minions Tick":
    @Condition Ready == true
    #Minions_Main()
    wait(15)
    Minion_Wave()
    top



rule "left":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)
    if(eventPlayer.getTeam()==Team.1):
        Players[0]=replace(null,Players[0].index(eventPlayer),Players[0])
    else:
        Players[1]=replace(null,Players[1].index(eventPlayer),Players[1])
    Left()
    j=""
    for i in range(len(CPlayers[0])):
        j=("{0},{1}".format(j,CPlayers[0][i]))
    j="{0}\n".format(j)
    for i in range(len(CPlayers[1])):
        j=("{0},{1}".format(j,CPlayers[1][i]))
    println(j)
    
rule "On Player Left":
    @Event playerLeft
    @Condition not eventPlayer.isDummy()
    Left()

def Left():
    for PlayerLeft_i in range(len(CPlayers[0])):
        if(CPlayers[0][PlayerLeft_i].Owner not in Players[0]):
            CPlayers[0][PlayerLeft_i].Owner=null
            startAction(8,CPlayers[0][PlayerLeft_i])
            #destroyDummy(Team.1,TeamSize+PlayerLeft_i)
            #CPlayers[0]=replace(CPlayers[0][PlayerLeft_i])
    for PlayerLeft_i in range(len(CPlayers[1])):
        if(CPlayers[1][PlayerLeft_i].Owner!=Players[1][PlayerLeft_i]):
            #destroyDummy(Team.2,TeamSize+PlayerLeft_i)
            #CPlayers[1]=CPlayers[0].exclude(CPlayers[1][PlayerLeft_i])
    disableInspector()


