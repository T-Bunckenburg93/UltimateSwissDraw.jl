# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")

using  Gadfly
# using CairoMakie


# sd = load_object("miso3.swissdraw")
sd = load_object("div2Seeding.swissdraw")

# ok so I want some swiss draw metrics
ddf = rankings(sd,allGames = true)


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


prevGames.roundPlayedP1 = prevGames.roundPlayed .+ 0.5

prevGames = coalesce.(prevGames, 0.0)

teamStats = filter(x->x.teamA == "Luminance", prevGames )

teamStats.yend = teamStats.strengthB .+ teamStats.margin
teamStats

set_default_plot_size(16cm, 16cm)
x_data = teamStats.roundPlayed
y_data =  teamStats.strengthA

lineStrength = layer(x=x_data, y=y_data, Geom.line, color=[colorant"Blue"], Theme(line_width=1pt))

plot(lineStrength)

plot(teamStats, 
    layer(x = :roundPlayed, y=:strengthA, Geom.line, color=[colorant"Blue"],  ),
    layer(x = :roundPlayed, xend = :roundPlayed, y = :strengthB, yend = :yend, Geom.segment( arrow=true, filled=false)),
    layer(x = :roundPlayed, y=:strengthB, Geom.point, color=[colorant"Red"], ),
    layer(x = :roundPlayed, y=:strengthB, label=:teamB, Geom.label(position=:right)),
    Coord.cartesian(xmin=-0.5, xmax=6, ymin=-10, ymax=10),

    # layer(x = :roundPlayed, y=:rankA, Geom.line, color=[colorant"Blue"],  ),
    # layer(x = :roundPlayed, xend = :roundPlayed, y = :rankB, yend = :yend, Geom.segment( arrow=true, filled=false)),
    # layer(x = :roundPlayed, y=:rankB, Geom.point, color=[colorant"Red"], ),
    # layer(x = :roundPlayed, y=:rankB, label=:teamB, Geom.label(position=:right)),
    # Coord.cartesian(xmin=-0.5, xmax=6, ymin=0, ymax=18),


    # strengthAFinal

    Scale.x_continuous(minvalue=0.5, maxvalue=5.0),
    Scale.y_continuous(minvalue=0.5, maxvalue=5.0),
    # xmin = 5,


    Guide.ylabel("Strength"),
    Guide.xlabel("Round")

)


# scatterlines!(teamStats.roundPlayed, teamStats.strengthA, color = :red)


