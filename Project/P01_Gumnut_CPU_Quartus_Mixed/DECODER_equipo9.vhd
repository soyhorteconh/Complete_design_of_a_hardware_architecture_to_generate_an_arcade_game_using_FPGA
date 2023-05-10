-- Equipo 9
-- Hortencia Alejandra Ramírez Vázquez A01750150
-- Karen Lizette Rodriguez Hernandez A01197734
-- José Gustavo Buenaventura Carreón A01570891
-- Carlos Gaeta Lopez A01611248

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY DECODER_equipo9 IS
	PORT(
		SelSw_9:	IN		STD_LOGIC_VECTOR( 3 DOWNTO 0 );
		Seg7_9:	OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 ));
END DECODER_equipo9;

ARCHITECTURE behavior OF DECODER_equipo9 IS
BEGIN
	PROCESS(SelSw_9)
	BEGIN
		CASE SelSw_9 IS
			WHEN "0000" => Seg7_9 <= NOT "0111111";
			WHEN "0001" => Seg7_9 <= NOT "0000110";
			WHEN "0010" => Seg7_9 <= NOT "1011011";
			WHEN "0011" => Seg7_9 <= NOT "1001111";
			WHEN "0100" => Seg7_9 <= NOT "1100110";
			WHEN "0101" => Seg7_9 <= NOT "1101101";
			WHEN "0110" => Seg7_9 <= NOT "1111101";
			WHEN "0111" => Seg7_9 <= NOT "0000111";
			WHEN "1000" => Seg7_9 <= NOT "1111111";
			WHEN "1001" => Seg7_9 <= NOT "1101111";
			WHEN "1010" => Seg7_9 <= NOT "1110111";
			WHEN "1011" => Seg7_9 <= NOT "1111100";
			WHEN "1100" => Seg7_9 <= NOT "0111001";
			WHEN "1101" => Seg7_9 <= NOT "1011110";
			WHEN "1110" => Seg7_9 <= NOT "1111001";
			WHEN "1111" => Seg7_9 <= NOT "1110001";
			WHEN OTHERS => Seg7_9 <= UNAFFECTED;
		END CASE;
	END PROCESS;
END behavior;

--ARCHITECTURE behavior OF DECODER_equipo9 IS
--BEGIN
--	Seg7_9	<=	NOT "0111111" WHEN (SelSw_9 = "0000") ELSE
--					NOT "0000110" WHEN (SelSw_9 = "0001") ELSE
--					NOT "1011011" WHEN (SelSw_9 = "0010") ELSE
--					NOT "1001111" WHEN (SelSw_9 = "0011") ELSE
--					NOT "1100110" WHEN (SelSw_9 = "0100") ELSE
--					NOT "1101101" WHEN (SelSw_9 = "0101") ELSE
--					NOT "1111101" WHEN (SelSw_9 = "0110") ELSE
--					NOT "0000111" WHEN (SelSw_9 = "0111") ELSE
--					NOT "1111111" WHEN (SelSw_9 = "1000") ELSE
--					NOT "1101111" WHEN (SelSw_9 = "1001") ELSE
--					NOT "1110111" WHEN (SelSw_9 = "1010") ELSE
--					NOT "1111100" WHEN (SelSw_9 = "1011") ELSE
--					NOT "0111001" WHEN (SelSw_9 = "1100") ELSE
--					NOT "1011110" WHEN (SelSw_9 = "1101") ELSE
--					NOT "1111001" WHEN (SelSw_9 = "1110") ELSE
--					NOT "1110001";
--END behavior;