#!mainFile "../../projTest.opy"
rule "Projectile Tick":
    @Condition len(ProjectileActive)>0
    tickCt++
    for PTempTick in range(1,len(ProjectileActive)):
        if(ProjectileActive[PTempTick] == 0):
            continue
        if(Projectile_Lifetime[ProjectileActive[PTempTick]]<=getTotalTimeElapsed()):
            ProjectilePool.append(ProjectileActive[PTempTick])
            PInfo[PInfoEnum.ID]=ProjectileActive[PTempTick]
            del ProjectileActive[PTempTick]
            PTempTick--
            ReleaseToProjPool()
        if(Projectile_Velocity[ProjectileActive[PTempTick]].y!=0):
            Projectile_Velocity[ProjectileActive[PTempTick]]+=vect(0,Projectile_Const[ProjectileActive[PTempTick]][PConst_Enum.GRAVITY],0)*TICK_LENGTH
        Projectile_Position[ProjectileActive[PTempTick]] += Projectile_Velocity[ProjectileActive[PTempTick]]*TICK_LENGTH
        PInfo[PInfoEnum.NEXTPOS] = Projectile_Position[ProjectileActive[PTempTick]]+Projectile_Velocity[ProjectileActive[PTempTick]]
        for PTempGrid in range(len(Projectile_Grid[ProjectileActive[PTempTick]])):
            for PTempCollision in range(Grid[Projectile_Grid[ProjectileActive[PTempTick]][PTempGrid]]):
                
            
    wait(TICK_LENGTH,Wait.ABORT_WHEN_FALSE)
    if(RULE_CONDITION):
        goto RULE_START
rule "Projectiles Make":
    if(PROJECTILE_POOLSIZE>150):
        print("Error: Too many projectiles") #This is way way too many
        return
    for PTempTick in range(1,PROJECTILE_POOLSIZE+1):
        ProjectilePool.append(PTempTick) #0 is skipped
        Projectile_IDs[PTempTick] = PTempTick+5000
        #!define projPos (Projectile_Position[evalOnce(PTempTick)]+Projectile_Velocity[evalOnce(PTempTick)]*(getTotalTimeElapsed()%TICK_LENGTH))
        createEffect(localPlayer if evalOnce(PTempTick) in ProjectileActive else null,Effect.SPHERE,Color.WHITE,projPos,Projectile_Const[evalOnce(PTempTick)][PConst_Enum.SIZE],EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createInWorldText(localPlayer if evalOnce(PTempTick) in ProjectileActive else null,evalOnce(PTempTick),projPos,1,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,Color.WHITE,SpecVisibility.DEFAULT)
        PInfo[PInfoEnum.ID]=PTempTick
        createBeam(localPlayer if evalOnce(PTempTick) in ProjectileActive else null,Beam.GRAPPLE,localPlayer.getPosition(),Projectile_Position[evalOnce(PTempTick)],Color.WHITE,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        ReleaseToProjPool()
        
rule "Make proj":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    enableInspector()
    PInfo[PInfoEnum.TYPE] = Projectile.PULSEBOMB
    wait(PInfo[PInfoEnum.TYPE][PConst_Enum.CAST_TIME])
    ProjectileActive.append(ProjectilePool[1])
    Projectile_Position[ProjectilePool[1]] = eventPlayer.getEyePosition()
    Projectile_Const[ProjectilePool[1]] = PInfo[PInfoEnum.TYPE]
    Projectile_Velocity[ProjectilePool[1]] = normalize(eventPlayer.getFacingDirection()+Vector.UP*PInfo[PInfoEnum.TYPE][PConst_Enum.DELTA])*PInfo[PInfoEnum.TYPE][PConst_Enum.V0]
    Projectile_Lifetime[ProjectilePool[1]] = getTotalTimeElapsed()+5
    del ProjectilePool[1]
    disableInspector()
    eventPlayer.setUltCharge(100)

rule "switch":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    waitUntil(PInfo[PInfoEnum.THREADACTIVE]==false,0.5)
    if(PInfo[PInfoEnum.THREADACTIVE]):
        return
    PInfo[PInfoEnum.THREADACTIVE] = true
    for(PTempThread in range(len(ProjectileActive))):
        Projectile_Velocity[ProjectileActive[PTempThread]] *= -1
    PInfo[PInfoEnum.THREADACTIVE] = false

def ReleaseToProjPool():
    Projectile_Position[PInfo[PInfoEnum.ID]] = vect(0,-10,0)
    Projectile_Velocity[PInfo[PInfoEnum.ID]] = vect(0,0,0)
    Projectile_Lifetime[PInfo[PInfoEnum.ID]] = 0
