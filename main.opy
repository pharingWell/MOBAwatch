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
#!include "heroes/generic.opy"

#!define loopt if(RULE_CONDITION):\
    goto RULE_START
#!define loopf if(not RULE_CONDITION):\
    goto RULE_START
#!define top goto RULE_START
#!define println(a) enableInspector()\
printLog(a)\
disableInspector()


rule "Set setting vars":
    Setting_CamSpeed=createWorkshopSetting(float[0.0:1.0],"Cosmetic","Unbound Camera Speed",0.5,23)

rule "InitiateGame":
    @Condition len(Team1) + len(Team2) < len(getAllPlayers())
    hudHeader(getAllPlayers(),w"Loading...",HudPosition.TOP,1,Color.RED,HudReeval.NONE)
    Ready=getLastCreatedText()-3
    Minions=[[-1],[-1]]
    Team1 = []
    Team2 = []
    ScreenLimits = [1.3,1.40]
    ThreadClear=true
    for i in range(len(getPlayers(Team.1))):
        if(getPlayers(Team.1)[i].isDummy()):
            getPlayers(Team.1)[i].Slot=i
    for i in range(len(getPlayers(Team.2))):
        if(getPlayers(Team.2)[i].isDummy()):
            getPlayers(Team.2)[i].Slot=i
    if((len(getAllPlayers()) % 2 != 0) and isGameInProgress()):
        wait(3)
        #Returns to Lobby due to incorrect amount of players (Requires even number of players)
        returnToLobby()
    #set to floor
    TeamSize = ceil(len(getAllPlayers()) / 2)
    Minions_Init()
    async(HealthHandle(),AsyncBehavior.NOOP)
    
    

rule "Debug Mode Check":
    @Condition not eventPlayer.isDummy()
    @Event playerJoined
    #If Host Player not Debugging, yet game started in Debug Mode: Send to lobby
    if (not isGameInProgress()):
        if (not getAllPlayers()[0] == hostPlayer and not len(getAllPlayers()) == 1):
            wait(2)
            returnToLobby()
        else:
            hudHeader(getAllPlayers(), "DEBUG MODE", HudPosition.TOP, 0, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

rule "Display server performance characteristics":
    /*
    hudHeader(getAllPlayers(), l"{0}: {1}".format(l"Server Load", l"{0}%".format(getServerLoad())), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers(), l"{0}: {1}".format(l"Server Load Average", l"{0}%".format(getAverageServerLoad())), HudPosition.RIGHT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers(), l"{0}: {1}".format(l"Server Load Peak", l"{0}%".format(getPeakServerLoad())), HudPosition.RIGHT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    */      

rule "Minions Tick":
    @Condition Ready == true
    Minions_Main()
    top
    


rule "Inspector":
    @Condition Ready == true
    disableInspector()
    wait(4)
    enableInspector()
    top

rule "On Player Join":
    @Event playerJoined
    @Condition not eventPlayer.isDummy()

    
rule "Check Hero Change":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    eventPlayer.CHero = eventPlayer.getCurrentHero()
    wait(0.1)
    ###INIT BOT###
    if(eventPlayer.getCurrentHero()!=eventPlayer.CHero):
        eventPlayer.CHero = Hero.ZARYA
        eventPlayer.CHero =eventPlayer.getCurrentHero()
        
        createDummy(eventPlayer.getCurrentHero(), eventPlayer.getTeam(), -1, vect(0,0,0),vect(0,0,0))
        eventPlayer.ControlledSlot = TeamSize+eventPlayer.Slot
        #printLog("H:{0},T:{1},S:{2},CS:{3}".format(eventPlayer.getCurrentHero(),eventPlayer.getTeam(),eventPlayer.Slot,eventPlayer.ControlledSlot))
        eventPlayer.ControlledRef = getPlayersInSlot(eventPlayer.ControlledSlot,eventPlayer.getTeam())
        eventPlayer.ControlledRef.Owner = eventPlayer
        eventPlayer.ControlledRef.startForcingOutlineFor(eventPlayer,true,Color.TEAM_1,OutlineVisibility.ALWAYS)
        eventPlayer.ControlledRef.startForcingName(eventPlayer)
        #eventPlayer.ControlledRef.setInvisibility(Invis.ENEMIES)
        if(eventPlayer.getTeam()==Team.1):
            Team1.append(eventPlayer.ControlledRef)
        elif(eventPlayer.getTeam()==Team.2):
            Team2.append(eventPlayer.ControlledRef)
        CameraSetup()
        eventPlayer().UIContainer=[]
        for  eventPlayer().i in range(TeamSize*2):
            eventPlayer().UIContainer = eventPlayer().UIContainer.concat([-1,-1])
        OnHero()
        UI_Setup()
        UI_Process()
    else:
        top


def OnHero():
    #disabled hero ults from the player's perspective
    if(eventPlayer.CHero not in [Hero.MOIRA,Hero.BRIGITTE,Hero.WIDOWMAKER,Hero.TORBJORN]):
        eventPlayer.disallowButton(Button.ULTIMATE)
    wait(0.5)
    
    


rule "Bot - Hero Connection":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    eventPlayer.startForcingPosition(vect(eventPlayer.ControlledRef.getPosition().x,-15,eventPlayer.ControlledRef.getPosition().z),true)
    if(eventPlayer.ControlledRef.Hidden):
        eventPlayer.ControlledRef.setInvisibility(Invis.ENEMIES)
    else:
        eventPlayer.ControlledRef.setInvisibility(Invis.NONE)
    wait(1)
    top

    #!define updateCooldown(button) eventPlayer.setAbilityCooldown(button,eventPlayer.ControlledRef.getAbilityCooldown(button))
def UI_Setup():
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableGamemodeHud()
    #disableInspector()
    #eventPlayer.disableHeroHUD()
    createInWorldText(eventPlayer,"<•>",updateEveryTick(vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.ControlledRef.getEyePosition().y+0.0,eventPlayer.ControlledRef.getEyePosition().z+0.2)),1.5*(not eventPlayer.ControlledRef.Hidden),Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,Color.RED,SpecVisibility.NEVER)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.RELOAD)
    eventPlayer.disallowButton(Button.MELEE)
    eventPlayer.disallowButton(Button.JUMP)
