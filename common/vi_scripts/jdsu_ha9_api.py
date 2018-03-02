#!/usr/bin/env python
import sys
import os
import fcntl
import termios
import time
import glob
fd=0
debug=0
commands={
 'Attenuation': ['Attenuation',
                 '\n Sets the attenuation of the attenuator relative to  the 0 dB reference position; that is, it isindependent of the attenuation display offset. The default unit is dB.\n'],
 'Beam_Block': ['Beam_Block',
                ' \n Controls the on/off status of the beam block:\n   0 = beam block off\n   1 = beam block on\n'],
 'Calibration_Wavelength': ['Calibration_Wavelength',
                            '\n Sets the calibration wavelength of the att enuator from 1200 to 1700 nm for the standard HA9model and from 750 to 1700 nm for the wide model (HA9W). The default unit is meters (m).\n'],
 'Clear_SRQ_Mask_Register': ['Clear_SRQ_Mask_Register',
                             '\n Clears the SRQ mask register (see the  Status Reporting and Service Request Controlsection).\n'],
 'Clear_Status_Byte': ['Clear_Status_Byte',
                       '\n Clears or resets the status byte.\n'],
 'Display_Mode': ['Display_Mode',
                  '\n Controls the display mode of the attenuator while in Remote mode:\n   0 = ATT mode\n   1 = PWR mode\n'],
 'Display_Offset_(ATT_Mode)': ['Display_Offset_(ATT_Mode)',
                               '\n Sets the display offset in ATT mode. The default unit is dB.\n'],
 'Display_Offset_(PWR_Mode)': ['Display_Offset_(PWR_Mode)',
                               '\n Sets the display offset in PWR mode so that  the display matches the power meter reading.The default unit is dBm.\n'],
 'Driver_Control': ['Driver_Control',
                    '\n Controls the on/off status of the driver:\n   0 = driver off\n   1 = driver on\n'],
 'Output_Power': ['Output_Power',
                  '\n Sets the output power of the attenuator, including the display offset. The default unit is dBm.\n Use PCAL or STPWR or perform a calibration in Local mode before performing PWR.\n'],
 'Reset': ['Reset',
           '\n Returns the attenuator to the following default settings:\n   WVL = 1310 nm\n   DISP = 0*  CAL = 0 dB\n   PCAL = 0 dB* ATT = 0 dB\n The values of D, XDR, and SRE are not changed.\n'],
 'SRQ_Mask_Register': ['SRQ_Mask_Register',
                       '\n Writes a decimal number to the eight-bit SRQ mask register. Setting a bit to 1 generates aservice request interrupt (SRQ) when the corresponding bit in the status register changes from 0 to 1 (see the Status Reporting and Service Request Control section).\n']
}
querys={
 'Attenuation': ['Attenuation',
                 '\n Returns the attenuation of the attenuator:\n  ATT? returns the current attenuation\n  ATT? MIN returns 0 or the minimum attenuation setting at the current wavelength\n  ATT? MAX returns 0 or the maximum attenuation setting at the current wavelength\n  If the HA9 attenuator is set at the minimum loss position, ATT? returns -1 dB.\n'],
 'Beam_Block_Status': ['Beam_Block_Status',
                       '\n Returns the on/off status of the beam block:\n  0 = beam block off\n  1 = beam block on\n'],
 'Calibration_Wavelength': ['Calibration_Wavelength',
                            '\n Returns the calibration wavelength:\n  WVL? returns the current calibration wavelength\n  WVL? MIN returns the minimum calibration wavelength\n  WVL? MAX returns the maximum calibration wavelength\n'],
 'Condition_Register': ['Condition_Register',
                        '\n Returns the contents of the conditi on register as an integer (see the  Status Reporting andService Request Control section).\n'],
 'Display_Mode': ['Display_Mode',
                  '\n Returns the display mode of the attenuator:\n  0 = ATT mode\n  1 = PWR mode\n'],
 'Display_Offset_(ATT_Mode)': ['Display_Offset_(ATT_Mode)',
                               '\n Returns the display offset in ATT mode:\n  CAL? returns the current display offset\n  CAL? MIN returns the minimum display offset\n  CAL? MAX returns the maximum display offset\n'],
 'Display_Offset_(PWR_Mode)': ['Display_Offset_(PWR_Mode)',
                               '\n Returns the display offset in PWR mode:\n  PCAL? returns the current display offset\n  PCAL? MIN returns the minimum display offset\n  PCAL? MAX returns the maximum display offset\n'],
 'Driver_Status': ['Driver_Status',
                   '\n Returns the status of the driver:\n  0 = driver is off\n  1 = driver is on\n'],
 'Error_Number': ['Error_Number',
                  '\n Returns an error number if the self-test operation fails:\n  330 = self-test failed\n    0 = no error occurred\n'],
 'Identification': ['Identification',
                    '\n Returns a string that identifies the manufacturer, the HA9 model number, the serial number (or0 if unavailable), and the firmware level,  for example, JDS UNIPHASE HA9x,01, 0,00.100\n where x = S for standard model and x = L for wide model\n'],
 'Input_Buffer': ['Input_Buffer',
                  '\n Returns the status of the input buffer:\n  1 = the input buffer is empty; for example, all commands have been executed\n  0 = the input buffer is not empty; for example, commands are still pending\n'],
 'Last_Error': ['Last_Error',
                '\n Returns an error number from an error queue. The queue can contain as many as five errornumbers. The first error read is the last error that occurred.\n  000 = error queue is empty\n'],
 'Learn': ['Learn',
           '\n In HA and HP mode, returns a 58-character string containing a summary of the current settingsof the attenuator. The string is formatted as follows:\n  Fiber setting = four characters (always returns 1)\n   Output state = four characters (0 = beam block off, 1 = beam block on)*  SRQ mask = eight characters\n  Attenuation display offset = 13 characters*  Attenuation = 13 characters\n  Wavelength = 16 characters\n  HA mode example: 1   0   6       10.0000      22.0000      13000e-06\n  HP mode example: F I;D 1;SRE   6;CAL  10.0000;ATT  22.0000;WVL    13000e-06;\n'],
 'Power_Setting': ['Power_Setting',
                   '\n Returns the optical power setting:\n  PWR? returns the current optical power setting\n  PWR? MIN returns the minimum optical power setting at the current wavelength\n  PWR? MAX returns the maximum optical power setting at the current wavelength\n "If the HA9 attenuator is set at the minimum loss position, PWR? returns 101 dB.\n'],
 'Self_test': ['Self_test',
               '\n Executes a self-test operation and returns the result. An error code is also placed into the errorqueue. The queue can be queried with  ERR? or  LERR?.  TST? also sets bit 7 in the status register.\n  0 = self-test passed\n  1 = self-test failed\n'],
 'Slope_Control': ['Slope_Control',
                   '\n Returns the method by which the attenuator determines the slope of the attenuation:\n  0 = calibration wavelength\n  1 = user slope\n'],
 'Slope_User_Value': ['Slope_User_Value',
                      '\n Returns the user slope:\n  SLP? returns the current user slope\n  SLP? MIN returns the minimum user slope*\n  SLP? MAX return the maximum user slope\n'],
 'Status_Register': ['Status_Register',
                     '\n Returns the contents of the status register as an integer.\n']
}
def jdsu_commands():
  """
  setup_rs232_link()
  set_Reset(value)
  set_Display_Mode(value)
  set_Display_Offset__PWR_Mode_(value)
  set_Beam_Block(value)
  set_SRQ_Mask_Register(value)
  set_Clear_Status_Byte(value)
  set_Attenuation(value)
  set_Display_Offset__ATT_Mode_(value)
  set_Clear_SRQ_Mask_Register(value)
  set_Display_Offset__PWR_Mode_(value)
  set_Output_Power(value)
  set_Driver_Control(value)
  set_Calibration_Wavelength(value)
  get_Last_Error()
  get_Identification()
  get_Calibration_Wavelength()
  get_Calibration_Wavelength_MAX()
  get_Calibration_Wavelength_MIN()
  get_Display_Mode()
  get_Display_Offset__ATT_Mode_()
  get_Display_Offset__ATT_Mode__MAX()
  get_Display_Offset__ATT_Mode__MIN()
  get_Attenuation()
  get_Attenuation_MAX()
  get_Attenuation_MIN()
  get_Slope_Control()
  get_Status_Register()
  get_Power_Setting()
  get_Power_Setting_MAX()
  get_Power_Setting_MIN()
  get_Self_test()
  get_Beam_Block_Status()
  get_Input_Buffer()
  get_Error_Number()
  get_Slope_User_Value()
  get_Slope_User_Value_MAX()
  get_Slope_User_Value_MIN()
  get_Display_Offset__PWR_Mode_()
  get_Display_Offset__PWR_Mode__MAX()
  get_Display_Offset__PWR_Mode__MIN()
  get_Driver_Status()
  get_Condition_Register()
  get_Learn()
  """

