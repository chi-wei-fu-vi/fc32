#!/bin/env python2
from dom_reconfig_api_13sp1 import *
from dom_serdes_api import *
import time
import datetime
from pprint import pprint

debug=0
def ber_1d(fpgaid,chid,prbs_mode,phase_step=0,EyeQ_enable=0,max_error_bits=10,max_bit_error_rate=0.1,max_run_time_in_seconds=10,polling_interval_in_seconds=2,verbose=0):
  """
  Bit error rate test
  When enable_eye_view = 1, use Altera's BER.  Otherwise, use Prbs in DOM fabric.
  phase_step                  = 0
  max_error_bits              = 10
  max_bit_error_rate          = 0.1
  max_run_time_in_seconds     = 10
  polling_interval_in_seconds = 2
  """
  global debug


  # prbs selection
  prbs_sel_list = { 'off' : 0, 'prbs7' : 1, 'prbs31' : 2 }

  # send preamble
  set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list['off'],verbose)

  # Transceiver RX word aligner: 0 to disable, 1 to enable
  # enable_word_aligner = 0


  ####################################################
  # BER test
  ####################################################

  # Not using internal loopback
  set_Ctl_SerialLpbkEn(fpgaid,chid,0,verbose)


  if debug : print "\n\n--- 1D EyeQ on FPGA %d logical channel %d ---\n\n" % (fpgaid,chid)

  # open serdes channel
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_1D_Eye(fpgaid,1,verbose)


  if EyeQ_enable:
    # enable EyeQ
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_step,verbose)
    reconfig_EyeQ_set_Polarity(fpgaid,0,verbose)
    # Reset everything, snapshot and counters are reset to 0
    reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,1,verbose)
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
    # set to 0, pauses accumulation, preserving the current values
    reconfig_EyeQ_set_Counter_Enable(fpgaid,0,verbose)
    print "Running test for %d seconds with %s:" % (max_run_time_in_seconds,"EyeQ BER")
  else:
    # disable EyeQ
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_step,verbose)
    # initialize prbs
    set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list[prbs_mode],verbose)
    set_PrbsCtl_NotLockedCntClr(fpgaid,chid,1,verbose)
    print "Running test for %d seconds with %s:" % (max_run_time_in_seconds,prbs_mode)
    # Reset counters, start generator and checker
    set_PrbsCtl_RxCntClr(fpgaid,chid,1,verbose)
    set_PrbsCtl_ErrCntClr(fpgaid,chid,1,verbose)

  # report serdes channel status
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
  reconfig_EyeQ_set_Counter_Enable(fpgaid,1,verbose)
  reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
  if debug : reconfig_dump_state(fpgaid,verbose)

  if debug : print "%17s %14s %12s %14s"%("Elapsed time(sec)"," Total bits   "," Error bits ","Bit error rate")
  if debug : print "%17s %14s %12s %14s"%("=================","==============","============","==============")


  # clear counter before start test
  if EyeQ_enable:
    # set to 1, set to 1, the counters accumulate bits and errors
    reconfig_EyeQ_set_Counter_Enable(fpgaid,1,verbose)
  else:
    # Reset counters, start generator and checker
    set_PrbsCtl_RxCntClr(fpgaid,chid,1,verbose)
    set_PrbsCtl_ErrCntClr(fpgaid,chid,1,verbose)

  start_time = time.time()
  elapsed_time = 0
  error_bits = 0
  locked = 1
  while elapsed_time < max_run_time_in_seconds and error_bits < max_error_bits and locked == 1:
    time.sleep(polling_interval_in_seconds*1000*0.001)
    elapsed_time = time.time() - start_time
    if EyeQ_enable:
      # Copy the counter values into local registers for read access
      reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,2,verbose)
      reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
      reconfig_EyeQ_set_Counter_Enable(fpgaid,1,verbose)
      reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
      total_bits     = (reconfig_EyeQ_get_Bit_Counter63_32(fpgaid,verbose) << 32) + reconfig_EyeQ_get_Bit_Counter31_0(fpgaid,verbose)
      #total_bits     = reconfig_EyeQ_get_Bit_Counter31_0(fpgaid,verbose)
      total_bits     = total_bits * 256
      error_bits     = (reconfig_EyeQ_get_Err_Conter63_32(fpgaid,verbose)  << 32) + reconfig_EyeQ_get_Err_Counter31_0(fpgaid,verbose)
      #error_bits     = reconfig_EyeQ_get_Err_Counter31_0(fpgaid,verbose)
      bit_error_rate = float(error_bits)/float(total_bits)
      if debug : print "%17d %14d %12d %14e"%(elapsed_time,total_bits,error_bits,bit_error_rate)
    else:
      if get_PrbsLock(fpgaid,chid,verbose):
        # Snapshot the counters
        total_bits     = get_PrbsRxCnt(fpgaid,chid,verbose)
        error_bits     = get_PrbsErrCnt(fpgaid,chid,verbose)
        bit_error_rate = float(error_bits)/float(total_bits)
        if debug : print "%17d %14d %12d %14e"%(elapsed_time,total_bits,error_bits,bit_error_rate)
      else:
        if debug : print "%17d %14s %12s %14s"%(elapsed_time,"[Not locked]","[Not locked]","[Not locked]")
        total_bits     = 0
        error_bits     = 0
        bit_error_rate = 0
        locked = 0

  if elapsed_time >= max_run_time_in_seconds:
    if debug : print "\nTest stopped after achieving maximum run time of %d seconds" % max_run_time_in_seconds
  elif error_bits >= max_error_bits:
    if debug : print "\nTest stopped after hitting the maximum number of error bits of %d bits" % max_error_bits
  else:
    if debug : print "\nTest stopped because checker cannot lock to incoming data pattern"

  # Stop generator and checker
  set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list['off'],verbose)

  if debug : print "\n\n--- End of PRBS test on FPGA %d logical channel %d ---\n\n" % (fpgaid,chid)

  return (locked,bit_error_rate,total_bits,error_bits)

