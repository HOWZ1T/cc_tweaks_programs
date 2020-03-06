-- User: dylan
-- Date: 2020-03-05
-- Time: 9:17 p.m.

-- TL (Turtle Library)
-- Provides useful functions for programming turtles

-- directions
local DIRS = {
    NORTH = 0,
    EAST = 1,
    SOUTH = 2,
    WEST = 3
}

-- turtle state
local tstate = {
    dir = nil,
    xyz = nil
}

-- gets api version
function getVersion()
    return 1
end

function initiateTurtle()
    print("enter current facing direction:\n1. NORTH\n2. EAST\n3. SOUTH\n4. WEST\n")
    local inp = read()
    local d = tonumber(inp)
    if d < DIRS.NORTH or d > DIRS.WEST then
        error("invalid direction")
    end
    tstate.dir = d

    print("enter current x position: ")
    inp = read()
    d = tonumber(d)
    local x = d

    print("enter current y position: ")
    inp = read()
    d = tonumber(d)
    local y = d

    print("enter current z position: ")
    inp = read()
    d = tonumber(d)
    local z = d

    tstate.xyz = vector.new(x, y, z)
end

-- returns bool indicating if turtle was initialized
function programaticInit(dir, xyz)
    if dir < DIRS.NORTH or dir > DIRS.WEST then
        return false
    end

    tstate.dir = dir
    tstate.xyz = xyz

    return true
end

function getDir()
    return tstate.dir
end

function getPos()
    return tstate.xyz
end

------------------------------------------START MOVEMENT: all funcs return bool
function turnRight()
    local r = turtle.turnRight()
    if not r then
        return false
    end
    tstate.dir = (tstate.dir + 1) % 4
    return true
end

function turnLeft()
    local r = turtle.turnLeft()
    if not r then
        return false
    end
    tstate.dir = (tstate.dir - 1) % 4
    return true
end

function forward()
    local r = turtle.forward()
    if not r then
        return false
    end

    local d = tstate.dir
    local p = tstate.xyz
    if d == DIRS.NORTH then
        p.z = p.z - 1
    elseif d == DIRS.EAST then
        p.x = p.x + 1
    elseif d == DIRS.SOUTH then
        p.z = p.z + 1
    elseif d == DIRS.WEST then
        p.x = p.x - 1
    end
    tstate.xyz = p
    return true
end

function backward()
    local r = turtle.backward()
    if not r then
        return false
    end

    local d = tstate.dir
    local p = tstate.xyz
    if d == DIRS.NORTH then
        p.z = p.z + 1
    elseif d == DIRS.EAST then
        p.x = p.x - 1
    elseif d == DIRS.SOUTH then
        p.z = p.z - 1
    elseif d == DIRS.WEST then
        p.x = p.x + 1
    end
    tstate.xyz = p
    return true
end

function up()
    local r = turtle.up()
    if not r then
        return false
    end

    tstate.xyz.y = tstate.xyz.y + 1
    return true
end

function down()
    local r = turtle.down()
    if not r then
        return false
    end

    tstate.xyz.y = tstate.xyz.y - 1
    return true
end

function face(dir) -- faces the turtle to the given direction
    if dir < DIRS.NORTH or dir > DIRS.WEST then
        return false
    end

    while dir ~= tstate.dir do
        local r = turnRight()
        if not r then
            return false
        end
    end

    return true
end

function moveTo(pos)
    -- handle y
    while tstate.xyz.y ~= pos.y do
        if tstate.xyz.y > pos.y then
            local r = up()
            if not r then
                return false
            end
        elseif tstate.xyz.y < pos.y then
            local r = down()
            if not r then
                return false
            end
        end
    end

    -- handle x
    -- set dir
    if tstate.xyz.x > pos.x then
        local r = face(DIRS.EAST)
        if not r then
            return false
        end
    elseif tstate.xyz.x < pos.x then
        local r = face(DIRS.WEST)
        if not r then
            return false
        end
    end

    while tstate.xyz.x ~= pos.x do
        local r = forward()
        if not r then
            return false
        end
    end

    -- handle z
    -- set dir
    if tstate.xyz.z > pos.z then
        local r = face(DIRS.SOUTH)
        if not r then
            return false
        end
    elseif tstate.xyz.z < pos.z then
        local r = face(DIRS.NORTH)
        if not r then
            return false
        end
    end

    while tstate.xyz.z ~= pos.z do
        local r = forward()
        if not r then
            return false
        end
    end

    return true
end

--------------------------------------------END MOVEMENT


--------------------------------------------START FUEL MANAGEMENT

-- returns bool indicating if turtle needs refuel
-- diff: specifies the required difference from the fuel limit to consider needing refuel
-- a diff of 0 switches this feature off
function needsRefuel(diff)
    local lim = turtle.getFuelLimit()
    if lim == 0 then
        return false
    end

    return turtle.getFuelLevel() < lim and lim - turtle.getFuelLevel() >= diff
end

-- returns true if refuelled
-- else false if couldn't refuel
function refuel()
    print('attempting to refuel...')
    local initFuel = turtle.getFuelLevel()
    local prevSlot = turtle.getSelectedSlot()
    --attempts to refuel by cycling through items in the turtles inventory
    for i = 1, 16, 1 do  --cycle through inventory
        turtle.select(i)
        local hasFuel = true
        while hasFuel == true and needsRefuel(0) == true do
            hasFuel = turtle.refuel(1)
        end
    end
    turtle.select(prevSlot) --reset turtle back to it's pre-refuel slot

    if turtle.getFuelLevel() > initFuel then --determines if turtle was refuelled
        print('refueled by ' + tostring(turtle.getFuelLevel() - initFuel))
        return true
    end

    return false
end

--------------------------------------------END FUEL MANAGEMENT

--------------------------------------------START INVENTORY MANAGEMENT

function hasSpace(slot)
    return turtle.getItemSpace(slot) > 0 or turtle.getItemCount(slot) == 0
end

function isEmpty(slot)
    return turtle.getItemCount(slot) == 0
end

function hasInvSpace()
    for i = 1, 16, 1 do
        if hasSpace(slot) then
            return true
        end
    end
    return false
end

function hasInvEmptySlot()
    for i = 1, 16, 1 do
        if isEmpty(slot) then
            return true
        end
    end
    return false
end
--------------------------------------------END INVENTORY MANAGEMENT
