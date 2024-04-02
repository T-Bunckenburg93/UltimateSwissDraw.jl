# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")


# ArrowPts = createArrow(1,5,1,0)


# sd = load_object("miso3.swissdraw")
sd = load_object("div2Seeding.swissdraw")

prevGames = GenerateStrengthCharts(sd,"charts/strengthChanges")
# function WriteStrengthChanges(sd,path::String)
CreateStrengthChart(filter(x->x.teamA == "Luminance", prevGames ),-15,15)
CreateStrengthChart(filter(x->x.teamA == "Radiance", prevGames ),-15,15)


t1 = (filter(x->x.teamA == "Radiance", prevGames ))
t2 = filter(x->x.teamA == "Luminance", prevGames )
    # How to interpret this chart? 

    # All teams start at zero, the red/green arrows are the margin of which they won their first game, 
    # this then leads to a strength calculation increas or decrease. They then play another team that should ve somewhat similar score
    # The difference between the strengths is alos the 'expected' outcome. 
    # generally, winning by less or losing by more  than this expected outcome will decrease a teams percieved stength,
    # while winning be more, or losing by less should decrease it.
    # This can be affected by other games, ie if you lose by a small margin to a team that then does very well then
    # your percieved strength may increase du to this factor. 
    # Teams will also generally move more earlier on in the swiss draw, while they are more settled later on. 

    select(filter(x->x.teamA == "Radiance", prevGames ),
    [:teamA,:teamB,:margin,:roundPlayed,:strengthA,:strengthAFinal,:prevStrengthB,:strengthBFinal])
    exampleDF = DataFrame()
push!()

    exampleDF

    CreateStrengthChart(filter(x->x.teamA == "Radiance", prevGames ),-15,15)


exampleDF = DataFrame(
        teamA = String[],
        teamB = String[],
        margin = Int64[],
        roundPlayed = Int64[],
        strengthA = Float64[],
        strengthAFinal = Float64[],
        prevStrengthB = Float64[],
        strengthBFinal = Float64[],
    )
    
push!(exampleDF,["Example Team","Team1",-4,1,-2.5,-4.87401,0.0,3.03703])
push!(exampleDF,["Example Team","Team2",-7,2,-6.16667,-4.87401,-2.5, 1.56563])
push!(exampleDF,["Example Team","Team3",2,3,-4.35959,-4.87401,-2.2, -6.80963])
push!(exampleDF,["Example Team","Team4",-1,4,-4.87401,-4.87401,-5.59161, -5.28905])
push!(exampleDF,["Example Team","",0,0,0.0,-4.87401,0.0, 0.0])

CreateStrengthChart(exampleDF,-15,15)