def dfe_tap1_sweep (fpgaid,chid,eq_ctrl_list=[0,1,2],dfe_tap_list=[[0,1,2],[0,1,2],[0,1,2]],prbs_mode="prbs7",phase_step=0,EyeQ_enable=0,max_error_bits=10,max_bit_error_rate=0.1,max_run_time_in_seconds=10,polling_interval_in_seconds=2,verbose=0):
  """
  """
  global debug
  # Procedure to run for DFE Tap1 value
  final_dfe_tap1 = 0
  final_dfe_tap2 = 0
  final_dfe_tap3 = 0
  ber_lowest     = 1
  ber_lower_tap1 = 1
  ber_lower_tap2 = 1
  ber_lower_tap3 = 1
  eq_ctrl_best   = 0
  locked         = 0
  break_eq_loop  = 0
  dfe_tap1_list = dfe_tap_list[0]
  dfe_tap2_list = dfe_tap_list[1]
  dfe_tap3_list = dfe_tap_list[2]
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)

  for eq_ctrl in eq_ctrl_list:
    #reset DFE Tap Value
    dfe_tap2_val = 0
    dfe_tap3_val = 0
    reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
    reconfig_DFE_set_tap_2_polarity(fpgaid,0,verbose)
    reconfig_DFE_set_tap_2(fpgaid,dfe_tap2_val,verbose)
    reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
    reconfig_DFE_set_tap_3_polarity(fpgaid,0,verbose)
    reconfig_DFE_set_tap_3(fpgaid,dfe_tap3_val,verbose)

    # Set Rx Equalizer value
    reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
    reconfig_PMA_set_RX_equalization_control(fpgaid,eq_ctrl,verbose)

    for dfe_tap1 in dfe_tap1_list:
      # Set DFE Tap Value 1
      reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
      reconfig_DFE_set_tap_1(fpgaid,dfe_tap1,verbose)
      # call ber_1d for dfe calibration
      # phase_step=0,EyeQ_enable=0,max_error_bits=10000,max_bit_error_rate=0.1,user_run_time_in_seconds,interval_in_seconds=2
      (locked,bit_error_rate,total_bits,error_bits) = ber_1d(fpgaid,chid,prbs_mode,phase_step,EyeQ_enable,max_error_bits,max_bit_error_rate,max_run_time_in_seconds,polling_interval_in_seconds,verbose)

      if locked == 1:
        if bit_error_rate == 0:
          ber_lower_tap1 = bit_error_rate
          ber_lowest     = ber_lower_tap1
          eq_ctrl_best   = eq_ctrl
          final_dfe_tap1 = dfe_tap1
          dfe_tap2_val   = 0
          dfe_tap3_val   = 0
          break_eq_loop  = 1

          # Print output before found BER=0.000 for and break
          print "%14d %12d %12d %12d %14d %12d %14e"%(eq_ctrl,final_dfe_tap1,dfe_tap2_val,dfe_tap3_val,total_bits,error_bits,ber_lowest)
          break
        else:

          if ber_lowest > bit_error_rate:
            ber_lower_tap1 = bit_error_rate
            final_dfe_tap1 = dfe_tap1
            ber_lowest     = bit_error_rate
            eq_ctrl_best   = eq_ctrl

      print "%14d %12d %12d %12d %14d %12d %14e"%(eq_ctrl,dfe_tap1,dfe_tap2_val,dfe_tap3_val,total_bits,error_bits,bit_error_rate)

    if ber_lower_tap1 > 0:
      # Set Lowest DFE Tap Value 1
      reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
      reconfig_DFE_set_tap_1(fpgaid,chid,final_dfe_tap1,verbose)

      # BER is not equal to 0, run DFE Tap2 experiment
      (dfe_tap2_ber,dfe_tap2_val,dfe_tap2_bit,dfe_tap2_err,dfe_tap3_ber,dfe_tap3_val,dfe_tap3_bit,dfe_tap3_err)=dfe_tap2_sweep(fpgaid,chid,dfe_tap_list,final_dfe_tap1,eq_ctrl,prbs_mode,phase_step,EyeQ_enable,max_error_bits,max_bit_error_rate,max_run_time_in_seconds,polling_interval_in_seconds)

      if dfe_tap3_ber > dfe_tap2_ber:
        if dfe_tap2_ber > ber_lower_tap1:
          if ber_lowest > ber_lower_tap1:
            ber_lowest = ber_lower_tap1
            eq_ctrl_best = eq_ctrl
            final_dfe_tap2 = 0
            final_dfe_tap3 = 0
            locked = 1
        else:
          if ber_lowest > dfe_tap2_ber:
            #set ber_lower_tap2 dfe_tap2_ber
            ber_lowest = dfe_tap2_ber
            eq_ctrl_best = eq_ctrl
            final_dfe_tap2 = dfe_tap2_val
            final_dfe_tap3 = 0
            total_bits = dfe_tap2_bit
            error_bits = dfe_tap2_err
            locked = 1

            if dfe_tap2_ber == 0:
              break_eq_loop = 1
      else:
        if ber_lowest > dfe_tap3_ber:
          #set ber_lower_tap3 dfe_tap3_ber
          ber_lowest = dfe_tap3_ber
          eq_ctrl_best = eq_ctrl
          final_dfe_tap2 = dfe_tap2_val
          final_dfe_tap3 = dfe_tap3_val
          total_bits = dfe_tap3_bit
          error_bits = dfe_tap3_err
          locked = 1

          if dfe_tap3_ber == 0:
            break_eq_loop = 1


    # if BER found inside DFE Tap loop 1,2,3 then break this loop
    if break_eq_loop == 1:
      break

  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,0,verbose)
  return (ber_lowest,final_dfe_tap1,final_dfe_tap2,final_dfe_tap3,total_bits,error_bits,locked,eq_ctrl_best)

