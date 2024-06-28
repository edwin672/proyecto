library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
entity ROM_Instruccione is port(
	clk: in std_logic;
	clr: in std_logic;
	enable: in std_logic;
	read_m : in std_logic; 
	address: in std_logic_vector(7 downto 0);
	data_out : out std_logic_vector(23 downto 0)
);
end ROM_Instruccione; 

architecture a_ROM of ROM_Instruccione is  
	
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
	--instruccion OP_READT para leer el teclado
	constant OP_READT: std_logic_vector(5 downto 0):= "010111";
	--instruccion para leer el mensaje que se guardo en la memoria
	constant OP_READM: std_logic_vector(5 downto 0):= "011000";
	--instruccion ler del registro de proposito general A
	constant OP_READA: std_logic_vector(5 downto 0):= "011001";
	
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
		--0 leer de teclado 
		0 => OP_READT & "000000000000000000",		
		--intruccion i load en RA
		--10 => OP_LOAD & RPG_A & "0000000000000000",
		--intruccion leer de RA
		--10 => OP_READA & "000000000000000000",
		10 => OP_READM & "000000000000000000",
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
					