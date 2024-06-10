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
        KEY : out STD_LOGIC_VECTOR(3 downto 0);
        MatCol : out STD_LOGIC_VECTOR(7 downto 0);
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

    signal led_state : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    constant MAX_COUNT : integer := 4000000;
    signal clk : std_logic := '0';
    signal count : integer range 0 to 4000000;

    constant MAX_COUNT2 : integer := 6000;
    signal count_cols: integer range 0 to 6000;
    signal clk_cols : std_logic := '0';

    signal clk_0 : std_logic := '0';
    signal clk_1 : std_logic := '0';

    signal current_col : integer := 0;
    signal key_detected : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal prev_key_detected : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal stored_key : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal display_enable : std_logic := '0';

    signal prueba : std_logic := '0';

    signal MatrizRow : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal MatrizCol : STD_LOGIC_VECTOR(7 downto 0) := "01111111";
    type matrix_array is array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
    
    constant letraA : matrix_array := (
        "00010010",
        "00010001",
        "00010001",
        "00010001",
        "00010001",
        "00010010",
        "11111100",
        "11111100"
    );

    constant letraB : matrix_array := (
        "01101110",
        "10010001",
        "10010001",
        "10010001",
        "11111110",
        "00000000",
        "00000000",
        "00000000"
    );
	constant letraC : matrix_array := (
    "01000010",
    "10000001",
    "10000001",    
    "10000001",
	"01111110",
    "00000000",
    "00000000",
    "00000000"
);
	constant letraD : matrix_array := (
    "01111110",
    "10000001",
    "10000001",    
    "10000001",
	"11111110",
    "00000000",
    "00000000",
    "00000000"
);
constant letraE : matrix_array := (
    "10000001",
    "10010001",
    "10010001",    
    "10010001",
	"11111111",
    "00000000",
    "00000000",
    "00000000"
);
constant letraF : matrix_array := (
    "00000001",
    "00001001",
    "00001001",    
    "00001001",
	"11111111",
    "00000000",
    "00000000",
    "00000000"
);
constant letraG : matrix_array := (
    "01110010",
    "10010001",
    "10010001",    
	"10000001",    
	"01111110",
    "00000000",
    "00000000",
    "00000000"
);
constant letraH : matrix_array := (
    "11111111",
    "00010000",
    "00010000",
    "00010000",
    "11111111",
    "00000000",
    "00000000",
    "00000000"
);
constant letraI : matrix_array := (
    "10000001",
    "10000001",
    "11111111",
    "10000001",
    "10000001",
    "00000000",
    "00000000",
    "00000000"
);
constant letraJ : matrix_array := (
    "01111111",	
    "10000001",
    "10000000",
    "10000000",
    "01100000",    
    "00000000",
	"00000000",
    "00000001"
);
constant letraK : matrix_array := (
    "10000011",
    "01000100",
    "00101000",    
    "00010000",
	"11111111",
    "00000000",
    "00000000",
    "00000000"
);

    signal row_counter : integer range 0 to 7 := 0;
    signal letraSelect : matrix_array;
	signal guardar : std_logic_vector(3 downto 0):= (others => '0');
    
begin

OSCinst0: OSCH generic map("26.60") port map('0', clk);

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

process(clk_cols)
begin
    if rising_edge(clk_cols) then
        case current_col is
            when 0 =>
                COL <=  "1000";
                if ROW(0) = '1' then key_detected <= "1100"; end if;
                if ROW(1) = '1' then key_detected <= "1000"; end if;
                if ROW(2) = '1' then key_detected <= "0100"; end if;
                if ROW(3) = '1' then key_detected <= "0000"; end if;
            when 1 =>
                COL <=  "0100";
                if ROW(0) = '1' then key_detected <= "1101"; end if;
                if ROW(1) = '1' then key_detected <= "1001"; end if;
                if ROW(2) = '1' then key_detected <= "0101"; end if;
                if ROW(3) = '1' then key_detected <= "0001"; end if;
            when 2 =>
                COL <= "0010";
                if ROW(0) = '1' then key_detected <= "1110"; end if;
                if ROW(1) = '1' then key_detected <= "1010"; end if;
                if ROW(2) = '1' then key_detected <= "0110"; end if;
                if ROW(3) = '1' then key_detected <= "0010"; end if;
            when 3 =>
                COL <= "0001";
                if ROW(0) = '1' then key_detected <= "1111"; end if;
                if ROW(1) = '1' then key_detected <= "1011"; end if;
                if ROW(2) = '1' then key_detected <= "0111"; end if;
                if ROW(3) = '1' then key_detected <= "0011"; end if;
            when others =>
                COL <= "1111";
                key_detected <= "0000";
        end case;

        if current_col = 3 then
            current_col <= 0;
        else
            current_col <= current_col + 1;
        end if;

        MatrizCol <= MatrizCol(0) & MatrizCol(7 downto 1);

        if row_counter = 7 then
            row_counter <= 0;
        else
            row_counter <= row_counter + 1;
        end if;
    end if;
end process;

process(clk_0)
begin
    if(rising_edge(clk_0)) then
        prueba <= not prueba;
    end if;
end process;

process(clk_cols, key_detected)
begin
    if rising_edge(clk_cols) then
        if key_detected /= "1111" then
			if(prev_key_detected/= "0000" and  key_detected = "1101") then
				guardar <= "1010";
			else
				guardar <= key_detected;
			end if;
			prev_key_detected <= key_detected;
        end if;

        if key_detected = "1111" then
            display_enable <= '1';
            stored_key <= guardar;
        elsif key_detected /= "1111" and prev_key_detected = "1111" then
            display_enable <= '0';
        end if;
    end if;
end process;

process(clk_cols)
begin
    if rising_edge(clk_cols) then
        if display_enable = '1' then
            MatrizRow <= letraSelect(row_counter);
        else
            MatrizRow <= (others => '0');
        end if;
    end if;
end process;

process(stored_key)
begin
    case stored_key is
        when "0000" =>
            letraSelect <= letraA;
        when "0001" =>
            letraSelect <= letraB;
		when "0010" =>
            letraSelect <= letraC;
		when "0100" =>
            letraSelect <= letraD;
		when "0101" =>
            letraSelect <= letraE;
		when "0110" =>
            letraSelect <= letraF;
		when "1000" =>
            letraSelect <= letraG;
		when "1001" =>
            letraSelect <= letraH;
		when "1010" =>
            letraSelect <= letraJ;
		when "1011" =>
            letraSelect <= letraJ;
        when others =>
            letraSelect <= letraK;
    end case;
end process;

MatRow <= MatrizRow;
MatCol <= MatrizCol;
KEY <= key_detected;
LED <= prueba;

end Behavioral;
