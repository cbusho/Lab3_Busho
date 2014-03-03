----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:39:47 02/21/2014 
-- Design Name: 
-- Module Name:    input_to_pulse - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity input_to_pulse is
	  port ( clk          : in std_logic;
            reset        : in std_logic;
            input        : in std_logic;
            pulse        : out std_logic
           );
end input_to_pulse;

architecture Behavioral of input_to_pulse is

type button is
(idle, pressed, letgo);

signal button_reg, button_next : button;
signal count_reg, count_next : unsigned ( 19 downto 0);
signal pulse_buf, pulse_next_buf : std_logic;

begin

--state register
	process(clk, reset)
	begin
		if (reset = '1') then
			button_reg <= idle;
		elsif (rising_edge(clk)) then
			button_reg <= button_next;
		end if;
	end process;

--count register
	process(clk, reset)
	begin 
		if (reset = '1') then
			count_reg <= to_unsigned(0, 20);
		elsif (rising_edge(clk)) then
			count_reg <= count_next;
		end if;
	end process;

-- count logic

		count_next <= count_reg + 1 when ((button_next = pressed) and (input = '0')) else
						  to_unsigned(0,20);	

--next-state logic
	process(input, count_reg, button_reg)
	begin
		button_next <= button_reg;
		case button_reg is
			when idle =>
				if (input = '1') then
					button_next <= pressed;
				end if;
			when pressed =>
				if (count_reg > 50000 and input = '0') then
					button_next <= letgo;
				end if;
			when letgo =>
				button_next <= idle;
			end case;
	end process;

-- output buffer
	process(clk, reset)
	begin
		if (reset = '1') then
			pulse_buf <= '0';
		elsif (rising_edge(clk)) then
			pulse_buf <= pulse_next_buf;
		end if;
	end process;
		
-- output logic
	process(button_reg)
	begin
		case button_reg is
			when idle =>
				pulse_next_buf <= '0';
			when pressed =>
				pulse_next_buf <= '0';
			when letgo =>
				pulse_next_buf <= '1';
		end case;
	end process;

-- output
	pulse <= pulse_buf;

end Behavioral;

