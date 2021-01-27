function satmeas = get_satmeas(obj)
% ��ȡ���ǲ���
% satmeas:[x,y,z,vx,vy,vz,rho,rhodot]
% ��Ϊ����ʲôʱ�䷢������֪��,����ͨ����ȷ���㶨λ�������λ��ö�λ�����ӵ���ķ���ʱ��
% --|----------------------|-------|-------------
%   tc(trackDataTail)      tp      ta(buffHead)
%  ���ٵ�                 ��λ��  ��ǰ������
% dtp=ta-tp:��ǰ�����㵽��λ���ʱ���,ͨ��ʱ�����
% dtc=ta-tc:��ǰ�����㵽���ٵ��ʱ���,ͨ�����������
% dt=tp-tc=dtc-dtp=(ta-tc)-(ta-tp),��λ�㵽���ٵ��ʱ���,������Ƶ�ʵõ�����λ
% ����λ0~1023��Ӧ1ms

c = 299792458; %����
fL1 = 1575.42e6; %L1�ز�Ƶ��
lamda = c / fL1; %�ز�����,m

dtp = (obj.ta-obj.tp) * [1;1e-3;1e-6]; %��ǰ�����㵽��λ���ʱ���
fs = obj.sampleFreq * (1+obj.deltaFreq); %������Ĳ���Ƶ��

satmeas = NaN(obj.chN,8);
for k=1:obj.chN
    channel = obj.channels(k);
    if channel.state>=2 %ֻҪ�����ϵ�ͨ�����ܲ�,���ﲻ�ù��ź�����,ѡ�Ƕ�������
        %----���㶨λ�����ӵ���ķ���ʱ��
        dn = mod(obj.buffHead-channel.trackDataTail+1, obj.buffSize) - 1; %ǡ�ó�ǰһ��������ʱdn=-1
        dtc = dn / fs; %��ǰ�����㵽���ٵ��ʱ���
        dt = dtc - dtp; %��λ�㵽���ٵ��ʱ���
        codePhase = channel.remCodePhase + channel.codeNco*dt; %��λ������λ
        te = [floor(channel.tc0/1e3), mod(channel.tc0,1e3), 0] + ...
             [0, floor(codePhase/1023), mod(codePhase/1023,1)*1e3]; %��λ���뷢��ʱ��
        %----�����źŷ���ʱ������λ���ٶ�
        % [satmeas(k,1:6), corr] = LNAV.rsvs_emit(channel.ephe(5:end), te, obj.rp, obj.vp, obj.iono, obj.pos);
        %----�����źŷ���ʱ������λ���ٶȼ��ٶ�
        [rsvsas, corr] = LNAV.rsvsas_emit(channel.ephe(5:end), te, obj.rp, obj.vp, obj.iono, obj.pos);
        satmeas(k,1:6) = rsvsas(1:6);
        %----���������˶�������ز�Ƶ�ʱ仯��(��ʱ����Ʋ���,ʹ����һʱ�̵�λ�ü������,����ʸ����𲻴�)
        rhodotdot = rhodotdot_cal(rsvsas, obj.rp, obj.vp, obj.geogInfo);
        channel.carrAccS = -rhodotdot / lamda; %���ø���ͨ���ز�Ƶ�ʱ仯��,Hz/s
        %----����α��α����
        tt = (obj.tp-te) * [1;1e-3;1e-6]; %�źŴ���ʱ��,s
        carrAcc = channel.carrAccS + channel.carrAccR; %�ز����ٶ�(�ڴ���ٶ�ʱ�迼�Ƕ�λ������ٵ�ʱ�����ڵĶ����ձ仯)
        dCarrFreq = carrAcc * (dt-0.5e-3); %���ٵ����ز�Ƶ��ʵ�������¸�1ms����ʱ���м�ʱ�̵��ز�Ƶ��
        doppler = (channel.carrFreq+dCarrFreq)/fL1 + obj.deltaFreq; %��һ��,���ջ��ӿ�ʹ�����ձ�С(�������±�Ƶ)
        satmeas(k,7:8) = satmeasCorr(tt, doppler, corr);
    end
end

end