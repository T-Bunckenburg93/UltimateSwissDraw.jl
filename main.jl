# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")


using Mousetrap, CSV, JLD2


filething = []





main("swiss.draw") do app::Application

    mainWindow = Window(app)

    other_window = Window(app)
    set_hide_on_close!(other_window, true)

    connect_signal_close_request!(mainWindow) do self::Window
        destroy!(other_window)
        return WINDOW_CLOSE_REQUEST_RESULT_ALLOW_CLOSE
    end

    defaultWindowSize = Vector2f(1000, 1100)
    
    # Init Swiss Draw Oject
    _swissDrawObject = []

    topWindowOpenLoadDraw = hbox()
    set_title!(mainWindow, "Ultimate Swiss Draw") 


    NewDraw = Mousetrap.Button()
    set_child!(NewDraw, Mousetrap.Label("Create a new Swiss Draw"))

    connect_signal_clicked!(NewDraw) do self::Mousetrap.Button

        # println(get_selected(dropdownMatchup))
        println("Creating New Swiss Draw" )
        # updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
        activate!(NewDrawClicked)
        return nothing
        
    end

    _loadPath = ""
    LoadDraw = Mousetrap.Button()
    set_child!(LoadDraw, Mousetrap.Label("Load existing Draw"))

    connect_signal_clicked!(LoadDraw) do self::Mousetrap.Button
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

        addTeams = Mousetrap.Button()
        set_child!(addTeams, Mousetrap.Label("Add Teams"))

        connect_signal_clicked!(addTeams) do self::Mousetrap.Button
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

        addFields = Mousetrap.Button()
        set_child!(addFields, Mousetrap.Label("Add Field List"))

        connect_signal_clicked!(addFields) do self::Mousetrap.Button
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

        SubmitNewDraw = Mousetrap.Button()
        set_child!(SubmitNewDraw, Mousetrap.Label("Create Draw"))

        connect_signal_clicked!(SubmitNewDraw) do self::Mousetrap.Button

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


        info = Mousetrap.Label("
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
        viewport_rcp = Viewport()
        set_size_request!(viewport_rcp, Vector2f(400,600)) 
        set_child!(viewport_rcp, column_view)

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


        # And add the update Score bit

        updateScore = hbox()
        dropdownMatchup = DropDown()

        # If not selected it rests on the first value
        # matchID = 1
        # find the first missing value of matchID
        # in theory so that the dropdown defaults to the next unentered one
        matchID = findfirst(x->ismissing(x.teamAScore) && ismissing(x.teamBScore) ,_swissDrawObject.currentRound.Games)
        println(matchID)

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

        SwitchFieldButton = Mousetrap.Button()
        set_child!(SwitchFieldButton, Mousetrap.Label("Switch Fields"))
    
        connect_signal_clicked!(SwitchFieldButton) do self::Mousetrap.Button

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
        SaveSwissDraw = Mousetrap.Button()
        set_child!(SaveSwissDraw, Mousetrap.Label("Save Swiss Draw"))
    
        connect_signal_clicked!(SaveSwissDraw) do self::Mousetrap.Button
            println("Saving Swiss Draw")
    
            file_chooser = FileChooser(FILE_CHOOSER_ACTION_SAVE)
            filter = FileFilter("SwissDraw")
            add_allowed_suffix!(filter, "swissdraw")
            add_filter!(file_chooser, filter)ke 
    
            on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
                _savePath = get_path(files[1])
                println(_savePath)
    
                save_object(_savePath, _swissDrawObject)
            end
    
            present!(file_chooser)
            return nothing
        end

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


        # And lets look at the previous results stuff
        previousResults = Mousetrap.Button()
        set_child!(previousResults, Mousetrap.Label("Previous Results"))
    
        connect_signal_clicked!(previousResults) do self::Mousetrap.Button
    
            activate!(refreshPrevResults)
            return nothing
        end
    
        # What if we wanted to run the swiss draw to get new round?
        RunSwissDrawB = Mousetrap.Button()
        set_child!(RunSwissDrawB, Mousetrap.Label("Run Swiss Draw"))
    
        connect_signal_clicked!(RunSwissDrawB) do self::Mousetrap.Button
    
            activate!(runSwissDraw)
            return nothing
        end


        # and some formatting

        center_box = hbox(Mousetrap.Label("
        Current Round

        Update the scores, 
        Switch teams,
        move fields.

        In order to ensure teams don't get forgotten, you can only switch a team with another team.
        ")) 
        topWindow = vbox(center_box,viewport_rcp)
        # set_size_request!(mainWindow, Vector2f(400,600)) 

        push_back!(topWindow,updateScore)
        push_back!(topWindow,SwitchTeams)
        push_back!(topWindow,SwitchFields)
        push_back!(topWindow,Mousetrap.Label(" "))

        primaryButtons = hbox()
            push_back!(primaryButtons,downloadDraw)
            push_back!(primaryButtons,Mousetrap.Label(" --- "))
            push_back!(primaryButtons,SaveSwissDraw)
            push_back!(primaryButtons,Mousetrap.Label(" --- "))
            push_back!(primaryButtons,previousResults)            
            push_back!(primaryButtons,Mousetrap.Label(" --- "))
            push_back!(primaryButtons,RunSwissDrawB)

        push_back!(topWindow,primaryButtons)

        L2 = Mousetrap.Label("
        To share the draw, you can download it as a csv. 

        Once the score are filled out, you can submit the scores and calculate the next round. 
        Note that missing scores will be assumed as 0 
        ")
        push_back!(topWindow,L2)

        set_margin!(center_box, 75)

        set_child!(mainWindow, topWindow)
        set_size_request!(topWindow, defaultWindowSize )
        present!(mainWindow)
    end
    
    refreshPrevResults = Action("refreshPrevResults.page", app) do x::Action

        # clear!()

        # Add the current round info
        column_view = ColumnView()
        viewport_rpr = Viewport()
        set_size_request!(viewport_rpr, Vector2f(400,600)) 
        set_child!(viewport_rpr, column_view)

    
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
        

        SwitchTeamsButton = Mousetrap.Button()
        set_child!(SwitchTeamsButton, Mousetrap.Label("Switch Teams"))
    
        connect_signal_clicked!(SwitchTeamsButton) do self::Mousetrap.Button

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



        SwitchFieldButton = Mousetrap.Button()
        set_child!(SwitchFieldButton, Mousetrap.Label("Switch Fields"))
    
        connect_signal_clicked!(SwitchFieldButton) do self::Mousetrap.Button

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
        SaveSwissDraw = Mousetrap.Button()
        set_child!(SaveSwissDraw, Mousetrap.Label("Save Swiss Draw"))
    
        connect_signal_clicked!(SaveSwissDraw) do self::Mousetrap.Button
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
    
        # And lets look at the Current round
        currentRound = Mousetrap.Button()
        set_child!(currentRound, Mousetrap.Label("Current Round"))
    
        connect_signal_clicked!(currentRound) do self::Mousetrap.Button
    
            activate!(refreshCurrentDraw)
            return nothing
        end

        # And lets look at the analysis Page
        analysis = Mousetrap.Button()
        set_child!(analysis, Mousetrap.Label("Analysis"))
    
        connect_signal_clicked!(analysis) do self::Mousetrap.Button
    
            activate!(AnalyseSwissDraw)
            return nothing
        end
        

        # and some formatting

        center_box = hbox(Mousetrap.Label("SwissDraw")) 
        topWindow = vbox(center_box,viewport_rpr)
        push_back!(topWindow,updateScore)
        push_back!(topWindow,SwitchTeams)
        push_back!(topWindow,SwitchFields)
        push_back!(topWindow,Mousetrap.Label(" "))

        primaryButtons = hbox()
            # push_back!(primaryButtons,downloadDraw)
            push_back!(primaryButtons,Mousetrap.Label(" --- "))
            push_back!(primaryButtons,SaveSwissDraw)            
            push_back!(primaryButtons,Mousetrap.Label(" --- "))
            push_back!(primaryButtons,currentRound)
            push_back!(primaryButtons,Mousetrap.Label(" --- "))
            push_back!(primaryButtons,analysis)

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

            set_widget_at!(column_view, field, v, Mousetrap.Label(string(i.fieldNumber )))
            set_widget_at!(column_view, TeamA, v, Mousetrap.Label(string(i.teamA )))
            set_widget_at!(column_view, TeamB, v, Mousetrap.Label(string(i.teamB )))
            set_widget_at!(column_view, TeamAScoreVal, v, Mousetrap.Label(string(i.teamAScore )))
            set_widget_at!(column_view, TeamBScoreVal, v, Mousetrap.Label(string(i.teamBScore )))

        end

        # Utility Buttons

        RunSwissDraw = Mousetrap.Button()
        set_child!(RunSwissDraw, Mousetrap.Label("Run Swiss Draw"))
    
        connect_signal_clicked!(RunSwissDraw) do self::Mousetrap.Button

            CreateNextRound!(_swissDrawObject)

            activate!(refreshCurrentDraw)
            return nothing
            
        end


        # And lets look at the previous results stuff
        previousResults = Mousetrap.Button()
        set_child!(previousResults, Mousetrap.Label("Previous Results"))
    
        connect_signal_clicked!(previousResults) do self::Mousetrap.Button
    
            activate!(refreshPrevResults)
            return nothing
        end

            
        # And lets look at the Current round
        currentRound = Mousetrap.Button()
        set_child!(currentRound, Mousetrap.Label("Current Round"))
    
        connect_signal_clicked!(currentRound) do self::Mousetrap.Button
    
            activate!(refreshCurrentDraw)
            return nothing
        end

            

        RefreshSwissDraw = Mousetrap.Button()
        set_child!(RefreshSwissDraw, Mousetrap.Label("Refresh Swiss Draw"))
    
        connect_signal_clicked!(RefreshSwissDraw) do self::Mousetrap.Button

            # println("$matchID , teamA: $_tAScore  teamB: $_tBScore  "   )

            refreshNextRound!(_swissDrawObject)
            activate!(refreshCurrentDraw)
            return nothing
            
        end



        # and some formatting

        center_box = hbox(Mousetrap.Label("Run Swiss Draw")) 
        topWindow = vbox(center_box,column_view)
        
        push_back!(topWindow,Mousetrap.Label("---"))

        buttons = hbox()
        push_back!(buttons,RunSwissDraw)
        push_back!(buttons,RefreshSwissDraw)
        push_back!(buttons,currentRound)
        push_back!(buttons,previousResults)

        push_back!(topWindow,buttons)



        set_margin!(center_box, 75)

        set_child!(mainWindow, topWindow)
        present!(mainWindow)

    end



    strengthWindow = Action("strengthWindow.page", app) do x::Action
            
        # topWindow = vbox()

        # prior we regen the data and charts
        prevGames = GenerateStrengthCharts(_swissDrawObject,"charts/strengthChanges")

        rankOrder = sort(combine(groupby(prevGames,:teamA),:rankAFinal => maximum),:rankAFinal_maximum)

        # here I assume that the charts are already made nd are on disk
        strengthNotebook = Notebook()
        set_size_request!(strengthNotebook, defaultWindowSize )

        for i in rankOrder.teamA
                image = Mousetrap.Image()
                create_from_file!(image,"charts\\strengthChanges\\strength changes $i.png" #= load image of size 400x300 =#)
                
                image_display = ImageDisplay()
                create_from_image!(image_display, image)

                push_back!(strengthNotebook, image_display, Mousetrap.Label(i))
        end


        set_tabs_reorderable!(strengthNotebook,true)
        set_is_scrollable!(strengthNotebook,true)

        # set_child!(topWindow, strengthNotebook)

        set_title!(other_window, "Ultimate Swiss Draw") 
        set_child!(other_window, strengthNotebook)
        present!(other_window)

    end


    AnalyseSwissDraw = Action("AnalyseSwissDraw.page", app) do x::Action

        set_title!(mainWindow, "Ultimate Swiss Draw: Analyse Draw") 

        # Utility Buttons
        showStrengths = Mousetrap.Button()
        set_child!(showStrengths, Mousetrap.Label("Show Strength Charts"))
    
        connect_signal_clicked!(showStrengths) do self::Mousetrap.Button
    
            activate!(strengthWindow)
            return nothing
        end
            
        # and add a button to return us to the rest of the analysis

        # And lets look at the analysis Page

        returnToResults = Mousetrap.Button()
        set_child!(returnToResults, Mousetrap.Label("Return to results"))
    
        connect_signal_clicked!(returnToResults) do self::Mousetrap.Button
    
            activate!(refreshPrevResults)
            return nothing
        end

        
        # and some formatting

        center_box = hbox(Mousetrap.Label("Analysis")) 

        topWindow = vbox(center_box)
        set_size_request!(topWindow, defaultWindowSize )
        
        push_back!(topWindow,Mousetrap.Label("---"))
        push_back!(topWindow,showStrengths)
        push_back!(topWindow,Mousetrap.Label("
            How to interpret these chart? 

            All teams start at zero and the red/green arrows are the margin of which they won their first game, 
            this then leads to their strength increasing or decreasing. They then play another team that should be a somewhat similar strength
            The difference between the strengths is also the 'expected' outcome, so if a team plays another team and the strength difference is 5, then there should be a 5 point difference between the two teams. 
            Generally, winning by less than expected or losing by more  than this expected outcome will decrease a teams percieved stength, while winning by more, or losing by less should increase it.
            This can be affected by other games, ie if you lose by a small margin to a team that then does very well later on, then your strength score should rise slightly in response. 
            
            Teams will generally move more earlier on in the swiss draw, and become more settled later on.
        "))
        push_back!(topWindow,Mousetrap.Label("---"))
        push_back!(topWindow,returnToResults)

        # buttons = hbox()
        # push_back!(buttons,RunSwissDraw)
        # push_back!(buttons,RefreshSwissDraw)
        # push_back!(buttons,currentRound)
        # push_back!(buttons,previousResults)

        # push_back!(topWindow,buttons)



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