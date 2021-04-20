% 8���͹켣
% <Global Positioning Systems, Inertial Navigation, and Integration> P399

%% ����
L = 5000; %�켣����
V = 100; %ƽ���ٶ�
S = L/14.94375529901562;
w = 2*pi*V/L;

T = L/V; %��ʱ��
t = (0:0.001:1)*T;

%% λ��
x = 3*S*sin(w*t); %���᷽��
y = 2*S*sin(w*t) .* cos(w*t);

figure
plot(x,y)
axis equal
grid on

%% �ٶ�
vx = 3*S*w*cos(w*t);
vy = 2*S*w*(cos(w*t).^2-sin(w*t).^2);
figure
subplot(3,1,1)
plot(t,vx)
grid on
subplot(3,1,2)
plot(t,vy)
grid on
subplot(3,1,3)
plot(t,sqrt(vx.^2+vy.^2)) %�ٶȾ���ֵ
grid on

%% ���ٶ�
ax = -3*S*w^2*sin(w*t);
ay = -8*S*w^2*sin(w*t) .* cos(w*t);
figure
subplot(3,1,1)
plot(t,ax)
grid on
subplot(3,1,2)
plot(t,ay)
grid on
subplot(3,1,3)
plot(t,sqrt(ax.^2+ay.^2)) %���ٶȾ���ֵ
grid on