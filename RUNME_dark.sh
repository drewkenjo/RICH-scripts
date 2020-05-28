#las!/bin/bash

###########
#  USER   #
###########

source /home/rich/LaserTED/swFE/bin_mc/RUNME.cfg

DISABLEFULLGRID=0 # skip [gain,thr] = [x2,25][x4,25][x4,50] use it for high gain mapmt

############
#  EXPERT  #
############
debug=0 # use 0 for data taking
ENABLECALG=0 # enable online gain calibration
ADDR_TOP="192.168.2.10" # TOP
ADDR_BOT="192.168.1.10" # BOTTOM

ADCNBIT=12 # 12, 10 or  8


##############
#  FUNCTION  #
##############

#-----------------------------
ADC_RESOLUTION(){
#-----------------------------
  BITS=$1
  TEN=0
  EIGHT=0

  if [ $BITS -eq 8 ]; then
    EIGHT=1
  fi

  if [ $BITS -eq 10 ]; then
    TEN=1
  fi
}


#-----------------------------
SET_FPGA(){
#-----------------------------
  ip=$1 
}


#-----------------------------
SET_MAROC_ID(){
#-----------------------------
  mrc0=$1
  mrc1=$2
  mrc2=$3
  printf -v TILEFOLDER '../tile/%s_%s_%s/' $mrc0 $mrc1 $mrc2
  printf -v TILEFOLDERBIS '../tile/%s_%s_%s_' $mrc0 $mrc1 $mrc2
  printf -v DB '../db/%s_%s_%s' $mrc0 $mrc1 $mrc2
  printf -v OUTFOLDER ../out/

  mkdir $TILEFOLDER
}


#-----------------------------
SET_MAPMT(){
#-----------------------------
  mapmt0=$1
  mapmt1=$2
  mapmt2=$3
}


#-----------------------------
SET_TDC(){
#-----------------------------
  SOURCE=$1; # 0 CTEST, 1 ANODES
}


#-----------------------------
SET_TDC_EVBUILDER(){
#-----------------------------
  TRIG_DELAY=$1 
  LOOKBACK=$2
  WINDOW=$3 
}


#-----------------------------
SET_PULSER(){
#-----------------------------
  PULSE_FREQ=20000 # TDC + ADC
  #PULSE_FREQ=500000 # TDC only
  PULSE_DUTYCYCLE=0.9
  PULSE_REPETITION=100000000
}


#-----------------------------
SET_STATISTICS(){
#-----------------------------
  TIME=1800
  EVENTS=1000000   # 10^6
# EVENTS=100000   # 10^5
# EVENTS=10000   # 10^4
# EVENTS=1000   # 10^3
}


#-----------------------------
SET_GAIN_MODE(){
#-----------------------------
  GAIN_MODE=$1 # 0 FOR NO EQUALIZAITON, 1 FOR MAPS
}


#-----------------------------
SET_GAIN_DEFAULT(){
#-----------------------------
  GAIN=$1 
}


#-----------------------------
SET_THRESHOLD(){
#-----------------------------
  # MODE = 0 absolute threshold 
  # MODE = 1 relative to the pedestal file in ../db/<tile>/chip0.txt
  #THR_MODE=0
  #THR=250  

  THR_MODE=$1
  THR=$2
}


#-----------------------------
SET_ADC(){
#-----------------------------
 ENABLE_ADC=1
}


#-----------------------------
SET_CTEST(){
#-----------------------------
  # CHANNEL TEST MASK (CTEST PIN, AUXILIARY INPUT)
  # 0 = disabled 
  # 1 = single channel (ch_sel), 
  # 2 = all channels
  # 3 = all but one (ch_sel)
  CTEST_MODE=0 
  CTEST_CHSEL=23 
}


#-----------------------------
SET_CHARGE(){
#-----------------------------
  CTEST_AMPLITUDE=$1 
}


#-----------------------------
SET_PROBING(){
#-----------------------------
  # 0..63 to enable an individual channel (oscilloscope or for DC measurement)
  # -1 to disable  
  PROBE=$1
}


#-----------------------------
SET_RUN_ID(){
#-----------------------------
   RUNID=$1
}

