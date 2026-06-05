library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory is
    Port (
        Address     : in  STD_LOGIC_VECTOR(31 downto 0);
        Instruction : out STD_LOGIC_VECTOR(31 downto 0)
    );
end InstructionMemory;

architecture Behavioral of InstructionMemory is

    type ROM_TYPE is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);

    constant ROM : ROM_TYPE := (

        -- ADDI X1, X0, #5
        -- X1 = 5
        0 => x"91001401",

        -- ADDI X2, X0, #10
        -- X2 = 10
        1 => x"91002802",

        -- ADD X3, X1, X2
        -- X3 = 15
        2 => x"8B020023",

        -- MUL X4, X1, X2
        -- X4 = 5 * 10 = 50
        -- This is the unique extension instruction.
        3 => x"9B027C24",

        -- SUB X5, X4, X3
        -- X5 = 50 - 15 = 35
        4 => x"CB030085",

        -- AND X6, X3, X2
        -- X6 = 15 AND 10 = 10
        5 => x"8A020066",

        -- ORR X7, X1, X2
        -- X7 = 5 OR 10 = 15
        6 => x"AA020027",

        -- STUR X4, [X0,#0]
        -- MEM[0] = 50
        7 => x"F8000004",

        -- LDUR X0, [X0,#0]
        -- X0 = 50
        8 => x"F8400000",

        -- CBZ X0, SKIP
        -- Not taken because X0 = 50
        9 => x"B4000040",

        -- B END
        -- Branch to instruction 12
        10 => x"14000002",

        -- ADDI X1, X0, #99
        -- Skipped by B instruction
        11 => x"91018C01",

        -- END: NOP
        12 => x"D503201F",

        others => x"D503201F"
    );

begin

    -- Word aligned instruction fetch.
    -- Address increases by 4, so use Address(6 downto 2) as the ROM index.
    Instruction <= ROM(to_integer(unsigned(Address(6 downto 2))));

end Behavioral;
