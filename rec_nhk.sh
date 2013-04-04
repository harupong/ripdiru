#!/bin/sh

pid=$$
date=`date '+%Y-%m-%d-%H_%M'`
playerurl="http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf"
outdir="."

if [ $# -le 1 ]; then
  echo "usage : $0 channel_name duration(minuites) [outputdir] [prefix]"
  exit 1
fi

if [ $# -ge 2 ]; then
  channel=$1
  DURATION=`expr $2 \* 60 + 30`
fi
if [ $# -ge 3 ]; then
  outdir=$3
fi
PREFIX=${channel}
if [ $# -ge 4 ]; then
  PREFIX=$4
fi

#
# set channel
#
case $channel in
    "NHK1")
    rtmp="rtmpe://netradio-r1-flash.nhk.jp"
    playpath="NetRadio_R1_flash@63346"
    aspx="http://mfile.akamai.com/129931/live/reflector:46032.asx"
    ;;
    "NHK2")
    rtmp="rtmpe://netradio-r2-flash.nhk.jp"
    playpath="NetRadio_R2_flash@63342"
    aspx="http://mfile.akamai.com/129932/live/reflector:46056.asx"
    ;;
    "FM")
    rtmp="rtmpe://netradio-fm-flash.nhk.jp"
    playpath="NetRadio_FM_flash@63343"
    aspx="http://mfile.akamai.com/129933/live/reflector:46051.asx"
    ;;
    *)
    echo "failed channel"
    exit 1
    ;;
esac

#
# rtmpdump
#
#rtmpdump -q \
#         -r ${rtmp} \
#         --playpath ${playpath} \
#         --app "live" \
#         -W $playerurl \
#         --live \
#         --stop ${DURATION} \
#         -o "/tmp/${channel}_${date}"
#
(sleep ${DURATION};echo -n q) | \
    mplayer -playlist ${aspx} \
            -benchmark -vo null -ao pcm:file="/tmp/${channel}_${date}.wav" \
            -really-quiet -quiet

ffmpeg -loglevel quiet -y -i "/tmp/${channel}_${date}.wav" -acodec libmp3lame -ab 128k "${outdir}/${PREFIX}_${date}.mp3"
if [ $? = 0 ]; then
  rm -f "/tmp/${channel}_${date}.wav"
fi
