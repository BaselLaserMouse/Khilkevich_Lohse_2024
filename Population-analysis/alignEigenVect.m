function u = alignEigenVect(u, templateVect)
% check if orientation of eigenvectors from differrent draws is the same
% (by checking corr), if not - flip
% u(N,dim,drawsNumb)

for d=1:size(u,3)
    for pc=1:size(u,2)
        if sum(isnan(corr(templateVect(:,pc), u(:,pc,d))))>0
            debug = 1;
        else
            if (templateVect(:,pc)'*u(:,pc,d))<0
                u(:,pc,d) = - u(:,pc,d);
            end
        end
    end
end

end

