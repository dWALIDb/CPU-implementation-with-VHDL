library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity io_port is 
port(
	clk,reset,io_wd,io_rd,io_write:in std_logic;
	io_sel: in std_logic_vector(0 downto 0);
	reg,acc,input_data :in std_logic_vector(DataBus_size-1 downto 0);
	io_adress:in std_logic_vector(3 downto 0);
	io_out:out std_logic_vector(dataBus_size-1 downto 0);
	port0,port1,port2,port3,port4,port5,port6,port7:out std_logic_vector(dataBus_size-1 downto 0);
	port8,port9,port10,port11,port12,port13,port14,port15:out std_logic_vector(dataBus_size-1 downto 0)
);
end io_port;
architecture arch of io_port is 

component port_file is 
port 
( 
	input : in std_logic_vector(dataBus_size-1 downto 0);
	reset,clk,rd,wd: in std_logic;
	adress: in std_logic_vector(3 downto 0);
	output: out std_logic_vector(dataBus_size-1 downto 0);
	port0,port1,port2,port3,port4,port5,port6,port7:out std_logic_vector(dataBus_size-1 downto 0);
	port8,port9,port10,port11,port12,port13,port14,port15:out std_logic_vector(dataBus_size-1 downto 0)
);
end component;

component data_mux2 is 
port
(
	inputs :in t_array2_std8;
	sel:in std_logic_vector(0 downto 0);
	output: out std8
);
end component;

	signal data_sel:t_array2_std8;
	signal io_in,i:std_logic_vector(dataBus_size-1 downto 0);

begin
	--select input to ioport 
	data_sel(0)<=reg;
	data_sel(1)<=acc;
	io_data: data_mux2 port map(inputs=>data_sel,sel=>io_sel,output=>io_in);
	--the actual port 
	i<=input_data when io_write='1' else io_in;
	in_out_port:port_file
	port map(clk=>clk,reset=>reset,adress=>io_adress,rd=>io_rd,wd=>io_wd,input=>i,output=>io_out,
	port0=>port0,port1=>port1,port2=>port2,port3=>port3,port4=>port4,port5=>port5,port6=>port6,port7=>port7,
	port8=>port8,port9=>port9,port10=>port10,port11=>port11,port12=>port12,port13=>port13,port14=>port14,port15=>port15);
end arch;