% �۲쵱ʱ�䰴��������ȡģʱ���������λ���Ƿ�����
% ����ǲ�����,���н������в鿴zai��ele����
% ����ο�GPS.visibility
% ����ʹ�������������������λ��ʱ,ʱ�����ο�ʱ�̵������Ӧ����3.5��
% ���Ҫ���㳤ʱ���,�轫�������ǽ�ȥ

filename = GPS.almanac.download('~temp\almanac', UTC2GPS([2020,2,23,15,0,0],8));
almanac = GPS.almanac.read(filename); %����ο�ʱ��61440
ts = 61440 + 302400 - 1800; %ʵ��ts-toe����302400
p = [42.27452,123.85232,105]; %���ջ�λ��
h = 1; %����ʱ��1h

% ʹ����������������Ƿ�λ�Ǹ߶Ƚ�
n = size(almanac,1); %������
m = h*30; %����
aziele = zeros(n,2,m); %[azi,ele],����άΪʱ��
for k=1:m
    aziele(:,:,k) = aziele_almanac(almanac(:,6:end), ts, p); %[azi,ele]
    ts = ts+120; %����ʱ��
end

% ��ȡ�߶ȽǴ���0������
index = zeros(1,n, 'logical'); %�ɼ���������
for k=1:n
    if ~isempty(find(aziele(k,2,:)>0,1)) %���ڸ߶ȽǴ���0
        index(k) = 1;
    end
end
PRN = almanac(index,1);
azi = mod(aziele(index,1,:),360)/180*pi; %��λ��ת�ɻ���,0~360��
azi = reshape(azi,length(PRN),m); %��Ϊ����,��Ϊʱ��
ele = aziele(index,2,:);
ele = reshape(ele,length(PRN),m);