#!mainFile "main.opy"
#!define println(a)  wait(0.1)\
enableInspector()\
printLog(a)\
disableInspector()


#!defineMember ln(a) (100*((a)**0.01)-100)
#!define MinionPositionLane1n3(t,j) (((t)/8)+(3-j-1)*50*sqrt(ln(1-abs((t)-100)/138.75)/1.3635+(0.967**2))-2) 
#MOBA Map, Desmos
#!define MinionPositionLane2(t) (((t)/8)*(4 < (t) and (t) < 16))
#!define M_id(i,k) 10+(i+1)+k/100
#!define ft(a,i) (((a)+0.02)*(1-i)+(i)*(19.98-(a)))
#!define MinionLimit(a) a*0+(1-a)*20
#range(0,48) is min          k             2-type[1=min,2=struct]            team               structures
#!define NonPLoc(id) (id % floor(id))*100   + (2-floor(id/10))     *  48*(floor(id-1) % 10) + (id-1)*(floor(id-1) % 10)*36
#i*48+k

#floor(id/10)
#floor(id) % 10
#id % floor(id)

def Minions_Move():
    for LocTemp_i in range(len(LocationChange)):
        LocTemp_var=floor(LocationChange[LocTemp_i].x * 1000) % 100
        if (NonPlayer_Loc[LocTemp_var].x!=LocationChange[LocTemp_i].x):
            LocTemp_var=NonPlayer_Loc.index([elem for elem in NonPlayer_Loc if elem.x==LocationChange[LocTemp_i].x][0])
        NonPlayer_Loc[LocTemp_var]=NonPlayer_Loc[LocTemp_var]+vect(0,LocationChange[LocTemp_i].y,LocationChange[LocTemp_i].z) #don't want to add the id twice, so we add 0
    wait(0.1)
def Minions_Main():
    /*
    M_tTemp=0
    Temp_ID=0
    M_DataTemp=0
    PA_Temp=[]
    waitUntil(ThreadClear==true,100)
    ThreadClear = false
    for i in range(0,2): #iterates through teams
        #printLog("{0} {1} {2}_".format(k,MinionRanges[0][i-1],MinionRanges[0][i-1]+MinionRanges[1][i-1]))
        MA_Temp=[-1]
        for k in range(0,len(Minions[i])): #iterates through all minion objects in lane on team
            MR_Temp=Minions[i][k]
            if(Minions[i][k][6]==true):
                if(Minions[i][k][3]>0):
                    #get minion's range by type
                    #!define dist MinionTypes[Minions[i][k][0]*MinionTypesQualities+2] 
                    #!define structDist(a) abs(Minions[i][k][1] - (StructuresMP[a].y-StructuresWH[a].y/2))**2+abs(Minions[i][k][2] - (StructuresMP[a].z-StructuresWH[a].z/2))**2
                    #!define minionDist(a) (Minions[a+1]-Minions[i][k][1])**2 +(Minions[a+2]-Minions[i][k][2])**2
                    #!define playerDist(a) PA_Temp[a].ControlledRef.getPosition().x**2+PA_Temp[a].ControlledRef.getPosition().z**2
                    Temp_ID = 0
                    if(Minions[i][k][4]==0): #player id = 0, minion id = 1, struct id = 2
                        #MOVE Minion
                        if(i==0):
                            #increase time by one
                            if(t1(MR_Temp[1]+0.1)<MinionLimit(0)):
                                MR_Temp[1] = t1(MR_Temp[1]+0.1)
                        elif(i==1):
                            #increase time by one
                            if(t2(MR_Temp[1]+0.1)>MinionLimit(1)):
                                MR_Temp[1] = t2(MR_Temp[1]+0.1)
                        #handle f(t)
                        MR_Temp[2]=MinionPositionLane2(M_tTemp)
                        
                        M_tTemp = 0
                        for l in range(len(Structures)):
                            if(structDist(l)<=dist**2):
                                HealthChange.append(vect(2+l/1000,MinionTypes[Minions[k]*MinionTypesQualities+3],1)) #adds damage instance to array with vect(id, damage dealt, tick duration) where damage dealt is according to its type
                                goto break_end
                            #as is in combat, deal damage
                        for l in range(MinionRanges[2-i][0],MinionRanges[2-i][0]+MinionRanges[2-1][1]):
                            if(minionDist(l)<=dist**2):
                                M_tTemp =1+l/1000
                                HealthChange.append(vect(M_tTemp,MinionTypes[Minions[k]*MinionTypesQualities+3],1)) #adds damage instance to array with vect(id, damage dealt, tick duration) where damage dealt is according to its type
                                goto break_end
                        if(i==0):
                            PA_Temp=getPlayers(Team.1)
                        elif(i==1):
                            PA_Temp=getPlayers(Team.2)
                        for l in range(len(PA_Temp)):
                            if(playerDist(l)<=dist**2):
                                M_tTemp = 0+PA_Temp.Slot/1000+(i/10)
                                HealthChange.append(vect(M_tTemp,MinionTypes[Minions[k]*MinionTypesQualities+3],1))
                                goto break_end
                            
                    elif(Minions[i][k][4] >= 2): #--Reevaluate target distance--#
                        Temp_ID = (Minions[i][k][4]-2)*1000
                        if ((structDist(Temp_ID)>dist**2) or (Structures[Temp_ID].y <= 0)): #check structure hp
                            M_tTemp = 0
                            goto break_end 
                    elif(Minions[i][k][4] < 2 and Minions[i][k][4] >= 1):  
                        Temp_ID = (Minions[i][k][4]-1)*1000
                        if ((minionDist(Temp_ID)>dist**2) or (Minions[Temp_ID+3]<=0) or (Minions[Temp_ID+8]==Minions[i][k][8])): #if outside of range,
                            M_tTemp = 0
                            goto break_end 
                    elif(Minions[i][k][4] < 1 and Minions[i][k][4]>0):
                        if(Minions[i][k][4]*10>=2): #bug check
                            PA_Temp=getPlayers(Team.1)
                            Temp_ID=(Minions[i][k][4]-0.1)*1000
                        elif(Minions[i][k][4]*10>=1):
                            PA_Temp=getPlayers(Team.2)
                            Temp_ID=(Minions[i][k][4]-0.2)*1000
                        if ((playerDist(Temp_ID)>dist**2) or PA_Temp[Temp_ID].getHealth()<=0):
                            M_tTemp = 0
                            goto break_end 
                    break_end:
                    MR_Temp[4]=M_tTemp #set target
                    if(i == 0):
                        M_tTemp = (Color.TEAM_1)
                    elif(i==1):
                        M_tTemp = (Color.TEAM_2)
                else:
                    MR_Temp[6]=false
            else:
                println("Remove Minion {0} on Team {1}".format(j,i+1))
                #slate for removal
            if(MA_Temp[len(MA_Temp)-1]!=-1):
                MA_Temp.append(0)
            MA_Temp[len(MA_Temp)-1]=MR_Temp
        if(i<2):
            Minions[i]=MA_Temp     
    ThreadClear = true*/
    wait(1)
    
