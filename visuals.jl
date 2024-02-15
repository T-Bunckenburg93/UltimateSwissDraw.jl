# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")

using CSV, LinearAlgebra, StatsBase, GraphMakie, Graphs
# using CairoMakie


# sd = load_object("miso3.swissdraw")
sd = load_object("div2Example5.swissdraw")


# ok so I want some swiss draw metrics

prevRoundsRankings(sd)
ddf = allRankings(sd)
# CreateNextRound!(sd)

vcat(sd.previousRound,sd.currentRound)

rNumber = sd.currentRound.roundNumber -1 


allStrengths = DataFrame()

for i in 1:rNumber

    df = teamStrengths(filter(x-> x.roundNumber <= i, sd.previousRound))
    df.round .= i
    df.rank = 1:size(df,1)

    append!(allStrengths,df)

end

allStrengths

# ok, so I want to get all games played as a df
rounds = sd.previousRound

# create a dataframe from the gamesplayed to get an overview of the situation
df  = DataFrame(teamA = String[], teamB = String[],margin=Int[], teamAscore = Int[],teamBscore = Int[], roundPlayed =Int[])

for j in rounds
    for i in j.Games
        push!(df, (i.teamA, i.teamB,coalesce(i.teamAScore-i.teamBScore,0),coalesce(i.teamAScore,0),coalesce(i.teamBScore,0),j.roundNumber ), promote=true)
    end
end

df
allStrengths

function expectedOutcome(allRounds,teamA,teamB,round)

    teamAMargin = filter(x->x.team == teamA && x.round == round,allRounds).strength[1]
    teamBMargin = filter(x->x.team == teamB && x.round == round,allRounds).strength[1]
    expectedDiff = (teamAMargin-teamBMargin)

    return expectedDiff
end

# expectedOutcome(allR,"Morri","Mount",1)

sort(df,:teamA)

allDF = DataFrame()

for i in 1:3
    df.roundCalculated .= i 
    append!(allDF,df)
end

sort(allDF,:teamA)

allDF.epectededMargin .= 0.0

for i in eachrow(allDF)

    i.epectededMargin = expectedOutcome(allStrengths,i.teamA ,i.teamB,i.roundCalculated)

end

allDF.marginDiffABS = abs.(allDF.margin .- allDF.epectededMargin)
allDF.marginDiff = (allDF.margin .- allDF.epectededMargin)

sort(filter(x->x.roundCalculated == 3,allDF),:marginDiffABS,rev = true)


combine(groupby(allDF,:roundCalculated),:marginDiffABS .=> [mean,var])


