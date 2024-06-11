function setBoxAndTicks
% turn off box and ticks for all plots in current figure

allAxes = findall(gcf, 'type', 'axes');

for ii = 1:length(allAxes)
   tag = get(allAxes(ii),'tag');
   if strcmp(tag,'legend')
       continue;
   end
   set(allAxes(ii),'box','off'); 
   set(allAxes(ii),'TickDir','out');
end