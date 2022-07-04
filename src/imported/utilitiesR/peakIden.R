################################################################################

peakIden <- function(

  fSeq,
  dThreshold = NULL
) {

  if (is.null(dThreshold)) dThreshold <- 1
  fSeq <- c(0, fSeq, 0)
  fThreseq <- which(fSeq >= dThreshold)
  fPeakLength <- which(fSeq[fThreseq + 1] < dThreshold) - which(fSeq[fThreseq - 1] < dThreshold) + 1
  fUpperLimIx <- (fThreseq[cumsum(fPeakLength)]) - 1
  fLowerLimIx <- fUpperLimIx - fPeakLength + 1
  peakFeat <- data.frame(peakNo = seq_along(fLowerLimIx), lowerLimIx = fLowerLimIx, upperLimIx = fUpperLimIx, peakLengthIx = fPeakLength)

  return(peakFeat)
}

################################################################################
