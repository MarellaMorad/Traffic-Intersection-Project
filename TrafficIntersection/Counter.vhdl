-------------------------------------------------------------------
-- Counter.vhd
-- Here are the time delays defined based on the light used
-- This counter is based on 100Hz as the clock frequency
-- Based on this freqnecy, the time delay for:
-- Amber is 3s, Walk is 4s, Green is 5s
-------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Counter module
entity Counter is
	Port (
		  Reset     : in   STD_LOGIC;
		  clock     : in   STD_LOGIC;
		  
		  clear     : in   STD_LOGIC; -- Clear counter to zero
		  
		  cEq300		: out	 STD_LOGIC; -- 3 seconds delay (Amber)
		  cEq400  	: out  STD_LOGIC;	-- 4 seconds delay (Walk)
		  cEq500		: out  STD_LOGIC  -- 5 seconds delay (Green)
		  );
end Counter;

architecture Behavioral of Counter is

signal count : natural range 0 to 502;
-- give the range of the count values as whole numbers
-- 502 to make sure that the we do not miss 500
-- time in seconds = counts/100Hz
begin

   process (Reset, clock, count)
   begin
      if (Reset = '1') then
			-- Reset count to 1
         count <= 1;
      elsif rising_edge(clock) then
         if (clear = '1') then
				-- reset count to 1 only at rising edge
            count <= 1;
         else
				-- count (increment count by 1)
            count <= count + 1;
         end if;
      end if;
		-- Amber light delay
		if (count = 300) then
			cEq300 <= '1';
		else
			cEq300 <= '0';
		end if;
		-- Walk light delay
		if (count = 400) then
			cEq400 <= '1';
		else
			cEq400 <= '0';
		end if;
		-- Green light delay
		if (count = 500) then
			cEq500 <= '1';
		else
			cEq500 <= '0';
		end if;
   end process;
end architecture Behavioral;