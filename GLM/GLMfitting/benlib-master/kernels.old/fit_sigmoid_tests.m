x = [-100:100];
%y = sigmoidresp([100 2 30 40], x);
y = sigmoidresp([10 2 90 80], x)/100000;
figure(1);

for ex = 1:10
	fprintf('exponent = %d\n', ex);
	yp = y*10^ex;
	sig = fit_sigmoid(x, yp);
	fprintf('\n%0.2f %0.2f %0.2f %0.2f\n', sig.params);


	subplot(1,10,ex)
	plot(x,yp, 'o')
	hold on;
	plot(x,sigmoidresp(sig.params, x), 'linewidth', 2)
	%set(gca, 'xticklabel', [], 'yticklabel', [])
	hold off;

	drawnow;
end

return

for ii = 1:100
	x = [-100:100];
	y = sigmoidresp(rand(1,4)*100, x)+rand*100;
	y = y.*(1+rand(size(y))*.1-.05)*100000;
	sig = fit_sigmoid(x, y);

	subplottight(10,10,ii)
	plot(x,y, 'o')
	hold on;
	plot(x,sigmoidresp(sig.params, x), 'linewidth', 2)
	set(gca, 'xticklabel', [], 'yticklabel', [])
	hold off;

	drawnow;
end
