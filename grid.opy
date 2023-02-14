#!mainFile "main.opy"
/*global*/
#Grid
#GridStatic
#GridTemp
/*player*/
#GridPlayer

#Grid and GridStatic are arrays which contain arrays of object ids. The object ids correspond to 
#tile is the name for the given grid element
#!define GRID_ROW_LENGTH 2
#!define GRID_ORIGIN vect(0,0,0)
#!define TILE_W 35
#!define TILE_H 20
#!define SHOW_GRID true
#!define Tile(x,y) (y*GRID_ROW_LENGTH+x+2)

rule "UI Debug - Grid":
    @Condition SHOW_GRID
    Grid = [[1001],[1002],[1003],[1004]]
    print(updateEveryTick(arrToString7(localPlayer.playerGrid)))
    print(updateEveryTick(arrToString7(localPlayer.Temp[tempP.TILEAUTO_QUEUE]).replace("_","-")))
    #print(arrToString7(localPlayer.Render_StaticEffects))
    print((localPlayer.getPosition().x-(TILE_H/2)-GRID_ORIGIN.x)/TILE_W)
    forGlobal(GRID_RENDERER,0,len(Grid)):
        #!define tileCorner vect(floor(Iter[forG.GRID_RENDERER]/GRID_ROW_LENGTH)*TILE_H,0.05,Iter[forG.GRID_RENDERER]%GRID_ROW_LENGTH*TILE_W)+GRID_ORIGIN
        createInWorldText(localPlayer,"{},{}:{}".format(Iter[forG.GRID_RENDERER]%GRID_ROW_LENGTH,floor(Iter[forG.GRID_RENDERER]/GRID_ROW_LENGTH),Iter[forG.GRID_RENDERER]),tileCorner,1,Clip.NONE,WorldTextReeval.VISIBILITY,Color.WHITE,SpecVisibility.DEFAULT)
        createBeam(localPlayer,Beam.BAD,tileCorner,tileCorner+vect(TILE_H,0,0),Color.WHITE,EffectReeval.VISIBILITY)
        createBeam(localPlayer,Beam.BAD,tileCorner,tileCorner+vect(0,0,TILE_W),Color.WHITE,EffectReeval.VISIBILITY)
        #createBeam(localPlayer,Beam.BAD,tileCorner+vect(0,0,TILE_H),tileCorner+vect(TILE_W,0,TILE_H),Color.WHITE,EffectReeval.VISIBILITY)
        #createBeam(localPlayer,Beam.BAD,tileCorner+vect(TILE_W,0,0),tileCorsner+vect(TILE_W,0,TILE_H),Color.WHITE,EffectReeval.VISIBILITY)
        forEndG(GRID_RENDERER)
    
rule "Grid Auto Add/Remove":
    /*
    Every 16 ticks or when triggered manually by setting updateCamera to true, update the grid tiles that are shown to a given player
    First, all the grid tiles the player can see are captured and stored in an array
    That array is then stripped up duplicates, becoming an array of current tiles
    The already loaded tiles, or the cached tiles, are compared to the current tiles, 
    with the add tile function being called on all that are new and the remove tile function on all that are no longer active*/
    @Event eachPlayer
    #
    #
    #

    @Condition false 

    #
    #
    #
    @Condition eventPlayer.updateCamera or getTotalTimeElapsed()%0.512<0.016
    eventPlayer.updateCamera = false
    #rounds the given location to the nearest tile
    #!define getTileByPos(pos) /*Tile(round(*/((pos).x-(TILE_W/2)-GRID_ORIGIN.x)/TILE_W,/*),round(*/((pos).z-(TILE_H/2)-GRID_ORIGIN.z)/TILE_H/*))*/
    #add all four possible tiles to a temporary variable
    #!define TILEVISION_H TILE_H
    #!define TILEVISION_W TILE_W
    pTemp(TILEAUTO_QUEUE) = [getTileByPos(eventPlayer.getPosition()),getTileByPos(eventPlayer.getPosition()+vect(TILEVISION_W,0,0)),getTileByPos(eventPlayer.getPosition()-vect(TILEVISION_W,0,0)),getTileByPos(eventPlayer.getPosition()+vect(0,0,TILEVISION_H)),getTileByPos(eventPlayer.getPosition()-vect(0,0,TILEVISION_H))]
    #for each tile in the queue, add run the add tile function if it is not already added
    forPlayer(TILEAUTO,0,len(pTemp(TILEAUTO_QUEUE))):
        pTemp(TILEAUTO_ITER) = pTemp(TILEAUTO_QUEUE)[eventPlayer.Iter[forP.TILEAUTO]]
        if(not pTemp(TILEAUTO_ITER) in eventPlayer.playerGrid):
            if(pTemp(TILEAUTO_ITER) > 0 and pTemp(TILEAUTO_ITER) < len(Grid)):
                pTemp(TILEOPERATION_ADD) = pTemp(TILEAUTO_QUEUE)[eventPlayer.Iter[forP.TILEAUTO]]
                smallMessage(eventPlayer,"addingtile")
                eventPlayer.playerGrid.append(pTemp(TILEOPERATION_ADD))
                #AddTile()
        forEndP(TILEAUTO)
        
    #for each tile not in the queue, remove it from the current tile set, as its not in vision
    forPlayer(TILEAUTO,0,len(eventPlayer.playerGrid)):
        pTemp(TILEAUTO_ITER) = eventPlayer.playerGrid[eventPlayer.Iter[forP.TILEAUTO]]
        if(not pTemp(TILEAUTO_ITER) in pTemp(TILEAUTO_QUEUE)):
            pTemp(TILEOPERATION_REMOVE) = pTemp(TILEAUTO_ITER)
            RemoveTile()
        forEndP(TILEAUTO)

