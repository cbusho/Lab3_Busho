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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity character_gen is
    Port ( clk : in  STD_LOGIC;
           blank : in  STD_LOGIC;
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

signal count: std_logic_vector(11 downto 0);
signal data_out_a_sig: std_logic_vector(7 downto 0);
signal data_out_b_sig: std_logic_vector(7 downto 0);
signal font_data_sig: std_logic_vector(7 downto 0);

begin

Inst_char_screen_buffer: char_screen_buffer PORT MAP(
		clk => clk,
		we => write_en,
		address_a => count,
		address_b => row(10 downto 4) & column(10 downto 3),
		data_in => ascii_to_write,
		data_out_a => data_out_a_sig,
		data_out_b => data_out_b_sig
	);
	
Inst_font_rom: font_rom PORT MAP(
		clk => clk,
		addr => row(3 downto 0) & data_out_b_sig(6 downto 0),
		data => open
	);	

end Behavioral;

