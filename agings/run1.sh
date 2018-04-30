#!/bin/sh

#export SCRIPT_DIR=`pwd`
#INC_SIZE_SCRIPT=$SCRIPT_DIR/inc-size.sh
#GREP_TEST=$SCRIPT_DIR/grep_test.sh

if [ $# -le 0 ]; then
  echo "Device not provided"
  exit 1
fi

export TEST_DEV=$1
INPUT_SIZE=$2

echo
echo "Creating files in directories"
echo

MNT_PNT=$TEST_DEV
BLK_SIZE=4096

EQ_NUM=1
#MAX_BLOCKS=6554
#FRAC_VAL="0.2"
#MAX_BLOCKS=`echo "$BLK_PER_GRP*$FRAC_VAL" | bc`
#MAX_BLOCKS=$((1 + $BLK_PER_GRP * 2 / 10))



#DIR_NUM=`shuf -i 1-100 -n 1`
DIR_NUM=$INPUT_SIZE
echo "Directories to create: $DIR_NUM"
echo -e "Directory - No. of files"

for i in $(seq -f "%04g" 1 $DIR_NUM)
do
    DIR_NM=$MNT_PNT/$i

  if [ ! -d "$DIR_NM" ]; then
      mkdir $DIR_NM
  fi

  #FILES_NUM=`shuf -i 1-100 -n 1`
  FILES_NUM=100
  it=0
  while [ $it -le $FILES_NUM ]
  do
    blk_cnt=`shuf -i 1-5 -n 1`
    

    THISDATE=`date +"%y%m%d"`
    THISTIME=`date +%s%N`
    THIS=$THISDATE$THISTIME
    RAND=`head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9~_-' | fold -w 10 | head -n 1`
    UNDER_STR="_"
    OUT_FILE=$DIR_NM/$RAND$UNDER_STR$THIS
    FILE_SZ=`echo "$BLK_SIZE * $blk_cnt" | bc`
    
    sudo dd if=/dev/zero of=$OUT_FILE  bs=$BLK_SIZE count=$blk_cnt status=none
    #sudo fallocate -l $FILE_SZ $OUT_FILE
    if [ $? -eq $EQ_NUM ]; then
        exit 0
    fi

    #it=$[$it+$blk_nm]
    let "it += 1"
  done
  FS_USED="df | grep '$TEST_DEV' | awk '{print \$5}'"  
  FS_USED=`eval $FS_USED`

  echo -e "$i - $FILES_NUM"
done
#COMMENT1
sync
#$GREP_TEST $MNT_PNT

exit 0
