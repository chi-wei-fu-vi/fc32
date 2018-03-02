#!/usr/bin/env python2

import string, math, re

def hex64(n):
    return "0x%s"%("0000000000000000%x"%(n&0xffffffffffffffff))[-16:]

def hex16(n):
    return "0x%s"%("0000%x"%(n&0xffff))[-4:]
    

def log2 (num):
    return math.ceil (math.log (num) / math.log (2))

# function that tries to interpret a number in Verilog notation
def get_digit(str):
    robj = re.compile ("(\d+)'([dhb])([\da-fA-F]+)")
    mobj = robj.match (str)
    return int(mobj.group(1))

def number (str):
    try:
        robj = re.compile ("(\d+)'([dhb])([\da-fA-F]+)")
        mobj = robj.match (str)
        if (mobj):
            if mobj.group(2) == 'h': radix = 16
            elif mobj.group(2) == 'b': radix = 2
            else: radix = 10
    
            return int (mobj.group(3), radix)
        else:
            return int(str)
    except ValueError:
        print "ERROR: number conversion of %s failed" % str
        return 0

# 0x .. format
def hexn(n,digit):
    if digit%4 !=0:
        itr = digit/4+1
    else:
        itr=digit/4

    tmp_str = "%0d'h"%itr+'f'*itr
    tmp_num = number(tmp_str)
    return "0x%s"%('0'*itr+'%x'%(n&tmp_num))[-itr:]

# 'h format
def hexh(n,digit):
    if digit%4 !=0:
        itr = digit/4+1
    else:
        itr=digit/4

    tmp_str = "%0d'h"%itr+'f'*itr
    tmp_num = number(tmp_str)
    return "%0d'h%s"%(digit,('0'*itr+'%x'%(n&tmp_num))[-itr:])




def int2bin (n):
    bStr = ''
    if (n < 0): raise ValueError, "must be positive integer"
    if (n == 0): return '0'
    while (n > 0):
        bStr = str (n%2) + bStr
        n = n >> 1
    return bStr

# it returns end num, start num
def loc2num (str):
    mtstr = re.compile ('\d+')
    mtstr2 = mtstr.findall(str)
    num =[]
    num.append(int(mtstr2[0],10))
    num.append(int(mtstr2[1],10))
    return num

def simp_block (mlist):
    result = ''
    for s in mlist:
        result += '    ' + s + '\n'

    return result
    
def comb_block (statements):
    result = 'always @*\n'
    result += '  begin\n'
    for s in statements:
        result += '    ' + s + '\n'
    result += '  end\n'
    return result

def seq_block (clock, statements, lite = '0'):
    if(lite == '1'):
        result = 'generate if(LITE != 1) begin\n'
        result += 'always @(posedge ' + clock + ' or negedge rst_n)\n'
        result += '  begin\n'
        for s in statements:
            result += '    ' + s + '\n'
        
        result += '  end\nend\nendgenerate\n\n'

    else:
        result = 'always @(posedge ' + clock + ' or negedge rst_n)\n'
        result += '  begin\n'
        for s in statements:
            result += '    ' + s + '\n'

        result += '  end\n'

    return result

def seq_block_sync (clock, statements, lite = '0'):
    if(lite == '1'):
        result = 'generate if(LITE != 1) begin\n'
        result += 'always @(posedge ' + clock + ')\n'
        result += '  begin\n'
        for s in statements:
            result += '    ' + s + '\n'

        result += '  end\nend\nendgenerate\n\n'
    else:
        result = 'always @(posedge ' + clock + ')\n'
        result += '  begin\n'
        for s in statements:
            result += '    ' + s + '\n'

        result += '  end\n'


    return result


class v_node:
    def __init__ (self,name,base,digit):
        self.name = name
        self.base = base
        self.clist = []
        self.rlist = []
        self.digit = digit
        self.size  = 0
        self.array_size = 0
        self.x_base = ''  # binary base
        self.msk = ''
        self.clk = ''
        self.sp  = '' #superposition


class v_field:
    def __init__ (self, name, loc, type, desc):
        self.name = name
        self.loc = loc
        tmp = loc2num(loc)
        self.msk = self.get_64b_msk(tmp[1],tmp[0])
        self.shift = tmp[1]
        self.ed = tmp[0]
        self.type = type
        self.desc = desc.rstrip()

    def get_64b_msk(self,st,ed):
        my_msk = ''
        for i in range(64):
            if( (i >= st) and (i <= ed)):
                my_msk+='1'
            else:
                my_msk+='0'

        my_msk = my_msk[::-1]
        my_msk_int = int(my_msk,2)
        my_hex = hex64(my_msk_int)

        return (my_hex)


class v_register:
    def __init__ (self, name, offset, type, default, desc, regex=""):
        self.name = name
        self.offset = self.get_hex16(offset)
        self.type = type
        self.default = default
        self.desc = self.get_desc(desc)
        self.regex = regex
        self.field = []
        self.offset2 = offset
        self.base = 0
    
    def get_hex16(self,offset):
        rc = re.search(r"(\d+)\'h([0-9a-fA-F]+)", offset)
        if rc == None:
            print "mismatch:", offset
            return  hex16(0)
        else:
            tmp_int = int(rc.group(2),16)
        return hex16(tmp_int)

    def get_desc(self,str):
        my_str = str.rstrip()
        return my_str

class v_reg_list:
    def __init__ (self, name, base, size, array_size):
        self.name = name
        self.base = base
        self.size = size
        self.array_size = array_size
        self.reserved = 0
        self.list = []


class vdoc_reg_group:
    def __init__ (self, name, life='cur'):
        self.name=name
        self.life=life
        self.dlist = []

class vg_group:
    def __init__ (self, name, base):
        self.name = name
        self.base = "0x%s00"%base[3:]
        self.creg = []

class vdoc_fld (v_field):
    def __init__ (self, name, loc, type, desc,life):
        v_field.__init__(self, name, loc, type, desc)
        self.idx = 0
        self.life = life

class vdoc_reg (v_register):
    def __init__ (self, name, offset, type, default, desc, life,mem_sz=''):
        v_register.__init__(self, name, offset, type, default, desc)
        self.life = life
        if(mem_sz !=''):
            self.mem_sz = self.get_hex16(mem_sz)
        else:
            self.mem_sz = 0
