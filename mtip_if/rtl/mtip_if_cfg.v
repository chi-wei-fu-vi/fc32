/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: mtip_if_cfg.v$
* $Author: honda.yang $
* $Date: 2013-07-19 10:31:19 -0700 (Fri, 19 Jul 2013) $
* $Revision: 2880 $
* Description: FCOE module parameter definitions
*
***************************************************************************/

package mtip_if_cfg;

///////////////////////////////////////////////////////////////////////////////
// FC SOF Characters
///////////////////////////////////////////////////////////////////////////////
localparam      SOFc1                           = 32'h BCB51717;
localparam      SOFi1                           = 32'h BCB55757;
localparam      SOFn1                           = 32'h BCB53737;
localparam      SOFi2                           = 32'h BCB55555;
localparam      SOFn2                           = 32'h BCB53535;
localparam      SOFi3                           = 32'h BCB55656;
localparam      SOFn3                           = 32'h BCB53636;
localparam      SOFc4                           = 32'h BCB51919;
localparam      SOFi4                           = 32'h BCB55959;
localparam      SOFn4                           = 32'h BCB53939;
localparam      SOFf                            = 32'h BCB55858;

///////////////////////////////////////////////////////////////////////////////
// FC EOF Characters
///////////////////////////////////////////////////////////////////////////////
localparam      EOFfp                           = 32'h BC957575;
localparam      EOFfn                           = 32'h BCB57575;
localparam      EOFdtp                          = 32'h BC959595;
localparam      EOFdtn                          = 32'h BCB59595;
localparam      EOFap                           = 32'h BC95F5F5;
localparam      EOFan                           = 32'h BCB5F5F5;
localparam      EOFnp                           = 32'h BC95D5D5;
localparam      EOFnn                           = 32'h BCB5D5D5;
localparam      EOFnip                          = 32'h BC8AD5D5;
localparam      EOFnin                          = 32'h BCAAD5D5;
localparam      EOFdtip                         = 32'h BC8A9595;
localparam      EOFdtin                         = 32'h BCAA9595;
localparam      EOFrtp                          = 32'h BC959999;
localparam      EOFrtn                          = 32'h BCB59999;
localparam      EOFrtip                         = 32'h BC8A9999;
localparam      EOFrtin                         = 32'h BCAA9999;

localparam      IDLE                            = 32'h BC95B5B5;

localparam      ARBFF                           = 32'h BC94FFFF;



endpackage
