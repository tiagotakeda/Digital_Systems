-------------------------------------------------------
--! @file multiplicador.vhd
--! @brief synchronous multiplier
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-15
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity multiplicador_fd is
  port (
	  sig_mult_fd:  in  bit; --indicador modo complemento de 2
    clock:        in  bit;
    Va,Vb:        in  bit_vector(3 downto 0);
    RSTa,CEa:     in  bit;
    RSTb,CEb:     in  bit;
    RSTr,CEr:     in  bit;
    DCb:          in  bit;
    Zrb:          out bit;
    Vresult:      out bit_vector(7 downto 0)
  );
end entity;

architecture structural of multiplicador_fd is

  component reg4
    port (
      clock, reset, enable: in bit;
      D: in  bit_vector(3 downto 0);
      Q: out bit_vector(3 downto 0)
    );
  end component;

  component reg8
    port (
      clock, reset, enable: in bit;
      D: in  bit_vector(7 downto 0);
      Q: out bit_vector(7 downto 0)
    );
  end component;

  component mux4_2to1
    port (
      SEL : in bit;    
      A :   in bit_vector  (3 downto 0);
      B :   in bit_vector  (3 downto 0);
      Y :   out bit_vector (3 downto 0)
    );
  end component;

  -- component mux8_2to1
  --   port (
  --     SEL : in bit;    
  --     A :   in bit_vector  (7 downto 0);
  --     B :   in bit_vector  (7 downto 0);
  --     Y :   out bit_vector (7 downto 0)
  --   );
  -- end component;

  component fa_4bit
    port (
      A,B  : in  bit_vector(3 downto 0);
      CIN  : in  bit;
      SUM  : out bit_vector(3 downto 0);
      COUT : out bit
    );
  end component;

  component fa_8bit
    port (
      A,B  : in  bit_vector(7 downto 0);
      CIN  : in  bit;
      SUM  : out bit_vector(7 downto 0);
      COUT : out bit
      );
  end component;

  component zero_detector
    port (
      A    : in bit_vector(3 downto 0);
      zero : out bit
    );
  end component;

  signal s_ra, s_rb:         bit_vector(3 downto 0);
  signal s_bmenos1, s_muxb, s_mux_va, s_mux_vb:  bit_vector(3 downto 0);
  signal s_a8, s_soma, s_rr,s_mux_result: bit_vector(7 downto 0);
  signal not_va, not_vb, comp2_va, comp2_vb:  bit_vector(3 downto 0); --complemento de 2 dos operandos
  signal comp2_result, not_result, newresult:       bit_vector(7 downto 0); --complemento de 2 do resultado
  signal va_select:          bit;
  signal vb_select:          bit;
  signal result_select:      bit;
  signal a3_xor_b3:          bit;

begin
   not_va<=not(Va); --complemento de 2 de A
   not_vb<=not(Vb); --complemento de 2 de B

   va_select <= sig_mult_fd and Va(3);--realizam o complemento de dois de A se o numero eh negativo e os operandos estão em complemento de 2 
   vb_select <= sig_mult_fd and Vb(3);--realizam o complemento de dois de B se o numero eh negativo e os operandos estão em complemento de 2 
   
   CP_VA: fa_4bit port map (
      A=> not_va,
      B=> "0001", -- somei com 1
      CIN=> '0',
      SUM=> comp2_va,
      COUT=> open
      );

  CP_VB: fa_4bit port map (
      A=> not_vb,
      B=> "0001", -- somei com 1
      CIN=> '0',
      SUM=> comp2_vb,
      COUT=> open
    );
   
  MUX_VA: mux4_2to1 port map (
      SEL=> va_select,    
      A=>   Va,
      B=>   comp2_va,
      Y=>   s_mux_va
      );
		
	MUX_VB: mux4_2to1 port map (
      SEL=> vb_select,    
      A=>   Vb,
      B=>   comp2_vb,
      Y=>   s_mux_vb
      );
  
  RA: reg4 port map (
      clock=>  clock, 
      reset=>  RSTa, 
      enable=> CEa,
      D=>      s_mux_va,
      Q=>      s_ra
     );
  
  RB: reg4 port map (
      clock=>  clock, 
      reset=>  RSTb, 
      enable=> CEb,
      D=>      s_muxb,
      Q=>      s_rb
     );
  
  RR: reg8 port map (
      clock=>  clock, 
      reset=>  RSTr, 
      enable=> CEr,
      D=>      s_soma,
      Q=>      s_rr
     );  
  
  SOMA: fa_8bit port map (
        A=>   s_a8,
        B=>   s_rr,
        CIN=> '0',
        SUM=> s_soma,
        COUT=> open
        );

  SUB1: fa_4bit port map (
        A=>   s_rb,
        B=>   "1111",  -- (-1)
        CIN=> '0',
        SUM=> s_bmenos1,
        COUT=> open
        );
  
  MUXB: mux4_2to1 port map (
        SEL=> DCb,    
        A=>   s_mux_vb,
        B=>   s_bmenos1,
        Y=>   s_muxb
        );

  ZERO: zero_detector port map (
        A=>    s_rb,
        zero=> Zrb
        );

  s_a8 <= "0000" & s_ra;
  
  not_result<=not(s_rr);


  CP_RESULT: fa_8bit port map (
      A=> not_result,
      B=> "00000001", -- somei com 1
      CIN=> '0',
      SUM=> comp2_result,
      COUT=> open
      );

  result_select <= (sig_mult_fd and Va(3) and not(Vb(3))) or 
                    (sig_mult_fd and Vb(3) and not(Vb(3)));
  
  newresult <= s_mux_result;
  
	-- MUX_RESULT: mux8_2to1 port map (
  --       SEL=> result_select,    
  --       A=>   s_rr,
  --       B=>   comp2_result,
  --       Y=>   s_mux_result
  --       );
  
  --Vresult <= s_mux_result;--COMPLETAR COM O NOVO CALCULO
  
  Vresult <= s_rr when (result_select = '0') else comp2_result;

    
end architecture;