class vdoc_group (vg_group):
    def __init__ (self, name, base, life):
        vg_group.__init__(self, name, base)
        self.map_name = self.get_new_name(name, base)
        self.life = life
    
    def get_new_name(self,name,base):
        my_str =''
        if(base[4] == '2' and base[3] != '0'):
            my_str = 'LINK'+base[3]+'_GLOBAL'
        elif(base[4] == '1' and base[3] != '0'):
            my_str = 'LINK'+base[3]+'_CHAN1'
        elif(base[4] == '0' and base[3] != '0'):
            my_str = 'LINK'+base[3]+'_CHAN0'
        else:
            my_str = name

        return my_str



class reg_field:
    def __init__ (self, name, type, st, ed):
        self.name = name
        self.type = type
        self.st = st
        self.ed = ed
        self.width = ed-st+1

class net:
    def __init__ (self, type, name, width=1):
        self.width = width
        self.name  = name
        self.type  = type

    def declaration (self):
        if (self.width == 1):
            return self.type + ' ' + self.name + ';'
        else:
            return "%s [%d:0] %s;" % (self.type, self.width-1, self.name)
        
class port:
    def __init__ (self, direction, name, width=1):
        self.direction = direction
        self.width = width
        self.name = name

    def declaration (self):
        if (self.width == 1):
            return self.direction + ' ' + self.name + ';'
        else:
            return "%s [%d:0] %s;" % (self.direction, self.width-1, self.name)

class decoder_range:
    def __init__ (self, name, base, bits):
        self.name = name
        self.base = base
        self.bits = bits

    def check_range(self):
        mask = (1 << self.bits) - 1
        if (self.base & mask):
            return 1
        else: return 0

    def get_base_addr(self):
        return self.base


# jdon new addr decoder
class dec_group:
    def __init__ (self, ranges,wd):
        self.addr_width = wd # address bit width
        self.data_size = 64
        self.name = ''
        self.type = 0
        self.ranges = ranges
        self.ports = [port ('input', 'clk'), port('input','rst_n')]
        self.nets  = []
        self.blocks = []
        
    def build (self):
        self.ports.append (port ('input', 'iMM_ADDR', self.addr_width))
        self.ports.append (port ('input', 'iMM_WR_EN'))
        self.ports.append (port ('input', 'iMM_RD_EN'))
        self.ports.append (port ('input', 'iMM_WR_DATA', self.data_size))
        self.ports.append (port ('output', 'oMM_RD_DATA', self.data_size))
        self.ports.append (port ('output', 'oMM_RD_DATA_V'))

        self.nets.append (net('reg','rd_data',self.data_size))
        self.nets.append (net('reg','rd_data_v'))
        self.nets.append (net('reg','ldata',self.data_size))
        self.nets.append (net('reg','ldata_v'))
        self.nets.append (net('reg','ldata_vd'))

        self.nets.append (net('reg','laddr',self.addr_width))
        self.nets.append (net('reg','lwen'))
        self.nets.append (net('reg','lren'))
        self.nets.append (net('reg','lwdata',self.data_size))

        self.blocks.append ( """
   always @(posedge clk or negedge rst_n)
    begin
      if (~rst_n)
        begin
          rd_data <= 0;
          rd_data_v <= 0;
          laddr <= 'h0;
          lwen <= 0;
          lren <= 0;
          lwdata <= 'h0;
        end
      else
        begin
           rd_data <= ldata;
           ldata_vd <= ldata_v;
           rd_data_v <= ldata_vd;
           laddr <= iMM_ADDR;
           lwen <= iMM_WR_EN;
           lren <= iMM_RD_EN;
           lwdata <= iMM_WR_DATA;           
         end // else: !if(~rst_n)
    end // always @ (posedge clk)\n""")

        self.blocks.append ("""
    assign oMM_RD_DATA = rd_data;
    assign oMM_RD_DATA_V = rd_data_v;
\n""")

#        addr_mux = ["\ncasez (laddr) // synopsys parallel_case"]

        for r in self.ranges:
            self.ports.append (port ('output', r.name.upper() + "_ADDR",self.addr_width))
            self.ports.append (port ('output', r.name.upper() + "_WR_DATA", self.data_size))
            self.ports.append (port ('output', r.name.upper() + "_WR_EN"))
            self.ports.append (port ('output', r.name.upper() + "_RD_EN"))
            self.ports.append (port ('input', r.name.upper() + "_RD_DATA", self.data_size))
            self.ports.append (port ('input', r.name.upper() + "_RD_DATA_V"))
            self.nets.append (net('reg', "l"+r.name+"_wren"))
            self.nets.append (net('reg', "l"+r.name+"_rden"))

            if(r.clk == ''):
                cur_clk = 'clk'
                wrad = ["assign %s_ADDR = laddr;"%r.name.upper(),
                        "assign %s_WR_EN = l%s_wren;"%(r.name.upper(),r.name),
                        "assign %s_RD_EN = l%s_rden;"%(r.name.upper(),r.name),
                        "assign %s_WR_DATA = lwdata;\n"%r.name.upper()]
                self.blocks.append (simp_block(wrad))


            else: # sync required
                cur_clk = r.name.upper()+"_clk"
                cur_rst = r.name.upper()+"_rst_n"
                self.ports.append (port ('input', cur_clk))
                self.ports.append (port ('input', cur_rst))
                self.nets.append (net('wire', "l"+r.name+"_rd_data_v"))
                self.nets.append (net('wire', "l"+r.name+"_rd_data",self.data_size))
                self.nets.append (net('wire', r.name.upper()+"_WR_EN"))
                self.nets.append (net('wire', r.name.upper()+"_RD_EN"))

                sync_blk = ["///////////////////////////////////////////",
                             "//",
                             "// Pulse Sync for %s"%r.name.upper(), 
                             "//",
                             "///////////////////////////////////////////\n",
                             "vi_sync_csr sync_%s ("%r.name.upper(),
                             "  .iRST_N_A       (rst_n),",
                             "  .iCLK_A         (clk),",
                             "  .iWREN_A        (l%s_wren),"%r.name,
                             "  .iRDEN_A        (l%s_rden),"%r.name,
                             "  .iADDR_A        (laddr),",
                             "  .iWR_DATA_A     (lwdata),",
                             "  .oACK_A         (l%s_rd_data_v),"%r.name,
                             "  .oRD_DATA_A     (l%s_rd_data),"%r.name,
                             "  .iRST_N_B       (%s),"%cur_rst,
                             "  .iCLK_B         (%s),"%cur_clk,
                             "  .oWREN_B        (%s_WR_EN),"%r.name.upper(),
                             "  .oRDEN_B        (%s_RD_EN),"%r.name.upper(),
                             "  .iACK_B         (%s_RD_DATA_V),"%r.name.upper(),
                             "  .iRD_DATA_B     (%s_RD_DATA),"%r.name.upper(),
                             "  .oADDR_B        (%s_ADDR),"%r.name.upper(),
                             "  .oWR_DATA_B     (%s_WR_DATA)"%r.name.upper(),
                             ");\n"]

                self.blocks.append (simp_block(sync_blk))

