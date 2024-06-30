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
    attribute NOM_FREQ of OSCinst0: label is "26.60";  --- - -------- ----  --- -- -------------------------------------      
    
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

type instruction_type is (i_readt2,i_readme,i_readra,i_readm,i_readt,i_nop,i_load,i_addi,i_dply,i_adec,i_bnz,i_jump,i_bz,i_bs,i_null,i_bnc,i_bc,i_bnv,i_bv,i_halt,i_add,i_sub,i_mult,i_div,i_multi,i_divi,i_comp1,i_comp2,i_jmp,i_jalr);

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
	1 => "11111110",
	2 => "11111000",
	3 => "00010100",
	4 => "00010010",
	5 => "00010100",
	6 => "11111000",
	7 => "00000000",
	-- B
	8 => "11111100",
	9 => "00000000",
	10 =>  "11111110",
	11 =>  "10010010",
	12 => "10010010",
	13 => "10010010",
	14 => "01101100",
	15 => "00000000",
					
	--C
	16 => "10000010",
	17 => "10000010",
	18 => "10000010",
	19 => "10000010",
	20 => "00000000",
	21 => "00000000",
	22 => "00000000",
	23 => "11111110",
		
		--D
		24 => "10000010",
	25 => "10000010",
	26 => "10000010",
	27 => "01111100",
	28 => "00000000",
	29 => "00000000",
	30 => "00000000",
	31 => "11111110",
		--E
		32 => "10010010",
	33 => "10010010",
	34 => "10010010",
	35 => "10010010",
	36 => "00000000",
	37 => "00000000",
	38 => "00000000",
	39 => "11111110",
		--F				
		40 => "00010010",
	41 => "00010010",
	42 => "00000010",
	43 => "00000010",
	44 => "00000000",
	45 => "00000000",
	46 => "00000000",
	47 => "11111110",
		--G
	48 => "10000010",
	49 => "10010010",
	50 => "10010010",
	51 => "11110010",
	52 => "00000000",
	53 => "00000000",
	54 => "00000000",
	55 => "11111110",
		--H
		56 => "00010000",
	57 => "00010000",
	58 => "00010000",
	59 => "11111110",
	60 => "00000000",
	61 => "00000000",
	62 => "00000000",
	63 => "11111110",
		--I
		64 => "10000010",
	65 => "11111110",
	66 => "10000010",
	67 => "10000010",
	68 => "00000000",
	69 => "00000000",
	70 => "00000000",
	71 => "10000010",
		--J
	72 => "10000010",
	73 => "11111110",
	74 => "00000010",
	75 => "00000010",
	76 => "00000000",
	77 => "00000000",
	78 => "00000000",
	79 => "10000010",
		--K
		80 => "00010000",
	81 => "00101000",
	82 => "01000100",
	83 => "10000010",
	84 => "00000000",
	85 => "00000000",
	86 => "00000000",
	87 => "11111110",
		--L
		88 => "10000000",
	89 => "10000000",
	90 => "10000000",
	91 => "10000000",
	92 => "00000000",
	93 => "00000000",
	94 => "00000000",
	95 => "11111110",
		--M
	96 => "00000100",
	97 => "00001000",
	98 => "00000100",
	99 => "11111110",
	100 => "00000000",
	101 => "00000000",
	102 => "00000000",
	103 => "11111110",
		--N
		104 => "00001100",
	105 => "00111000",
	106 => "01100000",
	107 => "11111110",
	108 => "00000000",
	109 => "00000000",
	110 => "00000000",
	111 => "11111110",
		--O
		112 => "10000010",
	113 => "10000010",
	114 => "10000010",
	115 => "11111110",
	116 => "00000000",
	117 => "00000000",
	118 => "00000000",
	119 => "11111110",
		--P
		120 => "00010010",
	121 => "00010010",
	122 => "00010010",
	123 => "00001100",
	124 => "00000000",
	125 => "00000000",
	126 => "00000000",
	127 => "11111110",
		--Q               
		128 => "10000010",
	129 => "10100010",
	130 => "11000010",
	131 => "11111110",
	132 => "00000000",
	133 => "00000000",
	134 => "00000000",
	135 => "11111110",
		--R               
		136 => "00010010",
	137 => "00110010",
	138 => "01010010",
	139 => "10001100",
	140 => "00000000",
	141 => "00000000",
	142 => "00000000",
	143 => "11111110",
		--S                
		144 => "10010010",
	145 => "10010010",
	146 => "10010010",
	147 => "11110110",
	148 => "00000000",
	149 => "00000000",
	150 => "00000000",
	151 => "11011110",
		--T                
		152 => "00000010",
	153 => "11111110",
	154 => "00000010",
	155 => "00000010",
	156 => "00000000",
	157 => "00000000",
	158 => "00000000",
	159 => "00000010",
		--U                
		160 => "10000000",
	161 => "10000000",
	162 => "10000000",
	163 => "11111110",
	164 => "00000000",
	165 => "00000000",
	166 => "00000000",
	167 => "11111110",
		--V                
		168 => "01110000",
	169 => "10000000",
	170 => "01110000",
	171 => "00001110",
	172 => "00000000",
	173 => "00000000",
	174 => "00000000",
	175 => "00001110",
		--W                
		176 => "10000000",
	177 => "01111110",
	178 => "10000000",
	179 => "01111110",
	180 => "00000000",
	181 => "00000000",
	182 => "00000000",
	183 => "01111110",
		--X                
		184 => "01101100",
	185 => "00010000",
	186 => "01101100",
	187 => "11000110",
	188 => "00000000",
	189 => "00000000",
	190 => "00000000",
	191 => "11000110",
		--Y                
		192 => "00001100",
	193 => "11110000",
	194 => "00001100",
	195 => "00000110",
	196 => "00000000",
	197 => "00000000",
	198 => "00000000",
	199 => "00000110",
		--Z                
		200 => "10100001",
	201 => "10001001",
	202 => "10000101",
	203 => "10000011",
	204 => "00000000",
	205 => "00000000",
	206 => "00000000",
	207 => "11000001"
);



