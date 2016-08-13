local SeedList = {}
 
local SEEDARRAY = {}
local SEEDINDEX = 0
 
function SeedList.GetNextSeed()
    if #SEEDARRAY > 0 then
        if SEEDINDEX < #SEEDARRAY then
            SEEDINDEX = SEEDINDEX + 1
            return SEEDARRAY[SEEDINDEX]
        end
    end
end
   
return SeedList