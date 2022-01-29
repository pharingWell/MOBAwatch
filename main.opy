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
    CPlayers=[-1]
    Players=[-1]
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


rule "Inspector":
    @Condition Ready == true
    disableInspector()
    wait(1)
    enableInspector()
    top

rule "left":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)
    if(eventPlayer.getTeam()==Team.1):
        Players[0]=replace("null",Players[0].index(eventPlayer),Players[0])
    else:
        Players[1]=replace("null",Players[1].index(eventPlayer),Players[1])
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
        if(CPlayers[0][PlayerLeft_i].Owner!=Players[0][PlayerLeft_i]):
            Players[0]=Players[0]
            #destroyDummy(Team.1,TeamSize+PlayerLeft_i)
            #CPlayers[0]=replace(CPlayers[0][PlayerLeft_i])
    for PlayerLeft_i in range(len(CPlayers[1])):
        if(CPlayers[1][PlayerLeft_i].Owner!=Players[1][PlayerLeft_i]):
            #destroyDummy(Team.2,TeamSize+PlayerLeft_i)
            #CPlayers[1]=CPlayers[0].exclude(CPlayers[1][PlayerLeft_i])
    disableInspector()


def UI_Setup():
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableGamemodeHud()
    createInWorldText(eventPlayer,"<•>",updateEveryTick(vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.ControlledRef.getEyePosition().y+0.0,eventPlayer.ControlledRef.getEyePosition().z+0.2)),1.5*(not eventPlayer.ControlledRef.Hidden),Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,Color.RED,SpecVisibility.NEVER)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.RELOAD)
    eventPlayer.disallowButton(Button.MELEE)
    eventPlayer.disallowButton(Button.JUMP)
    for(i in range(0,TeamSize)):
        if(eventPlayer.Team==1):
            hudText(eventPlayer,"{0}{1}".format(heroIcon(Players[0][evalOnce(i)].getCurrentHero()),Players[0][evalOnce(i)]),Players[0][evalOnce(i)].getHealth(),null,HudPosition.LEFT,i-TeamSize,Players[0][evalOnce(i)].UIContainer[0],Players[0][evalOnce(i)].UIContainer[0],null,HudReeval.STRING_AND_COLOR)
            hudText(eventPlayer,"{0}{1}".format(heroIcon(Players[1][evalOnce(i)].getCurrentHero()),Players[1][evalOnce(i)]),null,null,HudPosition.RIGHT,i-TeamSize,Players[1][evalOnce(i)].UIContainer[0],Players[1][evalOnce(i)].UIContainer[0],null,HudReeval.STRING_AND_COLOR)
        else:
            hudText(eventPlayer,"{0}{1}".format(heroIcon(Players[1][evalOnce(i)].getCurrentHero()),Players[1][evalOnce(i)]),Players[1][evalOnce(i)].getHealth(),null,HudPosition.LEFT,i-TeamSize,Players[1][evalOnce(i)].UIContainer[0],Players[1][evalOnce(i)].UIContainer[0],null,HudReeval.STRING_AND_COLOR)
            hudText(eventPlayer,"{0}{1}".format(heroIcon(Players[0][evalOnce(i)].getCurrentHero()),Players[0][evalOnce(i)]),null,null,HudPosition.RIGHT,i-TeamSize,Players[0][evalOnce(i)].UIContainer[0],Players[0][evalOnce(i)].UIContainer[0],null,HudReeval.STRING_AND_COLOR)
            

def UI_Process():
    @Name "S_UI_Process"
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
    createInWorldText(eventPlayer,"•",vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z-eventPlayer.CamLoc.y/12.5),2.5,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,eventPlayer.UICursorStyles[0],SpecVisibility.NEVER)
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
    wait(0.1)
    eventPlayer.ControlledRef.CPos = vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z)
    startAction(0,eventPlayer.ControlledRef)
    createInWorldText(eventPlayer,"¤",vect(eventPlayer.ControlledRef.CPos.x,0,eventPlayer.ControlledRef.CPos.z-eventPlayer.CamLoc.y/12.5),2.0,Clip.NONE,WorldTextReeval.NONE,Color.SKY_BLUE,SpecVisibility.NEVER)
    eventPlayer.MovementGroundCursor = getLastCreatedText()