def dfe_tap2_sweep (fpgaid,chid,dfe_tap_list,final_dfe_tap1,eq_ctrl,prbs_mode="prbs7",phase_step=0,EyeQ_enable=0,max_error_bits=10,max_bit_error_rate=0.1,max_run_time_in_seconds=10,polling_interval_in_seconds=2,verbose=0):
  """
  """
  global debug
  final_dfe_tap2  = 0
  ber_lower_tap2  = 1
  dfe_tap3_ber    = 1
  dfe_tap3_val    = 0
  error_bit_lower = 0

  dfe_tap1_list = dfe_tap_list[0]
  dfe_tap2_list = dfe_tap_list[1]
  dfe_tap3_list = dfe_tap_list[2]
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)

  for dfe_tap2 in dfe_tap2_list:
    # Set DFE Tap Value 2
    reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
    if dfe_tap2 > 0:
      reconfig_DFE_set_tap_2_polarity(fpgaid,1,verbose)
      reconfig_DFE_set_tap_2(fpgaid,chid,dfe_tap2,verbose)
    else:
      reconfig_DFE_set_tap_2_polarity(fpgaid,0,verbose)
      reconfig_DFE_set_tap_2(fpgaid,chid,dfe_tap2,verbose)

    # call ber_1d for dfe calibration
    # phase_step=0,EyeQ_enable=0,max_error_bits=10000,max_bit_error_rate=0.1,user_run_time_in_seconds,interval_in_seconds=2
    (locked,bit_error_rate,total_bits,error_bits) = ber_1d(fpgaid,chid,prbs_mode,phase_step,EyeQ_enable,max_error_bits,max_bit_error_rate,max_run_time_in_seconds,polling_interval_in_seconds,verbose)
 
    if locked == 1:
      if bit_error_rate == 0:
        ber_lower_tap2 = bit_error_rate
        final_dfe_tap2 = dfe_tap2
        print "%14d %12d %12d %12d %14d %12d %14e"%(eq_ctrl,final_dfe_tap1,final_dfe_tap2,dfe_tap3_val,total_bits,error_bits,ber_lower_tap2)
        break
      elif bit_error_rate < ber_lower_tap2:
        ber_lower_tap2 = bit_error_rate
        final_dfe_tap2 = dfe_tap2
    print "%14d %12d %12d %12d %14d %12d %14e"%(eq_ctrl,final_dfe_tap1,dfe_tap2,dfe_tap3_val,total_bits,error_bits,bit_error_rate)

  if ber_lower_tap2 > 0:
    # Set Lowest DFE Tap Value 2
    reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
    if dfe_tap2 > 0:
      reconfig_DFE_set_tap_2_polarity(fpgaid,1,verbose)
      reconfig_DFE_set_tap_2(fpgaid,chid,final_dfe_tap2,verbose)
    else:
      reconfig_DFE_set_tap_2_polarity(fpgaid,0,verbose)
      reconfig_DFE_set_tap_2(fpgaid,chid,final_dfe_tap2,verbose)

    # BER is not equal to 0, run DFE Tap2 experiment
    (dfe_tap3_ber,dfe_tap3_val,dfe_tap3_bit,dfe_tap3_err)= dfe_tap3_sweep(fpgaid,chid,dfe_tap_list,final_dfe_tap1,final_dfe_tap2,eq_ctrl,prbs_mode,phase_step,EyeQ_enable,max_error_bits,max_bit_error_rate,max_run_time_in_seconds,polling_interval_in_seconds,verbose)


  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,0,verbose)
  return (ber_lower_tap2,final_dfe_tap2,total_bits,error_bits,dfe_tap3_ber,dfe_tap3_val,dfe_tap3_bit,dfe_tap3_err)

def dfe_tap3_sweep (fpgaid,chid,dfe_tap_list,final_dfe_tap1,final_dfe_tap2,eq_ctrl,prbs_mode="prbs7",phase_step=0,EyeQ_enable=0,max_error_bits=10,max_bit_error_rate=0.1,max_run_time_in_seconds=10,polling_interval_in_seconds=2,verbose=0):
  """
  """
  global debug
  final_dfe_tap3  = 0
  ber_lower_tap3  = 1
  error_bit_lower = 0

  dfe_tap1_list = dfe_tap_list[0]
  dfe_tap2_list = dfe_tap_list[1]
  dfe_tap3_list = dfe_tap_list[2]
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)

  for dfe_tap3 in dfe_tap3_list:
    # Set DFE Tap Value 3
    reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
    if dfe_tap3 > 0:
      reconfig_DFE_set_tap_3_polarity(fpgaid,chid,1,verbose)
      reconfig_DFE_set_tap_3(fpgaid,chid,dfe_tap3,verbose)
    else:
      reconfig_DFE_set_tap_3_polarity(fpgaid,chid,0,verbose)
      reconfig_DFE_set_tap_3(fpgaid,chid,dfe_tap3,verbose)

    # call ber_1d for dfe calibration
    # phase_step=0,EyeQ_enable=0,max_error_bits=10000,max_bit_error_rate=0.1,user_run_time_in_seconds,interval_in_seconds=2
    (locked,bit_error_rate,total_bits,error_bits) = ber_1d(fpgaid,chid,prbs_mode,phase_step,EyeQ_enable,max_error_bits,max_bit_error_rate,max_run_time_in_seconds,polling_interval_in_seconds,verbose)

    if locked == 1:
      if bit_error_rate == 0:
        final_dfe_tap3 = dfe_tap3
        ber_lower_tap3 = 0
        print "%14d %12d %12d %12d %14d %12d %14e"%(eq_ctrl,final_dfe_tap1,final_dfe_tap2,final_dfe_tap3,total_bits,error_bits,ber_lower_tap3)
        break
      elif bit_error_rate < ber_lower_tap3:
        final_dfe_tap3 = dfe_tap3
        ber_lower_tap3 = bit_error_rate

    print "%14d %12d %12d %12d %14d %12d %14e"%(eq_ctrl,final_dfe_tap1,final_dfe_tap2,dfe_tap3,total_bits,error_bits,bit_error_rate)

  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,0,verbose)
  return (ber_lower_tap3,final_dfe_tap3,total_bits,error_bits)

