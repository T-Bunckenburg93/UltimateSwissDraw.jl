
function strengthsPopout(other_window)
    # strengthWindow = Action("strengthWindow.page", app) do x::Action
            
    # topWindow = vbox()

    # prior we regen the data and charts
    # prevGames = GenerateStrengthCharts(_swissDrawObject,"charts/strengthChanges")

    rankOrder = rankings(_swissDrawObject, allGames = false)

    # here I assume that the charts are already made and are on disk
    strengthNotebook = Notebook()
    # set_size_request!(strengthNotebook,  Vector2f(800, 800) )

    for i in rankOrder.teamA
            image = Mousetrap.Image()
            create_from_file!(image,"charts\\strengthChanges\\strength changes $i.png" #= load image of size 400x300 =#)
            
            image_display = ImageDisplay()
            create_from_image!(image_display, image)
            set_size_request!(image_display,  Vector2f(1000, 1000) )

            push_back!(strengthNotebook, image_display, Mousetrap.Label(i))
    end


    set_tabs_reorderable!(strengthNotebook,true)
    set_is_scrollable!(strengthNotebook,true)

    # set_child!(topWindow, strengthNotebook)

    set_title!(other_window, "Ultimate Swiss Draw") 
    set_child!(other_window, strengthNotebook)
    present!(other_window)

end