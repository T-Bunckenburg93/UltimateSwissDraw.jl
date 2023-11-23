
include("init.jl")

using OneHotArrays, LinearAlgebra, JuMP, Cbc, GLPK

dataIn = deepcopy(sampleData)

dataIn
# ok, so round 1 is pretty easy. we split the team in half and across the skill gap. 
# if there is a bye it can go to three places. The middle, the 



function CreateFirstRound(_df::DataFrame,bye::Symbol=:middle)

    df = deepcopy(_df)

    g = Game[]
    # first check if df is odd:
    if isodd(size(df,1))
   
        if bye == :middle
            ind = Int(ceil(size(df,1)/2))

            # add the bye to the byegame object
            byeGame = Game(df[ind,:].team,"BYE","",0,0)
            push!(g,byeGame)
            # and RM the team
            deleteat!(df,ind)

        end
        if bye == :first
            ind = 1

            # add the bye to the byegame object
            byeGame = Game(df[ind,:].team,"BYE","",0,0)
            push!(g,byeGame)
            # and RM the team
            deleteat!(df,ind)
            
        end
        if bye == :last
            ind = size(df,1)

            # add the bye to the byegame object
            byeGame = Game(df[ind,:].team,"BYE","",0,0)
            push!(g,byeGame)
            # and RM the team
            deleteat!(df,ind)
            
        end
    end

    # order the teams so that we can join the top of the top half to the top of the bottom
    # if there were 8 teams, 1 -> 5, 2 -> 6 etc
    df._rank = collect(1:size(df,1))

    sz = floor(size(df,1)/2)

    df._rank_match = df._rank .+ sz
    
    # And join them together 
    pairings = innerjoin(
                select(df,[:team, :_rank_match,]),
                select(df,[:team, :_rank]),
                on = :_rank_match => :_rank, renamecols = "_left" => "_right")
            
    

    for i in eachrow(pairings)
        push!(g, Game(i.team_left, i.team_right, "", 0, 0))
    end

    NextRound = nextRound(g) # create a nextround object from the list of games.
    return NextRound;

end

dataIn
firstRound= CreateFirstRound(dataIn)


# run round randomly
for i in firstRound.gamesToPlay
    if i.teamB != "BYE"
        i.teamAScore = rand(0:15)
        i.teamBScore = rand(0:15)
    else
        i.teamAScore = 13
    end
end



# ok, so now we want to save this as a round
round1 = Round(1,firstRound.gamesToPlay)

round1.playedGames



# dataIn
# firstRound= CreateFirstRound(dataIn)
secondRound =CreateNextRound(round1.playedGames,:middle)

secondRound.gamesToPlay
# run round randomly
for i in secondRound.gamesToPlay
    if i.teamB != "BYE"
        i.teamAScore = rand(0:15)
        i.teamBScore = rand(0:15)
    else
        i.teamAScore = 13
    end
end

# ok, so now we want to save this as a round
round2 = Round(2,secondRound.gamesToPlay)



gamesPlayed = vcat(
    round1.playedGames, 
    round2.playedGames
    )

thirdRound = CreateNextRound(gamesPlayed,:middle)

rankings(gamesPlayed)