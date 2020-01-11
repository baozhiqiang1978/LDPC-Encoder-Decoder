LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY test_New_Message IS
GENERIC(
	-- Define Generics
	 N :natural := 10 -- Length of Codeword Bits
);

END test_New_Message;



ARCHITECTURE behav OF test_New_Message IS

COMPONENT New_Message IS

PORT(
	-- Clock and Reset
	clk 		: IN std_logic;
	rstb 		: IN std_logic;


	-- Input Interface I/O
	isop 		: IN std_logic
);

END COMPONENT;

-- Define Signals

	signal CycleNumber : integer;

	signal clk_i 		: std_logic;
	signal rstb_i 		: std_logic;
	signal isop_i 		:  std_logic;


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
	test: New_Message 	PORT MAP( 	clk => clk_i,
				       		rstb => rstb_i,
						isop => isop_i
				        );
	-- Perform Test
	Do_Test:
	PROCESS
	BEGIN

	
	WAIT FOR 20 ns;

	isop_i	<= '1';
        WAIT FOR 15 ns;
	isop_i	<= '0';
	


	WAIT FOR 100 ns;


	isop_i	<= '1';
        WAIT FOR 15 ns;
	isop_i	<= '0';


	WAIT FOR 100 ns;

	isop_i	<= '1';	
        WAIT FOR 15 ns;
	isop_i	<= '0';



	END PROCESS Do_Test;


END behav;
