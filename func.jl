using DataFrames,  Dates, JLD2, GLPK, StatsBase, LinearAlgebra, CairoMakie
using EAGO
# using JuMP
### Customer structures that we use and can operate on

"""
A game is a pairing of two teams at a location.
Can be updated at any time to add the score, location etc

accessible fields are:

    teamA::String
    teamB::String
    fieldNumber::Int
    teamAScore::Int
    teamBScore::Int
    streamed::Bool
"""
mutable struct Game
    teamA::String
    teamB::String
    fieldNumber::Int
    teamAScore::Union{Int,Missing}
    teamBScore::Union{Int,Missing}
    streamed::Bool
end

Base.show(io::IO, z::Game) = print(io,"'",z.teamA,"' plays '", z.teamB,"' on Field: ",z.fieldNumber,", Score: ",z.teamAScore," - ",z.teamBScore,", Streamed = ",z.streamed ) 


Game("teamA","teamB",1,missing,missing,false)




"""
RoundOfGames:
A set of games that are all been played at the same time. 
These are time agnostic, and this object may hold games that have completed or are yet to complete

accessible fields are:
    Games::Array{Game}
    roundNumber::Int
"""
mutable struct RoundOfGames
    Games::Array{Game}
    roundNumber::Int
end 

function Base.show(io::IO, z::RoundOfGames) 
    println()
    println(io,"Round Number: ", z.roundNumber)
    # println()
    println.(io,"   ", z.Games)
    # println()

end



"""
    Field Layout is a struct that holds the field information as a dataframe, 
    as well as a distance matrix for the fields relationship between each other.

Accessible Fields are:

    fieldDF::DataFrame
    distanceMatrix::Array{Float64}
    distanceMax::Float64
"""
mutable struct fieldLayout
    fieldDF::DataFrame
    distanceMatrix::Array{Float64}
    distanceMax::Float64
end

struct changeLog
    date::DateTime
    initalVal
    changedVal
end


"""
This is the wider Swiss Draw objects. All exposed actions need to work on this object.

accessible fields are:  

    initialRanking::DataFrame  
    layout::fieldLayout  
    bye::Symbol  
    currentRound::RoundOfGames  
    previousRound::Array{RoundOfGames}  

"""
mutable struct SwissDraw

    initialRanking::DataFrame
    layout::fieldLayout
    bye::Symbol

    currentRound::RoundOfGames
    previousRound::Array{RoundOfGames}

    AllChanges::Array{changeLog}

end


function Base.show(io::IO, z::SwissDraw) 

    println()
    println(io,"This Swiss draw contains ", size(z.initialRanking,1), " teams" )
    println()

    if size(z.previousRound) != 0 
        show.(io,z.previousRound)
    end


    println()
    println(io, "The current/next round is" )
    show(io,z.currentRound)
    # println()
    
    
end


# typeof(x)

### Creator functions for these custom structures.

"""
Takes an inital ranking od teams, a list of fields and their XY coordinates, and the bye location (:First, :Middle, :Last)
and returns a swiss draw object.
"""
function createSwissDraw(_initialRanking::DataFrame,_fieldDF::DataFrame,_bye::Symbol=:middle)

    _fieldlayout = createFieldLayout(_fieldDF::DataFrame)
    currentRound = CreateFirstRound(_initialRanking,_fieldlayout,_bye)

    swissDraw = SwissDraw(_initialRanking,_fieldlayout,_bye,currentRound,Array{RoundOfGames}[],Array{changeLog}[])
    return swissDraw

end


"""
createFieldLayout(_fieldDF::DataFrame)

    This function creates a field layout object from a dataframe. 
    The dataframe must have the following cols:
        number::Int64
        x::Int64
        y::Int64
        stream::Bool

"""
function createFieldLayout(_fieldDF::DataFrame)

    fieldN = size(sort(_fieldDF,:number),1)
    
    _distanceM = zeros(fieldN,fieldN)
    for i in 1:fieldN
        for j in 1:fieldN
    
            _distanceM[i,j] = sqrt((_fieldDF.x[i]-_fieldDF.x[j])^2 + (_fieldDF.y[i]-_fieldDF.y[j])^2)
    
        end 
    end
    _distMax = maximum(_distanceM)

    return fieldLayout(_fieldDF,_distanceM,_distMax)
end
# x = createFieldLayout(_fieldDF)


function CreateFirstRound(_df::DataFrame,_fieldLayout::fieldLayout,bye::Symbol=:middle)
    # function CreateFirstRound(_df::DataFrame,fieldDataFrame::DataFrame,bye::Symbol=:middle)

    df = deepcopy(_df)
    sort!(df,:rank)
    field_df = deepcopy(select(_fieldLayout.fieldDF,[:number,:stream]))


    g = Game[]
    # first check if df is odd:
    if isodd(size(df,1))
   
        if bye == :middle
            ind = Int(ceil(size(df,1)/2))

            # add the bye to the byegame object
            byeGame = Game(String(df[ind,:].team),"BYE",0,15,0,false)
            push!(g,byeGame)
            # and RM the team
            deleteat!(df,ind)

        end
        if bye == :first
            ind = 1

            # add the bye to the byegame object
            byeGame = Game(String(df[ind,:].team),"BYE",0,15,0,false)
            push!(g,byeGame)
            # and RM the team
            deleteat!(df,ind)
            
        end
        if bye == :last
            ind = size(df,1)

            # add the bye to the byegame object
            byeGame = Game(String(df[ind,:].team),"BYE",0,15,0,false)
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

    sort!(pairings,:_rank_match, rev=true)


    fdf = first(sort!(field_df,:stream, rev = true), size(pairings,1))

    finalPairing = hcat(pairings,fdf)


    # ok, now we have pairings, we can assign the streamed games
            
    

    for i in eachrow(finalPairing)
        push!(g, Game(i.team_left, i.team_right, i.number, missing, missing, i.stream))
    end

    NextRound = RoundOfGames(g,1) # create a nextround object from the list of games.
    return NextRound;

end

# CreateFirstRound(_df::DataFrame,fieldDataFrame::DataFrame,bye::Symbol=:middle)



### These are Utility functions that help along the way






"""
extend_to_n(matrix, n)
takes a 2 dimensional matrix and returns a 3 dimensional matrix, 
with the third dimension being the size of n. 

each 'slice' is the original matrix

ie 
extend_to_n([1], n)

1x1x2 Array{Int64, 3}:
[:, :, 1] =
 1 2

[:, :, 2] =
 1 2
"""
function extend_to_n(matrix::AbstractArray, n)
    return cat([matrix for _ in 1:n]..., dims=3)
end
# extend_to_n([1 2], 2)


