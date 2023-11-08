library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Traffic Controller module
entity Controller is
    Port ( Reset        : in   STD_LOGIC;
           clock        : in   STD_LOGIC;

           -- Car and pedestrian buttons
           CarEW        : in   STD_LOGIC; -- Car on EW road
           CarNS        : in   STD_LOGIC; -- Car on NS road
           PedEW        : in   STD_LOGIC; -- Pedestrian moving EW (crossing NS road)
           PedNS        : in   STD_LOGIC; -- Pedestrian moving NS (crossing EW road)
           
           -- Light control
           LightsEW     : out STD_LOGIC_VECTOR (1 downto 0); -- controls EW lights
           LightsNS     : out STD_LOGIC_VECTOR (1 downto 0);  -- controls NS lights
           
			  -- Counter control
			  clear        : in  STD_LOGIC;
			  clearCounter : out STD_LOGIC;
			  is400			: in  STD_LOGIC
           );
end Controller;

architecture Behavioral_CONT of Controller is

	type StateType is (NSGreen, NSAmber, EWGreen, EWAmber, NSPed, EWPed);
	signal state, nextState : StateType;
	
	-- Encoding for lights
	constant RED   : std_logic_vector(1 downto 0) := "00";
	constant AMBER : std_logic_vector(1 downto 0) := "01";
	constant GREEN : std_logic_vector(1 downto 0) := "10";
	constant WALK  : std_logic_vector(1 downto 0) := "11";
	
begin

	SynchronousProcess:
	process(reset, clock)
	begin
		if(Reset = '1') then
			state <= EWGreen;
		elsif rising_edge(clock) then
			state <= nextState;
		end if;
	end process SynchronousProcess;
	
	PedProcess:
	process(reset, clock)
	begin
		if(Reset = '1') then
			PedNS1 <= '0';
			PedEW1 <= '0';
		elsif rising_edge(clock) then
			if(PedNS = '1') then
				PedNS1 <= '1';
			end if;
			
			if(PedEW = '1') then
				PedEW1 <= '1';
			end if;
		end if;
	end process PedProcess;
	
	CombinationalProcess:
	process(state, is400)
	begin
		-- default values for outputs
		LightsEW <= RED;
		LightsNS <= RED;
		clearCounter <= '0';
		-- nextState <= EWGrren;
		
		case state is
			when EWGreen  =>
				-- Waiting for CarNS press
				clearCounter <= '1';
				if(CarNS = '1') then
					LightsEW <= GREEN;
					nextState <= EWAmber;
					clearCounter <= '1';
				end if;
				
			when EWAmber  =>
				-- Waiting for PedNS press
				clearCounter <= '1';
				if(PedNS = '1') then
					LightsEW <= AMBER;
					nextState <= NSPed;
					clearCounter <= '1';
				elsif(PedNS = '0') then
					LightsEW <= AMBER;
					nextState <= NSGreen;
					clearCounter <= '1';
				end if;
				
			when NSPed  =>
				--moving to NSGreen regardless of input
				LightsNS <= WALK;
				nextState <= NSGreen;
				
			when NSGreen  =>
				-- watiting for CarEW press
				clearCounter <= '1';
				if(CarEW = '1') then
					LightsNS <= GREEN;
					nextState <= NSAmber;
					clearCounter <= '1';
				end if;

			when NSAmber  =>
				-- Waiting for PedEW press
				clearCounter <= '1';
				if(PedEW = '1') then
					LightsEW <= AMBER;
					nextState <= EWPed;
					clearCounter <= '1';
				elsif(PedEW = '0') then
					LightsEW <= AMBER;
					nextState <= EWGreen;
					clearCounter <= '1';
				end if;
			when EWPed  =>
				--moving to NSGreen regardless of input
				LightsEW <= WALK;
				nextState <= EWGreen;	
		end case;
	end process CombinationalProcess;
end Behavioral_CONT;

