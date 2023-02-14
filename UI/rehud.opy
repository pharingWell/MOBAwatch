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
globalvar UIObj_IDs
globalvar UIObj_Generator
playervar UIObj_UIPosition #vect of uiPos(uipos_x,uipos_z) 
playervar UIObj_Selected #array of bools
playervar selectedOffset #selected drag is active (bool)
playervar cursorX
playervar cursorY

playervar CamLoc
playervar Debug
playervar Distance
globalvar gameReady
playervar Ready
playervar selectionUIPos #the variable is an array of length 4 that stores the positions of the values needed for the selection box. The values are: [original selection x, original selection z, current cursor x, current cursor z]
playervar hudUIHeights #stores how many rows are used so that menus can open up
subroutine cameraToggle
subroutine betterForcing

playervar Temp
#!define pTemp(enumvalue) eventPlayer.Temp[tempP.enumvalue] 
enum tempP:
    UNDERCURSOR,
    HIGHESTOBJ
playervar Iter
#!define forPlayer(enum,startval,max)/**/\
eventPlayer.Iter[forP.enum] = startval\
while(eventPlayer.Iter[forP.enum]<(max))
#!define forEndP(enum) eventPlayer.Iter[forP.enum]+=1
#eventPlayer.Iter[forP]
enum forP:
    CAPTURESELECTION

globalvar Iter
#!define forGlobal(enum,startval,max)/**/\
Iter[(forG.enum)] = startval\
while(Iter[(forG.enum)]<(max))
#!define forEndG(enum) Iter[(forG.enum)]+=1
#Iter[forG]

enum forG:
    GENERATEOBJS,





#!define cursPos(player) updateEveryTick(EYE(player)+ vFOR*50 -(player).getHorizontalFacingAngle()*vRIGHT- (player).getHorizontalFacingAngle()*vUP)
#!define cursAngle(player) normalize(directionTowards(EYE(player),cursPos(player)))

#!define CamPos(player)  /*(vFOR*(player).Distance*-1)*/
#!define EYE(player) (vect(0,0.89,-0.45)*hostPlayer.Distance)
#updateEveryTick((player).CamLoc+vect(0,10,0)+) 
#!define SENSTV 10
#!define CURSORX updateEveryTick(-localPlayer.getHorizontalFacingAngle())
#!define CURSORY updateEveryTick(-localPlayer.getVerticalFacingAngle())

#!define vFOR vect(0,-0.89,0.45) /*Direction between camera EYE(localPlayer) and camera look point or look at direction*/
#!define vRIGHT vect(-1,0,0) /*angleToDirection(horizontalAngleOfDirection(vFOR)-90,verticalAngleOfDirection(vFOR))*/
#!define vUP vect(0,0.45,0.89) /*crossProduct(vRIGHT,vFOR)*/

#!define DEBUG_LOCATION 0
#!define debugPrint(text) hudHeader(localPlayer if localPlayer.Debug else null,(text),HudPosition.LEFT,0,Color.WHITE,HudReeval.VISIBILITY_AND_STRING,SpecVisibility.NEVER)
#!define arrToString7(arr) ("{},{},{},{},{},{}".format((arr)[0],(arr)[1],(arr)[2],(arr)[3],(arr)[4],(arr)[5],(arr)[6])).replace(",0",",_")
#todo: 8.9 isnt right for some reason
#optimize irlPos
#!define irlPos(xpos,ypos) updateEveryTick(normalize(directionTowards(EYE(localPlayer), EYE(localPlayer)+ vFOR*50 + ((xpos)*vRIGHT+ (ypos)*vUP)))*8.9 + EYE(localPlayer))
#!define uiPos(xpos,ypos) updateEveryTick(EYE(localPlayer)+ vFOR*50 + ((xpos)*vRIGHT+ (ypos)*vUP))
##!define DISTANCE 50 /*used for UI, defines screen size. Lowering this value changes your Y upper and lower limit and the wraparound distance for the X*/
##!define cursorPos 1000/(CURSORY+89)*(vFOR + CURSORX/localPlayer.Distance*vRIGHT+CURSORY/localPlayer.Distance*vUP)+EYE(localPlayer)
#-10/(-0.89 + Z/50*-0.45)
#(0-CamPos.y)/( vFOR.y +CURSORY/localPlayer.Distance*vUP.y)
#10/(0.89+CURSORY*24.5)
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
    eventPlayer.selectionUIPos = [-1000,-1000,-1000,-1000]
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ULTIMATE)
    waitUntil(eventPlayer.hasSpawned(),100)
    eventPlayer.startCamera(vect(0,1,0),vect(0,-1,0),10000)
    eventPlayer.teleport(eventPlayer.CamLoc-vect(0,-30,0))
    eventPlayer.Ready = true
    waitUntil(gameReady==true,100)
    eventPlayer.Distance = 10
    eventPlayer.UIObj_UIPosition = UIObj_Generator
    async(cameraToggle(),AsyncBehavior.NOOP)
    async(betterForcing(),AsyncBehavior.NOOP)
    eventPlayer.Distance = 10
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

