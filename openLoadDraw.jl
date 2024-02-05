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
                
            end

            present!(file_chooser)
        end

        SubmitNewDraw = Button()
        set_child!(SubmitNewDraw, Label("Create Draw"))

        connect_signal_clicked!(SubmitNewDraw) do self::Button

            println("Created New Swiss Draw")
            _swissDrawObject = createSwissDraw(DataFrame(CSV.File(_teamPath)),DataFrame(CSV.File(_fieldPath)))

            dump(_swissDrawObject)
            activate!(SwissDrawCreated)

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

    end
    

    SwissDrawCreated = Action("SwissDrawCreated.page", app) do x::Action

        SaveSwissDraw = Button()
        set_child!(SaveSwissDraw, Label("Save Swiss Draw"))

        connect_signal_clicked!(SaveSwissDraw) do self::Button

            println("Saved Swiss Draw")
            # _swissDrawObject = createSwissDraw(DataFrame(CSV.File(_teamPath)),DataFrame(CSV.File(_fieldPath)))

        end

        remove_child!(openLoad)

        topWindowOpenLoadDraw = vbox()
        push_front!(topWindowOpenLoadDraw,SaveSwissDraw)
        set_child!(openLoad,topWindowOpenLoadDraw)

        present!(openLoad)

    end
    # activate!(SwissDrawCreated)




    push_front!(topWindowOpenLoadDraw,NewDraw)
    push_back!(topWindowOpenLoadDraw,LoadDraw)

    set_child!(openLoad, topWindowOpenLoadDraw)
    present!(openLoad)


end