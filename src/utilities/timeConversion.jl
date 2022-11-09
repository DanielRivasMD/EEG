####################################################################################################

function convertFromSeconds(sec::Int64)
  hours = 0
  minutes = 0
  seconds = sec % 60

  if sec >= 60
      minutes = floor(sec / 60)
  end
  if minutes >= 60
      hours = floor(minutes / 60)
      minutes = minutes % 60
  end
  time = (hours, minutes, seconds)
  return time
end

####################################################################################################
