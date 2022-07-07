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


def Minions_Move():
    for LocTemp_i in range(len(Minions_DLoc)):
        LocTemp_var=floor(Minions_DLoc[LocTemp_i].x * 1000) % 100
        if (NonPlayer_Loc[LocTemp_var].y!=Minions_DLoc[LocTemp_i].y):
            LocTemp_var=NonPlayer_Loc.index([elem for elem in NonPlayer_Loc if elem.y==Minions_DLoc[LocTemp_i].y][0])
        NonPlayer_Loc[LocTemp_var]=NonPlayer_Loc[LocTemp_var]+Minions_DLoc[LocTemp_i]*vect(1,0,1) #don't want to add the id twice, so we add 0
    wait(0.1)
def Minions_Main():
    LocTemp_var=getTotalTimeElapsed()*100
    waitUntil(ThreadClear==true,100)
    ThreadClear=false
    for i in range(0,2):
        for j in range(0,MinionHalfCount):
            NonPlayer_Loc[i*MinionHalfCount+j]=NonPlayer_Loc[i*MinionHalfCount+j]+Minions_DLoc[i*MinionHalfCount+j]
           # Minions_DLoc recalculate
    ThreadClear=true
    
    
    
def PrintMinions():
    waitUntil(ThreadClear==true,100)
    ThreadClear=false
    # for i in range(len(Minions)):
    #     PrintText_Temp="Team {0}:\n[".format(i+1)
    #     for j in range(len(Minions[i])):
    #         if(strLen(PrintText_Temp)*1+30>511):
    #             println(PrintText_Temp)
    #             PrintText_Temp="Team {0}, Index {1}:\n".format(i+1,j)
    #         PrintText_Temp="{0}[".format(PrintText_Temp)
    #         for k_ in range(len(Minions[i][j])):
    #             PrintData_Temp=","
    #             if(k_>=len(Minions[i][j])-1):
    #                 PrintData_Temp=""
    #             PrintText_Temp="{0}{1}{2}".format(PrintText_Temp,Minions[i][j][k_],PrintData_Temp)
    #         PrintData_Temp="],\n" 
    #         if(j>=len(Minions[i])-1):
    #             PrintData_Temp="]"
    #         PrintText_Temp="{0}{1}".format(PrintText_Temp,PrintData_Temp)
    #     PrintData_Temp=","
    #     if(i>=len(Minions)-1):
    #         PrintData_Temp=""
    #     PrintText_Temp="{0}]{1}".format(PrintText_Temp,PrintData_Temp)
    #     println("{0} Team {1}, Length {2}".format(PrintText_Temp,i+1,j))
    ThreadClear=true

def Minions_Wave():
        waitUntil(ThreadClear==true,100)
        ThreadClear=false
        MinionWaves[0]++
        if(MinionPool!=[0] and len(MinionPool)):
            for i in range(0,2):
                for j in range((1-i),MinionsPerWave+(MinionWaves[0]>15 and MinionWaves[0]%3==0)+1): #3 waves per side, 6 each, adds one if wave is late in game
                    
                    MinionCounts[i]=(MinionCounts[i]+1)%100 #causes wraparound
                    Temp_Slot=MinionPool[0]   #grabs minion slot before removing it
                    del MinionPool[0] #removes it from pool
                    Temp_ID = MinionCounts[i]+i*100+1000
                    Minions_Info[Temp_Slot] = [i,0 if j<6 else 1 if j==6 else 2 if j==7 else 3 if j==8 else -1,MinionWaves[0],MinionCounts[i]]
                    Minions_Visibility[Temp_Slot]=1
                    Minions_HP[Temp_Slot] = MinionClass_BaseHP[Minions_Info[evalOnce(Temp_Slot)][1]]
                    Minions_IDs[Temp_Slot] = Temp_ID
                    #Minions info is set after the text and entity are created
                    Minions_DLoc[Temp_Slot] = vect(1,Temp_ID,1)
                    NonPlayer_Loc[Temp_Slot] = vect(0,Temp_ID,0)        
                    wait(0.25)
        PrintText_Temp=""
        for l in range(0,len(MinionPool)):
            PrintText_Temp="{},{}".format(PrintText_Temp,MinionPool[l])
        ThreadClear=true
