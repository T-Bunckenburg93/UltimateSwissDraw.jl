

function previous_results(mainWindow)

    set_title!(mainWindow, "Ultimate Swiss Draw: Calculate Next Round") 


        # and some formatting
        topWindow = vbox()
        # set_expand!(topWindow, false)
    
        set_horizontal_alignment!(topWindow, ALIGNMENT_CENTER)
        set_vertical_alignment!(topWindow, ALIGNMENT_START)
    
        viewport = Viewport()
        set_expand!(viewport, true)
    
        set_margin!(viewport, 10)
        set_horizontal_alignment!(viewport, ALIGNMENT_CENTER)
        set_vertical_alignment!(viewport, ALIGNMENT_START)
    
        set_size_request!(viewport, Vector2f(770,700)) 

        

       # Add the current round info
       column_view = ColumnView()

       RoundN = push_back_column!(column_view, "Round Number")
       
       TeamA = push_back_column!(column_view, "Team A")
       TeamB = push_back_column!(column_view, "Team B")

       TeamAScoreVal = push_back_column!(column_view, "Team A Score")
       TeamBScoreVal = push_back_column!(column_view, "Team B Score")
       Field = push_back_column!(column_view, "Field #")
       Streamed = push_back_column!(column_view, "Streamed")

       rowNum = 1
       
       for (x,i) in enumerate(_swissDrawObject.previousRound)

           for (y,j) in enumerate(i.Games)

               set_widget_at!(column_view, RoundN, rowNum, Mousetrap.Label(string( x )))
               set_widget_at!(column_view, TeamA, rowNum, Mousetrap.Label(string(j.teamA )))
               set_widget_at!(column_view, TeamB, rowNum, Mousetrap.Label(string(j.teamB )))
               set_widget_at!(column_view, TeamAScoreVal, rowNum, Mousetrap.Label(string(j.teamAScore )))
               set_widget_at!(column_view, TeamBScoreVal, rowNum, Mousetrap.Label(string(j.teamBScore )))
               set_widget_at!(column_view, Field, rowNum, Mousetrap.Label(string(j.fieldNumber )))
               set_widget_at!(column_view, Streamed, rowNum, Mousetrap.Label(string(j.streamed )))

               rowNum += 1

           end

       end

       set_child!(viewport, column_view)

       # And add the update Score bit

       updateScore = hbox()
       dropdownMatchup = DropDown()
       roundID = 1
       matchID = 1

       # If not selected it rests on the first value

       for (x,i) in enumerate(_swissDrawObject.previousRound)

           for (y,j) in enumerate(i.Games)

               # set_widget_at!(column_view, RoundN, rowNum, Mousetrap.Label(string( x )))

               push_back!(dropdownMatchup,string("Round ",x,": ", j.teamA," vs ",j.teamB)) do z::DropDown
                   roundID = x
                   matchID = y
                   return nothing
               end

           end
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
           # println("$matchID , teamA: $_tAScore  teamB: $_tBScore  "   )

           updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore),Int64(roundID))
           activate!(getPreviousResults)
           return nothing
           
       end


       push_front!(updateScore,dropdownMatchup)
       push_back!(updateScore,teamAInputScore)
       push_back!(updateScore,teamBInputScore)
       push_back!(updateScore,updateGameButton)

       set_margin!(dropdownMatchup, 10)
       set_margin!(teamAInputScore, 10)
       set_margin!(teamBInputScore, 10)
       set_margin!(updateGameButton, 10)

       set_accent_color!(updateGameButton, WIDGET_COLOR_ACCENT, false)


       # dump(get_selected(dropdownMatchup))

       # Oh yes. How good. Now lets add the team switcher.

       SwitchTeams = hbox()

       TeamRound = DropDown()
       TeamOne = DropDown()
       TeamTwo = DropDown()

       # If not selected it rests on the first value
       teamOneID = 1
       teamTwoID = 1
       TeamRoundID = 1

       for (v,i) in enumerate(_swissDrawObject.initialRanking.team)

           push_back!(TeamOne,String(string(i))) do x::DropDown
               teamOneID = v
               return nothing
           end

           push_back!(TeamTwo,String(string(i))) do x::DropDown
               teamTwoID = v
               return nothing
           end

       end

       # and do the same for rounds
       for (v,i) in enumerate(_swissDrawObject.previousRound)

           push_back!(TeamRound,string("Round ",v)) do x::DropDown
               TeamRoundID = v
               return nothing
           end

       end
       

       SwitchTeamsButton = Mousetrap.Button()
       set_child!(SwitchTeamsButton, Mousetrap.Label("Switch Teams"))
   
       connect_signal_clicked!(SwitchTeamsButton) do self::Mousetrap.Button

           println("$TeamRoundID $teamOneID  $teamTwoID")

           println(_swissDrawObject.initialRanking.team[teamOneID],_swissDrawObject.initialRanking.team[teamTwoID])


           # updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
           SwitchTeams!(_swissDrawObject,
               String(_swissDrawObject.initialRanking.team[teamOneID]),
               String(_swissDrawObject.initialRanking.team[teamTwoID]),
               TeamRoundID

               )
               activate!(getPreviousResults)
           return nothing
           
       end

       push_front!(SwitchTeams,TeamRound)
       push_back!(SwitchTeams,TeamOne)
       push_back!(SwitchTeams,TeamTwo)
       push_back!(SwitchTeams,SwitchTeamsButton)

       set_margin!(TeamRound, 10)
       set_margin!(TeamOne, 10)
       set_margin!(TeamTwo, 10)
       set_margin!(SwitchTeamsButton, 10)

       set_accent_color!(SwitchTeamsButton, WIDGET_COLOR_ACCENT, false)



       # Now we we add the field switcher


       SwitchFields = hbox()

       fieldRound = DropDown()
       fieldA = DropDown()
       fieldB = DropDown()

       # If not selected it rests on the first value
       fieldAID = 1
       fieldBID = 1
       fieldRoundID = 1

       for (v,i) in enumerate(_swissDrawObject.layout.fieldDF.number)

           # println(i,v)
   
           push_back!(fieldA,string("Field ",i)) do x::DropDown
               fieldAID = v
               return nothing
           end

           push_back!(fieldB,string("Field ",i)) do x::DropDown
               fieldBID = v
               return nothing
           end

       end

       # and do the same for rounds
       for (v,i) in enumerate(_swissDrawObject.previousRound)

           push_back!(fieldRound,string("Round ",v)) do x::DropDown
               fieldRoundID = v
               return nothing
           end

       end

       SwitchFieldButton = Mousetrap.Button()
       set_child!(SwitchFieldButton, Mousetrap.Label("Switch Fields"))
   
       connect_signal_clicked!(SwitchFieldButton) do self::Mousetrap.Button

           # println(get_selected(dropdownMatchup))
           println("$fieldAID  $fieldBID "   )

           switchFields!(_swissDrawObject, fieldAID, fieldBID, fieldRoundID)
           activate!(getPreviousResults)
           return nothing
           
       end

       push_front!(SwitchFields,fieldRound)
       push_back!(SwitchFields,fieldA)
       push_back!(SwitchFields,fieldB)
       push_back!(SwitchFields,SwitchFieldButton)

       set_margin!(fieldRound, 10)
       set_margin!(fieldA, 10)
       set_margin!(fieldB, 10)
       set_margin!(SwitchFieldButton, 10)

       set_accent_color!(SwitchFieldButton, WIDGET_COLOR_ACCENT, false)

       # add the download Current Draw
       downloadDraw = Mousetrap.Button()
       set_child!(downloadDraw, Mousetrap.Label("Save Round as CSV"))
   
       connect_signal_clicked!(downloadDraw) do self::Mousetrap.Button
       
           # Save current round Object
       
           file_chooser = FileChooser(FILE_CHOOSER_ACTION_SAVE)
           filter = FileFilter("CSV")
           add_allowed_suffix!(filter, "csv")
           add_filter!(file_chooser, filter)
       
           on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
       
               _df = DataFrame(teamA = String[], teamB = String[], FieldNumber = Int64[])
               for i in _swissDrawObject.currentRound.Games
                   push!(_df,[i.teamA,i.teamB,i.fieldNumber])
               end
       
               _downloadPath = get_path(files[1])
   
               CSV.write(_downloadPath, _df)
               println("Saved the current round as a CSV")
               println(_downloadPath)
       
           end
       
           present!(file_chooser)
           return nothing
       end

       # and some formatting

       topWindow = vbox(viewport)
       push_back!(topWindow,updateScore)
       push_back!(topWindow,SwitchTeams)
       push_back!(topWindow,SwitchFields)

    #    set_margin!(updateScore, 10)
    #    set_margin!(SwitchTeams, 10)
    #    set_margin!(SwitchFields, 10)
    #    set_margin!(analysis, 10)


       push_back!(topWindow,Mousetrap.Label(" --- "))

       mButtons = MenuButtons(previousResults=false)
       set_horizontal_alignment!(mButtons, ALIGNMENT_CENTER)
       set_vertical_alignment!(mButtons, ALIGNMENT_END)
   
       push_back!(topWindow,mButtons)

       set_child!(mainWindow, topWindow)
       present!(mainWindow)
    return nothing
end