def open_ttyUSB(num):
  """
  open tty
  """
  fd=os.open("/dev/ttyUSB%d"%num,os.O_RDWR | os.O_NOCTTY)
  print os.ttyname(fd)
  return fd

def open_ttyS(num):
  """
  open tty
  """
  fd=os.open("/dev/ttyS%d"%num,os.O_RDWR | os.O_NOCTTY)
  print os.ttyname(fd)
  return fd

def term_getattr(fd):
  """
  """
  (iflag,oflag,cflag,lflag,ispeed,ospeed,cc)=termios.tcgetattr(fd)

def term_getattr(fd,iflag,oflag,cflag,lflag,ispeed,ospeed,cc):
  """
  """
  #termios.tcsetattr(fd, termios.TCSANOW,[iflag,oflag,cflag,lflag,ispeed,ospeed,cc])
  termios.tcsetattr(fd, termios.TCSADRAIN,[iflag,oflag,cflag,lflag,ispeed,ospeed,cc])

def get_response(fd,verbose=1):
  """
  """
  ch=os.read(fd,80) 
  if debug or (verbose & 1): print ch
  return ch



def config_port(fd):
  """
  """
  termios.tcflush(fd, termios.TCIOFLUSH)
  (iflag,oflag,cflag,lflag,ispeed,ospeed,cc)=termios.tcgetattr(fd)
  print map(lambda x: bin(x),[iflag,oflag,cflag,lflag,ispeed,ospeed])
  cflag = termios.B1200 | termios.CS8 | termios.CLOCAL | termios.CREAD | termios.CRTSCTS
  iflag = termios.IGNPAR | termios.ICRNL # translate CR to NL on input
  oflag = termios.ONLCR                  # map NL to CR-NL on output
  lflag = termios.ICANON
  cc[termios.VEOF] = '\x04'                   # ^D
  cc[termios.VMIN] = '\x01'                   # should not be necessary since we're in canonical processing mode...

  termios.tcflush(fd, termios.TCIFLUSH);  # flush input data
  #termios.tcsetattr(fd, termios.TCSADRAIN,[iflag,oflag,cflag,lflag,ispeed,ospeed,cc])
  termios.tcsetattr(fd, termios.TCSADRAIN,[8,16,0b1100100000110000,0,9,9,cc])
