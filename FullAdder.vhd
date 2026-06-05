library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Processor is
    Port(
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC
    );
end Processor;

architecture Behavioral of Processor is

    ---------------------------------------------------
    -- Program Counter and Instruction Fetch Signals
    ---------------------------------------------------
    signal PC          : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal NextPC      : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus4     : STD_LOGIC_VECTOR(31 downto 0);
    signal BranchAddr  : STD_LOGIC_VECTOR(31 downto 0);
    signal Instruction : STD_LOGIC_VECTOR(31 downto 0);

    ---------------------------------------------------
    -- Register File Signals
    ---------------------------------------------------
    signal ReadReg1    : STD_LOGIC_VECTOR(4 downto 0);
    signal ReadReg2    : STD_LOGIC_VECTOR(4 downto 0);
    signal WriteReg    : STD_LOGIC_VECTOR(4 downto 0);

    signal ReadData1   : STD_LOGIC_VECTOR(31 downto 0);
    signal ReadData2   : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData   : STD_LOGIC_VECTOR(31 downto 0);

    ---------------------------------------------------
    -- Immediate and ALU Signals
    ---------------------------------------------------
    signal Immediate   : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUInputB   : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResult   : STD_LOGIC_VECTOR(31 downto 0);
    signal Zero        : STD_LOGIC;

    ---------------------------------------------------
    -- Data Memory Signal
    ---------------------------------------------------
    signal MemData     : STD_LOGIC_VECTOR(31 downto 0);

    ---------------------------------------------------
    -- Control Signals
    ---------------------------------------------------
    signal RegWrite    : STD_LOGIC;
    signal ALUSrc      : STD_LOGIC;
    signal MemRead     : STD_LOGIC;
    signal MemWrite    : STD_LOGIC;
    signal MemtoReg    : STD_LOGIC;
    signal Branch      : STD_LOGIC;
    signal UncondBr    : STD_LOGIC;
    signal BranchTaken : STD_LOGIC;
    signal ALUControl  : STD_LOGIC_VECTOR(3 downto 0);

    ---------------------------------------------------
    -- MUL Extension Signals
    -- Uses Lab 4 full-adder multiplier structure.
    ---------------------------------------------------
    signal MulA        : STD_LOGIC_VECTOR(3 downto 0);
    signal MulB        : STD_LOGIC_VECTOR(3 downto 0);
    signal MulP        : STD_LOGIC_VECTOR(7 downto 0);
    signal MulResult32 : STD_LOGIC_VECTOR(31 downto 0);

    ---------------------------------------------------
    -- Register File Storage
    -- XZR is represented as register 31 and always reads as zero.
    ---------------------------------------------------
    type REG_ARRAY is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal Regs : REG_ARRAY := (others => (others => '0'));

    ---------------------------------------------------
    -- Data Memory Storage
    -- 128 words, each 32 bits wide.
    ---------------------------------------------------
    type MEM_ARRAY is array (0 to 127) of STD_LOGIC_VECTOR(31 downto 0);
    signal DataMem : MEM_ARRAY := (others => (others => '0'));

