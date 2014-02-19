----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:55:47 02/10/2014 
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
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;


entity atlys_lab_video is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  up : in STD_LOGIC;
			  down : in STD_LOGIC;
			  speed : in STD_LOGIC;
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0));
end atlys_lab_video;


architecture Novakowski of atlys_lab_video is
	signal pixel_clk, serialize_clk, serialize_clk_n : std_logic;
	signal h_sync_inter, v_sync_inter, blank_inter, v_completed_inter : std_logic;
	signal red_inter, green_inter, blue_inter : STD_LOGIC_VECTOR (7 downto 0);
	signal row_inter, column_inter : unsigned(10 downto 0);
	signal ballx_inter, bally_inter, paddley_intermed : STD_LOGIC_VECTOR(10 downto 0);
	signal red_s, green_s, blue_s, clock_s: std_logic;
begin


	vga_sync_connect : entity work.vga_sync(behavioral)
		PORT MAP ( clk => pixel_clk,
           reset =>  reset, 
           h_sync =>  h_sync_inter,
           v_sync =>  v_sync_inter,
           v_completed =>  v_completed_inter,
           blank => blank_inter,
           row =>  row_inter,
           column => column_inter 		
	);

 
	pixel_gen_connect : entity work.pixel_gen(behavioral)
		PORT MAP(
			row => row_inter,
			column => column_inter,
			blank => blank_inter,
			ball_x => ballx_inter,
			ball_y => bally_inter,
			paddle_y => paddley_intermed,
			r => red_inter,
			g => green_inter,
			b => blue_inter
	);


	pong_control_connect : entity work.pong_control(behavioral)
		PORT MAP(
			clk =>  pixel_clk,
			reset =>  reset,
			up => up,
			down => down,
			speed => speed,
			v_completed =>  v_completed_inter,
			ball_x =>   ballx_inter,
			ball_y =>   bally_inter,
			paddle_y =>  paddley_intermed
	);	


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




    -- Convert VGA signals to HDMI (actually, DVID ... but close enough)
    inst_dvid: entity work.dvid
    port map(
                clk       => serialize_clk,
                clk_n     => serialize_clk_n, 
                clk_pixel => pixel_clk,
                red_p     => red_inter,
                green_p   => green_inter,
                blue_p    => blue_inter,
                blank     => blank_inter,
                hsync     => h_sync_inter,
                vsync     => v_sync_inter,
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

end Novakowski;
