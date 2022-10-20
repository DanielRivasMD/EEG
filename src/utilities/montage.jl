####################################################################################################

"identify montage"
function montageIden(channels)

  ####################################################################################################
  # patch patient 12 containing different montages
  ####################################################################################################

  # select unipolar. chb12_28 & chb12_29
  unipolar = filter(χ -> !contains(χ, "-"), channels)

  ####################################################################################################

  # second bipokar set. chb12_27
  staticBipolar = ["F7-CS2", "T7-CS2", "P7-CS2", "FP1-CS2", "F3-CS2", "C3-CS2", "P3-CS2", "O1-CS2", "FZ-CS2", "CZ-CS2", "PZ-CS2", "FP2-CS2", "F4-CS2", "C4-CS2", "P4-CS2", "O2-CS2", "F8-CS2", "T8-CS2", "P8-CS2", "C2-CS2", "C6-CS2", "CP2-CS2", "CP4-CS2", "CP6-CS2"]
  secBipolar = channels[channels .∈ [staticBipolar]]

  ####################################################################################################

  # reference channels
  refChannels = filter(χ -> contains(χ, "Ref"), channels)

  ####################################################################################################

  # patch channels
  mainBipolar = channels[channels .∉ [[unipolar; secBipolar; refChannels]]]

  ####################################################################################################

  return (mainBipolar, secBipolar, unipolar, refChannels)

end

####################################################################################################
