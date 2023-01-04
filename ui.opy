#!mainFile "main.opy"

#This is used for any generic (non-hero specific) UI
#!define textPos(intended) (intended) + (vect(false, 0.8 - 0.075 * distance((intended), localPlayer), false))

rule "Mode":
    if(Setting_Mode==1): #Standalone
        hudSubtext(localPlayer if not localPlayer.Ready else null,"MOBAwatch: Standalone",HudPosition.TOP,0,Color.ORANGE,HudReeval.VISIBILITY)
    else:
        hudSubtext(localPlayer if not localPlayer.Ready else null,"MOBAwatch: Open",HudPosition.TOP,0,Color.VIOLET,HudReeval.VISIBILITY)

    
def UI_Setup():
    print(eventPlayer.Iter[forP.COOLDOWNS])
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
    forPlayer(forP.COOLDOWNS,eventPlayer,0,len(CD_Buttons)):
        if(not eventPlayer.AbilityVerify[2]==CD_Buttons[eventPlayer.Iter[forP.COOLDOWNS]]):
            updateCooldown(CD_Buttons[eventPlayer.Iter[forP.COOLDOWNS]])
            eventPlayer.setUltCharge(eventPlayer.ControlledRef.getUltCharge())
        else:
            if(eventPlayer.getAbilityCooldown(eventPlayer.AbilityVerify[2])<=1.1 and not eventPlayer.AbilityVerify[2]==Button.ULTIMATE):
                eventPlayer.setAbilityCooldown(CD_Buttons[eventPlayer.Iter[forP.COOLDOWNS]],1)
                smallMessage(eventPlayer,eventPlayer.getAbilityCooldown(CD_Buttons[eventPlayer.Iter[forP.COOLDOWNS]]))
            elif(eventPlayer.getUltCharge()>98.5 and eventPlayer.AbilityVerify[2]==Button.ULTIMATE):
                eventPlayer.setUltCharge(99.9)
        forEndP(forP.COOLDOWNS,eventPlayer)
    if(HeroSpecs[eventPlayer.ControlledRef.CHero_Index][HeroStat.BASE][Base.HEALTH]>1):
        eventPlayer.setMaxAmmo(0,eventPlayer.ControlledRef.Resource[1])
        eventPlayer.setAmmo(0,eventPlayer.ControlledRef.Resource[0])
    wait(0.1)
    top

