#!mainFile "main.opy"

#This is used for any generic (non-hero specific) UI


rule "Mode":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    if(Setting_Mode==1): #Standalone
        hudSubtext(getAllPlayers(),"MOBAwatch: Standalone",HudPosition.TOP,0,Color.ORANGE,HudReeval.VISIBILITY)
    else:
        hudSubtext(getAllPlayers(),"MOBAwatch: Open",HudPosition.TOP,0,Color.VIOLET,HudReeval.VISIBILITY)

    eventPlayer.Temp_DistanceSort = getLastCreatedText()
    wait(15)
    destroyHudText(eventPlayer.Temp_DistanceSort)
    
def UI_Setup():

    eventPlayer.setMaxAmmo(0,0)
    eventPlayer.setMaxAmmo(1,0)
    eventPlayer.setAmmo(0,0)
    eventPlayer.setAmmo(1,0)
    eventPlayer.addHealthPool(Health.NORMAL,(eventPlayer.ControlledRef.Health[0])+eventPlayer.ControlledRef.Health[2][0]*(eventPlayer.ControlledRef.Health[2][0]<0)-2,true,true)
    eventPlayer.addHealthPool(Health.ARMOR,0-eventPlayer.ControlledRef.Health[2][0] if eventPlayer.ControlledRef.Health[2][0]<0 else 1,true,true)
    eventPlayer.addHealthPool(Health.SHIELDS,eventPlayer.ControlledRef.Health[2][0] if eventPlayer.ControlledRef.Health[2][0]>0 else 1,true,true)
    CD_Buttons=[Button.ABILITY_1,Button.ABILITY_2,Button.JUMP,Button.CROUCH,Button.SECONDARY_FIRE]
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableGamemodeHud()
    print("{}, {}, {}".format(min(5,20*max(0,eventPlayer.ControlledRef.Health[3])),20*max(0,eventPlayer.ControlledRef.Health[3]),eventPlayer.ControlledRef.Health[3]))
    createInWorldText(eventPlayer if eventPlayer.ControlledRef.isAlive() else null,"{}\n|{}|{}|{}|{}|".format("         <•>" if not eventPlayer.ControlledRef.Hidden else "",
    "{0}{1}".format(__substring__("IIIII",0,min(5,20*max(0,eventPlayer.ControlledRef.Health[3]))),__substring__(".....",min(5,20*max(0,eventPlayer.ControlledRef.Health[3])),4)),
    "{0}{1}".format(__substring__("IIIII",0,min(5,20*max(0,eventPlayer.ControlledRef.Health[3]-0.25))),__substring__(".....",min(5,20*max(0,eventPlayer.ControlledRef.Health[3]-0.25)),4)),
    "{0}{1}".format(__substring__("IIIII",0,min(5,20*max(0,eventPlayer.ControlledRef.Health[3]-0.5))),__substring__(".....",min(5,20*max(0,eventPlayer.ControlledRef.Health[3]-0.5)),4)),
    "{0}{1}".format(__substring__("IIIII",0,min(5,20*max(0,eventPlayer.ControlledRef.Health[3]-0.75))),__substring__(".....",min(5,20*max(0,eventPlayer.ControlledRef.Health[3]-0.75)),4))
    ),updateEveryTick(vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.ControlledRef.getEyePosition().y+0.0,eventPlayer.ControlledRef.getEyePosition().z+0.2)),1.5,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.GREEN if(localPlayer==eventPlayer) else Color.TEAM_1 ,SpecVisibility.NEVER)
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
            

#!define updateCooldown(button) eventPlayer.setAbilityCooldown(button,eventPlayer.ControlledRef.getAbilityCooldown(button))\
    eventPlayer.setAbilityCharge(button,eventPlayer.ControlledRef.getAbilityCharge(button))\
    eventPlayer.setAbilityResource(button,eventPlayer.ControlledRef.getAbilityResource(button))
def UI_Process():
    @Name "S_UI_Process"
    #eventPlayer.setHealth(
        
    eventPlayer.setMaxHealth(40)
    print(evalOnce(100*(eventPlayer.ControlledRef.Health[1])/eventPlayer.getMaxHealth()))
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
    eventPlayer.ControlledRef.Health[3]=eventPlayer.ControlledRef.Health[0]/eventPlayer.ControlledRef.Health[1] #sets normalized health
    wait(0.1)
    top



