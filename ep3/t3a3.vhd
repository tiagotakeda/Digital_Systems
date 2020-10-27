library IEEE;
use IEEE.math_real.all;
use IEEE.numeric_bit.all;

entity calc is
  port(
    clock : in bit;
    reset : in bit;
    instruction : in bit_vector(15 downto 0);
    overflow : out bit;
    q1 : out bit_vector(15 downto 0)
  );
end entity;

architecture calc_arch  of calc is

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


  component regfile is
    generic(
      regn : natural := 32; 
      wordSize : natural := 64
    );
    port(
      clock : in bit;
      reset : in bit;
      regWrite : in bit;

      rr1, rr2, wr : in bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
      d : in bit_vector(wordSize - 1 downto 0);
      q1, q2 : out bit_vector(wordSize - 1 downto 0)
    );
  end component;

signal opera : bit;
signal opera2, opera1, dest : bit_vector(4 downto 0);
signal parc1, parc2, q2_out : bit_vector(15 downto 0);
signal sum_result : bit_vector(15 downto 0);
signal sum_cout, comp2_cout : bit;
constant num_regs : natural := 32;
constant tam_palavra : natural := 16;
constant num_bits_regs : natural := 5;

begin

  opera <= instruction(15);
  opera1 <= instruction(9 downto 5);
  opera2 <= instruction(14 downto 10);
  q1 <= parc1;
  dest <= instruction(4 downto 0);

  with opera select
    parc2 <=
      q2_out when '1',
      (3 => instruction(13), 2 => instruction(12),
       1 => instruction(11), 0 => instruction(10), others => instruction(14))  when '0',
      q2_out when others;

  somador: fa_nbits generic map(tam_palavra)
  port map(parc1, parc2, '0', sum_result, sum_cout);

  bloco_regs : regfile generic map(num_regs, tam_palavra)
  port map (clock, reset, '1', opera1, opera2, dest, sum_result, parc1, q2_out);

  overflow <= ((parc1(15) and parc2(15)) and not sum_result(15)) or 
      ((not parc1(15) and not parc2(15)) and sum_result(15));
end architecture;

--------------------------------------------------------------------------------------------

library IEEE;
use IEEE.math_real.all;
use IEEE.numeric_bit.all;

entity flipflop is
  port(
    clk : in bit; 
    rst : in bit; 
    en : in bit;

    d : in bit;
    q : out bit;
    q_n : out bit
  );
end entity;

architecture flipflop_arch of flipflop is
begin

  ffdr : process(clk, rst)
  begin
    if(rst = '1') then
      q <= '0';
      q_n <= '1';
    elsif(clk = '1' and clk'event) then
      if(en = '1') then
        q <= d;
        q_n <= not d;
      end if;
    end if;
  end process;

end architecture;
--------------------------------------------------------------------------------------------

library IEEE;
use IEEE.math_real.all;
use IEEE.numeric_bit.all;

entity reg is
  generic (
    wordSize : natural := 4
  );
  port(
    clock : in bit;
    reset : in bit;
    load : in bit;

    d : in bit_vector(wordSize - 1 downto 0);
    q : out bit_vector(wordSize -1 downto 0)
  );
end reg;

architecture reg_arch of reg is

component flipflop is
  port(
    clk : in bit;
    rst : in bit;
    en : in bit;

    d : in bit;
    q : out bit;
    q_n : out bit
  );
end component;

signal notq : bit_vector(wordSize - 1 downto 0);
begin

  gen_flipflops : for i in 0 to wordSize - 1 generate
    ffd: flipflop port map(
      clk => clock,
      rst => reset,
      en => load,
      d => d(i),
      q => q(i),
      q_n => notq(i)
    );
  end generate;

end architecture;

--------------------------------------------------------------------------------------------

library IEEE;
use IEEE.math_real.all;
use IEEE.numeric_bit.all;

entity regfile is
  generic(
    regn : natural := 32;
    wordSize : natural := 64
  );
  port(
    clock : in bit;
    reset : in bit;
    regWrite : in bit;

    rr1, rr2, wr : in bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
    d : in bit_vector(wordSize - 1 downto 0);
    q1, q2 : out bit_vector(wordSize - 1 downto 0)
  );
end regfile;

architecture regfile_arch of regfile is

component reg is
  generic (
    wordSize : natural := 4
  );
  port(
    clock : in bit;
    reset : in bit;
    load : in bit;

    d : in bit_vector(wordSize - 1 downto 0);
    q : out bit_vector(wordSize -1 downto 0)
  );
end component;

type saidas_reg is array(0 to regn - 1) of bit_vector(wordSize -1 downto 0);

signal en_registradores : bit_vector(regn - 1 downto 0);
signal saidas_regs : saidas_reg;

begin

  gen_reg: for i in 0 to regn - 2 generate
    registrador: reg generic map(
      wordSize => wordSize
    )
    port map(
      clock => clock,
      reset => reset,
      load => en_registradores(i),
      d => d,
      q => saidas_regs(i)
    );
  end generate;

  saidas_regs(regn - 1) <= (others => '0');

  enable: process(wr, regWrite)
  begin
    for j in 0 to regn -2 loop
      if (j = to_integer(unsigned(wr)) and regWrite = '1') then
        en_registradores(j) <= '1';
      else
        en_registradores(j) <= '0';
      end if;
    end loop;
  end process;

  q1 <= saidas_regs(to_integer(unsigned(rr1)));
  q2 <= saidas_regs(to_integer(unsigned(rr2)));
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

--------------------------------------------------------------------------------------------