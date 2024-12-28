local Blocks = require("blocks")
local Game = {}

local boardHeight = 20
local boardWidth = 10
local blockSize = 20

function Game:load()
    self.board = {}
    for y = 1, boardHeight do
        self.board[y] = {}
        for x = 1, boardWidth do
            self.board[y][x] = 0  -- 0 oznacza pustą komórkę
        end
    end
    self.activeBlock = self:spawnNewBlock() -- Losowo generowany klocek
    self.blockX, self.blockY = 5, 0 -- Początkowa pozycja klocka
    self.gravityTimer = 0 -- Timer do opadania klocka
    self.speed = 0.5 -- Czas pomiędzy opadaniem klocków
end

function Game:update(dt)
    -- Ustawienie timera dla grawitacji (opadanie klocków)
    self.gravityTimer = self.gravityTimer + dt
    if self.gravityTimer >= self.speed then
        self.gravityTimer = 0
        self:blockFall()  -- Klocek opada
    end
end

function Game:keypressed(key)
    if key == "left" then
        -- Sprawdzenie, czy klocek nie wyjdzie poza lewą granicę planszy
        if self.blockX > 1 then
            self.blockX = self.blockX - 1
        end
    elseif key == "right" then
        -- Sprawdzenie, czy klocek nie wyjdzie poza prawą granicę planszy
        if self.blockX + #self.activeBlock[1] - 1 <= 10 then
            self.blockX = self.blockX + 1
        end
    elseif key == "down" then
        -- Sprawdzenie, czy klocek nie wyjdzie poza dolną granicę planszy
        if self.blockY + #self.activeBlock <= 20 then
            self.blockY = self.blockY + 1
        end
    end
end


-- Funkcja opadającego klocka
function Game:blockFall()
    self.blockY = self.blockY + 1

    -- Sprawdzenie, czy klocek dotknął dołu planszy lub innych klocków
    if self:checkCollision() then
        self:lockBlock()  -- Zablokuj klocek na planszy
        self:clearFullLines()  -- Usuwanie pełnych linii
        self.activeBlock = self:spawnNewBlock()  -- Nowy klocek
        self.blockX, self.blockY = 5, 0  -- Reset pozycji
        if self:checkCollision() then
            -- Gra kończy się, jeśli nie ma miejsca na nowy klocek
            print("Game Over!")
        end
    end
end

-- Funkcja sprawdzająca kolizję klocka z planszą
function Game:checkCollision()
    -- Iterate through each block in the active block
    for y = 1, #self.activeBlock do
        for x = 1, #self.activeBlock[y] do
            if self.activeBlock[y][x] == 1 then
                -- Calculate the actual position on the board
                local boardX = self.blockX + x - 1  -- Adjust for 0-based indexing on the board
                local boardY = self.blockY + y - 1  -- Adjust for 0-based indexing on the board

                -- Check if the block has reached the bottom of the screen (bottom edge)
                if boardY >= boardHeight then
                    return true
                end

                -- Check if the block is colliding with other blocks (check the row below the active block)
                if self.board[boardY + 1] and self.board[boardY + 1][boardX] == 1 then
                    return true
                end
            end
        end
    end

    -- No collision found
    return false
end



-- Funkcja blokująca klocek na planszy
function Game:lockBlock()
    for y = 1, #self.activeBlock do
        for x = 1, #self.activeBlock[y] do
            if self.activeBlock[y][x] == 1 then
                local boardX = self.blockX + x 
                local boardY = self.blockY + y  
                print("Locking block at", boardX, boardY)


                -- Tworzymy nową linię, jeśli nie istnieje
                if not self.board[boardY] then
                    print("Creating new board line", boardY)

                    self.board[boardY] = {}
                end

                -- Blokowanie klocka na planszy
                self.board[boardY-1][boardX] = 1
            end
        end
    end
end




-- Funkcja usuwająca pełne linie
function Game:clearFullLines()
    for y = #self.board, 1, -1 do
        -- Upewnij się, że linia istnieje przed jej przetwarzaniem
        if self.board[y] then
            local isFull = true
            for x = 1, boardWidth do
            
                -- Sprawdzamy, czy w tej linii nie ma pustych miejsc
                if self.board[y][x] == 0 then
                    isFull = false
                    break
                end
            end
            -- Jeśli linia jest pełna, usuwamy ją
            if isFull then
                table.remove(self.board, y)  -- Usuwanie pełnej linii
                table.insert(self.board, 1, {})  -- Dodanie pustej linii na górze
            end
        end
    end
end



-- Funkcja losująca nowy klocek
function Game:spawnNewBlock()
    local types = {"I", "O", "T", "L"}
    local randomType = types[love.math.random(1, #types)]
    return Blocks:getShape(randomType)  -- Funkcja w module Blocks powinna zwracać klocki w odpowiednim formacie
end


function Game:draw()
    -- Rysowanie planszy (zablokowane klocki)
    for y = 1, #self.board do
        for x = 1, #self.board[y] do
            if self.board[y][x] == 1 then
                -- Rysowanie zablokowanych klocków na planszy
                love.graphics.setColor(0.5, 0.5, 0.5)  -- Ustaw kolor (szary)
                love.graphics.rectangle("fill", (x-1) * blockSize, (y - 1) * blockSize, blockSize, blockSize)
            end
        end
    end

    -- Rysowanie aktywnego klocka
    for y = 1, #self.activeBlock do
        for x = 1, #self.activeBlock[y] do
            if self.activeBlock[y][x] == 1 then
                -- Ustaw kolor dla aktywnego klocka (np. czerwony)
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", (self.blockX + x - 1) * 20, (self.blockY + y - 1) * 20, 20, 20)
            end
        end
    end
    love.graphics.setColor(1, 1, 1)  -- Kolor krawędzi (biały)
    love.graphics.rectangle("line", 20, 0, (boardWidth -1)* 20, boardHeight * 20)  -- Rysowanie prostokąta wokół planszy
end

return Game
