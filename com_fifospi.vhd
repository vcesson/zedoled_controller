----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:28:55 02/22/2013 
-- Design Name: 
-- Module Name:    com_fifospi - Behavioral 
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

entity com_fifospi is
    Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		FIFO_EMPTY : in  STD_LOGIC;
      SPI_FIN : in  STD_LOGIC;
      SPI_EN : out  STD_LOGIC;
      READ_DONE : out  STD_LOGIC);
end com_fifospi;

architecture Behavioral of com_fifospi is

type control_states is (
	Init_s,
	Send_Data_s,
	Wait_SPI_Fin_s,
	Update_fifo_s,
	Idle_s);

signal sm : control_states := Init_s;

begin

sm_seq : process (CLK)
begin
	if(CLK'event and CLK = '1') then
		if(RST = '1') then
			sm <= Init_s;
		else
			case (sm) is
				when Init_s =>
					if(FIFO_EMPTY = '0') then
						sm <= Send_data_s;
					end if;
				when Send_data_s =>
					sm <= Wait_SPI_Fin_s;
				when Wait_SPI_Fin_s =>
					if(SPI_FIN = '1') then
						sm <= Update_Fifo_s;
					end if;
				when Update_Fifo_s =>
					sm <= Idle_s;
				when Idle_s =>
					if(FIFO_EMPTY = '0') then
						sm <= Send_Data_s;
					end if;
			end case;
		end if;
	end if;
end process;

sm_comb : process (sm)
begin
	case (sm) is
		when Init_s =>
			READ_DONE <= '0';
			SPI_EN <= '0';
		when Send_data_s =>
			SPI_EN <= '1';
		when Wait_SPI_Fin_s => null;
		when Update_Fifo_s =>
			READ_DONE <= '1';
			SPI_EN <= '0';
		when Idle_s =>
			READ_DONE <= '0';
	end case;
end process;

end Behavioral;

