# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")


using Mousetrap, CSV, JLD2


filething = []







main() do app::Application

    mainWindow = Window(app)
    
    # Init Swiss Draw Oject
    _swissDrawObject = []

    topWindowOpenLoadDraw = hbox()
    set_title!(mainWindow, "Ultimate Swiss Draw") 

    NewDraw = Button()
    set_child!(NewDraw, Label("Create a new Swiss Draw"))

    connect_signal_clicked!(NewDraw) do self::Button

        # println(get_selected(dropdownMatchup))
        println("Creating New Swiss Draw" )
        # updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
        activate!(NewDrawClicked)
        return nothing
        
    end

    _loadPath = ""
    LoadDraw = Button()
    set_child!(LoadDraw, Label("Load existing Draw"))

    connect_signal_clicked!(LoadDraw) do self::Button
        println("Saving Swiss Draw")

        file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
        filter = FileFilter("SwissDraw")
        add_allowed_suffix!(filter, "swissdraw")
        add_filter!(file_chooser, filter)

        on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
            _loadPath = get_path(files[1])
            println(_loadPath)

            # save_object(_savePath, _swissDrawObject)
            _swissDrawObject = load_object(_loadPath)
            activate!(refreshCurrentDraw)

        end

        present!(file_chooser)
    end



#= 
    Create the page to present when user hits New Draw
