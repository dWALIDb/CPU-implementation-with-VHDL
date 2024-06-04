library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity reg_file is 
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
end reg_file;
architecture arch of reg_file is
type custom_array is array(2**adress_field-1 downto 0) of std_logic_vector(bus_size-1 downto 0);
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
	
end arch;
