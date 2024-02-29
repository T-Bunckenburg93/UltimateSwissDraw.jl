

function generate_child(label::String) ::Widget
    child = Frame(Overlay(Separator(), Mousetrap.Label(label)))
    set_size_request!(child, Vector2f(150, 150))
    set_margin!(child, 10)
    return child
end

# prevGames = GenerateStrengthCharts(_swissDrawObject,"charts/strengthChanges")

# filter(x-> x.teamA == "Whakatu" && x.roundPlayed != 0  , prevGames)

function standings(mainWindow)

    set_title!(mainWindow, "Ultimate Swiss Draw: Calculate Next Round") 

    prevGames = GenerateStrengthCharts(_swissDrawObject,"charts/strengthChanges")

    rankOrder = sort(combine(groupby(prevGames,:teamA),:rankAFinal => maximum),:rankAFinal_maximum)

    # and some formatting
    topWindow = vbox()
    set_expand!(topWindow, false)

    set_horizontal_alignment!(topWindow, ALIGNMENT_CENTER)
    set_vertical_alignment!(topWindow, ALIGNMENT_START)


    stack = Stack()
    set_size_request!(stack, Vector2f(770,700)) 

    rank = rankings(_swissDrawObject, allGames = false)

    for i in eachrow(rank)

        heading = string(i.rank,": ",i.teamA, " ", round(i.strength,digits = 2) )

        stackWindow = vbox()

        titles = hbox()
        set_margin_horizontal!(titles, 50)
        set_margin_vertical!(titles, 10)

        push_back!(stackWindow,titles)
        push_back!(titles, Mousetrap.Label(i.teamA))
        push_back!(titles, Mousetrap.Label(string(round(i.strength,digits = 4))))

        # create the colls 

        # Add the current round info
        column_view = ColumnView()
        viewport = Viewport()
        set_size_request!(viewport, Vector2f(650,400)) 
        set_child!(viewport, column_view)

        rnd = push_back_column!(column_view, "Round")

        TeamA = push_back_column!(column_view, "Team A")
        TeamB = push_back_column!(column_view, "Team B")

        outcome = push_back_column!(column_view, "Outcome")

        fieldNumber = push_back_column!(column_view, "Field")
        streamed = push_back_column!(column_view, "Streamed")



        for (v,j) in enumerate(eachrow(filter(x-> x.teamA == i.teamA && x.roundPlayed != 0  , prevGames)))

            set_widget_at!(column_view, rnd, v, Mousetrap.Label(string(j.roundPlayed )))
            set_widget_at!(column_view, TeamA, v, Mousetrap.Label(string(j.teamA )))
            set_widget_at!(column_view, TeamB, v, Mousetrap.Label(string(j.teamB )))
            set_widget_at!(column_view, outcome, v, Mousetrap.Label(string( j.teamAscore,"-",j.teamBscore )))
            set_widget_at!(column_view, fieldNumber, v, Mousetrap.Label(string(j.field)))
            set_widget_at!(column_view, streamed, v, Mousetrap.Label(string(j.streamed )))

        end

        set_expand!(viewport, true)
        push_back!(stackWindow,viewport)

        # and add the strngth chart

        image = Mousetrap.Image()
        teamName = i.teamA
        create_from_file!(image,"charts\\strengthChanges\\strength changes $teamName.png" #= load image of size 400x300 =#)
        
        image_display = ImageDisplay()
        create_from_image!(image_display, image)
        set_size_request!(image_display, Vector2f(500,500)) 
        set_expand!(image_display, true)
        # set_expand!(image, true)

        set_horizontal_alignment!(image_display, ALIGNMENT_START)
        set_vertical_alignment!(image_display, ALIGNMENT_START)

        push_back!(stackWindow, image_display )


        # will need to create the rest here

        # add_child!(stack,  generate_child(i.teamA), heading )
        add_child!(stack,  stackWindow, heading )
    end
    


    # add_child!(stack, generate_child("Child #01"), "Page #01")
    # add_child!(stack, generate_child("Child #02"), "Page #02")
    # add_child!(stack, generate_child("Child #03"), "Page #03")

    stack_model = get_selection_model(stack)
    connect_signal_selection_changed!(stack_model, stack) do x::SelectionModel, position::Integer, n_items::Integer, stack::Stack
        println("Current stack page is now: $(get_child_at(stack, position))")
    end

    push_back!(topWindow, hbox(StackSidebar(stack), stack)) # Create StackSidebar from stack


    # Now to create extra buttons
    extraButtons = hbox()
    set_horizontal_alignment!(extraButtons, ALIGNMENT_CENTER)
    set_vertical_alignment!(extraButtons, ALIGNMENT_END)
    set_margin!(extraButtons, 10)



    downloadRankings = Mousetrap.Button()

    set_accent_color!(downloadRankings, WIDGET_COLOR_ACCENT, false)

    set_child!(downloadRankings, Mousetrap.Label("Download Rankings"))

    connect_signal_clicked!(downloadRankings) do self::Mousetrap.Button
    
        # Save current round Object
    
        file_chooser = FileChooser(FILE_CHOOSER_ACTION_SAVE)
        filter = FileFilter("CSV")
        add_allowed_suffix!(filter, "csv")
        add_filter!(file_chooser, filter)
    
        on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
    
            rankDf = rankings(_swissDrawObject, allGames = false)

            DataFrames.select!(rankDf,([
                    :rank => :Rank,
                    :teamA => :Team,
                    :strength => :Strength,
                    :played => :GamesPlayed,
                    :margin => :TotalMargin,
                    :winA => :Wins,
                    :lossA => :Losses,
                    :drawA => :Draws,
                    :byeA=> :Byes]))
       
    
            _downloadPath = get_path(files[1])

            CSV.write(_downloadPath, rankDf)
            println("Saved the current rankings as a CSV")
            println(_downloadPath)
    
        end
    
        present!(file_chooser)
        return nothing
    end

    push_back!(extraButtons,downloadRankings)

    # Add popout window for all strengths

    
    popOutStength = Mousetrap.Button()

    set_accent_color!(popOutStength, WIDGET_COLOR_ACCENT, false)

    set_child!(popOutStength, Mousetrap.Label("All Strengths"))

    connect_signal_clicked!(popOutStength) do self::Mousetrap.Button
        activate!(strengthsPopoutAction)
    end
    push_back!(extraButtons,popOutStength)


    # and now go to the ALL buttons.
    push_back!(topWindow,Mousetrap.Label(" --- "))

    push_back!(topWindow,extraButtons)


    push_back!(topWindow,Mousetrap.Label(" --- "))

    mButtons = MenuButtons(runSwissDraw=false)

    set_horizontal_alignment!(mButtons, ALIGNMENT_CENTER)
    set_vertical_alignment!(mButtons, ALIGNMENT_END)

    push_back!(topWindow,mButtons)

    set_child!(mainWindow, topWindow)
    # set_size_request!(topWindow, defaultWindowSize )
    present!(mainWindow)
    return nothing
end


