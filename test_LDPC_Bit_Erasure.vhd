LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY test_Bit_Erasure IS
GENERIC(
	-- Define Generics
	 C : integer := 10 -- Length of Codeword Bits
);

END test_Bit_Erasure;



ARCHITECTURE behav OF test_Bit_Erasure IS

COMPONENT Bit_Erasure IS

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	isop : IN std_logic;
	code_data : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	error_data : OUT std_logic_vector (C-1 downto 0)
);

END COMPONENT;

-- Define Signals

	signal CycleNumber : integer;

	signal clk_i 	: std_logic;
	signal rstb_i 	: std_logic;
	signal isop_i 	:  std_logic;
	signal code_data_i 	:  std_logic_vector(C-1 downto 0);
	signal edone_i 	:  std_logic;
	signal error_data_i 	:  std_logic_vector (C-1 downto 0);

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
	test: Bit_Erasure PORT MAP( 	clk => clk_i,
				       	rstb => rstb_i,
					isop => isop_i,
					code_data => code_data_i,
					edone => edone_i,
					error_data => error_data_i
				        );


	-- Perform Test
	Do_Test:
	PROCESS
	BEGIN

	WAIT FOR 5 ns;

	isop_i	<= '1';
	code_data_i	<= ("1101101001");
        WAIT FOR 15 ns;
	isop_i	<= '0';
	


	WAIT FOR 100 ns;


	isop_i	<= '1';
	code_data_i	<= ("0010011110");
        WAIT FOR 15 ns;
	isop_i	<= '0';


	WAIT FOR 100 ns;

	isop_i	<= '1';
	code_data_i	<= ("1010110100");
        WAIT FOR 15 ns;
	isop_i	<= '0';


	END PROCESS Do_Test;


END behav;
