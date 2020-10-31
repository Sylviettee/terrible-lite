import open from require 'sqlite3'
import readFileSync from require 'fs'

convert = require './utils/convert'

conn = open 'db.sqlite'

-- Convert our models.toml into tables
conn\exec [[
CREATE TABLE IF NOT EXISTS users (
  UserId TEXT NOT NULL PRIMARY KEY, 
  Xp REAL DEFAULT 0, 
  Config TEXT DEFAULT "-- .terriblerc
edit '--// Blank notepad \\--'

editor:addCommand('rep', function(args)
    local repeated = ''

    local toRepeat = args[1]
    local count = tonumber(args[2])

    if not count then
      return editor:reject('Invalid count')
    end

    for i = 1, count do
      repeated = repeated .. toRepeat
    end

    editor:editCurrentLine(repeated)
end)
");
]]

cache = {}

get = (tbl, id_name, id) ->
  stmt = conn\prepare "SELECT * FROM #{tbl} WHERE #{id_name} == ?;"

  res = stmt\reset!\bind(id)\step!

  res

{
  :conn
  :get
}