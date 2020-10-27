-------------------------------------------------------
--! @file fa_1bit.vhd
--! @brief 1-bit full adder
--! @author Edson S. Gomi (gomi@usp.br)
--! @date 2020-09-07
-------------------------------------------------------
 
entity fa_1bit is
  port (
    A,B : in bit;       -- adends
    CIN : in bit;       -- carry-in
    SUM : out bit;      -- sum
    COUT : out bit      -- carry-out
    );
end entity fa_1bit;

architecture wakerly of fa_1bit is
-- Solution Wakerly's Book (4th Edition, page 475)
begin
  SUM <= (A xor B) xor CIN;
  COUT <= (A and B) or (CIN and A) or (CIN and B);
end architecture wakerly;