/*made using equations from https://www.rapidtables.com/convert/color/hsv-to-rgb.html*/
#!define hsv_C(s,v) (s * v) /*0.49*/
#!define hsv_X(h,s,v) hsv_C(s,v) * (1 - abs(((h)/60) % 2 - 1))
#!define hsv_M(s,v) (v - hsv_C(s,v)) /*0.21*/
#!define hsv_r(h,s,v) (hsv_C(s,v) if abs((h)-180)>=120 else hsv_X(h,s,v) if abs((h)-180)>=60 else 0)
#!define hsv_b(h,s,v) (hsv_X(h,s,v) if (h)%180 < 60 else hsv_C(s,v) if (h) < 180 else 0)
#!define hsv_g(h,s,v) (hsv_X(h,s,v) if (h)%180 >= 120 else 0 if (h) < 180 else hsv_C(s,v))
#!define hsv(h,s,v) updateEveryTick(rgb((hsv_r(h,s,v)+hsv_M(s,v))*255,(hsv_b(h,s,v)+hsv_M(s,v))*255,(hsv_g(h,s,v)+hsv_M(s,v))*255))

#reeval must include visibility and string
#!define hudUISet(x,y,pos) hudSubheader(localPlayer,updateEveryTick("{}{}".format("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n".substring(0,max(1,y)),"                                                                                                                              ".substring(0,max(1,x)) )),pos,300,null,HudReeval.VISIBILITY_AND_STRING,SpecVisibility.NEVER)

