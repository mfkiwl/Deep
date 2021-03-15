%% �۲쵱ʱ�䰴��������ȡģʱ���������λ���Ƿ�����
% ����ǲ�����,���н������в鿴zai��ele����.
% ����ο�GPS.visibility.
% ����ʹ�������������������λ��ʱ,ʱ�����ο�ʱ�̵������Ӧ����3.5��.
% ���Ҫ���㳤ʱ���,�轫�������ǽ�ȥ.

% ��ȡ����
t = UTC2GPS([2020,2,23,15,0,0], 8);
filename = GPS.almanac.download('~temp\almanac', t);
almanac = GPS.almanac.read(filename); %������Ĳο�ʱ��Ϊ61440
ts = 61440 + 302400 - 1800; %ʵ��ts-toe����302400
p = [42.27452, 123.85232, 105]; %���ջ�λ��
h = 1; %����ʱ��1h

% ʹ����������������Ƿ�λ�Ǹ߶Ƚ�
svN = size(almanac,1); %������
n = h*30; %����
azi = zeros(svN,n); %ÿһ��Ϊһ��ʱ���
ele = zeros(svN,n);
for k=1:n
    rs = rs_almanac(almanac(:,5:end), t);
    [azi(:,k), ele(:,k)] = aziele_xyz(rs, p);
    ts = ts+120; %����ʱ��
end