library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library machxo2;
use machxo2.all; 

entity led_blink is
    Port (
        LED : out STD_LOGIC;
        ROW : in STD_LOGIC_VECTOR(3 downto 0);
        COL : out STD_LOGIC_VECTOR(3 downto 0);
        MatCol : out STD_LOGIC_VECTOR(15 downto 0);
        MatRow : out STD_LOGIC_VECTOR(7 downto 0)
    );
end led_blink;

architecture Behavioral of led_blink is
    component OSCH
        generic (NOM_FREQ: string);
        port (STDBY: in std_logic; OSC: out std_logic);
    end component;
	
    attribute NOM_FREQ: string;
    attribute NOM_FREQ of OSCinst0: label is "8.31"; 

    constant MAX_COUNT : integer := 4000000;
    signal clk : std_logic := '0';
    signal count : integer range 0 to 4000000; 

    constant MAX_COUNT2 : integer := 6000;
    signal count_cols: integer range 0 to 6000;
    signal clk_cols : std_logic := '0';

    signal clk_0 : std_logic := '0';
    signal clk_1 : std_logic := '0';

    signal current_col : integer := 0;
    signal key_detected : integer := 0;
    signal prev_key_detected : integer := 0;
    signal stored_key : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal display_enable : std_logic := '0';

    signal prueba : std_logic := '0';

    signal MatrizRow : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal MatrizCol : STD_LOGIC_VECTOR(15 downto 0) := "0111111111111111";
    type matrix_array is array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
    

    signal row_counter : integer range 0 to 7 := 0;
    signal letraSelect : matrix_array;
	signal guardar : integer := 0;
	signal empezar: std_logic := '0';
	signal parar : std_logic := '0';
	signal leido_rom : std_logic_vector(7 downto 0):= (others => '0');
	signal direccion : integer range 0 to 512;
	type memoria_array is array (0 to 99) of INTEGER;
	type memoria_mensajes is array (0 to 3) of memoria_array;
	signal mensajes : memoria_mensajes := (others => (others => 0));
	signal mensaje_moviendose : memoria_array := (others => 0);
	signal contador_posi : integer := 0;
	
	type fila is array (7 downto 0) of std_logic;
	type filas_mensaje is array (0 to 99) of fila;	
	
	signal filas_moviendose  : filas_mensaje;

component ROM_C is port(
	clk: in std_logic;
	enable: in std_logic;
	address: in integer range 0 to 512; --Direccion de entrada en entero
	data : out std_logic_vector(7 downto 0) --Columna de la matriz de leds
	
);
end component;

begin

OSCinst0: OSCH generic map("26.60") port map('0', clk);
rom : ROM_C port map(clk_cols,'1',direccion,leido_rom);




process(clk)
begin
    if (rising_edge(clk)) then
        if (count_cols < MAX_COUNT2) then
            count_cols <= count_cols + 1;
        else
            count_cols <= 0;
            clk_cols <= not clk_cols;
        end if;
    end if;
end process;

process(clk)
begin
    if (rising_edge(clk)) then
        if (count < MAX_COUNT) then
            count <= count + 1;
        else
            count <= 0;
            clk_0 <= not clk_0;
        end if;
    end if;
end process;
-------------------------------------relojs----------------------------------
mensajes(0)(0) <= 0;
mensajes(0)(1) <= 8;
mensajes(0)(2) <= 16;
--mensaje declarado que muestre A B C
process(clk_cols, clk_0) 
begin 

if rising_edge(clk_cols) then
	if(empezar = '1') then	
		
		direccion <= mensajes(0)(contador_posi) + row_counter;            
		MatrizRow <= leido_rom; 
		
	end if;
	if(empezar = '0')then
		MatrizRow <= "00000000"; 
	end if;
	if rising_edge (clk_0) then
		if(contador_posi = 3) then
			contador_posi <= 0;
		else
			contador_posi <= contador_posi +1;
		end if;
	end if;
end if;

end process;
process(clk_cols)
begin
    if rising_edge(clk_cols) then
        case current_col is
            when 0 =>
                COL <= "1000";
                if ROW(1) = '1' then 
                    key_detected <= 48; 
                end if;
                if ROW(2) = '1' then 
                    key_detected <= 24; 
                end if;
                if ROW(3) = '1' then 
                    key_detected <= 0;
					empezar <= '0';					
                end if;
            when 1 =>
                COL <= "0100";
                if ROW(0) = '1' then 
                    key_detected <= 72; 
                end if;
                if ROW(1) = '1' then 
                    key_detected <= 56; 
                end if;
                if ROW(2) = '1' then 
                    key_detected <= 32; 
                end if;
                if ROW(3) = '1' then 
                    key_detected <= 8; 
                end if;
            when 2 =>
                COL <= "0010";
                if ROW(1) = '1' then 
                    key_detected <= 64; 
                end if;
                if ROW(2) = '1' then 
                    key_detected <= 40; 
                end if;
                if ROW(3) = '1' then 
                    key_detected <= 16; 
                end if;
            when 3 =>
                COL <= "0001";
                if ROW(0) = '1' then 
                    row_counter <= 0;
                    empezar <= '1';                    
                    MatrizCol <= "0111111111111111";
                end if;
            when others =>
                parar <= '1';
        end case;
        
        if current_col = 3 then
            current_col <= 0;
        else
            current_col <= current_col + 1;
        end if;

        if empezar = '1' then 
            if row_counter = 7 then
                row_counter <= 0;
            else
                row_counter <= row_counter + 1; 
            end if;
            MatrizCol <= MatrizCol(0) & MatrizCol(15 downto 1);
             
        end if;
    end if;
end process;


process(clk_0)--genera el reloj cada segundo, cada que cambie un segundo sube la letra al arreglo auxiliar y hace un movimiento a la izquierda  
begin
    if(rising_edge(clk_0)) then
        prueba <= not prueba;
    end if;
end process;

process(clk_0)
begin
if(empezar = '1') then
	--aqui va que empiece con un for a hacer el cargado y corrimiento
else
	--aqui iria que deje de mostrar cosas o que deje de moverse
end if;
end process;


MatRow <= MatrizRow;
MatCol <= MatrizCol;
LED <= prueba;

end Behavioral;
