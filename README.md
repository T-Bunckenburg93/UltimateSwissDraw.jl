# SwissDraw.jl
Swiss Draw implemented in Julia.

# To install:

Julia 1.10.0 or greater is advised. 

Download from github onto local machine. VS code with the Julia extension is advised 

run init.jl either from inside vscode, or via shell. This should download and install all the packages

Then just run main.jl and either create a new swiss draw from inital_teams.csv and field_distances.csv, or load an existing swiss draw from div2Seeding.swissdraw

The current state of the repo is rough, and design and layout elements are to be seriously  considered at a later date. 

## What is a Swiss Draw? 

A swiss draw is a way to calculate rankings and rounds in a tournamet or league style setting. It is effective at doing this when there are more teams in the tournament that can practically play each other and the realitive strengths of these teams is unknown. It also avoids the pools of death that can occur in other tournament styles and is desinged to give teams lots of close games across the tournament.

## How does this one work?

This version is designed for ultimate frisbee, and takes the margins of games into account as a way to quickly and effectively rank teams. When using this method, teams need to be communicated that margins matter. A team losing by 1 point is not far off a draw, and indicates that the two teams are very close in strength, while a team losing by 10 points indicates a much wider margin. 

The first round teams are ordered by an inital seeding. If there are 8 teams, 1st seed plays 5th, 2nd plays 6th.. etc. If there is no inital ordering, then this is just random. Subsequent rounds are decided by finding similar pairings of strengths. 

There are considerations in the logic so teams don't play each other more than once, the ability to add feilds that have streamed games, and you if your fields are spread out, you can minimise the distance that teams have to travel to their next field.

In the instance that a mistake is made, or if you want to modify the draw, you can switch teams and fields around and refresh the draw. 

The strengths of each team can be visualsed as they move through the draw.

You can save the draw as you enter results, and load it later.