# add decoder type
        if(self.type == 0):

            addr_mux = ["\ncasez (laddr) // synopsys parallel_case"]
            for r in self.ranges: 
                addr_mux.insert(0, "l%s_wren = 0;" % r.name)
                addr_mux.insert(1, "l%s_rden = 0;" % r.name)

#            print "dbg: %s   %d"%(r.msk,len(r.msk))

                base_addr = r.x_base
                for i in range(-1,-len(r.msk)-1,-1):
                    if(r.msk[i] == '1'):
                        if(i == -1):
                            base_addr = base_addr[:i]+'z'
                        else:
                            base_addr = base_addr[:i]+'z'+base_addr[i+1:]
#               print "base : %d   %s" %(i,base_addr)
#            print "new base: %d'b%s : %0d" % (r.digit,base_addr,len(base_addr))
            
                    if(r.digit > len(base_addr)):
                        fill = r.digit - len(base_addr)
                        base_addr = '0'*fill+base_addr
            
                addr_mux.append ("%d'b%s :" % (r.digit,base_addr))
                addr_mux.append ("begin  // %s"%r.name)
                addr_mux.append ("l%s_wren = lwen;" % r.name)
                addr_mux.append ("l%s_rden = lren;" % r.name)
                if(r.clk == ''):
                    addr_mux.append ("ldata_v = %s_RD_DATA_V;" % r.name.upper())
                    addr_mux.append ("ldata = %s_RD_DATA;" % r.name.upper())
                else:
                    addr_mux.append ("ldata_v = l%s_rd_data_v;" % r.name)
                    addr_mux.append ("ldata = l%s_rd_data;" % r.name)
                
                addr_mux.append ("end")

            addr_mux.append("default :")
            addr_mux.append("begin")
            addr_mux.append("  ldata = {32'h5555_AAAA,{%d{1'b0}},laddr};"%(32-r.digit))
            addr_mux.append("  ldata_v = lren;")
            addr_mux.append("end")
            addr_mux.append("endcase\n")

            self.blocks.insert (0, comb_block(addr_mux))
        else:
            addr_mux = ["\ncasez (laddr) // synopsys parallel_case"]
            addr_mux2 = ["\ncasez (laddr) // synopsys parallel_case"]
            addr_mux3 = ["\ncasez (laddr) // synopsys parallel_case"]
            for r in self.ranges: 
                addr_mux.insert(0, "l%s_wren = 0;" % r.name)
                addr_mux.insert(1, "l%s_rden = 0;" % r.name)

#            print "dbg: %s   %d"%(r.msk,len(r.msk))

                base_addr = r.x_base
                for i in range(-1,-len(r.msk)-1,-1):
                    if(r.msk[i] == '1'):
                        if(i == -1):
                            base_addr = base_addr[:i]+'z'
                        else:
                            base_addr = base_addr[:i]+'z'+base_addr[i+1:]
#               print "base : %d   %s" %(i,base_addr)
#            print "new base: %d'b%s : %0d" % (r.digit,base_addr,len(base_addr))
            
                    if(r.digit > len(base_addr)):
                        fill = r.digit - len(base_addr)
                        base_addr = '0'*fill+base_addr
            
                addr_mux.append ("%d'b%s :" % (r.digit,base_addr))
                addr_mux.append ("begin  // %s"%r.name)
                addr_mux.append ("l%s_wren = lwen;" % r.name)
                addr_mux.append ("l%s_rden = lren;" % r.name)
                addr_mux2.append ("%d'b%s :" % (r.digit,base_addr))
                addr_mux2.append ("begin  // %s"%r.name)
                addr_mux3.append ("%d'b%s :" % (r.digit,base_addr))
                addr_mux3.append ("begin  // %s"%r.name)
                if(r.clk == ''):
                    addr_mux.append ("ldata_v = %s_RD_DATA_V;" % r.name.upper())
                    addr_mux2.append ("ldata[63:32] = %s_RD_DATA[63:32];" % r.name.upper()) 
                    addr_mux3.append ("ldata[31:0] = %s_RD_DATA[31:0];" % r.name.upper())
                else:
                    addr_mux.append ("ldata_v = l%s_rd_data_v;" % r.name)
                    addr_mux2.append ("ldata[63:32] = l%s_rd_data[63:32];" % r.name)
                    addr_mux3.append ("ldata[31:0] = l%s_rd_data[31:0];" % r.name)
                
                addr_mux.append ("end")
                addr_mux2.append ("end")
                addr_mux3.append ("end")

            addr_mux.append("default :")
            addr_mux.append("begin")
            addr_mux.append("  ldata_v = lren;")
            addr_mux.append("end")
            addr_mux.append("endcase\n")

            addr_mux2.append("default :")
            addr_mux2.append("begin")
            addr_mux2.append("  ldata[63:32] = {32'h5555_AAAA};")
            addr_mux2.append("end")
            addr_mux2.append("endcase\n")
            addr_mux3.append("default :")
            addr_mux3.append("begin")
            addr_mux3.append("  ldata[31:0] = {{%d{1'b0}},laddr};"%(32-r.digit))
            addr_mux3.append("end")
            addr_mux3.append("endcase\n")

            self.blocks.insert (0, comb_block(addr_mux))
            self.blocks.insert (1, comb_block(addr_mux2))
            self.blocks.insert (2, comb_block(addr_mux3))
            
    def header(self):
        mystr = "/********************************CONFIDENTIAL****************************\n"
        mystr +="* Copyright (c) 2012 Virtual Instruments.\n"
        mystr +="* 25 Metro Dr, STE#400, San Jose, CA 95110\n"
        mystr +="* www.virtualinstruments.com\n"
        mystr +="* $Archive: $\n"
        mystr +="* $Author: $\n"
        mystr +="* $Date: $\n"
        mystr +="* $Revision: $\n"
        mystr +="* Description:\n"
        mystr +="* This module decodes address and mux/demux read/write data among configuration registers.\n"
        mystr +="* This is generated from %s.xml and vgen script. Do not manually modify it\n"%self.name
        mystr +="* All manual changes will be overwritten by script whenever new file is generated.\n\n"
        mystr +="***************************************************************************/\n"

        return mystr
            
 # for addr decoder        
    def verilog (self):
        self.build()
        result = self.header()
        result += 'module ' + self.name + ' ('
        result += string.join (map (lambda x: x.name, self.ports), ',')
        result += ');\n'

        # print port list
        for p in self.ports:
            result += p.declaration() + '\n'

        result +='\n'
        # print net list
        for n in self.nets:
            result += n.declaration() + '\n'
        
        result +='\n'

        # create all blocks in block list
        for b in self.blocks:
            result += b

        result +='\n'        
        result += 'endmodule\n'
        return result

    def add_range (self, r):
        self.ranges.append (r)

        
        

