function x1 = RK2(fun, x0, dt, u0, u1)
% �������������΢�ַ���
% fun:΢�ַ��̺������

K1 = fun(x0, u0);
K2 = fun(x0+K1*dt, u1);
x1 = x0 + (K1+K2)*dt/2;

end