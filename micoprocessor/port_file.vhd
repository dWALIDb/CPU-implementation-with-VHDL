library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity port_file is 
port 
( 
	input : in std_logic_vector(dataBus_size-1 downto 0);
	reset,clk,rd,wd: in std_logic;
	adress: in std_logic_vector(3 downto 0);
	output: out std_logic_vector(dataBus_size-1 downto 0);
	port0,port1,port2,port3,port4,port5,port6,port7:out std_logic_vector(dataBus_size-1 downto 0);
	port8,port9,port10,port11,port12,port13,port14,port15:out std_logic_vector(dataBus_size-1 downto 0)
);
end port_file;
architecture arch of port_file is
type custom_array is array(15 downto 0) of std_logic_vector(dataBus_size-1 downto 0);
signal locations: custom_array;
begin
	write_data:process(clk,reset,wd,adress)
	begin
	if reset='1' then locations<=(others=>(others=>'0'));
	elsif rising_edge(clk) then 
		if wd='1' then locations(to_index(adress))<=input; --write to rf
		end if;
	end if;
	end process;
	read_data:process(rd,adress,locations)
	begin
	if rd='1' then output<=locations(to_index(adress));
	else output<=(others=>'0');
	end if;
	end process;
	--we want the values of the ports to be visible but not changable :)
	port0<=locations(0);
	port1<=locations(1);
	port2<=locations(2);
	port3<=locations(3);
	port4<=locations(4);
	port5<=locations(5);
	port6<=locations(6);
	port7<=locations(7);
	port8<=locations(8);
	port9<=locations(9);
	port10<=locations(10);
	port11<=locations(11);
	port12<=locations(12);
	port13<=locations(13);
	port14<=locations(14);
	port15<=locations(15);
	
end arch;