################################################


class register_group:
    def __init__ (self, sz):
        self.addr_size = sz
        self.data_size = 64
        self.name = ''
        self.local_width = 1  # number of address bits consumed
        self.registers = []
        self.ports = [port ('input', 'clk'), port('input','rst_n')]
        self.nets  = []
        self.interrupts = 0   # if interrupt registers present
        self.user = 0         # if user-defined registers present
        self.blocks = []
        self.registered_read = 0
        self.hold_regs = 0
        self.hold_inputs = []

    def top_intf (self,has_mem):
        self.ports.append (port ('input', 'wr_en'))
        self.ports.append (port ('input', 'rd_en'))
        self.ports.append (port ('input', 'addr', self.addr_size))
        self.ports.append (port ('input', 'wr_data', self.data_size))
        self.ports.append (port ('output', 'rd_data', self.data_size))
        self.ports.append (port ('output', 'rd_data_v'))
        self.nets.append (net('reg','rd_data',self.data_size))
        self.nets.append (net('reg','ldata',self.data_size))
        self.nets.append (net('reg','lwr_data',self.data_size))
        self.nets.append (net('reg','rd_data_v'))
        self.nets.append (net('reg','memrd_en'))
        self.nets.append (net('reg','memrd_v'))
        self.nets.append (net('reg','lwr_en'))

        if(has_mem == 1):
            self.nets.append (net('reg','memrd_en_latch'))
        else:
            self.nets.append (net('wire','memrd_en_latch'))

    # create a hook for post-processing to be done after all data has been
    # added to the object.
    def post (self,has_mem):
        self.top_intf(has_mem)
        for reg in self.registers:
            self.ports.extend (reg.io())
            self.nets.extend (reg.nets())
            #self.local_width = int(math.ceil (log2 (len (self.registers))))
            self.local_width = self.addr_size;


    def global_logic (self):
        # create select pin for this block
        statements = []
        tot_memrdv = "1'b0"

        # create read and write selects for each register
        for r in self.registers:
            if (r.type() != 'mem'):
                slogic =  "(addr[%d:%d] == %d) & (rd_en == 1'b1)" % (self.local_width-1,0,r.offset)
            else:
                if(r.rng != 1):
                    slogic = "(addr[%d:%d] >= %d) & (addr[%d:%d] < %d) & (rd_en == 1'b1)" % (self.local_width-1,0,r.offset,self.local_width-1,0,r.offset+r.rng)
                else:
                    slogic =  "(addr[%d:%d] == %d) & (rd_en == 1'b1)" % (self.local_width-1,0,r.offset)
                tot_memrdv += " | iREG_%s_V"%r.name

            if(r.lite == '1'):
                s = "%s_rd_sel = 1'b0;" % r.name
            else:
                s = "%s_rd_sel = %s;" % (r.name,slogic)
            statements.append (s)
#            print "mydbg : %s" % r.type
            if r.write_cap():
                if (r.iscnt == 1):
