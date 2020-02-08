local Interpreter = require 'scripts.interpreter'
local Logs = require 'lib.logs'
local path = require 'path'


local PWD
local interpreter

local function get_pwd()
  return arg[1]
end

local function assert_help(assertion, msg)
  Logs.assert(assertion, 1, msg, "\n",
    "Usage:\n\n",
    "  $ ygopic <mode> <art-folder> <card-database> <output-folder> [options]\n\n",
    "Arguments:\n\n",
    "  mode          \tEither `anime` or `proxy`\n",
    "  art-folder    \tPath to a folder containing artwork for the cards\n",
    "  card-database \tPath to a .cdb describing each card\n",
    "  output-folder \tPath to a folder that will contain output images\n\n",
    "Available options:\n\n",
    "  --size WxH       \tW and H determines width and height of the output\n",
    "                   \timages. If only W or H is specified, aspect ratio\n",
    "                   \tis preserved. Example: `--size 800x` will output\n",
    "                   \timages in 800px in width, keeping aspect ratio.\n",
    "                   \tDefaults to original size\n\n",
    "  --ext <ext>      \tSpecifies which extension is used for output,\n",
    "                   \teither `png`, `jpg` or `jpeg`. Defaults to `jpg`\n\n",
    "  --artsize <mode> \tSpecifies how artwork is fitted into the artbox,\n",
    "                   \teither `cover` or `contain`, defaults to `cover`\n\n",
    "  --year <year>    \tSpecifies an year to be used in `proxy` mode in\n",
    "                   \tthe copyright line. Defaults to `1996`\n\n",
    "  --author <author>\tSpecifies an author to be used in `proxy` mode in\n",
    "                   \tthe copyright line. Defaults to `KAZUKI TAKAHASHI`\n\n"
  )
end

local function run(flags, mode, imgfolder, cdbfp, outfolder)
  local Composer = require 'scripts.composer.composer'
  assert_help(mode, "Please specify <mode>")
  assert_help(imgfolder, "Please specify <art-folder>")
  assert_help(cdbfp, "Please specify <card-database>")
  assert_help(outfolder, "Please specify <output-folder>")
  imgfolder = path.join(PWD, imgfolder)
  cdbfp = path.join(PWD, cdbfp)
  outfolder = path.join(PWD, outfolder)
  local options = {
    year = flags["--year"],
    author = flags["--author"],
    ext = flags["--ext"],
    size = flags["--size"],
    artsize = flags["--artsize"]
  }
  for k, o in pairs(options) do options[k] = o[1] end
  Composer.compose(mode or "", imgfolder, cdbfp, outfolder, options)
end

local function init_interpreter()
  interpreter = Interpreter()
  interpreter:add_command("", run, "--size", 1, "--ext", 1, "--artsize", 1,
    "--year", 1, "--author", 1)
end

PWD = get_pwd()
init_interpreter()
local errmsg, cmd, args, flags = interpreter:parse(unpack(arg, 2))
assert_help(not errmsg, errmsg)
interpreter:exec(cmd, args, flags)
