function cal_iono(obj)
% �����������ǵĵ����У��ֵ(ֻ��ͼ)
% obj:���ջ�����

% ���û�е�����������û������,ֱ�ӷ���
if isnan(obj.iono(1)) || isempty(obj.result.satmeasIndex)
    return
end

% ���������ǲ��������Ƿ�λ�Ǹ߶Ƚ�
[azi, ele] = cal_aziele(obj); %ÿ��һ������

% ��������У��ֵ
[n, svN] = size(azi); %n:���ݵ���,svN:������
iono = NaN(n,svN);
lla = obj.storage.pos;
ta = obj.storage.ta;
for k=1:n
    for i=1:svN
        if ~isnan(azi(k,i))
            iono(k,i) = Klobuchar1(obj.iono, azi(k,i), ele(k,i), ...
                        lla(k,1), lla(k,2), ta(k));
        end
    end
end
iono = iono * 299792458; %��λ���m

% ��ͼ
labels = obj.result.satmeasPRN; %���Ǳ���ַ���
figure('Name','ionosphere')
plot(iono, 'LineWidth',1.5)
legend(labels)
grid on

end