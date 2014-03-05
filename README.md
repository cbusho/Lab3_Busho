Lab3_Busho
==========

## Introduction
I created a font controller that allows a user to write a character to any location within a 30 by 80 
character grid on a VGA screen. The user was allowed to scroll through a list of characters using switches
and a button that used a Moore state machine to debounce to select which character they wanted. 


## Implementation
- I used A Moore state machine for my button presses. This made sure to debounce the buttons so the user
could select one character at a time. I used D Flip Flops for next state, current state, count, output buffers, and next output buffers for the input to pulse (button) module. 

  - This is an example of a D Flip Flop

``` VHDL
-- state register
	process(clk, reset)
	begin
		if (reset = '1') then
			state_reg <= idle;
		elsif (clk'event and clk = '1') then
			state_reg <= state_next;
		end if;
	end process;
```

  - This is an example of a mux

``` VHDL
count_next <= count_reg + 1 when ((button_next = pressed) and (input = '0')) else
						  to_unsigned(0,20);	
```

- I also created a testbench to test if the state machine worked. The testbench was too spread out to 
see all of it in one screen because a long delay was used to prevent debouncing. The following test was
performed.

``` VHDL
      wait for clk_period*10;

		reset <= '0';
		input <= '1';

		 wait for 100 ns;	

      wait for clk_period*10;

		input <= '0';
		wait for 600 us;
		input <= '1';
		wait for 1000 ns;
		input <= '0';	
```

- I used the pong control module as my state machine to keep track of the ball and paddle. The pixel
gen module was used to color the items on the screen. Both of these modules were instantiated in the
top atlys shell in conjunction with all the VGA components used in Lab1 in order to drive the VGA screen.

- Block Diagram 

![alt text](Block_diagram.png "Block Diagram")

- pong_control.vhd state diagram

![alt text](Pong_control_state_diagram.png "State Diagram")

## Test/Debug

- Made the AF logo, it was not straight, proceeded to draw it out on a piece of paper
- Drew the ball and tried to make it move, realized it was moving too fast and made it move off of 
  a count that counted up on v_completed
- Ball kept 'teleporting every 8 seconds, it was really moving really fast for a split second
- Made my next output buffers only trigger off of v_completed
- Had to do the same to paddle to prevent it from moving really fast
- Had to set my default values for the next output buffers outside of the v_completed if statement 
  to prevent inferred memory
  
## Conclusion
I learned that creating combinational logic whenever possible seems to be easier. Placing everything 
inside process statements has the potential to cause several timing issues and inferred memory. Signals 
may not change when you want them to if you are not careful about what goes inside your process statements.
While debugging may be a pain, this lab has shown me to be extra careful with sensitivity lists and how 
to code memory.
