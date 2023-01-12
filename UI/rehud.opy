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

playervar CamLoc
playervar Debug
playervar Distance
playervar Ready
playervar selectionUIPos
subroutine cameraToggle
subroutine betterForcing

enum forG:
    VERTICAL_BOXES,
    HORIZONTAL_BOXES
globalvar Iter
#!define forGlobal(index,startval,max)/**/\
Iter[(forG.index)] = startval\
while(Iter[(forG.index)]<(max))
#!define forEndG(index) Iter[(forG.index)]+=1
#Iter[forG]


#!define cursPos(player) updateEveryTick(EYE(player)+ vFOR*50 -(player).getHorizontalFacingAngle()*vRIGHT- (player).getHorizontalFacingAngle()*vUP)
#!define cursAngle(player) normalize(directionTowards(EYE(player),cursPos(player)))

#!define CamPos(player)  /*(vFOR*(player).Distance*-1)*/
#!define EYE(player) (vect(0,0.89,-0.45)*hostPlayer.Distance)
#updateEveryTick((player).CamLoc+vect(0,10,0)+) 
#!define SENSTV 10
#!define CURSORX updateEveryTick(-localPlayer.getHorizontalFacingAngle())
#!define CURSORZ updateEveryTick(-localPlayer.getVerticalFacingAngle())

#!define vFOR vect(0,-0.89,0.45) /*Direction between camera EYE(localPlayer) and camera look point or look at direction*/
#!define vRIGHT vect(-1,0,0) /*angleToDirection(horizontalAngleOfDirection(vFOR)-90,verticalAngleOfDirection(vFOR))*/
#!define vUP vect(0,0.45,0.89) /*crossProduct(vRIGHT,vFOR)*/
#todo: 8.9 isnt right for some reason
#optimize irlPos
#!define irlPos(xpos,ypos) updateEveryTick(normalize(directionTowards(EYE(localPlayer), EYE(localPlayer)+ vFOR*50 + ((xpos)*vRIGHT+ (ypos)*vUP)))*8.9 + EYE(localPlayer))
#!define uiPos(xpos,ypos) updateEveryTick(EYE(localPlayer)+ vFOR*50 + ((xpos)*vRIGHT+ (ypos)*vUP))
#!define arrToString7(arr) ("{},{},{},{},{},{}".format((arr)[0],(arr)[1],(arr)[2],(arr)[3],(arr)[4],(arr)[5],(arr)[6])).replace(",0",",_")
#!define textPos(pos) updateEveryTick((pos) + vUP * (dotProduct(vFOR, (pos) - EYE(localPlayer)) / 18)) /*text is anchored to its correct position*/
#!define cursorPos vect(0,0,0)
##!define DISTANCE 50 /*used for UI, defines screen size. Lowering this value changes your Y upper and lower limit and the wraparound distance for the X*/
##!define cursorPos 1000/(CURSORZ+89)*(vFOR + CURSORX/localPlayer.Distance*vRIGHT+CURSORZ/localPlayer.Distance*vUP)+EYE(localPlayer)
#-10/(-0.89 + Z/50*-0.45)
#(0-CamPos.y)/( vFOR.y +CURSORZ/localPlayer.Distance*vUP.y)
#10/(0.89+CURSORZ*24.5)
#
rule "Turn off HUD":
    @Event eachPlayer
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableHeroHUD()
    eventPlayer.CamLoc = vect(0,-10,0)
    eventPlayer.setGravity(0)
    eventPlayer.setMoveSpeed(0)
    eventPlayer.startForcingHero(Hero.TRACER)
    eventPlayer.Distance = 10
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ULTIMATE)
    eventPlayer.startCamera(vect(0,0,0),vect(0,-1,0),10000)
    waitUntil(eventPlayer.hasSpawned(),100)
    eventPlayer.startForcingPosition(eventPlayer.CamLoc,false)
    wait(1)
    eventPlayer.stopForcingPosition()
    eventPlayer.setFacing(vect(0,0,1),Relativity.TO_WORLD)
    eventPlayer.Ready = true
    /*eventPlayer.startCamera(EYE(localPlayer)-vFOR*eventPlayer.Distance,-vFOR,40)*/
    async(cameraToggle(),AsyncBehavior.NOOP)
    async(betterForcing(),AsyncBehavior.NOOP)
    

def cameraToggle():
    eventPlayer.startCamera(EYE(eventPlayer),EYE(eventPlayer)+vFOR,40)
    waitUntil(eventPlayer.isHoldingButton(Button.RELOAD),10000)
    eventPlayer.stopCamera()
    waitUntil(not eventPlayer.isHoldingButton(Button.RELOAD),10000)
    goto RULE_START

def betterForcing():
    if((eventPlayer.getPosition().x-eventPlayer.CamLoc.x)**2 + (eventPlayer.getPosition().z-eventPlayer.CamLoc.z)**2 > 1):
        eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(),eventPlayer.CamLoc),distance(eventPlayer.getPosition(),eventPlayer.CamLoc),Relativity.TO_WORLD,Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    wait(1)
    goto RULE_START

