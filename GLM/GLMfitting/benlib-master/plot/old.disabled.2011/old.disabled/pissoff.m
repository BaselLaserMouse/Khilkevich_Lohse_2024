function pissoff(fname)

[ok, name] = unix('whoami');
name = name(1:end-1);
if ~strcmp(name,'willmore')
  fprintf(['Hello, ' name ',\n']);
  fprintf(['You have attempted to run ' fname '\n']);
  fprintf('This program should only be run by Ben Willmore.\n');
  fprintf('If you want to use it for your own data, edit it\n');
  fprintf('CAREFULLY, and remove all references to willmore-\n');
  fprintf('collected data. If you mess up BW''s data using\n');
  fprintf('this program, you will be instantly destroyed by\n');
  fprintf('infinitely powerful Beams.\n');
  fprintf('\n');
  fprintf('To save you from this terrible fate, Matlab will\n');
  fprintf('now exit. Sorry, but it''s for your own good.\n');
  exit
else
  fprintf('User is willmore, continuing...\n');
end