def ber_1d_test (fpgaid,chid,prbs_mode,phase_step=0,EyeQ_enable=0,max_error_bits=10,max_bit_error_rate=0.1,max_run_time_in_seconds=10,polling_interval_in_seconds=2,verbose=0):
  """
  Bit error rate test
  When enable_eye_view = 1, use Altera's BER.  Otherwise, use Prbs in DOM fabric.
  phase_step                  = 0
  max_error_bits              = 10
  max_bit_error_rate          = 0.1
  max_run_time_in_seconds     = 10
  polling_interval_in_seconds = 2
  """
  global debug


  # prbs selection
  prbs_sel_list = { 'off' : 0, 'prbs7' : 1, 'prbs31' : 2 }

  # send preamble
  set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list['off'],verbose)

  # Transceiver RX word aligner: 0 to disable, 1 to enable
  # enable_word_aligner = 0

  # EyeQ phase steps, not used if EyeQ is disabled
  phase_steps           = range(64)

  # Transceiver reconfig analog values
  vodctrl_list          = [0,1,2,3,4,5,6,7]
  preemph1t_list        = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
  preemph0t_list        = [-15,-14,-13,-12,-11,-10,-9,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
  preemph2t_list        = [-15,-14,-13,-12,-11,-10,-9,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
  dcgain_list           = [0,1,2,3]
  eqctrl_list           = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]




  ####################################################
  # BER test
  ####################################################

  # Not using internal loopback
  set_Ctl_SerialLpbkEn(fpgaid,chid,0,verbose)


  print "\n\n--- PRBS test on FPGA %d logical channel %d ---\n\n" % (fpgaid,chid)

  # open serdes channel
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_1D_Eye(fpgaid,1,verbose)


  if EyeQ_enable:
    # enable EyeQ
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_step,verbose)
    reconfig_EyeQ_set_Polarity(fpgaid,0,verbose)
    # Reset everything, snapshot and counters are reset to 0
    reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,1,verbose)
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
    # set to 0, pauses accumulation, preserving the current values
    reconfig_EyeQ_set_Counter_Enable(fpgaid,0,verbose)
    print "Running test for %s seconds with %d:" % (max_run_time_in_seconds,"EyeQ BER")
  else:
    # disable EyeQ
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_step,verbose)
    # initialize prbs
    set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list[prbs_mode],verbose)
    set_PrbsCtl_NotLockedCntClr(fpgaid,chid,1,verbose)
    print "Running test for %d seconds with %s:" % (max_run_time_in_seconds,prbs_mode)
    # Reset counters, start generator and checker
    set_PrbsCtl_RxCntClr(fpgaid,chid,1,verbose)
    set_PrbsCtl_ErrCntClr(fpgaid,chid,1,verbose)

  # report serdes channel status
  reconfig_dump_state(fpgaid,verbose)

  print "%17s %14s %12s %14s"%("Elapsed time(sec)"," Total bits   "," Error bits ","Bit error rate")
  print "%17s %14s %12s %14s"%("=================","==============","============","==============")


  # clear counter before start test
  if EyeQ_enable:
    # set to 1, set to 1, the counters accumulate bits and errors
    reconfig_EyeQ_set_Counter_Enable(fpgaid,1,verbose)
  else:
    # Reset counters, start generator and checker
    set_PrbsCtl_RxCntClr(fpgaid,chid,1,verbose)
    set_PrbsCtl_ErrCntClr(fpgaid,chid,1,verbose)

  while elapsed_time < max_run_time_in_seconds and error_bits < max_error_bits and locked == 1:
    if EyeQ_enable:
      # Copy the counter values into local registers for read access
      reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,2,verbose)
      reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
      reconfig_EyeQ_set_Counter_Enable(fpgaid,1,verbose)
      reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
      total_bits     = (reconfig_EyeQ_get_Bit_Counter63_32(fpgaid,verbose) << 32) + reconfig_EyeQ_get_Bit_Counter31_0(fpgaid,verbose)
      #total_bits     = reconfig_EyeQ_get_Bit_Counter31_0(fpgaid,verbose)
      total_bits     = total_bits * 256
      error_bits     = (reconfig_EyeQ_get_Err_Conter63_32(fpgaid,verbose)  << 32) + reconfig_EyeQ_get_Err_Counter31_0(fpgaid,verbose)
      #error_bits     = reconfig_EyeQ_get_Err_Counter31_0(fpgaid,verbose)
      bit_error_rate = float(error_bits)/float(total_bits)

    else:
      if get_PrbsLock(fpgaid,chid,verbose):
        # Snapshot the counters
        total_bits     = get_PrbsRxCnt(fpgaid,chid,verbose)
        error_bits     = get_PrbsErrCnt(fpgaid,chid,verbose)
        bit_error_rate = float(error_bits)/float(total_bits)
        print "%17d %14d %12d %14e"%(elapsed_time,total_bits,error_bits,bit_error_rate)
        error_bits = get_PrbsErrCnt(fpgaid,chid,verbose)
      else:
        print "%17d %14s %12s %14s"%(elapsed_time,"[Not locked]","[Not locked]","[Not locked]")
        locked = 0

  if elapsed_time >= max_run_time_in_seconds:
    print "\nTest stopped after achieving maximum run time of %d seconds" % max_run_time_in_seconds
  elif error_bits >= max_error_bits:
    print "\nTest stopped after hitting the maximum number of error bits of %d bits" % max_error_bits
  else:
    print "\nTest stopped because checker cannot lock to incoming data pattern"

  # Stop generator and checker
  set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list['off'],verbose)

  print "\n\n--- End of PRBS test on FPGA %d logical channel %d ---\n\n" % (fpgaid,chid)


