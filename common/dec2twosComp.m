function out = dec2twosComp(in, N)
% ʮ������ת��Ϊ����������,-1��ʾ0,1��ʾ1
% in:Ϊ����
% N:���λ��

if in<0
    binStr = dec2bin(2^N+in, N); %01�ַ���
else
    binStr = dec2bin(in, N);
end

out = ones(1,N);
out(binStr=='0') = -1; %��0��λ��д-1

end