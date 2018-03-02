
 add_fsm_encoding \
       {pcie4_uscale_plus_1_gt_phy_rst.fsm} \
       { }  \
       {{000 111} {001 000} {010 001} {011 010} {100 011} {101 100} {110 101} {111 110} }

 add_fsm_encoding \
       {pcie4_uscale_plus_1_gt_phy_txeq.fsm} \
       { }  \
       {{000 000} {001 001} {010 010} {011 011} {100 100} {101 101} }

 add_fsm_encoding \
       {pcie4_uscale_plus_1_gt_phy_rxeq.fsm} \
       { }  \
       {{000 000} {001 001} {010 010} {011 011} {100 100} }

 add_fsm_encoding \
       {pcie4_uscale_plus_1_gt_receiver_detect_rxterm.ctrl_fsm} \
       { }  \
       {{000 100} {001 000} {010 001} {011 010} {100 011} }
