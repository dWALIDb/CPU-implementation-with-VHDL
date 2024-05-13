library IEEE;
use ieee.std_logic_1164.all;
use work.tools.all;

entity ram is 
generic
(
	file_path:string
);
port
(
	input: in std_logic_vector(dataBus_size-1 downto 0);
	adress_field: in std_logic_vector(adressBus_size-1 downto 0);
	rd,wd,cs,clk: in std_logic;
	output: out std_logic_vector(dataBus_size-1 downto 0)
);
end ram;
architecture arch of ram is 
signal data :t_ram:=init_ram(file_path);
--attribute ram_init_file :string;
--attribute ram_init_file of data: signal is file_path;
--use the function for imulation use the attribute for implementation
begin
write_data:process(input,wd,clk,cs,data)
	begin
	if (cs='1' and rising_edge(clk)) then 
			if wd='1' then data(to_index(adress_field))<=input;
			end if;
	end if;
	end process;
read_data:process(rd,cs,adress_field,data)
	begin
	if cs='1' then 
			if rd='1' then output<=data(to_index(adress_field));
			else output<=(others=>'0');
			end if;
	else output<= (others=>'0');
	end if;
	end process;
end arch;