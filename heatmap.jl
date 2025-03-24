####################################################################################################

using CSV
using DataFrames
using Plots

####################################################################################################

# read all CSV files in directory
function read_csv_files(directory::String)
  file_list = filter(x -> endswith(x, ".csv"), readdir(directory, join=true))
  dataframes = [CSV.read(file, DataFrame) for file in file_list]
  return dataframes
end

function plot_heatmap(directory::String)
  # read CSVs into a list of DataFrames
  df_list = read_csv_files(directory)

  # merge DataFrames into a single DataFrame
  df_combined = hcat(df_list...)

  # convert to Matrix format for Heatmap
  heatmap_matrix = Matrix(df_combined)

  # plot Heatmap
  heatmap_plot = heatmap(heatmap_matrix, color = :viridis, title = split(directory, "/")[end - 1])

  # save Heatmap to PNG (fixed the string concatenation and file format)
  heatmap_filename = string(replace(directory, "traceback" => "heatmap"), "/", split(directory, "/")[end - 1], ".png")
  savefig(heatmap_plot, heatmap_filename)
end

####################################################################################################

# define address
directory_path = "/Users/drivas/Factorem/MindReader/hmm"

# list subdirectories
subdirectories = filter(d -> !occursin(r"\.log$", d), readdir(directory_path))

# iterate through subdirectories
for subdir in subdirectories
  println("Processing subdirectory: $subdir")

  if !isdir(string(directory_path, "/", subdir, "/heatmap"))
      mkdir(string(directory_path, "/", subdir, "/heatmap"))
      println("Directory created: $directory_path")
  else
      println("Directory already exists: $directory_path")
  end
  
  plot_heatmap(string(directory_path, "/", subdir, "/", "traceback"))

end

####################################################################################################