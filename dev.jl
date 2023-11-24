
include("init.jl")


println("### Starting Simulation ###")
println("###")
println("###")
using OneHotArrays, LinearAlgebra, JuMP, Cbc, GLPK, COSMO

dataIn = deepcopy(sampleData)
dataIn = deepcopy(sampleData)

fieldDF = deepcopy(_fieldDF)
# ok, so round 1 is pretty easy. we split the team in half and across the skill gap. 
# if there is a bye it can go to three places. The middle, the 
firstRound= CreateFirstRound(dataIn,fieldDF)
firstRound.gamesToPlay

# run round randomly
for i in firstRound.gamesToPlay
    if i.teamB != "BYE" && i.teamA != "BYE"
        i.teamAScore = rand(0:13)
        i.teamBScore = rand(0:13)
    elseif i.teamB == "BYE"
        i.teamAScore = 13
    elseif i.teamA == "BYE"
        i.teamBScore = 13
    end
end


# ok, so now we want to save this as a round
round1 = Round(1,firstRound.gamesToPlay)
# Show the curent rankings, and find the next set of games
@show rankings(round1.playedGames)
secondRound =CreateNextRound(round1.playedGames,_fieldDF)


# run round randomly
for i in secondRound.gamesToPlay
    if i.teamB != "BYE" && i.teamA != "BYE"
        i.teamAScore = rand(0:13)
        i.teamBScore = rand(0:13)
    elseif i.teamB == "BYE"
        i.teamAScore = 13
    elseif i.teamA == "BYE"
        i.teamBScore = 13
    end
end


# ok, so now we want to save this as a round
round2 = Round(2,secondRound.gamesToPlay)

gamesPlayed2 = vcat(
    round1.playedGames, 
    round2.playedGames
    )
# Show the curent rankings, and find the next set of games
@show rankings(gamesPlayed2);
thirdRound = CreateNextRound(gamesPlayed2,_fieldDF)



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
thirdRound = CreateNextRound(gamesPlayed2,_fieldDF);

thirdRound.gamesToPlay

filter(x->x.fieldNumber == 1,  gamesPlayed3)