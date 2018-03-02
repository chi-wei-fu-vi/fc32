
 add_fsm_encoding \
       {pio_ep_mem_access.wr_mem_state} \
       { }  \
       {{000 00} {001 01} {010 10} {100 11} }

 add_fsm_encoding \
       {pio_tx_engine.state} \
       { }  \
       {{0000 000001} {0001 000010} {0011 000100} {0110 010000} {1010 100000} {1100 001000} }
