//----------------------------------------------------------------------------
// dfe_check_reg_rd_after_wr_seq: UVM_REG transactions to write/read the DUT
//----------------------------------------------------------------------------
class dfe_check_rd_after_wr_seq extends dsp_tb_reg_base_seq;
    
    `uvm_object_utils(dfe_check_rd_after_wr_seq)
    
    function new(string name = "dfe_check_rd_after_wr_seq");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e    status;        
        uvm_reg         dfe_regs[$];
        uvm_reg_field   reg_fields[$];

        bit[31:0]   wr_data, rd_data;
        bit[31:0]   reg_mask;
        bit         ignore_flag;    //flag=1: need to ignore
        
        reg_model.mmap0_DFE.get_registers(dfe_regs);
        if(dfe_regs.size() == 0)
            `uvm_error(get_type_name(), "Can not get registers from this reg block\n")
        
        //set configure register
        reg_model.mmap0_DFE.DFE_DFE_MODE_CFG_0.write(status, 0);
        #1000;
        reg_model.mmap0_DFE.DFE_DFE_MODE_CFG_1.write(status, 0);
        #1000;
        reg_model.mmap0_DFE.DFE_TX_MODE_CFG.write(status, 0);
        #1000;
        reg_model.mmap0_DFE.DFE_DFE_CAPTURE_CFG_0.write(status, 'h1f);        
        #1000;
        reg_model.mmap0_DFE.DFE_DFE_CAPTURE_CFG_1.write(status, 'h1f);
        #1000;
        reg_model.mmap0_DFE.DFE_TX_CAPTURE_CFG.write(status, 'h3);
        
        //random write and read
        foreach(dfe_regs[i])begin
            string reg_name = dfe_regs[i].get_name();
            string field_name, field_access;
            int reg_name_len = reg_name.len();
            reg_mask = 32'hffffffff;
            ignore_flag = 0;

            reg_fields.delete();
            dfe_regs[i].get_fields(reg_fields); 
            if(reg_fields.size() == 0)begin
                `uvm_error(get_type_name(), "Can not get fields from this register\n")
                continue;
            end

            foreach(reg_fields[j])begin
                field_access = reg_fields[j].get_access(dfe_regs[i].get_default_map());
                field_access = field_access.substr(0,1);
                if( (field_access == "WO") || (field_access == "RO") )begin   //skip WO/RO registers
                    ignore_flag = 1;
                    break;
                end
                field_name = reg_fields[j].get_name();
                field_name = field_name.substr(reg_name_len+2,reg_name_len+9); //format of field name in reg model: (reg_name)__(field_name)
                if( (field_name == "RESERVED") )begin               //get register mask
                    reg_mask &= ~(((1<<reg_fields[j].get_n_bits())-1)<<reg_fields[j].get_lsb_pos());
                end
            end


            if(ignore_flag == 0)begin   //need to compare
                wr_data = $urandom_range('hffffffff,0);
                wr_data &= reg_mask;
                dfe_regs[i].write(status, wr_data);
                #1000;
                dfe_regs[i].mirror(status, UVM_NO_CHECK);
                #100;
                rd_data = dfe_regs[i].get_mirrored_value();
                
                `uvm_info(get_type_name(), $psprintf("%s mask is %h!\n", dfe_regs[i].get_name(), reg_mask), UVM_LOW)
                if(rd_data != wr_data)
                    `uvm_error(get_type_name(), $psprintf("%s wr/rd value compare failed!\nrd_data:%h, wr_data:%h\n", dfe_regs[i].get_name(), rd_data, wr_data))
                else
                    `uvm_info(get_type_name(), $psprintf("%s wr/rd value compare successful!\nrd_data:%h, wr_data:%h\n", dfe_regs[i].get_name(), rd_data, wr_data), UVM_LOW)
            end
            else    //need to ignore
                `uvm_info(get_type_name(), $psprintf("Skip to write and read %s, because it is %s!\n", reg_name, field_access), UVM_LOW)

            //recovery configure register
            if( (reg_name == "DFE_DFE_MODE_CFG_0") || (reg_name == "DFE_DFE_MODE_CFG_1") || (reg_name == "DFE_TX_MODE_CFG") )
                dfe_regs[i].write(status, 0);

            if( (reg_name == "DFE_DFE_CAPTURE_CFG_0") || (reg_name == "DFE_DFE_CAPTURE_CFG_1") || (reg_name == "DFE_TX_CAPTURE_CFG") )
                dfe_regs[i].write(status, 'hffffffff);  //will be masked
        end      


        `uvm_info(get_type_name(), "DFE Controller Register check rd after wr value sequence completed!", UVM_LOW)
    endtask

endclass : dfe_check_rd_after_wr_seq

