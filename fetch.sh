# CONUS Bounding Box
# lft_lon=-130.0
# rgt_lon=-65.0
# top_lat=60.0
# btm_lat=20.0

# Denver Bounding Box
lft_lon=-105.5
rgt_lon=-104.5
top_lat=40.0
btm_lat=39.5

# Get the current file name from NOMADS
latest=$(curl -s "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl" | perl -nle 'print $& if m{gfs.\d{10}}')

# Make sure we got a result
if [ -z $latest ]; then
  exit "No run found"
else
  echo "Latest file is $latest"
  echo "-----------------------------"
fi

# Extract the date and the init from the latest file name
run="${latest:8:2}z"
date=${latest:4:8}

# Make sure we have an "output" directory to put our files
mkdir -p output

# We want every 6 hour run out to 240 hours
for idx in {0..40}
do

  # Create a zero-padded string var named "hour"
  printf -v hour "%03g" $((idx*6))

  # Construct the filename
  filename="$latest.$hour.grib2"

  # Construct the URL
  url="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?"
  url+="file=gfs.t$run.pgrb2.0p25.f$hour"
  url+="&dir=%2F$latest"
  url+="&subregion="
  url+="&leftlon=$lft_lon&rightlon=$rgt_lon&toplat=$top_lat&bottomlat=$btm_lat"
  url+="&all_lev=on"
  url+="&var_CAPE=on"

  # Fetch the file
  echo "Fetching file $filename"
  curl -s "$url" -o output/$filename
  
  # Turn the file into a CSV
  wgrib2 output/$filename -csv output/$filename.csv > /dev/null
  rm output/$filename

  # Sleep between requests
  sleep 1

done
