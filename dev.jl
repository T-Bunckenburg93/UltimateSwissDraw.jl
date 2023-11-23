
include("init.jl")

using OneHotArrays, LinearAlgebra, JuMP, Cbc, GLPK

dataIn = deepcopy(sampleData)

dataIn
# ok, so round 1 is pretty easy. we split the team in half and across the skill gap. 
# if there is a bye it can go to three places. The middle, the 
firstRound= CreateFirstRound(dataIn)


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

# now we create the second game
secondRound =CreateNextRound(round1.playedGames,:middle)
@show rankings(round1.playedGames)

secondRound.gamesToPlay
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

thirdRound = CreateNextRound(gamesPlayed2,:middle)

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
