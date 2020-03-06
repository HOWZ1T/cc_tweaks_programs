-- User: dylan
-- Date: 2020-03-06
-- Time: 7:13 p.m.

-- HOWZ1T's Core (HCORE) library of useful utilities for computer craft programming

function getVersion()
    return 1
end

-- returns bool indicating user's response to y/n question
function promptYN(msg)
    repeat
        print(msg + " [y/n]: ")
        local inp = read()
        inp = inp:lower()
    until inp == "y" or inp == "n"

    if inp == "n" then
        return false
    else
        return true
    end
end

-- prompts the user and returns there input as string
function prompt(msg)
    print(msg)
    local inp = read()
    return inp
end

-- returns the entered number as a whole number (integer)
function promptInt(msg)
    local n
    repeat
        print(msg)
        local inp = read()
        n = tonumber(inp)
    until n ~= nil
    return math.floor(n) -- "ensures int"
end