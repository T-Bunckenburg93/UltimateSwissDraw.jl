# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")


using Mousetrap, CSV


filething = []







main() do app::Application

    openLoad = Window(app)
    
    # Init Swiss Draw Oject
    _swissDrawObject = []

    topWindowOpenLoadDraw = hbox()
    set_title!(openLoad, "Ultimate Swiss Draw") 

    NewDraw = Button()
    set_child!(NewDraw, Label("Create a new Swiss Draw"))

    connect_signal_clicked!(NewDraw) do self::Button

        # println(get_selected(dropdownMatchup))
        println("Creating New Swiss Draw" )
        # updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
        activate!(NewDrawClicked)
        return nothing
        
    end

    LoadDraw = Button()
    set_child!(LoadDraw, Label("Load an existing Swiss Draw"))

    connect_signal_clicked!(LoadDraw) do self::Button

        # println(get_selected(dropdownMatchup))
        println("Loading existing Swiss Draw" )
        # updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
        # activate!(refresh)
        return nothing
        
    end

#= 
    Create the page to present when user hits New Draw
=# 

    NewDrawClicked = Action("NewDrawClicked.page", app) do x::Action

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

            dump(_swissDrawObject)
            activate!(SwissDrawCreated)
            return nothing


        end

        topWindowOpenLoadDraw = vbox()

        selectButtons = hbox()

        push_front!(selectButtons,addTeams)
        push_back!(selectButtons,addFields)

        push_front!(topWindowOpenLoadDraw,selectButtons)
        push_back!(topWindowOpenLoadDraw,SubmitNewDraw)


        remove_child!(openLoad)
        set_child!(openLoad,topWindowOpenLoadDraw)

        present!(openLoad)
        return nothing


    end
    

    SwissDrawCreated = Action("SwissDrawCreated.page", app) do x::Action

        remove_child!(openLoad)

        # topWindowOpenLoadDraw = vbox()
        # push_front!(topWindowOpenLoadDraw,SaveSwissDraw)
        # set_child!(openLoad,topWindowOpenLoadDraw)

        activate!(refresh)
        return nothing


    end


    refresh = Action("refresh.page", app) do x::Action

        # clear!()

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
            activate!(refresh)
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
                _swissDrawObject.initialRanking.team[teamOneID],
                _swissDrawObject.initialRanking.team[teamTwoID]
                )
            activate!(refresh)
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
            activate!(refresh)
            return nothing
            
        end

        push_front!(SwitchFields,fieldA)
        push_back!(SwitchFields,fieldB)
        push_back!(SwitchFields,SwitchFieldButton)


        # Add the Save button
        SaveSwissDraw = Button()
        set_child!(SaveSwissDraw, Label("Save Swiss Draw"))

        connect_signal_clicked!(SaveSwissDraw) do self::Button

            println("Saved Swiss Draw")

        end


        # and some formatting

        center_box = hbox(Label("SwissDraw")) 
        topWindow = vbox(center_box,column_view)
        push_back!(topWindow,updateScore)
        push_back!(topWindow,SwitchTeams)
        push_back!(topWindow,SwitchFields)
        push_back!(topWindow,Label("---------"))
        push_back!(topWindow,SaveSwissDraw)
        set_margin!(center_box, 75)

        set_child!(openLoad, topWindow)
        present!(openLoad)
    end


    # activate!(SwissDrawCreated)


    push_front!(topWindowOpenLoadDraw,NewDraw)
    push_back!(topWindowOpenLoadDraw,LoadDraw)

    set_child!(openLoad, topWindowOpenLoadDraw)
    present!(openLoad)


end