rule "UI Definitions - Global Cursor":
    waitUntil(Ready==true,100)
    #>=(zpos-0.1)*0.016 and getTotalTimeElapsed()%(0.032*highestZpos)<=(zpos)*0.016
    #!define zPos(draw,zpos) null if zpos<getNumberOfTextIds() else (draw)
    #!define CamPos vect(-5,10,0)
    #!define EYE(player) updateEveryTick((player).CamLoc+vect(0,10,0) if mousetoggle else (player).ControlledRef.getEyePosition()*vect(1,0,1)+0.5*(player).ControlledRef.getVelocity()/magnitude((player).ControlledRef.getVelocity()))+CamPos+vect(((player).getEyePosition().y-(player).getPosition().y)/2,0,0)
    #!define CURSORX updateEveryTick(localPlayer.getHorizontalFacingAngle())
    #(localPlayer.cursorAngles[0].x)
    #!define CURSORZ updateEveryTick(localPlayer.getVerticalFacingAngle())
    #(localPlayer.cursorAngles[0].z+3)
    #!define vFOR vect(0.45,-0.89,0) /*Direction between camera EYE(localPlayer) and camera look point or look at direction*/
    #!define vLEFT vect(0,0,-1) /*angleToDirection(horizontalAngleOfDirection(vFOR)-90,verticalAngleOfDirection(vFOR))*/
    #!define vDOWN vect(-0.89,-0.45,0) /*crossProduct(vLEFT,vFOR)*/
    #!define SCALE 50 /*used for UI, defines screen size. Lowering this value changes your Y upper and lower limit and the wraparound distance for the X*/
    #!define uiPos(xpos,ypos) updateEveryTick(EYE(localPlayer)+SCALE*vFOR+(xpos)*vLEFT+ (ypos)*vDOWN) /*takes a position on the 2D screen, thus only x and y*/
    #!define textPos(pos) updateEveryTick((pos) + vDOWN * (dotProduct(vFOR, (pos) - EYE(localPlayer)) / 18)) /*text is anchored to its correct position*/
    #!define SCALE 50 /*used for UI, defines screen size. Lowering this value changes your Y upper and lower limit and the wraparound distance for the X*/
    #!define uiPos(xpos,ypos) updateEveryTick(EYE(localPlayer)+SCALE*vFOR+(xpos)*vLEFT+ (ypos)*vDOWN)
    createInWorldText(localPlayer, "•",uiPos(CURSORX,CURSORZ), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.NEVER)
    ScreenLimits = [1.25,0.68]
    #!define text(vis,text,pos,color) createInWorldText((vis), (text), textPos(pos) , (size), Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, (color), SpecVisibility.DEFAULT)
    #!define Vect(pos1,vect1) createBeam(localPlayer,Beam.GOOD,(pos1),(pos1)+(vect1),Color.AQUA,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createInWorldText(localPlayer,"¤",localPlayer.ControlledRef.MovetoPos-vect(1.25,0,0)+vect(0,100*(not localPlayer.MovementGroundCursor),0),2.0,Clip.SURFACES,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,rgb(238,148,148) if localPlayer.ControlledRef.AttackMove else Color.SKY_BLUE,SpecVisibility.NEVER)
    createEffect(localPlayer,Effect.SPHERE,Color.AQUA,localPlayer.ControlledRef.LookAtDir+localPlayer.ControlledRef,0.1,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createInWorldText(localPlayer, "•",uiPos(CURSORX,CURSORZ), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, localPlayer.UICursorStyles[0], SpecVisibility.NEVER)
    print("Hero Ability: [{},{},{}]".format(["NONE","PREP","MOVETO","CAST","COMPLETE"][localPlayer.ControlledRef.Hero_Ability[0]],localPlayer.ControlledRef.Hero_Ability[1],localPlayer.ControlledRef.Hero_Ability[2]))
    print("Ability Verify: [{},{},{},{}]".format(localPlayer.AbilityVerify[0],localPlayer.AbilityVerify[1],localPlayer.AbilityVerify[2],localPlayer.AbilityVerify[3]))
    print("Target: {},{},{}".format(localPlayer.ControlledRef.Target[0],localPlayer.ControlledRef.Target[1],localPlayer.ControlledRef.Target[2]))
    Vect(localPlayer.ControlledRef,localPlayer.ControlledRef.getFacingDirection())
    Vect(localPlayer.ControlledRef,localPlayer.ControlledRef.LookAtDir)
    #!define getPStatAbil(player,num) "{}{}{}{}".format("Abil #{}:\nCast Method: {}, Range: {},\nCost: {}, CD: {}".format((num),["Slf","Dir","Gnd","Cur","Tgt"][(player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.CASTMETHOD]],(player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.RANGE],(player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.COST],(player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.COOLDOWN]),\
        (", Charges: {}".format((player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.MAXCHARGES]) if (player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.MAXCHARGES]>0 else ""),\
        (", \nDmg: {}, Dmg Rate: {}/s".format((player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.DAMAGE],(player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.DAMAGERATE]) if (player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.DAMAGE]!= 0 else ""),\
        ", Dur: {} {}".format((player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.DURATION],(player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.ABILSPECIFICVAR] if (player).PlayerStats[PStat.ABIL+(num)-1][PStatAbil.ABILSPECIFICVAR]!=0 else ""))

    #!define getPStats(player) ("Stats:\n{} HP, {} Resource, {} Armor, {}x Damage Mult\n{}% Move Speed, Basic Atk Range: {},\nBasic Atk Damage: {}, {}% Atk Speed"\
        .format((player).PlayerStats[PStat.HEALTH],(player).PlayerStats[PStat.RESOURCE],(player).PlayerStats[PStat.ARMOR]*100,(player).PlayerStats[PStat.DEALMULT],(player).PlayerStats[PStat.MOVESPEED]*100,(player).PlayerStats[PStat.BASIC_RANGE],(player).PlayerStats[PStat.BASIC_DAMAGE],(player).PlayerStats[PStat.ATTACKSPEED]*100))
    hudHeader(localPlayer if localPlayer.showStats[0] else null,"{}\n{}\n{}\n{}\n{}".format(getPStats(localPlayer.showStats[1]),getPStatAbil(localPlayer.showStats[1],1),getPStatAbil(localPlayer.showStats[1],2),getPStatAbil(localPlayer.showStats[1],3),getPStatAbil(localPlayer.showStats[1],4)),HudPosition.RIGHT,99,Color.BLUE,HudReeval.VISIBILITY_SORT_ORDER_AND_STRING,SpecVisibility.DEFAULT)
    print(distance(localPlayer.getPosition()*vect(1,0,1),vect(2,0,1))/5)
    hudHeader(localPlayer if localPlayer.showStats[0] else null,"{}\n{}\n{}\n{}".format(arrToString10(localPlayer.ControlledRef.ActionQueue[ActionQueueVal.I0+1]),arrToString10(localPlayer.ControlledRef.ActionQueue[ActionQueueVal.I0+2]),arrToString10(localPlayer.ControlledRef.ActionQueue[ActionQueueVal.I0+3]),arrToString10(localPlayer.ControlledRef.ActionQueue[ActionQueueVal.I0+4])),HudPosition.TOP,0,Color.GRAY,HudReeval.VISIBILITY_AND_STRING,SpecVisibility.ALWAYS)
    print(arrToString10(localPlayer.ControlledRef.Action))
    print("A:{},{},{},{}".format(Projectile_Active[0],Projectile_Active[1],Projectile_Active[2],Projectile_Active[3]))
    print("P:{},{},{},{}".format(Projectile_Position[0],Projectile_Position[1],Projectile_Position[2],Projectile_Position[3]))