#                if (r.type() == 'frc' or r.type() == 'lrc' or r.type() == 'trc' or r.type() == 'satc'):
                    if(r.lite == '1'):
                        s = "%s_wr_sel = 1'b0;"% r.name
                    else:
                        s = "%s_wr_sel = (addr[%d:%d] == %d) & (lwr_en == 1'b1) & (lwr_data[0] == 1'b1);" % (r.name,self.local_width-1,0,r.offset)
                elif (r.type() == 'mem'):
                    if(r.rng != 1):
                        s = "%s_wr_sel = (addr[%d:%d] >= %d) & (addr[%d:%d] < %d) & (lwr_en == 1'b1);" % (r.name,self.local_width-1,0,r.offset,self.local_width-1,0,r.offset+r.rng)
                    else:
                        s = "%s_wr_sel = (addr[%d:%d] == %d) & (lwr_en == 1'b1);" % (r.name,self.local_width-1,0,r.offset)  
                else:
                    s = "%s_wr_sel = (addr[%d:%d] == %d) & (lwr_en == 1'b1);" % (r.name,self.local_width-1,0,r.offset)

                statements.append (s)

        statements.append ("memrd_v = %s;"%tot_memrdv)    
        return comb_block (statements)

    def memrd_latch(self):
        s=''
        sments = []
        sments.append ("case (1'b1)")
        for r in self.registers:
            if (r.type() == 'mem'):
                sments.append ("  %s_rd_sel : memrd_en_latch = 1'b1;"%r.name)
        
        sments.append("  default : memrd_en_latch = 1'b0;")
        sments.append("endcase")

        return comb_block (sments)


    def read_mux (self):
        s = ''
        sments = []

        # create data-output mux
        sments.append ("case (1'b1)")
        rd_target = "ldata"

        for r in self.registers:
            if (r.type() == 'lrc'):
                sments.append ("  %s_rd_sel : %s = %s_rd;" % (r.name, rd_target, r.name))
            elif (r.type() == 'trc'):
                sments.append ("  %s_rd_sel : %s = %s_sel;" % (r.name, rd_target, r.name))
            elif(r.type() == 'mem'):
                sments.append ("  %s_rd_wait: %s = iREG_%s_RD;"%(r.name,rd_target,r.name))
            elif(r.type() == 'rw' or r.type() == 'mix'):
                sments.append ("  %s_rd_sel : %s = WREG_%s;" % (r.name, rd_target,r.name))
            else:
                sments.append ("  %s_rd_sel : %s = %s;" % (r.name, rd_target,r.name))

        sments.append ("  default : %s = {32'h5555_AAAA,{%d{1'b0}},addr[%d:%d]};" % (rd_target,32-self.local_width,self.local_width-1,0))
        sments.append ("endcase")

        return comb_block (sments)
                
    def global_ff(self):
        statements = ["if (~rst_n) begin",
                      "   rd_data <= 64'h0;",
                      "   rd_data_v <= 1'b0;",
                      "   memrd_en <=  1'b0;",
                      "   lwr_en <=  1'b0;",
                      "   lwr_data <= 64'h0;",
                      "end else begin",
                      "   lwr_en <= wr_en;",
                      "   lwr_data <= wr_data;",
                      "   memrd_en <= (memrd_en_latch | memrd_v)? ~memrd_en : memrd_en;",
                      "   rd_data <= (memrd_v | rd_en)? ldata : rd_data;",
                      "   rd_data_v <= ((wr_en|rd_en) & ~memrd_en_latch) | memrd_v;",
                      "end"]
        return seq_block('clk',statements)

    def header(self):
        mystr = "/********************************CONFIDENTIAL****************************\n"
        mystr +="* Copyright (c) 2012 Virtual Instruments.\n"
        mystr +="* 25 Metro Dr, STE#400, San Jose, CA 95110\n"
        mystr +="* www.virtualinstruments.com\n"
        mystr +="* $Archive: $\n"
        mystr +="* $Author: $\n"
        mystr +="* $Date: $\n"
        mystr +="* $Revision: $\n"
        mystr +="* Description:\n"
        mystr +="* This module contains configuration registers and counters.\n"
        mystr +="* This is generated from %s.xml and vgen script. Do not manually modify it\n"%self.name
        mystr +="* All manual changes will be overwritten by script whenever new file is generated.\n\n"
        mystr +="***************************************************************************/\n"

        return mystr
        
    def verilog (self):

        has_mem=0
        for r in self.registers:
            if(r.type() == 'mem'):
                has_mem = 1;
        
        self.post(has_mem)
        result = self.header()
        result += 'module ' + self.name + ' ('
        result += string.join (map (lambda x: x.name, self.ports), ',')
        result += ');\n'
        result += 'parameter LITE = 0;\n'

        # print port list
        for p in self.ports:
            result += p.declaration() + '\n'

        result += '\n'
        # print net list
        for n in self.nets:
            result += n.declaration() + '\n'

        result += '\n'

        # create global logic
        result += '// global logic\n'
        result += self.global_logic()
        result += '\n// read mux\n'
        result += self.read_mux()
        result += '\n// memrd latch\n'
        if(has_mem == 1):
            result += self.memrd_latch()
        else:
            result += "assign memrd_en_latch = 1'b0;\n"

        result += '\n// global ff\n'
        result += self.global_ff()
        result += '\n'

        # print function blocks
        for r in self.registers:
            result += r.verilog_body()
            result += '\n'

        result += '\n'
            
        result += 'endmodule\n'
        return result


    def add_register (self, type, params):
        if (type == 'RW'):
            if(params['scope'] == 'reg'):
                self.add (rw_reg (params['name'],params['width'],params['offset'],params['default'],params['usr']))
            else:
                self.add (mix_reg(params['name'],params['width'],params['offset'],params['default'],params['usr']))
        elif (type == 'RO'):
            self.add (status_reg (params['name'],params['width'],params['offset']))
        elif (type == 'FRC'):
            self.add (freerun_cnt (params['name'],params['width'],params['offset'],params['default'],params['usr'],params['incsz'],params['lite']))
        elif (type == 'LRC'):
            self.add (latchrst_cnt (params['name'],params['width'],params['offset'],params['default'],params['usr'],params['incsz'],params['lite'])) 
        elif (type == 'TRC'):
            self.add (t_cnt (params['name'],params['width'],params['offset'],params['default'],params['usr'],params['incsz'],params['lite'])) 
        elif (type == 'MEM'):
            self.add (mem_reg (params['name'],params['width'],params['offset'],params['default'],params['adsz'],params['rng']))
        elif (type == 'SATC'):
            self.add (saturated_cnt (params['name'],params['width'],params['offset'],params['default'],params['usr'],params['incsz'],params['lite']))
        else:
            print "Unknown register type",type

    def add (self, reg):
        self.registers.append (reg)
        #self.ports.extend (reg.io())
        #self.nets.extend (reg.nets())
        #self.local_width = int(math.ceil (log2 (len (self.registers))))
        #rnum = 0
        #for r in self.registers:
        #    r.offset = rnum
        #    rnum += 1
        
class basic_register:
    def __init__ (self, name='', width=0, offset=0):
        self.offset = offset
        self.width  = width
        self.name   = name
        self.interrupt = 0
        self.iscnt = 0
        self.lite = 0

    def verilog_body (self):
        pass

    def type (self):
        return 'basic'
    
    def io (self):
        return []

    def nets (self):
        return []

    def write_cap (self):
        return 0

    def id_comment (self):
        return "// %s: %s\n" % (self.type(), self.name)

