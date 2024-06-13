library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity mensaje_memoria is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           seleccionar_mensaje : in  STD_LOGIC_VECTOR(1 downto 0);
           leer_escribir : in  STD_LOGIC;
           dato_escribir : in  INTEGER;
           dato_leer : out INTEGER;
		   indice :in  INTEGER);
end mensaje_memoria;

architecture Behavioral of mensaje_memoria is
    type memoria_array is array (0 to 99) of INTEGER;
    type memoria_mensajes is array (0 to 3) of memoria_array;
	type contador_array is array (0 to 3) of INTEGER range 0 to 99;

    signal memoria : memoria_mensajes := (others => (others => 0));
    signal contadores: contador_array := (others => 0);
    signal mensaje_seleccionado : INTEGER range 0 to 3 := 0;
	signal fin_mensajes : std_logic_vector (0 to 3) := (others => '0');
begin

    process(clk, reset)
    begin
        if reset = '1' then
            contadores <= (others => 0);
            mensaje_seleccionado <= 0;
            dato_leer <= 0;
        elsif rising_edge(clk) then
			case seleccionar_mensaje is
				when "00" =>	
				mensaje_seleccionado <= 0;
				when "01" =>	
				mensaje_seleccionado <= 1;
				when "10" =>	
				mensaje_seleccionado <= 2;
				when others =>	
				mensaje_seleccionado <= 3;
			end case;
			
            if leer_escribir = '1' then 
                --escribe
				if(fin_mensajes(mensaje_seleccionado) = '0') then
				memoria(mensaje_seleccionado)(contadores(mensaje_seleccionado)) <= dato_escribir;
                contadores(mensaje_seleccionado) <= contadores(mensaje_seleccionado) + 1;
                if contadores(mensaje_seleccionado) = 99 then
                    fin_mensajes(mensaje_seleccionado) <= '1';
                end if;
				end if;
            else
				--leer
                dato_leer <= memoria(mensaje_seleccionado)(indice);				
            end if;
        end if;
    end process;

end Behavioral;