rule "Start Camera":  
    @Event eachPlayer
    @Condition Ready == true
    @Condition not eventPlayer.isDummy()
    eventPlayer.UICursorStyles = [Color.WHITE,true,Color.RED,0.10]
    eventPlayer.CamLoc = vect(0,-10,0)
    eventPlayer.startCamera(updateEveryTick(EYE(localPlayer)), updateEveryTick(EYE(localPlayer)+vFOR), 40)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.setStatusEffect(null,Status.PHASED_OUT,9999)
    eventPlayer.setDamageReceived(0)
    eventPlayer.startForcingPosition(updateEveryTick(vect(eventPlayer.CamLoc.x,-10,eventPlayer.CamLoc.z)),true)
    eventPlayer.ControlledRef.MovetoPos=vect(0,0,0)
    eventPlayer.CamAttach=true
    
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
    chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z),duration=0.2,ChaseReeval.DESTINATION_AND_DURATION)
    wait(0.3)
    moveCameraWithPlayer()
    wait(0.2)
    eventPlayer.CamAttach=true  
def moveCameraWithPlayer():
    if(eventPlayer.CamAttach):
        if(mousetoggle):
            #!define toCamLoc vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z)+eventPlayer.ControlledRef.getFacingDirection()*(min(0.5,eventPlayer.ControlledRef.getSpeedInDirection(eventPlayer.ControlledRef.getFacingDirection())) if distance(eventPlayer.ControlledRef.MovetoPos,eventPlayer.ControlledRef.getPosition())<1.35 else 1)
            chase(eventPlayer.CamLoc,toCamLoc,rate=1 if distance(eventPlayer.ControlledRef.MovetoPos,eventPlayer.ControlledRef.getPosition())<1.35 else 10,ChaseReeval.DESTINATION_AND_RATE)

    
