% BOC(6,1)����غ���(�����ź����)

code1 = BDS.B1C.codeGene_pilot(1);
code2 = -code1;
code = reshape([code1;code2;code1;code2;code1;code2;code1;code2;code1;code2;code1;code2],1,[]);
c = xcorr(code);