function intNumber = twosComp2dec(binaryNumber)
% �����Ʋ����ַ���ת��Ϊʮ��������

% Convert from binary form to a decimal number
intNumber = bin2dec(binaryNumber);

% If the number is negative, then correct the result
if binaryNumber(1)=='1'
    intNumber = intNumber - 2^length(binaryNumber);
end

end