rule "Cursor": 
    @Event eachPlayer
    @Condition Ready == true
    @Condition not eventPlayer.isDummy()

    #createInWorldText(eventPlayer,"{0}".format(eventPlayer.cursor),eventPlayer.cursor,1.0,Clip.SURFACES,WorldTextReeval.VISIBILITY_AND_POSITION,Color.RED,SpecVisibility.NEVER)
    eventPlayer.UICursorStyles = [Color.WHITE,true,Color.RED,0.10]
    createInWorldText(eventPlayer,"•",updateEveryTick(vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z-eventPlayer.CamLoc.y/12.5)),2.5,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,eventPlayer.UICursorStyles[0],SpecVisibility.NEVER)
    createInWorldText(eventPlayer if eventPlayer.MovementGroundCursor else null,"¤",vect(eventPlayer.ControlledRef.MovetoPos.x,0,eventPlayer.ControlledRef.MovetoPos.z-eventPlayer.CamLoc.y/12.5),2.0,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,Color.SKY_BLUE,SpecVisibility.NEVER)
    #createInWorldText(eventPlayer,"•",vect(1.349*(9.75)*(eventPlayer.eyeAxis[0])+eventPlayer.CamLoc.x,0,0.775*(9.75)*(eventPlayer.eyeAxis[1]+0.25)+eventPlayer.CamLoc.z-1.25),2.5,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,eventPlayer.UICursorStyles[0],SpecVisibility.NEVER)
    #raycast(eventPlayer.CamLoc,vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z),getAllPlayers(),null,true).getHitPosition().y
    #createEffect(eventPlayer,Effect.SPHERE,eventPlayer.UICursorStyles[2],vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z),eventPlayer.UICursorStyles[3],EffectReeval.POSITION_AND_RADIUS)

rule "CursorStyle1":
    @Event eachPlayer
    @Condition Ready == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition not eventPlayer.isDummy()
    @Condition distance(vect(eventPlayer.ControlledRef.getPosition().x,0,eventPlayer.ControlledRef.getPosition().z),vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z))>1
    if(eventPlayer.ControlledRef.ArrivedAtM2P==1):
        eventPlayer.ControlledRef.ArrivedAtM2P=0
        eventPlayer.ControlledRef.MoveAbilityCancel=true
    eventPlayer.ControlledRef.MovetoPos = vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z)
    startAction(0,eventPlayer.ControlledRef)
    eventPlayer.MovementGroundCursor = true
    wait(0.5)
    while(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)):
        eventPlayer.MovementGroundCursor = false
        eventPlayer.ControlledRef.MovetoPos = vect(eventPlayer.cursor.x,0,eventPlayer.cursor.z)
        startAction(0,eventPlayer.ControlledRef)
        wait(0.3)
    #smallMessage(eventPlayer,"{0}_".format(eventPlayer.MovementGroundCursor))

rule "Print":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy() and eventPlayer.isHoldingButton(Button.CROUCH)
    #PrintMinions()

rule "Toggle CamAttach":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy() and eventPlayer.isHoldingButton(Button.JUMP)
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
        chase(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z),rate=eventPlayer.ControlledRef.getSpeed(),ChaseReeval.DESTINATION_AND_RATE)
def CameraSetup():
    @Name "S_CameraSetup"
    eventPlayer.CamLoc = vect(0,15,0)
    eventPlayer.setFacing(vect(0,0,0),Relativity.TO_WORLD) #15,-4
    eventPlayer.startCamera(vect(eventPlayer.CamLoc.x,eventPlayer.CamLoc.y,eventPlayer.CamLoc.z-0.01), vect(eventPlayer.CamLoc.x, 0, eventPlayer.CamLoc.z), 35)
    eventPlayer.ControlledRef.MovetoPos=vect(0,0,0)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.setStatusEffect(null,Status.PHASED_OUT,9999)
    eventPlayer.setDamageReceived(0)

rule "Camera Bounds":
    #!define Hori atan2(eventPlayer.getFacingDirection().x,eventPlayer.getFacingDirection().z)
    #!define Vert asin(eventPlayer.getFacingDirection().y)
    #!define HoriLimit ((ScreenLimits[0])+eventPlayer.eyeAxis[1]*0.1*eventPlayer.eyeAxis[1]/abs(eventPlayer.eyeAxis[1]))
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
    #if(distance(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z))>1 and eventPlayer.CamAttach):
    #    eventPlayer.CamLoc+=0.1*directionTowards(eventPlayer.CamLoc,vect(eventPlayer.ControlledRef.getEyePosition().x,eventPlayer.CamLoc.y,eventPlayer.ControlledRef.getEyePosition().z))
    top


def chaseCursorValues():    
    if(HoriBounds and VertBounds):
        eventPlayer.cursor=eventPlayer.cursorNew
    wait()
    top