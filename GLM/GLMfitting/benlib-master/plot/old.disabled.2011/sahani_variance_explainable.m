function v = sahani_variance_explainable(data,tt)
  % v = sahani_variance_explainable(data,tt)  
  %
  % data: as output by spikemonger
  % tt:   edges of bins for histogram

    
  % initialise structure
    v = struct;
    v.tt = tt;
    v.mean = nan(1,L(data));
    v.explainable = nan(1,L(data));

    
%% calculate for each stimulus
% ================================

  for ii=1:L(data)
    % number of repeats
      N = L(data(ii).repeats);
      
    % histogram
      h = nan(N, L(tt)-1);
      for jj=1:N
        h(jj,:) = histc_nolast(data(ii).repeats(jj).t,tt);
      end

    % calculate v explainable
      v.mean(ii) = var(mean(h));
      v.explainable(ii) = 1/(N-1) * (N * var(mean(h)) - mean(var(h,[],2)));
  end
  
%% calculate for overall dataset
% ===============================

  v.mean = sum(v.mean);
  v.explainable = sum(v.explainable);
  v.unexplainable = v.mean - v.explainable;
  v.noise_ratio = v.unexplainable / v.explainable;
  v.scale_performance_factor = v.mean / v.explainable;
  
  if v.explainable < 0
    v.explainable = 0;
    v.unexplainable = v.mean;
    v.noise_ratio = Inf;
    v.scale_performance_factor = nan;
  end
  
end


function h = histc_nolast(x,edges)
  h = histc(x,edges);
  h(end-1) = h(end-1)+h(end);
  h = h(1:(end-1));
end
