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
use work.globals.all;

-- Generate '1' on @Output with given @FREQUENCY

entity freq_generator is
    generic (FREQUENCY     : integer; -- target freq
             CLK_FREQUENCY : integer := FPGA_CLK_FREQ);

    port (Clk    : in  std_logic;
          Rst    : in  std_logic;
          Output : out std_logic);
end freq_generator;

-- Operation:
-- Calculate how many clocks must pass and count to that value

architecture Behavioral of freq_generator is

    constant CLK_MAX : integer := CLK_FREQUENCY/FREQUENCY;  -- 100 MHz

    signal counter : integer range 0 to CLK_MAX - 1;

begin

    logi : process (Clk, Rst) is

    begin
        if rising_edge(Clk) then
            Output  <= '0';
            counter <= counter + 1;

            if counter + 1 = CLK_MAX then
                Output  <= '1';
                counter <= 0;
            end if;

            if Rst = '1' then
                counter <= 0;
            end if;
        end if;
    end process logi;

end Behavioral;
