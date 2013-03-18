------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Mon Feb 25 13:03:20 2013 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_NUM_REG                    -- Number of software accessible registers
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Resetn                -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_NUM_REG                      : integer              := 3;
    C_SLV_DWIDTH                   : integer              := 32
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
	ZEDOLED_RST : in STD_LOGIC;
	ZEDOLED_SDIN : out  STD_LOGIC;
	ZEDOLED_SCLK : out  STD_LOGIC;
	ZEDOLED_DC : out  STD_LOGIC;
	ZEDOLED_RES : out  STD_LOGIC;
	ZEDOLED_VBAT : out  STD_LOGIC;
	ZEDOLED_VDD : out  STD_LOGIC;
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Resetn                  : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    Bus2IP_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
    Bus2IP_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    Bus2IP_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    IP2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Resetn : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

--type data_states is (Idle, Data_receive, Data_avail);

  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg1                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg2                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg_write_sel              : std_logic_vector(2 downto 0);
  signal slv_reg_read_sel               : std_logic_vector(2 downto 0);
  signal slv_ip2bus_data                : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;
 
  signal slv_dc							: std_logic := '0';
  signal slv_vdd							: std_logic := '1';
  signal slv_vbat							: std_logic := '1';
  signal slv_res							: std_logic := '1';
  signal slv_fifo_full					: std_logic;
  signal slv_fifo_empty					: std_logic;
  signal slv_datain						: std_logic_vector( 7 downto 0);
  signal slv_data_available			: std_logic;
  signal slv_data_receive				: std_logic;
  
	--signal data_state : data_states := Idle;
	
component oled_controller is
    Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		DATAIN : in STD_LOGIC_VECTOR( 7 DOWNTO 0);
		DATA_AVAILABLE : in STD_LOGIC;
		FIFO_FULL : out STD_LOGIC;
		FIFO_EMPTY : out STD_LOGIC;
		SDIN : out  STD_LOGIC;
		SCLK : out  STD_LOGIC);
end component;

begin

  ------------------------------------------
  --    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  --                     "100"   C_BASEADDR + 0x0
  --                     "010"   C_BASEADDR + 0x4
  --                     "001"   C_BASEADDR + 0x8
  ------------------------------------------
  
  --USER logic implementation added here
oled_controller_0 : oled_controller
	Port Map (
		CLK => Bus2IP_Clk,
		RST => ZEDOLED_RST,
		DATAIN => slv_datain,
		DATA_AVAILABLE => slv_data_available,
		FIFO_FULL => slv_fifo_full,
		FIFO_EMPTY => slv_fifo_empty,
		SDIN => ZEDOLED_SDIN,
		SCLK => ZEDOLED_SCLK
		);

	slv_reg_write_sel <= Bus2IP_WrCE(2 downto 0);
	slv_reg_read_sel  <= Bus2IP_RdCE(2 downto 0);
	slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2);
	slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2);

	-- fill status register
	slv_reg2(0)			<= slv_fifo_empty;
	slv_reg2(1)			<= slv_fifo_full;
	
	-- use control register
	slv_dc   <= slv_reg0(0);
	slv_res  <= slv_reg0(1);
	slv_vbat <= slv_reg0(2);
	slv_vdd  <= slv_reg0(3);
	ZEDOLED_DC 		<= slv_dc;
	ZEDOLED_RES 	<= slv_res and not(ZEDOLED_RST);
	ZEDOLED_VBAT 	<= slv_vbat;
	ZEDOLED_VDD 	<= slv_vdd;

	-- use data register
	slv_datain <= slv_reg1(7 downto 0);
				
  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin
    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Resetn = '0' then
        slv_reg0 <= (3 downto 1 => '1', others => '0');
        slv_reg1 <= (others => '0');
      else
        case slv_reg_write_sel is
          when "100" =>				-- Control register
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8+7 downto byte_index*8) <= Bus2IP_Data(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
            slv_data_available <= '0';
          when "010" =>				-- Data register
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg1(byte_index*8+7 downto byte_index*8) <= Bus2IP_Data(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
            slv_data_available <= '1';
          when others => 
            slv_data_available <= '0';
        end case;
      end if;
    end if;
  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0, slv_reg1, slv_reg2 ) is
  begin
    case slv_reg_read_sel is
      when "100" => 			-- Control register
			slv_ip2bus_data <= slv_reg0;
      when "010" => 			-- Data register
			slv_ip2bus_data <= slv_reg1;
      when "001" => 			-- Status register
			slv_ip2bus_data <= slv_reg2;
      when others => 
			slv_ip2bus_data <= (others => '0');
    end case;
  end process SLAVE_REG_READ_PROC;
		
	
  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  (others => '0');

  IP2Bus_WrAck <= slv_write_ack;
  IP2Bus_RdAck <= slv_read_ack;
  IP2Bus_Error <= '0';

end IMP;
