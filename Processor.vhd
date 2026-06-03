library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Processor is
    Port(
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC
    );
end Processor;

architecture Behavioral of Processor is

    signal PC          : STD_LOGIC_VECTOR(31 downto 0);
    signal Instruction : STD_LOGIC_VECTOR(31 downto 0);

    signal ReadData1   : STD_LOGIC_VECTOR(31 downto 0);
    signal ReadData2   : STD_LOGIC_VECTOR(31 downto 0);

    signal Immediate   : STD_LOGIC_VECTOR(31 downto 0);

    signal ALUResult   : STD_LOGIC_VECTOR(31 downto 0);

    signal MemData     : STD_LOGIC_VECTOR(31 downto 0);

begin

    ---------------------------------------------------
    -- PC Module
    ---------------------------------------------------

    -- ADD YOUR PC MODULE HERE

    ---------------------------------------------------
    -- Instruction Memory
    ---------------------------------------------------

    IMEM : entity work.InstructionMemory
        port map(
            Address     => PC,
            Instruction => Instruction
        );

    ---------------------------------------------------
    -- Register File
    ---------------------------------------------------

    -- ADD YOUR REGISTER FILE HERE

    ---------------------------------------------------
    -- Immediate Generator
    ---------------------------------------------------

    -- ADD YOUR IMMEDIATE GENERATOR HERE

    ---------------------------------------------------
    -- ALU
    ---------------------------------------------------

    -- ADD YOUR ALU HERE

    ---------------------------------------------------
    -- Data Memory
    ---------------------------------------------------

    -- ADD YOUR DATA MEMORY HERE

    ---------------------------------------------------
    -- Control Unit
    ---------------------------------------------------

    -- ADD YOUR CONTROL UNIT HERE

end Behavioral;