def send_cmd(fd,cmd):
  """
  """
  ret= os.write(fd,"%s\r"%cmd)
  return ret

def setup_rs232_link(verbose=1):
  """
Before opening open USB tty port, make sure that the attentuator is in "HA9" mode.
Steps to configure the instrument to "HA9" command set:
1.  Ensure that the attenuator is powered off (O).
2.  Set the power switch to  I (on) and as the unit powers on press and hold the LCL key for afew seconds. The display shows the command set [SCPI, HA9, or HPM ( YYY)], the message terminating sequence [carriage return, line feed <CR> <LF> or <LF> (TR)], and the GPIB address [AD, for example, YYY (TR) AD].
3. Press the  up-arrow  or down-arrow  key to change the command set to HA9.
4. Press the ATT/PWR key.
  """
  if debug or (verbose & 1): print """
Before opening open USB tty port, make sure that the attentuator is in "HA9" mode.
Steps to configure the instrument to "HA9" command set:
1.  Ensure that the attenuator is powered off (O).
2.  Set the power switch to  I (on) and as the unit powers on press and hold the LCL key for afew seconds. The display shows the command set [SCPI, HA9, or HPM ( YYY)], the message terminating sequence [carriage return, line feed <CR> <LF> or <LF> (TR)], and the GPIB address [AD, for example, YYY (TR) AD].
3. Press the  up-arrow  or down-arrow  key to change the command set to HA9.
4. Press the ATT/PWR key.
"""
  global fd
  success=0
  for device in glob.glob('/dev/ttyUSB*') if sys.platform.startswith('linux') else glob.glob('/dev/ttyS*'): 
    if device.startswith('/dev/ttyUSB'):
      fd=open_ttyUSB(int(device[-1]))
    else:
      os.system('chmod 666 %s'%device)
      fd=open_ttyS(int(device[-1]))
    time.sleep(1)
    config_port(fd)
    time.sleep(1)
    ret=send_cmd(fd,"ATT?")
    result=get_response(fd,verbose=verbose)
    if ret ==5:
      success=1
      break;
    else:
      os.close(fd)
  if success == 0:
    print "Error: No USB tty port available"
  else:
    print "USB tty port is %s"%device
    return fd