# I think I need an object to hold the field information, as well as the dist matrix
"""
    teamStrengths(rounds::Array{RoundOfGames})
    this gets the 'strength' of each team, based on how everyone has perfomred and based on the margins 
"""
function teamStrengths(rounds::Array{RoundOfGames})

    # create a dataframe from the gamesplayed to get an overview of the situation
    df  = DataFrame(teamA = String[], teamB = String[],margin=Int[], teamAscore = Int[],teamBscore = Int[])
    
    for j in rounds
        for i in j.Games
            push!(df, (i.teamA, i.teamB,coalesce(i.teamAScore-i.teamBScore,0),coalesce(i.teamAScore,0),coalesce(i.teamBScore,0)), promote=true)
        end
    end

    teams = unique(vcat(df.teamA,df.teamB))

    # get the matrix of games played to teams
    A = indicatormat(df.teamA,teams) .+ indicatormat(df.teamB,teams) .*-1

    # get the margins of the games
    b = reshape(df.margin,1,length(df.margin))
    
    # find the strengths from this
    s = b * pinv(A)

    # convert into vector and round
    s2 = float.(round.(s[1,:],digits=5))
    
    # push out as DF
    strengthdf = DataFrame(strength = s2, team = teams)
    sort!(strengthdf,:strength,rev = true)

    return strengthdf

end


# """
#     rankings(gamesPlayed::Vector{Game})

# This takes a vector of Games, and returns a ranking dataframe based on the games that have been played thus far. 
# """

# function rankings(gamesPlayed::RoundOfGames)

#     # create a dataframe from the gamesplayed to get an overview of the situation
#     df  = DataFrame(teamA = String[], teamB = String[],margin=Int[], teamAscore = Int[],teamBscore = Int[],stream=Bool[],val = Int[])

#     # allTeams = String[]
    
#     for i in gamesPlayed.Games
#         push!(df, (i.teamA, i.teamB,coalesce(i.teamAScore-i.teamBScore,0),coalesce(i.teamAScore,0),coalesce(i.teamBScore,0),i.streamed,1 ), promote=true)
#         push!(df, (i.teamB, i.teamA,coalesce(i.teamBScore-i.teamAScore,0),coalesce(i.teamBScore,0),coalesce(i.teamAScore,0),i.streamed,-1), promote=true)

    
#     end

        

#     # deduce some stats.
#     df.winA = Int.(coalesce.(df.teamAscore,0) .> coalesce.(df.teamBscore,0))
#     df.lossA = Int.(coalesce.(df.teamAscore,0) .< coalesce.(df.teamBscore,0))
#     df.drawA = Int.(coalesce.(df.teamAscore,0) .== coalesce.(df.teamBscore,0))
#     df.byeA = Int.(df.teamB .== "BYE")
#     df.played = Int.(df.teamB .!= "BYE")
#     df.streamed = Int.(df.stream)

#     # and create the ranking from WL
#     df.modified_margin = 3*df.winA .+ df.drawA

#     # combine the rankings by team
#     rankingsDf = combine(
#             groupby(df,:teamA),
#                             [:modified_margin,:margin,:played,:winA,:lossA,:drawA,:streamed] 
#                 .=> sum .=> [:modified_margin,:margin,:played,:winA,:lossA,:drawA,:streamed] 
#                 )

#     sort!(rankingsDf,[:modified_margin,:margin], rev = true)

#     rankingsDf.rank = collect(1:size(rankingsDf,1))

#     return rankingsDf
# end

function allRankings(_swissDraw::SwissDraw)

    # create a dataframe from the gamesplayed to get an overview of the situation
    df  = DataFrame(teamA = String[], teamB = String[],margin=Int[], teamAscore = Int[],teamBscore = Int[],stream=Bool[],val = Int[])

    for i in _swissDraw.currentRound.Games
        push!(df, (i.teamA, i.teamB,coalesce(i.teamAScore-i.teamBScore,0),coalesce(i.teamAScore,0),coalesce(i.teamBScore,0),i.streamed,1 ), promote=true)
        push!(df, (i.teamB, i.teamA,coalesce(i.teamBScore-i.teamAScore,0),coalesce(i.teamBScore,0),coalesce(i.teamAScore,0),i.streamed,-1), promote=true)
    end

    # allTeams = String[]
    
    for j in _swissDraw.previousRound
        for i in j.Games
            push!(df, (i.teamA, i.teamB,coalesce(i.teamAScore-i.teamBScore,0),coalesce(i.teamAScore,0),coalesce(i.teamBScore,0),i.streamed,1 ), promote=true)
            push!(df, (i.teamB, i.teamA,coalesce(i.teamBScore-i.teamAScore,0),coalesce(i.teamBScore,0),coalesce(i.teamAScore,0),i.streamed,-1), promote=true)
        end
    end

    # deduce some stats.
    df.winA = Int.(coalesce.(df.teamAscore,0) .> coalesce.(df.teamBscore,0))
    df.lossA = Int.(coalesce.(df.teamAscore,0) .< coalesce.(df.teamBscore,0))
    df.drawA = Int.(coalesce.(df.teamAscore,0) .== coalesce.(df.teamBscore,0))
    df.byeA = Int.(df.teamB .== "BYE")
    df.played = Int.(df.teamB .!= "BYE")
    df.streamed = Int.(df.stream)

    # and create the ranking from WL
    df.modified_margin = 3*df.winA .+ df.drawA

    # combine the rankings by team
    rankingsDf = combine(
            groupby(df,:teamA),
                            [:modified_margin,:margin,:played,:winA,:lossA,:drawA,:byeA,:streamed] 
                .=> sum .=> [:modified_margin,:margin,:played,:winA,:lossA,:drawA,:byeA,:streamed] 
                )

    # and get the strengths based off of linear algebra
    strength = teamStrengths(vcat(_swissDraw.previousRound,_swissDraw.currentRound))
    rename!(strength,:team => :teamA)

    leftjoin!(rankingsDf,strength,on = :teamA)

    # sort!(rankingsDf,[:modified_margin,:margin], rev = true)
    sort!(rankingsDf,:strength, rev = true)

    rankingsDf.rank = collect(1:size(rankingsDf,1))

    return rankingsDf
end


