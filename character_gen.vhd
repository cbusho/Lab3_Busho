----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:03:35 02/21/2014 
-- Design Name: 
-- Module Name:    character_gen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity character_gen is
    Port ( clk : in  STD_LOGIC;
           blank : in  STD_LOGIC;
			  reset : in STD_LOGIC;
           row : in  STD_LOGIC_VECTOR (10 downto 0);
           column : in  STD_LOGIC_VECTOR (10 downto 0);
           ascii_to_write : in  STD_LOGIC_VECTOR (7 downto 0);
           write_en : in  STD_LOGIC;
           r,g,b : out  STD_LOGIC_VECTOR (7 downto 0));
end character_gen;

architecture Behavioral of character_gen is

COMPONENT char_screen_buffer
	PORT(
		clk : IN std_logic;
		we : IN std_logic;
		address_a : IN std_logic_vector(11 downto 0);
		address_b : IN std_logic_vector(11 downto 0);
		data_in : IN std_logic_vector(7 downto 0);          
		data_out_a : OUT std_logic_vector(7 downto 0);
		data_out_b : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
COMPONENT font_rom
	PORT(
		clk : IN std_logic;
		addr : IN std_logic_vector(10 downto 0);          
		data : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;	

signal count, count_next: std_logic_vector(11 downto 0);
signal address_b_sig: std_logic_vector(13 downto 0);
signal data_out_a_sig: std_logic_vector(7 downto 0);
signal data_out_b_sig: std_logic_vector(7 downto 0);
signal font_data_sig: std_logic_vector(7 downto 0);
signal row_sig, row_sig_next: std_logic_vector(3 downto 0);
signal sel_next_1, sel_next_2, sel_inter, sel: std_logic_vector(2 downto 0);
signal color: std_logic;

begin

--instantiated components
Inst_char_screen_buffer: char_screen_buffer PORT MAP(
		clk => clk,
		we => write_en,
		address_a => count,
		address_b => address_b_sig(11 downto 0),
		data_in => ascii_to_write,
		data_out_a => open,
		data_out_b => data_out_b_sig
	);
	
Inst_font_rom: font_rom PORT MAP(
		clk => clk,
		addr => data_out_b_sig(6 downto 0) & row_sig,
		data => font_data_sig
	);	

-- col row sig
	address_b_sig <= std_logic_vector(unsigned(row(10 downto 4))*80 + unsigned(column(10 downto 3)));

row_sig_next <= row(3 downto 0);

process(clk)
	begin
		if(rising_edge(clk)) then
			row_sig <= row_sig_next;
		end if;
end process;

--count logic
count_next <= (others => '0') when reset = '1' else count;
count <= std_logic_vector(unsigned(count_next) + 1) when rising_edge(write_en) else 
			count_next;

--mux to draw	
sel_next_1 <= column(2 downto 0);
sel_next_2 <= sel_inter;

process(clk)
	begin
		if(rising_edge(clk)) then
			sel_inter <= sel_next_1;
		end if;
end process;

process(clk)
	begin
		if(rising_edge(clk)) then
			sel <= sel_next_2;
		end if;
end process;		

process(column, sel, clk)
begin
		case sel is
			when "000" =>
				color <= font_data_sig(7);
			when "001" =>
				color <= font_data_sig(6);
			when "010" =>
				color <= font_data_sig(5);
			when "011" =>
				color <= font_data_sig(4);
			when "100" =>
				color <= font_data_sig(3);
			when "101" =>
				color <= font_data_sig(2);
			when "110" =>
				color <= font_data_sig(1);
			when "111" =>
				color <= font_data_sig(0);	
			when others=>
		end case;
end process;		  

-- outputs

r <= (others=> '1') when color = '1' and blank = '0' else
	  (others=> '0');
g <= (others=> '0');	  
b <= (others=> '0');	  

end Behavioral;

