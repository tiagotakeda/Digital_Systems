use work.reg;

--Bancada de Testes para o registrador parametrizável
entity reg_tb is
  --Vazio
end entity;

architecture tb of reg_tb is

--Componentes
component reg is
  generic (
    wordSize : natural := 4
  );
  port(
    clock : in bit; --Entrada do clock
    reset : in bit; --Clear assíncrono
    load : in bit; --Write enable (carga paralela)

    d : in bit_vector(wordSize - 1 downto 0); --Entrada
    q : out bit_vector(wordSize -1 downto 0)
  );
end component;

--Constantes
constant tam_palavra : natural :=5;

--Sinais
signal clock_in, reset_in, load_in : bit;
signal d_in, q_out : bit_vector(tam_palavra -1 downto 0);

begin

  --Sinal do clock
  clock: process is
  begin
    clock_in <= '0';
    wait for 0.5 ns;
    clock_in <= '1';
    wait for 0.5 ns;
  end process;

  --Conectantdo DUT
  registrador : reg generic map(
    wordSize => tam_palavra
  )
  port map(
    clock => clock_in,
    reset => reset_in,
    load => load_in,
    d => d_in,
    q => q_out
  );

  --Process
  process
  begin

    --Testes de Escrita
    reset_in <= '0';
    load_in <= '1';
    d_in <= "01010";
    wait for 4 ns;
    assert (q_out = "01010")
    report "Falha no teste 1"
    severity error;

    reset_in <= '0';
    load_in <= '1';
    d_in <= "00000";
    wait for 4 ns;
    assert (q_out = "00000")
    report "Falha no teste 2"
    severity error;

    reset_in <= '0';
    load_in <= '1';
    d_in <= "11010";
    wait for 4 ns;
    assert (q_out = "11010")
    report "Falha no teste 3"
    severity error;

    --Teste load em LOW
    reset_in <= '0';
    load_in <= '0';
    wait for 1 ns;
    d_in <= "11111";
    wait for 4 ns;
    assert (q_out = "11010")
    report "Falha no teste 4"
    severity error;

    --Teste reset em HIGH
    reset_in <= '1';
    load_in <= '1';
    d_in <= "01011";
    wait for 4 ns;
    assert (q_out = "00000")
    report "Falha no teste 5"
    severity error;

    --Limpar inputs
    reset_in <= '0';
    load_in <= '0';
    d_in <= "00000";
    wait for 4 ns;

    assert(false)
    report "Testes Finalizados"
    severity note;

    wait;
  end process;
end architecture;
