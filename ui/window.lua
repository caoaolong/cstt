Slab = require("Slab")

window = {}

function window.draw(windows)
    for index, value in ipairs(windows) do
        if value.Show then
            value.Show = Slab.BeginWindow(value.ID, {
                Title = value.Title, TitleH = 26, AutoSizeWindow = false, IsOpen = true, W = 200
            })
            Slab.EndWindow()
        end
    end
end

return window