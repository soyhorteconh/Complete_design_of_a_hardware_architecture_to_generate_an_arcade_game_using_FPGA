-- Equipo 9
-- Hortencia Alejandra Ramírez Vázquez A01750150
-- Karen Lizette Rodriguez Hernandez A01197734
-- José Gustavo Buenaventura Carreón A01570891
-- Carlos Gaeta Lopez A01611248

----------------------------------------------------------

LIBRARY 	ieee;
USE 		ieee.std_logic_1164.all;
USE 		ieee.std_logic_arith.all;

ENTITY vga_9 IS
	GENERIC(
		H_LOW:	natural	:= 96; --Hpulse
		HBP: 		natural 	:= 48; --HBP
		H_HIGH:	natural 	:= 640; --Hactive
		HFP: 		natural  := 16; --HFP
		V_LOW: 	natural  := 2; --Vpulse
		VBP: 		natural	:= 33; --VBP
		V_HIGH: 	natural  := 480; --Vactive
		VFP: 		natural	:= 10 --VFP
	); 
	PORT(
		clk, rst_9: 					IN 	std_logic; --50MHz in our board
		H_sync, V_sync: 	OUT	std_logic;
		BLANKn, SYNCn : 	OUT 	std_logic;
		R, G, B: 			OUT 	std_logic_vector(3 DOWNTO 0);
		puntaje		  :	buffer 	std_logic;
		sw				  : 	in 	std_logic_vector(9 downto 0);
		btn			  :   in 	std_logic
	);
END vga_9;


ARCHITECTURE rtl OF vga_9 IS


	SIGNAL Hsync, Vsync, Hactive, Vactive, dena, clk_vga, clk_fsm:	std_logic;
	signal cont, address, data_out : natural;
	TYPE state_type IS( state_1_9, state_2_9, state_3_9 );
	SIGNAL pr_state_9, nx_state_9	:	state_type;
	signal and1	: std_logic_vector (9 downto 0);
	
	-- rom memory
	signal 	reg_address	:	integer	range 0 to 15;
			type		memory is array (0 to 99) of natural;

			constant myrom	:	memory :=	(
				0 => 576,
				1 => 256,
				2 => 128,
				3 => 128,
				4 => 320,
				5 => 0,
				6 => 384,
				7 => 512,
				8 => 448,
				9 => 384,
				10 => 64,
				11 => 448,
				12 => 384,
				13 => 256,
				14 => 192,
				15 => 128,
				16 => 448,
				17 => 320,
				18 => 320,
				19 => 64,
				20 => 512,
				21 => 512,
				22 => 192,
				23 => 320,
				24 => 192,
				25 => 0,
				26 => 448,
				27 => 64,
				28 => 512,
				29 => 0,
				30 => 128,
				31 => 320,
				32 => 448,
				33 => 448,
				34 => 0,
				35 => 512,
				36 => 512,
				37 => 256,
				38 => 384,
				39 => 192,
				40 => 512,
				41 => 192,
				42 => 192,
				43 => 192,
				44 => 256,
				45 => 320,
				46 => 192,
				47 => 128,
				48 => 512,
				49 => 0,
				50 => 512,
				51 => 256,
				52 => 64,
				53 => 64,
				54 => 192,
				55 => 128,
				56 => 256,
				57 => 512,
				58 => 576,
				59 => 192,
				60 => 0,
				61 => 0,
				62 => 192,
				63 => 448,
				64 => 256,
				65 => 128,
				66 => 256,
				67 => 512,
				68 => 192,
				69 => 512,
				70 => 0,
				71 => 384,
				72 => 320,
				73 => 448,
				74 => 64,
				75 => 320,
				76 => 128,
				77 => 512,
				78 => 64,
				79 => 128,
				80 => 512,
				81 => 576,
				82 => 320,
				83 => 448,
				84 => 0,
				85 => 448,
				86 => 512,
				87 => 512,
				88 => 0,
				89 => 128,
				90 => 192,
				91 => 256,
				92 => 256,
				93 => 320,
				94 => 256,
				95 => 512,
				96 => 448,
				97 => 256,
				98 => 576,
				99 => 128,
				others => 0
		);
	

