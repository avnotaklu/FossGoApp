# after move played by a
## a : 
### in cells ontap
    * ntp.now is time when move was played and set it to database's lastMoveDateTime for given player
### timerbuild function
    * get the lastMoveDateTime from database 
    * a's new time = timeLeftForA(duration) - timeSpentMakingNewMove
    * timeSpentMakingNewMove = timeOfa in lastMoveDateTime - timeOfb in lastMoveDateTime

    * set durationof a to database
    

## b : 
### in cells ontap
    * ntp.now is time when move was played and set it to database's lastMoveDateTime for given player
### timerbuild function
    * get the lastMoveDateTime from database 
    * b's new time = timeLeftForB(duration) - timeASpentMakingNewMove(lag that happended recieving move)
    * timeSpentMakingNewMove = ntpnow - timeOfa in lastMoveDateTime

    * put new datetime in database

    * set durationofb to database


# problems right now
    * the player who plays doesn't get their timer synced in case something unexpected happends(just set breakpoints that will unsync timer to reproduce) the sync happens only when opponent plays move and then the times are corrected.
