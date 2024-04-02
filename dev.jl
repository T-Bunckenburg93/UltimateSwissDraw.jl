# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());

using Mousetrap, CSV, JLD2


include("func.jl")
include("uifunc.jl")

_swissDrawObject = load_object("div2Seeding.swissdraw")
_swissDrawObject = load_object("stresst.swissdraw")
_swissDrawObject = load_object("div2Example5.swissdraw")


# CreateNextRound!(_swissDrawObject)



main("swiss.draw") do app::Application

    mainWindow = Window(app)
    set_expand!(mainWindow, true)

    # include("previousResults.jl")

    # global getPreviousResults = Action("example.getPreviousResults", app)
    # set_function!(getPreviousResults) do x::Action
    #     previousResults(mainWindow)
    # end

    # activate!(getPreviousResults)

    # include("runDraw.jl")

    # global runDraw = Action("example.b", app)
    # set_function!(runDraw) do x::Action
    #     run_draw(mainWindow)
    # end

    # activate!(runDraw)


    # include("standings.jl")

    # global standingsAction = Action("example.standingsAction", app)
    # set_function!(standingsAction) do x::Action
    #     standings(mainWindow)
    # end

    include("info.jl")
    global infoAction = Action("example.standingsAction", app)
    set_function!(infoAction) do x::Action
        infoinfoDump(mainWindow)
    end


    activate!(infoAction)

end

# rankdf = rankings(_swissDrawObject, allGames = false)

# # select(rank,([:rank => :RANK]))




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

    teams = unique(sort(vcat(df.teamA,df.teamB)))

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

    return A,b, 
    strengthdf,
    df
end


A,b,sdf, df = teamStrengths(_swissDrawObject.previousRound)

A

b

sdf.strength

sort!(sdf,:team)
sdf

s = reshape(sdf.strength,1,length(sdf.strength))

s * A

sort!(df,:teamA)

df.margin

teams = unique(vcat(df.teamA,df.teamB))

indicatormat(df.teamA, teams) .- indicatormat(df.teamB,teams) 


