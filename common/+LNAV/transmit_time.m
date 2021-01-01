function [te, tt] = transmit_time(ephe, tr, rp)
% �����źŽ���ʱ��,�����źŷ���ʱ��ʹ���ʱ��
% ����ʱ��Ϊ������ʱ��,���������ЧӦ,�����Ӳ�,Ⱥ�ӳ�
% ����ʱ��Ϊ��ʵ·������ʱ��
% ������,��������ʱ��,��λ��,�����µĴ���ʱ��,ֱ������ʱ������,����3�ξ�������
% ephe:21��������
% te:����ʱ��[s,ms,us], tt:����ʱ��,s
% tr:����ʱ��[s,ms,us], rp:���ջ�ecefλ��

w = 7.292115e-5;
c = 299792458;

% ���㴫��ʱ��
tr_sec = tr(1) + tr(2)/1e3 + tr(3)/1e6; %��sΪ��λ�Ľ���ʱ��
tt = 0.07; %����ʱ���ֵ,70ms
while 1
    te_sec = tr_sec - tt; %���㷢��ʱ��
    [rs, dtrel] = LNAV.rs_ephe(ephe(6:21), te_sec); %�����ڷ���ʱ��λ��
    theta = w*tt;
    C = [cos(theta), -sin(theta), 0;
         sin(theta),  cos(theta), 0;
                  0,           0, 1]; %������ת(ת�ù���)
    rsp = rp - rs*C; %����ָ�����ߵ�λ��ʸ��
    tt0 = tt; %�ϴδ���ʱ��
    tt = norm(rsp) / c; %�µĴ���ʱ��
    
    if abs(tt-tt0)<1e-12
        break
    end
end

% ���������Ӳ�
toc = ephe(1);
af0 = ephe(2);
af1 = ephe(3);
af2 = ephe(4);
TGD = ephe(5);
te_sec = tr_sec - tt;
dt = te_sec - toc;
dt = mod(dt+302400,604800)-302400; %�����ڡ�302400
dtsv = af0 + af1*dt + af2*dt^2; %�����Ӳ�

% ���㷢��ʱ��
te = timeCarry(tr - sec2smu(tt-dtsv-dtrel+TGD));

end