

function home_page(mainWindow)

    set_title!(mainWindow, "Ultimate Swiss Draw: Update Current Draw") 


    topWindow = vbox()
    # set_size_request!(topWindow, Vector2f(100,100)) 
    set_expand!(topWindow, false)

    set_horizontal_alignment!(topWindow, ALIGNMENT_CENTER)
    set_vertical_alignment!(topWindow, ALIGNMENT_START)


    # Add the current round info as cols
    column_view = ColumnView()
    set_expand!(column_view, true)

    sz = get_natural_size(column_view)

    viewport_rcp = Viewport()
    set_expand!(viewport_rcp, true)

    set_margin!(viewport_rcp, 10)
    set_horizontal_alignment!(viewport_rcp, ALIGNMENT_CENTER)
    set_vertical_alignment!(viewport_rcp, ALIGNMENT_CENTER)

    set_size_request!(viewport_rcp, Vector2f(770,700)) 
    set_child!(viewport_rcp, column_view)

    push_back!(topWindow,viewport_rcp)



    field = push_back_column!(column_view, "Field #")

    TeamA = push_back_column!(column_view, "Team A")
    TeamB = push_back_column!(column_view, "Team B")

    TeamAScoreVal = push_back_column!(column_view, "Team A Score")
    TeamBScoreVal = push_back_column!(column_view, "Team B Score")


    for (v,i) in enumerate(_swissDrawObject.currentRound.Games)

        set_widget_at!(column_view, field, v, Mousetrap.Label(string(i.fieldNumber )))
        set_widget_at!(column_view, TeamA, v, Mousetrap.Label(string(i.teamA )))
        set_widget_at!(column_view, TeamB, v, Mousetrap.Label(string(i.teamB )))
        set_widget_at!(column_view, TeamAScoreVal, v, Mousetrap.Label(string(i.teamAScore )))
        set_widget_at!(column_view, TeamBScoreVal, v, Mousetrap.Label(string(i.teamBScore )))

    end



    specificButtons = vbox()

    # And add the update Score bit

    updateScore = hbox()

    push_back!(specificButtons,updateScore)



    dropdownMatchup = DropDown()

    # If not selected it rests on the first value
    # matchID = 1
    # find the first missing value of matchID
    # in theory so that the dropdown defaults to the next unentered one
    matchID = findfirst(x->ismissing(x.teamAScore) && ismissing(x.teamBScore) ,_swissDrawObject.currentRound.Games)
    # println(matchID)

    if isnothing(matchID)
        matchID = 1
    end

    # Make the callback values a number that represents the index of the game into julia
    for (v,i) in enumerate(_swissDrawObject.currentRound.Games)

        push_back!(dropdownMatchup,string(i.teamA," vs ",i.teamB)) do x::DropDown
            matchID = v
            return nothing
        end
    end

    # and set it
    if isnothing(matchID) 
        set_selected!(dropdownMatchup,get_item_at(dropdownMatchup,1))
    else
        set_selected!(dropdownMatchup,get_item_at(dropdownMatchup,matchID))
    end


    # pull the values out of the spinbuttons into julia
    teamAInputScore = SpinButton(0, 15, 1)
    set_value!(teamAInputScore,0)
    set_orientation!(teamAInputScore, ORIENTATION_VERTICAL)


    _tAScore = 0
    connect_signal_value_changed!(teamAInputScore) do self::SpinButton
        _tAScore =  get_value(self)
        return nothing
    end

    teamBInputScore = SpinButton(0, 15, 1)
    set_value!(teamBInputScore,0)
    set_orientation!(teamBInputScore, ORIENTATION_VERTICAL)

    _tBScore = 0
    connect_signal_value_changed!(teamBInputScore) do self::SpinButton
        _tBScore =  get_value(self)
        return nothing
    end

    updateGameButton = Mousetrap.Button()
    set_child!(updateGameButton, Mousetrap.Label("Submit Scores"))

    connect_signal_clicked!(updateGameButton) do self::Mousetrap.Button

        # println(get_selected(dropdownMatchup))
        println("$matchID , teamA: $_tAScore  teamB: $_tBScore  "   )

        updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
        activate!(homePage)
        return nothing
        
    end

    set_margin!(updateScore, 10)
    set_margin!(dropdownMatchup, 10)
    set_margin!(teamAInputScore, 5)
    set_margin!(teamBInputScore, 5)
    set_margin!(updateGameButton, 10)

    set_horizontal_alignment!(dropdownMatchup, ALIGNMENT_START)
    set_horizontal_alignment!(teamAInputScore, ALIGNMENT_START)
    set_horizontal_alignment!(teamBInputScore, ALIGNMENT_START)
    set_horizontal_alignment!(updateGameButton, ALIGNMENT_END)

    push_front!(updateScore,dropdownMatchup)
    push_back!(updateScore,teamAInputScore)
    push_back!(updateScore,teamBInputScore)
    push_back!(updateScore,updateGameButton)

    set_horizontal_alignment!(updateScore, ALIGNMENT_START)
    set_accent_color!(updateGameButton, WIDGET_COLOR_ACCENT, false)

    
    println(get_allocated_size(teamAInputScore))

    # dump(get_selected(dropdownMatchup))

    # Oh yes. How good. Now lets add the team switcher.

    SwitchTeams = hbox()

    push_back!(specificButtons,SwitchTeams)


    TeamOne = DropDown()
    TeamTwo = DropDown()

    # If not selected it rests on the first value
    teamOneID = 1
    teamTwoID = 1

    for (v,i) in enumerate(_swissDrawObject.initialRanking.team)

        # println(i,v)

        push_back!(TeamOne,String(string(i))) do x::DropDown
            teamOneID = v
            return nothing
        end

        push_back!(TeamTwo,String(string(i))) do x::DropDown
            teamTwoID = v
            return nothing
        end

    end

    SwitchTeamsButton = Mousetrap.Button()
    set_child!(SwitchTeamsButton, Mousetrap.Label("Switch Teams"))

    connect_signal_clicked!(SwitchTeamsButton) do self::Mousetrap.Button

        # println(get_selected(dropdownMatchup))
        println("$teamOneID  $teamTwoID "   )

        println(_swissDrawObject.initialRanking.team[teamOneID],_swissDrawObject.initialRanking.team[teamTwoID])


        # updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
        SwitchTeams!(_swissDrawObject,
            String(_swissDrawObject.initialRanking.team[teamOneID]),
            String(_swissDrawObject.initialRanking.team[teamTwoID])
            )
        activate!(homePage)
        return nothing
        
    end

    set_margin!(TeamOne, 5)
    set_margin!(TeamTwo, 5)
    set_margin!(SwitchTeamsButton, 10)

    set_margin!(SwitchTeams, 10)


    push_front!(SwitchTeams,TeamOne)
    push_back!(SwitchTeams,TeamTwo)
    push_back!(SwitchTeams,SwitchTeamsButton)

    set_accent_color!(SwitchTeamsButton, WIDGET_COLOR_ACCENT, false)

    set_horizontal_alignment!(SwitchTeams, ALIGNMENT_START)


    println(get_allocated_size(TeamOne))

    # Now we we add the field switcher


    SwitchFields = hbox()
    push_back!(specificButtons,SwitchFields)


    fieldA = DropDown()
    fieldB = DropDown()

    # If not selected it rests on the first value
    fieldAID = 1
    fieldBID = 1

    for (v,i) in enumerate(_swissDrawObject.layout.fieldDF.number)

        # println(i,v)

        push_back!(fieldA,string(i)) do x::DropDown
            fieldAID = v
            return nothing
        end

        push_back!(fieldB,string(i)) do x::DropDown
            fieldBID = v
            return nothing
        end

    end

    SwitchFieldButton = Mousetrap.Button()

    set_child!(SwitchFieldButton, Mousetrap.Label("Switch Fields"))

    connect_signal_clicked!(SwitchFieldButton) do self::Mousetrap.Button

        println("$fieldAID  $fieldBID "   )

        switchFields!(_swissDrawObject, fieldAID, fieldBID)
        activate!(homePage)
        return nothing
        
    end

    push_front!(SwitchFields,fieldA)
    push_back!(SwitchFields,fieldB)
    push_back!(SwitchFields,SwitchFieldButton)

    set_margin!(fieldA, 5)
    set_margin!(fieldB, 5)
    set_margin!(SwitchFieldButton, 5)
    set_margin!(SwitchFields, 5)


    set_horizontal_alignment!(SwitchFields, ALIGNMENT_START)
    set_accent_color!(SwitchFieldButton, WIDGET_COLOR_ACCENT, false)


    push_back!(topWindow,specificButtons)

    push_back!(topWindow,Mousetrap.Label(" --- "))
    cb = CenterBox(ORIENTATION_HORIZONTAL)
    # add the download Current Draw

    push_back!(topWindow,cb)

    downloadDraw = Mousetrap.Button()
    set_center_child!(cb,downloadDraw)

    set_accent_color!(downloadDraw, WIDGET_COLOR_ACCENT, false)


    set_child!(downloadDraw, Mousetrap.Label("Save Round for UltiCentral"))

    connect_signal_clicked!(downloadDraw) do self::Mousetrap.Button
        # call the downloadDraw Popout
        activate!(DownloadDrawPopoutAction)
        return nothing
    end

    push_back!(topWindow,Mousetrap.Label(" --- "))

    mButtons = MenuButtons(home=false)

    set_horizontal_alignment!(mButtons, ALIGNMENT_CENTER)
    set_vertical_alignment!(mButtons, ALIGNMENT_END)

    push_back!(topWindow,mButtons)

    set_child!(mainWindow, topWindow)
    present!(mainWindow)
    return nothing
end
