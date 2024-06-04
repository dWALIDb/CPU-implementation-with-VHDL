library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity adress_mux2 is 
port
(
	inputs :in t_array2_std16;
	sel:in std_logic_vector(0 downto 0);
	output: out std16
);
end adress_mux2;
architecture arch of adress_mux2 is 
signal o:std16;
begin

	o<=inputs(to_index(sel));
	output<=o;

end arch;