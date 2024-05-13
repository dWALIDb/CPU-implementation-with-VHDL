library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity shift_reg is 
port
(
	input: in std_logic_vector(dataBus_size-1 downto 0);
	op: in std_logic_vector(shifter_ops-1 downto 0);
	extra: out std_logic;
	output: out std_logic_vector(dataBus_size-1 downto 0)
);
end shift_reg;
architecture arch of shift_reg is 
signal result : std_logic_vector(dataBus_size-1 downto 0);
signal E: std_logic;
begin
	process(op,input)
	begin
			case(op)is
			when"01" => result<='0'&input(dataBus_size-1 downto 1);E<='0';
			when"10" => result<=input(dataBus_size-2 downto 0)&'0';E<='0';
			when"11" => E<=input(dataBus_size-1);result<=input(dataBus_size-2 downto 0)&'0';
			when others =>result<=input; E<='0';
			end case;
	end process;
	extra<=E;
	output<=result;
end arch;