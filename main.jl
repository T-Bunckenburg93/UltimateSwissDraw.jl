include("init.jl")

# using OneHotArrays, LinearAlgebra, JuMP, GLPK, Mousetrap, CSV, DataFrames


dataIn = deepcopy(sampleData)

fieldDF = deepcopy(_fieldDF)
# ok, so round 1 is pretty easy. we split the team in half and across the skill gap. 
# if there is a bye it can go to three places. The middle, the 
firstRound= CreateFirstRound(dataIn,fieldDF)
firstRound.gamesToPlay[1].teamA


using Mousetrap

main() do app::Application
    window = Window(app)


    # snippet here, creates widget and adds it to `window' using `set_child!

    set_title!(window, "Swiss Draw") 
    # set_size_request!(window, Vector2f(500,500)) 

    # set_size_request!(window, Vector2f(500,500)) 

    newDraw = Button()
    set_child!(newDraw, Label("New Draw"))


    connect_signal_clicked!(newDraw) do self::Button
        println("clicked New Draw")
        file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
        filter = FileFilter("CSV")
        add_allowed_suffix!(filter, "csv")
        add_filter!(file_chooser, filter)
        present!(file_chooser)


        on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
            println(files)
            @show typeof(files[1])
    
            # present!(window2)
            @show get_path(files[1])


        end
    end


    loadDraw = Button()
    set_child!(loadDraw, Label("LoadDraw"))

    connect_signal_clicked!(loadDraw) do self::Button
        println("clicked Load Draw")
    end

    getStats = Button()
    set_child!(getStats, Label("Get Stats"))

    connect_signal_clicked!(getStats) do self::Button
        println("clicked get Stats")
    end



    column_view = ColumnView()

    field = push_back_column!(column_view, "Field #")
    TeamA = push_back_column!(column_view, "Team A")
    # TeamAScore = push_back_column!(column_view, "Team A Score")
    TeamB = push_back_column!(column_view, "Team B")
    # TeamBScore = push_back_column!(column_view, "Team B Score")

    for i in 1:size(firstRound.gamesToPlay,1)

        # firstRound.gamesToPlay[1]
        # set_widget_at!(column_view, column, row_i, Label("0$column_i | 0$row_i"))
        # firstRound.gamesToPlay[1].fieldNumber

        set_widget_at!(column_view, field, i, Label(string(firstRound.gamesToPlay[i].fieldNumber )))
        set_widget_at!(column_view, TeamA, i, Label(string(firstRound.gamesToPlay[i].teamA )))
        set_widget_at!(column_view, TeamB, i, Label(string(firstRound.gamesToPlay[i].teamB )))

        # firstRound.gamesToPlay[1].teamA
        
        # firstRound.gamesToPlay[1].teamB
    end

            

    set_expand!(column_view, true)
    set_child!(window, column_view)



# Need to make a better layout., can't have 2 widgets

    # # box = hbox( newDraw, loadDraw)
    # center_box = CenterBox(ORIENTATION_HORIZONTAL,newDraw,loadDraw,getStats)
    # set_margin!(center_box, 75)


    # set_child!(window, center_box)
    present!(window)


end




