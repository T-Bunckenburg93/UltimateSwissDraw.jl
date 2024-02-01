using DataFrames

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

# CSV.write("./field_distances.csv", _fieldDF)