cd /auto/data/archive/stimarchive/ED02/opti/e2004-03-30/e0043/net/

% eigenvectors

eig1 = pgmRead('image_0001.pgm');
eig2 = pgmRead('image_0003.pgm');
eig3 = pgmRead('image_0005.pgm');
eig4 = pgmRead('image_0007.pgm');
eig5 = pgmRead('image_0009.pgm');
eig6 = pgmRead('image_0011.pgm');
eig7 = pgmRead('image_0013.pgm');
eig8 = pgmRead('image_0015.pgm');


% good/bad stimuli

s1 = pgmRead('image_0017.pgm');
s2 = pgmRead('image_0019.pgm');
s3 = pgmRead('image_0021.pgm');
s4 = pgmRead('image_0023.pgm');
s5 = pgmRead('image_0002.pgm');
s6 = pgmRead('image_0004.pgm');
s7 = pgmRead('image_0006.pgm');
s8 = pgmRead('image_0008.pgm');

big = [eig1; eig2; eig3; eig4; eig5; eig6; eig7; eig8; s1; s2; s3; s4; s5; s6; s7; s8];
mx = max(big(:));

figure(1);

subplot(2,4,1);
show(eig8,[0 mx]);

subplot(2,4,2);
show(eig7,[0 mx]);

subplot(2,4,3);
show(eig6,[0 mx]);

subplot(2,4,4);
show(eig5,[0 mx]);

subplot(2,4,5);
show(eig4,[0 mx]);

subplot(2,4,6);
show(eig3,[0 mx]);

subplot(2,4,7);
show(eig2,[0 mx]);

subplot(2,4,8);
show(eig1,[0 mx]);



figure(2);

subplot(2,4,1);
show(s1,[0 mx]);

subplot(2,4,2);
show(s2,[0 mx]);

subplot(2,4,5);
show(s3,[0 mx]);

subplot(2,4,6);
show(s4,[0 mx]);

subplot(2,4,3);
show(s5,[0 mx]);

subplot(2,4,4);
show(s6,[0 mx]);

subplot(2,4,7);
show(s7,[0 mx]);

subplot(2,4,8);
show(s8,[0 mx]);

