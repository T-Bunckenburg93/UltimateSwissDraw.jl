

function run_draw(mainWindow)

    set_title!(mainWindow, "Ultimate Swiss Draw: Run Swiss Draw") 

        # Add the current round info
        column_view = ColumnView()

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


        # and some formatting
        topWindow = vbox()
        # set_expand!(topWindow, false)

        set_horizontal_alignment!(topWindow, ALIGNMENT_CENTER)
        set_vertical_alignment!(topWindow, ALIGNMENT_START)

        viewport_rcp = Viewport()
        set_expand!(viewport_rcp, true)
    
        set_margin!(viewport_rcp, 10)
        set_horizontal_alignment!(viewport_rcp, ALIGNMENT_CENTER)
        set_vertical_alignment!(viewport_rcp, ALIGNMENT_START)
    
        set_size_request!(viewport_rcp, Vector2f(770,700)) 
        set_child!(viewport_rcp, column_view)
    
        push_back!(topWindow,viewport_rcp)

        # Utility Buttons

        RunSwissDraw = Mousetrap.Button()
        set_child!(RunSwissDraw, Mousetrap.Label("Run Swiss Draw"))
    
        connect_signal_clicked!(RunSwissDraw) do self::Mousetrap.Button

            CreateNextRound!(_swissDrawObject)

            # and take us back
            activate!(homePage)
            return nothing
            
        end
            

        # RefreshSwissDraw = Mousetrap.Button()
        # set_child!(RefreshSwissDraw, Mousetrap.Label("Refresh Swiss Draw"))
    
        # connect_signal_clicked!(RefreshSwissDraw) do self::Mousetrap.Button

        #     # println("$matchID , teamA: $_tAScore  teamB: $_tBScore  "   )

        #     refreshNextRound!(_swissDrawObject)
        #     activate!(homePage)
        #     return nothing
            
        # end


        push_back!(topWindow,Mousetrap.Label("---"))
        
        buttons = hbox()
        push_back!(buttons,RunSwissDraw)
        # push_back!(buttons,RefreshSwissDraw)


        set_margin!(buttons, 10)
        set_margin!(RunSwissDraw, 10)
        # set_margin!(RefreshSwissDraw, 10)


        push_back!(topWindow,buttons)
        
        set_horizontal_alignment!(buttons, ALIGNMENT_CENTER)
        set_vertical_alignment!(buttons, ALIGNMENT_CENTER)

    push_back!(topWindow,Mousetrap.Label(" --- "))

    mButtons = MenuButtons(runSwissDraw=false)

    set_horizontal_alignment!(mButtons, ALIGNMENT_CENTER)
    set_vertical_alignment!(mButtons, ALIGNMENT_END)

    push_back!(topWindow,mButtons)

    set_child!(mainWindow, topWindow)
    # set_size_request!(topWindow, defaultWindowSize )
    present!(mainWindow)
    return nothing
end