def analog_sweep (fpgaid,chid,prbs_mode,phase_step=0,EyeQ_enable=0,max_error_bits=10000,max_bit_error_rate=0.1,max_run_time_in_seconds=10,polling_interval_in_seconds=2,verbose=0):
  """
  Bit error rate test
  When enable_eye_view = 1, use Altera's BER.  Otherwise, use Prbs in DOM fabric.
  phase_step                  = 0
  max_error_bits              = 10000
  max_bit_error_rate          = 0.1
  max_run_time_in_seconds     = 10
  polling_interval_in_seconds = 2
  """
  global debug


  # prbs selection
  prbs_sel_list = { 'off' : 0, 'prbs7' : 1, 'prbs31' : 2 }

  # send preamble
  set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list['off'],verbose)

  # Transceiver RX word aligner: 0 to disable, 1 to enable
  # enable_word_aligner = 0

  # EyeQ phase steps, not used if EyeQ is disabled
  phase_steps           = range(64)

  # Transceiver reconfig analog values
  #vodctrl_list          = [0,1,2,3,4,5,6,7]
  #preemph1t_list        = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
  #preemph0t_list        = [-15,-14,-13,-12,-11,-10,-9,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
  #preemph2t_list        = [-15,-14,-13,-12,-11,-10,-9,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
  #dcgain_list           = [0,1,2,3]
  #eqctrl_list           = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]

  vodctrl_list =   [50,63]
  preemph1t_list = [2]
  preemph0t_list = [1]
  preemph2t_list = [3]
  dcgain_list    = [1,2]
  eqctrl_list    = [1,3]



  ####################################################
  # BER test
  ####################################################

  # Not using internal loopback
  set_Ctl_SerialLpbkEn(fpgaid,chid,0,verbose)


  print "\n\n--- PRBS test on FPGA %d logical channel %d ---\n\n" % (fpgaid,chid)

  # open serdes channel
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
  reconfig_EyeQ_set_1D_Eye(fpgaid,1,verbose)


  if EyeQ_enable:
    # enable EyeQ
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_step,verbose)
    reconfig_EyeQ_set_Polarity(fpgaid,0,verbose)
    # Reset everything, snapshot and counters are reset to 0
    reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,1,verbose)
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
    # set to 0, pauses accumulation, preserving the current values
    reconfig_EyeQ_set_Counter_Enable(fpgaid,0,verbose)
    print "Running test for %d seconds with %s:" % (max_run_time_in_seconds,"EyeQ BER")
  else:
    # disable EyeQ
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_step,verbose)
    # initialize prbs
    set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list[prbs_mode],verbose)
    set_PrbsCtl_NotLockedCntClr(fpgaid,chid,1,verbose)
    print "Running test for %d seconds with %s:" % (max_run_time_in_seconds,prbs_mode)
    # Reset counters, start generator and checker
    set_PrbsCtl_RxCntClr(fpgaid,chid,1,verbose)
    set_PrbsCtl_ErrCntClr(fpgaid,chid,1,verbose)

  # report serdes channel status
  reconfig_dump_state(fpgaid,verbose)

  # this is to reset all PMA value for each channel
  ber_lowest       = 1
  dcgain_lowest    = 0
  eqctrl_lowest    = 0
  vodctrl_lowest   = 0
  preemph1t_lowest = 0
  preemph0t_lowest = 0
  preemph2t_lowest = 0

  print "\n\n--- Transceiver reconfig analog settings sweep for FPGA %d Channel %d ---\n\n" % (fpgaid,chid)


  print "%7s %9s %9s %9s %7s %12s %14s %12s %14s"%(" VOD   ","Preemph1t","Preemph0t","Preemph2t","DC gain","Equalization"," Total bits   "," Error bits ","Bit error rate")
  print "%7s %9s %9s %9s %7s %12s %14s %12s %14s"%("=======","=========","=========","=========","=======","============","==============","============","==============")

  # Loop every analog settings
  for vodctrl in vodctrl_list:
    for preemph1t in preemph1t_list:
      # set analog settings : 1st post tap
      reconfig_PMA_set_Pre_emphasis_first_post_tap(fpgaid,preemph1t,verbose)
      for preemph0t in preemph0t_list:
        # set analog settings : pre tap
        reconfig_PMA_set_Pre_emphasis_pre_tap(fpgaid,preemph0t,verbose)
        for preemph2t in preemph2t_list:
          # set analog settings : 2nd post tap
          reconfig_PMA_set_Pre_emphasis_second_post_tap(fpgaid,preemph2t,verbose)
          for dcgain in dcgain_list:
            # set analog settings : dc gain
            reconfig_PMA_set_RX_equalization_DC_gain(fpgaid,dcgain,verbose)
            for eqctrl in eqctrl_list:
              # set analog settings : equalization control
              reconfig_PMA_set_RX_equalization_control(fpgaid,eqctrl,verbose)

              # call ber_1d for dfe calibration
              # phase_step=0,EyeQ_enable=0,max_error_bits=10000,max_bit_error_rate=0.1,user_run_time_in_seconds,interval_in_seconds=2
              #(locked,bit_error_rate,total_bits,error_bits) = ber_1d(fpgaid,chid,"prbs7",0,0,10000,0.1,user_run_time_in_seconds,interval_in_seconds=2)
              (locked,bit_error_rate,total_bits,error_bits) = ber_1d(fpgaid,chid,prbs_mode,phase_step,EyeQ_enable,max_error_bits,max_bit_error_rate,max_run_time_in_seconds,polling_interval_in_seconds,verbose)
              print "%7d %9d %9d %9d %7d %12d %14d %12d %14e"%(vodctrl,preemph1t,preemph0t,preemph2t,dcgain,eqctrl,total_bits,error_bits,bit_error_rate)

              if locked == 1:
                if ber_lowest > bit_error_rate:
                  ber_lowest = bit_error_rate

                  vodctrl_lowest = vodctrl
                  preemph1t_lowest = preemph1t
                  preemph0t_lowest = preemph0t
                  preemph2t_lowest = preemph2t
                  dcgain_lowest = dcgain
                  eqctrl_lowest = eqctrl
              else:
                print "%7d %9d %9d %9d %7d %12d %14s %12s %14s"%(vodctrl,preemph1t,preemph0t,preemph2t,dcgain,eqctrl,"[Not locked]","[Not locked]","[Not locked]")

  print ""
  print " =========================================================================================="
  print "  Found lowest BER : %s with below analog settings" % ber_lowest
  print "  VOD control               : %d" % vodctrl_lowest
  print "  Pre-emphasis 1st post-tap : %d" % preemph1t_lowest
  print "  Pre-emphasis pre-tap      : %d" % preemph0t_lowest
  print "  Pre-emphasis 2nd post-tap : %d" % preemph2t_lowest
  print "  DC gain                   : %d" % dcgain_lowest
  print "  Equalization control      : %d" % eqctrl_lowest
  print ""
  print "Test stopped after sweeping through each combination of analog values for %d seconds\n" % max_run_time_in_seconds
  print "\n\n--- End of transceiver reconfig analog settings sweep for FPGA %d Logical Channel %d ---\n\n" % (fpgaid,chid)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,0,verbose)

