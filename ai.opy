#!mainFile "main.opy"
rule "Movement Automation":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() and not eventPlayer.Owner
    eventPlayer.MovetoPos=vect(random.randint(10,-10),0,random.randint(10,-10))
    waitUntil(eventPlayer.ArrivedAtM2P==-1,99)
