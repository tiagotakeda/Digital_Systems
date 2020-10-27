-------------------------------------------------------
--! @file t3a3_tb.vhd
--! @brief Testbench para calc em VHDL
--! @author Mateus Luis de Sousa (mateussousa010@usp.br)
--! @date 2020-10-12
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity t3a3_tb is
end entity;

architecture testbench of t3a3_tb is
  component  reg is
   generic (
        wordSize : natural := 4
        );

    port (
        clock : in bit; --! entrada de clock
        reset : in bit; --! clear assincrono
        load  : in bit ; --! write enable (carga paralela)
        d     : in bit_vector(wordSize-1 downto 0) ; --! entrada
        q     : out bit_vector(wordSize-1 downto 0) --!  saida
        );
  end component;

  component regfile is

    generic (
        regn : natural := 32;
        wordSize : natural := 64
    );

    port (
        clock : in bit;
        reset : in bit;
        regWrite : in bit;
        rr1 ,rr2 ,wr : in bit_vector(natural(ceil(log2 (real(regn)))) -1 downto 0);
        d : in bit_vector(wordSize-1 downto 0);
        q1 ,q2 : out bit_vector(wordSize-1 downto 0)
    );

    end component;

    component calc is

        port (
            clock : in bit;
            reset : in bit;
            instruction : in bit_vector(15 downto 0);
            overflow : out bit;
            q1 : out bit_vector(15 downto 0)
        );
    
    end component;
  
  -- sinais de suporte
  signal instruction_signal: bit_vector(15 downto 0);
  signal out_signal: bit_vector(15 downto 0);
  signal overflow_signal: bit;
  signal stopc, clock_sup, reset_sup: bit := '0';

  signal opcode_sup: bit;
  signal oper2_sup, oper1_sup, dest_sup: bit_vector(4 downto 0);

  -- Periodo do clock
  constant periodo : time := 10 ns;

begin

  -- Geração de clock
  clock_sup <= stopc and (not clock_sup) after periodo/2;

  instruction_signal(15) <= opcode_sup;
  instruction_signal(14 downto 10) <= oper2_sup;
  instruction_signal(9 downto 5) <= oper1_sup;
  instruction_signal(4 downto 0) <= dest_sup;

  -- Instâncias a serem testada
  dut_calc: calc port map(clock_sup, reset_sup, instruction_signal, overflow_signal, out_signal);

  -- Estímulos
  stim: process

  begin
    stopc <= '1';

    opcode_sup <= '0';
    oper2_sup <= "10000";
    oper1_sup <= "11111";
    dest_sup <= "00000";
    wait for 10 ns;
    assert not(out_signal = "0000000000000000" and overflow_signal = '0')
    report "1.OK: q_0 = -16; reset=0; out = 0" severity note;

    opcode_sup <= '0';
    oper2_sup <= "00101";
    oper1_sup <= "11111";
    dest_sup <= "00001";
    wait for 10 ns;
    assert not(out_signal = "0000000000000000" and overflow_signal = '0')
    report "2.OK: q_1 = +5; reset=0; out = 0" severity note;

    opcode_sup <= '1';
    oper2_sup <= "00001";
    oper1_sup <= "00000";
    dest_sup <= "00010";
    wait for 10 ns;
    assert not(out_signal = "1111111111110000" and overflow_signal = '0')
    report "3.OK: q_2 = -11; reset=0; out = -16" severity note;

    opcode_sup <= '0';
    oper2_sup <= "00000";
    oper1_sup <= "00010";
    dest_sup <= "00010";
    wait for 10 ns;
    assert not(out_signal = "1111111111110101" and overflow_signal = '0')
    report "4.OK: q_2 = -11; reset=0; out = -11" severity note;

    -- final do testbench
    stopc <= '0';

    wait;

  end process;

end architecture;