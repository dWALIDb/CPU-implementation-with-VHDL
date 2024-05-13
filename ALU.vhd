library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.tools.all;

entity ALU is 
generic
(
	bus_size: integer:=dataBus_size
);
port
(
	A,B: in std_logic_vector(bus_size-1 downto 0);
	op :  in	std_logic_vector(3 downto 0);
	carry,zero		: out std_logic;
	sign,overflow	: out std_logic;
	output			: out std_logic_vector(bus_size-1 downto 0)
);
end ALU;
architecture arch of ALU is 
signal z_flag,c_flag,s_flag,o_flag,carry_in,carry_out:std_logic;
signal temporary: std_logic_vector(1 downto 0);
signal result : std_logic_vector(bus_size downto 0):=(others=>'0');
signal O1,O2: std_logic;

begin
	process(A,B,op)
	begin
		case(op)is
		when"0001"=> result<='0'&A + B;--add a & b
		when"0010"=> result<='0'&A + (not B)+1;-- sub a&b 
		when"0011"=> result<='0'&A + 1;--inc a
		when"0100"=> result<='0'&B + 1;--inc b
		when"0101"=> result<='0'&A - 1;--dec a
		when"0110"=> result<='0'&B - 1;--dec b
		when"0111"=> result<='0'&(A and B);--a and b
		when"1000"=> result<='0'&(A or B);--a or b
		when"1001"=> result<='0'&not a;--1's complement for a
		when"1010"=> result<=('0'&not a)+1;--2's complement
		when"1011"=> result<='0'&(A xor B);--a xor b
		when"1100"=> result<='0'&B; --pass b
		when others=> result<='0'&A; --pass a
		
		end case;
	end process;
		
	process(result,op,A)
	begin
	if(A="00000000" or result(dataBus_size-1 downto 0)="00000000")then z_flag<='1'; --carefull when using dec reg with accumulator as "0"
	else z_flag<='0';
	end if;
	end process;
	
	c_flag<=result(bus_size);
	s_flag<=result(bus_size-1);--accumulator size only
	o_flag<=(O1 or O2)when op="0010"else '0';--only sub works for signed number
	carry<=c_flag;
	zero<=z_flag;
	sign<=s_flag;
	O1<=A(7) and B(7) and (not s_flag);
	O2<=(not A(7)) and (not b(7)) and s_flag;
	overflow<=o_flag;
	output<=result(bus_size-1 downto 0);
end arch;