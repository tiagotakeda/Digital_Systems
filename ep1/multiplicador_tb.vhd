-------------------------------------------------------
--! @file multiplicador_tb.vhd
--! @brief testbench for synchronous multiplier
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-15
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity multiplicador_tb is
end entity;

architecture tb of multiplicador_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component multiplicador
    port (
	  signed_mult: 	in bit;
      Clock:    	in  bit;	  
      Reset:    	in  bit;
      Start:    	in  bit;
      Va,Vb:    	in  bit_vector(3 downto 0);
      Vresult:  	out bit_vector(7 downto 0);
      Ready:    	out bit
    );
  end component;
  
  -- Declaração de sinais para conectar a componente
  signal clk_in: bit := '0';
  signal sig_in: bit := '0';						-- PARA TESTE
  signal rst_in, start_in, ready_out: bit := '0';
  signal va_in, vb_in: bit_vector(3 downto 0);
  signal result_out: bit_vector(7 downto 0);

  -- Configurações do clock
  signal keep_simulating: bit := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 1 ns;
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- O código abaixo, sem o "keep_simulating", faria com que o clock executasse
  ---- indefinidamente, de modo que a simulação teria que ser interrompida manualmente
  -- clk_in <= (not clk_in) after clockPeriod/2; 
  
  -- Conecta DUT (Device Under Test)
  dut: multiplicador
       port map(Clock=>   clk_in,
				signed_mult=>	sig_in,			-- PARA TESTE
                Reset=>   rst_in,
                Start=>   start_in,
                Va=>      va_in,
                Vb=>      vb_in,
                Vresult=> result_out,
                Ready=>   ready_out
      );

  ---- Gera sinais de estimulo
  stimulus: process is
  begin
  
    assert false report "simulation start" severity note;
    keep_simulating <= '1';
    
    ---- Caso de teste 1: A=3, B=6
    Va_in <= "0011"; 
    Vb_in <= "0110";
	sig_in <= '0';
    -- Reset inicial (1 periodo de clock) - não precisa repetir
    rst_in <= '1'; start_in <= '0';
    wait for clockPeriod;
    rst_in <= '0';
    wait until falling_edge(clk_in);
    -- pulso do sinal de Start
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="00010010") report "1.OK: 3x6=00010010 (18)" severity note;
    
    wait for clockPeriod;

    ----------------------------------------------------------------------------------

    ---- Caso de teste 2: A=15, B=11
    Va_in <= "1111"; 
    Vb_in <= "1011";
	sig_in <= '0';	
    -- pulso do sinal de Start
    wait until falling_edge(clk_in);
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="10100101") report "2.OK: 15x11=10100101 (165)" severity note;
    
    wait for clockPeriod;    

    ----------------------------------------------------------------------------------

    ---- Caso de teste 3: A=15, B=0
    Va_in <= "1111"; 
    Vb_in <= "0000";
	sig_in <= '0';
    -- pulso do sinal de Start
    wait until falling_edge(clk_in);
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="00000000") report "3.OK: 15x0=00000000 (0)" severity note;
    
    wait for clockPeriod;    
 
    ----------------------------------------------------------------------------------

    ---- Caso de teste 4: A=1, B=11
    Va_in <= "0001"; 
    Vb_in <= "1011";
	sig_in <= '0';
    -- pulso do sinal de Start
    wait until falling_edge(clk_in);
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="00001011") report "4.OK: 1x11=00001011 (11)" severity note;
    
    wait for clockPeriod;  
    ----------------------------------------------------------------------------------
	
	---- Caso de teste 5: A=-3, B=4
    Va_in <= "1101"; --> 13
    Vb_in <= "0100"; --> 4
	sig_in <= '1';
    -- pulso do sinal de Start
    wait until falling_edge(clk_in);
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="11110100") report "5.OK: -3x4=11110100 (-12)" severity note;
    
    wait for clockPeriod;  
	
	----------------------------------------------------------------------------------
	
	---- Caso de teste 6: A=0, B=-4
    Va_in <= "0000"; --> 0
    Vb_in <= "1100"; --> -4
	sig_in <= '1';
    -- pulso do sinal de Start
    wait until falling_edge(clk_in);
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="00000000") report "6.OK: 0x-4=00000000 (0)" severity note;
    
    wait for clockPeriod;  

	----------------------------------------------------------------------------------
	
	---- Caso de teste 7: A=-8, B=-4
    Va_in <= "1000"; --> -8
    Vb_in <= "1100"; --> -4
	sig_in <= '1';
    -- pulso do sinal de Start
    wait until falling_edge(clk_in);
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="00100000") report "7.OK: -8x-4=00100000 (32)" severity note;
    
    wait for clockPeriod;  
	
	----------------------------------------------------------------------------------
	
	---- Caso de teste 8: A=-1, B=-4
    Va_in <= "1111"; --> -1
    Vb_in <= "1100"; --> -4
	sig_in <= '1';
    -- pulso do sinal de Start
    wait until falling_edge(clk_in);
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="00000100") report "8.OK: -4x-1=00000100 (4)" severity note;
    
    wait for clockPeriod;  

    ---- inserir outros casos de teste aqui

    ----------------------------------------------------------------------------------

    ---- Caso de teste 65846841: A=5, B=-3
    Va_in <= "0101"; 
    Vb_in <= "1101";
	sig_in <= '1';
    -- pulso do sinal de Start
    wait until falling_edge(clk_in);
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="11110001") report "3.OK: 5x-3=11110001 (0)" severity note;
    
    wait for clockPeriod;    
 
    ----------------------------------------------------------------------------------

    ----------------------------------------------------------------------------------

    ---- Caso de teste 65846841: A=-3, B=5
    Va_in <= "1101"; 
    Vb_in <= "0101";
	sig_in <= '1';
    -- pulso do sinal de Start
    wait until falling_edge(clk_in);
    start_in <= '1';
    wait until falling_edge(clk_in);
    start_in <= '0';
    -- espera pelo termino da multiplicacao
    wait until ready_out='1';
    -- verifica resultado
    assert (result_out/="11110001") report "3.OK: 5x-3=11110001 (0)" severity note;
    
    wait for clockPeriod;    
 
    ----------------------------------------------------------------------------------



    ----------------------------------------------------------------------------------
 
    -- final do testbench
    assert false report "simulation end" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;
