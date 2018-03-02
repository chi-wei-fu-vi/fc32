#!/bin/env python2

rows=[]

ios=[]
logics=[]
always=[]


def readxls(file):
  """
  """
  wb = open_workbook(file)
  ws = wb.sheet_by_name("stats counter")
  for row in range(ws.nrows):
    #print ws.row_values(row)
    rows.append(ws.row_values(row))


def trc2vlog():
  """
input iREG_NUMGOODETHERTYPE3OCTETS_EN;
output [47:0] oREG_NUMGOODETHERTYPE3OCTETS_USR;
input [15:0] iREG_NUMGOODETHERTYPE3OCTETS_INC;
input iREG_NUMGOODETHERTYPE3OCTETS_LATCH;

reg [47:0] NUMGOODETHERTYPE3OCTETS;
reg [47:0] NUMGOODETHERTYPE3OCTETS_rd;
wire [47:0] NUMGOODETHERTYPE3OCTETS_sel;

// trc: NUMGOODETHERTYPE3OCTETS
always @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      begin
        NUMGOODETHERTYPE3OCTETS <= 48'h0;
        NUMGOODETHERTYPE3OCTETS_rd <= 48'h0;
      end
    else begin
      if(iREG_NUMGOODETHERTYPE3OCTETS_LATCH) begin
        NUMGOODETHERTYPE3OCTETS <= (iREG_NUMGOODETHERTYPE3OCTETS_EN == 1'b1)? iREG_NUMGOODETHERTYPE3OCTETS_INC : 48'h0;
        NUMGOODETHERTYPE3OCTETS_rd <= NUMGOODETHERTYPE3OCTETS;
      end else begin
        NUMGOODETHERTYPE3OCTETS <= (iREG_NUMGOODETHERTYPE3OCTETS_EN == 1'b1)? NUMGOODETHERTYPE3OCTETS + iREG_NUMGOODETHERTYPE3OCTETS_INC : NUMGOODETHERTYPE3OCTETS;
      end
    end
  end
assign NUMGOODETHERTYPE3OCTETS_sel = NUMGOODETHERTYPE3OCTETS_rd;
assign oREG_NUMGOODETHERTYPE3OCTETS_USR = NUMGOODETHERTYPE3OCTETS_sel;
  """

  regs=[]
  reg2loc={}
  reg2incsz={}
  rows.pop(0)
  for row in rows:
    (regdesc,regname,offset,default,regtype,usr,depth,incsz,bitdesc,bitname,loc,bittype)= row
    if regtype == "TRC":
      regs.append(regname)
      reg2loc[regname]=loc
      reg2incsz[regname]=incsz
     
  
  for reg in regs:
    if reg2incsz[reg] == "":
      ios.append("  %-10s %-5s %-15s %s"%("input","wire","","iREG_%s_EN"%reg.upper()))
      ios.append("  %-10s %-5s %-15s %s"%("output","wire",reg2loc[reg],"oREG_%s_USR"%reg.upper()))
      ios.append("  %-10s %-5s %-15s %s"%("input","wire","","iREG_%s_LATCH"%reg.upper()))
      logics.append("%-10s %-15s %s;"%("reg",reg2loc[reg],"%s"%reg.upper()))
      logics.append("%-10s %-15s %s;"%("reg",reg2loc[reg],"%s_rd"%reg.upper()))
      logics.append("%-10s %-15s %s;"%("wire",reg2loc[reg],"%s_sel"%reg.upper()))
      always.append("""
// trc: %s
always @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      begin
        %s <= 32'h0;
        %s_rd <= 32'h0;
      end
    else begin
      if(iREG_%s_LATCH) begin
        %s <= (iREG_%s_EN == 1'b1)? 32'h1 : 32'h0;
        %s_rd <= %s;
      end else begin
        %s <= (iREG_%s_EN == 1'b1)? %s + 'b1 : %s;
      end
    end
  end
assign %s_sel = %s_rd;
assign oREG_%s_USR = %s_sel;
"""%( reg.upper(), reg.upper(),
reg.upper(), reg.upper(), reg.upper(), reg.upper(), reg.upper(),
reg.upper(), reg.upper(), reg.upper(), reg.upper(), reg.upper(),
reg.upper(), reg.upper(), reg.upper(), reg.upper()))
    else:
      ios.append("  %-10s %-5s %-15s %s"%("input","wire","","iREG_%s_EN"%reg.upper()))
      ios.append("  %-10s %-5s %-15s %s"%("output","wire",reg2loc[reg],"oREG_%s_USR"%reg.upper()))
      ios.append("  %-10s %-5s %-15s %s"%("input","wire","[%d:0]"%(int(reg2incsz[reg])-1),"iREG_%s_INC"%reg.upper()))
      ios.append("  %-10s %-5s %-15s %s"%("input","wire","","iREG_%s_LATCH"%reg.upper()))
      logics.append("%-10s %-15s %s;"%("reg",reg2loc[reg],"%s"%reg.upper()))
      logics.append("%-10s %-15s %s;"%("reg",reg2loc[reg],"%s_rd"%reg.upper()))
      logics.append("%-10s %-15s %s;"%("wire",reg2loc[reg],"%s_sel"%reg.upper()))
      always.append("""
// trc: %s
always @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      begin
        %s <= 48'h0;
        %s_rd <= 48'h0;
      end
    else begin
      if(iREG_%s_LATCH) begin
        %s <= (iREG_%s_EN == 1'b1)? iREG_%s_INC : 48'h0;
        %s_rd <= %s;
      end else begin
        %s <= (iREG_%s_EN == 1'b1)? %s + iREG_%s_INC : %s;
      end
    end
  end
assign %s_sel = %s_rd;
assign oREG_%s_USR = %s_sel;
"""%( reg.upper(), reg.upper(),
reg.upper(), reg.upper(), reg.upper(), reg.upper(), reg.upper(),
reg.upper(), reg.upper(), reg.upper(), reg.upper(), reg.upper(),
reg.upper(), reg.upper(), reg.upper(), reg.upper(), reg.upper(),
reg.upper()))