"""
prevRoundsRankings(_swissDraw::SwissDraw)

    Similar to allRankings(_swissDraw::SwissDraw), but only finds the rankings for previous rounds. 
    The current round is excluded. This should be used in the context of refreshing the draw if an error 
    is discovered (and updated) in the prior rounds  

"""
function prevRoundsRankings(_swissDraw::SwissDraw)

    # create a dataframe from the gamesplayed to get an overview of the situation
    df  = DataFrame(teamA = String[], teamB = String[],margin=Int[], teamAscore = Int[],teamBscore = Int[],stream=Bool[],val = Int[])
    
    for j in _swissDraw.previousRound
        for i in j.Games
            push!(df, (i.teamA, i.teamB,coalesce(i.teamAScore-i.teamBScore,0),coalesce(i.teamAScore,0),coalesce(i.teamBScore,0),i.streamed,1 ), promote=true)
            push!(df, (i.teamB, i.teamA,coalesce(i.teamBScore-i.teamAScore,0),coalesce(i.teamBScore,0),coalesce(i.teamAScore,0),i.streamed,-1), promote=true)
        end
    end


    # deduce some stats.
    df.winA = Int.(coalesce.(df.teamAscore,0) .> coalesce.(df.teamBscore,0))
    df.lossA = Int.(coalesce.(df.teamAscore,0) .< coalesce.(df.teamBscore,0))
    df.drawA = Int.(coalesce.(df.teamAscore,0) .== coalesce.(df.teamBscore,0))
    df.byeA = Int.(df.teamB .== "BYE")
    df.played = Int.(df.teamB .!= "BYE")
    df.streamed = Int.(df.stream)

    # and create the ranking from WL
    df.modified_margin = 3*df.winA .+ df.drawA

    # combine the rankings by team
    rankingsDf = combine(
            groupby(df,:teamA),
                            [:modified_margin,:margin,:played,:winA,:lossA,:drawA,:byeA,:streamed] 
                .=> sum .=> [:modified_margin,:margin,:played,:winA,:lossA,:drawA,:byeA,:streamed] 
                )


    # and get the strengths based off of linear algebra
    strength = teamStrengths(_swissDraw.previousRound)
    rename!(strength,:team => :teamA)

    leftjoin!(rankingsDf,strength,on = :teamA)

    # sort!(rankingsDf,[:modified_margin,:margin], rev = true)
    sort!(rankingsDf,:strength, rev = true)


    rankingsDf.rank = collect(1:size(rankingsDf,1))

    return rankingsDf
end

"""
Takes a lookup table of distance matrix, and 
returns the distance between x and y from that matrix
"""
function prevDistance(x,y,distanceM)
    return distanceM[x,y]
end
# prevDistance(1,10,distanceM)


"""
This takes a inital value to mutate and two values to switch around. 
If the inital value to mutate is the either of the values to swithc value, then it takes the other value.
if the value to mutate is not in either of the two values then it is unchanged

for example:
    switchVals!("a",["a","b"]) == "b"
    switchVals!("C",["a","b"]) == "C"

"""
function switchVals!(val,possibleVals::AbstractArray)
    # @assert size(possibleVals,1) == 2 && size(unique(possibleVals),1) == 2 "you can only switch two values "

    if val == possibleVals[1]
        val = possibleVals[2]
        # return
    elseif val == possibleVals[2]
        val = possibleVals[1]
        # return
    end
    return val
end

function ifZeroThenOne(x::Number)
    if x == 0
        return 1
    else
        return x
    end
end


# ok, so now we want mutation functions. ie to update/add outcome of a game. 
"""
updateScore!(_SwissDraw, _teamA::String, _teamB::String, _teamAScore::Int64, _teamBScore::Int64,round=missing)
    This updates a score if the teams are present in the round, or prints a warning. 
    if the team has already been updated, the score is not changed.  
    
    By default this will modify the latest round. 
    specifiying a round number will attempt to change that round
    
"""
function updateScore!(_SwissDraw, _teamA::String, _teamB::String, _teamAScore::Int64, _teamBScore::Int64,_round=missing)

    
    Round2Change = []

    # Check to see if we are changing the current round or a previous round
    if ismissing(_round)
        Round2Change = _SwissDraw.currentRound.Games
    else
        Round2Change =  filter(x->x.roundNumber == _round,_SwissDraw.previousRound )[1].Games

        if size(Round2Change,1) == 0 
            println("Round $round not found")
            return
        end

        println("Modifying Round $round")
    end

    game2Update = filter(x->x.teamA == _teamA && x.teamB == _teamB,Round2Change)

    if size(game2Update,1) != 1 
        println("The teams $_teamA and $_teamB don't seem to be playing each other this round")
        println("")
        println.("  ",_SwissDraw.currentRound.Games)
        println("")

        return
    end

    

    if  (coalesce(game2Update[1].teamAScore,0) == coalesce(_teamAScore) && coalesce(game2Update[1].teamBScore,0) == coalesce(_teamBScore)) 
        println("No changes to the score detected")
        println("")
        println(game2Update)
        println("")
        return
    end

    oldGame = deepcopy(game2Update)

    


    game2Update[1].teamAScore = _teamAScore
    game2Update[1].teamBScore = _teamBScore

    println("You've updated this game:")  
    println("Previously it was: ",oldGame)  
    # println(oldGame)
    println("Now it is: ",game2Update)  
    # println(game2Update)
    println()

    change = changeLog(Dates.now(),oldGame,game2Update)
    push!(_SwissDraw.AllChanges,change)

    return
end
"""
Simple way to update a game from in  the current round based off of the index
"""
function updateScore!(_SwissDraw, gameIndex::Int, _teamAScore::Int64, _teamBScore::Int64,_round=missing)

    Round2Change = []

    if ismissing(_round)
        Round2Change = _SwissDraw.currentRound
    else
        Round2Change =  filter(x->x.roundNumber == _round,_SwissDraw.previousRound )[1]

        if size(Round2Change.Games,1) == 0 
            println("Round $round not found")
            return
        end

        println("Modifying Round $round")
    end

    # game2Update = _SwissDraw.currentRound.Games[gameIndex]
    game2Update = Round2Change.Games[gameIndex]
    
    oldGame = deepcopy(game2Update)

    game2Update.teamAScore = _teamAScore
    game2Update.teamBScore = _teamBScore

    println("You've updated this game:")  
    println("Previously it was: ",oldGame)  
    # println(oldGame)
    println("Now it is: ",game2Update)  
    # println(game2Update)
    println()

end

# Draw = createSwissDraw(DataFrame(CSV.File(_teamPath)),DataFrame(CSV.File(_fieldPath)))

# Draw.currentRound.Games[1]
# updateScore!(Draw,1,1,2)

