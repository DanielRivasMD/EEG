####################################################################################################

using ArgParse: ArgParseSettings, @add_arg_table!, parse_args

####################################################################################################

function shArgParser(args)
    # minimal argument parsing
    ∫ = ArgParseSettings(; description = "MindReader command line utility.")

    @add_arg_table! ∫ begin

        "--input", "-i"
        arg_type = String
        required = false
        help = "`edf` file to read"

        "--inputDir", "-I"
        arg_type = String
        required = false
        help = "`edf` file directory"

        "--params", "-p"
        arg_type = String
        required = true
        help = "parameters"

        "--paramsDir", "-P"
        arg_type = String
        required = true
        help = "params file directory"

        "--annotation", "-a"
        arg_type = String
        required = false
        help = "annotation file"

        "--annotDir", "-A"
        arg_type = String
        required = false
        help = "annotation file directory"

        "--outDir", "-o"
        arg_type = String
        required = false
        default = "."
        help = "output directory"

        "--additional", "-f"
        arg_type = String
        required = false
        help = "comma-separated list of additional files to include"

        "--addDir", "-F"
        arg_type = String
        required = false
        help = "additional file(s) directory"

        "--window-size", "-w"
        nargs = '?'
        arg_type = Int
        default = 256
        help = "window size along raw signal"

        "--bin-overlap", "-b"
        nargs = '?'
        arg_type = Int
        default = 4
        help = "bin overlap along raw signal"

    end

    parsed_args = parse_args(∫)
    return parsed_args
end

####################################################################################################

#  parse shell arguments
shArgs = shArgParser(ARGS)

####################################################################################################

# # create directory if does not exist
# if !isdir(shArgs["outdir"]) && shArgs["outdir"] != "."
#   @info "Creating directory `$(shArgs["outdir"])`"
#   mkdir(shArgs["outdir"])
# end

####################################################################################################
