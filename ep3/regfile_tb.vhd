library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity regfile_tb is
end entity;

architecture tb of regfile_tb is

	constant wordSize : natural := 6;
	constant regn : natural := 8;
	constant clockPeriod : time := 1 ns;

	signal clock, reset, regWrite : bit;
	signal rr1, rr2, wr : bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
	signal d, q1, q2 : bit_vector(wordSize-1 downto 0);

	signal keep_simulating: bit := '0';

	component regfile is
		generic(
			regn : natural;
			wordSize : natural
		);
		port(
			clock: in  bit;
			reset: in  bit;
			regWrite : in  bit;
			rr1, rr2, wr : in  bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
			d: in  bit_vector(wordSize-1 downto 0);
			q1 , q2  : out bit_vector(wordSize-1 downto 0)
		);
	end component;

begin
	
	clock <= (not clock) and keep_simulating after clockPeriod/2;
  	
  	------ DUT -----------------------------------------------
  	DUT: regfile 
		generic map(
			wordSize => wordSize,
		regn => regn
  		)
  		port map(
			clock    => clock,
			reset    => reset,
			regWrite => regWrite,
			rr1      => rr1,
			rr2      => rr2,
			wr       => wr,
			d        => d,
			q1       => q1,
			q2       => q2
  		);

  	process
  	begin
		keep_simulating <= '1';
		report "Simulação iniciada:"; -- Inicio

		-- reset rapido
		reset <= '1';
		wait for clockPeriod;
		reset <= '0';
		rr1 <= "000";
		rr2 <= "000";

		wait for 0.25*clockPeriod; -- Offset do clock

		-- Tentando escrever com regWrite ativo   
		regWrite <= '1';

		rr1 <= "000"; -- Ler do registrador 0
		rr2 <= "001"; -- Ler do registrador 1
		wr  <= "000"; -- Escrever no registrador 0
		d <= "000111";
		wait for clockPeriod;
		assert (q1 = "000111") report "Teste 1.1: errado" severity error;
		assert (q1/= "000111") report "Teste 1.1: certo" severity error;
		assert (q2 = "000000") report "Teste 1.2: errado" severity error;
		assert (q2/= "000000") report "Teste 1.2: certo" severity error;

		rr1 <= "001"; -- Ler do registrador 1
		rr2 <= "000"; -- Ler do registrador 0
		wr  <= "001"; -- Escrever no registrador 1
		d <= "001110";
		wait for clockPeriod;
		assert (q1 = "001110") report "Teste 2.1: errado" severity error;
		assert (q1/= "001110") report "Teste 2.1: certo" severity error;
		assert (q2 = "000111") report "Teste 2.2: errado" severity error;
		assert (q2/= "000111") report "Teste 2.2: certo" severity error;

		rr1 <= "000"; -- Ler do registrador 0
		rr2 <= "010"; -- Ler do registrador 2
		wr  <= "010"; -- Escrever no registrador 2
		d <= "010101";
		wait for clockPeriod;
		assert (q1 = "000111") report "Teste 3.1: errado" severity error;
		assert (q1/= "000111") report "Teste 3.1: certo" severity error;
		assert (q2 = "010101") report "Teste 3.2: errado" severity error;
		assert (q2/= "010101") report "Teste 3.2: certo" severity error;

		rr1 <= "110"; -- Ler do registrador 6
		rr2 <= "111"; -- Ler do registrador 7
		wr  <= "111"; -- Escrever no registrador 7
		d <= "111111";
		wait for clockPeriod;
		assert (q1 = "000000") report "Teste 4.1: errado" severity error;
		assert (q1/= "000000") report "Teste 4.1: certo" severity error;
		assert (q2 = "000000") report "Teste 4.2: errado" severity error;
		assert (q2/= "000000") report "Teste 4.2: certo" severity error;

		-- Tentando escrever com regWrite inativo
		regWrite <= '0';

		rr1 <= "000"; -- Ler do registrador 0
		rr2 <= "001"; -- Ler do registrador 1
		wr  <= "000"; -- Escrever no registrador 0
		d <= "111000";
		wait for clockPeriod;
		assert (q1 = "000111") report "Teste 5.1: errado" severity error;
		assert (q1/= "000111") report "Teste 5.1: certo" severity error;
		assert (q2 = "001110") report "Teste 5.2: errado" severity error;
		assert (q2/= "001110") report "Teste 5.2: certo" severity error;

		-- Tentando resetar sem escrever
		reset <= '1';

		wait for 0.1*clockPeriod;
		assert (q1 = "000000") report "Teste 6.1: errado" severity error;
		assert (q1/= "000000") report "Teste 6.1: certo" severity error;
		assert (q2 = "000000") report "Teste 6.2: errado" severity error;
		assert (q2/= "000000") report "Teste 6.2: certo" severity error;
		wait for 0.9*clockPeriod;

		-- Tentando escrever resetando
		reset <= '1';
		regWrite <= '1';

		rr1 <= "000"; -- Ler do registrador 0
		rr2 <= "001"; -- Ler do registrador 1
		wr  <= "000"; -- Escrever no registrador 0
		d <= "111000";
		wait for clockPeriod;
		assert (q1 = "000000") report "Teste 7.1: errado" severity error;
		assert (q1/= "000000") report "Teste 7.1: certo" severity error;
		assert (q2 = "000000") report "Teste 7.2: errado" severity error;
		assert (q2/= "000000") report "Teste 7.2: certo" severity error;

		report "Simulação finalizada";
		keep_simulating <= '0';
		wait;
	end process;
end architecture;
