
function DownloadDrawPopout(other_window)
    # strengthWindow = Action("strengthWindow.page", app) do x::Action
            
    # topWindow = vbox()

    topWindow = vbox()
    # set_expand!(topWindow, false)

    set_horizontal_alignment!(topWindow, ALIGNMENT_CENTER)
    set_vertical_alignment!(topWindow, ALIGNMENT_START)

    viewport = Viewport()
    set_expand!(viewport, true)

    set_margin!(viewport, 10)
    set_horizontal_alignment!(viewport, ALIGNMENT_CENTER)
    set_vertical_alignment!(viewport, ALIGNMENT_START)

    set_size_request!(viewport, Vector2f(770,700)) 

        # Add the current round info
        column_view = ColumnView()

        field = push_back_column!(column_view, "Field #")

        TeamA = push_back_column!(column_view, "Team A")
        TeamB = push_back_column!(column_view, "Team B")

        df = DataFrame(TeamA = String[], TeamB = String[],fieldNumber= Int[])


        for (v,i) in enumerate(_swissDrawObject.currentRound.Games)


            set_widget_at!(column_view, field, v, Mousetrap.Label(string(i.fieldNumber )))
            set_widget_at!(column_view, TeamA, v, Mousetrap.Label(string(i.teamA )))
            set_widget_at!(column_view, TeamB, v, Mousetrap.Label(string(i.teamB )))

            push!(df,(i.teamA,i.teamB,i.fieldNumber))

        end

        set_child!(viewport, column_view)
    
        push_back!(topWindow,viewport)


        # Need to add buttons for:
        # startDate
        dataFields = vbox()
        set_horizontal_alignment!(dataFields, ALIGNMENT_CENTER)
        set_vertical_alignment!(dataFields, ALIGNMENT_START)


        startDateBox = hbox()
            set_horizontal_alignment!(startDateBox, ALIGNMENT_START)
            set_vertical_alignment!(startDateBox, ALIGNMENT_CENTER)
            set_margin!(startDateBox, 10)

        startDate = Entry()
            set_margin!(startDate, 10)
        set_text!(startDate, "dd/mm/yyyy")
            push_back!(startDateBox,Mousetrap.Label("Start Date:"))
            push_back!(startDateBox,startDate)

        startTimeBox = hbox()
            set_horizontal_alignment!(startTimeBox, ALIGNMENT_START)
            set_vertical_alignment!(startTimeBox, ALIGNMENT_CENTER)
            set_margin!(startTimeBox, 10)

        startTime = Entry()
            set_margin!(startTime, 10)
        set_text!(startTime, "HH:MM")
            push_back!(startTimeBox,Mousetrap.Label("Start Time:"))
            push_back!(startTimeBox,startTime)

        finishTimeBox = hbox()
            set_horizontal_alignment!(finishTimeBox, ALIGNMENT_START)
            set_vertical_alignment!(finishTimeBox, ALIGNMENT_CENTER)
            set_margin!(finishTimeBox, 10)

        finishTime = Entry()
            set_margin!(finishTime, 10)

        set_text!(finishTime, "HH:MM")
            push_back!(finishTimeBox,Mousetrap.Label("Finish Time:"))
            push_back!(finishTimeBox,finishTime)

        venueNameBox = hbox()
            set_horizontal_alignment!(venueNameBox, ALIGNMENT_START)
            set_vertical_alignment!(venueNameBox, ALIGNMENT_CENTER)
            set_margin!(venueNameBox, 10)

        venueName = Entry()
        set_margin!(venueName, 10)

        set_text!(venueName, "Ultimate Park")
            push_back!(venueNameBox,Mousetrap.Label("Venue Name:"))
            push_back!(venueNameBox,venueName)

    push_back!(topWindow,startDateBox)
    push_back!(topWindow,startTimeBox)
    push_back!(topWindow,finishTimeBox)
    push_back!(topWindow,venueNameBox)

    push_back!(topWindow,Mousetrap.Label(" --- "))


    
    downloadDraw = Mousetrap.Button()
        set_horizontal_alignment!(downloadDraw, ALIGNMENT_START)
        set_vertical_alignment!(downloadDraw, ALIGNMENT_CENTER)
        set_margin!(downloadDraw, 10)

    # set_accent_color!(RunSwissDraw, WIDGET_COLOR_ACCENT, false)

    set_child!(downloadDraw, Mousetrap.Label("downloadDraw"))


    connect_signal_clicked!(downloadDraw) do self::Mousetrap.Button
    
        file_chooser = FileChooser(FILE_CHOOSER_ACTION_SAVE)
        filter = FileFilter("CSV")
        add_allowed_suffix!(filter, "csv")
        add_filter!(file_chooser, filter)
    
        on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
    
            df.startDate .= get_text(startDate)
            df.startTime .= get_text(startTime)
            df.finishDate .= get_text(startDate)
            df.finishTime .= get_text(finishTime)
            df.venueName .= get_text(venueName)
    
            DataFrames.select!(df,[:TeamA,:TeamB,:startDate,:startTime,:finishDate,:finishTime,:venueName])

            _downloadPath = get_path(files[1])

            CSV.write(_downloadPath, df)
            println("Saved the current round as a CSV for ultiCentral")
            println(_downloadPath)

            # now we hide the window and return to the main page
            close!(other_window) #note that this doesn't destroy, just closes.
            activate!(homePage)

        end
    
        present!(file_chooser)
        return nothing
    end

    push_back!(topWindow,downloadDraw)

    push_back!(topWindow,Mousetrap.Label(" --- "))


    set_child!(other_window, topWindow)
    present!(other_window)

end