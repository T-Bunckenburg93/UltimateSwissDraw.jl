function formatLabel(txt::String)

    txt = replace(txt,"\n" => "")
    txt = replace(txt,"<br>" => "\n")

    txtLabel = Mousetrap.Label( txt)
    set_expand!(txtLabel, true)

    set_margin!(txtLabel, 10)
    set_wrap_mode!(txtLabel,LABEL_WRAP_MODE_ONLY_ON_WORD)
    set_vertical_alignment!(txtLabel, ALIGNMENT_START)
    # set_size_request!(txtLabel, Vector2f(770,0)) 


    viewport = Viewport()
    set_expand!(viewport, true)

    set_margin!(viewport, 10)
    set_horizontal_alignment!(viewport, ALIGNMENT_CENTER)


    set_size_request!(viewport, Vector2f(800,800)) 

    set_child!(viewport, txtLabel)

    set_vertical_alignment!(viewport, ALIGNMENT_START)


    return viewport

end



function infoDump(infoWindow)

    set_title!(infoWindow, "Ultimate Swiss Draw: Infomation") 

    topWindow = vbox()
    set_expand!(topWindow, true)
    set_horizontal_alignment!(topWindow, ALIGNMENT_CENTER)
    set_vertical_alignment!(topWindow, ALIGNMENT_START)
    set_size_request!(topWindow, Vector2f(800,700)) 


    stack = Stack()
    set_size_request!(stack, Vector2f(770,700)) 

    # push_back!(topWindow,stack)

    # viewport = Viewport()
    # set_expand!(viewport, true)

    # set_margin!(viewport, 10)
    # set_horizontal_alignment!(viewport, ALIGNMENT_CENTER)
    # set_vertical_alignment!(viewport, ALIGNMENT_CENTER)

    # set_size_request!(viewport, Vector2f(800,700)) 

    # push_back!(topWindow,viewport)

    # Infobox = vbox()
    # set_expand!(Infobox, true)
    # set_horizontal_alignment!(Infobox, ALIGNMENT_CENTER)
    # set_vertical_alignment!(Infobox, ALIGNMENT_START)
    # set_child!(viewport, Infobox)


