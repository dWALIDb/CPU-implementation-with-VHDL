library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package tools is 
	--size of address and data busses 
	constant dataBus_size : integer:=8;
	constant adressBus_size : integer:=8;--quite needed this way
	constant RF_adress : integer :=3;
	constant alu_ops: integer:=4;
	constant shifter_ops: integer:=2;
	constant opcode_size: integer:=5;
	
	subtype std8 is std_logic_vector(dataBus_size-1 downto 0);
	subtype std16 is std_logic_vector(adressBus_size-1 downto 0);
	type t_array2_std8 is array(1 downto 0)of std8;
	type t_array4_std8 is array(3 downto 0)of std8;
	type t_array2_std16 is array(1 downto 0)of std16;
	type t_array4_std16 is array(3 downto 0)of std16;
	
	type opcodes is (interrupt,decode,fetch,ldd,ldr,ldi,rla,rli,rlm,sta,str,ldsp,ldix,inc,incr,dec,decr,cp,cpr,
	cpm,sl,sr,rot,slr,srr,rotr,adr,adm,adi,sbr,sbm,sbi,swp,incix,decix,andr,andm,andi,orr,ori,orm,xori,xorr,xorm,
	cpl,neg,jp,jr,jpe,jpl,jpg,jre,jrl,jrg,jpne,jrne,jpc,jpnc,jpz,jpnz,jpp,jpn,jpo,jpno,jrc,jrnc,jrz,jrnz,jrp,jrn,
	jro,jrno,pushacc,popacc,call,ret,pushflag,popflag,pushreg,popreg,indexedld,indexedstr,di,ei,ina,inr,outa,outr,get,
	incrc,decrc,incc,decc,incrz,decrz,incz,decz,halt,nop,adix,sbix,andix,orix,xorix,cpix,pctoix,offsetix,pushix,popix);
	
	type t_ram is array(2**adressBus_size-1 downto 0)of std8;
	
	pure function to_index(val : std_logic_vector) return integer;
	pure function to_index_signed(val : std_logic_vector) return integer;
	pure function init_ram(file_placement : string) return t_ram;
	procedure nextstate(signal condition1,condition2 :in std_logic;signal state:out opcodes);
	
	procedure state_out(signal control_bus:in std_logic_vector(49 downto 0); 
	--data path's controlable signal
	signal RF_adress: out	std_logic_vector(RF_adress-1 downto 0);--3
	signal alu_op: out std_logic_vector(alu_ops-1 downto 0);--4
	signal shifter_op: out std_logic_vector(shifter_ops-1 downto 0);--2
	signal to_freg : out std_logic_vector(0 downto 0);--1
	signal to_acc_sel,to_RF_sel,memory_data_sel: out std_logic_vector(1 downto 0);--6
	signal carry_sel,rf_read,rf_write: out std_logic;--3
	signal acc_enable,freg_enable,swap_reg_enable: out std_logic;--3
	-- memory's controlable signals
	signal spc_sel:out std_logic_vector(0 downto 0);--1
	signal ir_adress:out std_logic_vector(1 downto 0);--2
	signal pc_enable,ix_enable,mar_enable,mir_enable,sp_enable,ram_enable: out std_logic;--6
	signal au_op:out std_logic_vector(1 downto 0);--2
	signal au_in_sel,mir_sel,mar_sel:out std_logic_vector(1 downto 0);--6
	signal ram_read,ram_write,ir_read,ir_write: out std_logic;--4
	-- io port's controlable signals 
	signal io_sel: out std_logic_vector(0 downto 0);--1
	signal io_wd, io_rd: out std_logic;--2
	signal io_adress:out std_logic_vector(3 downto 0)--4
	);
	
end package tools;

