library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity eeprom is 
   port(
		sw_in:in std_logic_vector(3 downto 0);
		addr:in std_logic_vector(6 downto 0);
		addr_16:in std_logic_vector(5 downto 0);
		cs:  out std_logic;
		di: out std_logic;
		do: in std_logic;
		send_ok:in std_logic;
		aa,ss:out std_logic;
		org_in:in std_logic;
		org: out std_logic;
		clk_in: in std_logic;
		sk:out std_logic;
		data_out:out std_logic_vector(7 downto 0);
		data_out_16:out std_logic_vector(15 downto 0)
	);
end eeprom;

architecture a of eeprom is
 signal sta : std_logic_vector(3 downto 0):="1000";
 signal hh:std_logic:='0';
 signal aa_sig:std_logic:='0';
 signal ss_sig:std_logic:='0';
 signal clk_sig:std_logic;
 signal st_a:std_logic_vector(8 downto 0):="000000000";
 signal di_tmp: std_logic_vector(21 downto 0);
  signal di_tmp_16: std_logic_vector(26 downto 0);
 signal di_tmp_s: std_logic;
 signal data_in : std_logic_vector(15 downto 0);
  signal data_in_16 : std_logic_vector(18 downto 0);
 signal data_out_tmp:std_logic_vector(7 downto 0);
signal data_out_tmp_16:std_logic_vector(15 downto 0);
 signal chk:std_logic;
 --"000"wait
 --"001"ERASE
 --"010"WRITE
 --"011"EWEN--s
 --"100"EWDS-st
 --"101"ERAL-e-all
 --"110"WRAL-s-all
 --"111"sw-wait
 --"1000"read
	begin
		process(clk_in)
			variable stt:integer:=0;
			begin
				if clk_in'event and clk_in='1' then 
					if stt=2700 then
						clk_sig<=not clk_sig; 
						stt:=0;

					else
						stt:=stt+1;
					end if;
				end if;
		end process;
		process(sta,clk_sig,send_ok,org_in)
		variable st : integer:=21;
		variable do_st:integer:=9;
		variable st_16 : integer:=26;
		variable do_st_16:integer:=17;
			begin
				if clk_sig'event and clk_sig='1' then
					if org_in='0' then 
						case sta is
							when "0000"=>
								if sw_in/="0000" then 
									sta<="0011";
								else
									sta<="0000";
								end if;
							when "0001"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 12)<="111" & addr;
								if st>11 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';
									cs<='0';
									st:=21; 
									sta<="0100";
								end if;
							when "0010"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								data_out_tmp<="10000010";
								di_tmp(21 downto 4)<="101" & addr & data_out_tmp;
								if st>3 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									cs<='0';
									di_tmp_s<='0';
									st:=21;
									sta<="0100";
								end if;
							when "0011"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 12)<="100" & "1100000";
								if st>11 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';
									cs<='0';
									st:=21;
									hh<='0';
									sta<="0111";
								end if;
							when "0100"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 12)<="100" & "0000000";
								if st>11 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';	
									cs<='0';
									st:=21;
									hh<='1';
									sta<="0111";
								end if;
							when "0101"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 12)<="100" & "1000000";
								if st>11 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';	
									cs<='0';
									st:=21;
									sta<="0100";
								end if;
							when "0110"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 4)<="100" & "0100000" & data_out_tmp;
								if st>3 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';			
									cs<='0';			
									st:=21;
									sta<="0100";
								end if;
							when "0111"=>
								cs<='0';
								if st_a="111111111" then
									st_a<="000000000";
									if hh='0' then 
										sta<=sw_in;
										aa_sig<='1';
									else
										aa_sig<='0';
										sta<="0000";
									end if;
								else
									st_a<=st_a+1;
								end if;
							when "1000"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 12)<="110" & addr;
								if st>11 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';
										if do_st<0 then
											data_out<=data_in(7 downto 0);
											cs<='0';
											st:=21;
											do_st:=9;
											ss_sig<='1';
											sta<="0100";
										else
											data_in(do_st)<=do;
											do_st:=do_st-1;
										end if;
								end if;
							when others=>
								null;
						end case;
						org<='0';
					else
						case sta is
							when "0000"=>
								if sw_in/="0000" then 
									sta<="0011";
								else
									sta<="0000";
								end if;
							when "0001"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 13)<="111" & addr_16;
								if st>12 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';
									cs<='0';
									st:=21; 
									sta<="0100";
								end if;
							when "0010"=>
								cs<='1';
								di_tmp_16(26 downto 0)<=(di_tmp_16'range=>'0');
								di_tmp_16(26 downto 2)<="101" & addr_16 & data_out_tmp_16;
								if st>=2 then 
									di_tmp_s<=di_tmp_16(st_16);
									st:=st-1;
								else
									cs<='0';
									di_tmp_s<='0';
									st_16:=26;
									sta<="0100";
								end if;
							when "0011"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 13)<="100" & "110000";
								if st>12 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';
									cs<='0';
									st:=21;
									hh<='0';
									sta<="0111";
								end if;
							when "0100"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 13)<="100" & "000000";
								if st>12 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';	
									cs<='0';
									st:=21;
									hh<='1';
									sta<="0111";
								end if;
							when "0101"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 13)<="100" & "100000";
								if st>12 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';	
									cs<='0';
									st:=21;
									sta<="0100";
								end if;
							when "0110"=>
								cs<='1';
								di_tmp_16(26 downto 0)<=(di_tmp_16'range=>'0');
								di_tmp_16(26 downto 2)<="100" & "010000" & data_out_tmp_16;
								if st_16>=2 then 
									di_tmp_s<=di_tmp_16(st_16);
									st:=st-1;
								else
									di_tmp_s<='0';			
									cs<='0';			
									st_16:=26;
									sta<="0100";
								end if;
							when "0111"=>
								cs<='0';
								if st_a="111111111" then
									st_a<="000000000";
									if hh='0' then 
										sta<=sw_in;
										aa_sig<='1';
									else
										aa_sig<='0';
										sta<="0000";
									end if;
								else
									st_a<=st_a+1;
								end if;
							when "1000"=>
								cs<='1';
								di_tmp(21 downto 0)<=(di_tmp'range=>'0');
								di_tmp(21 downto 13)<="110" & addr_16;
								if st>12 then 
									di_tmp_s<=di_tmp(st);
									st:=st-1;
								else
									di_tmp_s<='0';
										if do_st<0 then
											data_out_16<=data_in_16(15 downto 0);
											cs<='0';
											st:=21;
											do_st_16:=17;
											ss_sig<='1';
											sta<="0100";
										else
											data_in_16(do_st_16)<=do;
											do_st_16:=do_st_16-1;
										end if;
								end if;
							when others=>
								null;
						end case;
						org<='1';
					end if;
				end if;
				if send_ok='1' then
					ss_sig<='0';
				end if;
		end process;
		sk<=clk_sig;
ss<=ss_sig;
aa<=aa_sig;
di<=di_tmp_s;
end a;