function u = alignEigenVect(u, )
% check if orientation of eigenvectors from differrent draws is the same
% (by checking corr), if not - flip

% u(N,N,drawsNumb)

for d=1:size(u,3)
    for pc=1:size(u,2)
        if corr(u(:,pc,1), -u(:,pc,d))>corr(u(:,pc,1), u(:,pc,d))
            u(:,pc,d) = - u(:,pc,d);
        end
    end
end

end

