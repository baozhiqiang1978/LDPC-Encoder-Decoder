LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;



-- Input and Output Definition
ENTITY Top_Level_LDPC IS

GENERIC(
	-- Define Generics
	 N : integer := 5; -- Length of Message Bits
	 C : integer := 10 -- Length of Codewords
);

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;

	-- Input Interface I/O
	isop : IN std_logic;
	ivalid: IN std_logic;
	in_data : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	dec_done : OUT std_logic;
	out_data : OUT std_logic_vector (N-1 downto 0)

);

END Top_Level_LDPC;


ARCHITECTURE behav OF Top_Level_LDPC IS


-- Define State of the State Machine
TYPE state_type IS (ONRESET,IDLE,ENCODE,NODATA,ENC_VERIFY,ERROR,GEN_ERROR,ADD_ERROR,BITE_VERIFY, LOAD, PARITY_CHK1, PARITY_CHK2, PARITY_CHK3, PARITY_CHK4,HOLD,FIX_1,FIX_2,FIX_3,FIX_4,FIX_5,CODE_CHECK,MP_VERIFY,DEC_VERIFY,DECODE,DONE);


-- Define Signals 

SIGNAL current_state, next_state : state_type;
SIGNAL enc_data : std_logic_vector (N-1 downto 0);
SIGNAL odata_i : std_logic_vector (C-1 downto 0);
SIGNAL enc_code : std_logic;

SIGNAL error1 : integer;
SIGNAL error2 : integer;
SIGNAL error3 : integer;
SIGNAL code_data_i, code_data_s : std_logic_vector (C-1 downto 0);
SIGNAL count1 : std_logic_vector (3 downto 0);
SIGNAL count2 : std_logic_vector (3 downto 0);
SIGNAL count3 : std_logic_vector (3 downto 0);
SIGNAL count : std_logic_vector (2 downto 0);
SIGNAL bite_code, gen_done: std_logic;


SIGNAL pcheck1, pcheck2, pcheck3, pcheck4, pcheck5 : integer; --Counts the number of Error in each P Check Eqn 1
SIGNAL dec_code,mp_code: std_logic; -- Signals if any of the bits is not 0 or 1
SIGNAL idata : std_logic_vector (C-1 downto 0);



BEGIN


	sequential:
	PROCESS(clk,rstb,current_state,isop,ivalid,enc_code,gen_done,dec_code,bite_code,mp_code,pcheck1,pcheck2,pcheck3,pcheck4,pcheck5)
	BEGIN

	CASE current_state IS
	

	WHEN ONRESET =>
	next_state <= IDLE;

	WHEN IDLE =>
	IF( isop = '1' and ivalid = '1') THEN
	next_state <= ENCODE;
	ELSIF (isop = '1' and ivalid = '0') THEN
	next_state <= NODATA;
	ELSE
	next_state <= IDLE;
	END IF;


	WHEN ENCODE =>
	next_state <= ENC_VERIFY;

	WHEN NODATA =>
	IF( isop = '1' and ivalid = '1') THEN
	next_state <= ENCODE;
	ELSIF( ivalid = '1') THEN
	next_state <= ENCODE;
	ELSE
	next_state <= NODATA;
	END IF;

	WHEN ENC_VERIFY =>
	IF(enc_code = '1') THEN
	next_state <= GEN_ERROR;
	ELSIF (enc_code = '0') THEN
	next_state <= ERROR;
	ELSE
	next_state <= ENC_VERIFY;
	END IF;


	WHEN GEN_ERROR =>
	IF (gen_done = '1') THEN
	next_state <= ADD_ERROR;
	ELSE
	next_state <= GEN_ERROR;
	END IF;


	WHEN ADD_ERROR =>
	next_state <= BITE_VERIFY;


	WHEN BITE_VERIFY =>
	IF(bite_code = '0') THEN
	next_state <= ERROR;
	ELSIF (bite_code = '1') THEN
	next_state <= LOAD;
	ELSE
	next_state <= BITE_VERIFY;
	END IF;

	WHEN LOAD =>
	next_state <= PARITY_CHK1;	


	WHEN PARITY_CHK1 =>
	next_state <= PARITY_CHK2;	

	WHEN PARITY_CHK2 =>
      	next_state <= PARITY_CHK3;	
	
	WHEN PARITY_CHK3 =>
	next_state <= PARITY_CHK4;

	WHEN PARITY_CHK4 =>
	next_state <= HOLD;
