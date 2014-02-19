Lab 1 - Pong
=====

### Introduction

The purpose of this laboratory exercise was to build a simple pong game (with one paddle controlled by user input) using the modules created in the first VGA controller lab.

![alt text](http://i.imgur.com/Qvr0WSo.png "Pong Lab Image")

### Implementation

The implementation of this lab consisted of having to write code for three separate VHDL modules, while using three modules that were already written during the VGA synchronization lab. A block diagram/RTL schematic of my design can be seen in the image below:

![alt text](http://i.imgur.com/dUczGxU.png "RTL Schematic")

In addition, the state diagram for `hmm` can be seen below:

![alt text]( "State Diagram")

The modules that I wrote for this lab are listed below complete with examples and explanations:

 * `atlys_lab_video` - This file is the top level VHDL file that includes the instantiations of both the `vga_sync` and `pixel_gen` modules. The instantiations for each of these components can be seen below:

```vhdl
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
```


 * `pixel_gen` - This VHDL module is the pixel generator, which is the file that actually writes pixels to the monitor display, using signals and generics initialized in the earlier VHDL modules. The process for drawing the logo, paddle, and ball on the display (with user input from buttons on the FPGA) can be seen below:

```vhdl
		blue_logo <=
			  "00000000" when (blank = '1') else
			  "10101010" when (column_new > 200 and column_new < 280 and row_new > 200 and row_new < 220) else
			  "10101010" when (column_new > 200 and column_new < 220 and row_new > 200 and row_new < 280) else
			  "10101010" when (column_new > 260 and column_new < 280 and row_new > 200 and row_new < 280) else
			  "10101010" when (column_new > 220 and column_new < 260 and row_new > 240 and row_new < 260) else
			  "10101010" when (column_new > 320 and column_new < 400 and row_new > 200 and row_new < 220) else
			  "10101010" when (column_new > 320 and column_new < 340 and row_new > 200 and row_new < 280) else
			  "10101010" when (column_new > 320 and column_new < 400 and row_new > 240 and row_new < 260) else
			  "00000000";

		g <= "00000000" when (blank = '1') else
			  "11111111" when (column_new > 9 and column_new < 21 and (row_new > (paddle_y_new - 30) or 
									 row_new < corr) and row_new < (paddle_y_new + 30) ) else
			  "00000000"; 
 
		r <= "00000000" when (blank = '1') else
			  "00000000" when (blue_logo /= "00000000") else
			  "11111111" when (column_new > (ball_x_new - 5) and column_new < (ball_x_new + 5) and 
									 row_new > (ball_y_new - 5) and row_new < (ball_y_new + 5) ) else
			  "00000000";

		b <= blue_logo;

```


### Test/Debug

Throughout the course of this lab, I experienced issues with each of my VHDL modules. However, through the careful application of testbenches (and some consulatation with experts such as Captain Branchflower), I was able to properly diagnose and fix the different errors. The problems I experienced can be seen below.
 * In `h_sync_gen`, my first issue came with differences in type. I had initialized various signals to be used with my code, but I had written them with incorrect types. This gave me numerous problems while writing the code for this file, especially when trying to assign a value to my `column` that was dependent on count. I then realized that the value I needed to generate an unsigned value for `column`. After fixing this mistake, my code for `h_sync_gen` worked appropriately. 
 * In `vga_sync`, I was also experiencing issues, which once again seemed to be a result of a conflict in types. After failing to see what was wrong, a careful analysis of the error messages showed that one of my declared signals was not being appropriately used. The signal was being declared but not being used in the highest level file of `v_sync_gen`. After commenting out this input declaration, my code for `vga_sync` worked appropriately.
 * My final issue was one that should not have particularly beeen an issue. After not being able to get my completed code working on my FPGA, I realized that I had not created a constraints file that specified which parts of my FPGA to use. After the creation of this file, my code properly displayed the desired pattern on the monitor display.




### Conclusion

Overall, though very challenging, I thought that this was a valuable lab. It was extremely frustrating, but it definitely succeeded in teaching me a lot about how to write better VHDL code. One of the biggest challenges was trying to write code that the machine could synthesize. A lot of what I knew about writing in java and C does not apply in VHDL, and vice versa. In addition, I would not personally change very much about this lab besides maybe adding a little bit more direction in terms of choosing which state machines to use for which applications.

 