def EyeQ_sweep_1d_test (fpgaid,chid,prbs_mode,EyeQ_enable=0,max_error_bits=10000,max_bit_error_rate=0.1,max_run_time_in_seconds=10,polling_interval_in_seconds=2,verbose=0):
  """
  Bit error rate test
  When enable_eye_view = 1, use Altera's BER.  Otherwise, use Prbs in DOM fabric.
  max_error_bits              = 10000
  max_bit_error_rate          = 0.1
  max_run_time_in_seconds     = 10
  polling_interval_in_seconds = 2
  """
  global debug


  # prbs selection
  prbs_sel_list = { 'off' : 0, 'prbs7' : 1, 'prbs31' : 2 }

  # send preamble
  set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list['off'],verbose)

  # Transceiver RX word aligner: 0 to disable, 1 to enable
  # enable_word_aligner = 0

  # EyeQ phase steps, not used if EyeQ is disabled
  phase_steps           = range(64)

  # Transceiver reconfig analog values
  vodctrl_list          = [0,1,2,3,4,5,6,7]
  preemph1t_list        = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
  preemph0t_list        = [-15,-14,-13,-12,-11,-10,-9,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
  preemph2t_list        = [-15,-14,-13,-12,-11,-10,-9,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
  dcgain_list           = [0,1,2,3]
  eqctrl_list           = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]



  ####################################################
  # BER test
  ####################################################

  # Not using internal loopback
  set_Ctl_SerialLpbkEn(fpgaid,chid,0,verbose)


  print "\n\n--- 1D Eye sweep on FPGA %d logical channel %d ---\n\n" % (fpgaid,chid)

  # open serdes channel
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
  reconfig_EyeQ_set_1D_Eye(fpgaid,1,verbose)


  if EyeQ_enable:
    # enable EyeQ
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_steps[0],verbose)
    reconfig_EyeQ_set_Polarity(fpgaid,0,verbose)
    # Reset everything, snapshot and counters are reset to 0
    reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,1,verbose)
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
    # set to 0, pauses accumulation, preserving the current values
    reconfig_EyeQ_set_Counter_Enable(fpgaid,0,verbose)
    print "Running 1D EyeQ sweep for %d seconds with %s:" % (max_run_time_in_seconds,"EyeQ BER")
  else:
    # disable EyeQ
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_steps[0],verbose)
    # initialize prbs
    set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list[prbs_mode],verbose)
    set_PrbsCtl_NotLockedCntClr(fpgaid,chid,1,verbose)
    print "Running 1D EyeQ sweep for %d seconds with %s:" % (max_run_time_in_seconds,prbs_mode)
    # Reset counters, start generator and checker
    set_PrbsCtl_RxCntClr(fpgaid,chid,1,verbose)
    set_PrbsCtl_ErrCntClr(fpgaid,chid,1,verbose)

  # report serdes channel status
  reconfig_dump_state(fpgaid,verbose)


  print "\n\n--- 1D EyeQ sweep for FPGA %d Channel %d ---\n\n" % (fpgaid,chid)


  print "%10s %14s %12s %14s"%("Phase step"," Total bits   "," Error bits ","Bit error rate")
  print "%10s %14s %12s %14s"%("==========","==============","============","==============")

  eye_width = 0

  # Loop every phase steps
  for phase_step in phase_steps:
    # call ber_1d for dfe calibration
    # EyeQ_enable=0,max_error_bits=10000,max_bit_error_rate=0.1,user_run_time_in_seconds,interval_in_seconds=2
    #(locked,bit_error_rate,total_bits,error_bits) = ber_1d(fpgaid,chid,"prbs7",phase_step,0,10000,0.1,user_run_time_in_seconds,interval_in_seconds=2)
    (locked,bit_error_rate,total_bits,error_bits) = ber_1d(fpgaid,chid,prbs_mode,phase_step,EyeQ_enable,max_error_bits,max_bit_error_rate,max_run_time_in_seconds,polling_interval_in_seconds,verbose)
    if locked == 1:
      # Snapshot the counters
      print "%10d %14d %12d %14e"%(phase_step,total_bits,error_bits,bit_error_rate)
      if error_bits == 0:
        eye_width = eye_width+1
    else:
      print "%10d %14s %12s %14s"%(phase_step,"[Not locked]","[Not locked]","[Not locked]")
      locked = 0


  print ""
  print "Test stopped after sweeping through each phase steps for %d seconds\n" % max_run_time_in_seconds
  print "Approximated eye width is %d phase steps" % eye_width
  print "\n\n--- End of 1D Eye sweep for FPGA %d Logical Channel %d ---\n\n" % (fpgaid,chid)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,0,verbose)