BEGIN
		-- divisor de frecuencia
		PROCESS(clk)
		variable limit : integer := 0;
			BEGIN
				IF rising_edge(clk) THEN
					IF limit = 5000000 THEN
						limit := 0;
						clk_fsm <= '1';
					ELSE
						limit := limit + 1;
						clk_fsm <= '0';
					END IF;
				END IF;
			END PROCESS;
		
		--fsm
		PROCESS( clk_fsm, rst_9 )
			BEGIN
				IF( rst_9 = '1' )THEN
					pr_state_9 <= state_1_9;
				ELSIF rising_edge( clk_fsm ) THEN
					pr_state_9 <= nx_state_9;
			END IF;
		END PROCESS;
		
		-- State transitions / conditions
		PROCESS( pr_state_9 )
			BEGIN
				CASE pr_state_9 IS
					--Estado 1
					when state_1_9 =>
						nx_state_9 <= state_2_9;
						
					--Estado 2
					WHEN state_2_9 =>
						nx_state_9 <= state_3_9;
						
					--Estado 3
					WHEN state_3_9 =>
						if cont = 12 or puntaje = '0' then
							nx_state_9 <= state_1_9;
						elsif cont < 12 then
							nx_state_9 <= state_3_9;
						end if;
						
				END CASE;
		END PROCESS;

-------------------------------------------------------
--Part 1: CONTROL GENERATOR
-------------------------------------------------------		
		--Static signals for DACs:
		BLANKn 	<= '1'; --no direct blanking
		SYNCn 	<= '0'; --no sync on green
		
		--Create pixel clock (50MHz->25MHz):
		PROCESS( clk )
		BEGIN
			IF rising_edge( clk ) THEN 
				clk_vga <= not clk_vga;
			END IF;
		END PROCESS;
	
		--Horizontal signals generation:
		PROCESS( clk_vga )
			VARIABLE Hcount:	natural RANGE 0 to H_LOW + HBP + H_HIGH + HFP;
		BEGIN
			IF rising_edge( clk_vga ) THEN 
				Hcount := Hcount + 1;
				IF Hcount = H_LOW THEN 
					Hsync 	<= '1';
				ELSIF Hcount = H_LOW + HBP THEN 
					Hactive 	<= '1';
				ELSIF Hcount = H_LOW + HBP + H_HIGH THEN 
					Hactive 	<= '0';
				ELSIF Hcount = H_LOW + HBP + H_HIGH + HFP THEN 
					Hsync 	<= '0'; 
					Hcount 	:=  0;
				END IF;
			END IF;
		END PROCESS;
		
		--Vertical signals generation:
		PROCESS( Hsync )
			VARIABLE Vcount:	natural RANGE 0 TO V_LOW + VBP + V_HIGH + VFP;
		BEGIN
			IF rising_edge( Hsync ) THEN 
				Vcount := Vcount + 1;
				IF Vcount = V_LOW THEN 
					Vsync 	<= '1';
				ELSIF Vcount = V_LOW + VBP THEN 
					Vactive 	<= '1';
				ELSIF Vcount = V_LOW + VBP + V_HIGH THEN 
					Vactive 	<= '0';
				ELSIF Vcount = V_LOW + VBP + V_HIGH + VFP THEN 
					Vsync 	<= '0'; 
					Vcount 	:=  0;
				END IF;
			END IF;
		END PROCESS;
	
		H_sync <= Hsync;
		V_sync <= Vsync;
	
		---Display enable generation:
		dena <= Hactive and Vactive;
	