rule "Grid Debug":
    @Event eachPlayer
    @Condition SHOW_GRID 
    @Condition eventPlayer == hostPlayer
    print(pTemp(TILEOPERATION_ADD))



playervar TileAdd_GridArray
playervar TileAdd_RangeCounts
#input: pTemp(TILEOPERATION_ADD) [tile ids]
def AddTile():
    if(pTemp(TILEOPERATION_ADD)==-100): #if TILEOPERATION_ADD hasn't been updated but was called, return
        smallMessage(eventPlayer,"add tile needlessly called")
        return
    /* -- grid static -- */
    eventPlayer.TileAdd_GridArray = GridStatic[pTemp(TILEOPERATION_ADD)]
    eventPlayer.Iter[forP.TILEADD_RENDERRANGE_BOTTOM] = [len(eventPlayer.Render_Minions)-1,len(eventPlayer.Render_StaticTexts)-1,len(eventPlayer.Render_StaticEffects)-1,len(eventPlayer.Render_CustProjectiles)-1]
    forPlayer(TILEADD_TOADD,0,len(eventPlayer.TileAdd_GridArray)): #for each tile being added
        pTemp(TILEADD_GRIDDARRAY_OBJ) = eventPlayer.TileAdd_GridArray[eventPlayer.Iter[forP.TILEADD_TOADD]]
        if(pTemp(TILEADD_GRIDDARRAY_OBJ)[0]): #this means that the object is a map wall
    /*TODO: ADD WALL EFFECT CODE*/                    
        else: #this means the object is a structure or something else that has an id
            switch(floor(pTemp(TILEADD_GRIDDARRAY_OBJ)/1000)):
                case 2:
                    if(Structures_Active[Structures_IDs.index(pTemp(TILEADD_GRIDDARRAY_OBJ))]):
                        eventPlayer.Render_StaticEffects.append(pTemp(TILEADD_GRIDDARRAY_OBJ))
                        eventPlayer.Render_StaticTexts.append(pTemp(TILEADD_GRIDDARRAY_OBJ))
                        eventPlayer.TileAdd_RangeCounts[1] += 1
                        eventPlayer.TileAdd_RangeCounts[2] += 1
                    else:
                        goto removeStatic
                    break
                default:
                    goto removeStatic
            goto continueSLoop
            removeStatic:
                del eventPlayer.TileAdd_GridArray[eventPlayer.Iter[forP.TILEADD_TOADD]]
                eventPlayer.Iter[forP.TILEADD_TOADD] -= 1
        continueSLoop:
        forEndP(TILEADD_TOADD)
    eventPlayer.TilesTouched.append(eventPlayer.Iter[forP.TILEADD_TOADD])
    GridStatic[pTemp(TILEOPERATION_ADD)] = eventPlayer.TileAdd_GridArray
    /* -- grid -- */
    #stores the contents of grid so that any objects that are no longer valid can be removed from the grid
    eventPlayer.TileAdd_GridArray = Grid[pTemp(TILEOPERATION_ADD)]
    forPlayer(TILEADD_TOADD,0,len(eventPlayer.TileAdd_GridArray)): #for each tile being added
        pTemp(TILEADD_GRIDDARRAY_OBJ) = eventPlayer.TileAdd_GridArray[eventPlayer.Iter[forP.TILEADD_TOADD]]
        switch (floor(pTemp(TILEADD_GRIDDARRAY_OBJ)/1000)):
            case 1:
                if(not pTemp(TILEADD_GRIDDARRAY_OBJ) in Minions_IDs):
                    goto continueDLoop
                if(Minions_HP[Minions_IDs.index(pTemp(TILEADD_GRIDDARRAY_OBJ))]>0):
                    if(not Minions_Active[Minions_IDs.index(pTemp(TILEADD_GRIDDARRAY_OBJ))]):
                        /*TODO: Activate wave minion is in*/
                    eventPlayer.Render_Minions.append(pTemp(TILEADD_GRIDDARRAY_OBJ))
                    eventPlayer.TileAdd_RangeCounts[0] += 1
                else:
                    goto removeDynamic
                
            default:
                goto removeDynamic
        goto continueDLoop
        removeDynamic:
            del eventPlayer.TileAdd_GridArray[eventPlayer.Iter[forP.TILEADD_TOADD]]
            eventPlayer.Iter[forP.TILEADD_TOADD] -= 1 #remove by index moves the whole array down rather than leaving a gap
        continueDLoop:
        forEndP(TILEADD_TOADD)
    #replaces the contents of the grid index with the stored information
    #if all objects are still valid, nothing changes
    #otherwise, this removes inactive/dead minions, projectiles, etc from the given tile
    Grid[pTemp(TILEOPERATION_ADD)] = eventPlayer.TileAdd_GridArray
    # #!define newRenderRange(i) eventPlayer.Iter[forP.TILEADD_RENDERRANGE_BOTTOM][i],eventPlayer.Iter[forP.TILEADD_RENDERRANGE_BOTTOM][i]+eventPlayer.TileAdd_RangeCounts[i]
    # eventPlayer.TilesTouched_RenderRanges.append([pTemp(TILEOPERATION_ADD)[eventPlayer.Iter[forP.TILEADD_GRABFROMARRAY]],
    # newRenderRange(0), /*Minions*/
    # newRenderRange(1), /*StaticText*/
    # newRenderRange(2), /*StaticEffects*/
    # newRenderRange(3) /*Projectiles*/
    # ])
    eventPlayer.playerGrid.append(pTemp(TILEOPERATION_ADD))
    pTemp(TILEOPERATION_ADD) = -100 #it is impossible for this to be inputted by the intended addtile in auto

