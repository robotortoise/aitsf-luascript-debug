LuaQ          D5-begin80_10_HaiPlant_Iris.lua                 A@  ��  ��@@�$     $@  @ $�  � $�  � $    
�  	�B�	@C�	�C�@  �           module        D5-begin80_10_HaiPlant_Iris        package        seeall        場所説明01        右_強制イベント        Enter 
       FlagCheck        Update        _PAGE_   �.y�A           �m�A      �?  ����A       @                    
(      A@  @ �  E�  �  ��  @ @ @� � A� @ �  E  �@ �  � A� � �A � B� @ @ @� � A� @ �  E�  �  ��  @ @ @� @ A@  @  �           _P_   �.y�A       _F_        InfoOptionButtons        CutOff        _E_        _L_   ���$�A       Right        MCR_LocationDes        bg_2d/bg2d_12_02 
       廃工場 
       火曜日        午後11時27分        右_強制イベント   p)��A       On        _S_     (                                                                                                                                           )   U      	�     A@  @ �  E�  �  ��  
 AA �A �A B "A @�� @� � A  @ �  E�  �  ��  
 AA �A �A B "A @�� @� � A@ @ �  E�  �� ��  � @�� @� � A  @ �  E@ �� �@ � A @ � @� � A@ @ �  E� �� ŀ  AA @ � @� � A� @ �  E� �� ��  A � �� @ � @� � A@ @ �  E� �� �� � A� � �� @ � @� � A  @ �  E@ �� �@ � @�� @� � A  @ �  E@ �@ �@ @ � @� � A� @ �  E�  �� ��  � @�� @� � A 	 @ �  E� �� ŀ A	 A�	 @ � @� � A�	 @ �  C � � 
 �@	 A
 A�
 @ � @� � A�
 @ �  C � � 
 �   AA @ � @� � A� @ �  C � � 
 �@	 � A @ � @� � A@ @ �  C � � 
 �  � A� @ � @� � A  @ �  E@ �� �@ @ � @� � A� @ �  E@ �  �@ � @�� @� � A@ @ �  E�  �  ��  
 AA �A �A B "A @�� @� � A� @ �  E�  �� ��  � @�� @� � A  @ �  E@ �� �@ � AA @ � @� � A� @ �  E@ �� �@ � @�� @� � A� @ �  E� �� ��  A� @ � @� � A@ @ �  C � �� �� @ � @� � A  @ �  E� �� �� A A� @ � @� � A� @ �  C � �� �  @ � @� � A@ @ �  E@ �  �@ � @�� @� � A� @ �  E� �� ��  A @ � @� � A@ @ �  E� �� �� A A @ � @� � A� @ �  E� �� ��  A @ � @� � A� @ �  E� �� �� � A @ � @� � A  @ �  E� �� �� A A @ � @� � A� @ �  C � �� �  @ � @� � A� @ �  C � �  �@ @ � @� � A@  @  � W          _P_    �m�A       _F_        Right        SetRotateRange                _E_        _L_   m�6B  �:�W�A
       SetCamera        RightCamera02   �.���A	       Director        Play        D5-begin80_10_M01       �?  7��A       Face        Set 
       イリス        mo_c05_00_18_shinken   �~�A       SE        SE/ENV_SOUKO   �|��A       SE/ENV_RAIN_INDOOR       �?  pn�+�A       Filter        FadeIn        FADE_TIME_SLOW   �����A       Wait   0'%�A       RightCamera03   Pǐ��A       伊達        mo_c01_00_13_sinken   A�U�A       Talk        ここで間違いないな？        :D5-begin80_10:02_01:   ����A
       はい…        :D5-begin80_10:02_02:   �Q<�A:       沖浦はどこにおまえを連れて行こうと…？        :D5-begin80_10:02_03:    �Z��A       奥にある扉のほうです        :D5-begin80_10:02_04:   P[��A       MES        Hide   `L��A       FadeOut   m�6B  ���A       RightCamera04   @�r��A       @  87�B   ^�A       SE/SE_FOOT_DATE_WALK_HAIPLANT   �Q�r�A       wait �������?  0����A       SE/SE_FOOT_IRIS_WALK_HAIPLANT ffffff�?  �z��A      @  0&�wB  ��܅�A       Stop 333333�?  �#��A  P�e��A  �LtE�A   �U�A       SE/SE_HAIPLANT_HEAVYDOOR   �$'��A  �ü�A       JumpScript        D5-begin85_10_SaitoAgt_Iris        _S_     �  *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   -   -   -   -   -   -   -   -   -   -   -   .   .   .   .   .   .   .   .   .   .   .   .   /   /   /   /   /   /   /   /   /   /   /   /   0   0   0   0   0   0   0   0   0   0   0   0   0   0   1   1   1   1   1   1   1   1   1   1   1   1   1   1   2   2   2   2   2   2   2   2   2   2   2   3   3   3   3   3   3   3   3   3   3   5   5   5   5   5   5   5   5   5   5   5   8   8   8   8   8   8   8   8   8   8   8   8   9   9   9   9   9   9   9   9   9   9   9   9   :   :   :   :   :   :   :   :   :   :   :   :   ;   ;   ;   ;   ;   ;   ;   ;   ;   ;   ;   ;   <   <   <   <   <   <   <   <   <   <   <   <   =   =   =   =   =   =   =   =   =   =   ?   ?   ?   ?   ?   ?   ?   ?   ?   ?   ?   @   @   @   @   @   @   @   @   @   @   @   @   @   @   @   @   A   A   A   A   A   A   A   A   A   A   A   B   B   B   B   B   B   B   B   B   B   B   B   C   C   C   C   C   C   C   C   C   C   C   F   F   F   F   F   F   F   F   F   F   F   F   G   G   G   G   G   G   G   G   G   G   H   H   H   H   H   H   H   H   H   H   H   H   I   I   I   I   I   I   I   I   I   I   K   K   K   K   K   K   K   K   K   K   K   L   L   L   L   L   L   L   L   L   L   L   L   M   M   M   M   M   M   M   M   M   M   M   M   N   N   N   N   N   N   N   N   N   N   N   N   O   O   O   O   O   O   O   O   O   O   O   O   Q   Q   Q   Q   Q   Q   Q   Q   Q   Q   Q   Q   S   S   S   S   S   S   S   S   S   S   T   T   T   T   T   T   T   T   T   T   U   U   U   U                   Z   m      
|      A@  @ �  E�  �  ��  A A� �� �  B� @ @ @� � A� @ �  E  �@ �  � @�@ @� � A� @ �  E  �  �  � @�@ @� � A@ @ �  E� �� ŀ  AA @ @ @� � A� @ �  E� �� ŀ � A @ @ @� � A@ @ �  E� �� ŀ  AA @ @ @� � A� @ �  E� �� ŀ � A @ @ @� � A  @ �  E� �@ ŀ  A� @ @ @� � A� @ �  E� �@ ŀ � A� @ @ @� � A  @ �  C � �@ ŀ @ @ @� � A@  @  � $          _P_   ����A       _F_        Right        MCR_LocationDes        bg_2d/bg2d_12_02 
       廃工場 
       火曜日        午後11時27分        _E_        _L_   0?�q�A       BG        Load        D5-begin80_10_S01   P�h�A	       SetRight    � ��A       Chara        SetDefault        犀人in伊達        mo_c01_00_waitgun2   ��R�A
       イリス        mo_c05_00_wait   �s�<�A       Play    ��p�A  p���A       SetFaceWeight       �?  @i��A   ��C�A
       CallEvent        右_強制イベント        _S_     |   ]   ]   ]   ]   ]   ]   ]   ]   ]   ]   ]   ]   ]   ]   ]   ]   _   _   _   _   _   _   _   _   _   _   _   `   `   `   `   `   `   `   `   `   `   `   e   e   e   e   e   e   e   e   e   e   e   e   f   f   f   f   f   f   f   f   f   f   f   f   g   g   g   g   g   g   g   g   g   g   g   g   h   h   h   h   h   h   h   h   h   h   h   h   i   i   i   i   i   i   i   i   i   i   i   i   j   j   j   j   j   j   j   j   j   j   j   j   l   l   l   l   l   l   l   l   l   l   m   m   m   m                   o   p          �            p                   r   s          �            s                                   U   )   m   Z   p   o   s   r   y   z   {   |   }   }           