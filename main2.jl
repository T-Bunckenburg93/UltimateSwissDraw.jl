# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());

using Mousetrap, CSV, JLD2

include("func.jl")
include("uifunc.jl")



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
    global _swissDrawObject = []

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
            activate!(homePage)

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
            activate!(homePage)
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


    include("homePage.jl")
    global homePage = Action("example.homePage", app)
    set_function!(homePage) do x::Action
        mainwindow(mainWindow)
    end




        push_front!(topWindowOpenLoadDraw,NewDraw)
        push_back!(topWindowOpenLoadDraw,LoadDraw)
    
        set_child!(mainWindow, topWindowOpenLoadDraw)
        present!(mainWindow)
end    