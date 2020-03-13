function [alpha, Bn] = alpha_coef(w, v, dt)
% ����alpha�˲���ϵ��
% w:����������׼��
% v:����������׼��
% dt:��ɢʱ����
% alpha:��λ����ϵ��,p(k+1)=p(k)+alpha*dp
% https://en.wikipedia.org/wiki/Alpha_beta_filter

% ����ϵ��
% ���ݲο�����<The tracking index: A generalized parameter for ��-�� and ��-��-�� target trackers>
% ���������wʵ�����ǹ�ʽ�е�w*(dt/2)
% �����轫���������w����(dt/2),��ɹ�ʽ��ʹ�õ�w
w = w/(dt/2);
lamda = w/v*dt^2;
alpha = (-lamda^2 + sqrt(lamda^4+16*lamda^2)) / 8;

% �����ʽ�ǽ��迨�᷽���Ƴ�����,���������������ͬ
% P����̬��:P^2/(P+v^2) = w^2*dt^2 = Q
% P = (w^2*dt^2 + w^2*dt^2*sqrt(1+4*v^2/(w^2*dt^2))) / 2;
% alpha = P/(P+v^2) = Q/P = w^2*dt^2/P
% �μ�<�������˲�����ϵ���ԭ��(��2��)>159ҳ
% alpha = 2 / (1+sqrt(1+4*v^2/(w^2*dt^2)));

% �������
% <PhaseLock Techniques> P130
K = alpha/dt; %����ϵ��
Bn = K/4; %Hz

end