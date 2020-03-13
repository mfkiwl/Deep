function [alpha, beta, Bn, zeta] = alpha_beta_coef(w, v, dt)
% ����alpha-beta�˲���ϵ��
% alpha:��λ����ϵ��,p(k+1)=p(k)+alpha*dp
% beta:Ƶ������ϵ��,v(k+1)=v(k)+beta*dp
% https://en.wikipedia.org/wiki/Alpha_beta_filter

% ����ϵ��
lamda = w/v*dt^2;
r = (4 + lamda - sqrt(8*lamda+lamda^2)) / 4;
alpha = 1-r^2;
beta = (2*(2-alpha) - 4*sqrt(1-alpha)) / dt;

% �������
K1 = alpha/dt; %����ϵ��
K2 = beta/dt; %����ϵ��
Wn = sqrt(K2);
zeta = K1/2/Wn;
Bn = Wn*(4*zeta^2+1) / (8*zeta); %Hz

end