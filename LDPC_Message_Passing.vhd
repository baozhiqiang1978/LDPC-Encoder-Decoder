LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY Message_Passing IS

GENERIC(
	-- Define Generics
	 N :natural := 10 -- Length of Codeword Bits
);

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	isop : IN std_logic;
	error_data : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	msg_pass_done : OUT std_logic;
	odata : OUT std_logic_vector (N-1 downto 0)
);

END Message_Passing;



ARCHITECTURE behav OF Message_Passing IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET,IDLE,P_CNT1,P_CNT2,P_CNT3,P_CNT4,P_CNT5,P_CNT6,P_CNT7,P_CNT8,P_CNT9,P_CNT10,P_ONE,P_TWO,P_THREE,P_FOUR,P_FIVE, CODE_CHECK, VERIFY,ERROR, DONE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
SIGNAL pcheck1 : integer; --Counts the number of Error in each P Check Eqn 1
SIGNAL pcheck2 : integer; -- Eqn 2
SIGNAL pcheck3 : integer; -- Eqn 3
SIGNAL pcheck4 : integer; -- Eqn 4
SIGNAL pcheck5 : integer; -- Eqn 5
SIGNAL fix_count : integer; -- Hold the count of 0 and 1 in the code
SIGNAL verify_code: std_logic; -- Signals if any of the bits is not 0 or 1
SIGNAL idata : std_logic_vector (N-1 downto 0);


