
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY hex4x7seg IS
   GENERIC(RSTDEF: std_logic := '0');
   PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
        clk:   IN  std_logic;                       -- clock,           rising edge
        data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      active high
        dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
        ena:   OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable  signals,                active high
        seg:   OUT std_logic_vector( 7 DOWNTO 1);   -- 7 connections to seven-segment display, active high
        dp:    OUT std_logic);                      -- decimal point output,                   active high
END hex4x7seg;

ARCHITECTURE struktur OF hex4x7seg IS
    CONSTANT FREQ_N: natural := 2**14;
    CONSTANT MOD4_N: natural := 4;

    SIGNAL freq_cnt: std_logic_vector(0 TO 13);
    SIGNAL mod4_cnt: std_logic_vector(0 TO 1);
    SIGNAL mux_out: std_logic_vector(0 TO 3);
    SIGNAL mod14_ena: std_logic;
BEGIN


    -- Modulo-2**14-Zaehler
    p1: PROCESS (rst, clk) IS
    BEGIN
        IF rst=RSTDEF THEN
            freq_cnt <= (OTHERS => '0');
            mod14_ena <= '0';
        ELSIF rising_edge(clk) THEN
            IF freq_cnt=FREQ_N-1 THEN
                mod14_ena <= '1';
            ELSE
                mod14_ena <= '0';
            END IF;
            freq_cnt <= freq_cnt + 1;
        END IF;
    END PROCESS;


    -- Modulo-4-Zaehler
    p2: PROCESS (rst, clk) IS
    BEGIN
        IF rst=RSTDEF THEN
            mod4_cnt <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF mod14_ena = '1' THEN
                mod4_cnt <= mod4_cnt + 1;
            END IF;
        END IF;
    END PROCESS;

    
    -- 1-aus-4-Dekoder als Phasengenerator
    p3: PROCESS (rst, mod4_cnt) IS
    BEGIN
        IF rst=RSTDEF THEN
            ena <= (OTHERS => '0');
        ELSE
            CASE mod4_cnt IS
                WHEN "00" => 
                    ena <= "0001";
                WHEN "01" =>
                    ena <= "0010";
                WHEN "10" =>
                    ena <= "0100";
                WHEN "11" => 
                    ena <= "1000";
            END CASE;
        END IF;
    END PROCESS;

    
    -- 1-aus-4-Multiplexer
    WITH mod4_cnt SELECT
        mux_out <= data(3 DOWNTO 0) WHEN "00",
                    data(7 DOWNTO 4) WHEN "01",
                    data(11 DOWNTO 8) WHEN "10",
                    data(15 DOWNTO 12) WHEN "11";

    
    -- 7-aus-4-Dekoder
    WITH mux_out SELECT
        seg <= "0111111" WHEN "0000",
            "0000110" WHEN "0001",
            "1011011" WHEN "0010",
            "1001111" WHEN "0011",
            "1100110" WHEN "0100",
            "1101101" WHEN "0101",
            "1111101" WHEN "0110",
            "0000111" WHEN "0111",
            "1111111" WHEN "1000",
            "1101111" WHEN "1001",
            "1110111" WHEN "1010",
            "1111100" WHEN "1011",
            "0111001" WHEN "1100",
            "1011110" WHEN "1101",
            "1111001" WHEN "1110",
            "1110001" WHEN "1111";

    -- 1-aus-4-Multiplexer
    WITH mod4_cnt SELECT
        dp <= dpin(0) WHEN "00",
            dpin(1) WHEN "01",
            dpin(2) WHEN "10",
            dpin(3) WHEN "11";

END struktur;