function SwitchTeams!(_SwissDraw, _teamA::String, _teamB::String,_round=missing)

    teamsToSwitch = [_teamA,_teamB]

    Round2Change = []

    # Check to see if we are changing the current round or a previous round
    if ismissing(_round)
        Round2Change = _SwissDraw.currentRound.Games
    else
        # Round2Change =  filter(x->x.roundNumber == _round,_SwissDraw.previousRound )[1].Games
        Round2Change = _SwissDraw.previousRound[_round].Games

        if size(Round2Change,1) == 0 
            println("Round $round not found")
            return
        end

        println("Modifying Round $round")
    end
    games2Mod = filter(x->x.teamA in Set(teamsToSwitch) || x.teamB in Set(teamsToSwitch) ,Round2Change)


    if issubset(teamsToSwitch,_SwissDraw.initialRanking.team) == false
        println("Something is cooked with your teams")
        println("There are your teams:", )
        println.(teamsToSwitch)
        println()
        println("Teams in the draw:")
        println.(_SwissDraw.initialRanking.team)
        println("")

        return
    end

    if size(games2Mod,1) == 1 
        println("The two teams are already playing each Other: ")
        println(games2Mod)
        return
    end
    if size(games2Mod,1) > 2
        println("The two teams appear more than once: ")
        println(games2Mod)
        return
    end
    if size(games2Mod,1) == 0
        println("Neither of the two teams seem to exist: ")
        println(teamsToSwitch)
        println(Draw.currentRound.Games)
        return
    end

    premod = deepcopy(games2Mod)

    for i in games2Mod
    
        i.teamA = switchVals!(i.teamA,teamsToSwitch)
        i.teamB = switchVals!(i.teamB,teamsToSwitch)

        i.teamAScore = missing
        i.teamBScore = missing
        
    
    end

    println("The following two teams have been switched: $_teamA, $_teamB")
    println("Note that the scores have been reset to zero")
    println()
    println("The previous matchup was:")
    println(premod)
    println()
    println("The new Matchup is: ")
    println(games2Mod)
    println("")

    change = changeLog(Dates.now(),premod,games2Mod)
    push!(_SwissDraw.AllChanges,change)
    return
end
# SwitchTeams!(Draw,"Whakatu","Luminance",1)


function switchFields!(_SwissDraw, _field1::Int, _field2::Int,_round=missing)

    fields2Switch = [_field1,_field2]

    Round2Change = []

    # Check to see if we are changing the current round or a previous round
    if ismissing(_round)
        Round2Change = _SwissDraw.currentRound.Games
    else
        Round2Change =  filter(x->x.roundNumber == _round,_SwissDraw.previousRound )[1].Games

        if size(Round2Change,1) == 0 
            println("Round $round not found")
            return
        end

        println("Modifying Round $_round")
    end

    
    println("The teams playing on fields $_field1 and $_field2 have been switched")

    OldGame = deepcopy(filter(x->x.fieldNumber in Set(fields2Switch) ,Round2Change))

    # And switch em up 
    for i in Round2Change
        i.fieldNumber = switchVals!(i.fieldNumber,fields2Switch)
    end

    newGames = filter(x->x.fieldNumber in Set(fields2Switch) ,Round2Change)

    println.("New roster is: ", )
    println.(newGames)
    println()

    change = changeLog(Dates.now(),OldGame,newGames)
    push!(_SwissDraw.AllChanges,change)
    return


end