###########
# STORAGE #
###########


#-----------------------------
STORE_TILE(){
#-----------------------------
  NOW=$(date +"%Y_%m_%d_%H_%M")
  echo $NOW

  if [ $debug -eq 1 ]; then 
    mv $TILEFOLDER $TILEFOLDERBIS$NOW_$debug
    echo Data stored in $TILEFOLDERBIS$NOW_$debug
  else
    mv $TILEFOLDER $TILEFOLDERBIS$NOW
    echo Data stored in $TILEFOLDERBIS$NOW
  fi
  cp RUNME.cfg $TILEFOLDERBIS$NOW

  #echo ./PARSING $TILEFOLDERBIS$NOW 1 60 1
  #./PARSING.sh $TILEFOLDERBIS$NOW 1 60 1 &
}


############
# COMMANDS #
############

#-----------------------------
DO_WHEEL(){
#-----------------------------
   w=$1 
   wheel $w
}


#-----------------------------
DO_HV(){
#-----------------------------

  hvon $hv
  echo HV RAMPING, WAIT $RAMP seconds
  sleep $RAMP
  echo HV SETTLING, WAIT $WARMUP seconds
  sleep $WARMUP  
  echo DO_HV $hv DONE
}


#-----------------------------
DO_SLOWCONTROL(){
#-----------------------------
  echo DO_SLOWCONTROL
  ./daq run.address=$ip run.daq_mode=2 \
  run.maroc.id.[0]=$mrc0  run.maroc.id.[1]=$mrc1  run.maroc.id.[2]=$mrc2 
}


#-----------------------------
DO_RUN(){
#-----------------------------
   PREFIX="run"
   DAQMODE=1 # events

   if [ $debug -eq 1 ]; then 
     echo W$w TILE $TILE  RUN $totRun HV $hv G $GG THR $thr 
     EVENTS=1000

  else

    laser 0
    sleep 1

    laser 1
    sleep 1


    ./daq run.name=$PREFIX run.address=$ip run.id=$RUNID run.daq_mode=$DAQMODE \
    run.maroc.gain_mode=$GAIN_MODE run.maroc.gain_default=$GAIN \
    run.maroc.thr_default=$THR run.maroc.thr_mode=$THR_MODE \
    run.tdc.trigger_delay=$TRIG_DELAY \
    run.tdc.evtb_lookback=$LOOKBACK run.tdc.evtb_windowwidth=$WINDOW \
    run.maroc.EN_ADC=$ENABLE_ADC run.adc.enable_adc=$ENABLE_ADC run.adc.hold_delay=13 \
    run.maroc.ramp_8bit=$EIGHT run.maroc.ramp_10bit=$TEN \
    run.event_preset=$EVENTS run.time_preset=$TIME \
    run.ctest_amplitude=$CTEST_AMPLITUDE run.maroc.ctest_mode=$CTEST_MODE run.maroc.ch_sel=$CTEST_CHSEL \
    run.maroc.ch_probe=$PROBE \
    run.source_type=$SOURCE \
    run.pulser.frequency=$PULSE_FREQ run.pulser.dutycycle=$PULSE_DUTYCYCLE run.pulser.repetition=$PULSE_REPETITION \
    run.maroc.id.[0]=$mrc0  run.maroc.id.[1]=$mrc1  run.maroc.id.[2]=$mrc2 \
    run.mapmt.id.[0]=$mapmt0 run.mapmt.id.[1]=$mapmt1 run.mapmt.id.[2]=$mapmt2 \
    run.mapmt.hv=$hv \
    run.laser.y=$lasy run.laser.x=$lasx run.laser.w=$w 

    laser 0
  fi

  DO_LOG

  totRun=$((totRun+1))
}


#-----------------------------
SET_SCALER(){
#-----------------------------
  PREFIX="scaler"
  DAQMODE=0 # scaler
  DURATION=10000 # Scaler window in milliseconds
  REPETITION=1 # Number of iterations
}


#-----------------------------
SET_SCALER_DARK(){
#-----------------------------
  PREFIX="scaler_dark"
  PULSE_REPETITION=0
  DAQMODE=0 # scaler
  DURATION=10000 # Scaler window in milliseconds
  REPETITION=1 # Number of iterations
}


