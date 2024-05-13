library IEEE;     
use ieee.std_logic_1164.all;
use work.tools.all;

entity memory is 
port
(
	clk,reset,pc_enable,index_reg_enable,sp_enable,mar_enable,interupt_reg_enable,ir_enable: in std_logic;
	au_op: in std_logic_vector(1 downto 0);
	to_au_sel: in std_logic_vector(1 downto 0);
	to_pc_sel: in std_logic;
	to_pointers_sel: in std_logic;
	ram_data_sel: in std_logic_vector(1 downto 0);
	mar_adress_sel: in std_logic_vector(1 downto 0);
	ir_part: in std_logic_vector(1 downto 0);
	to_cu: out std_logic_vector(5 downto 0);
	ir_data,ram_data: out std_logic_vector(dataBus_size-1 downto 0)
);
end memory;
architecture arch of memory is 
signal au_out,au_in,pc_input:std_logic_vector(adressBus_size-1 downto 0);

component generic_reg is 
generic
(
	constant bus_size:integer :=dataBus_size
);
port 
(
	input: in std_logic_vector(dataBus_size-1 downto 0);
	clk,reset,enable: in std_logic;
	output:out std_logic_vector(dataBus_size-1 downto 0)
);
end component;

begin 
	PROGRAM_COUNTER:generic_reg generic map (bus_size=>adressBus_size) port map(clk=>clk,reset=>reset,input=>pc_input,enable=>pc_enable,output=>au_in);
end arch;