--------------------------------------------------------
----! @file alu_tb.vhd
----! @brief testbench ALU (n bits)
----! @author Lucas Lopes (lucas.lopes.paula@usp.br)
----! @date 17/10/2020
---------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity alu_tb is
end entity;

architecture testbench of alu_tb is
  component alu is
    generic (
      size : natural := 10 --bit size
    );
    port (
      A, B  :   in  bit_vector(size-1 downto 0); -- inputs
      F     :   out bit_vector(size-1 downto 0); -- outputs
      S     :   in  bit_vector(3 downto 0); -- op selection
      Z     :   out bit; -- zero flag
      Ov    :   out bit; -- overflow flag
      Co    :   out bit -- carry out
    );
  end component;

  -- sinais de suporte
  signal size : natural := 10;
  signal a_tb, b_tb, res : bit_vector(size-1 downto 0);
  signal zero, ovf, cout : bit;
  signal op : bit_vector(3 downto 0);

begin
  -- DUT (Device Under Test)
  alunbits : alu generic map (size) port map(A => a_tb, B => b_tb, S => op, F => res, Co => cout, Ov => ovf, Z => zero);

  -- Estímulos
  stim: process

  begin
    op <= "0000"; -- A and B
    a_tb <= "0000100000";
    b_tb <= "1111001110";
    wait for 5 ns;
    assert ((res = "0000000000") and (zero = '1') and (ovf = '0') and (cout = '0'))
    report "Teste 1: Erro on: A and B" severity error;

    a_tb <= "0010101000"; -- A and B
    wait for 5 ns;
    assert ((res = "0010001000") and (zero = '0') and (ovf = '0') and (cout = '1'))
    report "Teste 2: Error on A and B" severity error;

    op <= "0001"; -- A or B
    a_tb <= "1010010100";
    b_tb <= "0101010011";
    wait for 5 ns;
    assert ((res = "1111010111") and (zero = '0') and (ovf = '0') and (cout = '0'))
    report "Teste 3: Error on: A or B" severity error;

    op <= "0010"; -- A + B
    a_tb <= "1111111111";
    b_tb <= "1001110011";
    wait for 5 ns;
    assert ((res = "1001110010") and (zero = '0') and (ovf = '0') and (cout = '1'))
    report "Teste 4: Error on: A + B" severity error;

    op <= "0110"; -- A - B
    a_tb <= "1000100001";
    b_tb <= "0101100010";
    wait for 5 ns;
    assert ((res = "0010111111") and (zero = '0') and (ovf = '1') and (cout = '1'))
    report "Teste 5: Error on: A - B" severity error;

    op <= "0111"; -- A < B -> SLT = Set on Less Than
    a_tb <= "0101110101";
    b_tb <= "1011110011";
    wait for 5 ns;
    assert ((res = "0000000001") and (zero = '0') and (ovf = '1') and (cout = '0'))
    report "Teste 6: Error on: A < B" severity error;

    op <= "1100"; -- A nor B
    a_tb <= "1000000001";
    b_tb <= "0101110001";
    wait for 5 ns;
    assert ((res = "0010001110") and (zero = '0') and (ovf = '0') and (cout = '1'))
    report "Teste 7: Error on: A nor B" severity error;

  wait;

  end process;

end architecture;
