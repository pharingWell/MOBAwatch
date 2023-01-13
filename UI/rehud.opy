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
        "minimumLatencyInNs": 150000000,
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
playervar selectionUIPos #the variable is an array of length 4 that stores the positions of the values needed for the selection box. The values are: [original selection x, original selection z, current cursor x, current cursor z]
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
##!define DISTANCE 50 /*used for UI, defines screen size. Lowering this value changes your Y upper and lower limit and the wraparound distance for the X*/
##!define cursorPos 1000/(CURSORZ+89)*(vFOR + CURSORX/localPlayer.Distance*vRIGHT+CURSORZ/localPlayer.Distance*vUP)+EYE(localPlayer)
#-10/(-0.89 + Z/50*-0.45)
#(0-CamPos.y)/( vFOR.y +CURSORZ/localPlayer.Distance*vUP.y)
#10/(0.89+CURSORZ*24.5)
#
#!extension beamEffects

rule "Turn off HUD":
    @Event eachPlayer
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableHeroHUD()
    eventPlayer.CamLoc = vect(0,-10,0)
    eventPlayer.setGravity(0)
    eventPlayer.setMoveSpeed(0)
    eventPlayer.startForcingHero(Hero.TRACER)
    eventPlayer.selectionUIPos=[]
    eventPlayer.Distance = 10
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ULTIMATE)
    eventPlayer.startCamera(vect(0,0,0),vect(0,-1,0),10000)
    waitUntil(eventPlayer.hasSpawned(),100)
    eventPlayer.startForcingPosition(eventPlayer.CamLoc,false)
    wait(0.25)
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
    debugPrint(arrToString7(localPlayer.selectionUIPos))
    #debugPrint("{}/{}".format((0-CamPos(localPlayer).y)/( vFOR.y +CURSORZ/localPlayer.Distance*vUP.y),1000/(CURSORZ+89)))
    createInWorldText(localPlayer if getTotalTimeElapsed()%0.032>0.016 else null,"\&black_circle;",uiPos(CURSORX,CURSORZ)-vUP, 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.RED, SpecVisibility.ALWAYS)
    createInWorldText(localPlayer if getTotalTimeElapsed()%0.032<=0.016  else null,"\&black_circle;",uiPos(CURSORX,CURSORZ)-vUP, 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.RED, SpecVisibility.ALWAYS)
    #selection
    #print("CamPos:{}\nvUP:{}".format(CamPos(localPlayer),vUP)) 
    #vect(0,-20,0)*(len(localPlayer.selectionUIPos)<4)
    #!define beamType Beam.JUNKRAT_TRAP_CHAIN
    #!define beamVis localPlayer if localPlayer.selectionUIPos[4] else null
    createBeam(beamVis,beamType,irlPos(localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[1]),irlPos(CURSORX,localPlayer.selectionUIPos[1]),null,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(beamVis,beamType,irlPos(localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[1]),irlPos(localPlayer.selectionUIPos[0],CURSORZ),null,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(beamVis,beamType,irlPos(CURSORX,CURSORZ),irlPos(CURSORX,localPlayer.selectionUIPos[1]),null,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(beamVis,beamType,irlPos(CURSORX,CURSORZ),irlPos(localPlayer.selectionUIPos[0],CURSORZ),null,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    #createEffect(localPlayer,Effect.SPHERE,Color.WHITE,EYE(localPlayer)+(EYE(localPlayer).y/
    #eye location + normalized direction from the eye to the cursor position * the height difference between the two points = cursor on the map
    #print("quad1:{}\tquad2{}\nquad3{}\tquad4{}".format(irlPos(62,35),irlPos(-62,35),irlPos(-62,-35),irlPos(62,-35)))
rule "toggle hud":
    @Event eachPlayer
    @Condition eventPlayer.Ready == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    eventPlayer.enableHeroHud()
    waitUntil(eventPlayer.isHoldingButton(Button.INTERACT)==false,100)
    eventPlayer.disableHeroHUD()

rule "up":
    @Event eachPlayer
    @Condition eventPlayer.Ready   and false
    @Condition eventPlayer.isHoldingButton(Button.JUMP)
    eventPlayer.Distance += 1
    wait(0.1)
    if(RULE_CONDITION):
        goto RULE_START

rule "down":
    @Event eachPlayer
    @Condition eventPlayer.Ready  and false
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
    eventPlayer.selectionUIPos = [-eventPlayer.getHorizontalFacingAngle(),-eventPlayer.getVerticalFacingAngle(),-eventPlayer.getHorizontalFacingAngle(),-eventPlayer.getVerticalFacingAngle()]
    #!define 2dDistance(x1,y1,x2,y2) (x2 - x1)**2 + (y2 - y1)**2
    waitUntil(2dDistance(eventPlayer.selectionUIPos[0],eventPlayer.selectionUIPos[1],-eventPlayer.getHorizontalFacingAngle(),-eventPlayer.getVerticalFacingAngle())>1 or not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE),100)
    if(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)):
        goto hide
    eventPlayer.selectionUIPos[2] = -eventPlayer.getHorizontalFacingAngle()
    eventPlayer.selectionUIPos[3] = -eventPlayer.getVerticalFacingAngle()
    eventPlayer.selectionUIPos[4] = true
    while(eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)):
        eventPlayer.selectionUIPos[2] = -eventPlayer.getHorizontalFacingAngle()
        eventPlayer.selectionUIPos[3] = -eventPlayer.getVerticalFacingAngle()
        wait()
    hide:
        eventPlayer.selectionUIPos = []
        



        #rect1 x, rect1 halfwidth, rect1 y, rect1 height
#!define collisionRectRect(r1x,r1hw,r1y,r1h,r2x1,r2y1,r2x2,r2y2)/*rectangle 1 is a rectangle with an origin in the middle of its shape, rectangle 2 is a normal rectangle defined by x,y and x2, y2*/\
    r1x + r1hw >= r2x1 /*the origin point of rectangle 1, plus half its width is its right edge, and the r2 origin minus half the width is its left most edge*/\
and r1x - r1hw <= r2x2 /*r1 left edge less than r2 right edge*/\
and r1y + r1h >= r2y1 /*r1 top edge is above r2 bottom*/\
and r1y <= r2y2 /*r1 bottom edge is below the rop of r2*/\
/*thus, the rectangles are colliding*/

#!define selectionContain(r1x,r1hw,r1y,r1h,sx1,sy1,sx2,sy2)/*rectangle 1 is a rectangle with an origin in the middle of its shape, selection is a normal rectangle defined by x,y and x2, y2. */\
    /*Rather than detecting a collision, this detects if rectangle 1 is completely surrounded by the selection*/\
    r1x - r1hw <= max(sx1,sx2) /*rect1 left side is greater than rect2 right side*/\
and r1x + r1hw >= min(sx2,sx1) /*r1 right edge less than r2 left edge*/\
and r1y + r1h >= min(sy2,sy1) /*r1 bottom edge is below the rop of r2*/\
and r1y <= max(sy1 ,sy2)/*r1 top edge is above r2 bottom*/\
and localPlayer.selectionUIPos[4]
/*thus, the rectangles are colliding*/


#!define collisionPointRect(rect1x,halfwidth,rect1y,height,pointx,pointy,radius) ((pointx-radius<rect1x+halfwidth) and (pointx+radius>rect1x-halfwidth /*left and right*/) and (pointy-radius<rect1y+height) and (pointy+radius > rect1y /*top and bottom*/))

#!define loops 10
rule "ui grid":
    #createEffect(localPlayer,Effect.SPHERE,Color.AQUA,cursorPos,0.1,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    forGlobal(HORIZONTAL_BOXES,-6,7):
        forGlobal(VERTICAL_BOXES,-3,4):
            #"{},{}".format(Iter[forG.HORIZONTAL_BOXES],Iter[forG.VERTICAL_BOXES])
            wait()
            #!define mouseOver rgba(255,255,255,50) if selectionContain(evalOnce(Iter[forG.HORIZONTAL_BOXES]*10),1.5,evalOnce(Iter[forG.VERTICAL_BOXES])*10,3,localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[1],localPlayer.selectionUIPos[2],localPlayer.selectionUIPos[3]) else Color.BLACK if collisionPointRect(evalOnce(Iter[forG.HORIZONTAL_BOXES]*10),1.5,evalOnce(Iter[forG.VERTICAL_BOXES])*10,3,CURSORX,CURSORZ,0.17) else Color.GRAY 
            createInWorldText(localPlayer, "\&black_square;",uiPos(evalOnce(Iter[forG.HORIZONTAL_BOXES])*10,evalOnce(Iter[forG.VERTICAL_BOXES])*10),4,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR, mouseOver ,SpecVisibility.ALWAYS)
            forEndG(VERTICAL_BOXES)
        forEndG(HORIZONTAL_BOXES)
