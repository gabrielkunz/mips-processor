--------------------------------------------------------------------------------
--MIPS Based Processor
--Nomes:Amanda Wagner e Gabriel Kunz
--Disciplina: Organização de Computadores
--Professora: Débora Matos
--Data Path
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--Sinais externos
entity data_path is
	port(
		rst					: in 	std_logic; --Sistema->Data_Path
		clk 				: in 	std_logic; --Sistema->Data_Path
		write_reg_enable 	: in 	std_logic; --Unidade de Controle->Register Bank
		write_pc_enable		: in 	std_logic; --Unidade de Controle->PC
		write_ir_enable		: in 	std_logic; --Unidade de Controle->IR
		mux1_sel 			: in 	std_logic; --Unidade de Controle->MUX1
		mux2_sel 			: in 	std_logic; --Unidade de Controle->MUX2
		mux3_sel 			: in 	std_logic; --Unidade de Controle->MUX3
		operation			: in 	std_logic_vector (2 downto 0); --Unidade de Controle->ULA
		data_in				: in 	std_logic_vector (15 downto 0); --RAM->MUX1
		data_out			: out 	std_logic_vector (15 downto 0); --Register Bank->RAM
		op_code 			: out 	std_logic_vector (3 downto 0); --IR->Undiade de Controle
		ram_addr			: out 	std_logic_vector (7 downto 0); --MUX3->RAM
		neg_flag 			: out 	std_logic;
		zero_flag 			: out 	std_logic;
		write_flag_enable 	: in 	std_logic
		);
end data_path;

--Arquitetura
architecture arch of data_path is

--Sinais internos
signal pc_out 		:	std_logic_vector (7 downto 0); --PC->MUX3; PC->+2->MUX2
signal instruction 	: 	std_logic_vector (15 downto 0); --IR->Decoder
signal mux1_out 	: 	std_logic_vector (15 downto 0); --MUX1->Register Bank
signal mux2_out 	: 	std_logic_vector (7 downto 0); --MUX2->PC
signal ula_out 		: 	std_logic_vector (15 downto 0); --ULA->MUX1
signal mem_addr 	:	std_logic_vector (7 downto 0); --IR->MUX2; IR->MUX3
signal reg_target 	: 	std_logic_vector (1 downto 0); --IR->Register Bank
signal reg_a 		: 	std_logic_vector (1 downto 0); --IR->Register Bank
signal reg_b 		: 	std_logic_vector (1 downto 0); --IR->Register Bank
signal reg_out_a	: 	std_logic_vector (15 downto 0); --Register Bank->ULA
signal reg_out_b	: 	std_logic_vector (15 downto 0); --Register Bank->ULA
signal r0 : std_logic_vector (15 downto 0);
signal r1 : std_logic_vector (15 downto 0);
signal r2 : std_logic_vector (15 downto 0);
signal r3 : std_logic_vector (15 downto 0);
signal zero : std_logic;
signal neg : std_logic;

--Componentes
begin