#-----------------------------
DO_SCALER(){
#-----------------------------
  echo DO_SCALER
  laser $1;
  time ./daq run.name=$PREFIX run.address=$ip run.id=$RUNID run.daq_mode=$DAQMODE \
  run.slowcontrol.repetition=$REPETITION run.slowcontrol.time_interval=$DURATION \
  run.maroc.gain_mode=$GAIN_MODE run.maroc.gain_default=$GAIN \
  run.maroc.thr_default=$THR run.maroc.thr_mode=$THR_MODE \
  run.ctest_amplitude=$CTEST_AMPLITUDE run.maroc.ctest_mode=$CTEST_MODE run.maroc.ch_sel=$CTEST_CHSEL \
  run.maroc.ch_probe=$PROBE \
  run.source_type=$SOURCE \
  run.pulser.frequency=$PULSE_FREQ run.pulser.dutycycle=$PULSE_DUTYCYCLE \
  run.pulser.repetition=$PULSE_REPETITION \
  run.maroc.id.[0]=$mrc0  run.maroc.id.[1]=$mrc1  run.maroc.id.[2]=$mrc2 \
  run.mapmt.id.[0]=$mapmt0 run.mapmt.id.[1]=$mapmt1 run.mapmt.id.[2]=$mapmt2 \
  run.mapmt.hv=$hv \
  run.laser.y=$y run.laser.x=$x run.laser.w=$w 
  DO_LOG
}


#-----------------------------
DO_LOG(){
#-----------------------------
 printf -v ENTRY  '%3d W %d X %4d Y %4d HV %5d GMODE %2d GAIN %5s THR %5d %s\n'  $totRun $w $x $y $hv $GAIN_MODE $GAIN $THR $g$PREFIX
 echo $ENTRY >> ./logbook.txt
 #echo $ENTRY appended to ./logbook.txt
}


#-----------------------------
SET_HV(){
#-----------------------------
  hv=$1

  RAMP=60
  WARMUP=60
  if [ $debug -eq 1 ]; then 
    RAMP=0 
    WARMUP=0
  fi

  DO_HV
  DO_SLOWCONTROL
}

#-----------------------------
TURN_OFF(){
#-----------------------------
  lvoff
  hvoff
  laser 0
  echo -------------------------------
  echo I am done: everything OFF
  echo -------------------------------
}

#-----------------------------
INIT_SW(){  
#-----------------------------
 
  rm -f ./fpgaMonitor.txt
  rm -f ./logbook.txt

  if [ "$TILE" = "TOP" ]; then 
    lasx=215
    lasy=30
    lts_run $lasx $lasy
    SET_FPGA $ADDR_TOP
    SET_MAROC_ID $TOP_MAROC0 $TOP_MAROC1 $TOP_MAROC2
    SET_MAPMT $TOP_MAPMT0 $TOP_MAPMT1 $TOP_MAPMT2
  else
    lasx=215
    lasy=125
    lts_run $lasx $lasy
    SET_FPGA $ADDR_BOT
    SET_MAROC_ID $BOTTOM_MAROC0 $BOTTOM_MAROC1 $BOTTOM_MAROC2
    SET_MAPMT $BOTTOM_MAPMT0 $BOTTOM_MAPMT1 $BOTTOM_MAPMT2
  fi

  SET_ADC 1
  SET_TDC_EVBUILDER 30 30 30 
  SET_PROBING -1
  SET_TDC 1
  SET_STATISTICS
  SET_GAIN_MODE 0
  SET_GAIN_DEFAULT 64
  SET_THRESHOLD 1 50
  SET_PULSER
  SET_CTEST
  #SET_CHARGE 400 # [0..4095] that corresponds roughly to [5fC..2.5pC]

  w=0 

  echo ADC_RESOLUTION $ADCNBIT
  ADC_RESOLUTION $ADCNBIT    
  sleep 1

}