def ber_2d(fpgaid,chid,prbs_mode,phase_step=0,vertical_height=0,EyeQ_enable=0,max_error_bits=10,max_bit_error_rate=0.1,max_run_time_in_seconds=10,polling_interval_in_seconds=2,verbose=0):
  """
  Bit error rate test
  When enable_eye_view = 1, use Altera's BER.  Otherwise, use Prbs in DOM fabric.
  phase_step                  = 0
  max_error_bits              = 10
  max_bit_error_rate          = 0.1
  max_run_time_in_seconds     = 10
  polling_interval_in_seconds = 2
  """
  global debug


  # prbs selection
  prbs_sel_list = { 'off' : 0, 'prbs7' : 1, 'prbs31' : 2 }

  # send preamble
  set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list['off'],verbose)

  # Transceiver RX word aligner: 0 to disable, 1 to enable
  # enable_word_aligner = 0


  ####################################################
  # BER test
  ####################################################

  # Not using internal loopback
  set_Ctl_SerialLpbkEn(fpgaid,chid,0,verbose)


  if debug : print "\n\n--- PRBS test on FPGA %d logical channel %d ---\n\n" % (fpgaid,chid)

  # open serdes channel
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
  reconfig_EyeQ_set_1D_Eye(fpgaid,0,verbose)


  if EyeQ_enable:
    # enable EyeQ
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_step,verbose)
    if vertical_height > 0:
      reconfig_EyeQ_set_Polarity(fpgaid,1,verbose)
      reconfig_EyeQ_set_Vertical_height(fpgaid,vertical_height,verbose)
    else:
      reconfig_EyeQ_set_Polarity(fpgaid,0,verbose)
      reconfig_EyeQ_set_Vertical_height(fpgaid,-vertical_height,verbose)
    # Reset everything, snapshot and counters are reset to 0
    reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,1,verbose)
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
    # set to 0, pauses accumulation, preserving the current values
    reconfig_EyeQ_set_Counter_Enable(fpgaid,0,verbose)
    print "Running test for %d seconds with %s:" % (max_run_time_in_seconds,"EyeQ BER")
  else:
    # disable EyeQ
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_step,verbose)
    if vertical_height > 0:
      reconfig_EyeQ_set_Polarity(fpgaid,1,verbose)
      reconfig_EyeQ_set_Vertical_height(fpgaid,vertical_height,verbose)
    else:
      reconfig_EyeQ_set_Polarity(fpgaid,0,verbose)
      reconfig_EyeQ_set_Vertical_height(fpgaid,-vertical_height,verbose)
    # initialize prbs
    set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list[prbs_mode],verbose)
    set_PrbsCtl_NotLockedCntClr(fpgaid,chid,1,verbose)
    print "Running test for %d seconds with %s:" % (max_run_time_in_seconds,prbs_mode)
    # Reset counters, start generator and checker
    set_PrbsCtl_RxCntClr(fpgaid,chid,1,verbose)
    set_PrbsCtl_ErrCntClr(fpgaid,chid,1,verbose)

  # report serdes channel status
  if debug : reconfig_dump_state(fpgaid,verbose)

  if debug : print "%17s %14s %12s %14s"%("Elapsed time(sec)"," Total bits   "," Error bits ","Bit error rate")
  if debug : print "%17s %14s %12s %14s"%("=================","==============","============","==============")


  # clear counter before start test
  if EyeQ_enable:
    # set to 1, set to 1, the counters accumulate bits and errors
    reconfig_EyeQ_set_Counter_Enable(fpgaid,1,verbose)
  else:
    # Reset counters, start generator and checker
    set_PrbsCtl_RxCntClr(fpgaid,chid,1,verbose)
    set_PrbsCtl_ErrCntClr(fpgaid,chid,1,verbose)

  start_time = time.time()
  elapsed_time = 0
  error_bits = 0
  locked = 1
  while elapsed_time < max_run_time_in_seconds and error_bits < max_error_bits and locked == 1:
    time.sleep(polling_interval_in_seconds*1000*0.001)
    elapsed_time = time.time() - start_time
    if EyeQ_enable:
      # Copy the counter values into local registers for read access
      reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,2,verbose)
      reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
      total_bits     = (reconfig_EyeQ_get_Bit_Counter63_32(fpgaid,verbose) << 32) + reconfig_EyeQ_get_Bit_Counter31_0(fpgaid,verbose)
      total_bits     = total_bits * 256
      error_bits     = (reconfig_EyeQ_get_Err_Conter63_32(fpgaid,verbose)  << 32) + reconfig_EyeQ_get_Err_Counter31_0(fpgaid,verbose)
      bit_error_rate = float(error_bits)/float(total_bits)

    else:
      if get_PrbsLock(fpgaid,chid,verbose):
        # Snapshot the counters
        total_bits     = get_PrbsRxCnt(fpgaid,chid,verbose)
        error_bits     = get_PrbsErrCnt(fpgaid,chid,verbose)
        bit_error_rate = float(error_bits)/float(total_bits)
        if debug : print "%17d %14d %12d %14e"%(elapsed_time,total_bits,error_bits,bit_error_rate)
        error_bits = get_PrbsErrCnt(fpgaid,chid,verbose)
      else:
        total_bits     = 0
        error_bits     = 0
        bit_error_rate = 0
        if debug : print "%17d %14s %12s %14s"%(elapsed_time,"[Not locked]","[Not locked]","[Not locked]")
        locked = 0

  if elapsed_time >= max_run_time_in_seconds:
    if debug : print "\nTest stopped after achieving maximum run time of %d seconds" % max_run_time_in_seconds
  elif error_bits >= max_error_bits:
    if debug : print "\nTest stopped after hitting the maximum number of error bits of %d bits" % max_error_bits
  else:
    if debug : print "\nTest stopped because checker cannot lock to incoming data pattern"

  # Stop generator and checker
  set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list['off'],verbose)

  if debug : print "\n\n--- End of PRBS test on FPGA %d logical channel %d ---\n\n" % (fpgaid,chid)

  return (locked,bit_error_rate,total_bits,error_bits)

