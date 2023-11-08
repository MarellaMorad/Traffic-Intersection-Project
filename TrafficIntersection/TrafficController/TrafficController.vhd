-------------------------------------------------------------------
-- TrafficController.vhd
-- TopLevel of this project that includes the syncronising of inputs
-- and outputs from the other two modules into this one
-- i.e. from Controller and Counter into TrafficController
-------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- TopLevel module
entity TrafficController is
	Port ( -- Clock and Reset inputs
			 reset			:	in		STD_LOGIC;
			 clock			:	in		STD_LOGIC;
			 
			 -- Car and pedestrian buttons
			 CarEW			:	in 	STD_LOGIC;
			 CarNS			:	in		STD_LOGIC;
			 PedEW			:	in		STD_LOGIC;
			 PedNS			:	in		STD_LOGIC;

			 -- Light control
			 LightsEW		:	out	STD_LOGIC_VECTOR (1 downto 0);
			 LightsNS		:	out	STD_LOGIC_VECTOR (1 downto 0)
			);
end TrafficController;

architecture Behavioral of TrafficController is

-- Synchronized inputs
	signal CarEW_s 		:	STD_LOGIC;
	signal CarNS_s 		:	STD_LOGIC;
	signal PedEW_s 		:	STD_LOGIC;
	signal PedNS_s 		:	STD_LOGIC;


-- Internal connetions (coming from counter)
	signal clearCounter		:	STD_LOGIC;
	signal countEq500			:	STD_LOGIC;
	signal countEq400			:	STD_LOGIC;
	signal countEq300			:  STD_LOGIC;
	
begin

	--========================================
	-- Synchronizes all inputs to sync. logic
	--========================================
	synchronizer:
	process (reset, clock)
	begin
		if(reset = '1') then
			CarEW_s <= '0';
			CarNS_s <= '0';
			PedEW_s <= '0';
			PedNS_s <= '0';
		elsif rising_edge(clock) then
			CarEW_s <= CarEW;
			CarNS_s <= CarNS;
			PedEW_s <= PedEW;
			PedNS_s <= PedNS;
		end if;
	end process synchronizer;

--========================================
-- Counter used for timing 
--========================================
--First level sync
theCounter:
entity work.Counter
	Port Map (
				-- syncronising outputs from Counter to ports from TopLevel 
			--	Counter   	 TopLevel
				reset     => reset,
				clock     => clock,

				clear     => clearCounter, -- Clears the counter

				cEq300    => countEq300, -- Count equals 400
				cEq400    => countEq400, -- Count equals 400
				cEq500	 => countEq500 -- Count equals 500
				);

--========================================
-- Contoller to implement state machine 
--========================================
--Second level sync
theController:
entity work.controller
    Port Map(
				-- syncronising outputs from Controller to ports from TopLevel 
			--	Counter   	 	 TopLevel
				reset        => reset,
				clock        => clock,

				-- Car and pedestrian buttons
				CarEW        => CarEW_s,
				CarNS        => CarNS_s,
				PedEW        => PedEW_s,
				PedNS        => PedNS_s,

				-- Light control
				LightsEW     => LightsEW,
				LightsNS     => LightsNS,

				-- Counter control
				clearCounter => clearCounter,
				countEq300   => countEq300,
				countEq400   => countEq400,
				countEq500   => countEq500
				);

end Behavioral;

