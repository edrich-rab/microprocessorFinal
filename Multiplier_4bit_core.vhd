-- from Lab4_Multiplier.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Processor-friendly version of the Lab 4 multiplier.
-- This keeps the full-adder multiplier structure but removes switches and HEX displays.
entity Multiplier_4bit_Core is
    Port (
        A : in  STD_LOGIC_VECTOR(3 downto 0);
        B : in  STD_LOGIC_VECTOR(3 downto 0);
        P : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Multiplier_4bit_Core;

architecture Structural of Multiplier_4bit_Core is

    type partial_product_type is array (0 to 3) of STD_LOGIC_VECTOR(3 downto 0);

    signal ab : partial_product_type;

    signal s1 : STD_LOGIC_VECTOR(3 downto 0);
    signal c1 : STD_LOGIC_VECTOR(3 downto 0);

    signal s2 : STD_LOGIC_VECTOR(3 downto 0);
    signal c2 : STD_LOGIC_VECTOR(3 downto 0);

    signal c3 : STD_LOGIC_VECTOR(3 downto 0);

begin

    --------------------------------------------------
    -- Partial products
    -- ab(i)(j) = A(j) AND B(i)
    --------------------------------------------------
    gen_pp: for i in 0 to 3 generate
        gen_pp_inner: for j in 0 to 3 generate
            ab(i)(j) <= A(j) and B(i);
        end generate;
    end generate;

    --------------------------------------------------
    -- Product bit 0
    --------------------------------------------------
    P(0) <= ab(0)(0);

    --------------------------------------------------
    -- First row of full adders
    --------------------------------------------------
    FA1_0: entity work.FullAdder
        port map (
            a    => ab(0)(1),
            b    => ab(1)(0),
            cin  => '0',
            s    => P(1),
            cout => c1(0)
        );

    FA1_1: entity work.FullAdder
        port map (
            a    => ab(0)(2),
            b    => ab(1)(1),
            cin  => c1(0),
            s    => s1(1),
            cout => c1(1)
        );

    FA1_2: entity work.FullAdder
        port map (
            a    => ab(0)(3),
            b    => ab(1)(2),
            cin  => c1(1),
            s    => s1(2),
            cout => c1(2)
        );

    FA1_3: entity work.FullAdder
        port map (
            a    => '0',
            b    => ab(1)(3),
            cin  => c1(2),
            s    => s1(3),
            cout => c1(3)
        );

    --------------------------------------------------
    -- Second row of full adders
    --------------------------------------------------
    FA2_0: entity work.FullAdder
        port map (
            a    => s1(1),
            b    => ab(2)(0),
            cin  => '0',
            s    => P(2),
            cout => c2(0)
        );

    FA2_1: entity work.FullAdder
        port map (
            a    => s1(2),
            b    => ab(2)(1),
            cin  => c2(0),
            s    => s2(1),
            cout => c2(1)
        );

    FA2_2: entity work.FullAdder
        port map (
            a    => s1(3),
            b    => ab(2)(2),
            cin  => c2(1),
            s    => s2(2),
            cout => c2(2)
        );

    FA2_3: entity work.FullAdder
        port map (
            a    => c1(3),
            b    => ab(2)(3),
            cin  => c2(2),
            s    => s2(3),
            cout => c2(3)
        );

    --------------------------------------------------
    -- Third row of full adders
    --------------------------------------------------
    FA3_0: entity work.FullAdder
        port map (
            a    => s2(1),
            b    => ab(3)(0),
            cin  => '0',
            s    => P(3),
            cout => c3(0)
        );

    FA3_1: entity work.FullAdder
        port map (
            a    => s2(2),
            b    => ab(3)(1),
            cin  => c3(0),
            s    => P(4),
            cout => c3(1)
        );

    FA3_2: entity work.FullAdder
        port map (
            a    => s2(3),
            b    => ab(3)(2),
            cin  => c3(1),
            s    => P(5),
            cout => c3(2)
        );

    FA3_3: entity work.FullAdder
        port map (
            a    => c2(3),
            b    => ab(3)(3),
            cin  => c3(2),
            s    => P(6),
            cout => P(7)
        );

end Structural;
