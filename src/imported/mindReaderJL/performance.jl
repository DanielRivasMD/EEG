################################################################################

utilDir = "utilitiesJL/"
winBin = 256
overlap = 8

dataDir = "/Users/drivas/Factorem/EEG/Data/patientEEG/"

################################################################################

# file = string(dataDir, "0025MF.edf")
# xfile = string(dataDir, "0025MF.xlsx")

file = string(dataDir, "0026TS2015.edf")
xfile = string(dataDir, "0026TS2015.xlsx")

# file = string(dataDir, "0001LB.edf")
# xfile = string(dataDir, "0001LB.xlsx")

# TODO: train perceptron manually

################################################################################

# two-dimensional array
patientAr = [
# "0001LB" "healthy";
# "0002AC" "healthy";
# "0003DC" "healthy";
# "0004AD" "healthy";
# "0005RD" "healthy";
# "0006AH" "healthy";
# "0007DH" "healthy";
# "0008AH" "healthy";
# "0009EH" "healthy";
# "0010LL" "healthy";
# "0011DM" "healthy";
# "0012MN" "healthy";
# "0013JP" "healthy";
# "0014SP" "healthy";
# "0015LR" "healthy";
# "0016GR" "healthy";
# "0017DR" "healthy";
# "0018KR" "healthy";
# "0019GS" "healthy";
# "0020WT" "healthy";
"0021MA" "focalized";
"0022MD" "focalized";
"0023BA" "focalized";
"0024EZ" "focalized";
"0025MF" "focalized";
"0026TS2015" "focalized";
"0027TS2017" "focalized";
"0028TS2019" "focalized";
"0029AA" "focalized";
"0030GJ" "focalized";
"0031GJ" "focalized";
"0032AM" "focalized";
"0033GC" "focalized";
"0034MI2018" "focalized";
"0035MI2019" "focalized";
"0036LR" "focalized";
"0037SC" "focalized";
"0038AR" "focalized";
"0039LH" "focalized";
"0040AE" "focalized";
"0041DV" "focalized";
"0042EG" "focalized";
"0043AD" "focalized";
"0044JV" "focalized";
"0045KG" "focalized";
"0046MC" "focalized";
"0047PR" "focalized";
"0048JG" "focalized";
"0049LB" "focalized";
"0050DT" "focalized";
"0061JZ" "generalized";
"0062AC" "generalized";
"0063RR" "generalized";
"0064CR" "generalized";
"0065LC" "generalized";
"0066MM" "generalized";
"0067GM" "generalized";
"0068MR" "generalized";
"0069AG" "generalized";
"0070RP" "generalized";
"0071AC" "generalized";
"0072LJ" "generalized";
"0073FM" "generalized";
"0074JR" "generalized";
"0075PC" "generalized";
"0076FV" "generalized";
"0077MC" "generalized";
"0078BR" "generalized";
"0079GM" "generalized";
"0080JC" "generalized";
"0081MB" "generalized";
"0082KC" "generalized";
"0083EA" "generalized";
"0084CR" "generalized";
"0085OA" "generalized";
"0086AO" "generalized";
"0087UO" "generalized";
"0088MO" "generalized";
"0089JC" "generalized";
"0090RR" "generalized";
"0091OD" "generalized";
"0092MT" "generalized";
"0093CC" "generalized";
"0094JT" "generalized";
"0095JV" "generalized";
"0096JC" "generalized";
"0097LH" "generalized";
"0098NP" "generalized";
"0099NM" "generalized";
"0100MM" "generalized";
"0101SC" "generalized";
"0102JA" "generalized";
"0103AB" "generalized";
"0104JA" "generalized";
"0105IF" "generalized";
]

################################################################################

ssDf = DataFrame(patient = patientAr[:, 1], state = patientAr[:, 2], sensitivity = [missing; repeat([0.], size(patientAr, 1) - 1)], specificity = [missing; repeat([0.], size(patientAr, 1) - 1)])
ssDf[1, [:sensitivity, :specificity]] .= 0.

################################################################################

for ft in patientAr[:, 1]

  ################################################################################

  tfile = string(dataDir, ft, ".edf")
  xtfile = string(dataDir, ft, ".xlsx")

  ################################################################################

  # read edf file
  TedfDf, TstartTime, TrecordFreq = getSignals(tfile);

  @info ft
  if size(edfDf, 2) != size(TedfDf, 2)
    @warn "file has different number of channels than model"
    continue
  end

  # extract signal bins
  TsignalAr = extractSignalBin(TedfDf, binSize = winBin, binOverlap = overlap);

  # flatten array
  TsignalAr = Flux.flatten(TsignalAr);

  try
    # read xlsx file
    TxDf = xread(xtfile);

    # labels array
    TlabelAr = annotationCalibrator(
      TxDf,
      startTime = TstartTime,
      recordFreq = TrecordFreq,
      signalLength = size(TedfDf, 1),
      binSize = winBin,
      binOverlap = overlap
    );

    ################################################################################

    try
      # test model
      # modelTest(TsignalAr, TlabelAr, model, Params)

      global ssDf[findall(ssDf[:, :patient] .== ft), :sensitivity], ssDf[findall(ssDf[:, :patient] .== ft), :specificity] = modelSS(TsignalAr, TlabelAr, model, Params)
    catch e
      @warn "Model evaluation should be verified"
      global ssDf[findall(ssDf[:, :patient] .== ft), :sensitivity], ssDf[findall(ssDf[:, :patient] .== ft), :specificity] = (missing, missing)
    end

    ################################################################################

  catch e
    @warn "Annotations might be missing"
    global ssDf[findall(ssDf[:, :patient] .== ft), :sensitivity], ssDf[findall(ssDf[:, :patient] .== ft), :specificity] = (missing, missing)
  end

end

################################################################################

dropmissing!(ssDf)

################################################################################

using RCall

################################################################################

@rput ssDf
R"
source('utilitiesJL/performancePlot.R')
"

################################################################################
