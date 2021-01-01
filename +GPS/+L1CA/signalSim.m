classdef signalSim < handle
% GPS L1 C/A�źŷ���

% �ź�ǿ��˵��
% ���ջ����������������ܶ�Ϊ-205dBW/Hz(˫�ߴ�),-175dBm/Hz
% �������������ܶȼ��㹫ʽ:N0=kT/2, k=1.38e-23 ������������
% <GPSԭ������ջ����>л��P244
% GPS�ź����Ҫ��֤-160dBW(-130dBm),��Ӧ�����45dB��Hz
% ���ź�Ϊ-145dBm,��Ӧ�����30dB��Hz
% ������������ȷ�Χ40~55dB��Hz,��Ӧ����-135dBm~-120dBm
% ��������ֵ���㹫ʽ: A/sigma = sqrt(2*T*10^(CN0/10))
% sigma=1���������źŷ�ֵ���㹫ʽ: A = sqrt(10^(CN0/10)*(2/fs))
% 55dB��Hz�źŷ�ֵ0.4(fs=4e6)
% 40dB��Hz�źŷ�ֵ0.07(fs=4e6)
% ����ʱ���źŷ�ֵ����������Ϊ�ο�,���ж���ź�ʱ,�����ź�Ҳ�൱������,��ʹʵ�ʵ�����ȵ���Ԥ��ֵ
% ʵ������ʱ,�����ź�Խ��Խ�������������ر�������
% ����ָ������ʱ�����ܸ��ٵ������ź�Ҫ��֤A/sigma=3,��Ӧ�������ΪCN0 = 10*log10(9/(2*T))
% 1ms����ʱ����ٵ���������Ϊ36.5dB��Hz
% 20ms����ʱ����ٵ���������Ϊ23.5dB��Hz

% ����ȱ�:��һ��ʱ��,�ڶ��������,����������ȱ仯��
% �仯����������
% ��һ�е�ʱ�������0,��һ�еı仯��һ����0
% ���һ�еı仯�ʱ�����0

    properties
        PRN             %���Ǳ��
        CAcode          %һ�����ڵ�C/A��
        carrFactor      %�ز�����
        ephe            %����          
        message         %��������
        N0              %�������������ܶ�
        cnrMode         %�����ģʽ
        cnrValue        %�����ֵ
        cnrTable        %����ȱ�
        ele             %�߶Ƚ�
        azi             %��λ��
    end
    
    methods
        function obj = signalSim(PRN, sampleFreq) %���캯��
            obj.PRN = PRN;
            obj.CAcode = GPS.L1CA.codeGene(PRN);
            obj.carrFactor = -2*pi*1575.42e6;
            obj.N0 = 2 / sampleFreq; %sigma=1�ĸ�����������Ϊ2
            obj.cnrMode = 0; %Ĭ�ϸ��ݸ߶ȽǼ��������
        end
        
        function update_message(obj, t) %���µ�������
            obj.message = [-1, -1, GPS.L1CA.messageGene(t,obj.ephe), 1, -1]; %1504������
        end
        
        function update_aziele(obj, t, lla) %���·�λ�Ǹ߶Ƚ�
            % t:ʱ��,GPS������
            % lla:���ջ�λ��,γ����
            if ~isempty(obj.ephe) %������Щ����û����
                rs = LNAV.rs_ephe(obj.ephe(10:25), t); %����ecefλ��
                [obj.azi, obj.ele] = aziele_xyz(rs, lla); %���㷽λ�Ǹ߶Ƚ�
            else %û���������Ǹ߶Ƚ���-100��
                obj.azi = 0;
                obj.ele = -100;
            end
        end
        
        function cnr = get_cnr(obj, t) %��ȡ�����
            if obj.cnrMode==0 %���ݸ߶ȽǼ���
                cnr = 35 + 20*sind(obj.ele); %���35,���55
            elseif obj.cnrMode==1 %��ֵ
                cnr = obj.cnrValue;
            elseif obj.cnrMode==2 %��������ȱ�
                index = find(obj.cnrTable(1,:)<=t, 1, 'last'); %��Ķ�Ӧ��
                cnr = obj.cnrTable(2,index) + obj.cnrTable(3,index)*(t-obj.cnrTable(1,index));
            end
        end
        
        function [sigI, sigQ] = gene_signal(obj, te0, te, tr0, tr, sampleN) %�����ź�
            % te0:�ϴη���ʱ��,te:��ǰ����ʱ��(������,����������λ)
            % tr0:�ϴν���ʱ��,tr:��ǰ����ʱ��(���ջ���,�������ز���λ,�ز���λ��α��ֱ�����)
            % sampleN:��������
            samples = (1:sampleN) / sampleN;
            SMU2S = [1;1e-3;1e-6]; %[s,ms,us]��s
            %----�źŷ�ֵ
            CN0 = obj.get_cnr(tr*SMU2S); %�ź������
            amp = sqrt(10^(CN0/10) * obj.N0); %�źŷ�ֵ
            %----������
            te0_us = te0(3)/1e3; %�ϴη���ʱ���΢�벿��,��λ:ms
            dte_us = (te-te0) * [1e3;1;1e-3]; %����ʱ������,��λ:ms
            te_us_vector = te0_us + dte_us*samples; %����ʱ��΢�벿��ʸ��,��λ:ms
            codePhase = floor(mod(te_us_vector,1)*1023) + 1; %����λ(ÿ1ms��Ӧ1023����Ƭ)
            sigCode = obj.CAcode(codePhase) * amp;
            %----���ɵ�������
            te0_ms = te0(1)*1e3 + te0(2); %�ϴη���ʱ��ĺ��벿��
            te_ms_vector = te0_ms + floor(te_us_vector); %����ʱ����벿��ʸ��
            bitIndex = floor(te_ms_vector/20); %��������
            bitIndex = bitIndex - (floor(bitIndex(1)/1500)*1500 - 3); %��1500���������޳�,��3Ϊ��ʵ��message����
            sigNav = obj.message(bitIndex);
            sigCode = sigCode .* sigNav;
            if bitIndex(end)>=1503 %���µ�������
                obj.update_message(te(1));
            end
            %----�����ز�
            tt0 = (tr0 - te0) * SMU2S; %�ϴδ���ʱ��
            tt = (tr - te) * SMU2S; %��ǰ����ʱ��
            tt_vec = tt0 + (tt-tt0)*samples; %����ʱ��ʸ��
            carrPhase = tt_vec * obj.carrFactor; %�ز���λ
            carrPhase = carrPhase - floor(carrPhase(1)/2/pi)*2*pi; %��2pi���������޳�,�������Ǻ�������
            carrCos = cos(carrPhase);
            carrSin = sin(carrPhase);
            %----�ϳ��ź�
            sigI = sigCode .* carrCos;
            sigQ = sigCode .* carrSin;
        end
        
    end %end methods
    
end %end classdef