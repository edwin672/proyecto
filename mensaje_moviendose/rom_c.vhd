library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rom_c is port(
	clk: in std_logic;
	enable: in std_logic;
	address: in integer range 0 to 512; --Direccion de entrada en entero
	data : out std_logic_vector(7 downto 0) --Columna de la matriz de leds
);
end rom_c;

architecture caracteres of rom_c is
	type rom_type is array (0 to 512) of std_logic_vector(7 downto 0);
	signal rom_memory : rom_type := (
				
				--A
				0 => "00010100",
				1 => "00010010",
				2 => "00010100",
				3 => "11111000",
				4 => "00000000",
				5 => "00000000",
				6 => "00000000",
				7 => "11111000",
				
                --B
                 8 => "10010010",
                 9 => "10010010",
                10 => "10010010",
                11 => "11111110",
                12 => "00000000",
                13 => "00000000",
                14 => "00000000",
                15 => "01101100",				
                --C
				16 => "10000010",
                17 => "10000010",
                18 => "10000010",
                19 => "11111110",
                20 => "00000000",
                21 => "00000000",
                22 => "00000000",
                23 => "10000010",
                
                --D
				24 => "10000010",
                25 => "10000010",
                26 => "10000010",
                27 => "11111110",
                28 => "00000000",
                29 => "00000000",
                30 => "00000000",
                31 => "01111100",
                --E
				32 => "10010010",
                33 => "10010010",
                34 => "10010010",
                35 => "11111110",
                36 => "00000000",
                37 => "00000000",
                38 => "00000000",
                39 => "10010010",
				--F				
                40 => "00000010",
                41 => "00010010",
                42 => "00010010",
                43 => "11111110",
                44 => "00000000",
                45 => "00000000",
                46 => "00000000",
                47 => "00000010",
				--G
                48 => "10010010",
                49 => "10010010",
                50 => "10000010",
                51 => "11111110",
                52 => "00000000",
                53 => "00000000",
                54 => "00000000",
                55 => "11110010",
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
                72 => "00000010",
                73 => "11111110",
                74 => "10000010",
                75 => "10000010",
                76 => "00000000",
                77 => "00000000",
                78 => "00000000",
                79 => "00000010",
				--K
                80 => "01000100",
                81 => "00101000",
                82 => "00010000",
                83 => "11111110",
                84 => "00000000",
                85 => "00000000",
                86 => "00000000",
                87 => "10000010",
				--L
                88 => "10000000",
                89 => "10000000",
                90 => "10000000",
                91 => "11111110",
                92 => "00000000",
                93 => "00000000",
                94 => "00000000",
                95 => "10000000",
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
                104 => "01100000",
                105 => "00111000",
                106 => "00001100",
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
                123 => "11111110",
                124 => "00000000",
                125 => "00000000",
                126 => "00000000",
                127 => "00001100",
				--Q               
                128 => "11000010",
                129 => "10100010",
                130 => "10000010",
                131 => "11111110",
                132 => "00000000",
                133 => "00000000",
                134 => "00000000",
                135 => "11111110",
				--R               
                136 => "01010010",
                137 => "00110010",
                138 => "00010010",
                139 => "11111110",
                140 => "00000000",
                141 => "00000000",
                142 => "00000000",
                143 => "10001100",
				--S                
                144 => "10010010",
                145 => "10010010",
                146 => "10010010",
                147 => "11011110",
                148 => "00000000",
                149 => "00000000",
                150 => "00000000",
                151 => "11110110",
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
                200 => "10000101",
                201 => "10011001",
                202 => "10100001",
                203 => "11000001",
                204 => "00000000",
                205 => "00000000",
                206 => "00000000",
                207 => "10000011",
				--0                
                208 => "10000110",
                209 => "10111010",
                210 => "11000010",
                211 => "11111110",
                212 => "00000000",
                213 => "00000000",
                214 => "00000000",
                215 => "11111110",
				--1                
                216 => "10000000",
                217 => "11111110",
                218 => "10000010",
                219 => "10000000",
                220 => "00000000",
                221 => "00000000",
                222 => "00000000",
                223 => "10000000",
				--2                
                224 => "10001001",
                225 => "10001001",
                226 => "10001001",
                227 => "11111001",
                228 => "00000000",
                229 => "00000000",
                230 => "00000000",
                231 => "10001111",
				--3                
                232 => "10010010",
                233 => "10010010",
                234 => "10010010",
                235 => "10010010",
                236 => "00000000",
                237 => "00000000",
                238 => "00000000",
                239 => "01111100",
				--4                
                240 => "00010000",
                241 => "00010000",
                242 => "00010000",
                243 => "00011110",
                244 => "00000000",
                245 => "00000000",
                246 => "00000000",
                247 => "11111110",
				--5                
                248 => "10010010",
                249 => "10010010",
                250 => "10010010",
                251 => "10011110",
                252 => "00000000",
                253 => "00000000",
                254 => "00000000",
                255 => "11110010",
				--6                
                256 => "10010010",
                257 => "10010010",
                258 => "10010010",
                259 => "11111110",
                260 => "00000000",
                261 => "00000000",
                262 => "00000000",
                263 => "11110010",
				--7                
                264 => "00010010",
                265 => "00010010",
                266 => "00010010",
                267 => "00000010",
                268 => "00000000",
                269 => "00000000",
                270 => "00000000",
                271 => "11111110",
				--8                
                272 => "10010010",
                273 => "10010010",
                274 => "10010010",
                275 => "01101100",
                276 => "00000000",
                277 => "00000000",
                278 => "00000000",
                279 => "01101100",
				--9                
                280 => "00010010",
                281 => "00010010",
                282 => "00010010",
                283 => "00011110",
                284 => "00000000",
                285 => "00000000",
                286 => "00000000",
                287 => "11111110",
				--espacio                
                288 => "00000000",
                289 => "00000000",
                290 => "00000000",
                291 => "00000000",
                292 => "00000000",
                293 => "00000000",
                294 => "00000000",
                295 => "00000000",
				-- + mas               
                296 => "00010000",
                297 => "01111100",
                298 => "00010000",
                299 => "00010000",
                300 => "00000000",
                301 => "00000000",
                302 => "00000000",
                303 => "00010000",
				-- - menos                
                304 => "00010000",
                305 => "00010000",
                306 => "00010000",
                307 => "00010000",
                308 => "00000000",
                309 => "00000000",
                310 => "00000000",
                311 => "00010000",
                -- \ el otro slash
                312 => "00100000",
                313 => "00010000",
                314 => "00001000",
                315 => "00000110",
                316 => "00000000",
                317 => "00000000",
                318 => "00000000",
                319 => "11000000",                
				-- / slash 
                320 => "00001000",
                321 => "00010000",
                322 => "00100000",
                323 => "11000000",
                324 => "00000000",
                325 => "00000000",
                326 => "00000000",
                327 => "00000110",
                -- _ guion bajo
                328 => "10000000",
                329 => "10000000",
                330 => "10000000",
                331 => "10000000",
                332 => "00000000",
                333 => "00000000",
                334 => "00000000",
                335 => "10000000",
                -- ! exclamacion
                336 => "00000000",
                337 => "10111110",
                338 => "10111110",
                339 => "00000000",
                340 => "00000000",
                341 => "00000000",
                342 => "00000000",
                343 => "00000000",
                -- ? interrogacion
                344 => "00010010",
                345 => "00010010",
                346 => "00010010",
                347 => "10110010",
                348 => "00000000",
                349 => "00000000",
                350 => "00000000",
                351 => "00011110",
                -- . punto
                352 => "11000000",
                353 => "11000000",
                354 => "00000000",
                355 => "00000000",
                356 => "00000000",
                357 => "00000000",
                358 => "00000000",
                359 => "00000000",
                -- \n fin de cadena                
                360 => "00000000",
                361 => "00000000",
                362 => "00000000",
                363 => "00000000",
                364 => "00000000",
                365 => "00000000",
                366 => "00000000",                
				367 => "00000000",
				--
                368 => "00000000",
                369 => "00000000",
                370 => "00000000",
                371 => "00000000",
                372 => "00000000",
                373 => "00000000",
                374 => "00000000",
                375 => "00000000",
                --
                376 => "00000000",
                377 => "00000000",
                378 => "00000000",
                379 => "00000000",
                380 => "00000000",
                381 => "00000000",
                382 => "00000000",
                383 => "00000000",
                --
                384 => "00000000",
                385 => "00000000",
                386 => "00000000",
                387 => "00000000",
                388 => "00000000",
                389 => "00000000",
                390 => "00000000",
                391 => "00000000",
                --
                392 => "00000000",
                393 => "00000000",
                394 => "00000000",
                395 => "00000000",
                396 => "00000000",
                397 => "00000000",
                398 => "00000000",
                399 => "00000000",
                --
                400 => "00000000",
                401 => "00000000",
                402 => "00000000",
                403 => "00000000",
                404 => "00000000",
                405 => "00000000",
                406 => "00000000",
                407 => "00000000",
                --
                408 => "00000000",
                409 => "00000000",
                410 => "00000000",
                411 => "00000000",
                412 => "00000000",
                413 => "00000000",
                414 => "00000000",
                415 => "00000000",
                --
                416 => "00000000",
                417 => "00000000",
                418 => "00000000",
                419 => "00000000",
                420 => "00000000",
                421 => "00000000",
                422 => "00000000",
                423 => "00000000",
                --
                424 => "00000000",
                425 => "00000000",
                426 => "00000000",
                427 => "00000000",
                428 => "00000000",
                429 => "00000000",
                430 => "00000000",
                431 => "00000000",
                --
                432 => "00000000",
                433 => "00000000",
                434 => "00000000",
                435 => "00000000",
                436 => "00000000",
                437 => "00000000",
                438 => "00000000",
                439 => "00000000",
                --
                440 => "00000000",
                441 => "00000000",
                442 => "00000000",
                443 => "00000000",
                444 => "00000000",
                445 => "00000000",
                446 => "00000000",
                447 => "00000000",
                --
                448 => "00000000",
                449 => "00000000",
                450 => "00000000",
                451 => "00000000",
                452 => "00000000",
                453 => "00000000",
                454 => "00000000",
                455 => "00000000",
                --
                456 => "00000000",
                457 => "00000000",
                458 => "00000000",
                459 => "00000000",
                460 => "00000000",
                461 => "00000000",
                462 => "00000000",
                463 => "00000000",
                --
                464 => "00000000",
                465 => "00000000",
                466 => "00000000",
                467 => "00000000",
                468 => "00000000",
                469 => "00000000",
                470 => "00000000",
                471 => "00000000",
                --
                472 => "00000000",
                473 => "00000000",
                474 => "00000000",
                475 => "00000000",
                476 => "00000000",
                477 => "00000000",
                478 => "00000000",
                479 => "00000000",
                --
                480 => "00000000",
                481 => "00000000",
                482 => "00000000",
                483 => "00000000",
                484 => "00000000",
                485 => "00000000",
                486 => "00000000",
                487 => "00000000",
                --
                488 => "00000000",
                489 => "00000000",
                490 => "00000000",
                491 => "00000000",
                492 => "00000000",
                493 => "00000000",
                494 => "00000000",
                495 => "00000000",
                --
                496 => "00000000",
                497 => "00000000",
                498 => "00000000",
                499 => "00000000",
                500 => "00000000",
                501 => "00000000",
                502 => "00000000",
                503 => "00000000",
                --
                504 => "00000000",
                505 => "00000000",
                506 => "00000000",
                507 => "00000000",
                508 => "00000000",
                509 => "00000000",
                510 => "00000000",
                511 => "00000000",
                --
				512 => "00000000"
	);
begin 
	process (clk)
		begin
			if(clk'event and clk = '1') then
				if (enable = '1') then
					data <= rom_memory(address);
				end if;
			end if;
		end process;
end caracteres;