def PrintMinions():
    waitUntil(ThreadClear==true,100)
    ThreadClear=false
    for i in range(len(Minions)):
        PrintText_Temp="Team {0}:\n[".format(i+1)
        for j in range(len(Minions[i])):
            if(strLen(PrintText_Temp)*1+30>511):
                println(PrintText_Temp)
                PrintText_Temp="Team {0}, Index {1}:\n".format(i+1,j)
            PrintText_Temp="{0}[".format(PrintText_Temp)
            for k in range(len(Minions[i][j])):
                PrintData_Temp=","
                if(k>=len(Minions[i][j])-1):
                    PrintData_Temp=""
                PrintText_Temp="{0}{1}{2}".format(PrintText_Temp,Minions[i][j][k],PrintData_Temp)
            PrintData_Temp="],\n" 
            if(j>=len(Minions[i])-1):
                PrintData_Temp="]"
            PrintText_Temp="{0}{1}".format(PrintText_Temp,PrintData_Temp)
        PrintData_Temp=","
        if(i>=len(Minions)-1):
            PrintData_Temp=""
        PrintText_Temp="{0}]{1}".format(PrintText_Temp,PrintData_Temp)
        println("{0} Team {1}, Length {2}".format(PrintText_Temp,i+1,j))
    println("\n\n\n\n\n\n\n\n\n\n")
    ThreadClear=true

def Minion_Wave():
    waitUntil(ThreadClear==true,100)
    ThreadClear=false
    for i in range(2):
        for l in range(MinionWaves[i]*6,(MinionWaves[i]+1)*6):
            if(i==0):
                M_tTemp=Color.TEAM_1
            elif(i==1):
                M_tTemp=Color.TEAM_2
            #createInWorldText(,MinionTypes[Minions[i][k][0]*MinionTypesQualities],vect(NonPlayer_Loc[evalOnce(k)][1],0,Minions[evalOnce(i)][evalOnce(k)][2]),3,Clip.SURFACES,WorldTextReeval.VISIBILITY_AND_POSITION,M_tTemp,SpecVisibility.NEVER)
            MinionRenders[i] = [len(Minions[i])-1,getLastCreatedText,getLastCreatedEntity]
def Minions_Init():
                           # 0    , 1   ,  2   , 3  ,                 4                            5       6        7              8                  9    
    MinionQualities = len(["Type","id","hp","ID of Minion being fought or Player name","isAlive","Visbility"]) #t is the time the minion has been moving (place on function lane(t))
    MinionTypesQualities=len(["icon", "name", "range", "damage","base_hp"])
    MinionTypes = ["ι","Minion",2,10,80,"ί","Mage",6,16,60,"ϊ","Seige",12,40,150,"ΐ","Brute",3,80,400]
    MWeapons = [["ο","ơ","δ","σ"],["Y","ϒ","ϔ", "Ẏ"]]
    for i in range(0,2):
        for k in range(48):
            MR_Temp=[(Temp_ID),M_id(i,k),MinionTypes[Temp_ID*MinionTypesQualities+4],0,false,null]
            if(len(MR_Temp)!=MinionQualities):
                println("Error: MinionCreate is wrong size")
            
            if(Minions[i]==-1):
                Minions[i]=[MR_Temp]
            else:
                Minions[i].append([MR_Temp])
            NonPlayer_Loc[i*48+k]=vect(M_id(i,k),ft(0,i),0)
    Ready()  
/*  
(j==1 or j==3): M_DataTemp=MinionPositionLane1n3(M_tTemp,j)
*/

            /**/
            #createBeam(Minions[evalOnce(i)][evalOnce(k)][7],Beam.GRAPPLE,vect(Minions[evalOnce(i)][evalOnce(k)][1]-0.25,1,Minions[evalOnce(i)][evalOnce(k)][2]),vect(Minions[evalOnce(i)][evalOnce(k)][1]+0.5*(Minions[evalOnce(i)][evalOnce(k)][3]/MinionTypes[Minions[evalOnce(i)][evalOnce(k)][0]*MinionTypesQualities+4]),1,Minions[evalOnce(i)][evalOnce(k)][2]),null,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            