function day = date2day(date)
% ��������������һ��ĵڼ���
% ���ڸ�ʽ:'yyyy-mm-dd',�ַ���

date0 = [date(1:4),'-01-01']; %�������
day = datenum(date,'yyyy-mm-dd') - datenum(date0,'yyyy-mm-dd') + 1;

end