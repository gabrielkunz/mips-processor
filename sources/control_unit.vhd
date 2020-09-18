--------------------------------------------------------------------------------
--MIPS Based Processor
--Nomes:Amanda Wagner e Gabriel Kunz
--Disciplina: Organização de Computadores
--Professora: Débora Matos
--Control Unit
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity control_unit is
port(
		rst					: in 	std_logic; --Sistema->Data_Path
		clk 				: in 	std_logic; --Sistema->Data_Path
		write_reg_enable 	: out 	std_logic; --Unidade de Controle->Register Bank
		write_pc_enable		: out 	std_logic; --Unidade de Controle->PC
		write_ir_enable		: out 	std_logic; --Unidade de Controle->IR
        write_ram_enable    : out   std_logic; --Unidade de controle -> ram
		mux1_sel 			: out 	std_logic; --Unidade de Controle->MUX1
		mux2_sel 			: out 	std_logic; --Unidade de Controle->MUX2
		mux3_sel 			: out 	std_logic; --Unidade de Controle->MUX3
		operation			: out 	std_logic_vector (2 downto 0); --Unidade de Controle->ULA
		op_code 			: in 	std_logic_vector (3 downto 0); --IR->Undiade de Controle
		halt				: out	std_logic;
        neg_flag            : in    std_logic;
        zero_flag           : in    std_logic;
        write_flag_enable   : out   std_logic
		);
end control_unit;

architecture arch of control_unit is
type estado is (GET_INSTRUCTION, --Autoriza o ir a pegar a instrucao
                DECODE, --Recebe a instrucao do ir decodificada e iterpreta ela
                ULA, --Realiza os calculos da ULA
                WRITE_REG, --Autoriza a escrita nos registradores
                SAVE_PC, --Atualiza o PC em caso de branch
                LOAD, --Prepara o load
                WRITE_MEM, --Autoriza a escrita na memoria para o store
                EHALT, --Loop de halt
                START); --Estado inicial
signal estado_atual : estado;

begin
process (clk)
begin
    if (clk'event and clk='1') then
	 if (rst = '0') then
		estado_atual <= START;
	else
        case estado_atual is
            when START =>
                estado_atual <= GET_INSTRUCTION;
            when GET_INSTRUCTION =>
                estado_atual <= DECODE;
            when DECODE =>
                case op_code is
                    when "0010" => --ADD
                        estado_atual <= ULA;
                    when "0011" => --SUB
                        estado_atual <= ULA;
                    when "0101" => --AND
                        estado_atual <= ULA;
                    when  "0100"=> --OR
                        estado_atual <= ULA;
                    when "0110" => --NOT
                        estado_atual <= ULA;
                    when "0000" => --LOAD
                        estado_atual <= LOAD;
                    when "0001" => --STORE
                        estado_atual <= WRITE_MEM;
                    when "0111" => --JMP
                        estado_atual <= SAVE_PC;
                    when "1001" => --JN
                        if (neg_flag = '1') then
                            estado_atual <= SAVE_PC;
                        else
                            estado_atual <= GET_INSTRUCTION;
                        end if ;
                    when "1000" => --JZ
                        if (zero_flag = '1') then
                            estado_atual <= SAVE_PC;
                        else
                            estado_atual <= GET_INSTRUCTION;
                        end if ;
                    when "1010" => --NOP
                        estado_atual <= GET_INSTRUCTION;
                    when "1111" => --HALT
                        estado_atual <= EHALT;
                            when others => null;
                end case;
            when ULA =>
                estado_atual <= WRITE_REG;
            when WRITE_REG =>
                estado_atual <= GET_INSTRUCTION;
            when SAVE_PC =>
                estado_atual <= GET_INSTRUCTION;
            when LOAD =>
                estado_atual <= WRITE_REG;
                when WRITE_MEM =>
                    estado_atual <= GET_INSTRUCTION;     
            when EHALT =>
                estado_atual <= EHALT; 
                when others => estado_atual <= EHALT;
        end case;
        end if;
    end if;
end process;

mux2_sel <= '0' when estado_atual = SAVE_PC else '1';
write_pc_enable <='1' when estado_atual = GET_INSTRUCTION or estado_atual = SAVE_PC else '0';
write_ir_enable <= '1' when estado_atual = GET_INSTRUCTION else '0';
mux3_sel <= '1' when (estado_atual = DECODE and op_code = "0001") OR (estado_atual = DECODE and op_code = "0000") or estado_atual = SAVE_PC else '0';
mux1_sel <= '1' when (estado_atual = ULA or estado_atual = WRITE_REG) else '0';
write_reg_enable <= '1' when (estado_atual = ULA or estado_atual = LOAD) else '0';
write_flag_enable <= '1' when (estado_atual = WRITE_REG) and (op_code = "0010" or op_code = "0011") else '0';
write_ram_enable <= '1' when estado_atual = DECODE and op_code = "0001" else '0';
operation   <= "000" when estado_atual = ULA and op_code = "0010" else
                    "100" when estado_atual = ULA and op_code = "0011" else
                    "010" when estado_atual = ULA and op_code = "0101" else
                    "001" when estado_atual = ULA and op_code = "0100" else 
                    "011" when estado_atual = ULA and op_code = "0110" else "001";
halt <= '1' when estado_atual = EHALT else '0';

end architecture;














