function q = quatCorr(q, X)
% ʹ����̬ʧ׼��������Ԫ��
% XΪ��̬ʧ׼��ʸ��,������

phi = norm(X);
if phi>1e-6
    qc = [cos(phi/2), X/phi*sin(phi/2)];
    q = quatmultiply(qc, q);
end
q = q / norm(q);

end