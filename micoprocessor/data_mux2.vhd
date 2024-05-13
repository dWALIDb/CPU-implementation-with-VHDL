library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity data_mux2 is 
port
(
	inputs :in t_array2_std8;
	sel:in std_logic_vector(0 downto 0);
	output: out std8
);
end data_mux2;
architecture arch of data_mux2 is 
signal o:std8;
begin

	o<=inputs(to_index(sel));
	output<=o;

end arch;