-------------------------------------------------------
--Part 2: IMAGE GENERATOR
-------------------------------------------------------
	----------------------
			--rom
				process (clk_fsm)
				begin
					if (clk_fsm'event and clk_fsm='1') then 
						reg_address <= address;
					end if;
				end process;
				
			--Get unregistered output
				data_out <= myrom(reg_address);
			
			
			----------------------


	--State actions
		PROCESS( Hsync, Vactive, Hactive, dena, clk, clk_fsm )
		VARIABLE line_count:	natural RANGE 0 TO V_HIGH;
		VARIABLE colum_count:	natural RANGE 0 TO H_HIGH;
		VARIABLE l:	natural := 0;
		variable c:	natural;
		--variable i: natural;
		
		BEGIN
		
		and1(0) <= not (sw(9) or sw(8) or sw(7) or sw(6) or sw(5) or sw(4) or sw(3) or sw(2) or sw(1));
		and1(1) <= not (sw(9) or sw(8) or sw(7) or sw(6) or sw(5) or sw(4) or sw(3) or sw(2) or sw(0));
		and1(2) <= not (sw(9) or sw(8) or sw(7) or sw(6) or sw(5) or sw(4) or sw(3) or sw(1) or sw(0));
		and1(3) <= not (sw(9) or sw(8) or sw(7) or sw(6) or sw(5) or sw(4) or sw(2) or sw(1) or sw(0));
		and1(4) <= not (sw(9) or sw(8) or sw(7) or sw(6) or sw(5) or sw(3) or sw(2) or sw(1) or sw(0));
		and1(5) <= not (sw(9) or sw(8) or sw(7) or sw(6) or sw(4) or sw(3) or sw(2) or sw(1) or sw(0));
		and1(6) <= not (sw(9) or sw(8) or sw(7) or sw(5) or sw(4) or sw(3) or sw(2) or sw(1) or sw(0));
		and1(7) <= not (sw(9) or sw(8) or sw(6) or sw(5) or sw(4) or sw(3) or sw(2) or sw(1) or sw(0));
		and1(8) <= not (sw(9) or sw(7) or sw(6) or sw(5) or sw(4) or sw(3) or sw(2) or sw(1) or sw(0));
		and1(9) <= not (sw(8) or sw(7) or sw(6) or sw(5) or sw(4) or sw(3) or sw(2) or sw(1) or sw(0));
		
				IF rising_edge( clk_fsm ) THEN
					CASE pr_state_9 IS
						--Estado 1
						WHEN state_1_9 =>
							cont <= 0;
							puntaje <= '1';
							c := 700;
							l := 32;
							
						--Estado 2
						WHEN state_2_9 =>
							c:= data_out; -- lista de valores
							l:= 0;
							address <= address + 1;
							puntaje <= '1';
							
							
							
						--Estado 3
						WHEN state_3_9 =>
							if cont < 12 then
								cont <= cont + 1;
								l := l + 32;
							else
								cont <= cont;
							end if;
							
							if ( l > 316 and l < 415) then
								if  (sw(9) = '1' and sw(8) = '0' and sw(7) = '0' and sw(6) = '0' and sw(5) = '0' and sw(4) = '0' and sw(3) = '0' and sw(2) = '0' and sw(1) = '0' and sw(0) = '0' and c = 0 )then
									puntaje <= '0';
									
								elsif (sw(9) = '0' and sw(8) = '1' and sw(7) = '0' and sw(6) = '0' and sw(5) = '0' and sw(4) = '0' and sw(3) = '0' and sw(2) = '0' and sw(1) = '0' and sw(0) = '0' and c = 64 )then
									puntaje <= '0';
								
								elsif (sw(9) = '0' and sw(8) = '0' and sw(7) = '1' and sw(6) = '0' and sw(5) = '0' and sw(4) = '0' and sw(3) = '0' and sw(2) = '0' and sw(1) = '0' and sw(0) = '0' and c = 128 )then
									puntaje <= '0';
									
								elsif (sw(9) = '0' and sw(8) = '0' and sw(7) = '0' and sw(6) = '1' and sw(5) = '0' and sw(4) = '0' and sw(3) = '0' and sw(2) = '0' and sw(1) = '0' and sw(0) = '0' and c = 192 )then
									puntaje <= '0';
									
								elsif (sw(9) = '0' and sw(8) = '0' and sw(7) = '0' and sw(6) = '0' and sw(5) = '1' and sw(4) = '0' and sw(3) = '0' and sw(2) = '0' and sw(1) = '0' and sw(0) = '0' and c = 256 )then
									puntaje <= '0';
									
								elsif (sw(9) = '0' and sw(8) = '0' and sw(7) = '0' and sw(6) = '0' and sw(5) = '0' and sw(4) = '1' and sw(3) = '0' and sw(2) = '0' and sw(1) = '0' and sw(0) = '0' and c = 320 )then
									puntaje <= '0';
									
								elsif (sw(9) = '0' and sw(8) = '0' and sw(7) = '0' and sw(6) = '0' and sw(5) = '0' and sw(4) = '0' and sw(3) = '1' and sw(2) = '0' and sw(1) = '0' and sw(0) = '0' and c = 384 )then
									puntaje <= '0';
									
								elsif (sw(9) = '0' and sw(8) = '0' and sw(7) = '0' and sw(6) = '0' and sw(5) = '0' and sw(4) = '0' and sw(3) = '0' and sw(2) = '1' and sw(1) = '0' and sw(0) = '0' and c = 448 )then
									puntaje <= '0';
									
								elsif (sw(9) = '0' and sw(8) = '0' and sw(7) = '0' and sw(6) = '0' and sw(5) = '0' and sw(4) = '0' and sw(3) = '0' and sw(2) = '0' and sw(1) = '1' and sw(0) = '0' and c = 512 )then
									puntaje <= '0';
									
								elsif (sw(9) = '0' and sw(8) = '0' and sw(7) = '0' and sw(6) = '0' and sw(5) = '0' and sw(4) = '0' and sw(3) = '0' and sw(2) = '0' and sw(1) = '0' and sw(0) = '1' and c = 576 )then
									puntaje <= '0';
									
								else
									puntaje <= '1';
								
								end if;
							else
								puntaje <= '1';
							end if;
							
					END CASE;
				END IF;
		----------------------------
		

		-- contadorline
		IF rising_edge( Hsync ) THEN
			IF Vactive = '1' THEN
				line_count := line_count + 1;
			ELSE
				line_count := 0;
			END IF;
		END IF;
		
		-- contadorcolumna
		IF rising_edge( clk_vga ) THEN
			IF Hactive = '1' THEN
				colum_count := colum_count + 1;
			ELSE
				colum_count 	:=  0;
			END IF;
		END IF;
		
		--
		IF dena = '1' THEN
			
				if (line_count > 415 and line_count < 480 and colum_count > 0 and colum_count < 64) then
					
					if (sw(9) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(9) = '1' and l > 316 and l < 415 and c = 0 and and1(9) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(9) = '0' and l > 316 and l < 415 and c = 0) or (sw(9) = '1' and and1(9) = '0' and c = 0) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
					
				elsif (line_count > 415 and line_count < 480 and colum_count > 64 and colum_count < 128) then
					if (sw(8) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(8) = '1' and l > 316 and l < 415 and c = 64 and and1(8) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(8) = '0' and l > 316 and l < 415 and c = 64) or (sw(8) = '1' and and1(8) = '0' and c = 64) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
					
				elsif (line_count > 415 and line_count < 480 and colum_count > 128 and colum_count < 192) then
					if (sw(7) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(7) = '1' and l > 316 and l < 415 and c = 128 and and1(7) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(7) = '0' and l > 316 and l < 415 and c = 128) or (sw(7) = '1' and and1(7) = '0' and c = 128) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
					
				elsif (line_count > 415 and line_count < 480 and colum_count > 192 and colum_count < 256) then
					if (sw(6) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(6) = '1' and l > 316 and l < 415 and c = 192 and and1(6) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(6) = '0' and l > 316 and l < 415 and c = 192) or (sw(6) = '1' and and1(6) = '0' and c = 192) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
					
				elsif (line_count > 415 and line_count < 480 and colum_count > 256 and colum_count < 320) then
					if (sw(5) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(5) = '1' and l > 316 and l < 415 and c = 256 and and1(5) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(5) = '0' and l > 316 and l < 415 and c = 256) or (sw(5) = '1' and and1(5) = '0' and c = 256) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
					
				elsif (line_count > 415 and line_count < 480 and colum_count > 320 and colum_count < 384) then
					if (sw(4) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(4) = '1' and l > 316 and l < 415 and c = 320 and and1(4) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(4) = '0' and l > 316 and l < 415 and c = 320) or (sw(4) = '1' and and1(4) = '0' and c = 320) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
					
				elsif (line_count > 415 and line_count < 480 and colum_count > 384 and colum_count < 448) then
					if (sw(3) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(3) = '1' and l > 316 and l < 415 and c = 384 and and1(3) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(3) = '0' and l > 316 and l < 415 and c = 384) or (sw(3) = '1' and and1(3) = '0' and c = 384) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
					
				elsif (line_count > 415 and line_count < 480 and colum_count > 448 and colum_count < 512) then
					if (sw(2) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(2) = '1' and l > 316 and l < 415 and c = 448 and and1(2) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(2) = '0' and l > 316 and l < 415 and c = 448) or (sw(2) = '1' and and1(2) = '0' and c = 448) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
		
				elsif (line_count > 415 and line_count < 480 and colum_count > 512 and colum_count < 576) then
					if (sw(1) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(1) = '1' and l > 316 and l < 415 and c = 512 and and1(1) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(1) = '0' and l > 316 and l < 415 and c = 512) or (sw(1) = '1' and and1(1) = '0' and c = 512) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
					
				elsif (line_count > 415 and line_count < 480 and colum_count > 576 and colum_count < 640) then
					if (sw(0) = '1' and l < 316 ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
					
					elsif (sw(0) = '1' and l > 316 and l < 415 and c = 576 and and1(0) = '1' ) then
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif ((sw(0) = '0' and l > 316 and l < 415 and c = 576) or (sw(0) = '1' and and1(0) = '0' and c = 576) ) then
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					else 
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );	
					end if;
					

				elsif (line_count > l and line_count < (l + 64) and (colum_count > c) and (colum_count < (c + 64))) then
					
					if c = 0 then
						--verde
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif c = 64 then
						--rojo
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
					
					elsif c = 128 then
						--amarillo
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif c = 192 then
						--azul
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '1' );
						
					elsif c = 256 then
						--rosa
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '1' );
						
					elsif c = 320 then
						--azul claro
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '1' );
						
					elsif c = 384 then
						--verde
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif c = 448 then
						--rojo
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '0' );
						
					elsif c = 512 then
						--amarillo
						R <= ( OTHERS => '1' );
						G <= ( OTHERS => '1' );
						B <= ( OTHERS => '0' );
						
					elsif c = 576 then
						--azul
						R <= ( OTHERS => '0' );
						G <= ( OTHERS => '0' );
						B <= ( OTHERS => '1' );
						
					end if;
					
				elsif (line_count > 380 and line_count < 385 and colum_count > 0 and colum_count < 640) then
					R <= ( OTHERS => '1' );
					G <= ( OTHERS => '1' );
					B <= ( OTHERS => '1' );
					
				else
					R <= ( OTHERS => '0' );
					G <= ( OTHERS => '0' );
					B <= ( OTHERS => '0' );
				end if;
				

			
			
			
----------------------------------------
		ELSE			
			R <= (OTHERS => '0');
			G <= (OTHERS => '0');
			B <= (OTHERS => '0');
		END IF;
	END PROCESS;	
	
END ARCHITECTURE;