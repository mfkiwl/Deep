function varargout = delayComp(pos, vel, acc, Cn2g, delay, q, wb)
% �ӳ�����,��λ���ٶ���̬������,�ڵ���ϵ����

% λ��
varargout{1} = pos + vel*delay*Cn2g;

% �ٶ�
varargout{2} = vel + acc*delay;

% ��̬
if nargin==7
    dtheta = wb*delay;
    phi = norm(dtheta);
    if phi>1e-12
        dq = [cos(phi/2), dtheta/phi*sin(phi/2)];
        q = quatmultiply(q, dq);
    end
    [r1,r2,r3] = quat2angle(q);
    varargout{3} = [r1,r2,r3]/pi*180;
end

end