BEGIN


	clock_state_machine:
	PROCESS(clk,rstb)

	BEGIN
	IF (rstb /= '1') THEN
	current_state <= ONRESET;
	ELSIF (clk'EVENT and clk = '1') THEN
	current_state <= next_state;
	END IF;

	END PROCESS clock_state_machine;




	sequential:
	PROCESS(clk,rstb)
	BEGIN

	CASE current_state IS
	

	WHEN ONRESET =>
		next_state <= IDLE;

	WHEN IDLE =>
	IF( isop = '1') THEN
		next_state <= P_CNT1;
	ELSE
		next_state <= IDLE;
	END IF;

	
	WHEN P_CNT1 =>
		next_state <= P_CNT2;

	WHEN P_CNT2 =>
		next_state <= P_CNT3;

	WHEN P_CNT3 =>
		next_state <= P_CNT4;

	WHEN P_CNT4 =>
		next_state <= P_CNT5;

	WHEN P_CNT5 =>
		next_state <= P_CNT6;

	WHEN P_CNT6 =>
		next_state <= P_CNT7;

	WHEN P_CNT7 =>
		next_state <= P_CNT8;

	WHEN P_CNT8 =>
		next_state <= P_CNT9;

	WHEN P_CNT9 =>
		next_state <= P_CNT10;

	WHEN P_CNT10 =>
	IF (pcheck1/2 = 1) THEN
		next_state <= P_ONE;
	ELSIF(pcheck2/2 = 1) THEN
		next_state <= P_TWO;
	ELSIF(pcheck3/2 = 1) THEN
		next_state <= P_THREE;
	ELSIF(pcheck4/2 = 1) THEN
		next_state <= P_FOUR;
	ELSIF(pcheck5/2 = 1) THEN
		next_state <= P_FIVE;
	ELSE
		next_state <= ERROR;
	END IF;

--------------------------------------------------------
	WHEN P_ONE =>
	IF(pcheck2/2 = 1) THEN
		next_state <= P_TWO;
	ELSIF(pcheck3/2 = 1) THEN
		next_state <= P_THREE;
	ELSIF(pcheck4/2 = 1) THEN
		next_state <= P_FOUR;
	ELSIF(pcheck5/2 = 1) THEN
		next_state <= P_FIVE;
	ELSE
		next_state <= CODE_CHECK;
	END IF;
----------------------------------------------------------


	WHEN P_TWO =>
	IF(pcheck3/2 = 1) THEN
		next_state <= P_THREE;
	ELSIF(pcheck4/2 = 1) THEN
		next_state <= P_FOUR;
	ELSIF(pcheck5/2 = 1) THEN
		next_state <= P_FIVE;
	ELSE
		next_state <= CODE_CHECK;
	END IF;
-----------------------------------------------------------


	WHEN P_THREE =>
	IF(pcheck4/2 = 1) THEN
		next_state <= P_FOUR;
	ELSIF(pcheck5/2 = 1) THEN
		next_state <= P_FIVE;
	ELSE
		next_state <= CODE_CHECK;
	END IF;
	
------------------------------------------------------------

	WHEN P_FOUR =>
	IF(pcheck5/2 = 1) THEN
		next_state <= P_FIVE;
	ELSE
		next_state <= CODE_CHECK;
	END IF;

-----------------------------------------------------------
	WHEN P_FIVE =>
		next_state <= CODE_CHECK;
-----------------------------------------------------------
	WHEN CODE_CHECK =>
		next_state <= VERIFY;
----------------------------------------------------------

	WHEN VERIFY =>
	IF(verify_code = '1') THEN
		next_state <= DONE;
	ELSE
		next_state <= P_CNT1;
	END IF;

	WHEN ERROR =>
		next_state <= ONRESET;


	WHEN DONE =>
		next_state <= ONRESET;


	WHEN OTHERS =>
		next_state <= ONRESET;


	END CASE;

	END PROCESS sequential;

------------------------------------------------------------

	combinational:
	PROCESS(clk, rstb)	
	BEGIN

	IF ( current_state = ONRESET) THEN
 		odata <= "UUUUUUUUUU" ;
		msg_pass_done <= 'U';
		verify_code<= 'U'; 
		
	END IF;

	IF (current_state = IDLE) THEN
		idata <= error_data;
		pcheck1 <= 0;
		pcheck2 <= 0;
		pcheck3 <= 0;
		pcheck4 <= 0;
		pcheck5 <= 0;
		fix_count <= 0;
	
	END IF;

-------------------------------------------------------------(9)
	IF (current_state = P_CNT1) THEN
	
	IF (idata(N-1) = '0') THEN
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck5 <= pcheck5;
        ELSIF (idata(N-1) = '1' ) THEN
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck5 <= pcheck5;
	ELSE
		pcheck2 <= pcheck2 + 1;
		pcheck3 <= pcheck3 + 1;
		pcheck5 <= pcheck5 + 1;
	END IF;
	END IF;
---------------------------------------------------------------(8)
	IF (current_state = P_CNT2) THEN
	
	IF (idata(N-2) = '0') THEN
	    	pcheck1 <= pcheck1;
		pcheck5 <= pcheck5;
        ELSIF (idata(N-2) = '1' ) THEN
	    	pcheck1 <= pcheck1;
		pcheck5 <= pcheck5;
	ELSE
		pcheck1 <= pcheck1 + 1;
		pcheck5 <= pcheck5 + 1;
	END IF;
	END IF;
---------------------------------------------------------------(7)

	IF (current_state = P_CNT3) THEN
	
	IF (idata(N-3) = '0') THEN
		pcheck1 <= pcheck1;
		pcheck2 <= pcheck2;
	    	pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
        ELSIF (idata(N-3) = '1' ) THEN
		pcheck1 <= pcheck1;
		pcheck2 <= pcheck2;
	    	pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
	ELSE
		pcheck1 <= pcheck1 + 1;
		pcheck2 <= pcheck2 + 1;
	    	pcheck3 <= pcheck3 + 1;
		pcheck4 <= pcheck4 + 1;
	END IF;
	END IF;

---------------------------------------------------------------(6)

	IF (current_state = P_CNT4) THEN
	
	IF (idata(N-4) = '0') THEN
		pcheck1 <= pcheck1;
		pcheck4 <= pcheck4;
        ELSIF (idata(N-4) = '1' ) THEN
		pcheck1 <= pcheck1;
		pcheck4 <= pcheck4;
	ELSE
		pcheck1 <= pcheck1 + 1;
		pcheck4 <= pcheck4 + 1;
	END IF;
	END IF;

----------------------------------------------------------------(5)

	IF (current_state = P_CNT5) THEN
	
	IF (idata(N-5) = '0') THEN
		pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
		pcheck5 <= pcheck5;
        ELSIF (idata(N-5) = '1' ) THEN
	    	pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
		pcheck5 <= pcheck5;
	ELSE
	    	pcheck3 <= pcheck3 + 1;
		pcheck4 <= pcheck4 + 1;
		pcheck5 <= pcheck5 + 1;
	END IF;
	END IF;

-----------------------------------------------------------------(4)

	IF (current_state = P_CNT6) THEN
	
	IF (idata(N-6) = '0') THEN
	    	pcheck1 <= pcheck1;
        ELSIF (idata(N-6) = '1' ) THEN
		pcheck1 <= pcheck1;
	ELSE
		pcheck1 <= pcheck1 + 1;
	END IF;
	END IF;

------------------------------------------------------------------(3)

	IF (current_state = P_CNT7) THEN
	
	IF (idata(N-7) = '0') THEN
	    	pcheck2 <= pcheck2;
        ELSIF (idata(N-7) = '1' ) THEN
		pcheck2 <= pcheck2;
	ELSE
		pcheck2 <= pcheck2 + 1;
	END IF;
	END IF;
--------------------------------------------------------------------(2)
	
	IF (current_state = P_CNT8) THEN
	
	IF (idata(N-8) = '0') THEN
		pcheck3 <= pcheck3;
        ELSIF (idata(N-8) = '1' ) THEN
		pcheck3 <= pcheck3;
	ELSE
		pcheck3 <= pcheck3 + 1;
	END IF;
	END IF;

-------------------------------------------------------------------(1)

	IF (current_state = P_CNT9) THEN
	
	IF (idata(N-9) = '0') THEN
		pcheck4 <= pcheck4;
        ELSIF (idata(N-9) = '1' ) THEN
		pcheck4 <= pcheck4;
	ELSE
		pcheck4 <= pcheck4 + 1;
	END IF;
	END IF;

------------------------------------------------------------------(0)

	IF (current_state = P_CNT10) THEN
	
	IF (idata(N-10) = '0') THEN
		pcheck5 <= pcheck5;
        ELSIF (idata(N-10) = '1' ) THEN
		pcheck5 <= pcheck5;
	ELSE
		pcheck5 <= pcheck5 + 1;
	END IF;
	END IF;

-----------------------------------------------------------------------------


	IF ( current_state = P_ONE) THEN	

	IF( idata(N-2) /= '0') and (idata(N-2) /= '1') THEN 		--(8)
	idata(N-2) <=  idata(N-3) xor idata(N-4) xor idata(N-6);
	ELSIF( idata(N-3) = '0') or (idata(N-3) /= '1') THEN		--(7)
	idata(N-3) <=  idata(N-2) xor idata(N-4) xor idata(N-6);
	ELSIF( idata(N-4) /= '0') or (idata(N-4) /= '1') THEN		--(6)
	idata(N-4) <=  idata(N-2) xor idata(N-3) xor idata(N-6);
	ELSIF( idata(N-6) /= '0') or (idata(N-6) /= '1') THEN		--(4)
	idata(N-6) <=  idata(N-2) xor idata(N-3) xor idata(N-4);
	END IF;

	END IF;


	IF ( current_state = P_TWO) THEN	

	IF( idata(N-1) /= '0') or (idata(N-1) /= '1') THEN 		--(9)
	idata(N-1) <=  idata(N-3) xor idata(N-7);
	ELSIF( idata(N-3) /= '0') or (idata(N-3) /= '1') THEN		--(7)
	idata(N-3) <=  idata(N-1) xor idata(N-7);
	ELSIF( idata(N-7) /= '0') or (idata(N-7) /= '1') THEN		--(3)
	idata(N-7) <=  idata(N-1) xor idata(N-3);
	END IF;

	END IF;


	IF ( current_state = P_THREE) THEN	

	IF( idata(N-1) /= '0') or (idata(N-1) /= '1') THEN 			--(9)
	idata(N-1) <=  idata(N-3) xor idata(N-5) xor idata(N-8);
	ELSIF( idata(N-3) /= '0') and (idata(N-3) /= '1') THEN			--(7)
	idata(N-3) <=  idata(N-1) xor idata(N-5) xor idata(N-8);
	ELSIF( idata(N-5) /= '0') and (idata(N-5) /= '1') THEN			--(5)
	idata(N-5) <=  idata(N-1) xor idata(N-3) xor idata(N-8);
	ELSIF( idata(N-8) /= '0') and (idata(N-8) /= '1') THEN			--(2)
	idata(N-8) <=  idata(N-1) xor idata(N-3) xor idata(N-5);
	END IF;

	END IF;


	IF ( current_state = P_FOUR) THEN	

	IF( idata(N-3) /= '0') and (idata(N-3) /= '1') THEN 		--(7)
	idata(N-3) <=  idata(N-4) xor idata(N-5) xor idata(N-9);
	ELSIF( idata(N-4) /= '0') and (idata(N-4) /= '1') THEN		--(6)
	idata(N-4) <=  idata(N-3) xor idata(N-5) xor idata(N-9);
	ELSIF( idata(N-5) /= '0') and (idata(N-5) /= '1') THEN		--(5)
	idata(N-5) <=  idata(N-3) xor idata(N-4) xor idata(N-9);
	ELSIF( idata(N-9) /= '0') and (idata(N-9) /= '1') THEN		--(1)
	idata(N-9) <=  idata(N-3) xor idata(N-4) xor idata(N-5);
	END IF;

	END IF;



	IF ( current_state = P_FIVE) THEN	

	IF( idata(N-1) /= '0') and (idata(N-1) /= '1') THEN 		--(9)
	idata(N-1) <=  idata(N-2) xor idata(N-5) xor idata(N-10);
	ELSIF( idata(N-2) /= '0') and (idata(N-2) /= '1') THEN		--(8)
	idata(N-2) <=  idata(N-1) xor idata(N-5) xor idata(N-10);
	ELSIF( idata(N-5) /= '0') and (idata(N-5) /= '1') THEN		--(5)
	idata(N-5) <=  idata(N-1) xor idata(N-2) xor idata(N-10);
	ELSIF( idata(N-10) /= '0') and (idata(N-10) /= '1') THEN	--(0)
	idata(N-10) <=  idata(N-1) xor idata(N-2) xor idata(N-5);
	END IF;

	END IF;


	IF ( current_state = CODE_CHECK) THEN
	--- Use a loop here
	FOR I IN 1 TO 10 LOOP
	IF (idata(N-I) = '0') or (idata(N-I) = '1') THEN
	fix_count <= fix_count + 1;
	ELSE
	fix_count <= fix_count;
	END IF;
	END LOOP;
	END IF;


	IF ( current_state = VERIFY) THEN
	IF (fix_count = 10) THEN  
		verify_code <= '1'; -- All the bit are 0 or 1
	ELSE
		verify_code <= '0';
		pcheck1 <= 0;
		pcheck2 <= 0;
		pcheck3 <= 0;
		pcheck4 <= 0;
		pcheck5 <= 0;
		fix_count <= 0;
	END IF;
	END IF;


	IF ( current_state = DONE) THEN
		msg_pass_done <= '1';
		odata <= idata;
	ELSE 
		msg_pass_done <= '0';
		odata <= "UUUUUUUUUU";
	END IF;

	END PROCESS combinational;


END behav;