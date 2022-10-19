#!mainFile "main.opy"
#!define println(a)  wait(0.1)\
enableInspector()\
printLog(a)\
disableInspector()


#!defineMember ln(a) (100*((a)**0.01)-100)
#!define MinionPositionLane1n3(t,j) (((t)/8)+(3-j-1)*50*sqrt(ln(1-abs((t)-100)/138.75)/1.3635+(0.967**2))-2) 
#MOBA Map, Desmos
#!define MinionPositionLane2(t) (((t)/8)*(4 < (t) and (t) < 16))
#!define M_id(i,k_) 10+(i+1)+k_/100
#!define ft(a,i) (((a)+0.02)*(1-i)+(i)*(19.98-(a)))
#!define MinionLimit(a) a*0+(1-a)*20
#!define slot(id) Minions_IDs.index(id)

def Minions_Move():
    forGlobal(forG.MINIONSMOVE,0,len(Minions_DLoc)):
        Iter[forG.MINIONSMOVEFLOOR]=floor(Minions_DLoc[Iter[forG.MINIONSMOVE]].x * 1000) % 100
        if (Minions_Loc[Iter[forG.MINIONSMOVEFLOOR]].y!=Minions_DLoc[Iter[forG.MINIONSMOVE]].y):
            Iter[forG.MINIONSMOVEFLOOR]=Minions_Loc.index([elem for elem in Minions_Loc if elem.y==Minions_DLoc[Iter[forG.MINIONSMOVE]].y][0])
        Minions_Loc[Iter[forG.MINIONSMOVEFLOOR]]=Minions_Loc[Iter[forG.MINIONSMOVEFLOOR]]+Minions_DLoc[Iter[forG.MINIONSMOVE]]*vect(1,0,1) #don't want to add the id twice, so we add 0
        forEndG(forG.MINIONSMOVE)
    wait(0.1)
# def Minions_Main():
#     LocTemp_var=getTotalTimeElapsed()*100
#     waitUntil(ThreadClear==true,100)
#     ThreadClear=false
#     for i in range(0,2):
#         for j in range(0,MinionHalfCount):
#             Minions_Loc[i*MinionHalfCount+j]=Minions_Loc[i*MinionHalfCount+j]+Minions_DLoc[i*MinionHalfCount+j]
#            # Minions_DLoc recalculate
#     ThreadClear=true
    
def Minions_Wave():
        waitUntil(ThreadClear==true,100)
        ThreadClear=false
        MinionWaves[0]++
        if(MinionPool!=[0] and len(MinionPool)):
            forGlobal(forG.MINION_WAVEITER_TEAM,0,2):
                forGlobal(forG.MINION_WAVEITER_TYPE,(1-Iter[forG.MINION_WAVEITER_TEAM]),MinionsPerWave+(MinionWaves[0]>15 and MinionWaves[0]%3==0)+1): #3 waves per side, 6 each, adds one if wave is late in game
                    MinionCounts[Iter[forG.MINION_WAVEITER_TEAM]]=(MinionCounts[Iter[forG.MINION_WAVEITER_TEAM]]+1)%100 #causes wraparound
                    Temp_Slot=MinionPool[0]   #grabs minion slot before removing it
                    del MinionPool[0] #removes it from pool
                    Temp_ID = MinionCounts[Iter[forG.MINION_WAVEITER_TEAM]]+Iter[forG.MINION_WAVEITER_TEAM]*100+1000
                    Minions_Info[Temp_Slot] = [Iter[forG.MINION_WAVEITER_TEAM],0 if Iter[forG.MINION_WAVEITER_TYPE]<6 else 1 if Iter[forG.MINION_WAVEITER_TYPE]==6 else 2 if Iter[forG.MINION_WAVEITER_TYPE]==7 else 3 if Iter[forG.MINION_WAVEITER_TYPE]==8 else -1,MinionWaves[0],MinionCounts[Iter[forG.MINION_WAVEITER_TEAM]]]
                    Minions_Visibility[Temp_Slot]=1
                    Minions_HP[Temp_Slot] = MinionClass_BaseHP[Minions_Info[evalOnce(Temp_Slot)][1]]
                    Minions_IDs[Temp_Slot] = Temp_ID
                    #Minions info is set after the text and entity are created
                    Minions_DLoc[Temp_Slot] = vect(1,Temp_ID,1)
                    Minions_Loc[Temp_Slot] = vect(0,Temp_ID,0)        
                    wait(0.25)
                    forEndG(forG.MINION_WAVEITER_TYPE)
                forEndG(forG.MINION_WAVEITER_TEAM)
        PrintText_Temp=""
        forGlobal(forG.MINIONS_PRINTPOOL,0,len(MinionPool)):
            PrintText_Temp="{},{}".format(PrintText_Temp,MinionPool[Iter[forG.MINIONS_PRINTPOOL]])
            forEndG(forG.MINIONS_PRINTPOOL)
        ThreadClear=true
