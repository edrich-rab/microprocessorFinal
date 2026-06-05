library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tProcessor is
end tProcessor;

architecture Behavioral of tProcessor is

    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';

begin

    --------------------------------------------------
    -- Device Under Test
    --------------------------------------------------
    DUT : entity work.Processor
        port map(
            clk   => clk,
            reset => reset
        );

    --------------------------------------------------
    -- Clock Generation
    -- Clock period = 20 ns
    --------------------------------------------------
    clk_process : process
    begin

        while true loop

            clk <= '0';
            wait for 10 ns;

            clk <= '1';
            wait for 10 ns;

        end loop;

    end process;

    --------------------------------------------------
    -- Reset
    --------------------------------------------------
    reset_process : process
    begin

        reset <= '1';
        wait for 25 ns;

        reset <= '0';
        wait;

    end process;

end Behavioral;
