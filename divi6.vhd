library ieee;
use ieee.std_logic_1164.all;

entity divi6 is
    port(
        clk: in std_logic;
        A, B: in std_logic_vector(15 downto 0); -- a de 8 bits
        result: out std_logic_vector(15 downto 0) -- b de 8 bits
    );
end entity;

architecture a_divi6 of divi6 is
	component SumRest16Bits is Port (
		A : in std_logic_vector(15 downto 0);
		B : in std_logic_vector(15 downto 0);
		Cin : in std_logic;
		Op : in std_logic;
		Res : out std_logic_vector(15 downto 0);
		Cout : out std_logic
	);
	end component;

signal Bveces : std_logic_vector(15 downto 0);

signal EASuma12 : std_logic_vector (15 downto 0);-- entrada A del sumador 12
signal EBSuma12 : std_logic_vector (15 downto 0);-- entrada B del sumador 12
signal Cin12 : std_logic;
signal Cout12: std_logic;
signal SalidaSum12 : std_logic_vector (15 downto 0);

signal Asuma : std_logic_vector (15 downto 0);-- entrada A del sumador 12
signal Contador : std_logic_vector (15 downto 0) := (others => '0');
signal Coutsuma: std_logic;
    
begin
  
Bveces <= A; --bveces recibe 40

Resta: SumRest16Bits port map (EASuma12 ,EBSuma12,Cin12,'1',Bveces,Cout12);

Suma : SumRest16Bits port map (Contador,Asuma,'0','0',result,Coutsuma);
	
process(Bveces,A,B) --  A / B 
	begin
		 if(Bveces >= B)then --2 es mayor a 4 		 
			EASuma12 <= Bveces;
			EBSuma12 <= B; --se va a restar a Bveces el valor de B
			Cin12 <= '1';
			Asuma <= "0000000000000001"; --sumamos 1 al contador
		 end if;
end process;
end architecture;