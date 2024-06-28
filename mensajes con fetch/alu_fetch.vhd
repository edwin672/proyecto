library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
----------------------------------------------------------

----------------------------------------------------------
entity alu_fetch is port(
    LED : out STD_LOGIC;
	LED2 : out STD_LOGIC;
	ROW : in STD_LOGIC_VECTOR(3 downto 0);
    COL : out STD_LOGIC_VECTOR(3 downto 0);
    MatCol : out STD_LOGIC_VECTOR(15 downto 0); 
    MatRow : out STD_LOGIC_VECTOR(7 downto 0)  
);       
end alu_fetch;
  
architecture behavior of alu_fetch is  ----------OSCILADOR INTERNO- -------------- ---- ------------ 
    component OSCH
        generic (NOM_FREQ: string);      
        port (STDBY: in std_logic; OSC: out std_logic);       
    end component;         
        
    attribute NOM_FREQ: string;     
    attribute NOM_FREQ of OSCinst0: label is "26.60"; ----------------  ------------------------------------------          
	component ROM_C is port(       
		clk: in std_logic;  
		enable: in std_logic; 
		address: in integer range 0 to 512; --Direccion de entrada en entero
		data : out std_logic_vector(7 downto 0) --Columna de la matriz de leds
	);	
	end component;

	component Rom_Instruccione is port(  
		clk: in std_logic;
		clr: in std_logic;
		enable: in std_logic;
		read_m : in std_logic; 
		address: in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(23 downto 0)
	);
	end component;	
	component RegistrosGernale is port(
		clk: in std_logic;
		reset: in std_logic;
		enable: in std_logic;
		data_in: in std_logic_vector(23 downto 0);
		selector1: in std_logic_vector(1 downto 0);
		data_out1: out std_logic_vector(23 downto 0)
	);
	end component;
signal reset : std_logic := '0';
signal clk: std_logic;
signal clk_0: std_logic:='0';
signal clk_1: std_logic:='0';
signal clk_cols: std_logic:='0';
signal clk_2: std_logic:='0';
signal Q: std_logic_vector(13 downto 0);
signal Qbcd: std_logic_vector(15 downto 0);
signal temp_control: std_logic_vector(3 downto 0);
signal un,de,ce,mi: std_logic_vector(6 downto 0);
signal Rdisplay: std_logic_vector(13 downto 0);
--REGISTROS PARA DATAPATH--
signal PC: std_logic_vector(7 downto 0):="00000000";
signal MAR: std_logic_vector(7 downto 0):=(others=>'0');
signal MBR: std_logic_vector(23 downto 0);
signal IR: std_logic_vector(23 downto 0);
signal ACC: std_logic_vector(15 downto 0);

--entradas,salidas componentes
signal data_bus: std_logic_vector(23 downto 0);
signal rpg_in: std_logic_vector(23 downto 0):=(others=>'0');
signal rpg_out: std_logic_vector(23 downto 0);
signal rpg_sel: std_logic_vector(1 downto 0):=(others=>'0');
signal rpg_in2: std_logic_vector(23 downto 0):=(others=>'0');
signal rpg_out2: std_logic_vector( 23 downto 0);
signal rpg_sel2: std_logic_vector(1 downto 0):=(others=>'0');
signal rpg_write: std_logic:='0';
signal A,B: std_logic_vector(15 downto 0);
signal control: std_logic_vector(3 downto 0);
signal C,Z,S,V: std_logic;

--entradas para el teclado
signal current_col : integer := 0; 
signal key_detected : integer := 0;
signal MatrizRow : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal MatrizCol : STD_LOGIC_VECTOR(15 downto 0) := "0111111111111111";
signal row_counter : integer range 0 to 7 := 0;    
signal empezar: std_logic := '0';
signal parar: std_logic := '0';
signal listo: std_logic := '1';
signal leido_teclado: std_logic := '0';

--entradas rom de letras
signal leido_rom : std_logic_vector(7 downto 0):= (others => '0');
signal direccion : integer range 0 to 512;

