# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")

using CSV, LinearAlgebra, StatsBase
using CairoMakie


# sd = load_object("miso3.swissdraw")
sd = load_object("div2Seeding.swissdraw")


# ok so I want some swiss draw metrics
ddf = Rankings(sd,allGames = true)

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

for i in 1:maximum(df.roundPlayed)
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


t = "Whakatu"

filter(
    x->x.roundPlayed == x.roundCalculated
    && (x.teamA == t || x.teamB == t)
    ,
    allDF
)

allStrengths.roundPlus1 = allStrengths.round .+1

tStrength = filter(x->x.team == t  ,allStrengths)

plot(tStrength.round,tStrength.strength, colour = tStrength.team)

# code to see the strength changes over time
# f = Figure()
# Axis(f[1, 1])
# for i in unique(allStrengths.team)

#     lines!(
#             filter(x->x.team == i  ,allStrengths).round, 
#             filter(x->x.team == i  ,allStrengths).strength,
#             label = i
#         )
# end 
# axislegend()
# f

allDF
# We need to merge strengths on

allDFStrength = leftjoin(
allDF,
rename(allStrengths,:strength=>:strengthA),
on = [:teamA => :team, :roundPlayed => :round],
# renamecols = :strength => :strengthA
)

select!(allDFStrength,Not(:rank))

leftjoin!(
allDFStrength,
rename(allStrengths,:strength=>:strengthB),
on = [:teamB => :team, :roundPlayed => :round],
# renamecols = :strength => :strengthA
)

select!(allDFStrength,Not(:rank))

allDFStrength

teamToLookAt = "GG"

teamStrength = filter(x->x.team == teamToLookAt  ,allStrengths)

allStrength = 
    filter(x->x.roundPlayed == x.roundCalculated &&
             (x.teamA == teamToLookAt || x.teamB == teamToLookAt)
             ,allDFStrength)

             allStrength


             
