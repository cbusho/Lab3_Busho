----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:07:25 02/04/2014 
-- Design Name: 
-- Module Name:    atlys_lab_video - Behavioral 
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

entity atlys_lab_video is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  Start: in STD_LOGIC;
			  button: in STD_LOGIC;
			  switch: in STD_LOGIC_VECTOR (7 downto 0);
			  led: out STD_LOGIC_VECTOR (7 downto 0);	
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0));
end atlys_lab_video;

architecture Behavioral of atlys_lab_video is

COMPONENT vga_sync
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		h_sync : OUT std_logic;
		v_sync : OUT std_logic;
		v_completed : OUT std_logic;
		blank : OUT std_logic;
		row : OUT unsigned(10 downto 0);
		column : OUT unsigned(10 downto 0)
		);
	END COMPONENT;
	
signal top_blank, blank1, blank2, button_pulse: std_logic;
signal top_row, top_column: unsigned(10 downto 0);
signal red, green, blue: std_logic_vector(7 downto 0);
signal v_sync_sig, h_sync_sig, pixel_clk, serialize_clk, serialize_clk_n,
		 red_s, green_s, blue_s, clock_s, v_comp,
		 v_sync_sig1, h_sync_sig1, v_sync_sig2, h_sync_sig2: std_logic;

begin

    -- Clock divider - creates pixel clock from 100MHz clock
    inst_DCM_pixel: DCM
    generic map(
                   CLKFX_MULTIPLY => 2,
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => pixel_clk
            );

    -- Clock divider - creates HDMI serial output clock
    inst_DCM_serialize: DCM
    generic map(
                   CLKFX_MULTIPLY => 10, -- 5x speed of pixel clock
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => serialize_clk,
                clkfx180 => serialize_clk_n
            );

	 Inst_vga_sync: vga_sync PORT MAP(
		clk => pixel_clk,
		reset => reset,
		h_sync => h_sync_sig,
		v_sync => v_sync_sig,
		v_completed => v_comp,
		blank => top_blank,
		row => top_row,
		column => top_column
	);
	
	Inst_character_gen: entity work.character_gen(Behavioral) PORT MAP(
		clk => pixel_clk,
		blank => top_blank,
		reset => reset,
		row => std_logic_vector(top_row),
		column => std_logic_vector(top_column),
		ascii_to_write => switch,
		write_en => button_pulse,
		r => red,
		g => green,
		b => blue
	);
	
	Inst_input_to_pulse: entity work.input_to_pulse(Behavioral) PORT MAP(
		clk => pixel_clk,
		reset => reset,
		input => button,
		pulse => button_pulse
	);
	
	process(pixel_clk)
	begin
		if(rising_edge(pixel_clk)) then
			h_sync_sig1 <= h_sync_sig;
			v_sync_sig1 <= v_sync_sig;
			blank1 <= top_blank;
		end if;
	end process;

	process(pixel_clk)
	begin
		if(rising_edge(pixel_clk)) then
			h_sync_sig2 <= h_sync_sig1;
			v_sync_sig2<= v_sync_sig1;
			blank2 <= blank1;
		end if;
	end process;	
	
    -- Convert VGA signals to HDMI (actually, DVID ... but close enough)
    inst_dvid: entity work.dvid
    port map(
                clk       => serialize_clk,
                clk_n     => serialize_clk_n, 
                clk_pixel => pixel_clk,
                red_p     => red,
                green_p   => green,
                blue_p    => blue,
                blank     => blank2,
                hsync     => h_sync_sig2,
                vsync     => v_sync_sig2,
                -- outputs to TMDS drivers
                red_s     => red_s,
                green_s   => green_s,
                blue_s    => blue_s,
                clock_s   => clock_s
            );

    -- Output the HDMI data on differential signalling pins
    OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
    OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
    OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
    OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );
		  
end Behavioral;