def Minions_Init():
    waitUntil(ThreadClear==true,100)
    ThreadClear=false
    #MWeapons = [["ο","ơ","δ","σ"],["Y","ϒ", "ϔ", "Ẏ"]]
    for i in range(0,2): 
    #!define MinionHalf 4
        for k_ in range((1-i),MinionHalf+(1-i)): #sk_ips 0, which is potentially problematic
            Temp_Slot = i*MinionHalf+k_
            Minion_setNullStats()
            if(MinionPool!=-1):
                MinionPool.append(Temp_Slot)
            else:
                MinionPool=[Temp_Slot]
            #+vect(-0.43,0,0)-0.01*vect(NonPlayer_Loc[evalOnce(Temp_Slot)].x-(localPlayer.getPosition().x-5),0,NonPlayer_Loc[evalOnce(Temp_Slot)].z-localPlayer.getPosition().z)
            #!define MinionVis localPlayer if (Minions_Info[evalOnce(Temp_Slot)][0] == localPlayer.Team and Minions_Visibility[evalOnce(Temp_Slot)] == 1) or Minions_Visibility[evalOnce(Temp_Slot)] == 2 else null
            #!define MinionPos NonPlayer_Loc[evalOnce(Temp_Slot)] + (getTotalTimeElapsed()+0.25*Minions_Info[evalOnce(Temp_Slot)][3]%4)%1 * Minions_DLoc[evalOnce(Temp_Slot)] /*should lerp minion between defined points based on direction*/
            #!define MinionColor Color.TEAM_1 if Minions_Info[evalOnce(Temp_Slot)][0]==1 else Color.TEAM_2 if Minions_Info[evalOnce(Temp_Slot)][0]==2 else null
            #println([elem + (((0.075 + angleBetweenVectors(directionTowards(EYE,LOOK), directionTowards(EYE, elem)))/2000 * distance(EYE, elem)) * Vector.DOWN) for elem in MinionPos][0])
            #Global.A = Mapped Array(Vector(0,0,0), Current Array Element + (0.075 - Angle Between Vectors(Facing Direction Of(Local Player), Direction Towards(Eye Position(Local Player), Current Array Element))/2000) * Distance Between(Eye Position(Local Player), Current Array Element) * Down)
            #text(MinionVis,MinionClass_Names[Minions_Info[evalOnce(Temp_Slot)][1]*2],MinionPos,MinionColor)
            
            #createInWorldText(MinionVis,,[pos - crossProduct(vect(0,0,-1),directionTowards(LOOK,pos))*distance(LOOK,pos)/16 for pos in [MinionPos-vect(0.45,0,0)]],3+Minions_Info[evalOnce(Temp_Slot)][1],Clip.NONE,WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,MinionColor,SpecVisibility.NEVER)
            createBeam(MinionVis,Beam.GRAPPLE,MinionPos+vect(0,0,-0.05),MinionPos+vect(0,0,0.05),MinionColor,EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
            Minions_Render[Temp_Slot] = [getLastCreatedText,getLastCreatedEntity]
    ThreadClear=true
    Ready()
#createBeam(Minions[evalOnce(i)][evalOnce(k_)][7],Beam.GRAPPLE,vect(Minions[evalOnce(i)][evalOnce(k_)][1]-0.25,1,Minions[evalOnce(i)][evalOnce(k_)][2]),vect(Minions[evalOnce(i)][evalOnce(k_)][1]+0.5*(Minions[evalOnce(i)][evalOnce(k_)][3]/MinionClasses[Minions[evalOnce(i)][evalOnce(k_)][0]*MinionClassQualities+4]),1,Minions[evalOnce(i)][evalOnce(k_)][2]),null,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


def Minion_setNullStats():
    Minions_IDs[Temp_Slot] = -0.001
    Minions_Target[Temp_Slot] = -0.001
    Minions_HP[Temp_Slot] = -0.001
    Minions_Visibility[Temp_Slot] = -0.001
    Minions_Info[Temp_Slot] = -0.001
    Minions_DLoc[Temp_Slot] = -0.001
    NonPlayer_Loc[Temp_Slot] = -0.001
