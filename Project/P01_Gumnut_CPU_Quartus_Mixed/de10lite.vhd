LIBRARY 	ieee;
USE		ieee.std_logic_1164.all, ieee.numeric_std.all;

ENTITY de10lite IS
	PORT(	
		CLOCK_50	: 	IN			std_logic;
		KEY		: 	IN 		std_logic_vector( 1 DOWNTO 0 );
		SW			: 	IN 		std_logic_vector( 9 DOWNTO 0 );
		VGA_HS	:	OUT		std_logic;
		VGA_VS	:	OUT		std_logic;
		VGA_R		:	OUT		std_logic_vector( 3 DOWNTO 0 );
		VGA_G		:	OUT		std_logic_vector( 3 DOWNTO 0 );
		VGA_B		:	OUT		std_logic_vector( 3 DOWNTO 0 );
		HEX0		:	OUT		std_logic_vector( 6 DOWNTO 0 );
		HEX5		:	OUT		std_logic_vector( 6 DOWNTO 0 );
		LEDR		: 	OUT		std_logic_vector( 9 DOWNTO 0 )
	);
END de10lite;

ARCHITECTURE behavior OF de10lite IS	
	
	component gumnut_with_mem IS
		generic ( 
			IMem_file_name : string := "gasm_text.dat";
			DMem_file_name : string := "gasm_data.dat";
         debug : boolean := false );
		port ( clk_i : in std_logic;
         rst_i : in std_logic;
         -- I/O port bus
         port_cyc_o : out std_logic;
         port_stb_o : out std_logic;
         port_we_o : out std_logic;
         port_ack_i : in std_logic;
         port_adr_o : out unsigned(7 downto 0);
         port_dat_o : out std_logic_vector(7 downto 0);
         port_dat_i : in std_logic_vector(7 downto 0);
         -- Interrupts
         int_req : in std_logic;
         int_ack : out std_logic );
	end COMPONENT gumnut_with_mem;
	COMPONENT DECODER_equipo9 IS
	PORT(
		SelSw_9:	IN		STD_LOGIC_VECTOR( 3 DOWNTO 0 );
		Seg7_9:	OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 ));
	END COMPONENT;
	
	component vga_9 IS 
		PORT(
			clk, rst_9: 					IN 	std_logic; --50MHz in our board
			H_sync, V_sync: 	OUT	std_logic;
			BLANKn, SYNCn : 	OUT 	std_logic;
			R, G, B: 			OUT 	std_logic_vector(3 DOWNTO 0);
			puntaje		  :	buffer 	std_logic;
			sw				  : 	in 	std_logic_vector(9 downto 0)
		);
	END component;

	
	SIGNAL 	clk_i, rst_i, 
				port_cyc_o, port_stb_o, 
				port_we_o, port_ack_i, 
				int_req, int_ack			: 	std_logic;
	SIGNAL 	port_dat_o, port_dat_i	:	std_logic_vector( 7 downto 0 );
	SIGNAL   port_adr_o					:	unsigned( 7 DOWNTO 0 );
	SIGNAL   SelSw_9                 :  std_logic_vector(3 downto 0);
	SIGNAL   SelSw_9_2               :  std_logic_vector(3 downto 0);
	signal BLANKn, SYNCn : std_logic;
	signal puntaje : std_logic;
	
	
BEGIN
	clk_i 		<= CLOCK_50;
	rst_i 		<= not KEY( 0 );
	port_ack_i 	<= '1';
	
	BLANKn 	<= '0'; 
	SYNCn 	<= '0';
	
	gumnut	:	COMPONENT gumnut_with_mem 
						PORT MAP(
							clk_i,
							rst_i,
							port_cyc_o,
							port_stb_o,
							port_we_o,
							port_ack_i,
							port_adr_o( 7 DOWNTO 0 ),
							port_dat_o( 7 DOWNTO 0 ),
							port_dat_i( 7 DOWNTO 0 ),
							int_req,
							int_ack
						);	
						
	vga: vga_9 port map (CLOCK_50, rst_i, VGA_HS , VGA_VS, BLANKn, SYNCn, VGA_R , VGA_G, VGA_B, puntaje, sw);
	
	leds     :   PROCESS (clk_i)
						BEGIN
							IF rising_edge(clk_i) THEN
								IF port_adr_o = "00000000" and port_cyc_o = '1' and port_stb_o = '1' and port_we_o = '1' THEN
									LEDR(7 DOWNTO 0) <= port_dat_o(7 DOWNTO 0);
								END IF;
							END IF;
					 END PROCESS;
					 
	disphex0 :   PROCESS (clk_i)
						BEGIN
							IF rising_edge(clk_i) THEN
								IF port_adr_o = "00000001" and port_cyc_o = '1' and port_stb_o = '1' and port_we_o = '1' THEN
									SelSw_9(3 DOWNTO 0) <= port_dat_o(3 DOWNTO 0);
								END IF;
							END IF;
					 END PROCESS;
					 
	hexa    :   DECODER_equipo9 port map(SelSw_9(3 downto 0), HEX0(6 downto 0));
					 
	button :   PROCESS (clk_i)
						BEGIN
							IF rising_edge(clk_i) THEN
								IF port_cyc_o = '1' and port_stb_o = '1' and port_we_o = '0' THEN
									port_dat_i(1 DOWNTO 0) <= (not KEY(1)) & puntaje;
								END IF;
							END IF;
					 END PROCESS;
					 
					 
	disphex2 :   PROCESS (clk_i)
						BEGIN
							IF rising_edge(clk_i) THEN
								IF port_adr_o = "00000011" and port_cyc_o = '1' and port_stb_o = '1' and port_we_o = '1' THEN
									SelSw_9_2(3 DOWNTO 0) <= port_dat_o(3 DOWNTO 0);
								END IF;
							END IF;
					 END PROCESS;
					 
	hexa2    :   DECODER_equipo9 port map(SelSw_9_2(3 downto 0), HEX5(6 downto 0));
	
	
	
								
END behavior;