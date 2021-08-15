% ��Ч����������֤

% ϵ��
Bn = 25;
zeta = sqrt(0.5);
Wn = Bn*8*zeta / (4*zeta^2 + 1);
K1 = 2*zeta*Wn;
K2 = Wn^2;

% (K1*s+K2)/(s^2+K1*s+K2)
fun = @(x) (K1^2*x.^2+K2^2)./(x.^4+(K1^2-2*K2)*x.^2+K2^2);
Bn0 = integral(fun,0,Inf)/(2*pi) %���ּ���Ĵ���
Bn %��ʽ����Ĵ���

% K2/(s^2+K1*s+K2)
fun = @(x) K2^2./(x.^4+(K1^2-2*K2)*x.^2+K2^2);
Bn0 = integral(fun,0,Inf)/(2*pi) %���ּ���Ĵ���
Bn = (Wn/2)*(1/4/zeta) %��ʽ����Ĵ���

% (K2/K1*s+K2)/(s^2+K1*s+K2)
fun = @(x) (K2^2/K1^2*x.^2+K2^2)./(x.^4+(K1^2-2*K2)*x.^2+K2^2);
Bn0 = integral(fun,0,Inf)/(2*pi) %���ּ���Ĵ���
Bn = (Wn/2)*(1/16/zeta^3+1/4/zeta) %��ʽ����Ĵ���