Library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity calc is
    port(
        clock       :   in  bit;
        reset       :   in  bit;
        instruction :   in  bit_vector(15 downto 0);
        overflow    :   out bit;
        q1          :   out bit_vector(15 downto 0)
    );
end entity;

architecture arch_calc of calc is

    component regfile is
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
    end component;

    component fa_nbits is
        generic(
          n : natural
        );
        port(
          A, B: in bit_vector(n - 1 downto 0);
          CinI: in bit;
          S: out bit_vector(n - 1 downto 0);
          CoutF: out bit
        );
    end component;

    signal op, sum_cout, comp2_cout : bit;
    signal op1, op2, dest : bit_vector(4 downto 0);
    signal p1, p2, q2_saida, sum_result : bit_vector(15 downto 0);

    constant regsN : natural := 32;
    constant tam_palavra : natural := 16;
    constant num_bits_regs : natural := 5;

begin
    op1 <= instruction(9 downto 5);
    op2 <= instruction(14 downto 10);
    op  <= instruction(15);

    with op select
        p2 <=
            q2_saida when '1',
            (3 => instruction(13), 2 => instruction(12), 1 => instruction(11),
             0 => instruction(10), others => instruction(14)) when '0',
             q2_saida when others;

    sum: fa_nbits generic map(tam_palavra)
                port map(p1, p2, '0', sum_result, sum_cout);

    
    REGISTRADORES: regfile generic map(regsN)
        port map(clock, reset, '1', op1, op2, dest, sum_result, p1, q2_saida);

        
    q1 <= p1;
    dest <= instruction(4 downto 0);
    overflow <= ((p1(15) and p2(15)) and not sum_result(15)) or 
            ((not p1(15) and not p2(15)) and sum_result(15));
end architecture;

-----------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------

library IEEE;
use IEEE.math_real.all;
use IEEE.numeric_bit.all;

entity fa_1bit is
  port (
    A,B : in bit;       -- adends
    CIN : in bit;       -- carry-in
    SUM : out bit;      -- sum
    COUT : out bit      -- carry-out
    );
end entity fa_1bit;

architecture wakerly of fa_1bit is

begin
  SUM <= (A xor B) xor CIN;
  COUT <= (A and B) or (CIN and A) or (CIN and B);
end architecture wakerly;
--------------------------------------------------------------------------------------------

library IEEE;
use IEEE.math_real.all;
use IEEE.numeric_bit.all;

entity fa_nbits is
  generic(
    n : natural
  );
  port(
    A, B: in bit_vector(n - 1 downto 0);
    CinI: in bit;
    S: out bit_vector(n - 1 downto 0);
    CoutF: out bit
  );
end entity;

architecture fa_nbits_arch of fa_nbits is

component fa_1bit is
  port (
    A,B : in bit;       -- adends
    CIN : in bit;       -- carry-in
    SUM : out bit;      -- sum
    COUT : out bit      -- carry-out
    );
end component fa_1bit;

signal carry : bit_vector(n downto 0);

begin
  carry(0) <= CinI;

  gen_add : for i in 0 to n-1 generate
    sum : fa_1bit port map(A(i), B(i), carry(i), S(i), carry(i +1));
  end generate;

  CoutF <= carry(n);
end architecture;