=# 

    NewDrawClicked = Action("NewDrawClicked.page", app) do x::Action

        set_title!(mainWindow, "Ultimate Swiss Draw: Create Draw") 

        # ok, so we want to refresh the page, with new bits and bobs. 

        # _teamPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\intial_teams.csv"
        _teamPath = ""

        addTeams = Button()
        set_child!(addTeams, Label("Add Teams"))

        connect_signal_clicked!(addTeams) do self::Button
            println("Added Teams")

            file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
            filter = FileFilter("CSV")
            add_allowed_suffix!(filter, "csv")
            add_filter!(file_chooser, filter)

            on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
                _teamPath = get_path(files[1])
                println(_teamPath)

            end

            present!(file_chooser)
        end

        # Does what it says on the tin
        # _fieldPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\field_distances.csv"
        _fieldPath = ""

        addFields = Button()
        set_child!(addFields, Label("Add Field List"))

        connect_signal_clicked!(addFields) do self::Button
            println("Added Fields")

            file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
            filter = FileFilter("CSV")
            add_allowed_suffix!(filter, "csv")
            add_filter!(file_chooser, filter)

            on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
                _fieldPath = get_path(files[1])
                println(files)
                # return nothing
            end

            present!(file_chooser)
            # return nothing
        end

        SubmitNewDraw = Button()
        set_child!(SubmitNewDraw, Label("Create Draw"))

        connect_signal_clicked!(SubmitNewDraw) do self::Button

            println("Created New Swiss Draw")
            _swissDrawObject = createSwissDraw(DataFrame(CSV.File(_teamPath)),DataFrame(CSV.File(_fieldPath)))

            # dump(_swissDrawObject)
            activate!(SwissDrawCreated)
            return nothing


        end

        topWindowOpenLoadDraw = vbox()

        selectButtons = hbox()

        push_front!(selectButtons,addTeams)
        push_back!(selectButtons,addFields)

        push_front!(topWindowOpenLoadDraw,selectButtons)


        info = Label("
    Columns needed:

        Team spreadsheet:
            'team' - The name and identifier of the team. 
                Note and odd number of teams will result in 
                a 'BYE' team being created.
            'rank' - The inital seeding. if you have no 
                    idea of the seeding random is fine

        Field spreadsheet:
            'number' - The number and identifier of the field
            'x' - the x position of the field
            'y' - the y position of the field
            'stream' - if the field will be streamed or not. 
                    This is intended for as many teams to 
                    get a streamed game. 
        ")


        push_back!(topWindowOpenLoadDraw,SubmitNewDraw)
        push_back!(topWindowOpenLoadDraw,info)

        println(pwd())

        image_display2 = ImageDisplay()
        create_from_file!(image_display2, "\\field_example.png")

        image_display = ImageDisplay(string(pwd(),"\\field_example.png"))

        push_back!(topWindowOpenLoadDraw,image_display)
        push_back!(topWindowOpenLoadDraw,image_display2)



        remove_child!(mainWindow)
        set_child!(mainWindow,topWindowOpenLoadDraw)

        present!(mainWindow)
        return nothing


    end
    

    SwissDrawCreated = Action("SwissDrawCreated.page", app) do x::Action

        remove_child!(mainWindow)

        activate!(refreshCurrentDraw)
        return nothing


    end


    refreshCurrentDraw = Action("refreshCurrentDraw.page", app) do x::Action

        set_title!(mainWindow, "Ultimate Swiss Draw: Current Draw") 


        # Add the current round info
        column_view = ColumnView()

        field = push_back_column!(column_view, "Field #")

        TeamA = push_back_column!(column_view, "Team A")
        TeamB = push_back_column!(column_view, "Team B")

        TeamAScoreVal = push_back_column!(column_view, "Team A Score")
        TeamBScoreVal = push_back_column!(column_view, "Team B Score")


        for (v,i) in enumerate(_swissDrawObject.currentRound.Games)

            set_widget_at!(column_view, field, v, Label(string(i.fieldNumber )))
            set_widget_at!(column_view, TeamA, v, Label(string(i.teamA )))
            set_widget_at!(column_view, TeamB, v, Label(string(i.teamB )))
            set_widget_at!(column_view, TeamAScoreVal, v, Label(string(i.teamAScore )))
            set_widget_at!(column_view, TeamBScoreVal, v, Label(string(i.teamBScore )))

        end


        # And add the update Score bit

        updateScore = hbox()
        dropdownMatchup = DropDown()

        # If not selected it rests on the first value
        matchID = 1

        # Make the callback values a number that represents the index of the game into julia
        for (v,i) in enumerate(_swissDrawObject.currentRound.Games)
    
            push_back!(dropdownMatchup,string(i.teamA," vs ",i.teamB)) do x::DropDown
                matchID = v
                return nothing
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

        updateGameButton = Button()
        set_child!(updateGameButton, Label("Submit Scores"))
    
        connect_signal_clicked!(updateGameButton) do self::Button

            # println(get_selected(dropdownMatchup))
            println("$matchID , teamA: $_tAScore  teamB: $_tBScore  "   )

            updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
            activate!(refreshCurrentDraw)
            return nothing
            
        end


        push_front!(updateScore,dropdownMatchup)
        push_back!(updateScore,teamAInputScore)
        push_back!(updateScore,teamBInputScore)
        push_back!(updateScore,updateGameButton)

        # dump(get_selected(dropdownMatchup))

        # Oh yes. How good. Now lets add the team switcher.

        SwitchTeams = hbox()

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

        SwitchTeamsButton = Button()
        set_child!(SwitchTeamsButton, Label("Switch Teams"))
    
        connect_signal_clicked!(SwitchTeamsButton) do self::Button

            # println(get_selected(dropdownMatchup))
            println("$teamOneID  $teamTwoID "   )

            println(_swissDrawObject.initialRanking.team[teamOneID],_swissDrawObject.initialRanking.team[teamTwoID])


            # updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
            SwitchTeams!(_swissDrawObject,
                String(_swissDrawObject.initialRanking.team[teamOneID]),
                String(_swissDrawObject.initialRanking.team[teamTwoID])
                )
            activate!(refreshCurrentDraw)
            return nothing
            
        end

        push_front!(SwitchTeams,TeamOne)
        push_back!(SwitchTeams,TeamTwo)
        push_back!(SwitchTeams,SwitchTeamsButton)



        # Now we we add the field switcher


        SwitchFields = hbox()

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

        SwitchFieldButton = Button()
        set_child!(SwitchFieldButton, Label("Switch Fields"))
    
        connect_signal_clicked!(SwitchFieldButton) do self::Button

            # println(get_selected(dropdownMatchup))
            println("$fieldAID  $fieldBID "   )

            # println(_swissDrawObject.initialRanking.team[teamOneID],_swissDrawObject.initialRanking.team[teamTwoID])

            # updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
            # SwitchTeams!(_swissDrawObject,
            #     _swissDrawObject.initialRanking.team[teamOneID],
            #     _swissDrawObject.initialRanking.team[teamTwoID]
            #     )

            switchFields!(_swissDrawObject, fieldAID, fieldBID)
            activate!(refreshCurrentDraw)
            return nothing
            
        end

        push_front!(SwitchFields,fieldA)
        push_back!(SwitchFields,fieldB)
        push_back!(SwitchFields,SwitchFieldButton)


        _savePath = ""
        SaveSwissDraw = Button()
        set_child!(SaveSwissDraw, Label("Save Swiss Draw"))
    
        connect_signal_clicked!(SaveSwissDraw) do self::Button
            println("Saving Swiss Draw")
    
            file_chooser = FileChooser(FILE_CHOOSER_ACTION_SAVE)
            filter = FileFilter("SwissDraw")
            add_allowed_suffix!(filter, "swissdraw")
            add_filter!(file_chooser, filter)
    
            on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
                _savePath = get_path(files[1])
                println(_savePath)
    
                save_object(_savePath, _swissDrawObject)
            end
    
            present!(file_chooser)
            return nothing
        end

        # add the download Current Draw
        downloadDraw = Button()
        set_child!(downloadDraw, Label("Save Round as CSV"))
    
        connect_signal_clicked!(downloadDraw) do self::Button
        
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


        # And lets look at the previous results stuff
        previousResults = Button()
        set_child!(previousResults, Label("Previous Results"))
    
        connect_signal_clicked!(previousResults) do self::Button
    
            activate!(refreshPrevResults)
            return nothing
        end
    
        # What if we wanted to run the swiss draw to get new round?
        RunSwissDrawB = Button()
        set_child!(RunSwissDrawB, Label("Run Swiss Draw"))
    
        connect_signal_clicked!(RunSwissDrawB) do self::Button
    
            activate!(runSwissDraw)
            return nothing
        end


        # and some formatting

        center_box = hbox(Label("
        Current Round

        Update the scores, 
        Switch teams,
        move fields.

        In order to ensure teams don't get forgotten, you can only switch a team with another team.
        ")) 
        topWindow = vbox(center_box,column_view)
        push_back!(topWindow,updateScore)
        push_back!(topWindow,SwitchTeams)
        push_back!(topWindow,SwitchFields)
        push_back!(topWindow,Label(" "))

        primaryButtons = hbox()
            push_back!(primaryButtons,downloadDraw)
            push_back!(primaryButtons,Label(" --- "))
            push_back!(primaryButtons,SaveSwissDraw)
            push_back!(primaryButtons,Label(" --- "))
            push_back!(primaryButtons,previousResults)            
            push_back!(primaryButtons,Label(" --- "))
            push_back!(primaryButtons,RunSwissDrawB)

        push_back!(topWindow,primaryButtons)

        L2 = Label("
        To share the draw, you can download it as a csv. 

        Once the score are filled out, you can submit the scores and calculate the next round. 
        Note that missing scores will be assumed as 0 
        ")
        push_back!(topWindow,L2)

        set_margin!(center_box, 75)

        set_child!(mainWindow, topWindow)
        present!(mainWindow)
    end

    refreshPrevResults = Action("refreshPrevResults.page", app) do x::Action

        # clear!()

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

                set_widget_at!(column_view, RoundN, rowNum, Label(string( x )))
                set_widget_at!(column_view, TeamA, rowNum, Label(string(j.teamA )))
                set_widget_at!(column_view, TeamB, rowNum, Label(string(j.teamB )))
                set_widget_at!(column_view, TeamAScoreVal, rowNum, Label(string(j.teamAScore )))
                set_widget_at!(column_view, TeamBScoreVal, rowNum, Label(string(j.teamBScore )))
                set_widget_at!(column_view, Field, rowNum, Label(string(j.fieldNumber )))
                set_widget_at!(column_view, Streamed, rowNum, Label(string(j.streamed )))

                rowNum += 1

            end

        end


        # And add the update Score bit

        updateScore = hbox()
        dropdownMatchup = DropDown()
        roundID = 1
        matchID = 1

        # If not selected it rests on the first value

        for (x,i) in enumerate(_swissDrawObject.previousRound)

            for (y,j) in enumerate(i.Games)

                # set_widget_at!(column_view, RoundN, rowNum, Label(string( x )))

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

        updateGameButton = Button()
        set_child!(updateGameButton, Label("Submit Scores"))
    
        connect_signal_clicked!(updateGameButton) do self::Button

            # println(get_selected(dropdownMatchup))
            # println("$matchID , teamA: $_tAScore  teamB: $_tBScore  "   )

            updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore),Int64(roundID))
            activate!(refreshPrevResults)
            return nothing
            
        end


        push_front!(updateScore,dropdownMatchup)
        push_back!(updateScore,teamAInputScore)
        push_back!(updateScore,teamBInputScore)
        push_back!(updateScore,updateGameButton)

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
        

        SwitchTeamsButton = Button()
        set_child!(SwitchTeamsButton, Label("Switch Teams"))
    
        connect_signal_clicked!(SwitchTeamsButton) do self::Button

            # println(get_selected(dropdownMatchup))
            println("$teamOneID  $teamTwoID "   )

            println(_swissDrawObject.initialRanking.team[teamOneID],_swissDrawObject.initialRanking.team[teamTwoID])


            # updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
            SwitchTeams!(_swissDrawObject,
                String(_swissDrawObject.initialRanking.team[teamOneID]),
                String(_swissDrawObject.initialRanking.team[teamTwoID]),
                TeamRound

                )
            activate!(refreshPrevResults)
            return nothing
            
        end

        push_front!(SwitchTeams,TeamRound)
        push_back!(SwitchTeams,TeamOne)
        push_back!(SwitchTeams,TeamTwo)
        push_back!(SwitchTeams,SwitchTeamsButton)



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



        SwitchFieldButton = Button()
        set_child!(SwitchFieldButton, Label("Switch Fields"))
    
        connect_signal_clicked!(SwitchFieldButton) do self::Button

            # println(get_selected(dropdownMatchup))
            println("$fieldAID  $fieldBID "   )

            switchFields!(_swissDrawObject, fieldAID, fieldBID, fieldRoundID)
            activate!(refreshPrevResults)
            return nothing
            
        end

        push_front!(SwitchFields,fieldRound)
        push_back!(SwitchFields,fieldA)
        push_back!(SwitchFields,fieldB)
        push_back!(SwitchFields,SwitchFieldButton)


        _savePath = ""
        SaveSwissDraw = Button()
        set_child!(SaveSwissDraw, Label("Save Swiss Draw"))
    
        connect_signal_clicked!(SaveSwissDraw) do self::Button
            println("Saving Swiss Draw")
    
            file_chooser = FileChooser(FILE_CHOOSER_ACTION_SAVE)
            filter = FileFilter("SwissDraw")
            add_allowed_suffix!(filter, "swissdraw")
            add_filter!(file_chooser, filter)
    
            on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
                _savePath = get_path(files[1])
                println(_savePath)
    
                save_object(_savePath, _swissDrawObject)
            end
    
            present!(file_chooser)
            return nothing
        end

        # add the download Current Draw
        downloadDraw = Button()
        set_child!(downloadDraw, Label("Save Round as CSV"))
    
        connect_signal_clicked!(downloadDraw) do self::Button
        
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
    
        # And lets look at the Current round
        currentRound = Button()
        set_child!(currentRound, Label("Current Round"))
    
        connect_signal_clicked!(currentRound) do self::Button
    
            activate!(refreshCurrentDraw)
            return nothing
        end


        # and some formatting

        center_box = hbox(Label("SwissDraw")) 
        topWindow = vbox(center_box,column_view)
        push_back!(topWindow,updateScore)
        push_back!(topWindow,SwitchTeams)
        push_back!(topWindow,SwitchFields)
        push_back!(topWindow,Label(" "))

        primaryButtons = hbox()
            # push_back!(primaryButtons,downloadDraw)
            push_back!(primaryButtons,Label(" --- "))
            push_back!(primaryButtons,SaveSwissDraw)            
            push_back!(primaryButtons,Label(" --- "))
            push_back!(primaryButtons,currentRound)
            # push_back!(primaryButtons,Label(" --- "))
            # push_back!(primaryButtons,RunSwissDrawB)

        push_back!(topWindow,primaryButtons)

        set_margin!(center_box, 75)

        set_child!(mainWindow, topWindow)
        present!(mainWindow)
        return nothing
    end



    # And run the swiss draw thinggggg

    runSwissDraw = Action("runSwissDraw.page", app) do x::Action



        # Add the current round info
        column_view = ColumnView()

        field = push_back_column!(column_view, "Field #")

        TeamA = push_back_column!(column_view, "Team A")
        TeamB = push_back_column!(column_view, "Team B")

        TeamAScoreVal = push_back_column!(column_view, "Team A Score")
        TeamBScoreVal = push_back_column!(column_view, "Team B Score")


        for (v,i) in enumerate(_swissDrawObject.currentRound.Games)

            set_widget_at!(column_view, field, v, Label(string(i.fieldNumber )))
            set_widget_at!(column_view, TeamA, v, Label(string(i.teamA )))
            set_widget_at!(column_view, TeamB, v, Label(string(i.teamB )))
            set_widget_at!(column_view, TeamAScoreVal, v, Label(string(i.teamAScore )))
            set_widget_at!(column_view, TeamBScoreVal, v, Label(string(i.teamBScore )))

        end

        # Utility Buttons

        RunSwissDraw = Button()
        set_child!(RunSwissDraw, Label("Run Swiss Draw"))
    
        connect_signal_clicked!(RunSwissDraw) do self::Button

            # println("$matchID , teamA: $_tAScore  teamB: $_tBScore  "   )

            CreateNextRound!(_swissDrawObject)
            activate!(refreshCurrentDraw)
            return nothing
            
        end

        RefreshSwissDraw = Button()
        set_child!(RefreshSwissDraw, Label("Refresh Swiss Draw"))
    
        connect_signal_clicked!(RefreshSwissDraw) do self::Button

            # println("$matchID , teamA: $_tAScore  teamB: $_tBScore  "   )

            refreshNextRound!(_swissDrawObject)
            activate!(refreshCurrentDraw)
            return nothing
            
        end



        # and some formatting

        center_box = hbox(Label("Run Swiss Draw")) 
        topWindow = vbox(center_box,column_view)
        
        push_back!(topWindow,Label("---"))

        buttons = hbox()
        push_back!(buttons,RunSwissDraw)
        push_back!(buttons,RefreshSwissDraw)

        push_back!(topWindow,buttons)



        set_margin!(center_box, 75)

        set_child!(mainWindow, topWindow)
        present!(mainWindow)

    end

    # activate!(SwissDrawCreated)




    push_front!(topWindowOpenLoadDraw,NewDraw)
    push_back!(topWindowOpenLoadDraw,LoadDraw)

    set_child!(mainWindow, topWindowOpenLoadDraw)
    present!(mainWindow)


end