signal data_prueba : data_tipo := ( 
    --A
	0 => "00000000",
	1 => "00000000",
	2 => "11111000",
	3 => "00010100",
	4 => "00110010",
	5 => "00010100",
	6 => "11111000",
	7 => "00000000",
	-- B
	8 => "00000000",
	9 => "00000000",
	10 =>  "11111110",
	11 =>  "10010010",
	12 => "10010010",
	13 => "10010010",
	14 => "01101100",
	15 => "00000000"
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
						prueba2 <= '1';
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
								if(PC = "00001111") then
									PC <= "00000000";
								else
									PC <= PC + '1';
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
										PC <= "00000010";
									else
										PC <= PC + '1';
									end if;									
								
								end if;
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
							key_detected <= 7; 
						elsif ROW(2) = '1' then 
							key_detected <= 4; 
						elsif ROW(3) = '1' then 
							key_detected <= 1;
						end if;
					when 1 =>
						COL <= "0100";
						if ROW(0) = '1' then 
							key_detected <= 0; 
						elsif ROW(1) = '1' then 
							key_detected <= 8; 
						elsif ROW(2) = '1' then 
							key_detected <= 5; 
						elsif ROW(3) = '1' then 
							key_detected <= 2; 
						end if;
					when 2 =>
						COL <= "0010";
						if ROW(0) = '1' then 
							key_detected <= 9; 
						elsif ROW(1) = '1' then 
							key_detected <= 6; 
						elsif ROW(2) = '1' then 
							key_detected <= 3; 
						end if;
					when 3 =>
						COL <= "0001";
						if ROW(0) = '1' then 
							row_counter <= 0;
							leido_teclado <= '1';                 
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
