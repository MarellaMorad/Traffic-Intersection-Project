-------------------------------------------------------------------
-- Controller.vhd
-- Includes the setting of the state machine based on the state
-- machine diagram
-- It includes two process:
-- SynchronousProcess:
-- 	to sync asynchronous inputs to the clock
-- 	including the pedestrians buttons
-- CombinationalProcess:
--		to format the state machine
-------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Controller module
entity Controller is
    Port ( -- Clock and Reset inputs
			  reset        : in   STD_LOGIC;
           clock        : in   STD_LOGIC;

           -- Car and pedestrian buttons
           CarEW        : in   STD_LOGIC; -- Car on EW road
           CarNS        : in   STD_LOGIC; -- Car on NS road
			  -- Pedestrian moving EW (crossing NS road)
           PedEW        : in   STD_LOGIC; 
			  -- Pedestrian moving NS (crossing EW road)
           PedNS        : in   STD_LOGIC; 
           
           -- Light control
           LightsEW     : out STD_LOGIC_VECTOR (1 downto 0); -- controls EW lights
           LightsNS     : out STD_LOGIC_VECTOR (1 downto 0);  -- controls NS lights
           
			  -- Counter control
			  clearCounter : out STD_LOGIC; -- to clear counter
			  -- to check for right timing, count = 300, 400, 500 (will be synced from counter)
			  countEq300	: in	STD_LOGIC; -- 3 seconds delay (Amber)
			  countEq400  	: in  STD_LOGIC; -- 4 seconds delay (Walk)
			  countEq500	: in  STD_LOGIC  -- 5 seconds delay (Green)
           );
end Controller;

architecture Behavioral_CONT of Controller is

	type 		StateType is (NSGreen, NSAmber, EWGreen, EWAmber, NSPed, EWPed);
	signal 	state, nextState : StateType;
	signal 	PedNS_s, PedEW_s : STD_LOGIC;
	
	-- Encoding for lights
	constant RED   : std_logic_vector(1 downto 0) := "00";
	constant AMBER : std_logic_vector(1 downto 0) := "01";
	constant GREEN : std_logic_vector(1 downto 0) := "10";
	constant WALK  : std_logic_vector(1 downto 0) := "11";
	
begin
	SynchronousProcess:
	process(reset, clock, PedNS_s, PedEW_s, PedNS, PedEW)
	begin
		if(reset = '1') then
			state <= EWGreen; --default state
			--clearing PedNS_s and PedEW_s singals when reset is pressed (clearing the flip-flops)
			PedNS_s <= '0'; 	
			PedEW_s <= '0';
		elsif rising_edge(clock) then
			state <= nextState;
			if state = NSPed then
				-- setting PedNS_s to 0 after reaching the NSPed state (i.e. after turing the walk light for a short time)
				PedNS_s <= '0';
			elsif state = EWPed then
				-- setting PedEW_s to 0 after reaching the NSPed state (i.e. after turing the walk light for a short time)
				PedEW_s <= '0';
			end if;
			--Ped buttons syncronising with rising_edge
			if(PedNS = '1') then
				PedNS_s <= '1';
			end if;
			if(PedEW = '1') then
				PedEW_s <= '1';
			end if;
		end if;
	end process SynchronousProcess;
	
	CombinationalProcess: --state machince process
	process(state, countEq300, countEq400, countEq500, CarEW, CarNS, PedEW_s, PedNS_s)
	begin
		-- default values for outputs
		nextState <= state;
		LightsEW <= RED;
		LightsNS <= RED;
		clearCounter <= '0';
		case state is
			when EWGreen  =>
				-- setting the EW lights to green
				LightsEW <= GREEN;
				if(countEq500 = '1') then
					-- waiting for the CarNS button to be pressed
					if(CarNS = '1') then
						nextState <= EWAmber;
						clearCounter <= '1';
					-- PedNS_s is detected, cycle to EWAmber and then to NSPed (and NSGreen)
					elsif (PedNS_s = '1') then
						nextState <= EWAmber;
						clearCounter <= '1';
					-- PedEW_s is detected, cycle to EWPed (and stay in EWGreen)
					elsif (PedEW_s = '1') then
						nextState <= EWPed;
						clearCounter <= '1';
					end if;
				end if;
				
			when EWAmber  =>
				-- Waiting for PedNS press
				LightsEW <= AMBER;
				if(countEq300 = '1') then
					if(PedNS_s = '1') then
						nextState <= NSPed;
						clearCounter <= '1';
					elsif(PedNS_s = '0') then
						nextState <= NSGreen;
						clearCounter <= '1';
					end if;
				end if;
				
			when NSPed  =>
				--moving to NSGreen regardless of input
				LightsNS <= WALK;
				if(countEq400 = '1') then
					nextState <= NSGreen;
					clearCounter <= '1';
				end if;
				
			when NSGreen  =>
				-- watiting for CarEW press
					LightsNS <= GREEN;
				if(countEq500 = '1') then
					if(CarEW = '1') then
						nextState <= NSAmber;
						clearCounter <= '1';
					elsif (PedEW_s = '1') then
						nextState <= NSAmber;
						clearCounter <= '1';
					elsif (PedNS_s = '1') then
						nextState <= NSPed;
						clearCounter <= '1';
					end if;
				end if;

			when NSAmber  =>
				-- Waiting for PedEW press
				LightsNS <= AMBER;
				if(countEq300 = '1') then
					if(PedEW_s = '1') then
						nextState <= EWPed;
						clearCounter <= '1';
					elsif(PedEW_s = '0') then
						nextState <= EWGreen;
						clearCounter <= '1';
					end if;
				end if;
			when EWPed  =>
				--moving to NSGreen regardless of input
				LightsEW <= WALK;
				if(countEq400 = '1') then
					nextState <= EWGreen;
					clearCounter <= '1';
				end if;		
			when others =>
				nextState <= EWGreen;
		end case;			
	end process CombinationalProcess;
end Behavioral_CONT;