a = fopen('/home/scratch/from_cam/images/original films/FILM.1/C1-10.512');

x = zeros(512,512);
y = zeros(512,512);

for i = 1:512
  for j = 1:512
    tmp = fread(a,1,'float32');
    x(i,j) = tmp;
  end
end
