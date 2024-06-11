function pressed = getkeypresswithoutwaiting(window)

deadKey = char(1);

% Find the "dbloop key catcher" figure, or create it if it doesn't exist

% Close the figure if requested
if nargin==1
  hf = window;
else
  hf = findall(0,'Tag','KEY_CATCHER');
end

if isempty(hf)
  % Make the figure elusive
  hf = figure('Tag','KEY_CATCHER', ...
    'Units','Normalized','Position',[1.1 1.1 .2 .1], ...
    'Menubar','None','CurrentCharacter',deadKey, ...
    'IntegerHandle','Off','NumberTitle','Off', ...
    'Name','Key Press Window','Resize','Off', ...
    'HandleVisibility','off');
end

% Get the function stack for setting/clearing breakpoints
dbs = dbstack;

% Make the "key catcher" figure active so we can assuredly catch keys
figure(hf)
drawnow

% If a specified key was pressed, make a breakpoint so it stops on the next
% execution, or else clear that potential breakpoint
cc = get(hf,'CurrentCharacter');
if ~strcmp(cc,deadKey)
  pressed = cc;
  % Reset the CurrentCharacter so it doesn't stop on every iteration
  set(hf,'CurrentCharacter',deadKey)
else
  pressed = 0;
end
