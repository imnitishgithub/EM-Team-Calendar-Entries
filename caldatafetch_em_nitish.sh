#! /bin/bash
cd /home/nitisgup/BCAL
clear
if [ -f bh_load_EM.txt ]
then
    rm bh_load_EM.txt
fi
cp /home/kacharya/Beehive/output/bh_load_EM.txt .
if [ -f CalData ]
then
    rm -frv CalData
fi
if [ -f CalDataNew ]
then
    rm -frv CalDataNew
fi
if [ -f today_shifts ]
then
    rm -frv today_shifts
fi

if [ -f current_shift ]
then
    rm -frv current_shift
fi
if [ -f shift_time ]
then
    rm -frv shift_time
fi

today_date=`date +'%d-%b-%Y%k:%M'`

cat bh_load_EM.txt | cut -d'|' -f2- | cut -d'|' -f1- | awk {'print $1"|"$2"|"$4"|"$5'} | tr '|' ' ' | sed '/DAY_EVENT/d' >> CalData
cat CalData | awk {'print $2" "$3" "$1" "$4'} | sort -n >> CalDataNew


cat  CalDataNew | while read LINE
do
echo $LINE > current_line
shift_date=`sed -e 's/  \+/\t/g' current_line|cut -d" " -f1`
shift_date=$(date -d "${shift_date}" "+%s")
current_date=` date +'%d-%b-%Y'`
current_date=$(date -d "${current_date}" "+%s")
if [ ${shift_date} -eq ${current_date} ];
    then
     echo $LINE >> today_shifts
fi
done

cat  today_shifts | while read LINE
           do
             echo $LINE > shift_time
             shift_start_time=`sed -e 's/  \+/\t/g' shift_time|cut -d" " -f2`
             shift_start_time=$(date -d "${shift_start_time}" "+%s")
             shift_end_time=`sed -e 's/  \+/\t/g' shift_time|cut -d" " -f4`
             shift_end_time=$(date -d "${shift_end_time}" "+%s")
             current_time=` date +'%k:%M'`
             current_time=$(date -d "${current_time}" "+%s")               
            if [[ ${current_time}  -ge ${shift_start_time} ]] && [[ ${current_time} -le ${shift_end_time} ]]; then
                                 echo $LINE > current_shift
                                 exit
                          fi
           done

shift_date=`sed -e 's/  \+/\t/g' current_shift|cut -d" " -f1`
shift=`sed -e 's/  \+/\t/g' current_shift|cut -d" " -f3`
start_time=`sed -e 's/  \+/\t/g' current_shift|cut -d" " -f2`
end_time=`sed -e 's/  \+/\t/g' current_shift|cut -d" " -f4`
CHANGE_TITLE="DM Support- ${shift} Shift_Date: ${shift_date} from: ${start_time} PST till ${end_time} PST"
echo $CHANGE_TITLE
BUILD_ID="/topic $CHANGE_TITLE" 

rm -f /home/jenkins/jenkins_slave/play.properties
touch /home/jenkins/jenkins_slave/play.properties
echo BUILD_ID=$BUILD_ID > /home/jenkins/jenkins_slave/play.properties