--PC:
pc: process (clk)
begin
	if(clk'event and clk='1') then
		if(rst='0') then
			pc_out <= (others=>'0'); --Zera PC
		elsif (write_pc_enable='1') then
			pc_out <= mux2_out; --PC recebe ou PC+2 ou ram_addr vindo de instrucoes de salto
		end if;
	end if;
end process;

--Instruction Reader (IR):
ir : process (clk)
begin
    if (clk'event and clk = '1') then
        if (write_ir_enable = '1') then
            instruction <= data_in;
        end if ;
    end if;
end process;

--Decoder:
decoder: process (instruction)
begin
	reg_a <= "00";
	reg_b <= "00";
	reg_target <= "00";
	mem_addr <= "00000000";
	case(instruction (15 downto 12)) is --Separacao dos bits de acordo com a instrucao lida			
			when "0000" => --LOAD
				op_code <= "0000";
				mem_addr <= instruction(7 downto 0);
				reg_target <= instruction (11 downto 10);
			when "0001" => --STORE
				op_code <= "0001";
				mem_addr <= instruction(7 downto 0);
				reg_target <= instruction (11 downto 10);
			when "0010" => --ADD
				op_code <= "0010";
				reg_target <= instruction (11 downto 10); --bits logo apos o op code
				reg_a <= instruction (3 downto 2); -- 2 bits antes dos 2 ultimos bits
				reg_b <= instruction (1 downto 0); --2 ultimos bits
			when "0011" => --SUB
				op_code <= "0011";
				reg_target <= instruction (11 downto 10); --bits logo apos o op code
				reg_a <= instruction (3 downto 2); -- 2 bits antes dos 2 ultimos bits
				reg_b <= instruction (1 downto 0); --2 ultimos bits
			when "0100" => --OR
				op_code <= "0100";
				reg_target <= instruction (11 downto 10); --bits logo apos o op code
				reg_a <= instruction (3 downto 2); -- 2 bits antes dos 2 ultimos bits
				reg_b <= instruction (1 downto 0); --2 ultimos bits
			when "0101" => --AND
				op_code <= "0101";
				reg_target <= instruction (11 downto 10); --bits logo apos o op code
				reg_a <= instruction (3 downto 2); -- 2 bits antes dos 2 ultimos bits
				reg_b <= instruction (1 downto 0); --2 ultimos bits
			when "0110" => --NOT
				op_code <= "0110";
				reg_target <= instruction (11 downto 10); --bits logo apos o op code
				reg_a <= instruction (3 downto 2); -- 2 bits antes dos 2 ultimos bits
				reg_b <= instruction (1 downto 0); --2 ultimos bits
			when "0111" => --JUMP
				op_code <= "0111";
				mem_addr <= instruction (7 downto 0); --8 ultimos bits
			when "1000" => --JZ
				op_code <= "1000";
				mem_addr <= instruction(7 downto 0);
				reg_target <= instruction (11 downto 10);
			when "1001" => --JN
				op_code <= "1001";
				mem_addr <= instruction(7 downto 0);
				reg_target <= instruction (11 downto 10);
			when "1010" => --NOP
				op_code <= "1010";
			when "1111" => --HALT
				op_code <= "1111";
			when others =>
				
		end case ;	
end process;

--ULA:
ula: process (clk)
begin
	if (rst = '0') then
		ula_out <= (others=>'0'); --Zera a saida da ula em caso de reset
	else
		case( operation ) is
			when "000" => ula_out <= (reg_out_a + reg_out_b); --ADD
			when "001" => ula_out <= (reg_out_a or reg_out_b); --OR
			when "010" => ula_out <= (reg_out_a and reg_out_b); --AND
			when "011" => ula_out <= (not reg_out_a + '1'); --NOT
			when "100" => ula_out <= (reg_out_a - reg_out_b); --SUB
			when others => ula_out <= (reg_out_a or reg_out_b); --OR
		end case ;	
	end if ;
end process;

--Flags
flags : process (clk)
begin
	if (ula_out = "00000000") then
		zero <= '1';
	else
 		zero <= '0';
	end if ;
	if (ula_out(15) = '1') then
		neg <= '1';
	else
		neg <= '0';
	end if ;
end process;

write_flag_reg : process (clk)
begin
    if (clk'event and clk = '1') then
        if (write_flag_enable = '1') then
            zero_flag <= zero;
            neg_flag <= neg;
        end if ;
    end if;
end process;

----Register Bank:
--Escrever nos registradores:
write_reg : process (clk)
begin
    if (clk'event and clk = '1') then
        if (write_reg_enable = '1') then
            case (reg_target) is
                when "00" => r0 <= mux1_out;
                when "01" => r1 <= mux1_out;
                when "10" => r2 <= mux1_out;
                when others => r3 <= mux1_out;
            end case;
        end if ;
    end if;
end process;

--Ler Registradores:
reg_out_a <= r3 when reg_a = "11" else r2 when reg_a = "10" else r1 when reg_a = "01" else r0;
reg_out_b <= r3 when reg_b = "11" else r2 when reg_b = "10" else r1 when reg_b = "01" else r0;

--Mux1:
mux1_out <= ula_out when mux1_sel='1' else data_in; --Manda para o registrador target ou saida da ula ou dado da memoria

--Mux2:
mux2_out <= pc_out+2 when mux2_sel='1' else mem_addr; --Manda para o PC ou PC+2 ou endereco dado por instrucao de salto

--Mux3:
ram_addr <= pc_out when	mux3_sel='0' else mem_addr; --Memoria recebe ou endereco no PC ou endereco dado por instrucao de acesso a memoria
--
data_out <= reg_out_a;
end architecture ; -- arch
