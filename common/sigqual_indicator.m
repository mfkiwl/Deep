classdef sigqual_indicator < handle
% �ź�����ָʾ��
% ����һ�����ص�ȫ������,�������ݷ��Ž���������ȫ�۵�����ƽ��
% ����I·���ݵľ�ֵ��Q·���ݵı�׼��
% ����ź�����,�źŵ�ƽ��ģ��Ӧ�ô��������İ뾶

    properties
        quality    %�ź�����
        buffI      %һ�����ص�I·���ݻ���
        buffQ      %һ�����ص�Q·���ݻ���
        index      %��������,��0��ʼ
        N          %һ�����ص����ݵ���
        Im         %I·���ݵľ�ֵ
        Q2m        %Q·����ƽ���ľ�ֵ,Ҳ�����䷽��
    end
    
    methods
        % ���캯��
        function obj = sigqual_indicator(buffSize, N, m)
            % buffSize:���ݻ��泤��
            % N:һ�����ص����ݵ���
            % m:�����ֵ���ڳ���
            obj.quality = 0;
            obj.buffI = zeros(1,buffSize);
            obj.buffQ = zeros(1,buffSize);
            obj.index = 0;
            obj.N = N;
            obj.Im = mean_rec(m);
            obj.Q2m = mean_rec(m);
        end
        
        % ���к���
        function run(obj, I, Q)
            obj.index = obj.index + 1;
            ki = obj.index;
            n = obj.N; %һ�����ص����ݵ���
            obj.buffI(ki) = I;
            obj.buffQ(ki) = Q;
            if ki==n %�湻һ�����ص���
                obj.index = 0;
                bit = sign(sum(obj.buffI(1:n))/n); %���ط���
                for k=1:n
                    obj.Im.update(obj.buffI(k)*bit);
                    obj.Q2m.update(obj.buffQ(k)^2);
                end
                ratio = obj.Im.E / sqrt(obj.Q2m.E);
                if ratio>3
                    obj.quality = 2; %ǿ�ź�
                elseif ratio>2
                    obj.quality = 1; %���ź�
                else
                    obj.quality = 0; %ʧ��
                end
            end
        end
        
        % �ı�һ�����ص����ݵ���
        function changeN(obj, N, m)
            % N:һ�����ص����ݵ���
            % m:�����ֵ���ڳ���
            obj.quality = 0;
            obj.index = 0;
            obj.N = N;
            obj.Im.restart(m);
            obj.Q2m.restart(m);
        end
        
    end
    
end %end classdef