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
		  
		  is400    : out  STD_LOGIC -- Count equals 100    
		  );
end Counter;

architecture Behavioral of Counter is

signal count : natural range 0 to 402;

begin

   process (Reset, clock)
   begin

      if (Reset = '1') then
         count <= 1;
      elsif rising_edge(clock) then
         if (clear = '1') then
            count <= 1;
         else
            count <= count + 1;
         end if;
      end if;
		
		if (count = 400) then
			is400 <= '1';
		else
			is400 <= '0';
		end if;
   end process;
   
   -- No need to register outputs as state machine changes state immediately

end architecture Behavioral;