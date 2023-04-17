globalvar  B
globalvar effectHolder
globalvar textHolder
rule "a":
    @Event playerJoined
    #!define SCALE2 10
    #!define right angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection())+90,verticalAngleOfDirection(localPlayer.getFacingDirection()))
    #!define up normalize(crossProduct(right,localPlayer.getFacingDirection()))
    #!define uiPlayerPos(xpos,ypos) updateEveryTick(localPlayer.getEyePosition()+SCALE2*(localPlayer.getFacingDirection())+(xpos)*right+ (ypos)*up) /*takes a position on the 2D screen, thus only x and y*/
    #!define vis(team) localPlayer if localPlayer != getPlayersInSlot(evalOnce(B),team) else null
    for B in range(len(effectHolder)):
        destroyEffect(effectHolder[B])
        destroyInWorldText(textHolder[B])
    #!define tow(team) vectorTowards(localPlayer,getPlayersInSlot(evalOnce(B),team))
    #!define for localPlayer.getFacingDirection()
    #!define td(team) 1/(dotProduct(for,tow(team)))**1
    #!define dzy(team) 
    #!define dzx(team) ((getPlayersInSlot(evalOnce(B),team).getPosition().x-localPlayer.getPosition().x)*10/zd(team))
    createInWorldText(localPlayer,"ok",uiPlayerPos(1,1),1,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_AND_STRING,Color.AQUA,SpecVisibility.DEFAULT)
    #!define theLoop(team,color)\
    for B in range(getNumberOfPlayers(team)):\
        createEffect(vis(team),Effect.SPHERE,color,updateEveryTick(getPlayersInSlot(evalOnce(B),team)), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)\
        effectHolder.append(getLastCreatedEntity())\
        createInWorldText(vis(team),distance(localPlayer,getPlayersInSlot(evalOnce(B),team))*(localPlayer.getFacingDirection()-directionTowards(localPlayer,getPlayersInSlot(evalOnce(B),team))),uiPlayerPos(dzx(team),dzy(team)),1,Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,color,SpecVisibility.NEVER)\
        textHolder.append(getLastCreatedText())
    theLoop(Team.1,Color.TEAM_1)
    theLoop(Team.2,Color.TEAM_2)