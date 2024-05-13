library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity generic_reg is 
generic
(
	constant bus_size:integer :=8);
port 
(
	input: in std_logic_vector(bus_size-1 downto 0);
	clk,reset,enable: in std_logic;
	output:out std_logic_vector(bus_size-1 downto 0)
);
end generic_reg;
architecture arch of generic_reg is 
signal q:std_logic_vector(bus_size-1 downto 0);
begin
	output<=q;
	process(clk,reset,enable)
	begin
	if(reset='1') then q<=(others=>'0');
	elsif ((clk'event and clk='1')and enable='1') then q<=input;
	end if;
	end process;

end arch;