def set_Reset(value,verbose=1):
  """

 Returns the attenuator to the following default settings:
   WVL = 1310 nm
   DISP = 0*  CAL = 0 dB
   PCAL = 0 dB* ATT = 0 dB
 The values of D, XDR, and SRE are not changed.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the attenuator to the following default settings:
   WVL = 1310 nm
   DISP = 0*  CAL = 0 dB
   PCAL = 0 dB* ATT = 0 dB
 The values of D, XDR, and SRE are not changed.
"""
  cmd="RESET %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Display_Mode(value,verbose=1):
  """

 Controls the display mode of the attenuator while in Remote mode:
   0 = ATT mode
   1 = PWR mode

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Controls the display mode of the attenuator while in Remote mode:
   0 = ATT mode
   1 = PWR mode
"""
  cmd="DISP %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Display_Offset__PWR_Mode_(value,verbose=1):
  """

 Sets the display offset in PWR mode. The default unit is dBm.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Sets the display offset in PWR mode. The default unit is dBm.
"""
  cmd="PCAL %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Beam_Block(value,verbose=1):
  """
 
 Controls the on/off status of the beam block:
   0 = beam block off
   1 = beam block on

  """
  global debug
  global fd
  if debug or (verbose & 1): print """ 
 Controls the on/off status of the beam block:
   0 = beam block off
   1 = beam block on
"""
  cmd="D %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_SRQ_Mask_Register(value,verbose=1):
  """

 Writes a decimal number to the eight-bit SRQ mask register. Setting a bit to 1 generates aservice request interrupt (SRQ) when the corresponding bit in the status register changes from 0 to 1 (see the Status Reporting and Service Request Control section).

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Writes a decimal number to the eight-bit SRQ mask register. Setting a bit to 1 generates aservice request interrupt (SRQ) when the corresponding bit in the status register changes from 0 to 1 (see the Status Reporting and Service Request Control section).
"""
  cmd="SRE %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Clear_Status_Byte(value,verbose=1):
  """

 Clears or resets the status byte.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Clears or resets the status byte.
"""
  cmd="CSB %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Attenuation(value,verbose=1):
  """

 Sets the attenuation of the attenuator relative to  the 0 dB reference position; that is, it isindependent of the attenuation display offset. The default unit is dB.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Sets the attenuation of the attenuator relative to  the 0 dB reference position; that is, it isindependent of the attenuation display offset. The default unit is dB.
"""
  cmd="ATT %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Display_Offset__ATT_Mode_(value,verbose=1):
  """

 Sets the display offset in ATT mode. The default unit is dB.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Sets the display offset in ATT mode. The default unit is dB.
"""
  cmd="CAL %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Clear_SRQ_Mask_Register(value,verbose=1):
  """

 Clears the SRQ mask register (see the  Status Reporting and Service Request Controlsection).

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Clears the SRQ mask register (see the  Status Reporting and Service Request Controlsection).
"""
  cmd="CLR %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Display_Offset__PWR_Mode_(value,verbose=1):
  """

 Sets the display offset in PWR mode so that  the display matches the power meter reading.The default unit is dBm.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Sets the display offset in PWR mode so that  the display matches the power meter reading.The default unit is dBm.
"""
  cmd="STPWR %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Output_Power(value,verbose=1):
  """

 Sets the output power of the attenuator, including the display offset. The default unit is dBm.
 Use PCAL or STPWR or perform a calibration in Local mode before performing PWR.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Sets the output power of the attenuator, including the display offset. The default unit is dBm.
 Use PCAL or STPWR or perform a calibration in Local mode before performing PWR.
"""
  cmd="PWR %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Driver_Control(value,verbose=1):
  """

 Controls the on/off status of the driver:
   0 = driver off
   1 = driver on

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Controls the on/off status of the driver:
   0 = driver off
   1 = driver on
"""
  cmd="XDR %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def set_Calibration_Wavelength(value,verbose=1):
  """

 Sets the calibration wavelength of the att enuator from 1200 to 1700 nm for the standard HA9model and from 750 to 1700 nm for the wide model (HA9W). The default unit is meters (m).

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Sets the calibration wavelength of the att enuator from 1200 to 1700 nm for the standard HA9model and from 750 to 1700 nm for the wide model (HA9W). The default unit is meters (m).
"""
  cmd="WVL %s" % value
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd
  if debug or (verbose & 1): print "="*20
  ret=send_cmd(fd,cmd)
  time.sleep(1)