#!define sidebar(index,hero,player,position,color) if(eventPlayer().UIContainer[eventPlayer().UIIstanceHandler+1]!=index):\
        destroyHudText(eventPlayer().UIContainer[eventPlayer().UIIstanceHandler])\
        hudHeader(getAllPlayers(), player, position, 0, color, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)\
        eventPlayer().UIContainer[eventPlayer().UIIstanceHandler]=getLastCreatedText()\
        eventPlayer().UIContainer[eventPlayer().UIIstanceHandler+1]=index
def UI_Process():
    @Name "S_UI_Process"
    #for UIIstanceHandler in Team1:
    #    sidebar(0,Team1[eventPlayer().].getCurrentHero(),Team1[eventPlayer().UIIstanceHandler],HudPosition.LEFT,Color.TEAM_1)
    #sidebar(1,Team1[eventPlayer().UIIstanceHandler].getCurrentHero(),Team1[eventPlayer().UIIstanceHandler],HudPosition.LEFT,Color.GRAY)
    
    #
    updateCooldown(Button.ABILITY_1)
    updateCooldown(Button.ABILITY_2)
    updateCooldown(Button.JUMP)
    updateCooldown(Button.CROUCH)
    updateCooldown(Button.SECONDARY_FIRE)
    eventPlayer.setAmmo(0,1)
    eventPlayer.setAmmo(1,1)
    wait(0.1)
    top



rule "Cursor": 
    @Event eachPlayer
    @Condition Ready == true
    @Condition not eventPlayer.isDummy()

    #createInWorldText(eventPlayer,"{0}".format(eventPlayer.cursor),eventPlayer.cursor,1.0,Clip.SURFACES,WorldTextReeval.VISIBILITY_AND_POSITION,Color.RED,SpecVisibility.NEVER)
    eventPlayer.UICursorStyles = [Color.WHITE,true,Color.RED,0.10]
    createInWorldText(eventPlayer,"•",vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z-eventPlayer.CamLoc.y/12.5),2.5,Clip.SURFACES,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,eventPlayer.UICursorStyles[0],SpecVisibility.NEVER)
    #createInWorldText(eventPlayer,"•",vect(1.349*(9.75)*(eventPlayer.eyeAxis[0])+eventPlayer.CamLoc.x,0,0.775*(9.75)*(eventPlayer.eyeAxis[1]+0.25)+eventPlayer.CamLoc.z-1.25),2.5,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,eventPlayer.UICursorStyles[0],SpecVisibility.NEVER)
    #raycast(eventPlayer.CamLoc,vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z),getAllPlayers(),null,true).getHitPosition().y
    #createEffect(eventPlayer,Effect.SPHERE,eventPlayer.UICursorStyles[2],vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z),eventPlayer.UICursorStyles[3],EffectReeval.POSITION_AND_RADIUS)

