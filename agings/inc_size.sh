#!/bin/bash

WORK_DIR=$1
BLK_SZ=4096

echo
echo "############ Increase FS Size to $FS_SIZE - $WORK_DIR"
echo
#cd $WORK_DIR
DEV_DIR=/dev/zero
while true
do
    for dir in $WORK_DIR/*/
    do
        dir=${dir%*/}

        if [ $dir == "$WORK_DIR/lost+found" ]
        then
            continue
        fi
        #echo ${dir}
        cd $dir
        file1=`ls | shuf -n 1`
        rand_file=$dir/$file1

        #echo "$rand_file"
        #echo
        file_sz=`stat --printf="%s" $rand_file`
        blk_cnt=`shuf -i 1-512 -n 1`
        inc_size=`echo "$BLK_SZ * $blk_cnt" | bc`
        #truncate $rand_file --size $inc_size
        #sudo fallocate -l $inc_size $rand_file
        sudo dd if=$DEV_DIR of=$rand_file bs=$BLK_SZ count=$blk_cnt status=none
        sleep 0.25
        #new_sz=`stat --printf="%s" $rand_file`
        #echo "$rand_file: $file_sz --- $new_sz"
    done
    #echo
#done
#sync
#exit 0
#<<COMMENT1
    for dir in $WORK_DIR/*/
    do

        dir=${dir%*/}

        if [ $dir == "$WORK_DIR/lost+found" ]
        then
            continue
        fi

        blk_cnt=`shuf -i 1-512 -n 1`
        THISDATE=`date +"%y%m%d"`
        THISTIME=`date +%s%N`
        THIS=$THISDATE$THISTIME
        RAND=`head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9~_-' | fold -w 10 | head -n 1`
        UNDER_STR="_"
        OUT_FILE=$dir/$RAND$UNDER_STR$THIS
        FILE_SZ=`echo "$BLK_SZ * $blk_cnt" | bc`

        sudo dd if=$DEV_DIR of=$OUT_FILE  bs=$BLK_SZ count=$blk_cnt status=none
        sleep 0.25
        #sudo fallocate -l $FILE_SZ $OUT_FILE

    done 
#COMMENT1
done

sync

exit 0