def get_Last_Error(verbose=1):
  """

 Returns an error number from an error queue. The queue can contain as many as five errornumbers. The first error read is the last error that occurred.
  000 = error queue is empty

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns an error number from an error queue. The queue can contain as many as five errornumbers. The first error read is the last error that occurred.
  000 = error queue is empty
"""
  cmd="LERR?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Identification(verbose=1):
  """

 Returns a string that identifies the manufacturer, the HA9 model number, the serial number (or0 if unavailable), and the firmware level,  for example, JDS UNIPHASE HA9x,01, 0,00.100
 where x = S for standard model and x = L for wide model

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns a string that identifies the manufacturer, the HA9 model number, the serial number (or0 if unavailable), and the firmware level,  for example, JDS UNIPHASE HA9x,01, 0,00.100
 where x = S for standard model and x = L for wide model
"""
  cmd="IDN?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Calibration_Wavelength(verbose=1):
  """

 Returns the calibration wavelength:
  WVL? returns the current calibration wavelength
  WVL? MIN returns the minimum calibration wavelength
  WVL? MAX returns the maximum calibration wavelength

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the calibration wavelength:
  WVL? returns the current calibration wavelength
  WVL? MIN returns the minimum calibration wavelength
  WVL? MAX returns the maximum calibration wavelength
"""
  cmd="WVL?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Calibration_Wavelength_MAX(verbose=1):
  """

 Returns the calibration wavelength:
  WVL? returns the current calibration wavelength
  WVL? MIN returns the minimum calibration wavelength
  WVL? MAX returns the maximum calibration wavelength

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the calibration wavelength:
  WVL? returns the current calibration wavelength
  WVL? MIN returns the minimum calibration wavelength
  WVL? MAX returns the maximum calibration wavelength
"""
  cmd="WVL? MAX"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Calibration_Wavelength_MIN(verbose=1):
  """

 Returns the calibration wavelength:
  WVL? returns the current calibration wavelength
  WVL? MIN returns the minimum calibration wavelength
  WVL? MAX returns the maximum calibration wavelength

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the calibration wavelength:
  WVL? returns the current calibration wavelength
  WVL? MIN returns the minimum calibration wavelength
  WVL? MAX returns the maximum calibration wavelength
"""
  cmd="WVL? MIN"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Display_Mode(verbose=1):
  """

 Returns the display mode of the attenuator:
  0 = ATT mode
  1 = PWR mode

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the display mode of the attenuator:
  0 = ATT mode
  1 = PWR mode
"""
  cmd="DISP?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Display_Offset__ATT_Mode_(verbose=1):
  """

 Returns the display offset in ATT mode:
  CAL? returns the current display offset
  CAL? MIN returns the minimum display offset
  CAL? MAX returns the maximum display offset

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the display offset in ATT mode:
  CAL? returns the current display offset
  CAL? MIN returns the minimum display offset
  CAL? MAX returns the maximum display offset
"""
  cmd="CAL?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Display_Offset__ATT_Mode__MAX(verbose=1):
  """

 Returns the display offset in ATT mode:
  CAL? returns the current display offset
  CAL? MIN returns the minimum display offset
  CAL? MAX returns the maximum display offset

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the display offset in ATT mode:
  CAL? returns the current display offset
  CAL? MIN returns the minimum display offset
  CAL? MAX returns the maximum display offset
"""
  cmd="CAL? MAX"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Display_Offset__ATT_Mode__MIN(verbose=1):
  """

 Returns the display offset in ATT mode:
  CAL? returns the current display offset
  CAL? MIN returns the minimum display offset
  CAL? MAX returns the maximum display offset

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the display offset in ATT mode:
  CAL? returns the current display offset
  CAL? MIN returns the minimum display offset
  CAL? MAX returns the maximum display offset
"""
  cmd="CAL? MIN"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Attenuation(verbose=1):
  """

 Returns the attenuation of the attenuator:
  ATT? returns the current attenuation
  ATT? MIN returns 0 or the minimum attenuation setting at the current wavelength
  ATT? MAX returns 0 or the maximum attenuation setting at the current wavelength
  If the HA9 attenuator is set at the minimum loss position, ATT? returns -1 dB.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the attenuation of the attenuator:
  ATT? returns the current attenuation
  ATT? MIN returns 0 or the minimum attenuation setting at the current wavelength
  ATT? MAX returns 0 or the maximum attenuation setting at the current wavelength
  If the HA9 attenuator is set at the minimum loss position, ATT? returns -1 dB.
"""
  cmd="ATT?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Attenuation_MAX(verbose=1):
  """

 Returns the attenuation of the attenuator:
  ATT? returns the current attenuation
  ATT? MIN returns 0 or the minimum attenuation setting at the current wavelength
  ATT? MAX returns 0 or the maximum attenuation setting at the current wavelength
  If the HA9 attenuator is set at the minimum loss position, ATT? returns -1 dB.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the attenuation of the attenuator:
  ATT? returns the current attenuation
  ATT? MIN returns 0 or the minimum attenuation setting at the current wavelength
  ATT? MAX returns 0 or the maximum attenuation setting at the current wavelength
  If the HA9 attenuator is set at the minimum loss position, ATT? returns -1 dB.
"""
  cmd="ATT? MAX"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Attenuation_MIN(verbose=1):
  """

 Returns the attenuation of the attenuator:
  ATT? returns the current attenuation
  ATT? MIN returns 0 or the minimum attenuation setting at the current wavelength
  ATT? MAX returns 0 or the maximum attenuation setting at the current wavelength
  If the HA9 attenuator is set at the minimum loss position, ATT? returns -1 dB.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the attenuation of the attenuator:
  ATT? returns the current attenuation
  ATT? MIN returns 0 or the minimum attenuation setting at the current wavelength
  ATT? MAX returns 0 or the maximum attenuation setting at the current wavelength
  If the HA9 attenuator is set at the minimum loss position, ATT? returns -1 dB.
"""
  cmd="ATT? MIN"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Slope_Control(verbose=1):
  """

 Returns the method by which the attenuator determines the slope of the attenuation:
  0 = calibration wavelength
  1 = user slope

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the method by which the attenuator determines the slope of the attenuation:
  0 = calibration wavelength
  1 = user slope
"""
  cmd="USER?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Status_Register(verbose=1):
  """

 Returns the contents of the status register as an integer.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the contents of the status register as an integer.
"""
  cmd="SRE?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Power_Setting(verbose=1):
  """

 Returns the optical power setting:
  PWR? returns the current optical power setting
  PWR? MIN returns the minimum optical power setting at the current wavelength
  PWR? MAX returns the maximum optical power setting at the current wavelength
 "If the HA9 attenuator is set at the minimum loss position, PWR? returns 101 dB.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the optical power setting:
  PWR? returns the current optical power setting
  PWR? MIN returns the minimum optical power setting at the current wavelength
  PWR? MAX returns the maximum optical power setting at the current wavelength
 "If the HA9 attenuator is set at the minimum loss position, PWR? returns 101 dB.
"""
  cmd="PWR?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Power_Setting_MAX(verbose=1):
  """

 Returns the optical power setting:
  PWR? returns the current optical power setting
  PWR? MIN returns the minimum optical power setting at the current wavelength
  PWR? MAX returns the maximum optical power setting at the current wavelength
 "If the HA9 attenuator is set at the minimum loss position, PWR? returns 101 dB.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the optical power setting:
  PWR? returns the current optical power setting
  PWR? MIN returns the minimum optical power setting at the current wavelength
  PWR? MAX returns the maximum optical power setting at the current wavelength
 "If the HA9 attenuator is set at the minimum loss position, PWR? returns 101 dB.
"""
  cmd="PWR? MAX"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Power_Setting_MIN(verbose=1):
  """

 Returns the optical power setting:
  PWR? returns the current optical power setting
  PWR? MIN returns the minimum optical power setting at the current wavelength
  PWR? MAX returns the maximum optical power setting at the current wavelength
 "If the HA9 attenuator is set at the minimum loss position, PWR? returns 101 dB.

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the optical power setting:
  PWR? returns the current optical power setting
  PWR? MIN returns the minimum optical power setting at the current wavelength
  PWR? MAX returns the maximum optical power setting at the current wavelength
 "If the HA9 attenuator is set at the minimum loss position, PWR? returns 101 dB.
"""
  cmd="PWR? MIN"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Self_test(verbose=1):
  """

 Executes a self-test operation and returns the result. An error code is also placed into the errorqueue. The queue can be queried with  ERR? or  LERR?.  TST? also sets bit 7 in the status register.
  0 = self-test passed
  1 = self-test failed

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Executes a self-test operation and returns the result. An error code is also placed into the errorqueue. The queue can be queried with  ERR? or  LERR?.  TST? also sets bit 7 in the status register.
  0 = self-test passed
  1 = self-test failed
"""
  cmd="TST?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Beam_Block_Status(verbose=1):
  """

 Returns the on/off status of the beam block:
  0 = beam block off
  1 = beam block on

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the on/off status of the beam block:
  0 = beam block off
  1 = beam block on
"""
  cmd="D?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Input_Buffer(verbose=1):
  """

 Returns the status of the input buffer:
  1 = the input buffer is empty; for example, all commands have been executed
  0 = the input buffer is not empty; for example, commands are still pending

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the status of the input buffer:
  1 = the input buffer is empty; for example, all commands have been executed
  0 = the input buffer is not empty; for example, commands are still pending
"""
  cmd="OPC?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Error_Number(verbose=1):
  """

 Returns an error number if the self-test operation fails:
  330 = self-test failed
    0 = no error occurred

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns an error number if the self-test operation fails:
  330 = self-test failed
    0 = no error occurred
"""
  cmd="ERR?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Slope_User_Value(verbose=1):
  """

 Returns the user slope:
  SLP? returns the current user slope
  SLP? MIN returns the minimum user slope*
  SLP? MAX return the maximum user slope

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the user slope:
  SLP? returns the current user slope
  SLP? MIN returns the minimum user slope*
  SLP? MAX return the maximum user slope
"""
  cmd="SLP?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Slope_User_Value_MAX(verbose=1):
  """

 Returns the user slope:
  SLP? returns the current user slope
  SLP? MIN returns the minimum user slope*
  SLP? MAX return the maximum user slope

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the user slope:
  SLP? returns the current user slope
  SLP? MIN returns the minimum user slope*
  SLP? MAX return the maximum user slope
"""
  cmd="SLP? MAX"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Slope_User_Value_MIN(verbose=1):
  """

 Returns the user slope:
  SLP? returns the current user slope
  SLP? MIN returns the minimum user slope*
  SLP? MAX return the maximum user slope

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the user slope:
  SLP? returns the current user slope
  SLP? MIN returns the minimum user slope*
  SLP? MAX return the maximum user slope
"""
  cmd="SLP? MIN"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Display_Offset__PWR_Mode_(verbose=1):
  """

 Returns the display offset in PWR mode:
  PCAL? returns the current display offset
  PCAL? MIN returns the minimum display offset
  PCAL? MAX returns the maximum display offset

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the display offset in PWR mode:
  PCAL? returns the current display offset
  PCAL? MIN returns the minimum display offset
  PCAL? MAX returns the maximum display offset
"""
  cmd="PCAL?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Display_Offset__PWR_Mode__MAX(verbose=1):
  """

 Returns the display offset in PWR mode:
  PCAL? returns the current display offset
  PCAL? MIN returns the minimum display offset
  PCAL? MAX returns the maximum display offset

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the display offset in PWR mode:
  PCAL? returns the current display offset
  PCAL? MIN returns the minimum display offset
  PCAL? MAX returns the maximum display offset
"""
  cmd="PCAL? MAX"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Display_Offset__PWR_Mode__MIN(verbose=1):
  """

 Returns the display offset in PWR mode:
  PCAL? returns the current display offset
  PCAL? MIN returns the minimum display offset
  PCAL? MAX returns the maximum display offset

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the display offset in PWR mode:
  PCAL? returns the current display offset
  PCAL? MIN returns the minimum display offset
  PCAL? MAX returns the maximum display offset
"""
  cmd="PCAL? MIN"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Driver_Status(verbose=1):
  """

 Returns the status of the driver:
  0 = driver is off
  1 = driver is on

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the status of the driver:
  0 = driver is off
  1 = driver is on
"""
  cmd="XDR?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Condition_Register(verbose=1):
  """

 Returns the contents of the conditi on register as an integer (see the  Status Reporting andService Request Control section).

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 Returns the contents of the conditi on register as an integer (see the  Status Reporting andService Request Control section).
"""
  cmd="CNB?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20