rule "Throttling Bot":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isDummy()
    @Condition getPlayersInRadius(eventPlayer.CPos,0.5,Team.ALL,LosCheck.OFF)
    destroyInWorldText(eventPlayer.Owner.MovementGroundCursor)
    eventPlayer.stopFacing() 
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
        
        chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z),duration=0.3,ChaseReeval.DESTINATION_AND_DURATION)
        wait(0.3)
        chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.CPos.x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.CPos.z),rate=eventPlayer.ControlledRef.getSpeed(),ChaseReeval.DESTINATION_AND_RATE)

def moveCameraWithPlayer():
    if(eventPlayer.CamAttach):
        chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z),rate=eventPlayer.ControlledRef.getSpeed(),ChaseReeval.DESTINATION_AND_RATE)

def CameraSetup():
    @Name "S_CameraSetup"
    eventPlayer.CamLoc = vect(0,15,0)
    eventPlayer.setFacing(vect(0,0,0),Relativity.TO_WORLD) #15,-4

    eventPlayer.startCamera(vect(eventPlayer.CamLoc.x,eventPlayer.CamLoc.y,eventPlayer.CamLoc.z-0.01), vect(eventPlayer.CamLoc.x, 0, eventPlayer.CamLoc.z), 35)
    eventPlayer.ControlledRef.CPos=vect(0,0,0)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.setStatusEffect(null,Status.PHASED_OUT,9999)
    eventPlayer.setDamageReceived(0)

rule "Camera Bounds":
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
        eventPlayer.setFacing(angleToDirection((180/Math.PI)*0.97*(HoriLimit)*(eventPlayer.eyeAxis[0]/abs(eventPlayer.eyeAxis[0])),eventPlayer.eyeAxis[1]*-1*(180/Math.PI)),Relativity.TO_WORLD)
        #eventPlayer.setFacing(vect(sin(*1)), eventPlayer.i, cos(ScreenLimits[0]*(eventPlayer.eyeAxis[0]/abs(eventPlayer.eyeAxis[0])*1))),Relativity.TO_WORLD)
    elif(not VertBounds):
        eventPlayer.setFacing(angleToDirection((180/Math.PI)*eventPlayer.eyeAxis[0],(180/Math.PI)*-0.97*(VertLimit)*(eventPlayer.eyeAxis[1]/abs(eventPlayer.eyeAxis[1]))),Relativity.TO_WORLD)
        #Don't move the screen if your camera is locked
    if(not eventPlayer.CamAttach):
        #If mouse outside normal range(and camera unlocked), move screen that direction a given rate
        if(abs(eventPlayer.eyeAxis[0])>=HoriLimit*0.93):
            eventPlayer.CamLoc=(vect(eventPlayer.CamLoc.x+Setting_CamSpeed*(eventPlayer.eyeAxis[0]/abs(eventPlayer.eyeAxis[0])),eventPlayer.CamLoc.y,eventPlayer.CamLoc.z))
        #If mouse outside normal range(and camera unlocked), move screen that direction a given rate
        if(abs(eventPlayer.eyeAxis[1])>=VertLimit*0.93):
            eventPlayer.CamLoc=(vect(eventPlayer.CamLoc.x,eventPlayer.CamLoc.y,eventPlayer.CamLoc.z+Setting_CamSpeed*(eventPlayer.eyeAxis[1]/abs(eventPlayer.eyeAxis[1]))))
    ##
    eventPlayer.cursorNew=vect((eventPlayer.CamLoc.y*2.750)*(eventPlayer.eyeAxis[0]/Math.PI)+eventPlayer.CamLoc.x,0,((eventPlayer.eyeAxis[1])/(Math.PI/2))*(eventPlayer.CamLoc.y*0.775)+eventPlayer.CamLoc.z)
    if(eventPlayer.cursor==0):
        eventPlayer.cursor=vect(0,0.01,0)
        #starts chaseCursor subroutine once per player
        async(chaseCursorValues, AsyncBehavior.NOOP)
    wait(0.03)
    top


def chaseCursorValues():    
    if(HoriBounds and VertBounds):
        eventPlayer.cursor=eventPlayer.cursorNew
    wait(0.001)
    top
