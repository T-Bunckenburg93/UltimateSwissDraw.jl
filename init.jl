using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
Pkg.instantiate();
Pkg.status();

using DataFrames, JuMP

# Init some sample data for testing and development

_teams = String[
    "Scuba Doos",
    "Green Mambas",
    "Quill",
    "Beyblades",
    "HighSchool",
    "Cultimate",
    "Big2",
    "squid",
    "Royals",
    "Force",
    "Crew",
    "QuillSkill",
    # "Yeet",
]

_rank = collect(1:size(_teams,1))

# Create some sample data that we can test and build on
sampleData = DataFrame(team = _teams, rank = _rank)



"""
A game is a pairing of two teams at a location.
Can be updated at any time to add the score, location etc
"""
mutable struct Game
    teamA::String
    teamB::String
    Location::String
    teamAScore::Int
    teamBScore::Int
end


"""
nextRound
The next games that are yet to be played.
"""
mutable struct nextRound
    gamesToPlay::Array{Game}
end


"""
Round:
A set of games that have all been played at the same time.
"""
mutable struct Round
    roundNumber::Int
    playedGames::Array{Game}
end


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


"""
    rankings(gamesPlayed::Vector{Game})

This takes a vector of Games, and returns a ranking dataframe based on the games that have been played thus far. 
"""
function rankings(gamesPlayed::Vector{Game})

    # create a dataframe from the gamesplayed to get an overview of the situation
    df  = DataFrame(teamA = String[], teamB = String[],margin=Int[], teamAscore = Int[],teamBscore = Int[],val = Int[])

    # allTeams = String[]
    
    for i in gamesPlayed
        push!(df, (i.teamA, i.teamB,i.teamAScore-i.teamBScore,i.teamAScore,i.teamBScore,1 ), promote=true)
        push!(df, (i.teamB, i.teamA,i.teamBScore-i.teamAScore,i.teamBScore,i.teamAScore,-1), promote=true)
    
    end


    # deduce some stats.
    df.winA = Int.(df.teamAscore .> df.teamBscore)
    df.lossA = Int.(df.teamAscore .< df.teamBscore)
    df.drawA = Int.(df.teamAscore .== df.teamBscore)
    df.byeA = Int.(df.teamB .== "BYE")
    df.played = Int.(df.teamB .!= "BYE")

    # and create the ranking from WL
    df.modified_margin = 3*df.winA .+ df.drawA

    # combine the rankings by team
    rankingsDf = combine(
            groupby(df,:teamA),
                            [:modified_margin,:margin,:played,:winA,:lossA,:drawA,:byeA] 
                .=> sum .=> [:modified_margin,:margin,:played,:winA,:lossA,:drawA,:byeA] 
                )

    sort!(rankingsDf,[:modified_margin,:margin], rev = true)

    rankingsDf.rank = collect(1:size(rankingsDf,1))

    return rankingsDf

end







"""
This function takes a set of rankings and bye information, a list of previous games, and the bye indicator, 
it calculates who is next best to play each other, based on score. 

It returns a nextRound objects that are games to be played

it takes into consideration prior games, so that teams do no play each other more than once, 
and prior byes, so that a single team won't have more than one bye. 

If there are an odd number of teams, the bye position decides if it goes to the first rank,
bottom ranked, or middle ranked team, first taking into consideration the the points above.
"""
function CreateNextRound(prevGames::Vector{Game},bye::Symbol=:middle)
    # prevGames = gamesPlayed
    # bye = :middle
    df = rankings(prevGames)

    g = Game[]

    # # ok, so now we need to find the best combination of pairs where they haven't played prior.
    sort!(df,:teamA,rev=true)

    # This is just linear algebra?
    # lets make some cost matricies

    sz = size(df,1)
    costM = zeros(sz,sz)

    for i in 1:sz
        for j in 1:sz

            # This makes large matchups more costly
            costM[i,j] = max(abs.(df.rank[i] - df.rank[j]))

            # # This stops teams from playing themself
            if i == j 
                costM[i,j] += 1000
            end

            # This prevents teams that have had a bye from having another one
            if ((df.teamA[i]=="BYE" && df.byeA[j]==1 ) || (df.teamA[j]=="BYE" && df.byeA[i]==1 ))
                costM[i,j] += 1000
            end

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
                    costM[i,j] += abs.(size(df.rank,1)/2 .- df.rank[j])

                elseif df.teamA[j]=="BYE" 
                    costM[i,j] += abs.(size(df.rank,1)/2 .- df.rank[i])
                end

            elseif bye == :first 
                if df.teamA[i]=="BYE" 
                    costM[i,j] += df.rank[j]

                elseif df.teamA[j]=="BYE" 
                    costM[i,j] += df.rank[i]
                end

            elseif bye == :last 
                if df.teamA[i]=="BYE" 
                    costM[i,j] += df.rank[j]

                elseif df.teamA[j]=="BYE" 
                    costM[i,j] +=  size(df.rank,1) +1 .- df.rank[i]
                end
            end
        end
    end


costM


    # and now find the matrix of previous plays 
    prevGameDf = DataFrame(teamA = String[],teamB = String[])
    for i in prevGames

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

    allM = costM .+ prevGamesM

    # and now we can pump this into a linear algebra solver to find the best combo

    model = Model(GLPK.Optimizer)
    # set_attribute(model, "logLevel", 1)

    @variable(model,possibleGames[1:sz,1:sz],Bin)
    # @variable(model, x[1:m, 1:n], Bin);

    # only one from each row
    @constraint(model,tA[j in 1:sz], sum(possibleGames[i,j] for i in 1:sz) == 1 )
    # only one from each col
    @constraint(model,tB[i in 1:sz], sum(possibleGames[i,j] for j in 1:sz) == 1 )

    # this ensures that both teams play each other, else it might try A => B and then B => C
    @constraint(model,[i = 1:sz, j = 1:sz], possibleGames[i,j] == possibleGames[j,i]  )

    # we want the minimum difference in matchups
    @objective(model,Min,sum(allM .* possibleGames ))

    optimize!(model)

    summary = solution_summary(model,verbose=true);

    @show summary.:raw_status
    @show summary.:objective_value
    # Create dataframe to get values back out
    moreGames = DataFrame(value.(possibleGames),score_df.teamA)
    moreGames.team = score_df.teamA

    moreGames
    games2Add = filter(x->x.value == 1,stack(moreGames,score_df.teamA))

    # and now we can add these all as games
    games2Add
    rename!(games2Add,:team=>:teamA,:variable=>:teamB)

    if size(filter(x->x.teamA == x.teamB,games2Add),1) > 0
        @warn "One or more Teams have been paired with themself"
    end

    _teams = String[] 
    g 

    for i in eachrow(games2Add)

        if i.teamA ∉ _teams
            push!(g,Game(i.teamA,i.teamB,"",0,0))
            push!(_teams,i.teamA)
            push!(_teams,i.teamB)
        end
    end

    NextRound = nextRound(g) # create a nextround object from the list of games.
    return NextRound;
end 

# NextRound.gamesToPlay
# CreateNextRound(round1.playedGames,:middle)
# CreateNextRound(round1.playedGames,:first)
# CreateNextRound(round1.playedGames,:last)

# rankings(
#     vcat(round1.playedGames,round2.playedGames)
# )



# number 1:14






n = 1

n += 1