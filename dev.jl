

include("testData.jl")
include("func.jl")


println("### Starting Simulation ###")
println("###")
println("###")
using OneHotArrays, LinearAlgebra, JuMP, GLPK

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
updateScore!(Draw,"AUUC","MUA",0,15)

# And now we calculates
CreateNextRound!(Draw)

# ok, lets test that we can change previous outcomes
    initialRank = rankings(Draw)
    updateScore!(Draw,"AUUC","MUA",100,1,1)
    updatedRank = rankings(Draw)
    Draw.previousRound
# Very good

# Draw.AllChanges

Draw.currentRound

show(rankings(Draw))

updateScore!(Draw,"Axiom","Ethos",14,15)
updateScore!(Draw,"AUUC","Htron",10,12)
updateScore!(Draw,"Gen3","Radiance",9,7)
updateScore!(Draw,"GG","Morri",15,11)
updateScore!(Draw,"Mount","Patch",10,3)
updateScore!(Draw,"Duck","Luminance",10,7)
updateScore!(Draw,"T_Thunder","Whakatu",9,7)
updateScore!(Draw,"Euphoria","Tcookies",15,6)
updateScore!(Draw,"MUA","Wow",12,9)

Draw.currentRound

CreateNextRound!(Draw)
show(rankings(Draw))
Draw.currentRound

updateScore!(Draw,"Patch","Tcookies",14,10)
updateScore!(Draw,"Morri","Wow",15,1)
updateScore!(Draw,"Htron","MUA",11,7)
updateScore!(Draw,"Axiom","Gen3",15,11)
updateScore!(Draw,"Ethos","T_Thunder",10,8)
updateScore!(Draw,"Duck","GG",10,15)
updateScore!(Draw,"Euphoria","Mount",9,7)
updateScore!(Draw,"AUUC","Radiance",15,6)
updateScore!(Draw,"Luminance","Whakatu",12,9)