--------------------------------------------------------------
-- At Hold we have determined the number of errors based on the
-- parity check equations so we can process to fix the error
--------------------------------------------------------------
	WHEN HOLD => 
	IF (pcheck1= 1) THEN
	next_state <= FIX_1;
	ELSIF (pcheck2 = 1) THEN
	next_state <= FIX_2;
	ELSIF (pcheck3 = 1) THEN
	next_state <= FIX_3;
	ELSIF (pcheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF (pcheck5 = 1) THEN
	next_state <= FIX_5;
	ELSIF (pcheck1 = 0) and (pcheck2 = 0) and (pcheck3 = 0) and (pcheck4 = 0) and (pcheck5 = 0) THEN
	next_state <= DONE;
	ELSE
	next_state <= ERROR;
	END IF;

--------------------------------------------------------
	WHEN FIX_1 =>
	IF(pcheck2 = 1) THEN
	next_state <= FIX_2;
	ELSIF(pcheck3 = 1) THEN
	next_state <= FIX_3;
	ELSIF(pcheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF(pcheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
----------------------------------------------------------

	WHEN FIX_2 =>
	IF(pcheck3 = 1) THEN
	next_state <= FIX_3;
	ELSIF(pcheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF(pcheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
-----------------------------------------------------------


	WHEN FIX_3 =>
	IF(pcheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF(pcheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
	
------------------------------------------------------------

	WHEN FIX_4 =>
	IF(pcheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;

-----------------------------------------------------------
	WHEN FIX_5 =>
	next_state <= CODE_CHECK;
----------------------------------------------------------

	WHEN CODE_CHECK =>
	next_state <= MP_VERIFY;
-----------------------------------------------------------

	WHEN MP_VERIFY =>
	IF(mp_code = '1') THEN
	next_state <= DEC_VERIFY;
	ELSE
	next_state <= PARITY_CHK1;
	END IF;
------------------------------------------------------------
	WHEN DEC_VERIFY =>
	IF(dec_code = '1') THEN
	next_state <= DECODE;
	ELSIF (dec_code = '0') THEN
	next_state <= ERROR;
	ELSE
	next_state <= DEC_VERIFY;
	END IF;
---------------------------------------
	WHEN DECODE =>
	next_state <= DONE;

	WHEN DONE =>
	next_state <= ONRESET;

	WHEN ERROR =>
	next_state <= ONRESET;

	WHEN OTHERS =>
	next_state <= ONRESET;




	END CASE;
	END PROCESS sequential;


	clock_state_machine:
	PROCESS(clk,rstb)
	BEGIN
	IF (rstb /= '1') THEN
	current_state <= ONRESET;
	ELSIF (clk'EVENT and clk = '1') THEN
	current_state <= next_state;
	END IF;
	END PROCESS clock_state_machine;


	combinational:
	PROCESS(clk, rstb)
	BEGIN

	IF ( clk'EVENT and clk = '0') THEN

	IF (current_state = ONRESET) THEN
	enc_code<= 'U';
	gen_done <= 'U';  
	dec_code <= 'U';
	bite_code <= 'U';
	mp_code <= 'U';
	enc_data <= (OTHERS => 'U');
	code_data_i <= (OTHERS => 'U');
	code_data_s <= (OTHERS => 'U');
	odata_i <= (OTHERS => 'U');
	END IF;


	IF (current_state = IDLE) THEN
	enc_data <= in_data;
	count <= "011";
	count1 <= (OTHERS => '0');
	count2 <= (OTHERS => '0');
	count3 <= (OTHERS => '0');
	error1 <= 8;
	error2 <= 5;
	error3 <= 2;
	pcheck1 <= 0;
	pcheck2 <= 0;
	pcheck3 <= 0;
	pcheck4 <= 0;
	pcheck5 <= 0;
	END IF;

	IF (current_state = ENCODE) THEN
	odata_i(C-1) <= (enc_data(N-1) and '1') xor (enc_data(N-2) and '0') xor (enc_data(N-3) and '0') xor (enc_data(N-4) and '0') xor (enc_data(N-5) and '0');	
	odata_i(C-2) <= (enc_data(N-1) and '0') xor (enc_data(N-2) and '1') xor (enc_data(N-3) and '0') xor (enc_data(N-4) and '0') xor (enc_data(N-5) and '0');
	odata_i(C-3) <= (enc_data(N-1) and '0') xor (enc_data(N-2) and '0') xor (enc_data(N-3) and '1') xor (enc_data(N-4) and '0') xor (enc_data(N-5) and '0');
	odata_i(C-4) <= (enc_data(N-1) and '0') xor (enc_data(N-2) and '0') xor (enc_data(N-3) and '0') xor (enc_data(N-4) and '1') xor (enc_data(N-5) and '0');
	odata_i(C-5) <= (enc_data(N-1) and '0') xor (enc_data(N-2) and '0') xor (enc_data(N-3) and '0') xor (enc_data(N-4) and '0') xor (enc_data(N-5) and '1');
	odata_i(C-6) <= (enc_data(N-1) and '0') xor (enc_data(N-2) and '1') xor (enc_data(N-3) and '1') xor (enc_data(N-4) and '1') xor (enc_data(N-5) and '0');
	odata_i(C-7) <= (enc_data(N-1) and '1') xor (enc_data(N-2) and '0') xor (enc_data(N-3) and '1') xor (enc_data(N-4) and '0') xor (enc_data(N-5) and '0');
	odata_i(C-8) <= (enc_data(N-1) and '1') xor (enc_data(N-2) and '0') xor (enc_data(N-3) and '1') xor (enc_data(N-4) and '0') xor (enc_data(N-5) and '1');
	odata_i(C-9) <= (enc_data(N-1) and '0') xor (enc_data(N-2) and '0') xor (enc_data(N-3) and '1') xor (enc_data(N-4) and '1') xor (enc_data(N-5) and '1');
	odata_i(C-10) <= (enc_data(N-1) and '1') xor (enc_data(N-2) and '1') xor (enc_data(N-3) and '0') xor (enc_data(N-4) and '0') xor (enc_data(N-5) and '1');
	END IF; 


	IF (current_state = ENC_VERIFY) THEN
	IF (odata_i = "0000000000") THEN   --1
	enc_code <= '1';
	ELSIF (odata_i = "0000100111") THEN --2
	enc_code <= '1';
	ELSIF (odata_i = "0001010010") THEN --3
	enc_code <= '1';
	ELSIF (odata_i = "0001110101") THEN --4
	enc_code <= '1';
	ELSIF (odata_i = "0010011110") THEN --5
	enc_code <= '1';
	ELSIF (odata_i = "0010111001") THEN --6
	enc_code <= '1';
	ELSIF (odata_i = "0011001100") THEN --7
	enc_code <= '1';
	ELSIF (odata_i = "0011101011") THEN --8
	enc_code <= '1';
	ELSIF (odata_i = "0100010001") THEN --9
	enc_code <= '1';
	ELSIF (odata_i = "0100110110") THEN --10
	enc_code <= '1';
	ELSIF (odata_i = "0101000011") THEN --11
	enc_code <= '1';
	ELSIF (odata_i = "0101100100") THEN --12
	enc_code <= '1';
	ELSIF (odata_i = "0110001111") THEN --13
	enc_code <= '1';
	ELSIF (odata_i = "0110101000") THEN --14
	enc_code <= '1';
	ELSIF (odata_i = "0111011101") THEN --15
	enc_code <= '1';
	ELSIF (odata_i = "0111111010") THEN --16
	enc_code <= '1';
	ELSIF (odata_i = "1000001101") THEN --17
	enc_code <= '1';
	ELSIF (odata_i = "1000101010") THEN --18
	enc_code <= '1';
	ELSIF (odata_i = "1001011111") THEN --19
	enc_code <= '1';
	ELSIF (odata_i = "1001111000") THEN --20
	enc_code <= '1';
	ELSIF (odata_i = "1010010011") THEN --21
	enc_code <= '1';
	ELSIF (odata_i = "1010110100") THEN --22
	enc_code <= '1';
	ELSIF (odata_i = "1011000001") THEN --23
	enc_code <= '1';
	ELSIF (odata_i = "1011100110") THEN --24
	enc_code <= '1';
	ELSIF (odata_i = "1100011100") THEN --25
	enc_code <= '1';
	ELSIF (odata_i = "1100111011") THEN --26
	enc_code <= '1';
	ELSIF (odata_i = "1101001110") THEN --27
	enc_code <= '1';
	ELSIF (odata_i = "1101101001") THEN --28
	enc_code <= '1';
	ELSIF (odata_i = "1110000010") THEN --29
	enc_code <= '1';
	ELSIF (odata_i = "1110100101") THEN --30
	enc_code <= '1';
	ELSIF (odata_i = "1111010000") THEN --31
	enc_code <= '1';
	ELSIF (odata_i = "1111110111") THEN --32
	enc_code <= '1';
	ELSE
	enc_code <= '0';
	END IF;
	END IF;


	IF (current_state = GEN_ERROR) THEN
 		code_data_i <= odata_i;
		code_data_s <= odata_i;
		count1 <= code_data_i (C-1 downto 6);
		count2 <= code_data_i (C-5 downto 2);
		count3 <= code_data_i (C-7 downto 0);
         
	IF (count /= "000") THEN
		error1 <= (((to_integer(unsigned(count1)))*error1)+1) mod 10;	
		error2 <= (((to_integer(unsigned(count2)))*error2)+6) mod 10;
		error3 <= (((to_integer(unsigned(count3)))*error3)+9) mod 10;
		count <= count - 1;
		gen_done <= '0';

	ELSIF (count = "000") THEN
		gen_done <= '1'; -- Set Add Error to 1

	ELSE 
		count <= count;
	END IF;
	END IF;



	IF ( current_state = ADD_ERROR) THEN	
	-- Adding Errors
		code_data_i(error1) <= 'X';
		code_data_i(error2) <= 'X';
		code_data_i(error3) <= 'X';
	END IF;


	IF (current_state = BITE_VERIFY) THEN

	IF (code_data_i = code_data_s) THEN   --1
		bite_code <= '0'; --false
	ELSE
		bite_code <= '1'; --true
	END IF;
	END IF;

	IF (current_state = LOAD) THEN
		idata <= code_data_i;
		pcheck1 <= 0;
		pcheck2 <= 0;
		pcheck3 <= 0;
		pcheck4 <= 0;
		pcheck5 <= 0;
		
	END IF;

	IF (current_state = PARITY_CHK1) THEN
	


	IF  (idata(C-1) /= '0') and (idata(C-1) /= '1')  THEN
		pcheck2 <= pcheck2 + 1;
		pcheck3 <= pcheck3 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck5 <= pcheck5;
	END IF;

	IF  (idata(C-4) /= '0') and (idata(C-4) /= '1')  THEN
		pcheck1 <= pcheck1 + 1;
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck4 <= pcheck4;
	END IF;


	END IF;
---------------------------------------------------------------(8) (3) (2) and (1)
	IF (current_state = PARITY_CHK2) THEN
	
	IF  (idata(C-2) /= '0') and (idata(C-2) /= '1')  THEN
		pcheck1 <= pcheck1 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck5 <= pcheck5;
	END IF;

	IF  (idata(C-7) /= '0') and (idata(C-7) /= '1') THEN
		pcheck2 <= pcheck2 + 1;
	ELSE
		pcheck2 <= pcheck2;
	END IF;

	IF  (idata(C-8) /= '0') and (idata(C-8) /= '1') THEN
		pcheck3 <= pcheck3 + 1;
	ELSE
		pcheck3 <= pcheck3;
	END IF;

	IF  (idata(C-9) /= '0') and (idata(C-9) /= '1') THEN
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck4 <= pcheck4;
	END IF;


	END IF;
---------------------------------------------------------------(7) (0)

	IF (current_state = PARITY_CHK3) THEN
	
	IF  (idata(C-3) /= '0') and (idata(C-3) /= '1') THEN
		pcheck1 <= pcheck1 + 1;
		pcheck2 <= pcheck2 + 1;
	    	pcheck3 <= pcheck3 + 1;
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
	END IF;

	IF  (idata(C-10) /= '0') and (idata(C-10) /= '1') THEN
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck5 <= pcheck5;
	END IF;

	END IF;

---------------------------------------------------------------(5) and (4)

	IF (current_state = PARITY_CHK4) THEN
	
	IF  (idata(C-5) /= '0') and (idata(C-5) /= '1') THEN
	    	pcheck3 <= pcheck3 + 1;
		pcheck4 <= pcheck4 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
	    	pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
		pcheck5 <= pcheck5;
	END IF;

	IF  (idata(C-6) /= '0') and (idata(C-6) /= '1') THEN
		pcheck1 <= pcheck1 + 1;
	ELSE
		pcheck1 <= pcheck1;
	END IF;

	END IF;

-----------------------------------------------------------------------------


	IF (current_state = FIX_1) THEN	

	IF (idata(C-2) /= '0') and (idata(C-2) /= '1') THEN 		--(8)
	idata(C-2) <=  idata(C-3) xor idata(C-4) xor idata(C-6);
	ELSIF( idata(C-3) = '0') and (idata(C-3) /= '1') THEN		--(7)
	idata(C-3) <=  idata(C-2) xor idata(C-4) xor idata(C-6);
	ELSIF( idata(C-4) /= '0') and (idata(C-4) /= '1') THEN		--(6)
	idata(C-4) <=  idata(C-2) xor idata(C-3) xor idata(C-6);
	ELSIF( idata(C-6) /= '0') and (idata(C-6) /= '1') THEN		--(4)
	idata(C-6) <=  idata(C-2) xor idata(C-3) xor idata(C-4);
	END IF;

	END IF;


	IF ( current_state = FIX_2) THEN	

	IF( idata(C-1) /= '0') and (idata(C-1) /= '1') THEN 		--(9)
	idata(C-1) <=  idata(C-3) xor idata(C-7);
	ELSIF( idata(C-3) /= '0') and (idata(C-3) /= '1') THEN		--(7)
	idata(C-3) <=  idata(C-1) xor idata(C-7);
	ELSIF( idata(C-7) /= '0') and (idata(C-7) /= '1') THEN		--(3)
	idata(C-7) <=  idata(C-1) xor idata(C-3);
	END IF;

	END IF;


	IF (current_state = FIX_3) THEN	

	IF( idata(C-1) /= '0') and (idata(C-1) /= '1') THEN 			--(9)
	idata(C-1) <=  idata(C-3) xor idata(C-5) xor idata(C-8);
	ELSIF( idata(C-3) /= '0') and (idata(C-3) /= '1') THEN			--(7)
	idata(C-3) <=  idata(C-1) xor idata(C-5) xor idata(C-8);
	ELSIF( idata(C-5) /= '0') and (idata(C-5) /= '1') THEN			--(5)
	idata(C-5) <=  idata(C-1) xor idata(C-3) xor idata(C-8);
	ELSIF( idata(C-8) /= '0') and (idata(C-8) /= '1') THEN			--(2)
	idata(C-8) <=  idata(C-1) xor idata(C-3) xor idata(C-5);
	END IF;

	END IF;


	IF ( current_state = FIX_4) THEN	

	IF( idata(C-3) /= '0') and (idata(C-3) /= '1') THEN 		--(7)
	idata(C-3) <=  idata(C-4) xor idata(C-5) xor idata(C-9);
	ELSIF( idata(C-4) /= '0') and (idata(C-4) /= '1') THEN		--(6)
	idata(C-4) <=  idata(C-3) xor idata(C-5) xor idata(C-9);
	ELSIF( idata(C-5) /= '0') and (idata(C-5) /= '1') THEN		--(5)
	idata(C-5) <=  idata(C-3) xor idata(C-4) xor idata(C-9);
	ELSIF( idata(C-9) /= '0') and (idata(C-9) /= '1') THEN		--(1)
	idata(C-9) <=  idata(C-3) xor idata(C-4) xor idata(C-5);
	END IF;

	END IF;



	IF ( current_state = FIX_5) THEN	

	IF( idata(C-1) /= '0') and (idata(C-1) /= '1') THEN 		--(9)
	idata(C-1) <=  idata(C-2) xor idata(C-5) xor idata(C-10);
	ELSIF( idata(C-2) /= '0') and (idata(C-2) /= '1') THEN		--(8)
	idata(C-2) <=  idata(C-1) xor idata(C-5) xor idata(C-10);
	ELSIF( idata(C-5) /= '0') and (idata(C-5) /= '1') THEN		--(5)
	idata(C-5) <=  idata(C-1) xor idata(C-2) xor idata(C-10);
	ELSIF( idata(C-10) /= '0') and (idata(C-10) /= '1') THEN	--(0)
	idata(C-10) <=  idata(C-1) xor idata(C-2) xor idata(C-5);
	END IF;

	END IF;


	IF ( current_state = CODE_CHECK) THEN
	IF ((idata(C-1) = '0') or (idata(C-1) = '1')) and
	   ((idata(C-2) = '0') or (idata(C-2) = '1')) and
           ((idata(C-3) = '0') or (idata(C-3) = '1')) and
           ((idata(C-4) = '0') or (idata(C-4) = '1')) and
           ((idata(C-5) = '0') or (idata(C-5) = '1')) and
           ((idata(C-6) = '0') or (idata(C-6) = '1')) and
           ((idata(C-7) = '0') or (idata(C-7) = '1')) and
           ((idata(C-8) = '0') or (idata(C-8) = '1')) and
           ((idata(C-9) = '0') or (idata(C-9) = '1')) and
           ((idata(C-10) = '0') or (idata(C-10) = '1')) THEN
	   mp_code <= '1';
	   ELSE
	   mp_code <= '0';
	   pcheck1 <= 0;
	   pcheck2 <= 0;
	   pcheck3 <= 0;
	   pcheck4 <= 0;
	   pcheck5 <= 0;
	   END IF;
	   END IF;


	IF (current_state = DEC_VERIFY) THEN
	IF (idata = "0000000000") THEN   --1
	dec_code <= '1';
	ELSIF (idata = "0000100111") THEN --2
	dec_code <= '1';
	ELSIF (idata = "0001010010") THEN --3
	dec_code <= '1';
	ELSIF (idata = "0001110101") THEN --4
	dec_code <= '1';
	ELSIF (idata = "0010011110") THEN --5
	dec_code <= '1';
	ELSIF (idata = "0010111001") THEN --6
	dec_code <= '1';
	ELSIF (idata = "0011001100") THEN --7
	dec_code <= '1';
	ELSIF (idata = "0011101011") THEN --8
	dec_code <= '1';
	ELSIF (idata = "0100010001") THEN --9
	dec_code <= '1';
	ELSIF (idata = "0100110110") THEN --10
	dec_code <= '1';
	ELSIF (idata = "0101000011") THEN --11
	dec_code <= '1';
	ELSIF (idata = "0101100100") THEN --12
	dec_code <= '1';
	ELSIF (idata = "0110001111") THEN --13
	dec_code <= '1';
	ELSIF (idata = "0110101000") THEN --14
	dec_code <= '1';
	ELSIF (idata = "0111011101") THEN --15
	dec_code <= '1';
	ELSIF (idata = "0111111010") THEN --16
	dec_code <= '1';
	ELSIF (idata = "1000001101") THEN --17
	dec_code <= '1';
	ELSIF (idata = "1000101010") THEN --18
	dec_code <= '1';
	ELSIF (idata = "1001011111") THEN --19
	dec_code <= '1';
	ELSIF (idata = "1001111000") THEN --20
	dec_code <= '1';
	ELSIF (idata = "1010010011") THEN --21
	dec_code <= '1';
	ELSIF (idata = "1010110100") THEN --22
	dec_code <= '1';
	ELSIF (idata = "1011000001") THEN --23
	dec_code <= '1';
	ELSIF (idata = "1011100110") THEN --24
	dec_code <= '1';
	ELSIF (idata = "1100011100") THEN --25
	dec_code <= '1';
	ELSIF (idata = "1100111011") THEN --26
	dec_code <= '1';
	ELSIF (idata = "1101001110") THEN --27
	dec_code <= '1';
	ELSIF (idata = "1101101001") THEN --28
	dec_code <= '1';
	ELSIF (idata = "1110000010") THEN --29
	dec_code <= '1';
	ELSIF (idata = "1110100101") THEN --30
	dec_code <= '1';
	ELSIF (idata = "1111010000") THEN --31
	dec_code <= '1';
	ELSIF (idata = "1111110111") THEN --32
	dec_code <= '1';
	ELSE
	dec_code <= '0';
	END IF;
	END IF;


	IF (current_state = DECODE) THEN
	dec_done <= '1';
	out_data <= idata(C-1 downto C-5);
	ELSE 
	dec_done <= '0';
	out_data <= (OTHERS => 'U');
	END IF;


	IF ( current_state = DONE) THEN
	dec_done <= '1';
	out_data <= idata(C-1 downto C-5);
	ELSE 
	dec_done <= '0';
	out_data <= (OTHERS => 'U');
	END IF;



	END IF;
	END PROCESS combinational;



END behav;