type global_state_type is (reset_pc,fetch,fetch1,fetch2,fetch3,end_fetch,decode,end_decode, execute,end_execute); 
signal global_state: global_state_type;

type instruction_type is (i_readra,i_readm,i_readt,i_nop,i_load,i_addi,i_dply,i_adec,i_bnz,i_jump,i_bz,i_bs,i_null,i_bnc,i_bc,i_bnv,i_bv,i_halt,i_add,i_sub,i_mult,i_div,i_multi,i_divi,i_comp1,i_comp2,i_jmp,i_jalr);

signal instruction: instruction_type;

type execute_instruction_type is(t0,t1,t2,t3,t4);
signal execute_instruction: execute_instruction_type;

signal PC_multiplexor : std_logic_vector(7 downto 0);
type data_tipo is array (0 to 15) of std_logic_vector(7 downto 0);
--variables para leer movido
constant data_prueba : data_tipo := ( 
    -- A
	0 => "00000011",
	1 => "00000010",
	2 => "00000100",
	3 => "00001000",
	4 => "00010000",
	
	5 => "00100000",
	6 => "01000000",
	7 => "10000000",
    -- B
	8 => "00000011",
	9 => "00000110",
	10 => "00001100",
	11 => "00011000",
	12 => "00110000",
	13 => "01100000",
	14 => "11000000",
    15 => "11111111"
);
	signal filasaux : std_logic_vector(7 downto 0);
	
	signal contador_filas : integer := 0;
	signal filas_moviendose  : data_tipo;
	signal contador_copia: integer := 0;
	signal fin_cadena : std_logic := '0';
	type memoria_array is array (0 to 99) of INTEGER;
	signal mensaje_enteros : memoria_array := (others => 0);
	signal contador_caracteres : integer := 0;

	signal rpg_sel1: std_logic_vector(1 downto 0):=(others=>'0');
	signal rpg_out1: std_logic_vector(23 downto 0);

	signal mostrar: std_logic := '0';
	signal contador_mensaje: integer := 0;
	signal mensaje_leido: std_logic_vector(7 downto 0) := "00000000";

begin
-----------IMPLEMENTACION OSCILADOR INTERNO---------------
OSCinst0: OSCH generic map("26.60") port map('0', clk);
----------------------------------------------------------

