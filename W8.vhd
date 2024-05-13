library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity W8 is 
generic
(--for mif initilization you need to uncomment attribute in ram.vhd
	file_path:string:="C:\Users\DELL\Desktop\NewCPU\(dis)asmebler\binary_output.txt"
);--txt file initialization you uncomment the function "init_ram" in ram.vhd 
port
(
	clk,reset,go,int:in std_logic;
	input_data:in std_logic_vector(dataBus_size-1 downto 0);
	outputdata:out std_logic_vector(dataBus_size-1 downto 0);
	sevsegl0,sevsegh0,sevsegl1,sevsegh1,sevsegl2,sevsegh2,sevsegl3,sevsegh3,sevsegl4,sevsegh4:out std_logic_vector(6 downto 0);
	sevsegl5,sevsegh5,sevsegl6,sevsegh6,sevsegl7,sevsegh7,sevsegl8,sevsegh8,sevsegl9,sevsegh9:out std_logic_vector(6 downto 0);
	sevsegl10,sevsegh10,sevsegl11,sevsegh11,sevsegl12,sevsegh12,sevsegl13,sevsegh13:out std_logic_vector(6 downto 0);
	sevsegl14,sevsegh14,sevsegl15,sevsegh15:out std_logic_vector(6 downto 0)
);
end W8;
architecture arch of W8 is

component controlables is 
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
	io_sel: in std_logic_vector(0 downto 0);
	input_data:in std_logic_vector(dataBus_size-1 downto 0);
	io_wd,io_rd,write_io: in std_logic;
	io_adress:in std_logic_vector(3 downto 0);
	--useful for cu
	flag_reg :out std_logic_vector(dataBus_size-1 downto 0);
	ir_output,outdata :out std_logic_vector(dataBus_size-1 downto 0);
	--io port readable only values
	port0,port1,port2,port3,port4,port5,port6,port7:out std_logic_vector(dataBus_size-1 downto 0);
	port8,port9,port10,port11,port12,port13,port14,port15:out std_logic_vector(dataBus_size-1 downto 0)
	);
end component;

component CU is
port 
(
	--status of our micro processor
	flag_reg:in std_logic_vector(dataBus_size-1 downto 0);
	ir_output :in std_logic_vector(dataBus_size-1 downto 0);
	--usual controlers of cu
	clk,reset,int,go:in std_logic;
	-- data path's controlable signals
	RF_address: out	std_logic_vector(RF_adress-1 downto 0);
	alu_op: out std_logic_vector(alu_ops-1 downto 0);
	shifter_op: out std_logic_vector(shifter_ops-1 downto 0);
	to_freg : out std_logic_vector(0 downto 0);
	to_acc_sel,to_RF_sel,memory_data_sel: out std_logic_vector(1 downto 0);
	carry_sel,rf_read,rf_write: out std_logic;
	acc_enable,freg_enable,swap_reg_enable: out std_logic;
	-- memory's controlable signals
	spc_sel:out std_logic_vector(0 downto 0);
	ir_adress:out std_logic_vector(1 downto 0);
	pc_enable,ix_enable,mar_enable,mir_enable,sp_enable,ram_enable: out std_logic;
	au_op:out std_logic_vector(1 downto 0);
	au_in_sel,mir_sel,mar_sel:out std_logic_vector(1 downto 0);
	ram_read,ram_write,ir_read,ir_write: out std_logic;
	-- io port's controlable signals 
	io_sel: out std_logic_vector(0 downto 0);
	io_wd,io_rd,io_write: out std_logic;
	io_adress:out std_logic_vector(3 downto 0)
);
end component;

component sevseg is 
port(
	input: in std_logic_vector(3 downto 0);
	output: out std_logic_vector(6 downto 0)
);
end component;

signal vRF_address: std_logic_vector(RF_adress-1 downto 0);
signal valu_op: std_logic_vector(alu_ops-1 downto 0);
signal vshifter_op: std_logic_vector(shifter_ops-1 downto 0);
signal vto_freg: std_logic_vector(0 downto 0);
signal vto_acc_sel,vto_RF_sel,vmemory_data_sel: std_logic_vector(1 downto 0);
signal vcarry_sel,vrf_read,vrf_write:std_logic;
signal vacc_enable,vfreg_enable,vswap_reg_enable:std_logic;
signal vspc_sel:std_logic_vector(0 downto 0);
signal vir_adress:std_logic_vector(1 downto 0);
signal vpc_enable,vix_enable,vmar_enable,vmir_enable,vsp_enable,vram_enable:std_logic;
signal vau_op:std_logic_vector(1 downto 0);
signal vau_in_sel,vmir_sel,vmar_sel:std_logic_vector(1 downto 0);
signal vram_read,vram_write,vir_read,vir_write:std_logic;
signal vio_sel:std_logic_vector(0 downto 0);
signal vio_wd,vio_rd,vwrite_io:std_logic;
signal vio_adress:std_logic_vector(3 downto 0);
signal vfreg,vir_output,voutdata:std_logic_vector(dataBus_size-1 downto 0);
signal port0,port1,port2,port3,port4,port5,port6,port7:std_logic_vector(dataBus_size-1 downto 0);
signal port8,port9,port10,port11,port12,port13,port14,port15:std_logic_vector(dataBus_size-1 downto 0); 

