####################################################################################################

peakIden <- function(
  seq,
  threshold = NULL
) {

  # assign default value
  if (is.null(threshold)) threshold <- 1

  # decision on threshold
  if (threshold >= 0) {

    # pad sequence
    seq <- c(threshold - 1, seq, threshold - 1)

    # identify threshold indexes
    threseq <- which(seq >= threshold)

    # calculate peak lengths
    peakLength <- which(seq[threseq + 1] < threshold) - which(seq[threseq - 1] < threshold) + 1

  } else if (threshold < 0) {

    # pad sequence
    seq <- c(abs(threshold) + 1, seq, abs(threshold) + 1)

    # identify threshold indexes
    threseq <- which(seq <= abs(threshold))

    # calculate peak lengths
    peakLength <- which(seq[threseq + 1] > abs(threshold)) - which(seq[threseq - 1] > abs(threshold)) + 1

  } else {
    stop('value for threshold not recongnized')
  }

  # identify edges / limits
  upperLimIx <- (threseq[cumsum(peakLength)]) - 1
  lowerLimIx <- upperLimIx - peakLength + 1

  # load values
  peakFeat <- data.frame(peakNo = seq_along(lowerLimIx), lowerLimIx = lowerLimIx, upperLimIx = upperLimIx, peakLengthIx = peakLength)

  # return
  return(peakFeat)
}

####################################################################################################