"""
This function is the meat of the swiss draww. It takes a list of previous games, and the bye indicator, 
It calculates the rankings, and looks at prior games.
it calculates who is next best to play each other in the next round, based on the score of previous games.

It returns a nextRound objects that are games to be played

it takes into consideration prior games, so that teams do no play each other more than once, 
and prior byes, so that a single team won't have more than one bye. 

If there are an odd number of teams, the bye position decides if it goes to the first rank,
bottom ranked, or middle ranked team, first taking into consideration the the points above.
"""
# function CreateNextRound(prevGames::Vector{Game},_fieldLayout::fieldLayout ,bye::Symbol=:middle)
function CreateNextRound!(_SwissDraw)
    
    # dump(_SwissDraw)

    _currentRound = _SwissDraw.currentRound
    _fieldLayout = _SwissDraw.layout
    bye = _SwissDraw.bye
    # prevGames = firstRound
    # fieldDataFrame = deepcopy(_fieldDF)
    # _fieldLayout.fieldDF
    fdf = deepcopy(_fieldLayout.fieldDF)
    bye = :middle
    df = allRankings(_SwissDraw)

    show(df)
    # get previous locations
    prevField = DataFrame(team=String[],fieldNumber=Int[])

    for i in _currentRound.Games

        push!(prevField,(i.teamA,i.fieldNumber))
        push!(prevField,(i.teamB,i.fieldNumber))

    end

    prevField

    g = Game[]

    # # ok, so now we need to find the best combination of pairs where they haven't played prior.
    sort!(df,:teamA,rev=true)



    # We also need a distance matrix between fields
    sort!(fdf,:number)
    # fieldN = size(fdf,1)



    # This is just linear algebra?
    # lets make some cost matricies

    # so in order for these to all work well together, you need to make them different orders of magnitude
    # for example, we don't want team location to effect the draw, so we make it 10x smaller than the rank

    teamSz = size(df,1)
    fieldSz = size(fdf,1)

    costMatchup = zeros(teamSz,teamSz,fieldSz) # mag ~10^1
    costSelfMatchup = zeros(teamSz,teamSz,fieldSz) # mag ~10^6
    costAnotherBye = zeros(teamSz,teamSz,fieldSz) # mag ~10^3
    costSelectBye = zeros(teamSz,teamSz,fieldSz) # mag ~10^1
    costStream = zeros(teamSz,teamSz,fieldSz) # mag ~5^1
    costPrevField = zeros(teamSz,teamSz,fieldSz) # mag ~1^1
    # costM = zeros(sz,sz)

    for i in 1:teamSz
        for j in 1:teamSz
            for k in 1:fieldSz

                # This makes large matchups more costly
                costMatchup[i,j,k] = max(abs.(df.rank[i] - df.rank[j]))*10


                # # This stops teams from playing themself
                if i == j 
                    costSelfMatchup[i,j,k] = 1000000
                end


                # This prevents teams that have had a bye from having another one
                if ((df.teamA[i]=="BYE" && df.byeA[j]==1 ) || (df.teamA[j]=="BYE" && df.byeA[i]==1 ))
                    costAnotherBye[i,j,k] = 1000
                end


                # If none of the teams have had a streamed game, make it likely that they get one,
                # else make team pairings with a streamed game unlikely to not get it. 

            if fdf.stream[k] == true 
                    if df.streamed[i] + df.streamed[j] == 0
                        # incentivise lower teams to get streams 

                        # this should be thought over later, as its a bit poos
                        costStream[i,j,k] = ((teamSz - max(df.rank[i],df.rank[j])) / teamSz) -1
                    else 
                        costStream[i,j,k] = 10
                    end

                # then if its not a streamed field, we don't mind too much, but would like 
                # to play teams that have had at least one stream if we can, so we don't 
                # kill potential pairings for the next round
                elseif fdf.stream[k] == false
                    if df.streamed[i] + df.streamed[j] == 1
                        costStream[i,j,k] = 0
                    else
                        costStream[i,j,k] = 1
                    end
                end



                # this minimises the distance teams have to walk.
                # so for each (team x team x field combo), we look at the prev two fields, 
                # and assign a cost to it based on the mean distance the teams have to move

                costPrevField[i,j,k] = prevDistance(
                    ifZeroThenOne(prevField.fieldNumber[findfirst(x->x== df.teamA[i] ,prevField.team)]),
                    ifZeroThenOne(prevField.fieldNumber[findfirst(x->x== df.teamA[j] ,prevField.team)]),
                    _fieldLayout.distanceMatrix) / _fieldLayout.distanceMax


                ## and add a cost for where the bye might go based on rank
                ## the following code explains the rankings

                # n = collect(1:14)
                # szN = size(n,1)
                # # top.  want it to get progressively larger from 1
                # # we can literally just use the rank
                # n
                # # for last, we want to start large and get smaller 
                # sz +1 .- n
                # # for middle, we want to start small and get larger
                # abs.(szN/2 .- n)

                if bye == :middle 
                    if df.teamA[i]=="BYE" 
                        costSelectBye[i,j,k] = abs.(size(df.rank,1)/2 .- df.rank[j])*10

                    elseif df.teamA[j]=="BYE" 
                        costSelectBye[i,j,k] = abs.(size(df.rank,1)/2 .- df.rank[i])*10
                    end

                elseif bye == :first 
                    if df.teamA[i]=="BYE" 
                        costSelectBye[i,j,k] = df.rank[j]*10

                    elseif df.teamA[j]=="BYE" 
                        costSelectBye[i,j,k] = df.rank[i]*10
                    end

                elseif bye == :last 
                    if df.teamA[i]=="BYE" 
                        costSelectBye[i,j,k] = df.rank[j]*10

                    elseif df.teamA[j]=="BYE" 
                        costSelectBye[i,j,k] =  size(df.rank,1) +1 .- df.rank[i]*10
                    end
                end
            end
        end
    end

    costStream
    # costSelectBye
    costPrevField




    # and now find the matrix of previous plays 
    prevGameDf = DataFrame(teamA = String[],teamB = String[])
    for i in _currentRound.Games

        push!(prevGameDf,(i.teamA,i.teamB))
        push!(prevGameDf,(i.teamB,i.teamA))

    end


    sort!(prevGameDf,:teamA)
    prevGameDf.exclude .= 1000

    # ok so we remove the and games that are not being played
    score_df = unstack(prevGameDf, :teamA, :teamB, :exclude,fill = 0)
    sort!(filter!(x->(x.teamA ∈ df.teamA ) , score_df),:teamA,rev=true)

    # this ensures that the matrix is ordered alphabetically
    prevGamesM = Matrix(select(score_df,score_df.teamA))

    # make it include the field dimension so that we can add it to the rest
    allPrevGamesM = extend_to_n(prevGamesM, fieldSz)



    allM = 
        costMatchup .+ 
        costSelfMatchup .+ 
        costSelfMatchup .+ 
        costAnotherBye .+ 
        costStream .+ 
        costPrevField .+ 
        costSelectBye .+ 
        prevGamesM

        # allM
    # and now we can pump this into a linear algebra solver to find the best combo

    # model = Model(COSMO.Optimizer)
    # model = Model(Cbc.Optimizer)

    println("begining solver")

    # model = Model(GLPK.Optimizer, add_bridges = false)
    model = Model(EAGO.Optimizer)


    @variable(model,possibleGames[1:teamSz,1:teamSz,1:fieldSz],Bin)
    # @variable(model, x[1:m, 1:n], Bin);


    # These constraints ensure that teams only play once. 
    @constraint(model, teamA[i = 1:teamSz], sum(possibleGames[i, j, k] for j in 1:teamSz, k in 1:fieldSz) == 1)
    @constraint(model, teamB[j = 1:teamSz], sum(possibleGames[i, j, k] for i in 1:teamSz, k in 1:fieldSz) == 1)

    # this ensures that both teams play each other, else it might try A => B and then B => C
    @constraint(model, parity[i = 1:teamSz, j = 1:teamSz, k = 1:fieldSz], possibleGames[i, j, k] == possibleGames[j, i, k])

    # this makes sure that fields are not played on by more than 2 teams 
    @constraint(model, fields[k = 1:fieldSz], sum(possibleGames[i, j, k] for i in 1:teamSz, j in 1:teamSz) <= 2)


    # we want the minimum difference in matchups
    @objective(model,Min,sum(allM .* possibleGames ));
    model

    # set_attribute(model, "presolve", GLPK.GLP_OFF)

    optimize!(model)

    summary = solution_summary(model,verbose=true)

    @show summary.:raw_status
    @show summary.:objective_value
    # Create dataframe to get values back out

    # find all the positions where 1 
    pos = findall(x->x==1,value.(possibleGames))

    schedule = DataFrame(teamA = String[], teamB = String[], field = Int[], rankA = Int[], rankB = Int[], stream = Bool[])

    for i in pos
        push!(schedule,(df.teamA[i[1]], df.teamA[i[2]], fdf.number[i[3]], df.rank[i[1]], df.rank[i[2]] , fdf.stream[i[3]] ))
    end
    schedule


    if size(filter(x->x.teamA == x.teamB,schedule),1) > 0
        @warn "One or more Teams have been paired with themself"
    end

    _teams = String[] 
    g 
    schedule
    for i in eachrow(schedule)

        if i.teamA ∉ _teams
            push!(g,Game(i.teamA,i.teamB,i.field,missing,missing,i.stream))
            push!(_teams,i.teamA)
            push!(_teams,i.teamB)
        end
    end

    # also need to find the current round number.

    
    # And now we overwrite the swiss draw bits and bobs with the new information.
    # NextRound = nextRound(g) # create a nextround object from the list of games.
    NextRound = RoundOfGames(g,_SwissDraw.currentRound.roundNumber+1)

    push!(_SwissDraw.previousRound,_SwissDraw.currentRound)
    _SwissDraw.currentRound = NextRound
    # return NextRound;

end





