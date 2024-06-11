outerloop = 1000000;
number_of_trials = 10000;
number_of_successes = 0;

count = 0;
for jj = 1:outerloop
for ii = 1:number_of_trials
  count = count + 1;
  deck = randperm(52);
  number = mod(deck,13);
  f = (number==number(1));
  n = sum((f(1:51)==1) & (f(2:52)==1));
  number_of_successes = number_of_successes + (n>0);
end
  fprintf('%d %d %1.10f\n', number_of_successes, count,number_of_successes/count);
end