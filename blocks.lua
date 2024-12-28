local Blocks = {}

function Blocks:getShape(type)
    local shapes = {
        I = {{1, 1, 1, 1}},
        O = {{1, 1}, {1, 1}},
        T = {{0, 1, 0}, {1, 1, 1}},
        L = {{1, 1, 0}, {0, 1, 1}}
    }
    return shapes[type]
end

return Blocks
