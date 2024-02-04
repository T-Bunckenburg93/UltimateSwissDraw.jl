# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")


using Mousetrap, CSV

filething = []
_fieldPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\field_distances.csv"
_teamPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\intial_teams.csv"



main() do app::Application
    window = Window(app)
    set_title!(window, "Swiss Draw") 

    _swissDrawObject = createSwissDraw(DataFrame(CSV.File(_teamPath)),DataFrame(CSV.File(_fieldPath)))

    # dump(_swissDrawObject)

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
    
            push_back!(dropdownMatchup,string("TeamA: ",i.teamA," vs TeamB: ",i.teamB)) do x::DropDown
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
            println("$matchID , teamA: $_tAScore  teamB: $_tBScore  ")

            updateScore!(_swissDrawObject, Int64(matchID), Int64(_tAScore), Int64(_tBScore))
            activate!(refresh)
            return nothing
            
        end


        push_front!(updateScore,dropdownMatchup)
        push_back!(updateScore,teamAInputScore)
        push_back!(updateScore,teamBInputScore)
        push_back!(updateScore,updateGameButton)

        dump(get_selected(dropdownMatchup))

        # Oh yes. How good. Now lets add the field switcher.


        # and some formatting

        center_box = hbox(Label("SwissDraw")) 
        topWindow = vbox(center_box,column_view)
        push_back!(topWindow,updateScore)
        set_margin!(center_box, 75)

        set_child!(window, topWindow)
        present!(window)
    end

    activate!(refresh)


    # and add a button
  



end