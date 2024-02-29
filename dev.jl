# include("init.jl")
using Pkg
# set up environment and make sure all packages are present
Pkg.activate(pwd());

using Mousetrap, CSV, JLD2


include("func.jl")
include("uifunc.jl")

_swissDrawObject = load_object("div2Seeding.swissdraw")

main("swiss.draw") do app::Application

    mainWindow = Window(app)

    include("homePage.jl")

    global homePage = Action("example.homePage", app)
    set_function!(homePage) do x::Action
        mainwindow(mainWindow)
    end

    activate!(homePage)

end