class rw_reg (basic_register):
    def __init__ (self, name='', width=0, offset=0, default=0, usr=''):
        basic_register.__init__(self, name, width, offset)
        self.default = default
        self.usr = usr
        self.fields = []
        
    def verilog_body (self):
        vstr = self.id_comment()
        if(self.usr == '1'):
            statements = ["if (~rst_n) begin",
                          "   WREG_%s <= %d'h%x;" % (self.name, self.width, self.default),
                          "   %s_wr_sel_d <= 1'b0;"%(self.name),
                          "end else begin",
                          "   WREG_%s <= (%s_wr_sel == 1'b1)? lwr_data : WREG_%s;" % tuple([self.name] * 3),
                          "   %s_wr_sel_d <= %s_wr_sel;"%tuple([self.name] * 2),
                          "end"]
        else:
            statements = ["if (~rst_n) begin",
                          "   WREG_%s <= %d'h%x;" % (self.name, self.width, self.default),
                          "end else begin",
                          "   WREG_%s <= (%s_wr_sel == 1'b1)? lwr_data : WREG_%s;" % tuple([self.name] * 3),
                          "end"]

                      
        vstr += seq_block('clk', statements)

        for fld in self.fields:
            if(self.width == 1):
                tmp_fld = "%s" % (self.name)
            elif(fld.width == 1):
                tmp_fld = "%s[%0d]" % (self.name,fld.st)
            else:
                tmp_fld = "%s[%0d:%0d]" % (self.name,fld.ed,fld.st)

            if(len(self.fields) == 1):
                tmp_asg = "assign %s = WREG_%s;\n" % ('oREG_'+self.name,tmp_fld)
            else:
                tmp_asg = "assign oREG_%s_%s = WREG_%s;\n" % (self.name,fld.name,tmp_fld)

            vstr += tmp_asg            


        if(self.usr == '1'):
            vstr += "assign oREG_%s_WR_EN = %s_wr_sel_d;\n"%tuple([self.name] *2)

        return vstr

    def type (self):
        return 'rw'
        
    def io (self):
        my_list = []
        if(self.usr == '1'):
            my_list = [port('output','oREG_'+self.name+'_WR_EN',1)]

        if (len(self.fields) == 1):
            my_list.append(port('output','oREG_'+self.name, self.fields[0].width))
        else:
            for fld in self.fields:
                my_list.append (port ('output','oREG_'+self.name+'_'+fld.name, fld.width))


        return my_list

    def nets (self):
        my_list = []
        if(self.usr == '1'):
            my_list = [net('reg', 'WREG_'+self.name, self.width),
                       net('reg', self.name + '_rd_sel'),
                       net('reg', self.name + '_wr_sel'),
                       net('reg', self.name + '_wr_sel_d')]

        else:
            my_list = [ net('reg', 'WREG_'+self.name, self.width),
                        net('reg', self.name + '_rd_sel'),
                        net('reg', self.name + '_wr_sel')]

        return my_list

    def write_cap (self):
        return 1


class mix_reg (basic_register):
    def __init__ (self, name='', width=0, offset=0, default=0, usr=''):
        basic_register.__init__(self, name, width, offset)
        self.default = default
        self.usr = usr
        self.fields = []
        
    def verilog_body (self):
        vstr = self.id_comment()
        statements = ["if (~rst_n) WREG_%s <= %d'h%x;" % (self.name, self.width, self.default),"else begin"]
        asg_list = []

        for fld in self.fields:
            if(self.width == 1):
                tmp_fld = "%s" % (self.name)
                tmp_wr = "lwr_data[%0d]" % (fld.st)
            elif(fld.width == 1):
                tmp_fld = "%s[%0d]" % (self.name,fld.st)
                tmp_wr = "lwr_data[%0d]" % (fld.st)
            else:
                tmp_fld = "%s[%0d:%0d]" % (self.name,fld.ed,fld.st)
                tmp_wr = "lwr_data[%0d:%0d]" % (fld.ed,fld.st)

            if(fld.type == "RW"):
                tmp_str = "   WREG_%s <= (%s_wr_sel == 1'b1)? %s : WREG_%s;" % (tmp_fld,self.name,tmp_wr,tmp_fld)
            else: # if SC,
                tmp_str = "   WREG_%s <= (%s_wr_sel == 1'b1)? %s : 'b0;" % (tmp_fld,self.name,tmp_wr)

            if(len(self.fields) == 1):
                tmp_asg = "assign oREG_%s = WREG_%s;\n" % (self.name,tmp_fld)
            else:
                tmp_asg = "assign oREG_%s_%s = WREG_%s;\n" % (self.name,fld.name,tmp_fld)

            asg_list.append(tmp_asg)

            statements.append(tmp_str)

        statements.append("end")
                      
        vstr += seq_block('clk', statements)

        for asg in asg_list:
            vstr += asg


        if(self.usr == '1'):
            vstr += "assign oREG_%s_WR_EN = %s_wr_sel;\n"%tuple([self.name] *2)

        return vstr

    def type (self):
        return 'mix'
        
    def io (self):
        my_list = []
        if(self.usr == '1'):
            my_list = [port('output','oREG_'+self.name+'_WR_EN',1)]
        
        if (len(self.fields) == 1):
            my_list.append(port('output','oREG_'+self.name, self.fields[0].width))
        else:
            for fld in self.fields:
                my_list.append (port ('output','oREG_'+self.name+'_'+fld.name, fld.width))

        return my_list

    def nets (self):
        return [ net('reg', 'WREG_'+self.name, self.width),
                 net('reg', self.name + '_rd_sel'),
                 net('reg', self.name + '_wr_sel')]

    def write_cap (self):
        return 1


class status_reg (basic_register):
    def __init__ (self, name='', width=0, offset=0):
        basic_register.__init__(self, name, width, offset)

    def type (self):
        return 'ro'
        
    def verilog_body (self):
        vstr = self.id_comment()
        cur_loc = 63;

#        if(len(self.fields) != 1):
#            vstr += "assign %s = %s;\n" % ('l_'+self.name,self.name)
        my_asg='{'
        for fld in self.fields:
            zf = cur_loc - fld.ed
            if(zf != 0):
                my_asg += "{%0d{1'b0}}, "%zf

            if(len(self.fields) == 1):
                my_asg += 'iREG_'+self.name+', '
            else:
                my_asg += 'iREG_'+self.name+'_'+fld.name+', '


            

            cur_loc = fld.st-1
                
        if(cur_loc != -1):
            my_asg += "{%0d{1'b0}}, "% (cur_loc+1)

        my_asg = my_asg[:-2]
        my_asg += '}'
        vstr += "assign %s = %s;\n" % (self.name,my_asg)
                
        return vstr

    def io (self):
        if (len(self.fields) == 1):
            return [port('input','iREG_'+self.name, self.fields[0].width)]
        else:
            plist = []
            for fld in self.fields:
                plist.append (port ('input','iREG_'+self.name+'_'+fld.name,fld.width))
            return plist

    def nets (self):
        return [ net('reg', self.name + '_rd_sel'),
                 net('wire', self.name, 64)] # assume data field 64 bits

