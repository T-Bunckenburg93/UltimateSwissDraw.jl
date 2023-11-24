
include("init.jl")

using OneHotArrays, LinearAlgebra, JuMP, Cbc, GLPK

dataIn = deepcopy(sampleData)

dataIn
# ok, so round 1 is pretty easy. we split the team in half and across the skill gap. 
# if there is a bye it can go to three places. The middle, the 
firstRound= CreateFirstRound(dataIn,fieldDF)


firstRound.gamesToPlay
# enter results

# PW vs TT
firstRound.gamesToPlay[1].teamAScore = 13
firstRound.gamesToPlay[1].teamBScore = 5

# TC vs MUA
firstRound.gamesToPlay[2].teamAScore = 12
firstRound.gamesToPlay[2].teamBScore = 7

# Htron vs AUUC
firstRound.gamesToPlay[3].teamAScore = 13
firstRound.gamesToPlay[3].teamBScore = 7

# Axiom vs Euphoria
firstRound.gamesToPlay[4].teamAScore = 10
firstRound.gamesToPlay[4].teamBScore = 6

# Ethos vs Radiance
firstRound.gamesToPlay[5].teamAScore = 13
firstRound.gamesToPlay[5].teamBScore = 8

# GG vs Gen3
firstRound.gamesToPlay[6].teamAScore = 13
firstRound.gamesToPlay[6].teamBScore = 5

# Morri vs Luminance
firstRound.gamesToPlay[7].teamAScore = 13
firstRound.gamesToPlay[7].teamBScore = 3

# Mount vs Duck
firstRound.gamesToPlay[8].teamAScore = 13
firstRound.gamesToPlay[8].teamBScore = 2

# Whakatu vs Wow
firstRound.gamesToPlay[9].teamAScore = 13
firstRound.gamesToPlay[9].teamBScore = 4



# ok, so now we want to save this as a round
round1 = Round(1,firstRound.gamesToPlay)

# now we create the second game
secondRound =CreateNextRound(round1.playedGames,_fieldDF)
@show rankings(round1.playedGames)

secondRound.gamesToPlay

# "T_Thunder", "Whakatu"
secondRound.gamesToPlay[2].teamAScore = 13
secondRound.gamesToPlay[2].teamBScore = 4

secondRound.gamesToPlay[2]




# ok, so now we want to save this as a round
round2 = Round(2,secondRound.gamesToPlay)

gamesPlayed2 = vcat(
    round1.playedGames, 
    round2.playedGames
    )

    thirdRound = CreateNextRound(gamesPlayed2,_fieldDF)

@show rankings(gamesPlayed2);


thirdRound.gamesToPlay
# run round randomly
for i in thirdRound.gamesToPlay
    if i.teamB != "BYE" && i.teamA != "BYE"
        i.teamAScore = rand(0:13)
        i.teamBScore = rand(0:13)
    elseif i.teamB == "BYE"
        i.teamAScore = 13
    elseif i.teamA == "BYE"
        i.teamBScore = 13
    end
end
round3 = Round(3,thirdRound.gamesToPlay)


gamesPlayed3 = vcat(
    round1.playedGames, 
    round2.playedGames,
    round3.playedGames
    )

@show rankings(gamesPlayed3);