#input: eventPlayer.Iter[forP.TILEOPERATION_REMOVE] [tile ids]
def RemoveTile():
    @Name "RemoveTile"
    #WIP
    if(pTemp(TILEOPERATION_REMOVE)<1):
        return
    del eventPlayer.playerGrid[evalOnce(eventPlayer.playerGrid.index(pTemp(TILEOPERATION_REMOVE)))]


#input: pTemp(TILEOPERATION_OBJECT) (object id)
def AddToRender():
    switch(floor(pTemp(TILEOPERATION_OBJECT)/1000)):
        case 1:
            eventPlayer.Render_Minions.append(pTemp(TILEOPERATION_OBJECT))
            break
        case 3:
            eventPlayer.Render_CustProjectiles.append(pTemp(TILEOPERATION_OBJECT))
            break
#input: pTemp(TILEOPERATION_OBJECT) (object id)
def RemoveFromRender():
    #!define TileRender_RemoveFromArray(array) /**/\
        pTemp(RENDEROPERATION_OBJECTSWAP) = (array).index(pTemp(TILEOPERATION_OBJECT))\
        (array)[pTemp(RENDEROPERATION_OBJECTSWAP)] = 0\
        (array)[pTemp(RENDEROPERATION_OBJECTSWAP)] = (array)[len(array)-1]

    switch(floor(pTemp(TILEOPERATION_OBJECT)/1000)):
        case 1:
            TileRender_RemoveFromArray(eventPlayer.Render_Minions)
            break
        case 3:
            TileRender_RemoveFromArray(eventPlayer.Render_CustProjectiles)
            break
    
    

/*def UpdateTiles(): #updates all dynamic elements in the tile
    if(eventPlayer.isDummy() or getTotalTimeElapsed()%1!=0):
        return
    #
    eventPlayer.Render_Minions = []
    eventPlayer.Render_CustProjectiles = []
    forPlayer(RENDERUPDATE_TILES,0,len(eventPlayer.Iter[forP.TILEOPERATION_UPDATE])):
        eventPlayer.Iter[forP.RENDERUPDATE_ARRAY] = eventPlayer.Iter[forP.TILEOPERATION_UPDATE][eventPlayer.Iter[forP.RENDERUPDATE_TILES]] #stores the individual array from the grid for easier managing (and to prevent update issues)
        forPlayer(RENDERUPDATE_ELEMENT,0,len(eventPlayer.Iter[forP.RENDERUPDATE_ARRAY])):
                eventPlayer.Iter[forP.RENDERUPDATE_OBJECT] = eventPlayer.Iter[forP.RENDERUPDATE_ARRAY][eventPlayer.Iter[forP.RENDERUPDATE_ELEMENT]]
                switch(floor(eventPlayer.Iter[forP.RENDERUPDATE_OBJECT]/1000)):
                    case 1: #minions
                        eventPlayer.Render_Minions.append(eventPlayer.Iter[forP.RENDERUPDATE_OBJECT])
                        break
                    case 3: #projectiles
                        eventPlayer.Render_CustProjectiles.append(eventPlayer.Iter[forP.RENDERUPDATE_OBJECT])
                        break
                    case 4:
                        break
                    default:
                        break
            forEndP(RENDERUPDATE_ELEMENT)
        forEndP(RENDERUPDATE_TILES)*/