begin

    ---------------------------------------------------
    -- 1. Program Counter
    -- Reset sets PC to 0.
    -- Otherwise, PC updates on the rising edge of clk.
    ---------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            PC <= (others => '0');

        elsif rising_edge(clk) then
            PC <= NextPC;

        end if;
    end process;

    -- Normal next instruction address
    PCPlus4 <= STD_LOGIC_VECTOR(unsigned(PC) + 4);

    -- Branch target address
    BranchAddr <= STD_LOGIC_VECTOR(signed(PC) + signed(Immediate));

    -- Branch decision
    BranchTaken <= UncondBr or (Branch and Zero);

    -- PC selection MUX
    NextPC <= BranchAddr when BranchTaken = '1' else PCPlus4;

    ---------------------------------------------------
    -- 2. Instruction Memory
    ---------------------------------------------------
    IMEM : entity work.InstructionMemory
        port map(
            Address     => PC,
            Instruction => Instruction
        );

    ---------------------------------------------------
    -- 3. Register File
    ---------------------------------------------------

    -- For CBZ, the register being checked is in Instruction(4 downto 0).
    -- For other register instructions, Xn is in Instruction(9 downto 5).
    ReadReg1 <= Instruction(4 downto 0) when Instruction(31 downto 24) = "10110100" else
                Instruction(9 downto 5);

    -- For STUR, the register to store is in Instruction(4 downto 0).
    -- For R-type instructions, Xm is in Instruction(20 downto 16).
    ReadReg2 <= Instruction(4 downto 0) when MemWrite = '1' else
                Instruction(20 downto 16);

    -- Destination register
    WriteReg <= Instruction(4 downto 0);

    -- Asynchronous register reads
    ReadData1 <= (others => '0') when ReadReg1 = "11111" else
                 Regs(to_integer(unsigned(ReadReg1)));

    ReadData2 <= (others => '0') when ReadReg2 = "11111" else
                 Regs(to_integer(unsigned(ReadReg2)));

    -- Synchronous register write
    process(clk)
    begin
        if rising_edge(clk) then
            if RegWrite = '1' and WriteReg /= "11111" then
                Regs(to_integer(unsigned(WriteReg))) <= WriteData;
            end if;
        end if;
    end process;

    ---------------------------------------------------
    -- 4. Immediate Generator
    -- Supports ADDI, LDUR, STUR, CBZ, and B.
    ---------------------------------------------------
    process(Instruction)
        variable imm12 : signed(11 downto 0);
        variable imm9  : signed(8 downto 0);
        variable imm19 : signed(18 downto 0);
        variable imm26 : signed(25 downto 0);
    begin

        Immediate <= (others => '0');

        if Instruction(31 downto 22) = "1001000100" then

            -- ADDI immediate
            imm12 := signed(Instruction(21 downto 10));
            Immediate <= STD_LOGIC_VECTOR(resize(imm12, 32));

        elsif Instruction(31 downto 21) = "11111000010" or
              Instruction(31 downto 21) = "11111000000" then

            -- LDUR/STUR immediate
            imm9 := signed(Instruction(20 downto 12));
            Immediate <= STD_LOGIC_VECTOR(resize(imm9, 32));

        elsif Instruction(31 downto 24) = "10110100" then

            -- CBZ immediate shifted left by 2
            imm19 := signed(Instruction(23 downto 5));
            Immediate <= STD_LOGIC_VECTOR(shift_left(resize(imm19, 32), 2));

        elsif Instruction(31 downto 26) = "000101" then

            -- B immediate shifted left by 2
            imm26 := signed(Instruction(25 downto 0));
            Immediate <= STD_LOGIC_VECTOR(shift_left(resize(imm26, 32), 2));

        end if;

    end process;

    ---------------------------------------------------
    -- MUL Extension Hardware
    -- Reuses the Lab 4 4-bit by 4-bit full-adder multiplier.
    -- The lower 4 bits of Xn and Xm are multiplied.
    ---------------------------------------------------
    MulA <= ReadData1(3 downto 0);
    MulB <= ReadData2(3 downto 0);

    MUL_UNIT : entity work.Multiplier_4bit_Core
        port map(
            A => MulA,
            B => MulB,
            P => MulP
        );

    -- Zero-extend 8-bit multiplier product to 32 bits.
    MulResult32 <= x"000000" & MulP;

    ---------------------------------------------------
    -- 5. ALU
    -- ALUControl:
    -- 0000 = ADD
    -- 0001 = SUB
    -- 0010 = AND
    -- 0011 = ORR
    -- 0100 = MUL extension
    -- 0101 = PASS A for CBZ
    ---------------------------------------------------
    ALUInputB <= Immediate when ALUSrc = '1' else ReadData2;

    process(ReadData1, ALUInputB, ALUControl, MulResult32)
    begin

        case ALUControl is

            when "0000" =>
                ALUResult <= STD_LOGIC_VECTOR(signed(ReadData1) + signed(ALUInputB));

            when "0001" =>
                ALUResult <= STD_LOGIC_VECTOR(signed(ReadData1) - signed(ALUInputB));

            when "0010" =>
                ALUResult <= ReadData1 and ALUInputB;

            when "0011" =>
                ALUResult <= ReadData1 or ALUInputB;

            when "0100" =>
                ALUResult <= MulResult32;

            when "0101" =>
                ALUResult <= ReadData1;

            when others =>
                ALUResult <= (others => '0');

        end case;

    end process;

    Zero <= '1' when ALUResult = x"00000000" else '0';

    ---------------------------------------------------
    -- 6. Data Memory
    -- Word-addressed using ALUResult bits 8 downto 2.
    ---------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if MemWrite = '1' then
                DataMem(to_integer(unsigned(ALUResult(8 downto 2)))) <= ReadData2;
            end if;
        end if;
    end process;

    MemData <= DataMem(to_integer(unsigned(ALUResult(8 downto 2)))) when MemRead = '1' else
               (others => '0');

    ---------------------------------------------------
    -- 7. Writeback MUX
    -- MemtoReg = 1 selects memory data.
    -- MemtoReg = 0 selects ALU result.
    ---------------------------------------------------
    WriteData <= MemData when MemtoReg = '1' else ALUResult;

    ---------------------------------------------------
    -- 8. Control Unit and Branch Logic
    -- Combinational decode for required instructions plus MUL extension.
    ---------------------------------------------------
    process(Instruction)
    begin

        -- Default control values
        RegWrite   <= '0';
        ALUSrc     <= '0';
        MemRead    <= '0';
        MemWrite   <= '0';
        MemtoReg   <= '0';
        Branch     <= '0';
        UncondBr   <= '0';
        ALUControl <= "0000";

        if Instruction(31 downto 21) = "10001011000" then

            -- ADD
            RegWrite   <= '1';
            ALUControl <= "0000";

        elsif Instruction(31 downto 21) = "11001011000" then

            -- SUB
            RegWrite   <= '1';
            ALUControl <= "0001";

        elsif Instruction(31 downto 21) = "10001010000" then

            -- AND
            RegWrite   <= '1';
            ALUControl <= "0010";

        elsif Instruction(31 downto 21) = "10101010000" then

            -- ORR
            RegWrite   <= '1';
            ALUControl <= "0011";

        elsif Instruction(31 downto 21) = "10011011000" and
              Instruction(15 downto 10) = "011111" then

            -- MUL Xd, Xn, Xm
            -- Unique extension feature
            RegWrite   <= '1';
            ALUSrc     <= '0';
            ALUControl <= "0100";

        elsif Instruction(31 downto 22) = "1001000100" then

            -- ADDI
            RegWrite   <= '1';
            ALUSrc     <= '1';
            ALUControl <= "0000";

        elsif Instruction(31 downto 21) = "11111000010" then

            -- LDUR
            RegWrite   <= '1';
            ALUSrc     <= '1';
            MemRead    <= '1';
            MemtoReg   <= '1';
            ALUControl <= "0000";

        elsif Instruction(31 downto 21) = "11111000000" then

            -- STUR
            ALUSrc     <= '1';
            MemWrite   <= '1';
            ALUControl <= "0000";

        elsif Instruction(31 downto 24) = "10110100" then

            -- CBZ
            Branch     <= '1';
            ALUControl <= "0101";

        elsif Instruction(31 downto 26) = "000101" then

            -- B
            UncondBr   <= '1';

        end if;

    end process;

end Behavioral;
