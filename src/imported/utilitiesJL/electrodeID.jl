####################################################################################################

# electrodes

# Parasagittal/supra-sylvian electrodes
ParasagittalL = [
  "Fp1",
  "F3",
  "C3",
  "P3",
  "O1",
]

ParasagittalR = [
  "Fp2",
  "F4",
  "C4",
  "P4",
  "O2",
]

# Lateral/temporal electrodes
TemporalL = [
  "F7",
  "T3", # "T7",
  "T5", # "P7",
]

TemporalR = [
  "F8",
  "T4", # "T8",
  "T6", # "P8",
]

# Midline electrodes
Midline = [
  "Fz",
  "Cz",
  "Pz",
]

# Earlobe electrodes
Earlobe = [
  "A1",
  "A2",
]

####################################################################################################

# bipolar
templeft = [
  "FP1-F7",
  "F7-T7",
  "T7-P7",
  "P7-O1",
]

midleft = [
  "FP1-F3",
  "F3-C3",
  "C3-P3",
  "P3-O1",
]

tempright = [
  "FP2-F8",
  "F8-T8",
  "T8-P8",
  "P8-O2",
]

midright = [
  "FP2-F4",
  "F4-C4",
  "C4-P4",
  "P4-O2",
]

mid = [
  "FZ-CZ",
  "CZ-PZ",
]

other = [
  "P7-T7",
  "T7-FT9",
  "FT9-FT10",
  "FT10-T8",
]

####################################################################################################

Bipolar = [
  templeft;
  midleft;
  tempright;
  midright;
  mid;
  other;
]

elecID = [
  ParasagittalL;
  ParasagittalR;
  TemporalL;
  TemporalR;
  Midline;
  Earlobe;
  Bipolar;
]

####################################################################################################
