################################################################################

using FreqTables
using NamedArrays

################################################################################

"""

    ss(ar)

Calculate sensitivity and specificity from 2 x 2 array

"""
function ss(ar)
  return (sensitivity = ar[1, 1] / ( ar[1, 1] + ar[2, 1] ), specificity = ar[2, 2] / ( ar[2, 2] + ar[1, 2] ))
end

################################################################################

"""

    sensspec(data_loader, model)

Calculate sensitivity and specificity from a DataLoader object

"""
function sensspec(data_loader, model)
  d, l = data_loader
  d = data_loader.data[1] |> model |> onecold
  l = data_loader.data[2] |> onecold

  outNamedArray = [( d[l .== 2] |> freqtable |> reverse ) ( d[l .== 1] |> freqtable |> reverse )]
  if size(outNamedArray, 1) == 1
    added = copy(outNamedArray)
    NamedArrays.setnames!(added, [2], 1)
    added[1, :] .= 0
    outNamedArray = [outNamedArray; added]
  end
  return ss(outNamedArray)

end

################################################################################

"""

    sensspec(tbVec, labelVec)

Calculate sensitivity and specificity from a HMM

"""
function sensspec(tbVc::Array{Int64, 1}, labelVec::Array{Int64, 1})
  # reassign frecuency labels
  tbVec = copy(tbVc)
  tbVec[findall(tbVec .> 1)] .= 2
  tbVec[findall(tbVec .== 1)] .= 1
  # adjust & concatenate frecuency tables
  positives = tbVec[labelVec .== 2] |> freqtable |> reverse |> stFreqTb
  negatives = tbVec[labelVec .== 1] |> freqtable |> reverse |> stFreqTb
  outNamedArray = [positives negatives]
  return ss(outNamedArray)
end

################################################################################

"""

    stFreqTb(fTb::NamedArray{Int64, 1})

Adjust frecuency tables for concatenation

"""
function stFreqTb(fTb::NamedArray{Int64, 1})
  sTb = size(fTb, 1)
  # de novo
  if sTb == 0
    fTb = [1, 2] |> freqtable |> reverse
    fTb .= 0
  # concatenate missing
  elseif sTb == 1
    added = copy(fTb)
    nPos = names(fTb)
    if sum.(nPos)[1] == 0
      NamedArrays.setnames!(added, [2], 1)
      added[1, :] .= 0
      fTb = [fTb; added]
    elseif sum.(nPos)[1] == 1
      NamedArrays.setnames!(added, [1], 1)
      added[1, :] .= 0
      fTb = [added; fTb]
    end
  # through warning
  elseif sTb > 2
    @warn "frecuency table contains more than 2 values"
  end
  return fTb
end

################################################################################
