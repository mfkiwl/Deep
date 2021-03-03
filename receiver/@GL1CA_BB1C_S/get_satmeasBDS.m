function satmeas = get_satmeasBDS(obj)
% ��ȡBDS���ǲ���

Fca = 1575.42e6; %�ز�Ƶ��
Lca = 0.190293672798365; %�ز�����,m

SMU2S = [1;1e-3;1e-6]; %[s,ms,us]��s
Cdf = 1 + obj.deltaFreq; %����Ƶ�ʵ���ʵƵ�ʵ�ϵ��
dtp = (obj.ta-obj.tp)*SMU2S * Cdf; %��ǰ�����㵽��λ���ʱ���(���ջ���)

satmeas = NaN(obj.BDS.chN,8);
for k=1:obj.BDS.chN
    channel = obj.BDS.channels(k);
    if channel.state>=2 %ֻҪ�����ϵ�ͨ�����ܲ�,���ﲻ�ù��ź�����,ѡ�Ƕ�������
        %----���㶨λ�����ӵ���ķ���ʱ��
        dn = mod(obj.buffHead-channel.trackDataTail+1, obj.buffSize) - 1; %ǡ�ó�ǰһ��������ʱdn=-1
        dtc = dn / obj.sampleFreq; %��ǰ�����㵽���ٵ��ʱ���(���ջ���)
        dt = dtc - dtp; %��λ�㵽���ٵ��ʱ���(���ջ���)
        codePhase = channel.remCodePhase + channel.codeNco*dt; %��λ������λ
        te = [floor(channel.tc0/1e3), mod(channel.tc0,1e3), 0] + ...
             [0, floor(codePhase/2046), mod(codePhase/2046,1)*1e3]; %��λ���뷢��ʱ��(�������ز�ʱ��Ƶ��2.046e6Hz)
        %----�����źŷ���ʱ������λ���ٶ�
        % [satmeas(k,1:6), corr] = CNAV1.rsvs_emit(channel.ephe(5:end), te, obj.rp, obj.vp, obj.BDS.iono, obj.pos);
        %----�����źŷ���ʱ������λ���ٶȼ��ٶ�
        [rsvsas, corr] = CNAV1.rsvsas_emit(channel.ephe(5:end), te, obj.rp, obj.vp, obj.BDS.iono, obj.pos);
        satmeas(k,1:6) = rsvsas(1:6);
        %----���������˶�������ز�Ƶ�ʱ仯��(��ʱ����Ʋ���,ʹ����һʱ�̵�λ�ü������,����ʸ����𲻴�)
        rhodotdot = rhodotdot_cal(rsvsas, obj.rp, obj.vp, obj.geogInfo);
        channel.carrAccS = -rhodotdot/Lca / Cdf; %���ø���ͨ���ز�Ƶ�ʱ仯��,Hz/s
        %----����α��α����
        tt = (obj.tp-obj.dtBDS-te) * SMU2S; %�źŴ���ʱ��,s,��Ҫ����λʱ��ת��Ϊ����ʱ
        carrAcc = channel.carrAccS + channel.carrAccR;
        dCarrFreq = carrAcc * (dt-0.5e-3);
        doppler = (channel.carrFreq+dCarrFreq)*Cdf/Fca + obj.deltaFreq; %��һ��,���ջ��ӿ�ʹ�����ձ�С(�������±�Ƶ)
        satmeas(k,7:8) = satmeasCorr(tt, doppler, corr);
    end
end

end