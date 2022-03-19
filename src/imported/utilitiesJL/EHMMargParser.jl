################################################################################

using ArgParse

################################################################################

function shArgParser(args)
  # minimal argument parsing
  s = ArgParseSettings(description = "EEG Hidden Markov Model")
  @add_arg_table! s begin
      "--file", "-f"
        arg_type = String
        required = true
        help = "file to read"
      "--output", "-o"
        arg_type = String
        required = false
        help = "output directory"
  end
  parsed_args = parse_args(s)
  return parsed_args
end

################################################################################
