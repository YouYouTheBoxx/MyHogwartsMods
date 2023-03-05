-- load the JSON library.
local Json = require("json")

local JsonStorage = {}

JsonStorage.saveTable = function(t, filename, lineName)

	local myTable = {}

	local oldFile = io.open(string.format("./Saved/%s", filename), "r")
	if oldFile then
        -- read all contents of file into a string
        local contents = oldFile:read( "*a" )
        myTable = Json.decode(contents);
        io.close( oldFile )
    end
	
	myTable[lineName] = t
	
    local file = io.open(string.format("./Saved/%s", filename), "w")
    if file then
        local contents = Json.encode(myTable)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end

JsonStorage.loadTable = function(filename, lineName)
    local contents = ""
    local myTable = {}
    local file = io.open(string.format("./Saved/%s", filename), "r")

    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        myTable = Json.decode(contents);
        io.close( file )
        return myTable[lineName]
    end
    return nil
end

return JsonStorage