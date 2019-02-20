#!/bin/bash
#
# Rasperry Pi Health script. (c) 2017 by tkaiser (Thomas Kaiser)
#
# Initial version and some more information can be found here:
# https://github.com/bamarni/pi64/issues/4#issuecomment-292707581

echo -e "To stop simply press [ctrl]-[c]\n"
Maxfreq=$(( $(awk '{printf ("%0.0f",$1/1000); }'  </sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq) -15 ))
Counter=14
DisplayHeader="Time       Temp  CPU fake/real     Health state    Vcore"
while true ; do
	let Counter++
	if [ ${Counter} -eq 15 ]; then
		echo -e "${DisplayHeader}"
		Counter=0
	fi
	Health=$(perl -e "printf \"%19b\n\", $(vcgencmd get_throttled | cut -f2 -d=)")
	Temp=$(vcgencmd measure_temp | cut -f2 -d=)
	RealClockspeed=$(vcgencmd measure_clock arm | awk -F"=" '{printf ("%0.0f",$2/1000000); }' )
	SysFSClockspeed=$(awk '{printf ("%0.0f",$1/1000); }' </sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
	CoreVoltage=$(vcgencmd measure_volts | cut -f2 -d= | sed 's/000//')
	echo -e "$(date "+%H:%M:%S"): ${Temp}$(printf "%5s" ${SysFSClockspeed})/$(printf "%4s" ${RealClockspeed}) MHz $(printf "%019d" ${Health}) ${CoreVoltage}"
	sleep 5
done
