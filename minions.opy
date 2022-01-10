#!mainFile "main.opy"
#4
#
globalvar Minions 5
globalvar MinionRanges 6
globalvar MR_HelperBot 7
globalvar MR_HelperTop 8
globalvar HealthChange 9 #(id, health change amt (+ = dmg, - = healing), tick duration of either)
globalvar Structures 10 #id, health, blank
globalvar StructuresMP 11 #midpoint of structure (id,x,z)
globalvar StructuresWH 12 #width and height (id,w,h)
globalvar ThreadClear 13 #is thread clear for damaging minions 
globalvar M_tTemp 14
globalvar M_DataTemp 15
globalvar MA_Temp 16 #Minions Array Temp
globalvar PA_Temp 17 #Player Array Temp
globalvar MR_Temp 18 #Minion ranges temp array
globalvar Temp_ID 19
globalvar MinionWaves 33
globalvar TextEffectHandling 34
globalvar TextEH_Temp 35
globalvar PrintText_Temp 36
globalvar PrintData_Temp 37
subroutine Minions_Main 6
subroutine Minions_Init 7
subroutine Minions_Create 9
subroutine PrintMinions 10
subroutine Minion_Renderer 11
#33


#!define println(a)  wait(0.1)\
enableInspector()\
printLog(a)\
disableInspector()

#MinionRanges: [t1 lane1 start, t1 lane1 end, t1 lane2 start, t1 lane2 end, t1 lane3 start, t1 lane3 end, t2 lane1 start, t2 lane1 end, t2 lane2 start, t2 lane2 end, t2 lane3 start, t2 lane3 end]
#[0,1],[2,3],[4,5],[6,7],[8,9],[10,11]
# L1    L2  L3   L1    L2     L3  

#Minion Ranges: [t1 lane2 start, t2 lane2 start], [t1 lane 2 length, t2 lane 2 length]

#!defineMember ln(a) (100*((a)**0.01)-100)
#!define MinionPositionLane1n3(t,j) (((t)/8)+(3-j-1)*50*sqrt(ln(1-abs((t)-100)/138.75)/1.3635+(0.967**2))-2) #MOBA Map, Desmos
#!define MinionPositionLane2(t) (((t)/8)*(4 < (t) and (t) < 16))
#!define t1(a) ((a)+0.02)
#!define t2(a) (19.98-(a)) #199.998


def Minions_Main():
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
                            MR_Temp[1] = t1(MR_Temp[1]+0.1)
                        elif(i==1):
                            #increase time by one
                            MR_Temp[1] = t2(MR_Temp[1]+0.1)
                        #handle f(t)
                        MR_Temp[2]=MinionPositionLane2(M_tTemp)
                        /*
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
                        M_tTemp = (Color.TEAM_2)*/
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
    ThreadClear = true
    
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

def Minions_Create():
    waitUntil(ThreadClear==true,100)
    ThreadClear = false
    MR_Temp=[]
    for i in range(0,2): #iterates through teams
        for l in range(0,evalOnce(MinionWaves[0])):
            if(l<4):
                Temp_ID=0
            elif(l==5):
                Temp_ID=2
            else:
                Temp_ID=1
            if(i==0):
                M_tTemp=t1(0)
            elif(i==1):
                M_tTemp=t2(0)
            MR_Temp=[(Temp_ID),(M_tTemp),(MinionPositionLane2(M_tTemp)),MinionTypes[Temp_ID*MinionTypesQualities+4],0,i,true]
            if(len(MR_Temp)!=MinionQualities):
                println("Error: MinionCreate is wrong size")
            if(Minions[i]==-1):
                Minions[i]=[MR_Temp]
            else:
                Minions[i].append([MR_Temp])

            if(i==0):
                M_tTemp=Color.TEAM_1
            elif(i==1):
                M_tTemp=Color.TEAM_2
            TextEffectHandling[len(Minions[i])-1]=[len(Minions[i])-1,0,0,vect(0,0,0),vect(0,0,0),getAllPlayers()] #id,textid,effectid,textlocation(v3):(0,x,z),effectlocation(v3):(x1,x2,z),visibility
            createInWorldText(TextEffectHandling[evalOnce(len(Minions[i])-1)][6],MinionTypes[Minions[k]*MinionTypesQualities],vect(TextEffectHandling[evalOnce(len(Minions[i])-1)][3].y,0,TextEffectHandling[evalOnce(len(Minions[i])-1)][3].z),3,Clip.SURFACES,WorldTextReeval.VISIBILITY_AND_POSITION,evalOnce(M_tTemp),SpecVisibility.NEVER)
            j=getLastCreatedText()
            createBeam(TextEffectHandling[evalOnce(len(Minions[i])-1)][6],Beam.GOOD,vect(TextEffectHandling[evalOnce(len(Minions[i])-1)][4].x,1,TextEffectHandling[evalOnce(len(Minions[i])-1)][4].z),vect(TextEffectHandling[evalOnce(len(Minions[i])-1)][4].y,1,TextEffectHandling[evalOnce(len(Minions[i])-1)][4].z),M_tTemp,EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            k=getLastCreatedEntity()
            TextEffectHandling[len(Minions[i])-1]=[len(Minions[i])-1,j,k,vect(0,0,0),vect(0,0,0),getAllPlayers()] #id,textid,effectid,textlocation(v3):(0,x,z),effectlocation(v3):(x1,x2,z),visibility
  
    ThreadClear=true
        


def Minion_Renderer():
    for i in range(len(Minions)):
        for j in range(len(Minions[i])):
            TextEffectHandling[j]=[j,TextEffectHandling[j][1],TextEffectHandling[j][2],vect(0,Minions[i][j][1],Minions[i][j][2]),vect(Minions[i][j][1]-0.5,Minions[i][j][1]-0.5+(Minions[i][j][3]/MinionTypes[Minions[i][j][0]*MinionTypesQualities+4]),Minions[i][j][1]),getAllPlayers()]
  
def Minions_Init():
                           # 0    , 1   ,  2   , 3  ,                 4                            5       6    
    MinionQualities = len(["Type","time","f(t)","hp","ID of Minion being fought or Player name","team","isAlive"]) #t is the time the minion has been moving (place on function lane(t))
    MinionTypesQualities=len(["icon", "name", "range", "damage","base_hp"])
    MinionTypes = ["ι","Minion",2,10,80,"ί","Mage",6,16,60,"ϊ","Seige",12,40,150,"ΐ","Brute",3,80,400]
    MWeapons = [["ο","ơ","δ","σ"],["Y","ϒ","ϔ", "Ẏ"]]
    MinionWaves = [6]
/*
(j==1 or j==3): M_DataTemp=MinionPositionLane1n3(M_tTemp,j)
*/