library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; --------------------------------
use ieee.numeric_std.all;

----------------------------------------------------------
entity alu_fetch is port(
    LED : out STD_LOGIC; 
	LED2 : out STD_LOGIC; 
	ROW : in STD_LOGIC_VECTOR(3 downto 0);
    COL : out STD_LOGIC_VECTOR(3 downto 0);   
    MatCol : out STD_LOGIC_VECTOR(15 downto 0); 
    MatRow : out STD_LOGIC_VECTOR(7 downto 0)     
);end alu_fetch;   
   
architecture behavior of alu_fetch is  ----------OSCILADOR INTERNO- -------------- ---- ------------ 
    component OSCH
        generic (NOM_FREQ: string);        
        port (STDBY: in std_logic; OSC: out std_logic);            
    end component;                
               
    attribute NOM_FREQ: string;              
    attribute NOM_FREQ of OSCinst0: label is "26.60";  --- - -------- ----  -  -- -- -------------------------------------      
      
	component ROM_C is port(           
		clk: in std_logic;   
		enable: in std_logic;    
		address: in integer range 0 to 512; --Direccion de entrada en entero
		data : out std_logic_vector(7 downto 0) --Columna de la matriz de leds
	);	
	end component;

	component rom_intrucciones is port(  
		clk: in std_logic;
		clr: in std_logic;
		enable: in std_logic;
		read_m : in std_logic; 
		address: in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(23 downto 0)
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
signal MatrizCol : STD_LOGIC_VECTOR(15 downto 0) := "1111111111111110";
signal row_counter : integer range 0 to 7 := 0;    
signal empezar: std_logic := '0';
signal parar: std_logic := '0';
signal listo: std_logic := '1';
signal leido_teclado: std_logic := '0';

signal prueba2: std_logic := '0';

--entradas rom de letras
signal leido_rom : std_logic_vector(7 downto 0):= (others => '0');
signal direccion : integer range 0 to 512;

type global_state_type is (reset_pc,fetch,fetch1,fetch2,fetch3,end_fetch,decode,end_decode, execute,end_execute); 
signal global_state: global_state_type;

type instruction_type is (i_fillme,i_readt2,i_readme,i_readra,i_readm,i_readt,i_nop,i_load,i_addi,i_dply,i_adec,i_bnz,i_jump,i_bz,i_bs,i_null,i_bnc,i_bc,i_bnv,i_bv,i_halt,i_add,i_sub,i_mult,i_div,i_multi,i_divi,i_comp1,i_comp2,i_jmp,i_jalr);

signal instruction: instruction_type;

type execute_instruction_type is(t0,t1,t2,t3,t4);
signal execute_instruction: execute_instruction_type;

signal PC_multiplexor : std_logic_vector(7 downto 0);
type data_tipo is array (0 to 15) of std_logic_vector(7 downto 0);

type data_rom is array (0 to 207) of std_logic_vector(7 downto 0);
--variables para leer movido
signal data_rom_completa : data_rom := (
	--A
	0 => "00000000",
	1 => "00000000",
	2 => "11111000",
	3 => "00010100",
	4 => "00010010",
	5 => "00010100",
	6 => "11111000",
	7 => "00000000",
	-- B
	8 => "00000000",
	9 => "00000000",
	10 => "11111110",
	11 => "10010010",
	12 => "10010010",
	13 => "10010010",
	14 => "01101100",
	15 => "00000000",
					
	--C
	16 => "00000000",
	17 => "00000000",
	18 => "11111110",
	19 => "10000010",
	20 => "10000010",
	21 => "10000010",
	22 => "10000010",
	23 => "00000000",
	
	--D
	24 => "00000000",
	25 => "00000000",
	26 => "11111110",
	27 => "10000010",
	28 => "10000010",
	29 => "10000010",
	30 => "01111100",
	31 => "00000000",

	--E
	32 => "00000000",
	33 => "00000000",
	34 => "11111110",
	35 => "10010010",
	36 => "10010010",
	37 => "10010010",
	38 => "10000010",
	39 => "00000000",

	--F
	40 => "00000000",
	41 => "00000000",
	42 => "11111110",
	43 => "00001010",
	44 => "00001010",
	45 => "00001010",
	46 => "00000000",
	47 => "00000000",

	--G
	48 => "00000000",
	49 => "00000000",
	50 => "01111100",
	51 => "10000010",
	52 => "10000010",
	53 => "10010010",
	54 => "01110010",
	55 => "00000000",

	--H
	56 => "00000000",
	57 => "00000000",
	58 => "11111110",
	59 => "00010000",
	60 => "00010000",
	61 => "00010000",
	62 => "11111110",
	63 => "00000000",

	--I
	64 => "00000000",
	65 => "00000000",
	66 => "10000010",
	67 => "10000010",
	68 => "11111110",
	69 => "10000010",
	70 => "10000010",
	71 => "00000000",

	--J
	72 => "00000000",
	73 => "00000000",
	74 => "01100000",
	75 => "10000000",
	76 => "10000000",
	77 => "10000000",
	78 => "11111110",
	79 => "00000000",

	--K
	80 => "00000000",
	81 => "00000000",
	82 => "11111110",
	83 => "00010000",
	84 => "00101000",
	85 => "01000100",
	86 => "10000010",
	87 => "00000000",

	--L
	88 => "00000000",
	89 => "00000000",
	90 => "11111110",
	91 => "10000000",
	92 => "10000000",
	93 => "10000000",
	94 => "10000000",
	95 => "00000000",
	others => "00000000"
	);
	



signal data_prueba : data_tipo := (others => "00000000");
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
	signal selector_data : std_logic_vector(3 downto 0) := "0000";
	signal select_mensaje : std_logic_vector(1 downto 0) := "00";
	signal select_mensajeguardado : std_logic_vector(1 downto 0) := "00";
	signal leido_1: std_logic := '0';

begin
-----------IMPLEMENTACION OSCILADOR INTERNO---------------
OSCinst0: OSCH generic map("26.60") port map('0', clk);
----------------------------------------------------------

--clk
ROM_imp: rom_intrucciones port map(clk_0,reset,'1','1',MAR,data_bus);
rom_catalogo : ROM_C port map(clk_cols,'1',direccion,leido_rom);


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
						when "011000" =>instruction <= i_readm;
						when "011001" =>instruction <= i_readme;
						when "011010" => instruction <= i_readt2;	 
						when "011011" => instruction <= i_fillme;
						when others =>
							instruction <= i_null;
					end case;
					global_state<=end_decode;
					
				when end_decode=>
					global_state<=execute;
					
				when execute => 
				prueba2 <= '0';
					case instruction is		

					when i_readt =>
					case execute_instruction is
						when t0 =>
							empezar <= '1';
							execute_instruction <= t1;
							select_mensaje <= IR(1 downto 0);
						when t1 =>
						MatrizRow <= data_rom_completa(key_detected);
							if leido_teclado = '1' then	
								execute_instruction <= t2;
								
							end if;
						when t2 =>
							case select_mensaje is
								when "01" =>
									mensaje_enteros(0) <= key_detected;
									MatrizRow <= "11001100";
									PC <= "00000001";
									global_state<=end_execute;
									execute_instruction <= t0;
									empezar <= '0';										
								when others =>
									MatrizRow <= "11111111";
							end case;
								--execute_instruction <= t3;
							
						when t3 =>
							execute_instruction <= t4; 
						when t4 =>
															
							global_state<=end_execute;
							execute_instruction<=t0;
							
					end case;
						when i_readt2 =>
						
						case execute_instruction is
							when t0 =>
								empezar <= '1';
								execute_instruction <= t1;
								select_mensaje <= IR(1 downto 0);
							when t1 =>
								MatrizRow <= data_rom_completa(key_detected);
								if leido_teclado = '1' then
									if(key_detected = 50) then
										instruction <= i_readt2;
										execute_instruction <= t0;
									else
									
										instruction <= i_readt2;
										execute_instruction <= t2;
									end if;
								end if;
							when t2 =>
								case select_mensaje is
									when "10" =>
										mensaje_enteros(1) <= key_detected;
										MatrizRow <= "11001111";
										empezar <= '0';
										PC <= PC + '1';
										execute_instruction <= t0;
										global_state<=end_execute;
									when others =>
										MatrizRow <= "11111111";
								end case;
							when t3 =>
								execute_instruction <= t4;
							when t4 =>
								global_state<=end_execute;
								execute_instruction<=t0;
						end case;

						when i_nop =>
						--PC <= 10 en binario
							MatrizRow <= "00000000";
							PC <= "00001001";
							global_state<=end_execute;
							execute_instruction<=t0;
						
						when i_readm =>
						empezar <= '1';
						case execute_instruction is
							when t0 =>
								selector_data <= IR(3 downto 0);
								execute_instruction <= t1;
							when t1 =>
								case selector_data is
									when "0000" =>
										MatrizCol <= "1111111111111110";
										--obtener el valor de data prueba en selecto data de 0000 a 1111 a intero
										MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "0001"=>
									MatrizCol <= "1111111111111101";
									--obtener el valor de data prueba en selecto data de 0000 a 1111 a intero
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "0010"=>
									MatrizCol <= "1111111111111011";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "0011"=>
									MatrizCol <= "1111111111110111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "0100"=>
									MatrizCol <= "1111111111101111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "0101"=>
									MatrizCol <= "1111111111011111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "0110"=>
									MatrizCol <= "1111111110111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "0111"=>
									MatrizCol <= "1111111101111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "1000"=>
									MatrizCol <= "1111111011111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "1001"=>
									MatrizCol <= "1111110111111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "1010"=>
									MatrizCol <= "1111101111111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "1011"=>
									MatrizCol <= "1111011111111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "1100"=>
									MatrizCol <= "1110111111111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "1101"=>
									MatrizCol <= "1101111111111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "1110"=>
									MatrizCol <= "1011111111111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when "1111"=>
									MatrizCol <= "0111111111111111";
									MatrizRow <= data_prueba(to_integer(unsigned(selector_data)));
									when others =>
										MatrizCol <= "1111111111111111";
										MatrizRow <= "00000000";
									end case;
								execute_instruction <= t2;
							when t2 =>
							if(key_detected = 60) then
								PC <= "00000000";
							else
								if(PC = "100011") then
									PC <= "00010100";
								else
									PC <= PC + '1';
								end if;
							end if;
								execute_instruction <= t3; -- sincronizar data_bus
							when t3 =>
								execute_instruction <= t4;
							when t4 =>
								global_state <= end_execute;
								execute_instruction <= t0; 
						end case;

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

						when i_readme => --leer la tecla que se almaceno en el array de mensajes
						prueba2 <= '0';
						empezar <= '1';
							case execute_instruction is
								when t0 =>									
									--execute_instruction<=t1;	
									case IR(1 downto 0) is
										when "00" =>
											MAtrizCol <= "1111111111111110";
											MatrizRow <= data_rom_completa(mensaje_enteros(0));
										when "01" =>
											MatrizCol <= "1111111111111101";
											MatrizRow <= data_rom_completa(mensaje_enteros(1));
										when others =>
											MatrizRow <= "00000000";
									end case;	
									execute_instruction<=t1;
									
								when t1 =>
									
								execute_instruction <= t2;
								when t2 =>
									execute_instruction<=t3;
								when t3 =>
									execute_instruction<=t4;
								when t4 =>
								if(key_detected = 80) then
									PC <= "00000000";
									empezar <= '0';
								else
									if(PC = "00000011") then
										if(key_detected = 70) then
											PC <= "00000100";
										else
											PC <= "00000010";
										end if;
									else
										PC <= PC + '1';
									end if;									
								
								end if;
								execute_instruction<=t0;
								global_state<=end_execute;
							end case;
						when i_fillme =>
						prueba2 <= '1';
						 case execute_instruction is
							when t0 =>
								execute_instruction<=t1;
							when t1 =>
								case IR(3 downto 0) is
									when "0000" =>
										data_prueba(0) <= data_rom_completa(mensaje_enteros(0)+0);
									when "0001" =>
										data_prueba(1) <= data_rom_completa(mensaje_enteros(0)+1);
									when "0010" =>
										data_prueba(2) <= data_rom_completa(mensaje_enteros(0)+2);
									when "0011" =>
										data_prueba(3) <= data_rom_completa(mensaje_enteros(0)+3);
									when "0100" =>
										data_prueba(4) <= data_rom_completa(mensaje_enteros(0)+4);
									when "0101" =>
										data_prueba(5) <= data_rom_completa(mensaje_enteros(0)+5);
									when "0110" =>
										data_prueba(6) <= data_rom_completa(mensaje_enteros(0)+6);
									when "0111" =>
										data_prueba(7) <= data_rom_completa(mensaje_enteros(0)+7);
									when "1000" =>
										data_prueba(8) <= data_rom_completa(mensaje_enteros(1)+0);
									when "1001" =>
										data_prueba(9) <= data_rom_completa(mensaje_enteros(1)+1);
									when "1010" =>
										data_prueba(10) <= data_rom_completa(mensaje_enteros(1)+2);
									when "1011" =>
										data_prueba(11) <= data_rom_completa(mensaje_enteros(1)+3);
									when "1100" =>
										data_prueba(12) <= data_rom_completa(mensaje_enteros(1)+4);
									when "1101" =>
										data_prueba(13) <= data_rom_completa(mensaje_enteros(1)+5);
									when "1110" =>
										data_prueba(14) <= data_rom_completa(mensaje_enteros(1)+6);
									when "1111" =>
										data_prueba(15) <= data_rom_completa(mensaje_enteros(1)+7);
									when others =>
										data_prueba(0) <= data_rom_completa(mensaje_enteros(0));
								end case;
								execute_instruction<=t2;
							when t2 =>
								execute_instruction<=t3;
							when t3 =>
								execute_instruction<=t4;
							when t4 =>
								PC <= PC + '1';
								execute_instruction<=t0;
								global_state<=end_execute;
							end case;						
						when others =>
							global_state<=end_execute;
					end case;
					
				when end_execute=>
					--PC<=PC+1;
					global_state<=fetch;
				when others =>
					global_state<=reset_pc;
			end case;
		end if;
	end process;

	
	process(clk_0)
	begin
		if rising_edge(clk_0) then
			if empezar = '1' then
				case current_col is
					when 0 =>
						COL <= "1000";
						if ROW(0) = '1' then 
							key_detected <= 80; -- Enter
						elsif ROW(1) = '1' then 
							key_detected <= 56; 
						elsif ROW(2) = '1' then 
							key_detected <= 32; 
						elsif ROW(3) = '1' then 
							key_detected <= 8;
						end if;
					when 1 =>
						COL <= "0100";
						if ROW(0) = '1' then 
							key_detected <= 0; 
						elsif ROW(1) = '1' then 
							key_detected <= 64; 
						elsif ROW(2) = '1' then 
							key_detected <= 40; 
						elsif ROW(3) = '1' then 
							key_detected <= 16; 
						end if;
					when 2 =>
						COL <= "0010";
						if ROW(0) = '1' then 
							key_detected <= 72; 
						elsif ROW(1) = '1' then 
							key_detected <= 48; 
						elsif ROW(2) = '1' then 
							key_detected <= 24; 
						end if;
					when 3 =>
						COL <= "0001";
						if ROW(0) = '1' then 
							row_counter <= 0;
							leido_teclado <= '1';
						elsif ROW(3) = '1' then
							key_detected <= 70;
						elsif ROW(2) = '1' then
							key_detected <= 60;             
						end if;
				end case;
	
				if current_col = 3 then
					current_col <= 0;
				else
					current_col <= current_col + 1;
				end if;
			end if;
	
			if empezar = '0' then
				leido_teclado <= '0';
				key_detected <= 50;
			end if;
		end if;
	end process;


process(clk, reset)
	variable count: integer range 0 to 100;
	variable count1: integer range 0 to 2500000;
	variable count2: integer range 0 to 2500000;
	variable count3: integer range 0 to 8500000;
	begin
		if (reset = '1') then
			clk_0<= '0';
			clk_1<= '0';
			clk_cols<= '0';
			clk_2<= '0';
		elsif (rising_edge(clk)) then
			if (count < 100) then
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

			if (count3 < 8500000) then
				count3 := count3 + 1;
			else
				count3 := 0;
				clk_2 <= not clk_2;
			end if;
		end if;
end process;

MatRow <= MatrizRow; 
MatCol <= MatrizCol;
LED <= leido_teclado;-- rojp
LED2 <= prueba2; --azul
end behavior;
