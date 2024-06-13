library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ROM is port(
	clk: in std_logic;
	clr: in std_logic;
	enable: in std_logic;
	read_m : in std_logic; 
	address: in std_logic_vector(7 downto 0);
	data_out : out std_logic_vector(23 downto 0)
);
end ROM;

architecture a_ROM of ROM is
	
	constant OP_NOP:  std_logic_vector(5 downto 0):=  "000000";
	constant OP_LOAD: std_logic_vector(5 downto 0):=  "000001";
	constant OP_ADDI: std_logic_vector(5 downto 0):=  "000010";
	constant OP_DPLY: std_logic_vector(5 downto 0):=  "000011";
	constant OP_ADEC: std_logic_vector(5 downto 0):=  "000100";
	constant OP_BNZ: std_logic_vector(5 downto 0):=   "000101";
	constant OP_BZ: std_logic_vector(5 downto 0):=    "000110";
	constant OP_BS: std_logic_vector(5 downto 0):=    "000111";
	constant OP_BNC: std_logic_vector(5 downto 0):=   "001000";
	constant OP_BC: std_logic_vector(5 downto 0):=    "001001";
	constant OP_BNV: std_logic_vector(5 downto 0):=   "001010";
	constant OP_BV: std_logic_vector(5 downto 0):=    "001011";
	constant OP_HALT: std_logic_vector(5 downto 0):=  "001100";
	constant OP_ADD: std_logic_vector(5 downto 0):=   "001101";
	constant OP_SUB: std_logic_vector(5 downto 0):=   "001110";
	constant OP_MULT: std_logic_vector(5 downto 0):=  "011111";
	constant OP_DIV: std_logic_vector(5 downto 0):=   "010000";
	constant OP_MULTI: std_logic_vector(5 downto 0):= "010001";
	constant OP_DIVI: std_logic_vector(5 downto 0):=  "010010";
	constant OP_COMP1: std_logic_vector(5 downto 0):= "010011";
	constant OP_COMP2: std_logic_vector(5 downto 0):= "010100";
	constant OP_JMP: std_logic_vector(5 downto 0):=   "010101";
	constant OP_JALR: std_logic_vector(5 downto 0):=  "010110";

	--Control RPG
	constant RPG_A: std_logic_vector(1 downto 0):= "00";
	constant RPG_B: std_logic_vector(1 downto 0):= "01";
	constant RPG_C: std_logic_vector(1 downto 0):= "10"; 
	constant RPG_D: std_logic_vector(1 downto 0):= "11";

	--TIPO I |OP CODE(6)| REGISTRO DESTINO(2) | DIRECCION DE MEMORIA (16) Y OP A REALIZAR|
	--TIPO R |OP CODE(6)| REGISTRO DESTINO(2) | DIRECCION DE MEMORIA (16)|
	--TIPO J |OP CODE(6)| DIRECCION DE MEMORIA (18)|
	type ROM_Array is array (0 to 255) of std_logic_vector(23 downto 0);
	constant content: ROM_Array := (
		0 => OP_LOAD&"00"&"00000000"&"11110111",--LOAD W,RA
		1 => OP_ADDI&"00"&"000000000101"&"0110",--ADDI RA,5
		2 => OP_DPLY&"00"&"0000000000000000",--Rdisplay<- RA
		3 => OP_LOAD&"01"&"0000000011110110",--LOAD i,RB
		4 => OP_ADEC&"01"&"000000000000"&"0011",-- DEC RB
		5 => OP_NOP&"000000000000000000", --NOP
		6 => OP_BNZ&"000000000011111101", --BNZ,-3
		7 => OP_LOAD&"00"&"0000000011111000",--LOAD X,RA
		8 => OP_ADDI&"00"&"000000000110"&"0110",--ADDI RA,6
		9 => OP_DPLY&"00"&"0000000000000000",--Rdisplay<- RA
		10 =>OP_LOAD&"01"&"0000000011110110",--LOAD i,RB
		11=> OP_ADEC&"01"&"000000000000"&"0011",-- DEC RB
		12 =>OP_NOP&"000000000000000000",--NOP
		13 =>OP_BNZ&"000000000011111101", --BNZ,-3
		14 =>OP_LOAD&"00"&"0000000011111001",--LOAD Y,RA
		15 =>OP_ADDI&"00"&"000000000111"&"0110",--ADDI RA,7
		16 =>OP_DPLY&"00"&"0000000000000000",--Rdisplay<- RA
		17 =>OP_LOAD&"01"&"0000000011110110",--LOAD i,RB
		18=> OP_ADEC&"01"&"000000000000"&"0011",-- DEC RB
		19 =>OP_NOP&"000000000000000000",--NOP
		20 =>OP_BNZ&"000000000011111101", --BNZ,-3
		21 =>OP_HALT&"000000000000000000",

		--Ecuacion a) 17X + 25Y - W/4
		23 => OP_LOAD&RPG_A&"00000000"&"11111000", --LOAD X, RA
		24 => OP_MULTI&RPG_A&"000000010001"&"1101", --MULTI RA, 17 RES=
		25 => OP_LOAD&RPG_B&"00000000"&"11111001", --LOAD Y, RB
		26 => OP_MULTI&RPG_B&"000000011001"&"1101", --MULTI RB, 25 RES=
		27 => OP_LOAD&RPG_C&"00000000"&"11110111", --LOAD W, RC
		28 => OP_DIVI&RPG_C&"000000000100"&"1110", --DIVI RC, 4 RES=250
		29 => OP_ADD&RPG_A&RPG_B&"0000000000"&"0110", --ADD RA + RB, RA RES=
		30 => OP_SUB&RPG_A&RPG_C&"0000000000"&"0111", --SUB RA - RC, RA RES=

		--Ecuacion b) 10X^2 + 30X - Z/2
		47 => OP_LOAD&RPG_A&"00000000"&"11111000", --LOAD X, RA
		48 => OP_LOAD&RPG_B&"00000000"&"11111000", --LOAD X, RB
		49 => OP_MULT&RPG_A&RPG_B&"0000000000"&"1101", --MULT RA * RA, RA RES=X*X
		50 => OP_MULTI&RPG_A&"000000001010"&"1101", --MULTI RA, 10 RES=10*X*X
		51 => OP_MULTI&RPG_B&"000000011110"&"1101", --MULTI RB, 30 RES=30*X
		52 => OP_LOAD&RPG_C&"00000000"&"11111010", --LOAD Z, RC
		53 => OP_DIVI&RPG_C&"000000000010"&"1110", --DIVI RC, 2 RES=Z/2
		54 => OP_ADD&RPG_A&RPG_B&"0000000000"&"0110", --ADD RA + RB, RA RES=10*X*X + X*X
		55 => OP_SUB&RPG_A&RPG_C&"0000000000"&"0111", --SUB RA - RC, RA RES= 10*X*X + X*X - Z/2

		--Ecuacion c) -X^3 - 7Z +W/10
		71 => OP_LOAD&RPG_A&"00000000"&"11111000", --LOAD X, RA
		72 => OP_LOAD&RPG_B&"00000000"&"11111000", --LOAD X, RB
		73 => OP_MULT&RPG_A&RPG_B&"0000000000"&"1101", --MULT RA * RA, RA RES=X*X
		74 => OP_MULT&RPG_A&RPG_B&"0000000000"&"1101", --MULT RA * RA, RA RES=X*X*X
		75 => OP_LOAD&RPG_C&"00000000"&"11111010", --LOAD Z, RC
		76 => OP_MULTI&RPG_C&"000000000111"&"1101", --MULTI RC, 7 RES=7*Z
		77 => OP_LOAD&RPG_B&"00000000"&"11110111", --LOAD W, RC
		78 => OP_DIVI&RPG_B&"000000001010"&"1110", --DIVI RB, 10 RES=W/10
		79 => OP_SUB&RPG_B&RPG_C&"0000000000"&"0111", --SUB RB - RC, RB=W/10 - 7*Z
		80 => OP_SUB&RPG_B&RPG_A&"0000000000"&"0111", --SUB RB - RA, RB RES= W/10 - 7*Z - X^3

		--Ecuacion d) desplegar 0000 en el display
		246 => x"000012",-- 3 en decimal i
		247 => x"0003EB", -- 1003 en decimal W
		248 => x"000065", -- 101 en decimal X
		249 => x"000046", -- 70 en decimal Y 
		250 => x"000032", -- 50 en decimal Z
		251 => x"000012", -- 18 en decimal M
		252 => x"000007", -- 7 en decimal N 
		253 => x"000017", -- 23 en decimal O 
		254 => x"000037", -- 55 en decimal P 
		255 => x"00004D", -- 77 en decimal Q
		others => x"FFFFFF"
	);
begin
	process(clk,clr,read_m,address)
	begin
		if(clr='1') then	
			data_out<=(others=>'Z');
		elsif(clk'event and clk='1') then
			if(enable='1') then 
				if(read_m='1') then
					data_out<=content(conv_integer(address));
				else
					data_out<=(others=>'Z');
				end if;
			end if;
		end if;
	end process;
end a_ROM;
					