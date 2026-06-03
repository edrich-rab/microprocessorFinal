-- from Lab4_Multiplier.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
    signal s1, c1 : STD_LOGIC_VECTOR(3 downto 0);
    signal s2, c2 : STD_LOGIC_VECTOR(3 downto 0);
    signal s3, c3 : STD_LOGIC_VECTOR(3 downto 0);

begin

    gen_pp: for i in 0 to 3 generate
        gen_pp_inner: for j in 0 to 3 generate
            ab(i)(j) <= A(j) and B(i);
        end generate;
    end generate;

    P(0) <= ab(0)(0);

    FA1_0: entity work.FullAdder port map(ab(0)(1), ab(1)(0), '0',   P(1),  c1(0));
    FA1_1: entity work.FullAdder port map(ab(0)(2), ab(1)(1), c1(0), s1(1), c1(1));
    FA1_2: entity work.FullAdder port map(ab(0)(3), ab(1)(2), c1(1), s1(2), c1(2));
    FA1_3: entity work.FullAdder port map('0',      ab(1)(3), c1(2), s1(3), c1(3));

    FA2_0: entity work.FullAdder port map(s1(1),    ab(2)(0), '0',   P(2),  c2(0));
    FA2_1: entity work.FullAdder port map(s1(2),    ab(2)(1), c2(0), s2(1), c2(1));
    FA2_2: entity work.FullAdder port map(s1(3),    ab(2)(2), c2(1), s2(2), c2(2));
    FA2_3: entity work.FullAdder port map(c1(3),    ab(2)(3), c2(2), s2(3), c2(3));

    FA3_0: entity work.FullAdder port map(s2(1),    ab(3)(0), '0',   P(3),  c3(0));
    FA3_1: entity work.FullAdder port map(s2(2),    ab(3)(1), c3(0), P(4),  c3(1));
    FA3_2: entity work.FullAdder port map(s2(3),    ab(3)(2), c3(1), P(5),  c3(2));
    FA3_3: entity work.FullAdder port map(c2(3),    ab(3)(3), c3(2), P(6),  P(7));

end Structural;