begin

	CONTROLED:controlables
	generic map (file_path=>file_path) 
	port map(clk=>clk,reset=>reset,
	RF_address=>vRF_address,alu_op=>valu_op,shifter_op=>vshifter_op,
	to_freg=>vto_freg,to_acc_sel=>vto_acc_sel,to_RF_sel=>vto_rf_sel,
	memory_data_sel=>vmemory_data_sel,carry_sel=>vcarry_sel,
	rf_read=>vrf_read,rf_write=>vrf_write,acc_enable=>vacc_enable,
	freg_enable=>vfreg_enable,swap_reg_enable=>vswap_reg_enable,
	spc_sel=>vspc_sel,ir_adress=>vir_adress,pc_enable=>vpc_enable,
	ix_enable=>vix_enable,mar_enable=>vmar_enable,mir_enable=>vmir_enable,
	sp_enable=>vsp_enable,ram_enable=>vram_enable,au_op=>vau_op,
	au_in_sel=>vau_in_sel,mir_sel=>vmir_sel,mar_sel=>vmar_sel,
	ram_read=>vram_read,ram_write=>vram_write,ir_read=>vir_read,
	ir_write=>vir_write,io_sel=>vio_sel,io_wd=>vio_wd,io_rd=>vio_rd,
	io_adress=>vio_adress,flag_reg=>vfreg,ir_output=>vir_output,outdata=>voutdata,
	write_io=>vwrite_io,input_data=>input_data,
	port0=>port0,port1=>port1,port2=>port2,port3=>port3,port4=>port4,port5=>port5,port6=>port6,port7=>port7,
	port8=>port8,port9=>port9,port10=>port10,port11=>port11,port12=>port12,port13=>port13,port14=>port14,port15=>port15
	);                    
	  outputdata<=voutdata;
	  
	--  io port is connected to seven segment display
	
	hex0:sevseg port map(port0(3 downto 0),sevsegl0);hex1:sevseg port map(port0(dataBus_size-1 downto 4),sevsegh0);
	hex2:sevseg port map(port1(3 downto 0),sevsegl1);hex3:sevseg port map(port1(dataBus_size-1 downto 4),sevsegh1);
	hex4:sevseg port map(port2(3 downto 0),sevsegl2);hex5:sevseg port map(port2(dataBus_size-1 downto 4),sevsegh2);
	hex6:sevseg port map(port3(3 downto 0),sevsegl3);hex7:sevseg port map(port3(dataBus_size-1 downto 4),sevsegh3);
	hex8:sevseg port map(port4(3 downto 0),sevsegl4);hex9:sevseg port map(port4(dataBus_size-1 downto 4),sevsegh4);
	hex10:sevseg port map(port5(3 downto 0),sevsegl5);hex11:sevseg port map(port5(dataBus_size-1 downto 4),sevsegh5);
	hex12:sevseg port map(port6(3 downto 0),sevsegl6);hex13:sevseg port map(port6(dataBus_size-1 downto 4),sevsegh6);
	hex14:sevseg port map(port7(3 downto 0),sevsegl7);hex15:sevseg port map(port7(dataBus_size-1 downto 4),sevsegh7);
	hex16:sevseg port map(port8(3 downto 0),sevsegl8);hex17:sevseg port map(port8(dataBus_size-1 downto 4),sevsegh8);
	hex18:sevseg port map(port9(3 downto 0),sevsegl9);hex19:sevseg port map(port9(dataBus_size-1 downto 4),sevsegh9);
	hex20:sevseg port map(port10(3 downto 0),sevsegl10);hex21:sevseg port map(port10(dataBus_size-1 downto 4),sevsegh10);
	hex22:sevseg port map(port11(3 downto 0),sevsegl11);hex23:sevseg port map(port11(dataBus_size-1 downto 4),sevsegh11);
	hex24:sevseg port map(port12(3 downto 0),sevsegl12);hex25:sevseg port map(port12(dataBus_size-1 downto 4),sevsegh12);
	hex26:sevseg port map(port13(3 downto 0),sevsegl13);hex27:sevseg port map(port13(dataBus_size-1 downto 4),sevsegh13);
	hex28:sevseg port map(port14(3 downto 0),sevsegl14);hex29:sevseg port map(port14(dataBus_size-1 downto 4),sevsegh14);
	hex30:sevseg port map(port15(3 downto 0),sevsegl15);hex31:sevseg port map(port15(dataBus_size-1 downto 4),sevsegh15);

	CONTROLER:cu port 
	map(clk=>clk,reset=>reset,int=>int,go=>go,
	flag_reg=>vfreg,ir_output=>vir_output,
	RF_address=>vRF_address,alu_op=>valu_op,shifter_op=>vshifter_op,
	to_freg=>vto_freg,to_acc_sel=>vto_acc_sel,to_RF_sel=>vto_RF_sel,
	memory_data_sel=>vmemory_data_sel,carry_sel=>vcarry_sel,
	rf_read=>vrf_read,rf_write=>vrf_write,acc_enable=>vacc_enable,
	freg_enable=>vfreg_enable,swap_reg_enable=>vswap_reg_enable,
	spc_sel=>vspc_sel,ir_adress=>vir_adress,pc_enable=>vpc_enable,
	ix_enable=>vix_enable,mar_enable=>vmar_enable,mir_enable=>vmir_enable,
	sp_enable=>vsp_enable,ram_enable=>vram_enable,au_op=>vau_op,
	au_in_sel=>vau_in_sel,mir_sel=>vmir_sel,mar_sel=>vmar_sel,
	ram_read=>vram_read,ram_write=>vram_write,ir_read=>vir_read,
	ir_write=>vir_write,io_sel=>vio_sel,io_wd=>vio_wd,
	io_rd=>vio_rd,io_write=>vwrite_io,io_adress=>vio_adress
	);

end arch;