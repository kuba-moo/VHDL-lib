-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>
--
-- Copyright (C) 2014 Jakub Kicinski <kubakici@wp.pl>

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Generic bus append module
--      Appends Value (N_BYTES long) after packet on the bus
--      Value is latched with InPkt, what is seen on the last cycle
--      with InPkt high will be transmitted byte by byte onto the wire
-- NOTE: Transmission is big endian
--
-- WARNING: Pkt signal must be (and is kept) continuous

entity bus_append is
    generic (N_BYTES : integer);
    port (Clk     : in  std_logic;
          Rst     : in  std_logic;
          Value   : in  std_logic_vector (N_BYTES*8 - 1 downto 0);
          InPkt   : in  std_logic;
          InData  : in  std_logic_vector (7 downto 0);
          OutPkt  : out std_logic;
          OutData : out std_logic_vector (7 downto 0));
end bus_append;

architecture Behavioral of bus_append is

    constant UBIT : integer := N_BYTES * 8 - 1;

begin

    main : process (Clk)
        variable delayPkt  : std_logic;
        variable delayData : std_logic_vector(7 downto 0);

        variable saveValue : std_logic_vector (UBIT downto 0);
        variable write_out : std_logic := '0';
        variable write_cnt : integer range 0 to N_BYTES - 1;
    begin
        if RISING_EDGE(Clk) then
            OutPkt  <= delayPkt;
            OutData <= delayData;

            if write_out = '1' then
                OutPkt  <= '1';
                OutData <= saveValue(UBIT - write_cnt*8 downto UBIT - 7 - write_cnt*8);

                if write_cnt = N_BYTES - 1 then
                    write_out := '0';
                end if;
                write_cnt := write_cnt + 1;
            end if;

            if InPkt = '1' then
                saveValue := Value;
            end if;

            if delayPkt = '1' and InPkt = '0' then
                write_out := '1';
                write_cnt := 0;
            end if;

            delayPkt  := InPkt;
            delayData := InData;

            if rst = '1' then
                write_out := '0';
            end if;
        end if;
    end process;

end Behavioral;
