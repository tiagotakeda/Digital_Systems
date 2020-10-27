library ieee;
use ieee.numeric_bit.all;

entity ram is

    generic(
        addressSize : natural := 4;
        wordSize    : natural := 8
    );
    port(
        ck, wr   : in bit;
        addr     : in bit_vector(addressSize-1 downto 0);
        data_i   : in bit_vector(wordSize-1 downto 0);
        data_o   : out bit_vector(wordSize-1 downto 0)
    );

end ram;

architecture ram_arch of ram is

    constant MEM_DEPTH : integer := 2**addressSize;
    type mem_type is array (0 to MEM_DEPTH-1) of bit_vector(wordSize-1 downto 0);

    signal mem: mem_type;

begin

    process(ck, wr, addr, data_i)
    begin

        data_o <= (others => '0');

        if rising_edge(ck) and wr = '1' then
            mem(to_integer(unsigned(addr))) <= data_i;
        end if;
        if wr = '0' then
            data_o <= mem(to_integer(unsigned(addr)));
        else
            data_o <= (others => '0');
        end if;

    end process;

end ram_arch;