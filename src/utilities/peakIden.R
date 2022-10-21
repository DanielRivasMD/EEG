####################################################################################################

peak_iden <- function(
  f_seq,
  d_threshold = NULL
) {

  if (is.null(d_threshold)) d_threshold <- 1
  f_seq <- c(0, f_seq, 0)
  f_threseq <- which(f_seq >= d_threshold)
  f_peak_length <- which(f_seq[f_threseq + 1] < d_threshold) - which(f_seq[f_threseq - 1] < d_threshold) + 1
  f_upper_lim_ix <- (f_threseq[cumsum(f_peak_length)]) - 1
  f_lower_lim_ix <- f_upper_lim_ix - f_peak_length + 1
  peak_feat <- data.frame(peak_no = seq_along(f_lower_lim_ix), lower_lim_ix = f_lower_lim_ix, upper_lim_ix = f_upper_lim_ix, peak_length_ix = f_peak_length)

  return(peak_feat)
}

####################################################################################################
