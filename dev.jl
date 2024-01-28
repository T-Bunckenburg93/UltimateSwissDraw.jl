

include("testData.jl")
include("func.jl")


println("### Starting Simulation ###")
println("###")
println("###")
using OneHotArrays, LinearAlgebra, JuMP, GLPK

sampleData
_fieldDF

Draw = createSwissDraw(sampleData,_fieldDF)

print(Draw.currentRound)

# ok, so we want to switch some fields around
# We might do this to fuck with streaming
switchFields!(Draw,1,5)
switchFields!(Draw,2,6)


# update some scores
updateScore!(Draw,"Whakatu","Wow",1,15)
updateScore!(Draw,"Mount","Duck",1,15)
updateScore!(Draw,"Morri","Luminance",1,15)
updateScore!(Draw,"GG","Gen3",1,15)
updateScore!(Draw,"Ethos","Radiance",1,15)
updateScore!(Draw,"Axiom","Euphoria",1,15)
updateScore!(Draw,"Htron","AUUC",1,15)
updateScore!(Draw,"Tcookies","MUA",1,15)

# wait actually, a mistake was made and two teams that shouldn't have played each other did. 
SwitchTeams!(Draw,"Tcookies","AUUC")

# Now we reupdate the scores.. How good
updateScore!(Draw,"Htron","Tcookies",1,15)
updateScore!(Draw,"AUUC","MUA",1,100)









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