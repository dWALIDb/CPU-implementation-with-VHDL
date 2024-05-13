library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.tools.all;

entity AU is
port 
(
	input:in std_logic_vector(adressBus_size-1 downto 0);
	B: in std_logic_vector(dataBus_size-1 downto 0);
	op:in std_logic_vector(1 downto 0);
	output: out std_logic_vector(AdressBus_size-1 downto 0)
); 
end AU;
architecture arch of AU is 
signal result: std_logic_vector(AdressBus_size downto 0);
begin
	process(input,op,B)
	begin
		case(op)is 
		when"01"=>	result<='0'&input+B;--add /sub input and B
		when"00"=>	result<='0'&input;--pass input
		when"10"=>	result<='0'&input+1;--inc input
		when"11"=>	result<='0'&input-1;--dec input
		when others=> result<=(others=>'Z');
		end case;
	end process;
	output<=result(AdressBus_size-1 downto 0);
end arch;