"""
    This function is the meat of the swiss draw. Similar to createnextRound(), but it takes the 
    previously rounds only into account. 
"""
function refreshNextRound!(_SwissDraw)

    println("Begining Preprocessing")
    
    _currentRound = _SwissDraw.currentRound
    _fieldLayout = _SwissDraw.layout
    bye = _SwissDraw.bye
    # prevGames = firstRound
    # fieldDataFrame = deepcopy(_fieldDF)
    # _fieldLayout.fieldDF
    fdf = deepcopy(_fieldLayout.fieldDF)
    bye = :middle
    df = prevRoundsRankings(_SwissDraw)

    # get previous locations
    prevField = DataFrame(team=String[],fieldNumber=Int[])

    for i in _currentRound.Games

        push!(prevField,(i.teamA,i.fieldNumber))
        push!(prevField,(i.teamB,i.fieldNumber))

    end

    prevField

    g = Game[]

    # # ok, so now we need to find the best combination of pairs where they haven't played prior.
    sort!(df,:teamA,rev=true)



    # We also need a distance matrix between fields
    sort!(fdf,:number)
    # fieldN = size(fdf,1)



    # This is just linear algebra?
    # lets make some cost matricies

    # so in order for these to all work well together, you need to make them different orders of magnitude
    # for example, we don't want team location to effect the draw, so we make it 10x smaller than the rank

    teamSz = size(df,1)
    fieldSz = size(fdf,1)

    costMatchup = zeros(teamSz,teamSz,fieldSz) # mag ~10^1
    costSelfMatchup = zeros(teamSz,teamSz,fieldSz) # mag ~10^6
    costAnotherBye = zeros(teamSz,teamSz,fieldSz) # mag ~10^3
    costSelectBye = zeros(teamSz,teamSz,fieldSz) # mag ~10^1
    costStream = zeros(teamSz,teamSz,fieldSz) # mag ~5^1
    costPrevField = zeros(teamSz,teamSz,fieldSz) # mag ~1^1
    # costM = zeros(sz,sz)

    for i in 1:teamSz
        for j in 1:teamSz
            for k in 1:fieldSz

                # This makes large matchups more costly
                costMatchup[i,j,k] = max(abs.(df.rank[i] - df.rank[j]))*10


                # # This stops teams from playing themself
                if i == j 
                    costSelfMatchup[i,j,k] = 1000000
                end


                # This prevents teams that have had a bye from having another one
                if ((df.teamA[i]=="BYE" && df.byeA[j]==1 ) || (df.teamA[j]=="BYE" && df.byeA[i]==1 ))
                    costAnotherBye[i,j,k] = 1000
                end


                # If none of the teams have had a streamed game, make it likely that they get one,
                # else make team pairings with a streamed game unlikely to not get it. 

            if fdf.stream[k] == true 
                    if df.streamed[i] + df.streamed[j] == 0
                        # incentivise lower teams to get streams 

                        # this should be thought over later, as its a bit poos
                        costStream[i,j,k] = ((teamSz - max(df.rank[i],df.rank[j])) / teamSz) -1
                    else 
                        costStream[i,j,k] = 10
                    end

                # then if its not a streamed field, we don't mind too much, but would like 
                # to play teams that have had at least one stream if we can, so we don't 
                # kill potential pairings for the next round
                elseif fdf.stream[k] == false
                    if df.streamed[i] + df.streamed[j] == 1
                        costStream[i,j,k] = 0
                    else
                        costStream[i,j,k] = 1
                    end
                end



                # this minimises the distance teams have to walk.
                # so for each (team x team x field combo), we look at the prev two fields, 
                # and assign a cost to it based on the mean distance the teams have to move

                costPrevField[i,j,k] = prevDistance(
                    ifZeroThenOne(prevField.fieldNumber[findfirst(x->x== df.teamA[i] ,prevField.team)]),
                    ifZeroThenOne(prevField.fieldNumber[findfirst(x->x== df.teamA[j] ,prevField.team)]),
                    _fieldLayout.distanceMatrix) / _fieldLayout.distanceMax


                ## and add a cost for where the bye might go based on rank
                ## the following code explains the rankings

                # n = collect(1:14)
                # szN = size(n,1)
                # # top.  want it to get progressively larger from 1
                # # we can literally just use the rank
                # n
                # # for last, we want to start large and get smaller 
                # sz +1 .- n
                # # for middle, we want to start small and get larger
                # abs.(szN/2 .- n)

                if bye == :middle 
                    if df.teamA[i]=="BYE" 
                        costSelectBye[i,j,k] = abs.(size(df.rank,1)/2 .- df.rank[j])*10

                    elseif df.teamA[j]=="BYE" 
                        costSelectBye[i,j,k] = abs.(size(df.rank,1)/2 .- df.rank[i])*10
                    end

                elseif bye == :first 
                    if df.teamA[i]=="BYE" 
                        costSelectBye[i,j,k] = df.rank[j]*10

                    elseif df.teamA[j]=="BYE" 
                        costSelectBye[i,j,k] = df.rank[i]*10
                    end

                elseif bye == :last 
                    if df.teamA[i]=="BYE" 
                        costSelectBye[i,j,k] = df.rank[j]*10

                    elseif df.teamA[j]=="BYE" 
                        costSelectBye[i,j,k] =  size(df.rank,1) +1 .- df.rank[i]*10
                    end
                end
            end
        end
    end

    costStream
    # costSelectBye
    costPrevField




    # and now find the matrix of previous plays 
    prevGameDf = DataFrame(teamA = String[],teamB = String[])
    for i in _currentRound.Games

        push!(prevGameDf,(i.teamA,i.teamB))
        push!(prevGameDf,(i.teamB,i.teamA))

    end


    sort!(prevGameDf,:teamA)
    prevGameDf.exclude .= 1000

    # ok so we remove the and games that are not being played
    score_df = unstack(prevGameDf, :teamA, :teamB, :exclude,fill = 0)
    sort!(filter!(x->(x.teamA ∈ df.teamA ) , score_df),:teamA,rev=true)

    # this ensures that the matrix is ordered alphabetically
    prevGamesM = Matrix(select(score_df,score_df.teamA))

    # make it include the field dimension so that we can add it to the rest
    allPrevGamesM = extend_to_n(prevGamesM, fieldSz)



    allM = 
        costMatchup .+ 
        costSelfMatchup .+ 
        costSelfMatchup .+ 
        costAnotherBye .+ 
        costStream .+ 
        costPrevField .+ 
        costSelectBye .+ 
        prevGamesM

        # allM
    # and now we can pump this into a linear algebra solver to find the best combo

    # model = Model(COSMO.Optimizer)
    # model = Model(Cbc.Optimizer)



    println("Finished Preprocessing")
    println("...")
    println("...")
    println("Running Optimiser")

    model = Model(GLPK.Optimizer)

    @variable(model,possibleGames[1:teamSz,1:teamSz,1:fieldSz],Bin)
    # @variable(model, x[1:m, 1:n], Bin);


    # These constraints ensure that teams only play once. 
    @constraint(model, teamA[i = 1:teamSz], sum(possibleGames[i, j, k] for j in 1:teamSz, k in 1:fieldSz) == 1)
    @constraint(model, teamB[j = 1:teamSz], sum(possibleGames[i, j, k] for i in 1:teamSz, k in 1:fieldSz) == 1)

    # this ensures that both teams play each other, else it might try A => B and then B => C
    @constraint(model, parity[i = 1:teamSz, j = 1:teamSz, k = 1:fieldSz], possibleGames[i, j, k] == possibleGames[j, i, k])

    # this makes sure that fields are not played on by more than 2 teams 
    @constraint(model, fields[k = 1:fieldSz], sum(possibleGames[i, j, k] for i in 1:teamSz, j in 1:teamSz) <= 2)


    # we want the minimum difference in matchups
    @objective(model,Min,sum(allM .* possibleGames ));
    model

    # set_attribute(model, "presolve", GLPK.GLP_OFF)

    optimize!(model)

    summary = solution_summary(model,verbose=true)

    @show summary.:raw_status
    @show summary.:objective_value
    # Create dataframe to get values back out

    # find all the positions where 1 
    pos = findall(x->x==1,value.(possibleGames))

    schedule = DataFrame(teamA = String[], teamB = String[], field = Int[], rankA = Int[], rankB = Int[], stream = Bool[])

    for i in pos
        push!(schedule,(df.teamA[i[1]], df.teamA[i[2]], fdf.number[i[3]], df.rank[i[1]], df.rank[i[2]] , fdf.stream[i[3]] ))
    end
    schedule


    if size(filter(x->x.teamA == x.teamB,schedule),1) > 0
        @warn "One or more Teams have been paired with themself"
    end

    _teams = String[] 
    g 
    schedule
    for i in eachrow(schedule)

        if i.teamA ∉ _teams
            push!(g,Game(i.teamA,i.teamB,i.field,missing,missing,i.stream))
            push!(_teams,i.teamA)
            push!(_teams,i.teamB)
        end
    end

    # also need to find the current round number.

    
    # And now we overwrite the swiss draw bits and bobs with the new information.
    # NextRound = nextRound(g) # create a nextround object from the list of games.
    NextRound = RoundOfGames(g,_SwissDraw.currentRound.roundNumber+1)

    push!(_SwissDraw.previousRound,_SwissDraw.currentRound)
    _SwissDraw.currentRound = NextRound
    # return NextRound;