#!define debugPrint(text) hudHeader(localPlayer if localPlayer.Debug else null,(text),HudPosition.RIGHT,0,Color.WHITE,HudReeval.VISIBILITY_AND_STRING,SpecVisibility.NEVER)
rule "Hero Profile":
    setMatchTime(0)
    pauseMatchTime()
    wait(1)
    disableAnnouncer()
    debugPrint("({},{} / {})".format(CURSORX,CURSORZ,localPlayer.getFacingDirection()))
    debugPrint(localPlayer.Distance)
    debugPrint(cursorPos)
    debugPrint(arrToString7(localPlayer.selectionUIPos))
    #debugPrint("{}/{}".format((0-CamPos(localPlayer).y)/( vFOR.y +CURSORZ/localPlayer.Distance*vUP.y),1000/(CURSORZ+89)))
    createInWorldText(localPlayer if getTotalTimeElapsed()%0.032>0.016 else null,"\&black_circle;",uiPos(CURSORX,CURSORZ)-vUP, 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.RED, SpecVisibility.ALWAYS)
    createInWorldText(localPlayer if getTotalTimeElapsed()%0.032<=0.016  else null,"\&black_circle;",uiPos(CURSORX,CURSORZ)-vUP, 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.RED, SpecVisibility.ALWAYS)
    #selection
    #print("CamPos:{}\nvUP:{}".format(CamPos(localPlayer),vUP))
    createBeam(localPlayer,Beam.GRAPPLE,irlPos(localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[1]),irlPos(localPlayer.selectionUIPos[2],localPlayer.selectionUIPos[1]),Color.WHITE,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(localPlayer,Beam.GRAPPLE,irlPos(localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[1]),irlPos(localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[3]),Color.WHITE,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(localPlayer,Beam.GRAPPLE,irlPos(localPlayer.selectionUIPos[2],localPlayer.selectionUIPos[3]),irlPos(localPlayer.selectionUIPos[2],localPlayer.selectionUIPos[1]),Color.WHITE,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(localPlayer,Beam.GRAPPLE,irlPos(localPlayer.selectionUIPos[2],localPlayer.selectionUIPos[3]),irlPos(localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[3]),Color.WHITE,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    #createEffect(localPlayer,Effect.SPHERE,Color.WHITE,EYE(localPlayer)+(EYE(localPlayer).y/
    #eye location + normalized direction from the eye to the cursor position * the height difference between the two points = cursor on the map
    print("quad1:{}\tquad2{}\nquad3{}\tquad4{}".format(irlPos(62,35),irlPos(-62,35),irlPos(-62,-35),irlPos(62,-35)))
rule "toggle hud":
    @Event eachPlayer
    @Condition eventPlayer.Ready == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    eventPlayer.enableHeroHud()
    waitUntil(eventPlayer.isHoldingButton(Button.INTERACT)==false,100)
    eventPlayer.disableHeroHUD()

rule "up":
    @Event eachPlayer
    @Condition eventPlayer.Ready #  and false
    @Condition eventPlayer.isHoldingButton(Button.JUMP)
    eventPlayer.Distance += 1
    wait(0.1)
    if(RULE_CONDITION):
        goto RULE_START

rule "down":
    @Event eachPlayer
    @Condition eventPlayer.Ready  #and false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    eventPlayer.Distance -= 1
    wait(0.1)
    if(RULE_CONDITION):
        goto RULE_START

rule "turn":
    @Event eachPlayer
    @Condition eventPlayer.Ready
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    eventPlayer.Debug = not eventPlayer.Debug

rule "selection box":
    @Event eachPlayer
    @Condition eventPlayer.Ready
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    wait(0.1)
    if(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)):
        goto hide
    if(not RULE_CONDITION):
        return
    eventPlayer.selectionUIPos[0] = -eventPlayer.getHorizontalFacingAngle()
    eventPlayer.selectionUIPos[1] = -eventPlayer.getVerticalFacingAngle()
    while(eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)):
        eventPlayer.selectionUIPos[2] = -eventPlayer.getHorizontalFacingAngle()
        eventPlayer.selectionUIPos[3] = -eventPlayer.getVerticalFacingAngle()
        wait(0.15)
    hide:
        eventPlayer.selectionUIPos=[]

#!define collisionPointRect(rectx,halfwidth,recty,height,pointx,pointy,radius) ((pointx-radius<rectx+halfwidth) and (pointx+radius>rectx-halfwidth /*left and right*/) and (pointy-radius<recty+height) and (pointy+radius > recty /*top and bottom*/))

#!define loops 10
rule "ui grid":
    #createEffect(localPlayer,Effect.SPHERE,Color.AQUA,cursorPos,0.1,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    forGlobal(HORIZONTAL_BOXES,-6,7):
        forGlobal(VERTICAL_BOXES,-3,4):
            #"{},{}".format(Iter[forG.HORIZONTAL_BOXES],Iter[forG.VERTICAL_BOXES])
            wait()
            #!define mouseOver rgba(255,255,255,50) if collisionPointRect(evalOnce(Iter[forG.HORIZONTAL_BOXES]*10),1.5,evalOnce(Iter[forG.VERTICAL_BOXES])*10,3,CURSORX,CURSORZ,0.17) else Color.BLACK
            createInWorldText(localPlayer, "\&black_square;",uiPos(evalOnce(Iter[forG.HORIZONTAL_BOXES])*10,evalOnce(Iter[forG.VERTICAL_BOXES])*10),4,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR, mouseOver ,SpecVisibility.ALWAYS)
            forEndG(VERTICAL_BOXES)
        forEndG(HORIZONTAL_BOXES)
