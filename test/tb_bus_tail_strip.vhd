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

entity tb_bus_tail_strip is
end tb_bus_tail_strip;

architecture behavior of tb_bus_tail_strip is

    -- Component Declaration for the Unit Under Test (UUT)

    component bus_tail_strip
        generic (N_BYTES : integer);
        port (Clk     : in  std_logic;
              Rst     : in  std_logic;
              PktIn   : in  std_logic;
              DataIn  : in  std_logic_vector(7 downto 0);
              PktOut  : out std_logic;
              DataOut : out std_logic_vector(7 downto 0));
    end component;


    --Inputs
    signal Clk    : std_logic                    := '0';
    signal Rst    : std_logic                    := '0';
    signal PktIn  : std_logic                    := '0';
    signal DataIn : std_logic_vector(7 downto 0) := (others => '0');

    --Outputs
    signal PktOut, PktOut_1   : std_logic;
    signal DataOut, DataOut_1 : std_logic_vector(7 downto 0);

    -- Clock period definitions
    constant Clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    strip_3 : bus_tail_strip
        generic map (N_BYTES => 3)
        port map (
            Clk     => Clk,
            Rst     => Rst,
            PktIn   => PktIn,
            DataIn  => DataIn,
            PktOut  => PktOut_1,
            DataOut => DataOut_1
            );

    strip_1 : bus_tail_strip
        generic map (N_BYTES => 1)
        port map (
            Clk     => Clk,
            Rst     => Rst,
            PktIn   => PktOut_1,
            DataIn  => DataOut_1,
            PktOut  => PktOut,
            DataOut => DataOut
            );

    -- Clock process definitions
    Clk_process : process
    begin
        Clk <= '0';
        wait for Clk_period/2;
        Clk <= '1';
        wait for Clk_period/2;
    end process;


    -- Stimulus process
    stim_proc : process
    begin
        -- hold reset state for 100 ns.
        wait for 100 ns;

        wait for Clk_period*10;

        PktIn <= '1';
        for i in 1 to 10 loop
            DataIn <= CONV_std_logic_vector(i, 8);
            wait for Clk_period;
        end loop;
        PktIn <= '0';

        wait;
    end process;

end;