end


# Ok, so here we have some visualisation utilities:
function createArrow(x1,y1,x2,y2,barWidth=nothing,noseLength=nothing,arrowWidth=nothing)

    VectorLen = sqrt((x1-x2)^2 + (y1-y2)^2)
    UnitVector = ((x2-x1)/VectorLen , (y2-y1)/VectorLen)

    if isnothing(barWidth)
        barWidth = 1
    end

    if isnothing(noseLength)
        noseLength = 1
    end

    if isnothing(arrowWidth)
        arrowWidth = 2
    end

    poly = []

    push!(poly,Point2f(x2,y2))

    # Get the nose length, back from the tip, to find this midpoint
    ArrowMiddlePoint = (x2 - noseLength * UnitVector[1] , y2 - noseLength * UnitVector[2] ) 
    
    # println("Arrow from ($x1,$y1), ($x2,$y2)")
    # println("VectorLen = $VectorLen")
    # println("UnitVector = $UnitVector")
    # println("ArrowMiddlePoint = $ArrowMiddlePoint")

    perp = (-UnitVector[2],UnitVector[1])

    # get the arrowhead
    push!(poly, Point2f(ArrowMiddlePoint[1] - arrowWidth/2*perp[1], ArrowMiddlePoint[2] - arrowWidth/2*perp[2]))
    push!(poly, Point2f(ArrowMiddlePoint[1] - barWidth/2*perp[1], ArrowMiddlePoint[2] - barWidth/2*perp[2]))

    # get the tail of the arrowhead bar
    push!(poly, Point2f(x1 - barWidth/2*perp[1], y1 - barWidth/2*perp[2]))
    push!(poly, Point2f(x1 + barWidth/2*perp[1], y1 + barWidth/2*perp[2]))

    # and the other side of the arrowhead
    push!(poly, Point2f(ArrowMiddlePoint[1] + (barWidth/2)*perp[1], ArrowMiddlePoint[2] + (barWidth/2)*perp[2]))
    push!(poly, Point2f(ArrowMiddlePoint[1] + (arrowWidth/2)*perp[1], ArrowMiddlePoint[2] + (arrowWidth/2)*perp[2]))

    # and finish it off at the nose
    push!(poly,Point2f(x2,y2))

    # and make it point
    return Point2f.(poly)

end


function CreateStrengthChart(teamStats::DataFrame,minStrength,maxStrength)

    sort!(teamStats,:roundPlayed)

    f = Figure()

    t = teamStats.teamA[1]

    Axis(f[1, 1],
    title = "Strength changes for $t",
    xlabel = "Round",
    ylabel = "Strength calculation"
    )

    for i in eachrow(filter(x->x.roundPlayed > 0,teamStats))

        # Black Arrow is the change in strength
        # poly!(createArrow(i.roundPlayed + 0.5 ,i.prevStrengthA , i.roundPlayed+ 0.5 ,i.strengthA, 0.08,0.3,0.2), color = :Black, strokecolor = :black, strokewidth = 1)
        ablines!(teamStats.strengthAFinal[1] ,0, color = :gray, linestyle=:dash, linewidth=2)
        errorbars!(teamStats.roundPlayed, teamStats.prevStrengthB, teamStats.prevStrengthB .- teamStats.prevStrengthB, teamStats.strengthBFinal - teamStats.prevStrengthB , whiskerwidth = 10, direction = :y,color = :gray)

        # errorbars!(i.roundPlayed[2:end], i.prevStrengthB[2:end], i.prevStrengthB[2:end] .- i.prevStrengthB[2:end], i.strengthBFinal[2:end] .+ i.prevStrengthB[2:end] , whiskerwidth = 3, direction = :x)    
        if i.margin > 0  
            # Red Arrow is the actual Margin from the strength
            poly!(createArrow(i.roundPlayed - 0.15 ,i.prevStrengthB + 0.1, i.roundPlayed - 0.15 ,i.prevStrengthB + i.margin + 0.1, 0.08,0.3,0.2), color = :Green, strokecolor = :black, strokewidth = 1)
        else
            poly!(createArrow(i.roundPlayed - 0.15 ,i.prevStrengthB - 0.1, i.roundPlayed - 0.15 ,i.prevStrengthB + i.margin - 0.1, 0.08,0.3,0.2), color = :Red, strokecolor = :black, strokewidth = 1)
        end

    end

    lines!(teamStats.roundPlayed .+ 1,teamStats.strengthA,Legend = "Calculated Strength" )

    scatter!(teamStats.roundPlayed[2:end],teamStats.prevStrengthB[2:end] ,color = :blue, marker = :circle,  markersize = 15)
    text!(teamStats.roundPlayed, teamStats.prevStrengthB, text = teamStats.teamB) 

    r = maximum(teamStats.roundPlayed)

    # waterfall!(teamStats.margin[2:end], show_direction=true)
    limits!(0,r+3,floor(minStrength),ceil(maxStrength))


    elem_1 = [LineElement(color = :Blue, linestyle = nothing),]

    elem_2 = [LineElement(color = :gray, linestyle = nothing),]

    elem_3 = [PolyElement(color = :green, strokecolor = :green, strokewidth = 2,
            points =  createArrow(0.0,0.0,0,1,0.08,0.3,0.2) ),
            PolyElement(color = :Red, strokecolor = :Red, strokewidth = 2,
            points =  createArrow(0.5,1, 0.5,0, 0.08,0.3,0.2) )]

    elem_4 = MarkerElement(color = :blue, marker = :circle,  markersize = 15,
            strokecolor = :black)

    elem_5 = [LineElement(color = :gray, linestyle = :dash),]

    vline = :center

    if teamStats.strengthAFinal[1] >= 0 
        vline = :bottom
    else
        vline = :top
    end

    Legend(f[1,1],
        [elem_1, elem_5, elem_3, elem_4, elem_2],
        ["Strength Changes", "Final Strength ",  "Win/Loss Margin"," Opposition Strength", "Opposition Final Strength"],
        tellheight = false,
        tellwidth = false,
        halign = :right,
        valign = vline,

        margin = (10, 10, 10, 10),
        )

    return f
