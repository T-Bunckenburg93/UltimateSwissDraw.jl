using Test
using OneHotArrays, LinearAlgebra, JuMP, GLPK

include("func.jl")

_teams = String[
"T_Thunder",
"Tcookies",
"Htron",
"Axiom",
"Ethos",
"GG",
"Morri",
"Mount",
"Whakatu",
"Patch",
"MUA",
"AUUC",
"Euphoria",
"Radiance",
"Gen3",
"Luminance",
"Duck",
"Wow",
]

_rank = collect(1:size(_teams,1))

# Create some sample data that we can test and build on
sampleData = DataFrame(team = _teams, rank = _rank)


# Ok, so we need a distance matrix for each field
# field plots as xy

# may need to turn this into a function to make it do all the things

field_x = [2, 2, 3, 2, 2, 2, 2, 3, 2, 3 ]
field_y = [1, 4, 1, 3, 5, 7, 9, 9, 11, 11]
field_Number = [1, 2 , 3, 4, 5, 6, 7, 8, 9, 10 ]
stream = [true, true, false, false, false, false, false, false, false, false] 

_fieldDF = sort(DataFrame(number = field_Number, x = field_x, y= field_y, stream= stream),:number)




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

# And now we calculates
CreateNextRound!(Draw)

# ok, lets test that we can change previous outcomes
    initialRank = rankings(Draw)
    updateScore!(Draw,"AUUC","MUA",100,1,1)
    updatedRank = rankings(Draw)
    Draw.previousRound
# Very good

Draw.AllChanges





