#!mainFile "main.opy"

#This is used for any generic (non-hero specific) UI
#!define textPos(intended) (intended) + (vect(false, 0.8 - 0.075 * distance((intended), localPlayer), false))

rule "Mode":
    if(Setting_Mode==1): #Standalone
        hudSubtext(localPlayer if not localPlayer.Ready else null,"MOBAwatch: Standalone",HudPosition.TOP,0,Color.ORANGE,HudReeval.VISIBILITY)
    else:
        hudSubtext(localPlayer if not localPlayer.Ready else null,"MOBAwatch: Open",HudPosition.TOP,0,Color.VIOLET,HudReeval.VISIBILITY)

    
def UI_Setup():

    eventPlayer.setMaxAmmo(0,0)
    eventPlayer.setMaxAmmo(1,0)
    eventPlayer.setAmmo(0,0)
    eventPlayer.setAmmo(1,0)
    eventPlayer.setHealth(3)
    eventPlayer.setMaxHealth(3*(100/HeroSpecs[eventPlayer.ControlledRef.CHero_Index][0][0]))
    #eventPlayer.ControlledRef.Hidden=true
    eventPlayer.addHealthPool(Health.ARMOR,max(0,min(eventPlayer.ControlledRef.Health[1]-4,(abs(eventPlayer.ControlledRef.Health[2][0]) if eventPlayer.ControlledRef.Health[2][0]<0 else 1)+(eventPlayer.ControlledRef.Health[1]-eventPlayer.ControlledRef.Health[0]))),true,true)
    eventPlayer.addHealthPool(Health.NORMAL,max(0,-3+eventPlayer.ControlledRef.Health[0]-(abs(eventPlayer.ControlledRef.Health[2][0]) if eventPlayer.ControlledRef.Health[2][0]<0 else 1)),true,true)
    CD_Buttons=[Button.ABILITY_1,Button.ABILITY_2,Button.JUMP,Button.CROUCH,Button.SECONDARY_FIRE]
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableGamemodeHud()
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.RELOAD)
    eventPlayer.disallowButton(Button.MELEE)
    eventPlayer.disallowButton(Button.JUMP)

        
#!define updateCooldown(button) eventPlayer.setAbilityCooldown(button,eventPlayer.ControlledRef.getAbilityCooldown(button))\
    eventPlayer.setAbilityCharge(button,eventPlayer.ControlledRef.getAbilityCharge(button))\
    eventPlayer.setAbilityResource(button,eventPlayer.ControlledRef.getAbilityResource(button))

def UI_Process():
    @Name "S_UI_Process"
    if(eventPlayer.ControlledRef.isAlive()):
        eventPlayer.setHealth(eventPlayer.ControlledRef.Health[0])
    elif(eventPlayer.ControlledRef):
        wait(1)
        eventPlayer.setHealth(999)
    for eventPlayer.CD_i in range(len(CD_Buttons)):
        if(not eventPlayer.AbilityVerify[2]==CD_Buttons[eventPlayer.CD_i]):
            updateCooldown(CD_Buttons[eventPlayer.CD_i])
            eventPlayer.setUltCharge(eventPlayer.ControlledRef.getUltCharge())
        else:
            if(eventPlayer.getAbilityCooldown(eventPlayer.AbilityVerify[2])<=1.1 and not eventPlayer.AbilityVerify[2]==Button.ULTIMATE):
                eventPlayer.setAbilityCooldown(CD_Buttons[eventPlayer.CD_i],1)
            elif(eventPlayer.getUltCharge()>98.5 and eventPlayer.AbilityVerify[2]==Button.ULTIMATE):
                eventPlayer.setUltCharge(99.9)
    if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][0][1]>1):
        eventPlayer.setMaxAmmo(0,eventPlayer.ControlledRef.Mana[1])
        eventPlayer.setAmmo(0,eventPlayer.ControlledRef.Mana[1])
    wait(0.1)
    top