# Swiss Draw overview
    txt = 
        """<b>Swiss Draw </b>
        <br>
        <br>

    Swiss Draws are an alternative to a pool based draw structure designed to quickly and effectively order teams in a competition.
    <br>
    <br>
    This version is specifically designed for ultimate frisbee and is designed to be quick, simple and explainable. It is designed to be usable for a tournament situation and has the following optional features: 
        <br>
        - It can optimise the distribution of streamed games to make sure as many teams get a streamed game
        <br>
        - It can minimise the distance that teams need to travel to their next game.
        <br>
        <br>

    It works best under the following two conditions, but can work well in other cases:
    <br>
    <br>

        - Where there is a large range of teams across the competition, and there is minimal information about the respective strength of each team. 
        <br>
        - Where you may want to avoid rematches in order to give teams a variety of different teams to play against.
        <br>
        <br>
    The following should be enough for a basic understanding how it works.
        <br>
        <br>
    In the first round, teams are either randomly shuffled, or an order is provided. They then play off against the team that is half the field away. 
    For example, if there are 8 teams, 1 vs 5, 2 vs 6, 3 vs 7 and 4 vs 8. 
    <br>
    <br>

    For the next, and subsequent rounds, each teams strengths score is calculated (see strengths further down), and equivilent pairings are made. 1 vs 2, 3 vs 4, etc.
    <i> unless they have already played in a previous round. </i> In this case we use the next best suitable pairing.

    <br>
    <br>

    This way of matchup means that teams are always playing tough competition and don't play the same team multiple times.

    <br>
    <br>

    The suggested number of rounds is related to the number of teams you have: 3 rounds for 8 or more teams, 4 rounds for 16+ teams, 5 for 32+ ,6 for 64+, etc.
    This draw can take any number of teams, even or odd, and can calculate any number of rounds. You can either run the draw for as many rounds and determine a winner, or you can then go onto an elimination for the top 8, with the rest of the teams playing the swiss system. 

    <br>
    <br>

    More info about the Swiss Draw, or the Swiss System can be found here: <br> https://en.wikipedia.org/wiki/Swiss-system_tournament
    <br>
    """

    # push_back!(Infobox,Frame(formatLabel(txt)))
    add_child!(stack,  Frame(formatLabel(txt)), "Overview" )

    # Strength (layperson)
    txt = 
    """
    <b> Strength Explanation </b>
    <br>
    <br>
    This version uses the score margin of games to determine the strongest teams. 
    <br> 
    A way to think about strength is; how can we assign a value to each team in order to predict, or fit the outcome that has happened? 
    <br>
    <br>
    A teams strength can also be thought of as an expected <b>margin</b>; if team A has a strength of 5, and team B has a strength of -2, then team A would be expected to beat team B by 5 - -2, or 7 points. 
    <br>
    <br>
    This is most obvious after the first round, where a teams calculated strength is exactly half of the score difference from the first game. As the rounds go on, this strength score becomes more accurate as more information is collected.

    <br> <br>

    The number one takeaway for teams is that score differences are important!
    <br>
    <br>
    A team winning by a blowout means that they are deemed to be far better than their opponent. Even if a team is losing, they are incentivised to play as hard as possible in order to lower the margin, while a team winning has an incentive to play to the best of their abilities, even against weaker teams.
    <br>
    The most imbalanced games should only happen on the first round, so games should get much closer after that.

    This results in lots of closely paired games, no pools of death, and a fairier way of determining the comparitive strength of teams.
    <br>    
    <br>    
    <br>
    A few quirks of this method: 
    <br>    
    <br>    
        - Generally teams move up or down by exceeding the predicted margin for a game. If a team is expected to win by 7 points, and only win by 3, then their strength score should drop slightly, as they did not perform as well as they were expected to.
    <br>    
    <br>    
        - A teams strength score can also depend on the outcomes of other games, For example, if you narrowly lose to a strong team that then goes on to beat other teams by a large margin, then you should be ranked above these teams, and your strength score may rise as the strong team plays well. This will cause you to increase in strength, but can be confusing when you have a loss and your strength score goes up.
    <br>
    <br>
        - A teams strength score is relative to all the other teams in the pool. It rising or lowering slightly might not be significant, especially early on. 
    <br>
    <br>


    To explain these movements, there is a strength chart to show each team their strength matchups, and how their strengths changed over the course of the tournament.
    <br>    

    """

    add_child!(stack,  Frame(formatLabel(txt)), "Strengths" )


    # Strength (layperson)
    txt = 
    """
    <b>How to use the App</b>
    <br>
    <br>


    <b>Create a Draw </b>
    <br>
    <br>
    To create a draw you need a list of teams, as well as a list of fields. There are some example CSV files; sampleTeams.csv, and samplefields.csv, that show how these should be laid out. 
    <br> If there is no set ranking then put all teams as zero. 
    <br>If you don't care about field distances set the x and y for each value to zero. 
    <br>If you don't have any streamed fields, set this to be 'false' for all fields. 
    <br>


    <br> Note that you cannot add or remove teams once the draw is created.
    <br> <br>
    Once you have these, you can load them into the app using the create new draw button. 
    <br>
    <br>

    <b> Update a Draw </b>
    <br>

    <br>Once you have created a draw, this takes you to the 'Update Round' page, where you can update the scores and modify the round, by either switching teams or switching fields.     

    <br> 
    <br> 

    Once you are happy with the round, you may download the round as a CSV with some additional columns, to then upload it into UltiCentral. This is an optional export. 

    <br>
    <br>
    <b> Save and Load a Draw </b>

    <br> 
    <br> 

    At the bottom there is a save icon. This saves the Swiss draw as .swissDraw file.
    <br>
    On opening the app, you can then load this .swissDraw file back in at a later date.

    <br>
    <br>
    <b> Calculate the next Round  </b>


    <br> 
    <br> 

    Once you have loaded and submitted the scores for the current round, then go to the 'Calculate Next Round' page.
    <br> 
    This page gives an overview of the current round. If you have not entered a score and they are displayed as missing, then they will be assumed as 0.
    <br> 
    You can choose to either run the Swiss Draw, or refesh it.
    <br> 

    Running the Swiss draw will take the current round, calculate the strengths across all the games, and return the a list of matchups that are as close as possible. 

    <br><br>It then looks at where all the teams are currently located and finds the best field so that teams are walking as little as possible.
    <br>If some fields are selected for streaming, then teams that have had a stream are much less likely to be put onto these streamed fields until everyone has had a streamed field. Because higher ranked teams are likely to have streamed playoffs, it gives preference to lower ranked teams first to give more teams streamed games.

    <br><br>
    Finally, the matchups and the suggested fields are returned on the 'Update Round' page, where you can tweak the round if you see fit.
    <br>
    <br>
    <b> Previous Results </b>
    <br>
    <br>
    This is where you can see and edit all previous rounds that have been played thus far. You should only do this if there has been a mistake in entereing results in previous rounds. 
    <br>
    <br>
    <b> Refresh Current Round </b>
    <br>
    <br>
    if you make a mistake in a previous round, like getting the scores slightly off, or getting them mixed up, you can correct this error. 
    <br>Go to the 'Previous Results' page, and rectify the result.
    <br>Then go to the 'Calculate Next Round' page, and click 'Refresh Swiss Draw'.
    <br>
    <br>
    This will ignore any results from the current round and recalculate it, overwriting any entered results. It is not reccomended to do this if you have already have a round in progress, as the draw might be very different.
    <br>If there have been no changes, then the newly generated round should be the same. 

    <br>
    <br>
    <b> Rankings </b>
    <br>
    <br>
    Here you can see the strength scores for each team, their results and the strength chart to show how the strengths, and their opponents strengths, changed as they moved through the tournament.
    <br>You can also download the strengths, or browse all the strength charts
    """

    add_child!(stack,  Frame(formatLabel(txt)), "Guide" )

    # Strength (layperson)
    txt = 
    """
    <b> How to get the distances </b>
    <br>
    <br>
    The coordiantes for fields don't need to be extremely accurate. You can put a rough grid over them and estimate the points, as shown in the example below.
    <br>
    <br>
    <b> In the case of uneven teams: </b>
    <br>
    <br>

    It is reccomended that the coordinates (0,0) is close to the 'home' field, or whereever teams are likely to go to for lunch. <br>
    <br>
    This matters only in the case of uneaven teams and when there is a bye, as the team with a bye is assumed to be at (0,0).


    """
    add_child!(stack, Frame(formatLabel(txt)) , "Field Distance" )



    image = Mousetrap.Image()
    create_from_file!(image,"field_example.png")

    image_display = ImageDisplay()
    create_from_image!(image_display, image)
    set_size_request!(image_display, Vector2f(700,700)) 
    # set_expand!(image_display, true)

    set_vertical_alignment!(image_display, ALIGNMENT_START)


    add_child!(stack, image_display , "Field Distance Eg" )

    # Strength (layperson)
    txt = 
    """
    <b> Streamed Games </b>

    <br>
    <br>

    If there are streaming fields, there is logic built in to attempt to make as many teams get a stream as possible. 
    It is assumed that there will likely be some sort of playoffs, and teams that are more likely to make that playoff are more likely to get a stream then.
    <br>
    <br>

    Teams are also more likely to have a stream if they have not had a stream prior.




    """

    add_child!(stack,  Frame(formatLabel(txt)), "Streamed Games" )



    # Strength (mathematics)
    txt = 
    """
    <b> Strength Explanation (Maths) </b>
    <br>
    <br>

    The strength calculation comes from an ordinary least squares regression which can be set up like so:
    <br>

    Here we have a set of following equations for each game:
        <br>

    Mg = β_teamA * (1) + β_teamB * (-1)

    Where:
    <br>
    <br>
        Mg,         is the margin difference in the game
        <br>
        β_teamA     is the coefficient for the strength of teamA
        <br>
        β_teamB     is the coefficient for the strength of teamA
        <br>
        The 1 and -1 are mathematical indicators to show that the teams played each other, the negative is needed, else they would 'work together' to get to the margin. 

        <br><br>

    We can view these in matrix form, as :
    <br>

    Mg = βX
    <br>
    <br>
    Where:
    <br>
    <br>
    Mg is a column vector of Outcomes, and has dimesions [1,N_games]
    <br>
    β is the column vector of team strengths, and has dimension [1,N_teams]
    <br>
    X is a matrix representing teams by games played, with dimensions [N_teams,N_games]
    <br>






    <br>
    (note that ordinary least squares has errors. We're ignoring this part, as this takes into account the effect for sources other than the explanatory variables, and we really have no way to quantify or measure this. By doing this we assume then that the outcome of every game is soley due to the contribution of the two teams. )



    """
    add_child!(stack,  Frame(formatLabel(txt)), "Strengths (Math)" )



    # push_back!(Infobox,Frame(formatLabel(txt)))
    stack_model = get_selection_model(stack)
    connect_signal_selection_changed!(stack_model, stack) do x::SelectionModel, position::Integer, n_items::Integer, stack::Stack
        println("Current stack page is now: $(get_child_at(stack, position))")
    end

    push_back!(topWindow, hbox(StackSidebar(stack), stack)) # Create StackSidebar from stack

    set_child!(infoWindow, topWindow)
    present!(infoWindow)
    # return nothing
end





