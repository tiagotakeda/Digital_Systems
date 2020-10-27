library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom_arquivo is
    port (
        addr    :   in  bit_vector(3 downto 0);
        data    :   out bit_vector(7 downto 0)
    );
end rom_arquivo;

architecture rom_arch of rom_arquivo is
    type mem_tipo is array (0 to 15) of bit_vector(7 downto 0);

    impure function init_mem(conteudo_rom_ativ_02_carga : 
        in string) return mem_tipo is

            file arquivo : text open
                read_mode is conteudo_rom_ativ_02_carga;

            variable linha : line;
            variable temp_bv : bit_vector(7 downto 0);
            variable temp_mem : mem_tipo;

    begin
        for i in mem_tipo'range loop
            readLine(arquivo, linha);
            read(linha, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        return temp_mem;
    end;

    constant mem : mem_tipo := init_mem("mem_init_vhd.mif");

begin
    data <= mem(to_integer(unsigned(addr))); 
end rom_arch;