--clk
ROM_imp: ROM_Instruccione port map(clk_0,reset,'1','1',MAR,data_bus);
rom_catalogo : ROM_C port map(clk_cols,'1',direccion,leido_rom);
RPG : RegistrosGernale port map(clk_cols,reset,rpg_write,rpg_in,rpg_sel1,rpg_out1);
	process(clk_0, reset)
	begin
		if (reset = '1') then
			global_state <= reset_pc;
			execute_instruction<=t0;
			MAR<=(others=>'0');
			MBR<=(others=>'0');
			IR<=(others=>'0');
		elsif (rising_edge(clk_0) ) then			
			case global_state is
				when reset_pc=>
					global_state<=fetch;
				when fetch =>
					MAR<=PC;
					global_state<=fetch1;
				when fetch1 =>
					global_state<=fetch2;--sincronizar data_bus 
				when fetch2 => 
					MBR<=data_bus;
					global_state<=fetch3;
				when fetch3=>
					
					IR<=MBR;
					global_state<=end_fetch;
				when end_fetch=>
					global_state<=decode;
				when decode =>
					case IR(23 downto 18) is
						when "000000" =>instruction <= i_nop;
						when "000001" =>instruction <= i_load;
						when "000010" =>instruction <= i_addi;
						when "000011" =>instruction <= i_dply;
						when "000100" =>instruction <= i_adec;
						when "000101" =>instruction <= i_bnz;
						when "000110" =>instruction <= i_bz;
						when "000111" =>instruction <= i_bs;
						when "001000" =>instruction <= i_bnc;
						when "001001" =>instruction <= i_bc;
						when "001010" =>instruction <= i_bnv;
						when "001011" =>instruction <= i_bv;
						when "001100" =>instruction <= i_halt;
						when "001101" =>instruction <= i_add;
						when "001110" =>instruction <= i_sub;
						when "011111" =>instruction <= i_mult;
						when "010000" =>instruction <= i_div;
						when "010001" =>instruction <= i_multi;
						when "010010" =>instruction <= i_divi;
						when "010011" =>instruction <= i_comp1;
						when "010100" =>instruction <= i_comp2;
						when "010101" =>instruction <= i_jmp;
						when "010110" =>instruction <= i_jalr;
						when "010111" =>instruction <= i_readt; --instruccion de leer del teclado
						when "011000" =>instruction <= i_readm;	 --instruccion de leer de la memoria
						when "011001" =>instruction <= i_readra;	
						when others =>
							instruction <= i_null;
					end case;
					global_state<=end_decode;
					
				when end_decode=>
					global_state<=execute;
					
				when execute => 
					case instruction is		
					when i_readt =>
					case execute_instruction is
						when t0 =>
							empezar <= '1';
							execute_instruction <= t1;
						when t1 =>
							if leido_teclado = '1' then
								MatrizRow <= data_prueba(key_detected);
								empezar <= '0';
								execute_instruction <= t2;
							end if;
						when t2 =>
							if key_detected = 80 then -- Enter
								instruction <= i_nop;
							else
								-- Desplaza los valores actuales en mensaje_enteros y guarda el nuevo valor de key_detected
								for i in 98 downto 0 loop
									mensaje_enteros(i + 1) <= mensaje_enteros(i);
								end loop;
								mensaje_enteros(0) <= key_detected;
								contador_caracteres <= contador_caracteres + 1;
								execute_instruction <= t0;
								instruction <= i_readt;
							end if;
						when t3 =>
							execute_instruction <= t0; 
							global_state <= end_execute;
						when t4 =>									
							global_state<=end_execute;
					end case;
						when i_nop =>
						--PC <= 10 en binario
							MatrizRow <= "00000000";
							PC <= "00001001";
							global_state<=end_execute;
							execute_instruction<=t0;
						
						when i_readm =>
							case execute_instruction is 
								when t0 =>
									MatrizRow <= "11111111";
									execute_instruction<=t1;

								when t1 =>
									mostrar <= '1';
									MatrizRow <= mensaje_leido;							
								when t2 =>
									execute_instruction<=t3;--sincronizar data_bus
								when t3 =>
									execute_instruction<=t4;
								when t4 =>
									
									global_state<=end_execute;
							end case;
							--leer de memoria el mensaje que ya tenemos guardado

						when i_load =>
							case execute_instruction is 
								when t0 =>
									execute_instruction<=t1;
								when t1 =>
									rpg_write<='1';
									rpg_sel<=IR(17 downto 16); --RA
									rpg_in<="000000000000000000000011"; --3
									execute_instruction<=t2;
								when t2 =>
									execute_instruction<=t3;--sincronizar data_bus
									--pasara a entero el valor de salida de rpg_out1
									

								when t3 =>									
									execute_instruction<=t4;
								when t4 =>
									rpg_write<='0';
									execute_instruction<=t0;
									global_state<=end_execute;
							end case;
							
						when i_jump =>
							PC<=IR(7 downto 0);
							global_state<=end_execute;



						when others =>
							global_state<=end_execute;
					end case;
					
				when end_execute=>
					PC<=PC+1;
					global_state<=fetch;
				when others =>
					global_state<=reset_pc;
			end case;
		end if;
	end process;

	Q<=Rdisplay;
	
	process(clk_2)
	begin 
		if(mostrar = '1') then
			if(rising_edge(clk_2)) then
				if(contador_mensaje = 99) then
					contador_mensaje <= 0;
				else
					contador_mensaje <= contador_mensaje + 1;
				end if;
				mensaje_leido <= data_prueba(mensaje_enteros(contador_mensaje));
			end if;
		end if;
	end process;

	process(clk_cols) 
	begin 
		if(listo = '0' and empezar = '1') then
			if(rising_edge(clk_cols)) then
			filas_moviendose(contador_copia) <= data_prueba(contador_copia);
				if(contador_copia = 15) then
					listo <= '1';
					contador_copia <= 0;
				else
					contador_copia <= contador_copia +1;
				end if;
			end if;
		end if;
	end process;
	process(clk_cols,listo)
	begin
		if(listo = '1') then
			if(rising_edge(clk_cols)) then
				MatrizCol <= MatrizCol(14 downto 0) &MatrizCol(15);
				
				
				if(contador_filas = 15) then
					contador_filas <= 0;
				else
					contador_filas  <= contador_filas  +1;
				end if;
			end if;
		end if;
	end process;
	
	process(clk_cols)
	begin
		if empezar = '1' then
			if rising_edge(clk_cols) then
				case current_col is
					when 0 =>
						COL <= "1000";
						if ROW(0) = '1' then 
							key_detected <= 80; -- Enter
							leido_teclado <= '1';
						elsif ROW(1) = '1' then 
							key_detected <= 7; 
							leido_teclado <= '1';
						elsif ROW(2) = '1' then 
							key_detected <= 4; 
							leido_teclado <= '1';
						elsif ROW(3) = '1' then 
							key_detected <= 1;
							leido_teclado <= '1';      
						end if;
					when 1 =>
						COL <= "0100";
						if ROW(0) = '1' then 
							key_detected <= 0; 
							leido_teclado <= '1';
						elsif ROW(1) = '1' then 
							key_detected <= 8; 
							leido_teclado <= '1';
						elsif ROW(2) = '1' then 
							key_detected <= 5; 
							leido_teclado <= '1';
						elsif ROW(3) = '1' then 
							key_detected <= 2; 
							leido_teclado <= '1';
						end if;
					when 2 =>
						COL <= "0010";
						if ROW(0) = '1' then 
							key_detected <= 9; 
							leido_teclado <= '1';
						elsif ROW(1) = '1' then 
							key_detected <= 6; 
							leido_teclado <= '1';
						elsif ROW(2) = '1' then 
							key_detected <= 3; 
							leido_teclado <= '1';
						end if;
					when 3 =>
						COL <= "0001";
						if ROW(0) = '1' then 
							row_counter <= 0;
							leido_teclado <= '1';                 
						end if;
					when others =>
						parar <= '1';
				end case;
	
				if current_col = 3 then
					current_col <= 0;
				else
					current_col <= current_col + 1;
				end if;
			end if;
		end if;
	
		if empezar = '0' then
			leido_teclado <= '0';
		end if;
	end process;