package body tools is 
	
	pure function to_index(val: std_logic_vector) return integer is 
	begin 
	return to_integer(unsigned(val));
	end function ;
	
	pure function to_index_signed(val: std_logic_vector)return integer is 
	begin
	return to_integer(signed(val));
	end function;
	
	pure function init_ram(file_placement:string) return t_ram is
	variable i :integer:=0;
	variable output : t_ram;
	variable data_read : bit_vector(dataBus_size-1 downto 0);  
	variable line_read : line;
	file my_file: text open read_mode is file_placement;
	begin 
		while not endfile(my_file) loop
			readline(my_file,line_read);
			read(line_read,data_read);
			output(i):=to_stdlogicvector(data_read);
			if (i<2**adressBus_size-1)then 
			i:=i+1;
			else exit;
			end if;
		end loop;
		return output;
	end function;

	procedure nextstate(signal condition1,condition2 :in std_logic;signal state:out opcodes) is
	begin
	if (condition1='1' and condition2='1') then state<=interrupt; else state<=fetch;
	end if;
	end procedure;
	
	procedure state_out(signal control_bus:in std_logic_vector(49 downto 0); 
	--data path's controlable signal
	signal RF_adress: out	std_logic_vector(RF_adress-1 downto 0);--3
	signal alu_op: out std_logic_vector(alu_ops-1 downto 0);--4
	signal shifter_op: out std_logic_vector(shifter_ops-1 downto 0);--2
	signal to_freg : out std_logic_vector(0 downto 0);--1
	signal to_acc_sel,to_RF_sel,memory_data_sel: out std_logic_vector(1 downto 0);--6
	signal carry_sel,rf_read,rf_write: out std_logic;--3
	signal acc_enable,freg_enable,swap_reg_enable: out std_logic;--3
	-- memory's controlable signals
	signal spc_sel:out std_logic_vector(0 downto 0);--1
	signal ir_adress:out std_logic_vector(1 downto 0);--2
	signal pc_enable,ix_enable,mar_enable,mir_enable,sp_enable,ram_enable: out std_logic;--6
	signal au_op:out std_logic_vector(1 downto 0);--2
	signal au_in_sel,mir_sel,mar_sel:out std_logic_vector(1 downto 0);--6
	signal ram_read,ram_write,ir_read,ir_write: out std_logic;--4
	-- io port's controlable signals 
	signal io_sel: out std_logic_vector(0 downto 0);--1
	signal io_wd,io_rd: out std_logic;--2
	signal io_adress:out std_logic_vector(3 downto 0)--4
	) is 
	begin
	pc_enable<=control_bus(49);--1
	acc_enable<=control_bus(48);--1
	mar_enable<=control_bus(47);--1
	mir_enable<=control_bus(46);--1
	sp_enable<=control_bus(45);--1
	freg_enable<=control_bus(44);--1
	ix_enable<=control_bus(43);--1
	swap_reg_enable<=control_bus(42);--1
	ram_enable<=control_bus(41);--1
	ram_read<=control_bus(40);--1
	ram_write<=control_bus(39);--1
	ir_adress<=control_bus(38 downto 37);--2---
	ir_read<=control_bus(36);--1
	ir_write<=control_bus(35);--1
	RF_adress<=control_bus(34 downto 32);--3--
	rf_read<=control_bus(31);--1
	rf_write<=control_bus(30);--1
	io_adress<=control_bus(29 downto 26);--4
	io_rd<=control_bus(25);--1
	io_wd<=control_bus(24);--1--
	alu_op<=control_bus(23 downto 20);--4
	au_op<=control_bus(19 downto 18);--2
	shifter_op<=control_bus(17 downto 16);--2--
	to_freg<=control_bus(15 downto 15);--1
	to_acc_sel<=control_bus(14 downto 13);--2
	to_RF_sel<=control_bus(12 downto 11);--2
	memory_data_sel<=control_bus(10 downto 9);--2--
	carry_sel<=control_bus(8);--1
	spc_sel<=control_bus(7 downto 7);--1
	au_in_sel<=control_bus(6 downto 5);--2
	mir_sel<=control_bus(4 downto 3);--2
	mar_sel<=control_bus(2 downto 1);--2
	io_sel<=control_bus(0 downto 0);--1
	end procedure;
	
	end package body tools;