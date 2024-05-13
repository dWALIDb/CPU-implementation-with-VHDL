library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

--this comparison is signed comparison so beware when using the cp instructions

entity comparator is 
generic
(
	bus_size : integer :=dataBus_size
);
port 
(
	A,B: in std_logic_vector(bus_size-1 downto 0);--a and b are unsigned 
	G,L,E:out std_logic
);
end comparator;
architecture arch of comparator is 

begin
	process(A,B)
	begin
	if(to_index(A)>to_index(B)) then G<='1';
									 L<='0';
									 E<='0';
	elsif(to_index(A)=to_index(B)) then G<='0';
										L<='0';
										E<='1';
	else G<='0';
		 L<='1';
		 E<='0';
	end if;
	end process;

end arch;