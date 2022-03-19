################################################################################

# load packages
using DataFrames, XLSX, FreqTables

################################################################################

# set variables
proj_dir = "/Users/drivas/Factorem/EEG/"
file_path = "$(proj_dir)Data/patientEEG/"
files = readdir(file_path)

# regex for xlsx
rex = r"xlsx$"

# xlsx range
rng = collect(1:3)

################################################################################

# file verification
for file_name in files

  # 'occursin' is compatible with Julia v1.3.1
  if occursin(rex, file_name)

    println()
    println("File: $(file_name)")

    # open interphase to xlsx file
    XLSX.openxlsx("$(file_path)$(file_name)") do f

      # iterate through sheets
      for i in rng

        q = f[i][:]

        # check headers
        if sum(q[1, :] |> freqtable .> 1) > 0
          println("$(f[i].name) has duplicated headers")
        # check sheet names
        else
          println("$(f[i].name)")
        end

      end
    end
  end
end

################################################################################

for file_name in files

  # 'occursin' is compatible with Julia v1.3.1
  if occursin(rex, file_name)
    println("Gotta you => $(file_name)")

    # open interphase to xlsx file
    XLSX.openxlsx("$(file_path)$(file_name)") do f

      # read sheet 1: Patient Data (PD)
      global pd0 = DataFrame(XLSX.gettable(f[1])...)

      # read sheet 2: State Annoation (SA)
      global sa0 = DataFrame(XLSX.gettable(f[2])...)

      # read sheet 3: Event Marking (EM)
      global em0 = DataFrame(XLSX.gettable(f[3])...)

      # ellipsis are essential to interpret properly as DataFrame
    end

    # # print xlsx sheets
    # println("################################################################################")
    # println(pd0)
    # println(sa0)
    # println(em0)

  end
end

################################################################################
