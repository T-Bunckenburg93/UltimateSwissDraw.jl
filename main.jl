# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());

include("func.jl")


# using OneHotArrays, LinearAlgebra, JuMP, GLPK, Mousetrap, CSV, DataFrames


# dataIn = deepcopy(sampleData)

# fieldDF = deepcopy(_fieldDF)
# # ok, so round 1 is pretty easy. we split the team in half and across the skill gap. 
# # if there is a bye it can go to three places. The middle, the 
# firstRound= CreateFirstRound(dataIn,fieldDF)
# firstRound.gamesToPlay[1].teamA


using Mousetrap, CSV

filething = []




main() do app::Application
    window = Window(app)


    # snippet here, creates widget and adds it to `window' using `set_child!

    set_title!(window, "Swiss Draw") 
    # set_size_request!(window, Vector2f(500,500)) 

        
    _swissDrawObject = SwissDraw(
        DataFrame(
                team = [],
                Rank = []
                ),
        fieldLayout(DataFrame(),
                    Array{Float64}[],
                    0
                    ),
        :middle,
        RoundOfGames(
            Array{Game}[],
            0
            ),
        Array{RoundOfGames}[],
        Array{changeLog}[]
    )


    newDraw = Button()
    set_child!(newDraw, Label("New Draw"))


    connect_signal_clicked!(newDraw) do self::Button
        println("clicked New Draw")

        file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
        filter = FileFilter("CSV")
        add_allowed_suffix!(filter, "csv")
        add_filter!(file_chooser, filter)

        on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
            # println(files)
            push!(filething,files)
            println(files)


            # dump(files)
            # @show typeof(files[1])
    
            # present!(window2)
            # @show get_path(files[1])
            
        end

        present!(file_chooser)
    end



    # Does what it says on the tin

    _teamPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\intial_teams.csv"

    addTeam = Button()
    set_child!(addTeam, Label("Add Teams"))

    connect_signal_clicked!(addTeam) do self::Button
        println("Added Teams")

        file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
        filter = FileFilter("CSV")
        add_allowed_suffix!(filter, "csv")
        add_filter!(file_chooser, filter)

        on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
            _teamPath = get_path(files[1])
            println(files)
            
        end

        present!(file_chooser)
    end

    # Does what it says on the tin
    _fieldPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\field_distances.csv"

    addFields = Button()
    set_child!(addFields, Label("Add Fields"))

    connect_signal_clicked!(addFields) do self::Button
        println("Added Fields")

        file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
        filter = FileFilter("CSV")
        add_allowed_suffix!(filter, "csv")
        add_filter!(file_chooser, filter)

        on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
            _fieldPath = get_path(files[1])
            println(files)
            
        end

        present!(file_chooser)
    end



    # loadDraw = Button()
    # set_child!(loadDraw, Label("LoadDraw"))

    # connect_signal_clicked!(loadDraw) do self::Button
    #     println("clicked Load Draw")
    # end

    getStats = Button()
    set_child!(getStats, Label("Get Intital Draw"))

    connect_signal_clicked!(getStats) do self::Button
        println("clicked get Stats")

        println(_teamPath," & ", _fieldPath)

        _swissDrawObject = createSwissDraw(DataFrame(CSV.File(_teamPath)),DataFrame(CSV.File(_fieldPath)))

        # dump(_swissDrawObject)

        # Once we create the swiss draw, we can update the round calculationa
        column_view = ColumnView()

        field = push_back_column!(column_view, "Field #")

        TeamA = push_back_column!(column_view, "Team A")
        TeamB = push_back_column!(column_view, "Team B")

        TeamAScoreVal = push_back_column!(column_view, "Team A Score")
        TeamBScoreVal = push_back_column!(column_view, "Team B Score")

        UpdateScore = push_back_column!(column_view, "Update Score")
    

        for (v,i) in enumerate(_swissDrawObject.currentRound.Games)


            set_widget_at!(column_view, field, v, Label(string(i.fieldNumber )))
            set_widget_at!(column_view, TeamA, v, Label(string(i.teamA )))
            set_widget_at!(column_view, TeamB, v, Label(string(i.teamB )))
            set_widget_at!(column_view, TeamAScoreVal, v, Label(string(i.teamAScore )))
            set_widget_at!(column_view, TeamBScoreVal, v, Label(string(i.teamBScore )))

            # b = string("b_",v)
            # eval(Meta.parse("$b = Button()"))
            b = Button()

            # set_child!(eval(Meta.parse("$b")), Label("Update Scores"))
            set_child!(b, Label("Update Scores"))
            # connect_signal_clicked!(eval(Meta.parse("$b"))) do self::Button
            connect_signal_clicked!(b) do self::Button
                println("Changing the scores of ",i.teamA," and ",i.teamB)

                updateScoresWindow = Window(app)
                set_hide_on_close!(updateScoresWindow,true) 

                topWindow = vbox()
            
                _tA = i.teamA
                _tB = i.teamB
            
                push_front!(topWindow, Label(string("Enter the scores below:")))
            
               
                submitBox = hbox()
            
                # pull the values out of the spinbuttons into julia
                teamAInputScore = SpinButton(0, 15, 1)
                _tAScore = 0
                connect_signal_value_changed!(teamAInputScore) do self::SpinButton
                    _tAScore =  get_value(self)
                    return nothing
                end
            
                teamBInputScore = SpinButton(0, 15, 1)
                _tBScore = 0
                connect_signal_value_changed!(teamBInputScore) do self::SpinButton
                    _tBScore =  get_value(self)
                    return nothing
                end
            
                # This Adds the buttons and the text input for the get score object     
                push_front!(submitBox,Label(" Scores:    "))
            
                push_back!(submitBox,Label(string(_tA,": ")))
                push_back!(submitBox,teamAInputScore)
            
                push_back!(submitBox,Label(string("     ")))
            
                push_back!(submitBox,Label(string(_tB,": ")))
                push_back!(submitBox,teamBInputScore)
            
                push_back!(topWindow,submitBox)
            
            
                # ok now we need to add a button that takes the values of the spin button, 
                # and uses it to call the updateScore!() function.
            
            
                updateGameButton = Button()
                set_child!(updateGameButton, Label("Submit Scores"))
            
                connect_signal_clicked!(updateGameButton) do self::Button
                    # I want to add run the updateScore!()
                    # and then go back to the previous window
                    println("TA = $_tA $_tAScore, $_tB $_tBScore")
                    # updateScore!(_swissDrawObject,_tA,_tB,_tAScore,_tBScore)
                    present!(window)
                    
                end
            
                push_back!(topWindow,updateGameButton)
                set_child!(updateScoresWindow, topWindow)
            
                present!(updateScoresWindow)
                return nothing


            end
            # set_widget_at!(column_view, UpdateScore, v, eval(Meta.parse("$b")))
            set_widget_at!(column_view, UpdateScore, v, b)


            # Here I want to build a window widget that I can enter the score on

        end
        clear!(topWindow)
        # clear!(center_box)
        # center_box = CenterBox(ORIENTATION_HOsRIZONTAL,addTeam,addFields,getStats) 
        topWindow = vbox(center_box,column_view)
        set_margin!(center_box, 75)
    
    
        set_child!(window, topWindow)
        present!(window)
        return nothing

    end


    column_view = ColumnView()

    field = push_back_column!(column_view, "Field #")
    TeamA = push_back_column!(column_view, "Team A")
    # TeamAScore = push_back_column!(column_view, "Team A Score")
    TeamB = push_back_column!(column_view, "Team B")
    # TeamBScore = push_back_column!(column_view, "Team B Score")

    # get the swiss draw object and pull out data from it
    


    for (v,i) in enumerate(_swissDrawObject.currentRound.Games)

        # firstRound.gamesToPlay[1]
        # set_widget_at!(column_view, column, row_i, Label("0$column_i | 0$row_i"))
        # firstRound.gamesToPlay[1].fieldNumber

        set_widget_at!(column_view, field, v, Label(string(i.fieldNumber )))
        set_widget_at!(column_view, TeamA, v, Label(string(i.teamA )))
        set_widget_at!(column_view, TeamB, v, Label(string(i.teamB )))

    end

    set_expand!(column_view, true)

    # set_child!(window, getStats)
    # set_child!(window, column_view)
    # set_child!(window, loadDraw)







# Need to make a better layout., can't have 2 widgets

    # # box = hbox( newDraw, loadDraw)
    center_box = CenterBox(ORIENTATION_HORIZONTAL,addTeam,addFields,getStats)
    topWindow = vbox(center_box,column_view)
    # set_margin!(center_box, 75)


    set_child!(window, topWindow)
    present!(window)


end



# SwissDraw = createSwissDraw(DataFrame("C:\\Users\\tbunc\\github\\SwissDraw.jl\\intial_teams.csv"),DataFrame("C:\\Users\tbunc\\github\\SwissDraw.jl\\field_distances.csv"))

# DataFrame("C:\\Users\\tbunc\\github\\SwissDraw.jl\\intial_teams.csv")
# DataFrame(CSV.File("C:\\Users\\tbunc\\github\\SwissDraw.jl\\intial_teams.csv"))
