library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity data_path is 
port
(
	clk,reset :in std_logic;
	ram_data,IO_data,IR_data: in std_logic_vector(dataBus_size-1 downto 0);
	RF_adress_field: in	std_logic_vector(RF_adress-1 downto 0);
	alu_op: in std_logic_vector(alu_ops-1 downto 0);
	shifter_op: in std_logic_vector(shifter_ops-1 downto 0);
	to_freg : in std_logic_vector(0 downto 0);
	to_acc_sel,to_RF_sel,memory_data_sel: in std_logic_vector(1 downto 0);
	carry_sel,rf_read,rf_write: in std_logic;
	acc_enable,freg_enable,swap_reg_enable: in std_logic;
	acc_value,flag_value,reg_value :out std_logic_vector(dataBus_size-1 downto 0 )
)
;end data_path;
architecture arch of data_path is
 
component data_mux2 is 
port(
	inputs :in t_array2_std8;
	sel:in std_logic_vector(0 downto 0);
	output: out std8
);
end component;
 
component data_mux4 is 
port(
	inputs :in t_array4_std8;
	sel:in std_logic_vector(1 downto 0);
	output: out std8
);
end component;

component generic_reg is 
generic(bus_size:integer:=8);
port(
	input: in std_logic_vector(bus_size-1 downto 0);
	clk,reset,enable: in std_logic;
	output:out std_logic_vector(bus_size-1 downto 0)
);
end component;

component ALU is 
port(
	A,B: in std_logic_vector(dataBus_size-1 downto 0);
	op :  in	std_logic_vector(3 downto 0);
	carry,zero		: out std_logic;
	sign,overflow	: out std_logic;
	output			: out std_logic_vector(dataBus_size-1 downto 0)
);
end component;

component reg_file is 
generic
(
	bus_size: integer:=8;
	adress_field: integer:=3
);
port(
	input : in std_logic_vector(dataBus_size-1 downto 0);
	reset,clk,rd,wd: in std_logic;
	adress: in std_logic_vector(RF_adress-1 downto 0);
	output: out std_logic_vector(dataBus_size-1 downto 0)
);
end component;

component comparator is
port(
	A,B: in std_logic_vector(dataBus_size-1 downto 0);--a and b are unsigned 
	G,L,E:out std_logic
);
end component;

component shift_reg is 
port
(
	input: in std_logic_vector(dataBus_size-1 downto 0);
	op: in std_logic_vector(shifter_ops-1 downto 0);
	extra: out std_logic;
	output: out std_logic_vector(dataBus_size-1 downto 0)
);
end component;

signal into_acc,acc_out,shifter_out,alu_out,into_rf,rf_out,selected_data,swap_reg_out,flag_in: std_logic_vector(dataBus_size-1 downto 0);
signal acc_sel_inputs,rf_sel_inputs,memory_data_inputs: t_array4_std8;
signal flag_in_sel :t_array2_std8;
signal o,s,z,c,g,e,l,carry_decision,alu_carry,shifter_carry : std_logic;
begin

	--selection of data register,IR or straight from memory
	memory_data_inputs(0)<=ram_data;
	memory_data_inputs(1)<=IR_data;
	memory_data_inputs(2)<=rf_out;
	memory_data_inputs(3)<=(others=>'0');

	MEMORY_DATA:data_mux4 port map(inputs=>memory_data_inputs,sel=>memory_data_sel,output=>selected_data);

	--accumulator gets data from reg , ram, ir,last computation or IO data
	ACCUMULATOR:generic_reg generic map(bus_size=>dataBus_size)port map(clk=>clk, enable=>acc_enable, reset=>reset, input=>into_acc,output=>acc_out);
	
	--selection of acc inputs
	acc_sel_inputs(0)<=shifter_out;
	acc_sel_inputs(1)<=selected_data;
	acc_sel_inputs(2)<=IO_data;
	acc_sel_inputs(3)<=(others=>'0');

	ACC_SEL:data_mux4 port map(inputs=>acc_sel_inputs,sel=>to_acc_sel,output=>into_acc);
	acc_value<=acc_out;
	
		--rf gets data from acc,from other reg of rf,IR ,alu or ram data
	REGISTER_FILE:reg_file port map(input=>into_rf,clk=>clk,reset=>reset,rd=>rf_read,wd=>rf_write,adress=>rf_adress_field,output=>rf_out);
	
	 --selection of rf inputs
	rf_sel_inputs(0)<=selected_data;
	rf_sel_inputs(1)<=shifter_out;--used to store acc to reg too
	rf_sel_inputs(2)<=io_data;
	rf_sel_inputs(3)<=swap_reg_out;
	
	RF_SEL:data_mux4 port map(inputs=>rf_sel_inputs,sel=>to_rf_sel,output=>into_rf);
	
	SWAP_REG:generic_reg generic map(bus_size=>dataBus_size)port map(input=>rf_out,clk=>clk,reset=>reset,enable=>swap_reg_enable,output=>swap_reg_out);
	reg_value<=rf_out;
	
	-- alu gets data from register ,ram data or IR	
	ALUnit:ALU port map(A=>acc_out,B=>selected_data,op=>alu_op,carry=>alu_carry,zero=>z,overflow=>o,sign=>s,output=>alu_out);
	
	-- comparator gets inputs from register , ram data or IR and compares it to acc 
	COMPAR:comparator port map(A=>acc_out,B=>selected_data,G=>g,L=>l,E=>e);
	
	--flag reg is obtained from pop f or mostly from alu and comparator carry flag can be affected by rotate through carry of shifter 
	flag_in_sel(0)<=('0'&g&e&l&z&carry_decision&o&s);
	flag_in_sel(1)<=selected_data;
	FLAG_SELECTION: data_mux2 port map(inputs=>flag_in_sel,output=>flag_in,sel=>to_freg);
	
	FLAGS:generic_reg generic map(bus_size=>dataBus_size)port map(input=>flag_in,clk=>clk,reset=>reset,enable=>freg_enable,output=>flag_value);
	
	--shift reg recieves alu output directly
	SHIFTER:shift_reg port map(input=>alu_out,op=>shifter_op,extra=>shifter_carry,output=>shifter_out);
		-- carry selection for alu or shifter
		carry_decision<=shifter_carry or alu_carry;
	--carry_decision<=shifter_carry when(carry_sel='1') else alu_carry;
end arch;