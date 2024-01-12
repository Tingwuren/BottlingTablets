library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--单瓶药片计数模块
entity Single_vial_tablet_counter is
    port(
        start, lowfre, clr: in std_logic;
        --启动计数，0.5赫兹，清零
        warn: in std_logic;
        tabper: in std_logic_vector(7 downto 0);
        --Tablets per bottle（每瓶药片的BCD码输入），对应K7-K0
        co: out std_logic;
        --carry-over，当前瓶满后的进位
        persum1, persum0: buffer std_logic_vector(3 downto 0)
        --2个数码管（每瓶药片数），分别对应LG3，LG2，分别表示十位和个位
    );
end;

--用时钟脉冲来对药片数进行计数
architecture behavioral of Single_vial_tablet_counter is
begin
    process(lowfre, start, clr, warn)--当有时钟脉冲时开始计数
    begin
        if clr = '1' then
            --清零
            persum1 <= "0000";
            persum0 <= "0000";
        elsif warn = '1' then
			persum1 <= persum1;
			persum0 <= persum0;
        elsif lowfre'event and lowfre = '1' and start = '1' then
            --计数
            if persum1 & persum0 = (tabper) then
                --药片进位后，下一药瓶的药片数变为1
                co <= '1';
                persum1 <= "0000";
                persum0 <= "0001";
            elsif persum1 & persum0 < (tabper) then
                if persum0 = "1001" then
                    --(X)9下一个计数为(X+1)0，括号中代表一位，即进十位
                    persum1 <= persum1 + 1;
                    persum0 <= "0000";
                    co <= '0';
                else
                    --(X)(Y)下一个计数为(X)(Y+1)，括号中代表一位，即个位加
                    persum0 <= persum0 + 1;
                    co <= '0';
                end if;
            end if;
        end if;
    end process;
end behavioral;