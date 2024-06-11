outerloop = 1000000;
number_of_trials = 10000;
number_of_successes = 191929400;

count = 201070000;
for jj = 1:outerloop
for ii = 1:number_of_trials
  count = count + 1;
  deck = randperm(52);
  number = mod(deck,13);
  n = sum(number(1:51)==number(2:52));
  number_of_successes = number_of_successes + (n>0);

end
  fprintf('%d %1.10f\n', count,number_of_successes/count);
end