def Minions_Init():
    waitUntil(ThreadClear==true,100)
    ThreadClear=false
    #MWeapons = [["ο","ơ","δ","σ"],["Y","ϒ", "ϔ", "Ẏ"]]
    forGlobal(forG.MINIONSINIT_TEAM,0,2): 
    #!define MinionHalf 4
        forGlobal(forG.MINIONSINIT_SLOT,(1-Iter[forG.MINIONSINIT_TEAM]),MinionHalf+(1-Iter[forG.MINIONSINIT_TEAM])): #sk_ips 0, which is potentially problematic
            Temp_Slot = Iter[forG.MINIONSINIT_TEAM]*MinionHalf+Iter[forG.MINIONSINIT_SLOT]
            Minion_setNullStats()
            if(MinionPool!=-1):
                MinionPool.append(Temp_Slot)
            else:
                MinionPool=[Temp_Slot]
            #+vect(-0.43,0,0)-0.01*vect(Minions_Loc[evalOnce(Temp_Slot)].x-(localPlayer.getPosition().x-5),0,Minions_Loc[evalOnce(Temp_Slot)].z-localPlayer.getPosition().z)
            #!define MinionVis localPlayer if (Minions_Info[evalOnce(Temp_Slot)][0] == localPlayer.Team and Minions_Visibility[evalOnce(Temp_Slot)] == 1) or Minions_Visibility[evalOnce(Temp_Slot)] == 2 else null
            #!define MinionPos Minions_Loc[evalOnce(Temp_Slot)] + (getTotalTimeElapsed()+0.25*Minions_Info[evalOnce(Temp_Slot)][3]%4)%TICK_LENGTH * Minions_DLoc[evalOnce(Temp_Slot)] /*should lerp minion between defined points based on direction*/
            #!define MinionColor Color.TEAM_1 if Minions_Info[evalOnce(Temp_Slot)][0]==1 else Color.TEAM_2 if Minions_Info[evalOnce(Temp_Slot)][0]==2 else null
            createInWorldText(MinionVis,MinionClass_Names[Minions_Info[evalOnce(Temp_Slot)][1]*2],textPos(MinionPos),3+Minions_Info[evalOnce(Temp_Slot)][1],Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,MinionColor,SpecVisibility.NEVER)
            createBeam(MinionVis,Beam.GRAPPLE,MinionPos+vect(0,0,-0.05),MinionPos+vect(0,0,0.05),MinionColor,EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
            Minions_Render[Temp_Slot] = [getLastCreatedText,getLastCreatedEntity]
            forEndG(forG.MINIONSINIT_SLOT)
        forEndG(forG.MINIONSINIT_TEAM)
    ThreadClear=true
    Ready()

def Minion_setNullStats():
    Minions_IDs[Temp_Slot] = -0.001
    Minions_Target[Temp_Slot] = -0.001
    Minions_HP[Temp_Slot] = -0.001
    Minions_Visibility[Temp_Slot] = -0.001
    Minions_Info[Temp_Slot] = -0.001
    Minions_DLoc[Temp_Slot] = -0.001
    Minions_Loc[Temp_Slot] = -0.001
 