function y = minPhase(x)

h = hilbert(-log(x+0.0000000000001));
ph = imag(h);
y = real(ifft(x.*exp(i*ph)));
