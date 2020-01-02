local fs = require 'lfs'
local path = require 'path'
local sqlite = require 'lsqlite3complete'
local Logs = require 'scripts.logs'


local PWD
local GENFP = path.join("res", "new")

local function check_name(pack_name)
  Logs.assert(pack_name, 1, "No name was provided for the new extension pack")
end

local function create_folder(folder)
  Logs.info("Creating \"", folder, "\" folder...")
  local success, msg, errcode = fs.mkdir(path.join(PWD, folder))
  Logs.assert(success, errcode, ("%q - %s"):format(folder, msg))
end

local function create_cdb(pack_name)
  Logs.info("Creating card database...")
  local db, err, msg = sqlite.open(path.join(PWD, pack_name, pack_name .. ".cdb"))
  Logs.assert(db, err, msg)
  local sqlf = io.open(path.join(GENFP, "create-cdb.sql"), "r")
  local create_sql = sqlf:read("*a")
  sqlf:close()
  db:exec(create_sql)
  db:close()
end

local function copy_file(src, dst)
  Logs.info("Creating \"", dst, "\" file...")
  local srcfile, msg = io.open(src, "r")
  Logs.assert(srcfile, 1, msg)
  local dstfile, msg = io.open(path.join(PWD, dst), "w")
  Logs.assert(dstfile, 1, msg)
  dstfile:write(srcfile:read("*a"))
  dstfile:close()
  srcfile:close()
end

return function (pwd, pack_name)
  PWD = pwd
  check_name(pack_name)
  create_folder(pack_name)
  create_folder(path.join(pack_name, "artwork"))
  create_folder(path.join(pack_name, "pics"))
  create_folder(path.join(pack_name, "script"))
  create_cdb(pack_name)
  copy_file(path.join(GENFP, "default-config.toml"), path.join(pack_name, "config.toml"))
  copy_file(path.join(GENFP, "default.gitignore"), path.join(pack_name, ".gitignore"))
  Logs.ok("\"", pack_name, "\" pack successfully created!")
end
