# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")

# using  Gadfly
using CairoMakie


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
# ArrowPts = createArrow(1,5,1,0)


# sd = load_object("miso3.swissdraw")
sd = load_object("div2Seeding.swissdraw")

# ok so I want some swiss draw metrics
ddf = allRankings(sd)


# vcat(sd.previousRound,sd.currentRound)


# Get the strengths calculated at the end of each round
rNumber = sd.currentRound.roundNumber -1 

allStrengths = DataFrame()

for i in 1:rNumber

    df = teamStrengths(filter(x-> x.roundNumber <= i, sd.previousRound))
    df.round .= i
    df.rank = 1:size(df,1)

    append!(allStrengths,df)

end




# ok, so I want to get all games played as a df
rounds = sd.previousRound
sd.initialRanking
# create a dataframe from the gamesplayed to get an overview of the situation
prevGames  = DataFrame(teamA = String[], teamB = String[],margin=Int[], teamAscore = Int[],teamBscore = Int[], roundPlayed =Int[])

# I also want both games on each side to make it easier

for j in rounds
    for i in j.Games
        push!(prevGames, (i.teamA, i.teamB,coalesce(i.teamAScore-i.teamBScore,0),coalesce(i.teamAScore,0),coalesce(i.teamBScore,0),j.roundNumber ), promote=true)
        push!(prevGames, (i.teamB, i.teamA,coalesce(i.teamBScore-i.teamAScore,0),coalesce(i.teamBScore,0),coalesce(i.teamAScore,0),j.roundNumber ), promote=true)
    end
end

for i in eachrow(sd.initialRanking)
    push!(prevGames, (i.team, "",0,0,0,0 ), promote=true)
end

prevGames

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


prevGames.expectededMarginA .= 0.0
prevGames.expectededMarginB .= 0.0

for i in eachrow(prevGames)

    i.expectededMarginA = expectedOutcome(allStrengths,i.teamA ,i.teamB,i.roundPlayed - 1)
    i.expectededMarginB = expectedOutcome(allStrengths,i.teamB ,i.teamA,i.roundPlayed - 1)

end



prevGames
allStrengths

# now we join strengths on 


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

teamStats = filter(x->x.teamA == "Duck", prevGames )

teamStats.yend = teamStats.strengthB .+ teamStats.margin

sort!(teamStats,:roundPlayed)


maxStrength = maximum((prevGames.prevStrengthA .+ prevGames.margin)) 
minStrength = minimum((prevGames.prevStrengthA .+ prevGames.margin)) 




f = Figure()
Axis(f[1, 1],)

for i in eachrow(filter(x->x.roundPlayed > 0,teamStats))

    # Black Arrow is the change in strength
    poly!(createArrow(i.roundPlayed + 0.5 ,i.prevStrengthA , i.roundPlayed+ 0.5 ,i.strengthA, 0.08,0.3,0.2), color = :Black, strokecolor = :black, strokewidth = 1)

    if i.margin > 0  
        # Red Arrow is the actual Margin from the strength
        poly!(createArrow(i.roundPlayed - 0.15 ,i.prevStrengthA , i.roundPlayed - 0.15 ,i.prevStrengthA + i.margin, 0.08,0.3,0.2), color = :Green, strokecolor = :black, strokewidth = 1)
    else
        poly!(createArrow(i.roundPlayed - 0.15 ,i.prevStrengthA , i.roundPlayed - 0.15 ,i.prevStrengthA + i.margin, 0.08,0.3,0.2), color = :Red, strokecolor = :black, strokewidth = 1)
    end
end

lines!(teamStats.roundPlayed .+ 1,teamStats.strengthA,Legend = "Calculated Strength" )

scatter!(teamStats.roundPlayed,teamStats.prevStrengthB ,color = :blue, marker = :circle,  markersize = 15)
text!(teamStats.roundPlayed, teamStats.prevStrengthB, text = teamStats.teamB) 

# waterfall!(teamStats.margin[2:end], show_direction=true)
limits!(0,6,floor(minStrength),ceil(maxStrength))


elem_1 = [LineElement(color = :Blue, linestyle = nothing),]

elem_2 = PolyElement(color = :black, strokecolor = :black, strokewidth = 2,
        points =  createArrow(0,0.5,1,0.5 , 0.08,0.3,0.2) )

elem_3 = [PolyElement(color = :green, strokecolor = :black, strokewidth = 2,
        points =  createArrow(0.0,0.0,0,1,0.08,0.3,0.2) ),
        PolyElement(color = :Red, strokecolor = :black, strokewidth = 2,
        points =  createArrow(0.5,1, 0.5,0, 0.08,0.3,0.2) )]

elem_4 = MarkerElement(color = :blue, marker = :circle,  markersize = 15,
        strokecolor = :black)


Legend(f[1, 2],
    [elem_1, elem_2, elem_3,elem_4],
    ["Strength Changes", "Strength change arrow", "Game Margin"," Opposition strength"],
    patchsize = (35, 35), rowgap = 10)

    t = teamStats.teamA[1]

    supertitle = Label(f[0, :], "Strength changes for $t")
f