#-----------------------------
DO_PEDESTAL(){
#-----------------------------
  laser 0
  hvoff 0

  if [ $debug -eq 1 ]; then 
    echo " DEBUG MODE -------------------> PEDESTAL"
  else

  for GG in 64 #16 32 64 128 255
  do
#    echo ./PED.sh $mrc0 $mrc1 $mrc2 $GG 0 $ip
#    ./PED.sh $mrc0 $mrc1 $mrc2 $GG 0 $ip  
    printf -v GPEDFILEFORANA '%s/pedestal0_%03d.txt' $TILEFOLDER  $GG
    printf -v GPEDFILEFORDAQ '%s/chip0_%03d.txt' $TILEFOLDER  $GG
    echo cp $DB/pedestal0.txt  $GPEDFILEFORANA
    cp $DB/pedestal0.txt  $GPEDFILEFORANA
    echo cp $DB/chip0.txt  $GPEDFILEFORDAQ
    cp $DB/chip0.txt  $GPEDFILEFORDAQ
  done 
  fi   
  rm -f $TILEFOLDER/*.log
  rm -f $TILEFOLDER/*.bin 
  rm -f $TILEFOLDER/*.pdf
  rm -f $TILEFOLDER/*.root 
  rm -f $TILEFOLDER/pedestal0.txt
  #rm -f $TILEFOLDER/chip0.txt
  rm -f $TILEFOLDER/ped*ADC* 

  DO_SLOWCONTROL

}


#-----------------------------
DARK(){
#-----------------------------

  SET_SCALER_DARK

  rm -f $OUTFOLDER$PREFIX*
  DARKFOLDER="SCALERDARK"
  echo mkdir $DARKFOLDER
  mkdir $DARKFOLDER

  DO_SLOWCONTROL
  for hv in 1000 1050 1100 #1010 1020 1030 1040 1050 1060 1070 1080 1090 1100 #1025 1050 1075 1100  
  do
    SET_HV $hv
    for GG in 64
    do
      SET_GAIN_MODE 0
      SET_GAIN_DEFAULT $GG
      printf -v DARK_SUB '%s/HV%04d_GAIN%04d' $DARKFOLDER  $hv $GG
      mkdir $DARK_SUB
      NOW=$(date +"%Y-%m-%d_%H-%M-%S")
      echo $NOW
      printf -v DARKFILE '%s/rich_pedestal_%s.txt' $DARK_SUB $NOW
      touch $DARFILE
      threshold=150
      while [ $threshold -lt 700 ] 
      do
        echo THRESHOLD = $threshold
        SEC=$(date +"%s")
        echo $threshold >> $DARKFILE
        echo $GG >> $DARKFILE
        echo $SEC >> $DARKFILE
        echo $DURATION >> $DARKFILE

        SET_THRESHOLD 0 $threshold
        SET_RUN_ID $hv
        totRun=$hv
        DO_SCALER 0
        printf -v DARKFILE_OLD '%sscaler_dark_%06d.txt' $OUTFOLDER  $hv
        printf -v DARKLOG_OLD '%sscaler_dark_%06d.log' $OUTFOLDER  $hv
        printf -v DARKFILE_NEW '%sscaler_dark_HV%04d_GAIN%04d_THR%04d.txt' $OUTFOLDER  $hv $GAIN $THR
        printf -v DARKLOG_NEW '%sscaler_dark_HV%04d_GAIN%04d_THR%04d.log' $OUTFOLDER  $hv $GAIN $THR
        echo mv $DARKFILE_OLD $DARKFILE_NEW
        mv $DARKFILE_OLD $DARKFILE_NEW
        mv $DARKLOG_OLD $DARKLOG_NEW

        head  -64 $DARKFILE_NEW | awk '{printf("%8d %10d\n",$1,$2);}'  >> $DARKFILE
        head -129 $DARKFILE_NEW | tail -64 | awk '{printf("%8d %10d\n",$1,$2);}'  >> $DARKFILE
        head -194 $DARKFILE_NEW | tail -64 | awk '{printf("%8d %10d\n",$1,$2);}'  >> $DARKFILE
        
        threshold=`expr $threshold + 1`
      done # loop on THRESHOLD
      DO_SLOWCONTROL
      
       
    done # loop on GAIN
  done # loop on HV

  echo  ls -ltr $OUTFOLDER$PREFIX*
  ls -ltr $OUTFOLDER$PREFIX*
  echo  ls -ltr $TILEFOLDER
  ls -ltr $TILEFOLDER

  echo mv $OUTFOLDER$PREFIX* $DARKFOLDER
  mv $OUTFOLDER$PREFIX* $DARKFOLDER
  echo mv $DARKFOLDER $TILEFOLDER
  mv $DARKFOLDER $TILEFOLDER

}


#-----------------------------
COPY_LOGBOOK(){
#-----------------------------
  cat ./logbook.txt
  mv ./logbook.txt $TILEFOLDER
}


#-----------------------------
COPY_FPGAMONITOR(){
#-----------------------------
  cat ./fpgaMonitor.txt
  mv ./fpgaMonitor.txt $TILEFOLDER
}


#-----------------------------
DO_DATA_ACQUISITION(){
#-----------------------------

  echo "-----------------------------------------------> RUN "$totRun
  #totRun=1
  TIME=1800
  SET_GAIN_DEFAULT 64
  SET_THRESHOLD 1 50
 
  for hv in 1000 1100
  do
    SET_HV $hv

    for thr in 600
    do
      SET_THRESHOLD 1 $thr
      for GG in 64 40
      do
       
        SET_GAIN_MODE 0
        SET_GAIN_DEFAULT $GG
        SET_RUN_ID $totRun
        DO_RUN

        prevRun=$((totRun-1))
        printf -v FILESEED '%srun_%06d' $TILEFOLDER $prevRun
        printf -v PEDFILE '%s.ped' $FILESEED   
        printf -v GPEDFILEFORANA '%s/pedestal0_%03d.txt' $TILEFOLDER  $GG
        #cp $GPEDFILEFORANA $PEDFILE
        echo cp $GPEDFILEFORANA $PEDFILE 
        cp $GPEDFILEFORANA $PEDFILE 2>/dev/null # to suppress error output in bash
        
        if [ $ENABLECALG -eq 1 ]; then  
          ### ONLINE CALIB
          #eqmode=BES
           eqmode=TOT
          # eqmode=PMT
          printf -v LOGFILE '%s.log' $FILESEED
          ./reco $LOGFILE  

          ./ana  $LOGFILE $PEDFILE
          printf -v PARSTRING 'W%s_HV%s_THR%s' $w $hv $thr
          printf -v cmd 'plotADC.C++("%s","%s",192)' $FILESEED $PARSTRING    
          root -l -b -q  $cmd
          ./MapsGenerator_clean.sh $hv $thr $prevRun $TILEFOLDER $eqmode $mapmt0 $mapmt1 $mapmt2
          SET_GAIN_MODE 1
          SET_RUN_ID $totRun        
          DO_RUN
          prevRun=$((totRun-1))
          printf -v FILESEED '%srun_%06d' $TILEFOLDER $prevRun
          printf -v PEDFILE '%s.ped' $FILESEED   
          echo cp $TILEFOLDER/pedestal0.txt $PEDFILE
          cp $TILEFOLDER/pedestal0.txt $PEDFILE
        fi
      done
    done
  done
}



#-----------------------------
LASER(){
#-----------------------------
  w=$1
  EVENTS=$2
  DO_WHEEL $w 
  DO_SLOWCONTROL

  DO_DATA_ACQUISITION

  DO_SLOWCONTROL

}


#########
# MAIN  #
#########

date
#for TILE in TOP BOTTOM
for TILE in TOP 
do
  INIT_SW    
  lvon
  sleep 3
  DO_PEDESTAL
  totRun=1 # Run Counter  
#  LASER 3 100000000
#  LASER 4 100000000
#  LASER 5 100000000
#  LASER 6 100000000
#  LASER 1 100000

#  LASER 3 500000
#  LASER 1 15000000
#  LASER 2 15000000
#  LASER 3 15000000
#  LASER 4 15000000
#  LASER 5 15000000
#  LASER 6 15000000
  DARK
  COPY_LOGBOOK
  COPY_FPGAMONITOR
  STORE_TILE
  TURN_OFF
done
date
#eof
