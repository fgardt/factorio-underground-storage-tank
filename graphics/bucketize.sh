#! /usr/bin/env bash

function copy_to_buckets {
    mkdir -p $1_buckets/{005,010,015,020,025,030,035,040,045,050,055,060,065,070,075,080,085,090,095,100}
    cp $1/{000..059}.png $1_buckets/005/
    cp $1/{060..119}.png $1_buckets/010/
    cp $1/{120..179}.png $1_buckets/015/
    cp $1/{180..239}.png $1_buckets/020/
    cp $1/{240..299}.png $1_buckets/025/
    cp $1/{300..359}.png $1_buckets/030/
    cp $1/{360..419}.png $1_buckets/035/
    cp $1/{420..479}.png $1_buckets/040/
    cp $1/{480..539}.png $1_buckets/045/
    cp $1/{540..599}.png $1_buckets/050/
    cp $1/{600..659}.png $1_buckets/055/
    cp $1/{660..719}.png $1_buckets/060/
    cp $1/{720..779}.png $1_buckets/065/
    cp $1/{780..839}.png $1_buckets/070/
    cp $1/{840..899}.png $1_buckets/075/
    cp $1/{900..959}.png $1_buckets/080/
    cp $1/{960..1019}.png $1_buckets/085/
    cp $1/{1020..1079}.png $1_buckets/090/
    cp $1/{1080..1139}.png $1_buckets/095/
    cp $1/{1140..1199}.png $1_buckets/100/
}

copy_to_buckets "underground_tank/anim"
copy_to_buckets "underground_tank/hr-anim"
