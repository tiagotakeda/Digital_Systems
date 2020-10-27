-- at1
library IEEE;
use IEEE.math_real.all;
use IEEE.numeric_bit.all;

entity reg is 
generic(wordSize: natural := 4);
port(
	clock: in bit;
	reset: in bit;
	load: in bit;
	d:		in bit_vector(wordSize -1 downto 0);
	q:		out bit_vector(wordSize -1 downto 0)
);
end reg;

architecture reg1 of reg is

begin
	process(reset, clock)
	begin
		if reset = '1' then 
			q <= (others => '0');
		elsif clock'event and clock = '1' then
			if load = '1' then
				q <= d;
			end if;
		end if;
	end process;

end reg1;

--at2 começo
library IEEE;
use IEEE.math_real.all;
use IEEE.numeric_bit.all;

entity regfile is 
generic(
	wordSize: natural := 64;
	regn: natural := 32
	
);

port(
	clock: in bit;
	reset: in bit;
	regWrite: in bit;
	rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
	d:		in bit_vector(wordSize -1 downto 0);
	q1, q2:		out bit_vector(wordSize -1 downto 0)
);
end regfile;

architecture reg_arquivos of regfile is 
-- instanciando at1
component reg is
generic(wordSize: natural := 4);
	port(
		clock: in bit;
		reset: in bit;
		load: in bit;
		d:		in bit_vector(wordSize -1 downto 0);
		q:		out bit_vector(wordSize -1 downto 0)
	);
end component;

type saidas is array(0 to regn -1) of bit_vector(wordSize -1 downto 0);
signal regs_in: bit_vector(regn -1 downto 0);
signal regs_out: saidas;

begin 
	regs_gera: for j in 0 to regn -2 generate 
		reg_gerados: reg generic map(wordSize => wordSize)
		port map(clock => clock,
			reset => reset,
			load => regs_in(j),
			d => d,
			q => regs_out(j));
	end generate;
	
	regs_out(regn-1) <= (others => '0');
	
	enable: process(wr, regWrite)
	begin
		for i in 0 to regn -2 loop
			if i = to_integer(unsigned(wr)) and regWrite = '1' then
				regs_in(i) <= '1';
			else 
				regs_in(i) <= '0';
			
			end if;
		end loop;
	end process;
	
q1 <= regs_out(to_integer(unsigned(rr1)));
q2 <= regs_out(to_integer(unsigned(rr2)));

end reg_arquivos;