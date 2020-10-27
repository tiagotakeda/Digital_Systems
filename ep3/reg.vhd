library ieee;
use ieee.numeric_bit.all;

entity reg is
    generic(
        wordSize    :   natural := 4
    );

    port(
        clock   :   in  bit; --! entrada de clock
        reset   :   in  bit; --! clear assincrono
        load    :   in  bit; --! write enable (carga parelela)
        d       :   in  bit_vector(wordSize-1 downto 0); --! entrada
        q       :   out bit_vector(wordSize-1 downto 0)  --! saida
    );
end reg;

architecture dataflow of reg is

    component ffd is
        port (
            clock, d, reset, load   :   in  bit;
            q                       :   out bit
        );
    end component;

begin
    regs: for i in wordSize-1 downto 0 generate
        ffs: ffd port map(clock, d(i), reset, load, q(i));
    end generate;
end architecture;

---------------------------------------------------------------------

Library ieee;
use ieee.numeric_bit.all;

entity ffd is
    port (
        clock, d, reset, load   :   in  bit;
        q                       :   out bit
    );
end entity;

architecture processor of ffd is
    begin
        sequencial: process(clock, reset)
        begin
            if reset = '1' then
                q <= '0';
            elsif (rising_edge(clock) and load = '1') then
                q <= d;
            end if;
        end process;
end architecture;