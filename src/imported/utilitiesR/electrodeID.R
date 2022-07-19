####################################################################################################

# electrodes

# Parasagittal/supra-sylvian electrodes
ParasagittalL <- c(
  "Fp1",
  "F3",
  "C3",
  "P3",
  "O1"
)

ParasagittalR <- c(
  "Fp2",
  "F4",
  "C4",
  "P4",
  "O2"
)

# Lateral/temporal electrodes
TemporalL <- c(
  "F7",
  "T3", # "T7",
  "T5"  # "P7",
)

TemporalR <- c(
  "F8",
  "T4", # "T8",
  "T6"  # "P8",
)

# Midline electrodes
Midline <- c(
  "Fz",
  "Cz",
  "Pz"
)

# Earlobe electrodes
Earlobe <- c(
  "A1",
  "A2"
)

####################################################################################################

# bipolar
templeft <- c(
  "FP1-F7",
  "F7-T7",
  "T7-P7",
  "P7-O1"
)

midleft <- c(
  "FP1-F3",
  "F3-C3",
  "C3-P3",
  "P3-O1"
)

tempright <- c(
  "FP2-F8",
  "F8-T8",
  "T8-P8",
  "P8-O2"
)

midright <- c(
  "FP2-F4",
  "F4-C4",
  "C4-P4",
  "P4-O2"
)

mid <- c(
  "FZ-CZ",
  "CZ-PZ"
)

other <- c(
  "P7-T7",
  "T7-FT9",
  "FT9-FT10",
  "FT10-T8"
)

####################################################################################################

Bipolar <- c(
  templeft,
  midleft,
  tempright,
  midright,
  mid,
  other
)

elecID <- c(
  ParasagittalL,
  ParasagittalR,
  TemporalL,
  TemporalR,
  Midline,
  Earlobe,
  Bipolar
)

####################################################################################################
