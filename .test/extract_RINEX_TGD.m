% ��ȡGPS�㲥�����е�Ⱥ�ӳ���
% �ȶ�һ��RINEX�����ļ�,��������ephe

TGD = zeros(32,1);

for k=1:32
    if ~isempty(ephe.sv{k}) %�п���ĳ������û����
        TGD(k) = ephe.sv{k}(1).TGD;
    end
end

TGD = TGD*3e8; %��λ:m
figure
bar(TGD)