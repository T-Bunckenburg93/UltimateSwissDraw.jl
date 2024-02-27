

function run_draw(mainWindow)

    set_title!(mainWindow, "Ultimate Swiss Draw: Calculate Next Round") 

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


        set_child!(viewport_rcp, column_view)
    
        push_back!(topWindow,viewport_rcp)

        # Utility Buttons

        RunSwissDraw = Mousetrap.Button()
        set_accent_color!(RunSwissDraw, WIDGET_COLOR_ACCENT, false)

        set_child!(RunSwissDraw, Mousetrap.Label("Run Swiss Draw"))
    
        connect_signal_clicked!(RunSwissDraw) do self::Mousetrap.Button


            # overlay = Overlay()
            # remove_child!(mainWindow)
            # set_child!(overlay, topWindow)

            # spinner = Spinner()
            # set_is_spinning!(spinner, true)
            # add_overlay!(overlay, spinner)

            # set_child!(mainWindow,overlay)
            # present!(mainWindow)
            
            CreateNextRound!(_swissDrawObject, refresh = false)

            # and take us back
            activate!(homePage)
            return nothing
            
        end
            

        RefreshSwissDraw = Mousetrap.Button()
        set_accent_color!(RefreshSwissDraw, WIDGET_COLOR_ACCENT , false)

        set_child!(RefreshSwissDraw, Mousetrap.Label("Refresh Swiss Draw"))
    
        connect_signal_clicked!(RefreshSwissDraw) do self::Mousetrap.Button

            # println("$matchID , teamA: $_tAScore  teamB: $_tBScore  "   )

            
            CreateNextRound!(_swissDrawObject, refresh = true)
            activate!(homePage)
            println("refresh")
            return nothing
            
        end


        info = Mousetrap.Label("
Please ensure that the above scores are correct.

Note that calculating the next round can take a few moments, depending on size of the draw and your system. Let it run, and don't immediately exit if it says the window is unresponsive. 


        ")

        width_clamp_frame = ClampFrame(750, ORIENTATION_HORIZONTAL)
        set_child!(width_clamp_frame,info)
        # set_size_request!(info, Vector2f(770,0)) 
        set_wrap_mode!(info,LABEL_WRAP_MODE_ONLY_ON_WORD)

        push_back!(topWindow,width_clamp_frame)


        push_back!(topWindow,Mousetrap.Label("---"))
        
        buttons = hbox()
        push_back!(buttons,RunSwissDraw)
        push_back!(buttons,RefreshSwissDraw)


        set_margin!(buttons, 10)
        set_margin!(RunSwissDraw, 10)
        set_margin!(RefreshSwissDraw, 10)


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
