-- full adder from lab 4
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullAdder is
    Port (
        a    : in  STD_LOGIC;
        b    : in  STD_LOGIC;
        cin  : in  STD_LOGIC;
        s    : out STD_LOGIC;
        cout : out STD_LOGIC
    );
end FullAdder;

architecture Behavioral of FullAdder is
begin

    s    <= a xor b xor cin;
    cout <= (a and b) or (cin and (a xor b));

end Behavioral;