rule "CursorStyle1":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition not eventPlayer.isDummy()
    @Condition distance(vect(eventPlayer.ControlledRef.getPosition().x,0,eventPlayer.ControlledRef.getPosition().z),vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z))>1
    destroyInWorldText(eventPlayer.MovementGroundCursor)
    wait(0.01)
    eventPlayer.ControlledRef.CPos = vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z)
    if("{0}".format(eventPlayer.CamAttach)=="0"):
        eventPlayer.CamAttach=true
    async(moveCameraWithPlayer,AsyncBehavior.RESTART)
    eventPlayer.ControlledRef.startThrottleInDirection(vectorTowards(eventPlayer.ControlledRef.getEyePosition(), eventPlayer.ControlledRef.CPos), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.ControlledRef.startFacing(vectorTowards(vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.ControlledRef.getEyePosition().y,eventPlayer.ControlledRef.getEyePosition().z),vect(eventPlayer.ControlledRef.CPos.x,eventPlayer.ControlledRef.getEyePosition().y,eventPlayer.ControlledRef.CPos.z)),400,Relativity.TO_WORLD,FacingReeval.DIRECTION_AND_TURN_RATE)
    createInWorldText(eventPlayer,"¤",vect(eventPlayer.ControlledRef.CPos.x,0,eventPlayer.ControlledRef.CPos.z-eventPlayer.CamLoc.y/12.5),2.0,Clip.NONE,WorldTextReeval.NONE,Color.SKY_BLUE,SpecVisibility.NEVER)
    eventPlayer.MovementGroundCursor = getLastCreatedText()
    wait(0.25)
    loopt

rule "Throttling Bot":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer in getPlayersInRadius(eventPlayer.CPos,0.5,Team.ALL,LosCheck.OFF)
    destroyInWorldText(eventPlayer.Owner.MovementGroundCursor)
    eventPlayer.startTransformingThrottle(0.5,0.5,eventPlayer.getFacingDirection())
    eventPlayer.stopFacing()    
    wait(0.1)
    eventPlayer.stopThrottleInDirection()
    #smallMessage(eventPlayer,"{0}_".format(eventPlayer.MovementGroundCursor))

rule "Toggle CamAttach":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy() and eventPlayer.isHoldingButton(Button.JUMP)
    PrintMinions()

rule "Toggle CamAttach":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy() and eventPlayer.isHoldingButton(Button.MELEE)
    if(eventPlayer.CamAttach):
        eventPlayer.CamAttach=false
        stopChasingVariable(eventPlayer.CamLoc)
    else:   
        eventPlayer.CamAttach=true
        if(distance(eventPlayer.ControlledRef.CPos,vect(eventPlayer.ControlledRef.getEyePosition().x,0,eventPlayer.ControlledRef.getEyePosition().z))<1.2):
            chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z),duration=0.1,ChaseReeval.NONE)
        else:
            chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.CPos.x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.CPos.z),duration=0.1,ChaseReeval.NONE)

def moveCameraWithPlayer():
    if(eventPlayer.CamAttach):
        chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z),rate=eventPlayer.ControlledRef.getSpeed()+(not(eventPlayer.CamAttach)),ChaseReeval.DESTINATION_AND_RATE)

