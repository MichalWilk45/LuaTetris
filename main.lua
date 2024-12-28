local Game = require("game")

function love.load()
    love.window.setTitle("Tetris")
    love.window.setMode(400, 600)
    Game:load()
end

function love.update(dt)
    Game:update(dt)
end

function love.draw()
    Game:draw()
end

function love.keypressed(key)
    Game:keypressed(key)
end