rule "UI Definitions - Global Cursor":
    #!define EYE localPlayer.getPosition()+vect(-7.5,10+localPlayer.CamLoc.y,0)
    #!define LOOK localPlayer.getPosition()+vect(0,10,0)
    #!define CURSORX (localPlayer.cursorAngles[0].x)
    #!define CURSORZ (localPlayer.cursorAngles[0].z+3)
    #!define SCALE 50
    #!define DIR vect(0.68,-0.74,0)
    #directionTowards(eventPlayer.getPosition()+vect(-11,10+eventPlayer.CamLoc.y,0), eventPlayer.getPosition()+vect(0,10,0))
    #!define XSCALE vect(0,0,-1)
    #-crossProduct(DIR, angleToDirection(horizontalAngleOfDirection(DIR), verticalAngleOfDirection(DIR) - 90))
    #!define ZSCALE (vect(-0.88,-0.48,0))
    #-angleToDirection(horizontalAngleOfDirection(DIR), verticalAngleOfDirection(DIR) - 90)
    
    #!define uiPos(xpos,ypos) updateEveryTick(EYE+(xpos)/SCALE*XSCALE+DIR + (ypos)/SCALE*ZSCALE)
    createInWorldText(getAllPlayers(), "•", uiPos(CURSORX,CURSORZ), 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, localPlayer.UICursorStyles[0], SpecVisibility.NEVER)
    createInWorldText(localPlayer if localPlayer.MovementGroundCursor else null,"¤",vect(localPlayer.ControlledRef.MovetoPos.x,0,localPlayer.ControlledRef.MovetoPos.z-localPlayer.CamLoc.y/12.5),2.0,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,Color.SKY_BLUE,SpecVisibility.NEVER)
    createEffect(localPlayer,Effect.SPHERE,Color.WHITE,localPlayer.cursor,0.8,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(localPlayer,Beam.BRIGITTE_FLAIL_CHAIN,uiPos(ScreenLimits[0],ScreenLimits[1]),uiPos(ScreenLimits[0],-ScreenLimits[1]),Color.WHITE,EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
rule "Start Camera": 
    @Event eachPlayer
    @Condition Ready == true
    @Condition not eventPlayer.isDummy()
    eventPlayer.UICursorStyles = [Color.WHITE,true,Color.RED,0.10]
    eventPlayer.CamLoc = vect(0,12,0)
    eventPlayer.startCamera(EYE, LOOK, 35)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.setStatusEffect(null,Status.PHASED_OUT,9999)
    eventPlayer.setDamageReceived(0)
    eventPlayer.startForcingPosition(vect(eventPlayer.CamLoc.x,-10,eventPlayer.CamLoc.z),true)
    eventPlayer.ControlledRef.MovetoPos=vect(0,0,0)


rule "Print":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy() and eventPlayer.isHoldingButton(Button.INTERACT)
    #PrintMinions()
    print("1{}2{}3{}".format(directionTowards(eventPlayer.getPosition()+vect(-11,10+eventPlayer.CamLoc.y,0), eventPlayer.getPosition()+vect(0,10,0)),-crossProduct(DIR, angleToDirection(horizontalAngleOfDirection(DIR), verticalAngleOfDirection(DIR) - 90)),-angleToDirection(horizontalAngleOfDirection(DIR), verticalAngleOfDirection(DIR) - 90)))

rule "Toggle CamAttach":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.JUMP)
    wait(0.05)
    if(eventPlayer.isHoldingButton(Button.JUMP)):
        wait(0.3)
        if(eventPlayer.isHoldingButton(Button.JUMP)):
            if(eventPlayer.CamAttach): #hold down space to unlock camera
                smallMessage(eventPlayer,"Camera unlocked")
                eventPlayer.CamAttach=false
                stopChasingVariable(eventPlayer.CamLoc)
        else: #jump to character
            goto camtach
    else:
        goto camtach
    return
    camtach:
    eventPlayer.CamAttach=true    
    chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z),duration=0.2,ChaseReeval.DESTINATION_AND_DURATION)
    wait(0.3)
    chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.MovetoPos.x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.MovetoPos.z),rate=eventPlayer.ControlledRef.getSpeed(),ChaseReeval.DESTINATION_AND_RATE)        
    
def moveCameraWithPlayer():
    if(eventPlayer.CamAttach):
        #chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z),rate=eventPlayer.ControlledRef.getSpeed(),ChaseReeval.DESTINATION_AND_RATE)

    
rule "Camera Bounds":
    #!define Hori eventPlayer.getHorizontalFacingAngle()
    #!define Vert eventPlayer.getVerticalFacingAngle()
    #!define InHoriBounds abs(Hori)<ScreenLimits[0]*SCALE
    #!define InVertBounds abs(Vert)<ScreenLimits[1]*SCALE
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    if(InHoriBounds and InVertBounds):
        eventPlayer.cursorAngles[0]=vect(Hori,0,Vert) #Updates cursor
        if(Hori!=eventPlayer.cursorAngles[1].x): #Only updates In-screen position if one is valid
            eventPlayer.cursorAngles[2]=eventPlayer.cursorAngles[1]
            eventPlayer.cursorAngles[1]=eventPlayer.cursorAngles[0]
            #set last angle based on temp holding
        #negative height of EYE over y component of cursor component times the cursor plus EYE position
        eventPlayer.cursor=(0-eventPlayer.CamLoc.y)/(DIR.y+eventPlayer.cursorAngles[0].z/SCALE*ZSCALE.y)*(DIR+eventPlayer.cursorAngles[0].x/SCALE*XSCALE+eventPlayer.cursorAngles[0].z/SCALE*ZSCALE)+eventPlayer.getPosition()+vect(-11,10+eventPlayer.CamLoc.y,0)
    wait(0.032)
    top
rule "Prevent Cursor Wrapping":
    @Event eachPlayer
    @Condition not InHoriBounds or not InVertBounds
    #!define BounceMargin 0.35
    if(not InHoriBounds*1.1): #StartFacing is better handling larger movements, this if statement detects which one occured
        eventPlayer.startFacing(angleToDirection(
            Hori if InHoriBounds
            else angleDifference(eventPlayer.cursorAngles[2].x,eventPlayer.cursorAngles[1].x)/abs(angleDifference(eventPlayer.cursorAngles[2].x,eventPlayer.cursorAngles[1].x))
            *(SCALE-BounceMargin)*ScreenLimits[0]
            , clamp(Vert,0-(SCALE-BounceMargin)*ScreenLimits[1],(SCALE-BounceMargin)*ScreenLimits[1])
            ),1000000,Relativity.TO_WORLD,FacingReeval.NONE)
        wait(0.080)
        waitUntil(InHoriBounds and InVertBounds,1000)
        eventPlayer.stopFacing()
    else:
        eventPlayer.setFacing(angleToDirection(clamp(Hori,0-(SCALE-BounceMargin)*ScreenLimits[0],(SCALE-BounceMargin)*ScreenLimits[0]),clamp(Vert,0-(SCALE-BounceMargin)*ScreenLimits[1],(SCALE-BounceMargin)*ScreenLimits[1])),Relativity.TO_WORLD)
    eventPlayer.cursorAngles[0]=vect(Hori,0,Vert)