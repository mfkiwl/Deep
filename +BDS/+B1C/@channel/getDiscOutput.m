function [codeDisc, carrDisc] = getDiscOutput(obj)
% ��ȡ��λ����ڼ��������(�����)

k0 = obj.ns0+1;
k1 = obj.ns;
codeDisc = double(obj.storage.disc(k0:k1,1))';
carrDisc = double(obj.storage.disc(k0:k1,2))';

end