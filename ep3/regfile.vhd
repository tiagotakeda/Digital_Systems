Library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity regfile is
    generic(
        regn        :   natural := 32;
        wordSize    :   natural := 64
    );
    port(
        clock       :   in  bit;
        reset       :   in  bit;
        regWrite    :   in  bit;
        rr1, rr2, wr:   in  bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        d           :   in  bit_vector(wordSize-1 downto 0);
        q1, q2      :   out bit_vector(wordSize-1 downto 0)
    );
end entity;

architecture arch of regfile is
 
    component reg is
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
    end component;

    signal reg_entrada : bit_vector(regn-1 downto 0);
    type saida is array (0 to regn-1) of bit_vector (wordSize-1 downto 0);
    signal reg_saida : saida;

begin  
    reg_gera: for i in 0 to regn-2 generate
        reg_gerado: reg generic map(wordSize)
            port map(clock, reset, reg_entrada(i), d, reg_saida(i));
    end generate;

    enable: process(wr, regWrite)
    begin
        for i in 0 to regn-2 loop
            if i = to_integer(unsigned(wr)) and regWrite = '1' then
                reg_entrada(i) <= '1';
            else
                reg_entrada(i) <= '0';
            end if;
        end loop;
    end process;

    reg_saida(regn-1) <= (others => '0');
    q1 <= reg_saida(to_integer(unsigned(rr1)));
    q2 <= reg_saida(to_integer(unsigned(rr2)));

end architecture;    

------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------

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