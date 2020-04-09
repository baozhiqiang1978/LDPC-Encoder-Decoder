LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY Top_Decoder IS

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
	i_sop : IN std_logic;
	e_data : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	e_done : OUT std_logic;
	o_data : OUT std_logic_vector (N-1 downto 0)
);

END Top_Decoder;



ARCHITECTURE behav OF Top_Decoder IS






COMPONENT Message_Passing IS

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;

	-- Input Interface I/O
	isop : IN std_logic;
	error_data : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	msg_pass_done : OUT std_logic;
	odata : OUT std_logic_vector (C-1 downto 0)
);

END COMPONENT;

COMPONENT Decoder IS

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	isop : IN std_logic;
	idata : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	odata : OUT std_logic_vector (N-1 downto 0)

);

END COMPONENT;


--Signal Declaration

SIGNAL msg_pass_done_i: std_logic;
SIGNAL code_msg_pass_i: std_logic_vector(C-1 downto 0);
SIGNAL e_done_i: std_logic;
SIGNAL o_data_i: std_logic_vector(N-1 downto 0);

BEGIN



CE1: Message_Passing PORT MAP(	clk => clk,
				rstb => rstb, 
				isop => i_sop,
				error_data => e_data, 
				msg_pass_done => msg_pass_done_i,
				odata => code_msg_pass_i
			);

CE2: Decoder PORT MAP(	clk => clk,
			rstb => rstb,
			isop => msg_pass_done_i,
			idata => code_msg_pass_i,  
			edone => e_done,
			odata => o_data

			);


END behav;