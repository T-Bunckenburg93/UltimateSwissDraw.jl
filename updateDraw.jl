# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());
include("func.jl")


using Mousetrap, CSV

filething = []
_fieldPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\field_distances.csv"
_teamPath = "C:\\Users\\tbunc\\github\\SwissDraw.jl\\intial_teams.csv"

fieldLayout

# draw = createSwissDraw(DataFrame(CSV.File(_teamPath,stringtype=String)),DataFrame(CSV.File(_fieldPath)))

# draw.


main() do app::Application
    window = Window(app)
    set_title!(window, "Swiss Draw") 

    _swissDrawObject = createSwissDraw(DataFrame(CSV.File(_teamPath,stringtype=String)),DataFrame(CSV.File(_fieldPath)))

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
    
            push_back!(TeamOne,string(i)) do x::DropDown
                teamOneID = v
                return nothing
            end

            push_back!(TeamTwo,string(i)) do x::DropDown
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


        # Finally, we add the field switcher


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


        # and some formatting

        center_box = hbox(Label("SwissDraw")) 
        topWindow = vbox(center_box,column_view)
        push_back!(topWindow,updateScore)
        push_back!(topWindow,SwitchTeams)
        push_back!(topWindow,SwitchFields)
        set_margin!(center_box, 75)

        set_child!(window, topWindow)
        present!(window)
    end

    activate!(refresh)


    # and add a button
  



end