-- User: dylan
-- Date: 2020-03-02
-- Time: 10:14 p.m.

-- miner specific state
mstate = {
    shulker_count = 0,
    shulker_slots = {},
    ticks_passed = 0
}

function driver()
    print("Welcome to miner 2000")
    print("starting configuration...")
    -- init turtle state
    TL.initiateTurtle()

    -- get specific mining details
    print("enter number of shulkers in turtle: ")
    local inp = read()
    local n = tonumber(n)
    if n < 0 then
        print("warning no additional inventory will be available, turtle will fill up quickly.")
    else
        mstate.shulker_count = n

        -- find all shulker slots
        local data = TL.findAllInv("shulker_box")
        if data.count > 0 then
            if data.count > n then
                if HCORE.promptYN("found too many shulkers (" + tostring(data.count) +"), proceed ?") ~= true then
                    error("too many shulkers in inventory")
                end
            end

            mstate.shulker_count = data.count
            mstate.shulker_slots = data.data
        else
            error("no shulker boxes found in inventory.")
        end
    end

    -- getting quarry size
    local breadth = HCORE.promptInt("enter quarry breadth: ")
    local width = HCORE.promptInt("enter quarry width: ")
    local depth = HCORE.promptInt("enter min depth: ")
    if depth <= 5 then
        error("cannot dig lower than 5 due to bedrock generation.")
    end


    -- TODO: FINISH REWRITE
    -- TODO dig, move, tick_passed + 1 : after 100 tick check for inv space, check for refuel
end

--------------------------------------------START SCRIPT
if not os.loadAPI("TL") then -- loads the turtle library api
    error("couldn't load the TL (Turtle Library) api")
end

print("loaded API: TL")
print("version: " + tostring(TL.getVersion()))

if not os.loadAPI("HCORE") then -- loads HOWZ1T's core library api
    error("couldn't load the HCORE api")
end

print("loaded API: HCORE")
print("version: " + tostring(HCORE.getVersion()))

driver()
os.unloadAPI("TL")
os.unloadAPI("HCORE")
