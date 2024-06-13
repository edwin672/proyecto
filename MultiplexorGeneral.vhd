library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
----------------------------------------------------------

entity MultiplexorGeneral is port(
	S0: in std_logic;
	S1: in std_logic;
	PcOut: out std_logic_vector(7 downto 0)
);
end MultiplexorGeneral;

architecture Procesos of MultiplexorGeneral is

signal selector : std_logic_vector(1 downto 0);

begin 
selector <=S0&S1;
--se declaran las 4 operaciones que haran
--00 sea primer ecuacion
--00 sea segunda ecuacion
--00 sea tercera ecuacion
--00 sea salida en display 0000

process(selector)
begin 
	case selector is
		when "00" => --23
			PcOut <= "00010111";
		when "01" =>--47
			PcOut <= "00101111";
		when "10" =>--71
			PcOut <= "01000111";
		when others =>--95
			PcOut <= "01011111";
	end case;
end process;

end Procesos;