end


    # lets find the expected outcome
    function expectedOutcome(allRounds,teamA,teamB,round)

        teamAMargin = filter(x->x.team == teamA && x.round == round,allRounds)
        teamBMargin = filter(x->x.team == teamB && x.round == round,allRounds)

        if size(teamAMargin,1) == 1 && size(teamBMargin,1) == 1
            return (teamAMargin.strength[1] -teamBMargin.strength[1])
        else 
            return 0
        end
    end


    function GenerateStrengthCharts(_SwissDraw,path)

        # Get the strengths calculated at the end of each round
        roundNumber = _SwissDraw.currentRound.roundNumber -1 
    
        allStrengths = DataFrame()
    
        for i in 1:roundNumber
    
            df = teamStrengths(filter(x-> x.roundNumber <= i, _SwissDraw.previousRound))
            df.round .= i
            df.rank = 1:size(df,1)
    
            append!(allStrengths,df)
    
        end
    
        # ok, so I want to get all games played as a df
        rounds = _SwissDraw.previousRound
        _SwissDraw.initialRanking
        # create a dataframe from the gamesplayed to get an overview of the situation
        prevGames  = DataFrame(teamA = String[], teamB = String[],margin=Int[], teamAscore = Int[],teamBscore = Int[], roundPlayed =Int[], field = Int[], streamed = Bool[])
    
        # I also want both games on each side to make it easier
    
        for j in rounds
            for i in j.Games
                push!(prevGames, (i.teamA, i.teamB,coalesce(i.teamAScore-i.teamBScore,0),coalesce(i.teamAScore,0),coalesce(i.teamBScore,0),j.roundNumber, i.fieldNumber,i.streamed ), promote=true)
                push!(prevGames, (i.teamB, i.teamA,coalesce(i.teamBScore-i.teamAScore,0),coalesce(i.teamBScore,0),coalesce(i.teamAScore,0),j.roundNumber, i.fieldNumber,i.streamed ), promote=true)
            end
        end
    
        for i in eachrow(_SwissDraw.initialRanking)
            push!(prevGames, (i.team, "",0,0,0,0,0,false), promote=true)
        end
    
    
        prevGames.expectededMarginA .= 0.0
        prevGames.expectededMarginB .= 0.0
    
        for i in eachrow(prevGames)
    
            i.expectededMarginA = expectedOutcome(allStrengths,i.teamA ,i.teamB,i.roundPlayed - 1)
            i.expectededMarginB = expectedOutcome(allStrengths,i.teamB ,i.teamA,i.roundPlayed - 1)
    
        end
    
        prevGames
        allStrengths
    
        # now we join strengths on 
        # This would be better in sql
    
        leftjoin!(
            prevGames,
            rename(allStrengths,:strength=>:strengthA, :rank => :rankA),
            on = [:teamA => :team, :roundPlayed => :round],
        )
    
        leftjoin!(
            prevGames,
            rename(allStrengths,:strength=>:strengthB, :rank => :rankB),
            on = [:teamB => :team, :roundPlayed => :round],
        )
    
        leftjoin!(
            prevGames,
            rename(filter(x->x.round == maximum(allStrengths.round), allStrengths),:strength=>:strengthAFinal, :rank => :rankAFinal),
            on = [:teamA => :team],
        )
    
        leftjoin!(
            prevGames,
            select(rename(filter(x->x.round == maximum(allStrengths.round), allStrengths),:strength=>:strengthBFinal, :rank => :rankBFinal),Not(:round)),
            on = [:teamB => :team],
        )
    
        # allStrengths
        # and now get previous strengths
        allStrengths.round = allStrengths.round .+ 1
        leftjoin!(
            prevGames,
            rename(allStrengths,:strength=>:prevStrengthB, :rank => :prevRankB),
            on = [:teamB => :team, :roundPlayed => :round],
        )
    
        # and now get previous strengths
        leftjoin!(
            prevGames,
            rename(allStrengths,:strength=>:prevStrengthA, :rank => :prevRankA),
            on = [:teamA => :team, :roundPlayed => :round],
        )
    
    
    
        prevGames
        allStrengths
    
        prevGames.roundPlayedP1 = prevGames.roundPlayed .+ 0.5
    
        prevGames = coalesce.(prevGames, 0.0)
    
        teamStats = filter(x->x.teamA == "Mount", prevGames )
    
        teamStats.yend = teamStats.strengthB .+ teamStats.margin
    
    
        sort!(teamStats,:roundPlayed)
    
    
        maxStrength = maximum((prevGames.prevStrengthA .+ prevGames.margin)) 
        minStrength = minimum((prevGames.prevStrengthA .+ prevGames.margin))
    
        u = unique(prevGames.teamA)
        for team in u
    
            save("$path\\strength changes $team.png",CreateStrengthChart(filter(x->x.teamA == team, prevGames ), minStrength, maxStrength))
    
        end
        return prevGames
    end