def get_Learn(verbose=1):
  """

 In HA and HP mode, returns a 58-character string containing a summary of the current settingsof the attenuator. The string is formatted as follows:
  Fiber setting = four characters (always returns 1)
   Output state = four characters (0 = beam block off, 1 = beam block on)*  SRQ mask = eight characters
  Attenuation display offset = 13 characters*  Attenuation = 13 characters
  Wavelength = 16 characters
  HA mode example: 1   0   6       10.0000      22.0000      13000e-06
  HP mode example: F I;D 1;SRE   6;CAL  10.0000;ATT  22.0000;WVL    13000e-06;

  """
  global debug
  global fd
  if debug or (verbose & 1): print """
 In HA and HP mode, returns a 58-character string containing a summary of the current settingsof the attenuator. The string is formatted as follows:
  Fiber setting = four characters (always returns 1)
   Output state = four characters (0 = beam block off, 1 = beam block on)*  SRQ mask = eight characters
  Attenuation display offset = 13 characters*  Attenuation = 13 characters
  Wavelength = 16 characters
  HA mode example: 1   0   6       10.0000      22.0000      13000e-06
  HP mode example: F I;D 1;SRE   6;CAL  10.0000;ATT  22.0000;WVL    13000e-06;
"""
  cmd="LRN?"
  ret=send_cmd(fd,cmd)
  time.sleep(1)
  result=get_response(fd)
  result=result.strip()
  result=result.replace(' ','')
  result=result.replace("'","")
  if debug or (verbose & 1): print "="*20
  if debug or (verbose & 1): print cmd 
  if debug or (verbose & 1): print "-"*20
  if debug or (verbose & 1): print "Value = %s" % result
  if debug or (verbose & 1): print "="*20