class reg_cnt (basic_register):
    def __init__ (self, name='', width=0, offset=0, default=0, usr='',incsz=1,lite=0):
        basic_register.__init__(self, name, width, offset)
        self.default = default
        self.usr = usr
        self.incsz = incsz
        self.iscnt = 1
        self.lite = lite
        
    def io (self):
        my_list = []
        if(self.usr == '1'):
            my_list = [port('input','iREG_'+self.name+'_EN', 1),
                       port('output','oREG_'+self.name+'_USR',self.width)]
            
        else:
            my_list = [port('input','iREG_'+self.name+'_EN', 1)]


        if(self.incsz >1):
            my_list.append(port('input','iREG_'+self.name+'_INC',self.incsz))
        return my_list

    def nets (self):
        return [net('reg', self.name, self.width), 
                net('reg', self.name + '_rd_sel'),
                net('reg', self.name + '_wr_sel')]

    def write_cap (self):
        return 1
    

class freerun_cnt (reg_cnt):
    def __init__ (self, name='', width=0, offset=0, default=0, usr='',incsz=1,lite=0):
        reg_cnt.__init__(self,name,width,offset,default,usr,incsz,lite)

    def type (self):
        return 'frc'

    def verilog_body (self):
        vstr = self.id_comment()
        statements = ["if (~rst_n) %s <= %d'h%x;" % (self.name,self.width, self.default),
                      "else if (%s_wr_sel == 1'b1) %s <= %d'h%x;" % (self.name, self.name, self.width, self.default)]
        if(self.incsz > 1):
            statements.append("else %s <= (iREG_%s_EN == 1'b1)? %s + iREG_%s_INC : %s;" % tuple([self.name] * 5))
        else:
            statements.append("else %s <= (iREG_%s_EN == 1'b1)? %s + 1 : %s;" % tuple([self.name] * 4))

        vstr += seq_block('clk', statements,self.lite)

        if(self.usr == '1'):
            if(self.lite == '1'):
                tmp_asg = "assign oREG_%s_USR = {%d{1'b0}};\n"%(self.name,self.width)
            else:
                tmp_asg = "assign oREG_%s_USR = %s;\n"%tuple([self.name]*2)

            vstr += tmp_asg

        return vstr

    def io (self):
        my_list = reg_cnt.io (self)

        return my_list

    def nets (self):
        net_list = reg_cnt.nets (self)
        return net_list



class latchrst_cnt (reg_cnt):
    def __init__ (self, name='', width=0, offset=0, default=0, usr='',incsz=1,lite=0):
        reg_cnt.__init__(self,name,width,offset,default,usr,incsz,lite)

    def type (self):
        return 'lrc'
        
    def verilog_body (self):
        vstr = self.id_comment()
        statements = ["if (~rst_n)",
                      "  begin",
                      "    %s <= %d'h%x;" % (self.name,self.width, self.default),
                      "    %s <= %d'h%x;" % (self.name+'_rd',self.width, self.default),
                      "  end",
                      "else if (%s_wr_sel == 1'b1)" % (self.name),
                      "  begin",
                      "    %s <= %d'h%x;" % (self.name,self.width, self.default),
                      "    %s <= %d'h%x;" % (self.name+'_rd',self.width, self.default), 
                      "  end else begin",
                      "    if(iREG_%s_LATCH) begin" % (self.name)]
        if(self.incsz > 1):
            statements.append("      %s <= (iREG_%s_EN == 1'b1)? iREG_%s_INC : %d'h0;"%(self.name,self.name,self.name,self.width))
        else:
            statements.append("      %s <= (iREG_%s_EN == 1'b1)? %d'h1 : %d'h0;"%(self.name,self.name,self.width,self.width))

        statements.append("      %s_rd <= %s;"%(self.name,self.name))
        statements.append("    end else begin")

        if(self.incsz > 1):
            statements.append("      %s <= (iREG_%s_EN == 1'b1)? %s + iREG_%s_INC : %s;\n        end\n    end" % tuple([self.name] * 5))        
        else:
            statements.append("      %s <= (iREG_%s_EN == 1'b1)? %s + 'h1 : %s;\n        end\n    end" % tuple([self.name] * 4))

        vstr += seq_block('clk', statements,self.lite)

        if(self.usr == '1'):
            if(self.lite == '1'):
                tmp_asg = "assign oREG_%s_USR = {%d{1'b0}};\n"%(self.name,self.width)
            else:
                tmp_asg = "assign oREG_%s_USR = %s_rd;\n"%tuple([self.name]*2)

            vstr += tmp_asg

        return vstr

    def io (self):
        my_list = reg_cnt.io (self)
        my_list.append(port('input','iREG_'+self.name+'_LATCH',1))
        return my_list


    def nets (self):
        net_list = reg_cnt.nets (self)
        net_list.append(net('reg', self.name + '_rd', self.width))
        return net_list
    
class t_cnt (reg_cnt):
    def __init__ (self, name='', width=0, offset=0, default=0, usr='',incsz=1,lite=0):
        reg_cnt.__init__(self,name,width,offset,default,usr,incsz,lite)

    def type (self):
        return 'trc'
        
    def verilog_body (self):
        vstr = self.id_comment()
        statements = ["if (~rst_n)",
                      "  begin",
                      "    %s <= %d'h%x;" % (self.name,self.width, self.default),
                      "    %s <= %d'h%x;" % (self.name+'_rd',self.width, self.default),
                      "  end",
                      "else if (%s_wr_sel == 1'b1)" % (self.name),
                      "  begin",
                      "    %s <= %d'h%x;" % (self.name,self.width, self.default),
                      "    %s <= %d'h%x;" % (self.name+'_rd',self.width, self.default), 
                      "  end else begin",
                      "    if(iREG_%s_LATCH & ~iREG_%s_DIS) begin" % (self.name,self.name)]
        if(self.incsz > 1):
            statements.append("      %s <= (iREG_%s_EN == 1'b1)? iREG_%s_INC : %d'h0;"%(self.name,self.name,self.name,self.width))
        else:
            statements.append("      %s <= (iREG_%s_EN == 1'b1)? %d'h1 : %d'h0;"%(self.name,self.name,self.width,self.width))
       
        statements.append("      %s_rd <= %s;"%(self.name,self.name))
        statements.append("    end else begin")

        if(self.incsz > 1):
            statements.append("      %s <= (iREG_%s_EN == 1'b1)? %s + iREG_%s_INC : %s;\n        end\n    end" % tuple([self.name] * 5))
        else:
            statements.append("      %s <= (iREG_%s_EN == 1'b1)? %s + 'b1 : %s;\n        end\n    end" % tuple([self.name] * 4))

        vstr += seq_block('clk', statements,self.lite)

        if(self.lite == '1'):
            tmp_asg = "assign %s_sel = {%d{1'b0}};\n"%(self.name,self.width)
        else:
            tmp_asg = "assign %s_sel = (iREG_%s_DIS == 1'b1)? %s : %s_rd;\n"%tuple([self.name]*4)

        vstr += tmp_asg

        if(self.usr == '1'):
            if(self.lite == '1'):
                tmp_asg = "assign oREG_%s_USR = {%d{1'b0}};\n"%(self.name,self.width)
            else:
                tmp_asg = "assign oREG_%s_USR = %s_sel;\n"%tuple([self.name]*2)
            vstr += tmp_asg

        return vstr

    def io (self):
        my_list = reg_cnt.io (self)
        my_list.append(port('input','iREG_'+self.name+'_LATCH',1))
        my_list.append(port('input','iREG_'+self.name+'_DIS',1))    
        return my_list


    def nets (self):
        net_list = reg_cnt.nets (self)
        net_list.append(net('reg', self.name + '_rd', self.width))
        net_list.append(net('wire', self.name + '_sel', self.width))
        return net_list

