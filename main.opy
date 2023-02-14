##!obfuscate noConstantObfuscation

settings {
    "main": {
        "description": "MOBA (WIP)",
        "modeName": "MOBAwatch"
    },
    "lobby": {
        "mapRotation": "paused",
        "spectatorSlots": 0,
        "team1Slots": 5,
        "team2Slots": 5,
        "returnToLobby": "afterGame"
    },
    "gamemodes": {
        "hybrid": {
            "enabledMaps": [
                
            ],
            "payloadSpeed%": 10
        },
        "tdm": {
            "enabledMaps": [
                "workshopExpanse"
            ],
            "gameLengthInMn": 15,
            "enableMercyRezKillCancel": false,
            "scoreToWin": 100,
            "enableSelfInitiatedRespawn": false
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "enableSkins": false
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

#Activated extensions "numbani"
#!extension beamSounds
#!extension playMoreEffects
#!extension spawnMoreDummyBots
#!extension beamEffects
#!include "variables.opy"
#!include "ui.opy"
#!include "grid.opy"

##!include "projectiles.opy"
#!include "minions.opy"
#!include "heroes/generic.opy"
#!include "controlled.opy"
#!include "heroes/reaper.opy"
#!include "heroes/tracer.opy"
#Mercy
#Hanzo
#Torborn
#Reinhardt
#!include "heroes/pharah.opy"



rule "print .":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    println(".")
    
rule "Set setting vars":
    Setting_CamSpeed=createWorkshopSetting(float[0.0:1.0],"Cosmetic","Unbound Camera Speed",0.5,23)
    Setting_Mode=createWorkshopSetting(enum["Open","Standalone"],"Significant","Open: Allow players to join mid-game, Standalone: Full match",1,63)
    
    
rule "InitiateGame":
    #@Condition len(CPlayers[0]) + len(CPlayers[1]) < len(getAllPlayers())
    if(getNumberOfSlots(Team.ALL)/2!=getNumberOfSlots(Team.1) or (not getAllPlayers()[0] == hostPlayer and not len(getAllPlayers()) == 1)):
        #print("{} {}".format(getAllPlayers()[0],len(getAllPlayers())))
        wait(4)
        returnToLobby()
    Players=[-1]
    MinionPool=-1
    
    
    createDummy(Hero.REAPER,Team.2,6,vect(2,0,2),vect(0,0,0))
    CPlayers[1]=[getLastCreatedEntity()]
    CPlayers[1].CHero=Hero.REAPER 
    getLastCreatedEntity().setDamageReceived(0)
    wait()
    /*
    createDummy(Hero.TORBJORN,Team.2,7,vect(-2,0,2),vect(0,0,0))
    getLastCreatedEntity().setDamageReceived(0)
    CPlayers[1]=[CPlayers[1][0],getLastCreatedEntity()]
    wait()
    /*createDummy(Hero.DVA,Team.2,8,vect(0,0,4),vect(0,0,0))
    getLastCreatedEntity().setDamageReceived(0)
    CPlayers[1]=[CPlayers[1][0],CPlayers[1][1],getLastCreatedEntity()]
    wait()*/
    ThreadClear=true
    TeamSize = getNumberOfSlots(Team.1)
    forGlobal(TEAMSETUP,0,TeamSize):
        if(Iter[forG.TEAMSETUP]==0):
            Players[0]=["null"] 
            Players[1]=["null"]
        else:
            Players[0].append(["null"])
            Players[1].append(["null"])
        forEndG(TEAMSETUP)
    Minions_Init()
    async(HealthHandle(),AsyncBehavior.NOOP)
    setMatchTime(0) #change to 15 later
    #wait(15)
    pauseMatchTime()
    wait(1)
    disableAnnouncer()
    if(Setting_Mode==1): #Standalone
        unpauseMatchTime()
        setMatchTime(2700)
    else:
        disableGamemodeCompletion()
    
def Ready():
    forGlobal(PLAYERNAME_SETUP,0,TeamSize):
        hudText(getPlayers(Team.1),"{0}{1}".format(heroIcon(Players[0][evalOnce(Iter[forG.PLAYERNAME_SETUP])].getCurrentHero()),Players[0][evalOnce(Iter[forG.PLAYERNAME_SETUP])]),CPlayers[0][evalOnce(Iter[forG.PLAYERNAME_SETUP])].Health[0],null,HudPosition.LEFT,Iter[forG.PLAYERNAME_SETUP]-TeamSize,Players[0][evalOnce(Iter[forG.PLAYERNAME_SETUP])].UIContainer[0],Players[0][evalOnce(Iter[forG.PLAYERNAME_SETUP])].UIContainer[1],null,HudReeval.VISIBILITY_STRING_AND_COLOR)
        hudText(getPlayers(Team.1),"{0}{1}".format(heroIcon(Players[1][evalOnce(Iter[forG.PLAYERNAME_SETUP])].getCurrentHero()),Players[1][evalOnce(Iter[forG.PLAYERNAME_SETUP])]),null,null,HudPosition.RIGHT,Iter[forG.PLAYERNAME_SETUP]-TeamSize,Players[1][evalOnce(Iter[forG.PLAYERNAME_SETUP])].UIContainer[0],Players[1][evalOnce(Iter[forG.PLAYERNAME_SETUP])].UIContainer[0],null,HudReeval.VISIBILITY_STRING_AND_COLOR)
        hudText(getPlayers(Team.2),"{0}{1}".format(heroIcon(Players[1][evalOnce(Iter[forG.PLAYERNAME_SETUP])].getCurrentHero()),Players[1][evalOnce(Iter[forG.PLAYERNAME_SETUP])]),CPlayers[1][evalOnce(Iter[forG.PLAYERNAME_SETUP])].Health[0],null,HudPosition.LEFT,Iter[forG.PLAYERNAME_SETUP]-TeamSize,Players[1][evalOnce(Iter[forG.PLAYERNAME_SETUP])].UIContainer[0],Players[1][evalOnce(Iter[forG.PLAYERNAME_SETUP])].UIContainer[1],null,HudReeval.VISIBILITY_STRING_AND_COLOR)
        hudText(getPlayers(Team.2),"{0}{1}".format(heroIcon(Players[0][evalOnce(Iter[forG.PLAYERNAME_SETUP])].getCurrentHero()),Players[0][evalOnce(Iter[forG.PLAYERNAME_SETUP])]),null,null,HudPosition.RIGHT,Iter[forG.PLAYERNAME_SETUP]-TeamSize,Players[0][evalOnce(Iter[forG.PLAYERNAME_SETUP])].UIContainer[0],Players[0][evalOnce(Iter[forG.PLAYERNAME_SETUP])].UIContainer[0],null,HudReeval.VISIBILITY_STRING_AND_COLOR)
        forEndG(PLAYERNAME_SETUP) 
    Ready=true

rule "Inspector":
    @Condition Ready == true
    wait(1)
    disableInspector()
    
    #enableInspector()
    top    

rule "Display server performance characteristics":
    #hudHeader(getAllPlayers(), "{}{} {}{} {}{}".format("Load:", "{0}%".format(getServerLoad()), "Load Average:", "{0}%".format(getAverageServerLoad()), "Load Peak:", "{0}%".format(getPeakServerLoad())), HudPosition.RIGHT, -10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


rule "Minions Tick":
    @Condition Ready == true
    wait(1)
    #Minions_Main()
    
    #Minion_Wave()
    top

rule "start dot":
    @Event eachPlayer
    @Condition Item1_Bind
    eventPlayer.ControlledRef.Health[2] = [-250,5]
/*rule "left":
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
*/
rule "On Player Left":
    @Event playerLeft
    @Condition not eventPlayer.isDummy()
    Left()

/*def Left():
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
*/

rule "POV":
    @Event eachPlayer
    @Condition Item2_Bind
    eventPlayer.ControlledRef.setUltCharge(100)
    #eventPlayer.ControlledRef.Actions=0
    #Minions_Wave()
    

rule "POV":
    @Event eachPlayer
    @Condition Settings_Bind
    eventPlayer.showStats=[true,eventPlayer.ControlledRef]
    waitUntil_verify(Settings_Bind==false)
    eventPlayer.showStats=[]
    
/*
rule "PRS check on Join":
    @Event playerJoined
    @Condition not eventPlayer.isDummy()
    if(Setting_Mode==1 and prsChange[eventPlayer.getSlot()]): #if opened in standalone mode and the player slot they are going to be added to already has info, 
         #print the name and the rank score of the previous player
        println("PRS~{}:{}".format(prsChangeName[eventPlayer.getSlot()],prsChange[eventPlayer.getSlot()]))
    prsChangeName[eventPlayer.getSlot()] = "{}".format(eventPlayer)
    prsChange[eventPlayer.getSlot()] = 1
*/
rule "set db index":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    forPlayer(DBINDEX,0,len(dbKeys)):
        if(dbKeys[eventPlayer.Iter[forP.DBINDEX]]=="{}".format(eventPlayer)):
            eventPlayer.dbIndex = eventPlayer.Iter[forP.DBINDEX]
            eventPlayer.Iter[forP.DBINDEX] = 0
            return
        forEndP(DBINDEX)
    eventPlayer.dbIndex = len(dbKeys)
    dbKeys[eventPlayer.dbIndex] = "{}".format(eventPlayer)
    dbPRS[eventPlayer.dbIndex] = 1500
    println("PRS~{}>{}".format("{}".format(eventPlayer),dbPRS[eventPlayer.dbIndex]))

/*
    @Condition not eventPlayer.scoreRank
    @Condition ThreadClear
    for i in range(0,len(playerScoreRank)):
        if(playerScoreRank[i][0]=="{}".format(eventPlayer)):
            eventPlayer.scoreRank=playerScoreRank[i][1]
            goto setupPRS
    dbPRS[eventPlayer.dbIndex] = 1500
    setupPRS:
    ThreadClear = true
    println("PRS~{}>{}".format("{}".format(eventPlayer),dbPRS[eventPlayer.dbIndex]))
    
*/
#
#!include "../CrossOver/db/db.opy"