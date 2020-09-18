--------------------------------------------------------------------------------
--MIPS Based Processor
--Nomes:Amanda Wagner e Gabriel Kunz
--Disciplina: Organização de Computadores
--Professora: Débora Matos
--MIPS Top Module
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;

entity MIPS is
	port(
		rst		: in std_logic;
		clk		: in std_logic;
		halt	: out std_logic
		);
end MIPS;

architecture arch of MIPS is

--Sinais entre Controle e Data Path
signal write_reg_enable_s 	: std_logic;
signal write_pc_enable_s 	: std_logic;
signal write_ir_enable_s 	: std_logic;
signal mux1_sel_s 			: std_logic;
signal mux2_sel_s			: std_logic;
signal mux3_sel_s 			: std_logic;
signal operation_s 			: std_logic_vector (2 downto 0);
signal op_code_s 			: std_logic_vector (3 downto 0);
signal neg_flag_s 			: std_logic;
signal zero_flag_s 			: std_logic;
signal write_flag_enable_s 	: std_logic;

--Sinais entre Memoria e Controle
signal write_ram_enable_s : std_logic;

--Sinais entre Memoria e Data Path
signal data_out_s : std_logic_vector (15 downto 0);
signal data_in_s : std_logic_vector (15 downto 0);
signal ram_addr_s : std_logic_vector (7 downto 0);

--===============================================Controle===============================================
component control_unit
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
end component;
--======================================================================================================

--============================================Caminho de Dados==========================================
component data_path
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
end component;
--======================================================================================================

--================================================Memória===============================================
component ram_model
    Port ( data_out : in STD_LOGIC_VECTOR (15 downto 0); --Data_Path->RAM
           data_in : out STD_LOGIC_VECTOR (15 downto 0); --RAM->Data_Path
           ram_addr :in STD_LOGIC_VECTOR (7 downto 0); --Data_Path->RAM
           write_ram_enable : in STD_LOGIC; --Unidade de Controle->RAM
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end component;
--======================================================================================================

--================================================Port Map==============================================
begin
	control_unit_i: control_unit
		port map(
				rst 				=> rst,
				clk 				=> clk,
				write_reg_enable 	=> write_reg_enable_s,
				write_pc_enable 	=> write_pc_enable_s,
				write_ir_enable 	=> write_ir_enable_s,
				write_ram_enable 	=> write_ram_enable_s,
				mux1_sel 			=> mux1_sel_s,
				mux2_sel 			=> mux2_sel_s,
				mux3_sel 			=> mux3_sel_s,
				operation 			=> operation_s,
				op_code 			=> op_code_s,
				halt 				=> halt,
				neg_flag 		=> neg_flag_s,
				zero_flag 		=> zero_flag_s,
				write_flag_enable 	=> write_flag_enable_s
				);
	data_path_i: data_path
		port map(
				rst 				=> rst,
				clk 				=> clk,
				write_reg_enable 	=> write_reg_enable_s,
				write_pc_enable 	=> write_pc_enable_s,
				write_ir_enable 	=> write_ir_enable_s,
				mux1_sel 			=> mux1_sel_s,
				mux2_sel 			=> mux2_sel_s,
				mux3_sel 			=> mux3_sel_s,
				operation 			=> operation_s,
				data_in 			=> data_in_s,
				data_out 			=> data_out_s,
				op_code 			=> op_code_s,
				ram_addr 			=> ram_addr_s,
				neg_flag 			=> neg_flag_s,
				zero_flag 			=> zero_flag_s,
				write_flag_enable 	=> write_flag_enable_s
				);
	ram_model_i: ram_model
		port map(
				data_out => data_out_s,
				data_in => data_in_s,
				ram_addr => ram_addr_s,
				write_ram_enable => write_ram_enable_s,
				clk => clk,
				rst => rst
				);
end architecture ; -- arch
--======================================================================================================