def CameraSetup():
    @Name "S_CameraSetup"
    eventPlayer.CamLoc = vect(0,15,0)
    eventPlayer.setFacing(vect(0,0,0),Relativity.TO_WORLD) #15,-4
    eventPlayer.startCamera(vect(eventPlayer.CamLoc.x,eventPlayer.CamLoc.y,eventPlayer.CamLoc.z-0.01), vect(eventPlayer.CamLoc.x, 0, eventPlayer.CamLoc.z), 30)
    eventPlayer.ControlledRef.CPos=vect(0,0,0)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.setDamageReceived(0)
    

rule "Camera Bounds":
    #!define clamp(n, smallest, largest) (max(smallest, min(n, largest)))
    #
    #!define Hori atan2(eventPlayer.getFacingDirection().x,eventPlayer.getFacingDirection().z)
    #!define Vert asin(eventPlayer.getFacingDirection().y)
    #!define HoriLimit (ScreenLimits[0])+eventPlayer.eyeAxis[1]*0.1*eventPlayer.eyeAxis[1]/abs(eventPlayer.eyeAxis[1])
    #!define VertLimit ScreenLimits[1]
    #!define HoriBounds (abs(eventPlayer.eyeAxis[0])<HoriLimit)
    #!define VertBounds (abs(eventPlayer.eyeAxis[1]<VertLimit))
    @Event eachPlayer
    @Condition Ready == true
    @Condition not eventPlayer.isDummy()
    eventPlayer.eyeAxis[0]=Hori
    eventPlayer.eyeAxis[1]=Vert

    #if the mouse is out of bounds horizontally, bring it back in bounds (take current Horizontal angle and convert it back into facing direction to put a hard limit on look angle (hopefully))
    if(not HoriBounds):
        eventPlayer.setFacing(angleToDirection((180/Math.PI)*0.95*(HoriLimit)*(eventPlayer.eyeAxis[0]/abs(eventPlayer.eyeAxis[0])),eventPlayer.eyeAxis[1]*-1*(180/Math.PI)),Relativity.TO_WORLD)
        #eventPlayer.setFacing(vect(sin(*1)), eventPlayer.i, cos(ScreenLimits[0]*(eventPlayer.eyeAxis[0]/abs(eventPlayer.eyeAxis[0])*1))),Relativity.TO_WORLD)
    elif(not VertBounds):
        eventPlayer.setFacing(angleToDirection((180/Math.PI)*eventPlayer.eyeAxis[0],(180/Math.PI)*-0.95*(VertLimit)*(eventPlayer.eyeAxis[1]/abs(eventPlayer.eyeAxis[1]))),Relativity.TO_WORLD)
        #Don't move the screen if your camera is locked
    if(not eventPlayer.CamAttach):
        #If mouse outside normal range(and camera unlocked), move screen that direction a given rate
        if(abs(eventPlayer.eyeAxis[0])>=HoriLimit*0.969):
            eventPlayer.CamLoc=(vect(eventPlayer.CamLoc.x+Setting_CamSpeed*(eventPlayer.eyeAxis[0]/abs(eventPlayer.eyeAxis[0])),eventPlayer.CamLoc.y,eventPlayer.CamLoc.z))
        #If mouse outside normal range(and camera unlocked), move screen that direction a given rate
        if(abs(eventPlayer.eyeAxis[1])>=VertLimit*0.969):
            eventPlayer.CamLoc=(vect(eventPlayer.CamLoc.x,eventPlayer.CamLoc.y,eventPlayer.CamLoc.z+Setting_CamSpeed*(eventPlayer.eyeAxis[1]/abs(eventPlayer.eyeAxis[1]))))
    ##
    eventPlayer.cursorNew=vect((eventPlayer.CamLoc.y*2.750)*(eventPlayer.eyeAxis[0]/Math.PI)+eventPlayer.CamLoc.x,0,((eventPlayer.eyeAxis[1])/(Math.PI/2))*(eventPlayer.CamLoc.y*0.775)+eventPlayer.CamLoc.z)
    if(eventPlayer.cursor==0):
        eventPlayer.cursor=vect(0,0,0)
        #starts chaseCursor subroutine once per player
        async(chaseCursorValues, AsyncBehavior.NOOP)
    wait(0.03)
    top


def chaseCursorValues():
    #eventPlayer.cursor= eventPlayer.cursorNew
    if(HoriBounds and VertBounds):
        eventPlayer.cursor=eventPlayer.cursorNew
    wait(0.001)
    top