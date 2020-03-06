-- User: dylan
-- Date: 2020-03-02
-- Time: 10:14 p.m.

function driver()
    -- TODO: REWRITE
end

--------------------------------------------START SCRIPT
if not os.loadAPI("TL") then -- loads the turtle library api
    error("couldn't load the TL (Turtle Library) api")
end

print("loaded API: TL")
print("version: " + tostring(TL.getVersion()))
driver()
os.unloadAPI("TL")
