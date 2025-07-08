-- UI-knapper
local buttons = {
    { label = "Start Game", action = function() print("Start Game") end },
    { label = "Options", action = function() print("Options") end },
    { label = "Quit", action = function() love.event.quit() end }
}

local button_width = 300
local button_height = 50
local spacing = 20
local hovered = nil

function love.load()
    love.window.setTitle("Mock UI Menu")
    love.window.setMode(800, 600)
    font = love.graphics.newFont(24)
    love.graphics.setFont(font)
end

function love.draw()
    -- Baggrund
    love.graphics.clear(0.1, 0.1, 0.1)

    -- Titel
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Main Menu", 0, 100, love.graphics.getWidth(), "center")

    -- Knapper
    local total_height = (#buttons * button_height) + ((#buttons - 1) * spacing)
    local start_y = (love.graphics.getHeight() / 2) - (total_height / 2)

    for i, btn in ipairs(buttons) do
        local x = (love.graphics.getWidth() / 2) - (button_width / 2)
        local y = start_y + (i - 1) * (button_height + spacing)

        -- Hover-effekt
        if hovered == i then
            love.graphics.setColor(0.3, 0.6, 1.0)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end

        love.graphics.rectangle("fill", x, y, button_width, button_height, 10, 10)

        -- Tekst
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(btn.label, x, y + 12, button_width, "center")
    end
end

function love.mousemoved(mx, my)
    hovered = nil
    local total_height = (#buttons * button_height) + ((#buttons - 1) * spacing)
    local start_y = (love.graphics.getHeight() / 2) - (total_height / 2)

    for i = 1, #buttons do
        local x = (love.graphics.getWidth() / 2) - (button_width / 2)
        local y = start_y + (i - 1) * (button_height + spacing)

        if mx >= x and mx <= x + button_width and my >= y and my <= y + button_height then
            hovered = i
            break
        end
    end
end

function love.mousepressed(mx, my, button)
    if button == 1 and hovered then
        buttons[hovered].action()
    end
end