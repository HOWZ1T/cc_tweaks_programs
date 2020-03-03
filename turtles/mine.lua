-- User: dylan
-- Date: 2020-03-02
-- Time: 10:14 p.m.

-- GLOBALS --
CHEST_LOC = nil
NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

-- returns bool indicating if turtle needs refuel
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
    for i = 1, 16, 1 do
        turtle.select(i)
        local hasFuel = true
        while hasFuel == true and needsRefuel(0) == true do
            hasFuel = turtle.refuel(1)
        end

        if turtle.getFuelLevel() > initFuel then
            print('refueled by ' + tostring(turtle.getFuelLevel() - initFuel))
            return true
        end
    end

    return false
end


-- determines if the given block data is a chest or not
function isChest(data)
    if string.find(data.name, "chest") then
        return true
    end
    return false
end

function t180()
    turtle.turnRight()
    turtle.turnRight()
end

-- returns true if able to face chest, else false
function faceChest()
    for i = 1, 4, 1 do
        local success, dat = turtle.inspect()
        if success == true then
            if isChest(dat) then
                return true
            end
        end

        turtle.turnRight()
    end

    return false
end

-- returns true if able to locate chest
-- side effect, sets the CHEST_LOC global var to the correct pos
function locateChest()
    local x, y, z = gps.locate(5)
    if not x then
        print("gps failed...")
        return false
    end

    local turtleLoc = vector.new()
    local res = faceChest()
    if res == true then
        CHEST_LOC = turtleLoc
        print("chest location: ", tostring(CHEST_LOC))
        return true
    end

    return false
end

function getLoc()
    local x, y, z = gps.locate(5)
    if not x then
        error("gps failed...")
    end

    return vector.new(x, y, z)
end

-- determines facing direction
function getDir()
    local a = getLoc()
    turtle.forward()
    local b = getLoc()
    turtle.backward()

    if a.x > b.x then
        return EAST
    elseif a.x < b.x then
        return WEST
    elseif a.z > b.z then
        return SOUTH
    elseif a.z < b.z then
        return NORTH
    else
        return -1
    end
end

function setDir(dir)
    while not getDir() == dir do
        turtle.turnLeft()
    end
end

function abs(val)
    if val < 0 then
        return val * -1
    end
    return val
end

function moveTo(loc)
    local curLoc = getLoc()

    local yDiff = abs(loc.y - curLoc.y)
    local xDiff = abs(loc.x - curLoc.x)
    local zDiff = abs(loc.z - curLoc.z)

    local count = 0
    while count < yDiff do
        if curLoc.y < loc.y then
            turtle.up()
        else
            turtle.down()
        end
        count = count + 1
    end

    local dir = getDir()
    if dir == -1 then
        error("couldn't determine direction...")
        return
    end

    -- handle x
    if curLoc.x > loc.x then -- head WEST
        setDir(WEST)
    elseif curLoc.x < loc.x then -- head EAST
        setDir(EAST)
    end
    count = 0
    while count < xDiff do
       turtle.forward()
        count = count + 1
    end

    -- handle z
    if curLoc.z > loc.z then -- head NORTH
        setDir(NORTH)
    elseif curLoc.z < loc.z then -- head SOUTH
        setDir(SOUTH)
    end
    count = 0
    while not count < zDiff do
        turtle.forward()
        count = count + 1
    end
end

function hasInvSpace()
    return turtle.getItemCount() <= 0
end

function dumpInvChest()
    moveTo(CHEST_LOC)
    local res = faceChest()
    if res == false then
        error("couldn't find chest!")
    end

    for i = 16, 1, -1 do
        turtle.select(i)
        turtle.drop()
    end

    print("dumped inventory to chest")
end

-- gets the bounds of the quarry
function getBounds(size)
    local dir = getDir()
    if dir == -1 then
        error("couldn't determine direction")
    end

    local x1, y1, z1, x2, y2, z2, xStep, zStep
    local curLoc = getLoc()

    y1 = curLoc.y
    y2 = 5
    if dir == NORTH then
        z1 = curLoc.z
        z2 = curLoc.z - size
        zStep = -1
        x1 = curLoc.x
        x2 = curLoc.x + size
        xStep = 1
    elseif dir == EAST then
        z1 = curLoc.z
        z2 = curLoc.z + size
        zStep = 1
        x1 = curLoc.x
        x2 = curLoc.x + size
        xStep = 1
    elseif dir == SOUTH then
        z1 = curLoc.z
        z2 = curLoc.z + size
        zStep = 1
        x1 = curLoc.x
        x2 = curLoc.x - size
        xStep = -1
    elseif dir == WEST then
        z1 = curLoc.z
        z2 = curLoc.z - size
        zStep = -1
        x1 = curLoc.x
        x2 = curLoc.x - size
        xStep = -1
    end

    return x1, x2, z1, z2, y1, y2, xStep, zStep
end

function driver()
    print("welcome to miner v1000")
    print("enter square size")
    local inp = read()
    local num = tonumber(inp)

    if num == nil then
        error("invalid square size!")
        return
    end

    print("starting quarry...")
    print("finding chest...")
    local res = locateChest()
    if res == false then
        error("couldn't find chest")
        return
    end
    t180()  -- face away from chest

    print("checking fuel...")
    res = needsRefuel(0)
    if res == true then
        res = refuel()
        if res == false then
            error("couldn't refuel")
            return
        end
    end

    print("checking inventory...")
    if not hasInvSpace() then
        dumpInvChest()
        t180()
    end

    print("digging...")
    local x1, x2, z1, z2, y1, y2, xStep, zStep = getBounds(num)
    local yStep = -1

    for y = y1, y2, yStep do
        for x = x1, x2, xStep do
            for z = z1, z2, zStep do
                moveTo(vector.new(x, y, z))
                turtle.digDown()

                if needsRefuel(1000) then
                    print("refuelling...")
                    local res = refuel()
                    if res == false then
                        error("couldn't refuel")
                    end
                end

                if not hasInvSpace() then
                    print("dumping inventory to chest...")
                    local lastLoc = getLoc()
                    dumpInvChest()
                    t180()
                    moveTo(lastLoc)
                end
            end
        end
    end
end

driver()