class mem_reg (basic_register):
    def __init__ (self, name='', width=0, offset=0, default=0, addr_sz=0, rng=0):
        basic_register.__init__(self, name, width, offset)
        self.default = default
        self.addr_sz = addr_sz
        self.rng = rng
        self.fields = []
        

    def type (self):
        return 'mem'

    def verilog_body (self):
        vstr = self.id_comment()
        statements = []

        statements.append("if (~rst_n) begin")
        statements.append("   %s_rd_wait <= 1'b0;"%self.name)
        if(self.rng != 1):
            statements.append("   %s_addr_d <= 'b0;"%self.name)

        statements.append("   %s_wr_d <= 'b0;"%self.name)
        statements.append("   %s_wen_d <= 'b0;"%self.name)
        statements.append("   %s_ren_d <= 'b0;"%self.name)
        statements.append("end else begin")
        statements.append("   %s_rd_wait <= (%s_rd_sel | iREG_%s_V)? ~%s_rd_wait : %s_rd_wait;"%tuple([self.name]*5))
        if(self.rng != 1):
            statements.append("   %s_addr_d <= (addr - %s);"%(self.name,self.offset))

        statements.append("   %s_wen_d <= %s_wr_sel;"%(self.name,self.name))                     
        statements.append("   %s_wr_d <= wr_data;"%self.name)
        statements.append("   %s_ren_d <= %s_rd_sel;"%(self.name,self.name))
        statements.append("end")

        vstr += seq_block('clk',statements)
        

        if(self.rng != 1):
            vstr += "assign oREG_%s_ADDR = %s_addr_d;\n"%(self.name,self.name)

        vstr += "assign oREG_%s_WR = %s_wr_d;\n"%(self.name,self.name)
        vstr += "assign oREG_%s_WR_EN = %s_wen_d;\n"%tuple([self.name]*2)
        vstr += "assign oREG_%s_RD_EN = %s_ren_d;\n"%tuple([self.name]*2)
        
        return vstr

    def io (self):
#        print "dbg : %s  %d" % (self.rng, log2(int(self.rng)))
        my_list = []
        my_list.append(port('input','iREG_'+self.name+'_V'))
        my_list.append(port('input','iREG_'+self.name+'_RD',self.fields[0].width))
        if(self.rng != 1):
            my_list.append(port('output','oREG_'+self.name+'_ADDR',(log2(self.rng))))

        my_list.append(port('output','oREG_'+self.name+'_WR',self.fields[0].width))
        my_list.append(port('output','oREG_'+self.name+'_WR_EN'))
        my_list.append(port('output','oREG_'+self.name+'_RD_EN'))

        return my_list

    def nets (self):
        my_list = []
        my_list.append(net('reg',self.name+'_rd_sel'))
        my_list.append(net('reg',self.name+'_rd_wait'))
        my_list.append(net('reg',self.name+'_wr_sel'))
        if(self.rng != 1):
            my_list.append(net('reg',self.name+'_addr_d',(log2(self.rng))))

        my_list.append(net('reg',self.name+'_wr_d',self.fields[0].width))
        my_list.append(net('reg',self.name+'_wen_d'))
        my_list.append(net('reg',self.name+'_ren_d'))

        return my_list

    def write_cap (self):
        return 1

class saturated_cnt (reg_cnt):
    def __init__ (self, name='', width=0, offset=0, default=0, usr='',incsz=1,lite=0):
        reg_cnt.__init__(self,name,width,offset,default,usr,incsz,lite)
        
    def type (self):
        return 'satc'
        
    def verilog_body (self):
        vstr = self.id_comment()
        statements = ["if (~rst_n) %s <= %d'h%x;" % (self.name,self.width, self.default),
                      "else if (%s_wr_sel == 1'b1) %s <= %d'h%x;" % (self.name, self.name, self.width, self.default)]
        if(self.incsz > 1): # I assume counter and increament value is all power of 2.
            statements.append("else %s <= (iREG_%s_EN == 1'b1 && %s+iREG_%s_INC != %d'h0)? %s + iREG_%s_INC : %s;" % (self.name,self.name,self.name,self.name,self.width,self.name,self.name,self.name))
        else:
            statements.append("else %s <= (iREG_%s_EN == 1'b1 && %s != {%d{1'b1}})? %s + 1 : %s;" % (self.name,self.name,self.name,self.width,self.name,self.name))

        vstr += seq_block('clk', statements,self.lite)

        if(self.usr == '1'):
            if(self.lite == '1'):
                tmp_asg = "assign oREG_%s_USR = {%d{1'b0}};\n"%(self.name,self.width)
            else:
                tmp_asg = "assign oREG_%s_USR = %s;\n"%tuple([self.name]*2)                

            vstr += tmp_asg

        return vstr

    def io (self):
        my_list = reg_cnt.io (self)
        return my_list

    def nets (self):
        net_list = reg_cnt.nets (self)
        return net_list
