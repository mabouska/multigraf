#!/bin/bash
#made by Adam
#some mods later on by Marty
#does the screenshotting for TVs spread around the building
#first arg needs to be path to config file containing list of dashboard links and user for podman 

source $1

h=`date +%k` #get hour
d=`date +%u` #get day
s=`date +%s` #get sec since epoch
m=`expr $s / 60` # get min since epoch

# list of dashboards
# each record counts for 1 minute of dashboard time
list_length=${#dashboard_list[@]}

if [[ ! list_length -ge 1 ]]; then
  echo "dashboard list not found, is the path to the config file correct?"
  exit 1
fi

if [ $h -ge $starthr ] && [ $h -lt $stophr ] && [ $d -le $weekend ]; then #if it is a daytime working day
  podman container restart dashboard_screenshot
  min_mod=$(($m%$list_length))
  podman exec --user ${user} -it dashboard_screenshot google-chrome --ignore-certificate-errors --headless --force-device-scale-factor=1.5 --window-size=1920,1080 --virtual-time-budget=10000 --screenshot="/tmp/myscreenshot.png" "${dashboard_list[$min_mod]}"
  podman cp dashboard_screenshot:/tmp/myscreenshot.png /opt/SP/app01/grafana/png/myscreenshot.png
  chmod 666 ${screenshot_path}/myscreenshot.png
  cp ${script_path}/index.html  ${screenshot_path}/index.html
  echo "Debug info1: h = $h && d = $d - $(date)"
  echo "Debug info1: $(ls -la ${screenshot_path}/myscreenshot.png)"
else
  echo "Debug info2: h = $h && d = $d - $(date)"
  echo "Debug info2: $(ls -la ${screenshot_path}/myscreenshot.png)"
  cp ${script_path}/index.html  ${screenshot_path}/index.html
  cp ${script_path}/black.png ${screenshot_path}/myscreenshot.png
#  cp ${script_path}/llama.png ${screenshot_path}/myscreenshot.png
  chmod 666 ${screenshot_path}/myscreenshot.png

  # So this line is here because of infinitely growing log. I just could not figure out what to do with that, are you brave enough?
  > ${event_log_path}/events.log
fi

echo ""
