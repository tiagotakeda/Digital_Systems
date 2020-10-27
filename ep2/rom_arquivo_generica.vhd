library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom_arquivo_generica is

    generic(
        addressSize : natural := 4;
        wordSize    : natural := 8;
        datFileName : string  := "rom.dat"
    );

    port(
        addr : in  bit_vector(addressSize-1 downto 0);
        data : out bit_vector(wordSize-1 downto 0)
    );

end rom_arquivo_generica;

architecture rom_arch of rom_arquivo_generica is

    constant MEM_DEPTH : integer := 2**addressSize;
    type mem_tipo is array (0 to MEM_DEPTH-1) of bit_vector(wordSize-1 downto 0);
    
    impure function init_mem(file_name : in string) return mem_tipo is

        file arquivo      : text open read_mode is file_name;
        variable linha  : line;
        variable temp_bv    : bit_vector(wordSize-1 downto 0);
        variable temp_mem   : mem_tipo;

    begin
        
        for i in mem_tipo'range loop
            readline(arquivo, linha);
            read(linha, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        
        return temp_mem;
    
    end function;

    constant mem : mem_tipo := init_mem(datFileName);

begin
    data <= mem(to_integer(unsigned(addr)));
end rom_arch;