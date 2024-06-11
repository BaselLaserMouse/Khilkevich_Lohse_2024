function output = parfor_progress(input)
% pp = parfor_progress(10)
% for ii = 1:10
%   do_computation;
%   parfor_progress(pp);
% end

if ~isstruct(input)
    [~, dirname] = system('uuidgen');
    dirname = ['.' dirname(1:end-1)];
    mkdir(dirname);
    output.dirname = dirname;
    output.n = input;

else
    [~, filename] = system('uuidgen');
    filename = filename(1:end-1);
    f = fopen([input.dirname '/' filename], 'w');
    fwrite(f, 'X');
    fclose(f);
    [~, n_done] = system(['ls ' input.dirname ' | wc -l']);
    n_done = str2num(n_done);
    fprintf('%10d%% done (%d of %d)\n', (n_done/input.n)*100, n_done, input.n);

end
