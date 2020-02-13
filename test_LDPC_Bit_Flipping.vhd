LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY test_Bit_Flipping IS
GENERIC(
	-- Define Generics
	 N :natural := 10 -- Length of Codeword Bits
);

END test_Bit_Flipping;



ARCHITECTURE behav OF test_Bit_Flipping IS

COMPONENT Bit_Flipping IS

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	isop : IN std_logic;
	input_data : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	msg_decode_done : OUT std_logic;
	odata : OUT std_logic_vector (N-1 downto N-5)
);

END COMPONENT;

-- Define Signals

	signal CycleNumber : integer;

	signal clk_i 		: std_logic;
	signal rstb_i 		: std_logic;
	signal isop_i 		:  std_logic;
	signal input_data_i 	:  std_logic_vector(N-1 downto 0);
	signal msg_decode_done_i 	:  std_logic;
	signal odata_i 		:  std_logic_vector (N-1 downto N-5);

BEGIN

	-- Generate Clock
	GenerateCLK:
	PROCESS
	VARIABLE TimeHigh : time := 5 ns;
	VARIABLE TimeLow : time := 5 ns;
	VARIABLE CycleCount: integer := 0;
 
	BEGIN
	clk_i <= '1';
	WAIT FOR TimeHigh;
	clk_i <= '0';
	WAIT FOR TimeLow;

	--Handle Reset
	CycleCount := CycleCount + 1;
	CycleNumber <= CycleCount AFTER 1 ns;

	END PROCESS GenerateCLK;


	-- Generate Global Reset
	GenerateRSTB:
	PROCESS(CycleNumber)
	VARIABLE ResetTime : INTEGER := 2000;
	
	BEGIN
	IF (CycleNumber <= ResetTime) THEN
		rstb_i <= '1' AFTER 1 ns;
	ELSE
		rstb_i <= '0' AFTER 1 ns;
	END IF; 
	END PROCESS GenerateRSTB;


    


	-- Port Map Declaration
	test: Bit_Flipping 	PORT MAP( 	clk => clk_i,
				       		rstb => rstb_i,
						isop => isop_i,
						input_data => input_data_i,
						msg_decode_done => msg_decode_done_i,
						odata => odata_i
				        );


	-- Perform Test
	Do_Test:
	PROCESS
	BEGIN

	
	WAIT FOR 10 ns;

	isop_i	<= '1';
	input_data_i	<= ("1010111001"); -- Original Codeword 0010111001	
        WAIT FOR 15 ns;
	isop_i	<= '0';
	
	WAIT FOR 150 ns;


	isop_i	<= '1';
	input_data_i	<= ("0100100111"); -- Original Codeword 0000100111	
	WAIT FOR 15 ns;
	isop_i	<= '0';
	
	WAIT FOR 150 ns;


	isop_i	<= '1';
	input_data_i	<= ("0111000011"); --  Original Codeword 0101000011
        WAIT FOR 15 ns;
	isop_i	<= '0';

	WAIT FOR 150 ns;

	END PROCESS Do_Test;


END behav;
