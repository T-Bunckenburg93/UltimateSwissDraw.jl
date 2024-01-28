

include("testData.jl")
include("func.jl")


println("### Starting Simulation ###")
println("###")
println("###")
using OneHotArrays, LinearAlgebra, JuMP, GLPK

sampleData
_fieldDF

Draw = createSwissDraw(sampleData,_fieldDF)

Draw.currentRound

updateScore!(Draw,"Mount","Duck",1,100)


size(Draw.previousRound,1)

dump(
Draw.currentRound.Games
)




ta = "Whakatu"
tb = "Luminance"

Set([ta,tb])

["Mount"]



games2Mod = filter(x->x.teamA in Set([ta,tb]) || x.teamB in Set([ta,tb]) ,Draw.currentRound.Games)

game2Mod[1].teamAScore = 10
game2Mod[1].teamBScore = 15





# fieldLay = createFieldLayout(_fieldDF)


# # ok, so round 1 is pretty easy. we split the team in half and across the skill gap. 
# # if there is a bye it can go to three places. The middle, the 
# firstRound= CreateFirstRound(dataIn,fieldLay)
# firstRound.gamesToPlay

# # run round randomly
# for i in firstRound.gamesToPlay
#     if i.teamB != "BYE" && i.teamA != "BYE"
#         i.teamAScore = rand(0:13)
#         i.teamBScore = rand(0:13)
#     elseif i.teamB == "BYE"
#         i.teamAScore = 13
#     elseif i.teamA == "BYE"
#         i.teamBScore = 13
#     end
# end


# # ok, so now we want to save this as a round
# round1 = Round(1,firstRound.gamesToPlay)
# # Show the curent rankings, and find the next set of games
# @show rankings(round1.playedGames)
# secondRound =CreateNextRound(round1.playedGames,fieldLay)


# # run round randomly
# for i in secondRound.gamesToPlay
#     if i.teamB != "BYE" && i.teamA != "BYE"
#         i.teamAScore = rand(0:13)
#         i.teamBScore = rand(0:13)
#     elseif i.teamB == "BYE"
#         i.teamAScore = 13
#     elseif i.teamA == "BYE"
#         i.teamBScore = 13
#     end
# end


# # ok, so now we want to save this as a round
# round2 = Round(2,secondRound.gamesToPlay)

# gamesPlayed2 = vcat(
#     round1.playedGames, 
#     round2.playedGames
#     )
# # Show the curent rankings, and find the next set of games
# @show rankings(gamesPlayed2);
# thirdRound = CreateNextRound(gamesPlayed2,fieldLay)



# # run round randomly
# for i in thirdRound.gamesToPlay
#     if i.teamB != "BYE" && i.teamA != "BYE"
#         i.teamAScore = rand(0:13)
#         i.teamBScore = rand(0:13)
#     elseif i.teamB == "BYE"
#         i.teamAScore = 13
#     elseif i.teamA == "BYE"
#         i.teamBScore = 13
#     end
# end
# round3 = Round(3,thirdRound.gamesToPlay)


# gamesPlayed3 = vcat(
#     round1.playedGames, 
#     round2.playedGames,
#     round3.playedGames
#     )

# @show rankings(gamesPlayed3);
# thirdRound = CreateNextRound(gamesPlayed2,fieldLay);

# thirdRound.gamesToPlay

# filter(x->x.fieldNumber == 1,  gamesPlayed3)