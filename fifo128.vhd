----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:40:14 02/22/2013 
-- Design Name: 
-- Module Name:    fifo128 - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo128 is
	Port ( 
		CLK : in STD_LOGIC;
	   RST : in  STD_LOGIC;
		DATAIN : in  STD_LOGIC_VECTOR (7 downto 0);
		DATA_AVAILABLE : in  STD_LOGIC;
		READ_DONE : in  STD_LOGIC;
		DATAOUT : out  STD_LOGIC_VECTOR (7 downto 0);
		EMPTY : out  STD_LOGIC;
		FULL : out  STD_LOGIC);
end fifo128;

architecture Behavioral of fifo128 is

type write_states is (
	Write_Idle_s,
	Write_Done_s);

type read_states is (
	Read_Idle_s,
	Read_Done_s);

type memory_type is array (0 to 127) of STD_LOGIC_VECTOR (7 downto 0);

signal w_state : write_states := Write_Idle_s;
signal r_state : read_states := Read_Idle_s;
signal memory : memory_type :=(others => (others => '0'));   --memory for queue.
signal readptr, writeptr : STD_LOGIC_VECTOR (6 downto 0) :="0000000";  --read and write pointers
signal fifo_full, fifo_empty : STD_LOGIC;
signal data_num : STD_LOGIC_VECTOR(6 downto 0) :="0000000"; --hold the number of data in the fifo

begin
FULL <= fifo_full;
EMPTY <= fifo_empty;
fifo_full <= '1' when (data_num = "1111111") else '0';
fifo_empty <= '1' when (data_num = "0000000") else '0';
DATAOUT <= memory(conv_integer(readptr));
data_num <= (writeptr - readptr) when (writeptr >= readptr) else (128 + writeptr - readptr);

write_data : process(CLK) --write data into fifo and update pointer
begin
	if(CLK'event and CLK = '1') then
		if(RST = '1') then
			writeptr <= "0000000";
		else
			case (w_state) is
				when Write_Idle_s =>
					if(DATA_AVAILABLE = '1' and fifo_full = '0') then --there is new data and enough place to write it
						memory(conv_integer(writeptr)) <= DATAIN;
						if(writeptr = "1111111") then --update write pointer
							 writeptr <= "0000000";
						else
							 writeptr <= writeptr + '1';
						end if;
						w_state <= Write_Done_s;
					end if;
				when Write_Done_s =>
					if(DATA_AVAILABLE = '0') then
						w_state <= Write_Idle_s;
					end if;
			end case;			
		end if;
	end if;
end process;
		
read_data : process(CLK) --update pointer after a successful read
begin
	if(CLK'event and CLK = '1') then
		if(RST = '1') then
			readptr <= "0000000";
		else
			case (r_state) is
				when Read_Idle_s =>
					if(READ_DONE = '1' and fifo_empty = '0') then --data has been read and it was not dummy data
						if(readptr = "1111111") then --update read pointer
							 readptr <= "0000000";
						else
							 readptr <= readptr + '1';
						end if;
						r_state <= Read_Done_s;
					end if;
				when Read_Done_s =>
					if(READ_DONE = '0') then
						r_state <= Read_Idle_s;
					end if;
			end case;			
		end if;
	end if;
end process;
			
				
end Behavioral;
