library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity memory_unit is 
generic
(
	file_path:string
);
port 
(
	clk,reset	: in std_logic;
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
end memory_unit;
architecture arch of memory_unit is

component reg_file is 
generic
(
	bus_size: integer:=8;
	adress_field: integer:=3
);
port 
( 
	input : in std_logic_vector(bus_size-1 downto 0);
	reset,clk,rd,wd: in std_logic;
	adress: in std_logic_vector(adress_field-1 downto 0);
	output: out std_logic_vector(bus_size-1 downto 0)
);
end component;

component data_mux4 is  
port
(
	inputs :in t_array4_std8;
	sel:in std_logic_vector(1 downto 0);
	output: out std16
);
end component;

component generic_reg is 
generic
(
	constant bus_size:integer :=8);
port 
(
	input: in std_logic_vector(bus_size-1 downto 0);
	clk,reset,enable: in std_logic;
	output:out std_logic_vector(bus_size-1 downto 0)
);
end component;

component ram is 
generic
(
	file_path:string
);
port
(
	input: in std_logic_vector(dataBus_size-1 downto 0);
	adress_field: in std_logic_vector(adressBus_size-1 downto 0);
	rd,wd,cs,clk: in std_logic;
	output: out std_logic_vector(dataBus_size-1 downto 0)
);
end component;

component AU is 
port 
(
	input:in std_logic_vector(adressBus_size-1 downto 0);
	B: in std_logic_vector(dataBus_size-1 downto 0);
	op:in std_logic_vector(1 downto 0);
	output: out std_logic_vector(AdressBus_size-1 downto 0)
); 
end component;

component adress_mux2 is 
port
(
	inputs :in t_array2_std16;
	sel:in std_logic_vector(0 downto 0);
	output: out std16
);
end component;

component adress_mux4 is 
port
(
	inputs :in t_array4_std16;
	sel:in std_logic_vector(1 downto 0);
	output: out std16
);
end component;

signal spc_input,to_au,pc_out,sp_out,ix_out,last_operation,mar_in,mar_out: std_logic_vector(adressBus_size-1 downto 0);
signal ir_out,ram_out: std_logic_vector(dataBus_size-1 downto 0);
signal mir_in,mir_out: std_logic_vector(databus_size-1 downto 0);
signal pointers :t_array2_std16;
signal au_in,to_ram_adress :t_array4_std16;
signal to_ram_data: t_array4_std8;
begin
	--mux to select input to sp ix pc  either ir or last operation of au
	pointers(0)<=last_operation;
	pointers(1)<=ir_out;
	pointers_sel:adress_mux2 port map(inputs=>pointers,sel=>spc_sel,output=>spc_input);
	--pc sp and ix registers they are connected to arithmetic unit  
	program_counter: generic_reg generic map(bus_size=>adressBus_size)port map(clk=>clk,reset=>reset,enable=>pc_enable,input=>spc_input,output=>pc_out);
	stack_pointer: generic_reg generic map(bus_size=>adressBus_size)port map(clk=>clk,reset=>reset,enable=>sp_enable,input=>spc_input,output=>sp_out);
	index_reg: generic_reg generic map(bus_size=>adressBus_size)port map(clk=>clk,reset=>reset,enable=>ix_enable,input=>spc_input,output=>ix_out);
	-- au input from pc sp ix
	au_in(0)<=pc_out;
	au_in(1)<=sp_out;
	au_in(2)<=ix_out;
	au_in(3)<=(others=>'0');
	sel:adress_mux4 port map(inputs=>au_in,sel=>au_in_sel,output=>to_au);
	--au is responsible for changing ix sp pc 
	arthmetic_unit:AU port map(input=>to_au,B=>ir_out,op=>au_op,output=>last_operation);
	--mux to select adress of ram of one of the pointers
	to_ram_adress(0)<=pc_out;
	to_ram_adress(1)<=ix_out;
	to_ram_adress(2)<=sp_out;
	to_ram_adress(3)<=ir_out;
	ram_adress_sel:adress_mux4 port map(inputs=>to_ram_adress,sel=>mar_sel,output=>mar_in);
	--mux to select input data to ram
	to_ram_data(0)<=rf;
	to_ram_data(1)<=acc;
	to_ram_data(2)<=pc_out;
	to_ram_data(3)<=flag_reg;
	ram_in_sel: data_mux4 port map(inputs=>to_ram_data,sel=>mir_sel,output=>mir_in);
	--mar and mir are the adress and input data to ram
	memory_adress_reg: generic_reg generic map(bus_size=>adressBus_size)port map(clk=>clk,reset=>reset,enable=>mar_enable,input=>mar_in,output=>mar_out);
	memory_input_reg: generic_reg generic map(bus_size=>dataBus_size)port map(clk=>clk,reset=>reset,enable=>mir_enable,input=>mir_in,output=>mir_out);
	-- memory is a ram clocked input but unclocked output
	ram_mem: ram generic map (file_path=>file_path)port map(clk=>clk,rd=>ram_read,wd=>ram_write,cs=>ram_enable,input=>mir_out,adress_field=>mar_out,output=>ram_out);
	-- ir gets the output of the ram and it is a reg_file 3 bytes for isntruction and 1 byte for interrupt adress
	instruction_register:reg_file generic map(bus_size=>dataBus_size,adress_field=>2)port map(clk=>clk,reset=>reset,wd=>ir_write,rd=>ir_read,adress=>ir_adress,input=>ram_out,output=>ir_out);
	-- op_code
	op_code<=ir_out;
	-- ram_data
	ram_data<=ram_out;
	-- ir_pointer used for register file and io port
	ir_point<=ir_out(dataBus_size-1 downto 0);
end arch;