def EyeQ_sweep_2d_test (fpgaid,chid,prbs_mode,EyeQ_enable=0,max_error_bits=10000,max_bit_error_rate=0.1,max_run_time_in_seconds=10,polling_interval_in_seconds=2,verbose=0):
  """
  Bit error rate test
  When enable_eye_view = 1, use Altera's BER.  Otherwise, use Prbs in DOM fabric.
  max_error_bits              = 10000
  max_bit_error_rate          = 0.1
  max_run_time_in_seconds     = 10
  polling_interval_in_seconds = 2
  """
  global debug


  # prbs selection
  prbs_sel_list = { 'off' : 0, 'prbs7' : 1, 'prbs31' : 2 }

  # send preamble
  set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list['off'],verbose)

  # Transceiver RX word aligner: 0 to disable, 1 to enable
  # enable_word_aligner = 0

  # EyeQ phase steps, not used if EyeQ is disabled
  phase_steps           = range(64)
  vertical_heights      = range(64)

  # Transceiver reconfig analog values
  vodctrl_list          = [0,1,2,3,4,5,6,7]
  preemph1t_list        = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
  preemph0t_list        = [-15,-14,-13,-12,-11,-10,-9,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
  preemph2t_list        = [-15,-14,-13,-12,-11,-10,-9,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
  dcgain_list           = [0,1,2,3]
  eqctrl_list           = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]



  ####################################################
  # BER test
  ####################################################

  # Not using internal loopback
  set_Ctl_SerialLpbkEn(fpgaid,chid,0,verbose)


  print "\n\n--- 2D Eye sweep on FPGA %d logical channel %d ---\n\n" % (fpgaid,chid)

  # open serdes channel
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
  reconfig_EyeQ_set_1D_Eye(fpgaid,0,verbose)


  if EyeQ_enable:
    # enable EyeQ
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_steps[0],verbose)
    reconfig_EyeQ_set_Polarity(fpgaid,0,verbose)
    # Reset everything, snapshot and counters are reset to 0
    reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,1,verbose)
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,1,verbose)
    # set to 0, pauses accumulation, preserving the current values
    reconfig_EyeQ_set_Counter_Enable(fpgaid,0,verbose)
    print "Running 2D sweep for %d seconds with %s:" % (max_run_time_in_seconds,"EyeQ BER")
  else:
    # disable EyeQ
    reconfig_EyeQ_set_BERB_Enable(fpgaid,1,verbose)
    reconfig_EyeQ_set_Horizontal_phase(fpgaid,phase_steps[0],verbose)
    # initialize prbs
    set_PrbsCtl_PrbsSel(fpgaid,chid,prbs_sel_list[prbs_mode],verbose)
    set_PrbsCtl_NotLockedCntClr(fpgaid,chid,1,verbose)
    print "Running 2D sweep for %d seconds with %s:" % (max_run_time_in_seconds,prbs_mode)
    # Reset counters, start generator and checker
    set_PrbsCtl_RxCntClr(fpgaid,chid,1,verbose)
    set_PrbsCtl_ErrCntClr(fpgaid,chid,1,verbose)

  # report serdes channel status
  reconfig_dump_state(fpgaid,verbose)


  print "\n\n--- Transceiver reconfig EyeQ settings sweep for FPGA %d Channel %d ---\n\n" % (fpgaid,chid)


  print "%11s %10s %14s %12s %14s"%("Vert Height","Phase step"," Total bits   "," Error bits ","Bit error rate")
  print "%11s %10s %14s %12s %14s"%("===========","==========","==============","============","==============")

  ber_db={}
  # Loop every phase steps
  for vertical_height in vertical_heights:
    for polarity in range(2):
      if polarity == 1 and vertical_height == 0 : continue
      vertical_height=-vertical_height
      ber_db[vertical_height]={}
      eye_width=0
      for phase_step in phase_steps:
        ber_db[vertical_height][phase_step]={}
        # call ber_1d for dfe calibration
        # EyeQ_enable=0,max_error_bits=10000,max_bit_error_rate=0.1,user_run_time_in_seconds,interval_in_seconds=2
        #(locked,bit_error_rate,total_bits,error_bits) = ber_2d(fpgaid,chid,"prbs7",phase_step,vertical_height,0,10000,0.1,user_run_time_in_seconds,interval_in_seconds=2)
        (locked,bit_error_rate,total_bits,error_bits) = ber_2d(fpgaid,chid,prbs_mode,phase_step,vertical_height,EyeQ_enable,max_error_bits,max_bit_error_rate,max_run_time_in_seconds,polling_interval_in_seconds,verbose)
        ber_db[vertical_height][phase_step]["locked"]=locked
        ber_db[vertical_height][phase_step]["bit_err_rate"]=bit_error_rate
        ber_db[vertical_height][phase_step]["total_bits"]=total_bits
        ber_db[vertical_height][phase_step]["error_bits"]=error_bits
        if locked == 1:
          # Snapshot the counters
          print "%11d %10d %14d %12d %14e"%(vertical_height,phase_step,total_bits,error_bits,bit_error_rate)
          if error_bits == 0:
            eye_width = eye_width+1
        else:
          print "%11d %10d %14s %12s %14s"%(vertical_height,phase_step,"[Not locked]","[Not locked]","[Not locked]")
          locked = 0
      print "Approximated eye width is %d phase steps when vertical height = %d" % (eye_width,vertical_height)


  date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
  OUTFILE=open("ber2d%s"%date.replace(' ','_'),"w")
  pprint(ber_db)
  pprint(ber_db,OUTFILE)
  print ""
  print "Test stopped after sweeping through each phase steps for %d seconds\n" % max_run_time_in_seconds
  print "\n\n--- End of 2D Eye sweep for FPGA %d Logical Channel %d ---\n\n" % (fpgaid,chid)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,0,verbose)

