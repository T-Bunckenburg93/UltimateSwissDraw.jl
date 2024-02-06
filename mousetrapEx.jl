using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());

include("func.jl")
using Mousetrap, CSV

_teamPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\intial_teams.csv"
_fieldPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\field_distances.csv"
_swissDrawObject = createSwissDraw(DataFrame(CSV.File(_teamPath)),DataFrame(CSV.File(_fieldPath)))


main() do app::Application
    window = Window(app)

    _teamPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\intial_teams.csv"
    _fieldPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\field_distances.csv"
    _swissDrawObject = createSwissDraw(DataFrame(CSV.File(_teamPath)),DataFrame(CSV.File(_fieldPath)))


    topWindow = hbox()

    submit = Button()
    set_child!(submit, Label("Submit Score"))

    teamAInputScore = SpinButton(0, 15, 1)
    teamBInputScore = SpinButton(0, 15, 1)

    push_front!(topWindow,submit)
    push_back!(topWindow,teamAInputScore)
    push_back!(topWindow,teamBInputScore)


    set_child!(window, topWindow)

    # End of snippet

    present!(window)
end







main() do app::Application



    updateScoresWindow = Window(app)

    topWindow = vbox()

    _tA = "Bagel"
    _tB = "Toast"

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
        present!()
        
    end


    push_back!(topWindow,updateGameButton)

    set_child!(updateScoresWindow, topWindow)



    present!(updateScoresWindow)
end
