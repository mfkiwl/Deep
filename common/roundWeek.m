function dt = roundWeek(dt)
% ������������ѭ��,��ʱ���ת�ɡ�302400s
% �μ�GPS,BDS�ӿ��ĵ��������㲿��

if dt>302400
    dt = dt-604800;
elseif dt<-302400
    dt = dt+604800;
end

end