if __name__=='__main__':
  setup_rs232_link()
  for i in range(10):
    set_Attenuation(i)
    time.sleep(2)
  value=1
  set_Reset(value,verbose=1)
  set_Display_Mode(value,verbose=1)
  set_Display_Offset__PWR_Mode_(value,verbose=1)
  set_Beam_Block(value,verbose=1)
  set_SRQ_Mask_Register(value,verbose=1)
  set_Clear_Status_Byte(value,verbose=1)
  set_Attenuation(value,verbose=1)
  set_Display_Offset__ATT_Mode_(value,verbose=1)
  set_Clear_SRQ_Mask_Register(value,verbose=1)
  set_Display_Offset__PWR_Mode_(value,verbose=1)
  set_Output_Power(value,verbose=1)
  set_Driver_Control(value,verbose=1)
  set_Calibration_Wavelength(value,verbose=1)
  get_Last_Error(verbose=1)
  get_Identification(verbose=1)
  get_Calibration_Wavelength(verbose=1)
  get_Calibration_Wavelength_MAX(verbose=1)
  get_Calibration_Wavelength_MIN(verbose=1)
  get_Display_Mode(verbose=1)
  get_Display_Offset__ATT_Mode_(verbose=1)
  get_Display_Offset__ATT_Mode__MAX(verbose=1)
  get_Display_Offset__ATT_Mode__MIN(verbose=1)
  get_Attenuation(verbose=1)
  get_Attenuation_MAX(verbose=1)
  get_Attenuation_MIN(verbose=1)
  get_Slope_Control(verbose=1)
  get_Status_Register(verbose=1)
  get_Power_Setting(verbose=1)
  get_Power_Setting_MAX(verbose=1)
  get_Power_Setting_MIN(verbose=1)
  get_Self_test(verbose=1)
  get_Beam_Block_Status(verbose=1)
  get_Input_Buffer(verbose=1)
  get_Error_Number(verbose=1)
  get_Slope_User_Value(verbose=1)
  get_Slope_User_Value_MAX(verbose=1)
  get_Slope_User_Value_MIN(verbose=1)
  get_Display_Offset__PWR_Mode_(verbose=1)
  get_Display_Offset__PWR_Mode__MAX(verbose=1)
  get_Display_Offset__PWR_Mode__MIN(verbose=1)
  get_Driver_Status(verbose=1)
  get_Condition_Register(verbose=1)
  get_Learn(verbose=1)