rule "Hero Profile":
    setMatchTime(0)
    pauseMatchTime()
    wait(1)
    disableAnnouncer()  
    #print("{},{}".format(max(1,(localPlayer.getHorizontalFacingAngle())/119*103+52),((localPlayer.getHorizontalFacingAngle())-3)/67*42+21))
    hudUISet(0,25-localPlayer.hudUIHeights[0],HudPosition.LEFT)
    hudText(localPlayer,"SETTINGS" if not localPlayer.Debug else "1.\n2.\n3.\n4.\nSETTINGS","","",HudPosition.LEFT,301,  Color.GREEN,Color.BLACK,Color.AQUA,HudReeval.VISIBILITY_AND_SORT_ORDER,SpecVisibility.NEVER)
    hudUISet(0,25-localPlayer.hudUIHeights[1],HudPosition.TOP)
    hudText(localPlayer,"01    03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43","","",HudPosition.TOP,301,Color.RED,Color.BLACK,Color.AQUA,HudReeval.VISIBILITY_AND_SORT_ORDER,SpecVisibility.NEVER)
    hudUISet(0,25-localPlayer.hudUIHeights[2],HudPosition.RIGHT)
    hudText(localPlayer,"01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43","","",HudPosition.RIGHT,301,Color.YELLOW,Color.BLACK,Color.AQUA,HudReeval.VISIBILITY_AND_SORT_ORDER,SpecVisibility.NEVER)

    #hudText(localPlayer,"",,"",HudPosition.RIGHT,300,null,Color.AQUA,null,HudReeval.VISIBILITY_SORT_ORDER_AND_STRING,SpecVisibility.NEVER)
    #hudText(localPlayer,"",updateEveryTick(),"o",HudPosition.RIGHT,300,null,Color.AQUA,Color.GREEN,HudReeval.VISIBILITY_SORT_ORDER_AND_STRING,SpecVisibility.NEVER)
    #hudHeader(localPlayer,"hudbased cursor!",HudPosition.RIGHT,301,hsv(getTotalTimeElapsed()%3/3*360,0.7,0.9),HudReeval.VISIBILITY_AND_COLOR,SpecVisibility.NEVER)
    #!define NUM_OF_DEBUGS 7
    debugPrint("({},{} / {})".format(CURSORX,CURSORY,localPlayer.getFacingDirection()))
    debugPrint(localPlayer.Distance)
    debugPrint(arrToString7(localPlayer.selectionUIPos))
    #debugPrint("{}/{}".format((0-CamPos(localPlayer).y)/( vFOR.y +CURSORY/localPlayer.Distance*vUP.y),1000/(CURSORY+89)))
    createInWorldText(localPlayer if getTotalTimeElapsed()%0.032>0.016 else null,"\&black_circle;",uiPos(CURSORX,CURSORY)-vUP, 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.RED, SpecVisibility.ALWAYS)
    createInWorldText(localPlayer if getTotalTimeElapsed()%0.032<=0.016  else null,"\&black_circle;",uiPos(CURSORX,CURSORY)-vUP, 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.RED, SpecVisibility.ALWAYS)
    #selection
    #print("CamPos:{}\nvUP:{}".format(CamPos(localPlayer),vUP)) 
    #vect(0,-20,0)*(len(localPlayer.selectionUIPos)<4)
    #!define beamType Beam.SYMMETRA_TURRET
    #!define beamVis localPlayer if localPlayer.selectionUIPos[4] and localPlayer.isHoldingButton(Button.PRIMARY_FIRE) else null
    #!define beamColor localPlayer.getTeam()
    createBeam(beamVis,beamType,irlPos(CURSORX,localPlayer.selectionUIPos[1]),irlPos(localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[1]),beamColor,EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    createBeam(beamVis,beamType,irlPos(localPlayer.selectionUIPos[0],CURSORY),irlPos(localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[1]),beamColor,EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    createBeam(beamVis,beamType,irlPos(CURSORX,localPlayer.selectionUIPos[1]),irlPos(CURSORX,CURSORY),beamColor,EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    createBeam(beamVis,beamType,irlPos(localPlayer.selectionUIPos[0],CURSORY),irlPos(CURSORX,CURSORY),beamColor,EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    #createEffect(localPlayer,Effect.SPHERE,Color.WHITE,EYE(localPlayer)+(EYE(localPlayer).y/
    #eye location + normalized direction from the eye to the cursor position * the height difference between the two points = cursor on the map
    #print("quad1:{}\tquad2{}\nquad3{}\tquad4{}".format(irlPos(62,35),irlPos(-62,35),irlPos(-62,-35),irlPos(62,-35)))
rule "toggle hud":
    @Event eachPlayer
    @Condition (gameReady and eventPlayer.Ready) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    eventPlayer.enableHeroHud()
    waitUntil(eventPlayer.isHoldingButton(Button.INTERACT)==false,100)
    eventPlayer.disableHeroHUD()

rule "up":
    @Event eachPlayer
    @Condition (gameReady and eventPlayer.Ready)  # and false
    @Condition eventPlayer.isHoldingButton(Button.JUMP)
    #eventPlayer.Distance += 1
    eventPlayer.cursorX += 1
    wait(0.1)
    if(RULE_CONDITION):
        goto RULE_START

rule "down":
    @Event eachPlayer
    @Condition (gameReady and eventPlayer.Ready)  #and false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    #eventPlayer.Distance -= 1
    eventPlayer.cursorX -= 1
    wait(0.1)
    if(RULE_CONDITION):
        goto RULE_START

rule "debug mode":
    @Event eachPlayer
    @Condition (gameReady and eventPlayer.Ready)
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    eventPlayer.Debug = not eventPlayer.Debug
    if(eventPlayer.Debug):
        eventPlayer.hudUIHeights[DEBUG_LOCATION] += NUM_OF_DEBUGS
    else:
        eventPlayer.hudUIHeights[DEBUG_LOCATION] -= NUM_OF_DEBUGS


#!define selectionContain(r1x,r1hw,r1y,r1h,sx1,sy1,sx2,sy2)/*rectangle 1 is a rectangle with an origin in the middle of its shape, selection is a normal rectangle defined by x,y and x2, y2. */\
/*Rather than detecting a collision, this detects if rectangle 1 is completely surrounded by the selection*/\
    r1x - r1hw <= max(sx1,sx2) /*rect1 left side is greater than rect2 right side*/\
and r1x + r1hw >= min(sx2,sx1) /*r1 right edge less than r2 left edge*/\
and r1y + r1h >= min(sy2,sy1) /*r1 bottom edge is below the rop of r2*/\
and r1y <= max(sy1 ,sy2)/*r1 top edge is above r2 bottom*/

#!define collisionPointRect(rect1x,halfwidth,rect1y,height,pointx,pointy,radius) \
abs(rect1x - pointx) < (halfwidth + radius) /*left and right*/ \
and (pointy-radius<rect1y+height) and (pointy+radius > rect1y /*top and bottom*/)


rule "selection box":
    @Event eachPlayer
    @Condition (gameReady and eventPlayer.Ready)
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    eventPlayer.selectedOffset = false #set selected offset to false just in case. It should never be true here
    eventPlayer.selectionUIPos = [-eventPlayer.getHorizontalFacingAngle(),-eventPlayer.getVerticalFacingAngle(),-eventPlayer.getHorizontalFacingAngle(),-eventPlayer.getVerticalFacingAngle()]
    pTemp(UNDERCURSOR) =  [i * collisionPointRect(a.x,1.5,a.y,3,eventPlayer.selectionUIPos[0],eventPlayer.selectionUIPos[1],0.1) for a, i in eventPlayer.UIObj_UIPosition]
    pTemp(HIGHESTOBJ) = sorted(pTemp(UNDERCURSOR), lambda x: -x)[0]
    if(any(pTemp(UNDERCURSOR))):
        eventPlayer.selectedOffset = true #we are activating the selectedOffset to "move" all the selected objects
        if(not any([eventPlayer.UIObj_Selected[i] and x for x, i in pTemp(UNDERCURSOR)])): #if nothing under the cursor is selected, select whats under the cursor
            eventPlayer.UIObj_Selected = []
            eventPlayer.UIObj_Selected[pTemp(HIGHESTOBJ)] = true #this ensures that any overlapped objects are still selected and ready for dragging

    #!define 2dDistance(x1,y1,x2,y2) ((abs(x2 - x1))**2 + (abs(y2 - y1))**2)
    #drag detecting wait until
    waitUntil(2dDistance(eventPlayer.selectionUIPos[0],eventPlayer.selectionUIPos[1],-eventPlayer.getHorizontalFacingAngle(),-eventPlayer.getVerticalFacingAngle())>1 or not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE),100)
    #if true, drag. otherwise, use selection behavior
    if(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)): #the drag waituntil will fail into this, which should clean up everything
        eventPlayer.UIObj_Selected = []
        eventPlayer.UIObj_Selected[pTemp(HIGHESTOBJ)] = pTemp(UNDERCURSOR)[pTemp(HIGHESTOBJ)] and not eventPlayer.UIObj_Selected[pTemp(HIGHESTOBJ)]
        #uses a->b to determine toggle on click
        goto hide
    if(not eventPlayer.selectedOffset):
        eventPlayer.selectionUIPos[4] = true #this enabled the selection ui
    #runs the drag code, whether for moving objects or selecting
    while(eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)):
        eventPlayer.selectionUIPos[2] = -eventPlayer.getHorizontalFacingAngle()
        eventPlayer.selectionUIPos[3] = -eventPlayer.getVerticalFacingAngle()
        wait()
    if(eventPlayer.selectedOffset):
        eventPlayer.UIObj_UIPosition = [vect(a.x+(-eventPlayer.getHorizontalFacingAngle()-eventPlayer.selectionUIPos[0]),a.y+(-eventPlayer.getVerticalFacingAngle()-eventPlayer.selectionUIPos[1]),a.z) if eventPlayer.UIObj_Selected[i] else a for a, i in eventPlayer.UIObj_UIPosition]
    else:
        eventPlayer.UIObj_Selected = [selectionContain(i.x,1.5,i.y,3,eventPlayer.selectionUIPos[0],eventPlayer.selectionUIPos[1],eventPlayer.selectionUIPos[2],eventPlayer.selectionUIPos[3]) for i in eventPlayer.UIObj_UIPosition]
    hide:
        eventPlayer.selectedOffset = false #turn off selected offset after use
        eventPlayer.selectionUIPos = [-1000,-1000,-1000,-1000, false] #turns off selection ui too   
        



rule "ui grid":
    #createEffect(localPlayer,Effect.SPHERE,Color.AQUA,cursorPos,0.1,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    #wait(3)#needed while the eye location is based on player distance
    gameReady = true
    return #disables ui grid
    forGlobal(GENERATEOBJS,1,92):
        #!defineMember z ui_id 
        #Following with the pattern established with minions, one of the vector slots is the id
        #However, unlike minions, who only care about the x and z positions and use y as the id slot, the 2d nature of ui has us using z 
        UIObj_Generator[Iter[forG.GENERATEOBJS]] = vect(((Iter[forG.GENERATEOBJS]-1)%13-6)*10,(floor((Iter[forG.GENERATEOBJS]-1)/13)-3)*10,Iter[forG.GENERATEOBJS])
        ##!define objText "{}\n{},{}".format(evalOnce(Iter[forG.GENERATEOBJS]),localPlayer.UIObj_UIPosition[evalOnce(Iter[forG.GENERATEOBJS])].x,localPlayer.UIObj_UIPosition[evalOnce(Iter[forG.GENERATEOBJS])].y) if localPlayer.Debug else "\&black_square;"
        #UI pos has an offset (selectedOffset) which is only enabled during dragging, which allows the objects to be rendered "with" the cursor but without actually needing to be moved until dropped
        #!define objPos uiPos(localPlayer.UIObj_UIPosition[evalOnce(Iter[forG.GENERATEOBJS])].x + localPlayer.selectedOffset * localPlayer.UIObj_Selected[evalOnce(Iter[forG.GENERATEOBJS])] * (CURSORX-localPlayer.selectionUIPos[0]),localPlayer.UIObj_UIPosition[evalOnce(Iter[forG.GENERATEOBJS])].y + localPlayer.selectedOffset * localPlayer.UIObj_Selected[evalOnce(Iter[forG.GENERATEOBJS])] * (CURSORY-localPlayer.selectionUIPos[1]))
        #!define selectionCheck localPlayer.selectionUIPos[4] and selectionContain(localPlayer.UIObj_UIPosition[evalOnce(Iter[forG.GENERATEOBJS])].x,1.5,localPlayer.UIObj_UIPosition[evalOnce(Iter[forG.GENERATEOBJS])].y,3,localPlayer.selectionUIPos[0],localPlayer.selectionUIPos[1],localPlayer.selectionUIPos[2],localPlayer.selectionUIPos[3])
        createInWorldText(localPlayer,"\&black_square;",objPos,4,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR, rgb(57,182,204) if selectionCheck else rgb(56,106,165) if localPlayer.UIObj_Selected[evalOnce(Iter[forG.GENERATEOBJS])] else Color.GRAY,SpecVisibility.NEVER)
        wait()
        forEndG(GENERATEOBJS)
    gameReady = true