rule "Camera Bounds":
    #!define Hori eventPlayer.getHorizontalFacingAngle()
    #!define Vert eventPlayer.getVerticalFacingAngle()
    #!define InHoriBounds abs(Hori)<ScreenLimits[0]*SCALE
    #!define InVertBounds abs(Vert)<ScreenLimits[1]*SCALE
    #!define BounceMargin 0.5
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    if(not mousetoggle):
        eventPlayer.CamLoc=eventPlayer.ControlledRef.getPosition()*vect(1,0,1)+vect(0,eventPlayer.CamLoc.y,0)
    if(eventPlayer.Settings[PlayerSettings.CAMERA_NUDGE]==1):
        eventPlayer.CamLoc+=Setting_CamSpeed*vect(-(abs(Vert)>(SCALE-1.5*BounceMargin)*ScreenLimits[1] and abs(Vert)<(SCALE+0.8*BounceMargin)*ScreenLimits[1])*eventPlayer.cursorAngles[0].z/abs(eventPlayer.cursorAngles[0].z)
        ,0,-(abs(Hori)>(SCALE-1.5*BounceMargin)*ScreenLimits[0] and abs(Hori)<(SCALE+0.5*BounceMargin)*ScreenLimits[0])*eventPlayer.cursorAngles[0].x/abs(eventPlayer.cursorAngles[0].x))
    if(InHoriBounds and InVertBounds):
        eventPlayer.cursorAngles[0]=vect(Hori,0,Vert) #Updates cursor
        if(Hori!=eventPlayer.cursorAngles[1].x): #Only updates In-screen position if one is valid
            eventPlayer.cursorAngles[2]=eventPlayer.cursorAngles[1]
            eventPlayer.cursorAngles[1]=eventPlayer.cursorAngles[0]
            #set last angle based on temp holding
        #negative height of EYE(localPlayer) over y component of cursor component times the cursor plus EYE position
        eventPlayer.cursor=(0-CamPos.y)/(vFOR.y+eventPlayer.cursorAngles[0].z/SCALE*vDOWN.y)*(vFOR+eventPlayer.cursorAngles[0].x/SCALE*vLEFT+eventPlayer.cursorAngles[0].z/SCALE*vDOWN)+EYE(eventPlayer)
    wait(0.032)
    top
rule "Prevent Cursor Wrapping":
    @Event eachPlayer
    @Condition eventPlayer.Ready
    @Condition not eventPlayer.isDummy()
    @Condition not InHoriBounds or not InVertBounds
    if(not InHoriBounds*1.25): #StartFacing is better handling larger movements, this if statement detects which one occured
        eventPlayer.startFacing(angleToDirection(
            Hori if InHoriBounds
            else angleDifference(eventPlayer.cursorAngles[2].x,eventPlayer.cursorAngles[1].x)/abs(angleDifference(eventPlayer.cursorAngles[2].x,eventPlayer.cursorAngles[1].x))
            *(SCALE-BounceMargin)*ScreenLimits[0]
            ,Vert
            ),1000000,Relativity.TO_WORLD,FacingReeval.NONE)
        wait(0.080)
        waitUntil(InHoriBounds and InVertBounds,1000)
        eventPlayer.stopFacing()
    else:
        eventPlayer.setFacing(angleToDirection(clamp(Hori,0-(SCALE-BounceMargin)*ScreenLimits[0],(SCALE-BounceMargin)*ScreenLimits[0]),clamp(Vert,0-(SCALE-BounceMargin)*ScreenLimits[1],(SCALE-BounceMargin)*ScreenLimits[1])),Relativity.TO_WORLD)
    eventPlayer.cursorAngles[0]=vect(Hori,0,Vert)