process(clk_cols,listo)
begin 
	if(listo = '1') then
		if(rising_edge(clk_cols)) then
			MatrizCol <= MatrizCol(14 downto 0) &MatrizCol(15);	
		end if;
	end if;
end process;

process(clk, reset)
	variable count: integer range 0 to 250000;
	variable count1: integer range 0 to 2500000;
	variable count2: integer range 0 to 2500000;
	variable count3: integer range 0 to 4000000;
	begin
		if (reset = '1') then
			clk_0<= '0';
			clk_1<= '0';
			clk_cols<= '0';
			clk_2<= '0';
		elsif (rising_edge(clk)) then
			if (count < 100000) then
				count := count + 1;
			else
				count := 0;
				clk_0 <= not clk_0;
			end if;
			
			if (count1 < 1000000) then
				count1 := count1 + 1;
			else
				count1 := 0;
				clk_1 <= not clk_1;
			end if;

			if (count2 < 4000) then
				count2 := count2 + 1;
			else
				count2 := 0;
				clk_cols <= not clk_cols;
			end if;

			if (count3 < 4000000) then
				count3 := count3 + 1;
			else
				count3 := 0;
				clk_2 <= not clk_2;
			end if;
		end if;
end process;

MatRow <= MatrizRow; 
MatCol <= MatrizCol;
LED <= clk_2;
LED2 <= leido_teclado;
end behavior;
