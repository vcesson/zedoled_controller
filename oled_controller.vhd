----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:57:55 02/22/2013 
-- Design Name: 
-- Module Name:    oled_controller - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity oled_controller is
	Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		DATAIN : in STD_LOGIC_VECTOR( 7 DOWNTO 0);
		DATA_AVAILABLE : in STD_LOGIC;
		FIFO_FULL : out STD_LOGIC;
		FIFO_EMPTY : out STD_LOGIC;
		SDIN : out  STD_LOGIC;
		SCLK : out  STD_LOGIC);
end oled_controller;

architecture Behavioral of oled_controller is

component SpiCtrl is
	Port ( 
		CLK 		: in  STD_LOGIC; --System CLK (100MHz)
		RST 		: in  STD_LOGIC; --Global RST (Synchronous)
		SPI_EN 	: in  STD_LOGIC; --SPI block enable pin
		SPI_DATA : in  STD_LOGIC_VECTOR (7 downto 0); --Byte to be sent
		CS		: out STD_LOGIC; --Chip Select
		SDO 		: out STD_LOGIC; --SPI data out
		SCLK 	: out STD_LOGIC; --SPI clock
		SPI_FIN	: out STD_LOGIC);--SPI finish flag
end component;

component fifo128 is
	Port ( 
		CLK : in  STD_LOGIC; --System CLK
	   RST : in  STD_LOGIC; --Global RST (Synchronous)
		DATAIN : in  STD_LOGIC_VECTOR (7 downto 0);
		DATA_AVAILABLE : in  STD_LOGIC;
		READ_DONE : in  STD_LOGIC;
		DATAOUT : out  STD_LOGIC_VECTOR (7 downto 0);
		EMPTY : out  STD_LOGIC;
		FULL : out  STD_LOGIC);
end component;

component com_fifospi is
    Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		FIFO_EMPTY : in  STD_LOGIC;
      SPI_FIN : in  STD_LOGIC;
      SPI_EN : out  STD_LOGIC;
      READ_DONE : out  STD_LOGIC);
end component;

signal SPI_DATA :  STD_LOGIC_VECTOR (7 downto 0);
signal READ_DONE :  STD_LOGIC;
signal DATA :  STD_LOGIC_VECTOR (7 downto 0);
signal EMPTY :  STD_LOGIC;
signal SPI_EN :  STD_LOGIC;
signal SPI_FIN :  STD_LOGIC;

begin

FIFO_EMPTY <= EMPTY;

SpiCtrl_0 : SpiCtrl
	Port Map (
		CLK => CLK,
		RST => RST,
		SPI_EN => SPI_EN,
		SPI_DATA => DATA,
		SDO => SDIN,
		SCLK => SCLK,
		SPI_FIN => spi_fin
		);
	
fifo128_0 : fifo128
	Port Map (
		CLK => CLK,
		RST => RST,
		DATAIN => DATAIN,
		DATA_AVAILABLE => DATA_AVAILABLE,
		READ_DONE => READ_DONE,
		DATAOUT => DATA,
		EMPTY => EMPTY,
		FULL => FIFO_FULL
		);

com_fifospi_0 : com_fifospi
	Port Map (
		CLK => CLK,
		RST => RST,
		FIFO_EMPTY => EMPTY,
		SPI_FIN => SPI_FIN,
		SPI_EN => SPI_EN,
		READ_DONE => READ_DONE
		);

end Behavioral;

