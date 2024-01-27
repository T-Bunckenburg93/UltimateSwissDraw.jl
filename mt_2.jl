# ok so my goal is to load something in from a csv on disk. 
# pls pray for moi


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
    main_window = Window(app)
    other_window = Window(app)
    set_hide_on_close!(other_window, true)

    button = Button()

    set_child!(main_window, button)

    open_other_window = Action("open_other_window.action", app) do x    
        set_is_modal!(other_window, true)
        present!(other_window)

        return nothing
    end
    set_action!(button, open_other_window)

    connect_signal_close_request!(main_window) do self::Window
        destroy!(other_window)
        return WINDOW_CLOSE_REQUEST_RESULT_ALLOW_CLOSE
    end

    present!(main_window)
end



