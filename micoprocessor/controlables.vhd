library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity controlables is
generic
(
	file_path:string 
);
port(
	clk,reset:in std_logic;
	-- data path's controlable signals
	RF_address: in	std_logic_vector(RF_adress-1 downto 0);
	alu_op: in std_logic_vector(alu_ops-1 downto 0);
	shifter_op: in std_logic_vector(shifter_ops-1 downto 0);
	to_freg : in std_logic_vector(0 downto 0);
	to_acc_sel,to_RF_sel,memory_data_sel: in std_logic_vector(1 downto 0);
	carry_sel,rf_read,rf_write: in std_logic;
	acc_enable,freg_enable,swap_reg_enable: in std_logic;
	-- memory's controlable signals
	spc_sel:in std_logic_vector(0 downto 0);
	ir_adress:in std_logic_vector(1 downto 0);
	pc_enable,ix_enable,mar_enable,mir_enable,sp_enable,ram_enable: in std_logic;
	au_op:in std_logic_vector(1 downto 0);
	au_in_sel,mir_sel,mar_sel:in std_logic_vector(1 downto 0);
	ram_read,ram_write,ir_read,ir_write: in std_logic;
	-- io port's controlable signals 
	input_data:in std_logic_vector(dataBus_size-1 downto 0);
	io_sel: in std_logic_vector(0 downto 0);
	io_wd,io_rd,write_io: in std_logic;
	io_adress:in std_logic_vector(3 downto 0);
	--useful for cu
	flag_reg:out std_logic_vector(dataBus_size-1 downto 0);
	ir_output,outdata :out std_logic_vector(dataBus_size-1 downto 0);
	--io port readable only output 
	port0,port1,port2,port3,port4,port5,port6,port7:out std_logic_vector(dataBus_size-1 downto 0);
	port8,port9,port10,port11,port12,port13,port14,port15:out std_logic_vector(dataBus_size-1 downto 0)
	);
end controlables;
architecture arch of controlables is 
component data_path is 
port
(
	clk,reset :in std_logic;
	ram_data,IO_data,IR_data: in std_logic_vector(dataBus_size-1 downto 0);
	RF_adress_field: in std_logic_vector(2 downto 0);
	alu_op: in std_logic_vector(alu_ops-1 downto 0);
	shifter_op: in std_logic_vector(shifter_ops-1 downto 0);
	to_freg : in std_logic_vector(0 downto 0);
	to_acc_sel,to_RF_sel,memory_data_sel: in std_logic_vector(1 downto 0);
	carry_sel,rf_read,rf_write: in std_logic;
	acc_enable,freg_enable,swap_reg_enable: in std_logic;
	acc_value,flag_value,reg_value :out std_logic_vector(dataBus_size-1 downto 0 )
)
;end component;

component memory_unit is 
generic
(
	file_path:string
);
port 
(
	clk,reset: in std_logic;
	spc_sel:in std_logic_vector(0 downto 0);
	ir_adress:in std_logic_vector(1 downto 0);
	rf,flag_reg,acc: in std_logic_vector(dataBus_size-1 downto 0);
	pc_enable,ix_enable,mar_enable,mir_enable,sp_enable,ram_enable: in std_logic;
	au_op:in std_logic_vector(1 downto 0);
	au_in_sel,mir_sel,mar_sel:in std_logic_vector(1 downto 0);
	ram_read,ram_write,ir_read,ir_write: in std_logic;
	ram_data: out std_logic_vector(dataBus_size-1 downto 0);
	ir_point : out std_logic_vector(dataBus_size-1 downto 0);
	op_code: out std_logic_vector(7 downto 0)
	
);
end component;

component io_port is 
port(
	clk,reset,io_wd,io_rd,io_write:in std_logic;
	io_sel: in std_logic_vector(0 downto 0);
	reg,acc,input_data :in std_logic_vector(DataBus_size-1 downto 0);
	io_adress:in std_logic_vector(3 downto 0);
	io_out:out std_logic_vector(dataBus_size-1 downto 0);
	port0,port1,port2,port3,port4,port5,port6,port7:out std_logic_vector(dataBus_size-1 downto 0);
	port8,port9,port10,port11,port12,port13,port14,port15:out std_logic_vector(dataBus_size-1 downto 0)
);
end component;
	signal ramdata,iodata,accdata,regdata,irdata,flagdata: std_logic_vector(dataBus_size-1 downto 0);
begin
datapath:data_path port map(clk=>clk,reset=>reset,ram_data=>ramdata,io_data=>iodata,ir_data=>irdata,
RF_adress_field=>rf_address,alu_op=>alu_op,shifter_op=>shifter_op,to_freg=>to_freg,
to_acc_sel=>to_acc_sel,to_RF_sel=>to_RF_sel,memory_data_sel=>memory_data_sel,
carry_sel=>carry_sel,rf_read=>rf_read,rf_write=>rf_write,acc_enable=>acc_enable,freg_enable=>freg_enable,
swap_reg_enable=>swap_reg_enable,acc_value=>accdata,flag_value=>flagdata,reg_value=>regdata);

flag_reg<=flagdata;
outdata<=accdata;

memory:memory_unit generic map(file_path=>file_path) port map(clk=>clk,reset=>reset,spc_sel=>spc_sel,ir_adress=>ir_adress,pc_enable=>pc_enable,ix_enable=>ix_enable,
mar_enable=>mar_enable,mir_enable=>mir_enable,sp_enable=>sp_enable,rf=>regdata,flag_reg=>flagdata,acc=>accdata,
ram_enable=>ram_enable,au_op=>au_op,au_in_sel=>au_in_sel,mir_sel=>mir_sel,mar_sel=>mar_sel,ram_read=>ram_read,
ram_write=>ram_write,ir_read=>ir_read,ir_write=>ir_write,ram_data=>ramdata,ir_point=>irdata,op_code=>ir_output);



ioPort:io_port port map(clk=>clk,reset=>reset,input_data=>input_data,io_write=>write_io,io_rd=>io_rd,io_wd=>io_wd,io_sel=>io_sel,io_adress=>io_adress,
reg=>regdata,acc=>accdata,io_out=>iodata,port0=>port0,port1=>port1,port2=>port2,port3=>port3,port4=>port4,port5=>port5,port6=>port6,port7=>port7,
port8=>port8,port9=>port9,port10=>port10,port11=>port11,port12=>port12,port13=>port13,port14=>port14,port15=>port15);

end arch;