def writevlog(file):
  """
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    frame_128_255_good <= 0;
  else if (frame_128_255_good_inc)
    frame_128_255_good <= frame_128_255_good + 1;
  """
  OUTFILE=open(file,"w")
  lines=[]
  ios.append("  %-10s %-5s %-15s %s"%("input","wire","","clk"))
  ios.append("  %-10s %-5s %-15s %s"%("input","wire","","rst_n"))
  lines.append("module %s ("%os.path.splitext(os.path.basename(file))[0])
  lines.append(",\n".join(ios))
  lines.append(");")
  lines.extend(logics)
  lines.extend(always)
  lines.append("endmodule")
  print "\n".join(lines)
  OUTFILE.write("\n".join(lines))
  OUTFILE.close()
    
def writevlog_old(file):
  """
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    frame_128_255_good <= 0;
  else if (frame_128_255_good_inc)
    frame_128_255_good <= frame_128_255_good + 1;
  """
  OUTFILE=open(file,"w")
  lines=[]
  regs=[]
  ios=[]
  always=[]
  reg2loc={}
  rows.pop(0)
  for row in rows:
    (regdesc,regname,offset,default,regtype,usr,depth,incsz,bitdesc,bitname,loc,bittype)= row
    regs.append(regname)
    reg2loc[regname]=loc
     
  
  ios.append("  input  wire  %-15s  %s"% ("","clk"))
  ios.append("  input  wire  %-15s  %s"% ("","rst_n"))
  ios.extend(map(lambda x: "  output reg   %-15s  %s"%(reg2loc[x],x),regs))
  ios.extend(map(lambda x: "  input  wire  %-15s  %s"%("",x+"_inc"),regs))
  always.extend(map(lambda x: """always @(posedge clk or negedge rst_n)
  if (~rst_n)
    %s <= 0;
  else if (%s_inc)
    %s <= %s + 1;
"""%(x,x,x,x),regs))
  lines.append("module %s ("%os.path.splitext(os.path.basename(file))[0])
  lines.append(",\n".join(ios))
  lines.append(");")
  lines.extend(always)
  lines.append("endmodule")
  print "\n".join(lines)
  OUTFILE.write("\n".join(lines))
  OUTFILE.close()
 

if __name__ == '__main__':
  """
  """
  import sys
  import os
  libdir = os.path.dirname(os.path.realpath(__file__)) + "/lib"
  sys.path.append(libdir)  # for lib/xlwt module
  from xlrd import *

  argc=len(sys.argv)
  if argc > 1 : xls = sys.argv[1]
  if argc > 2 : vlog = sys.argv[2] # verilog format

  readxls(xls)
  trc2vlog()
  writevlog(vlog)



