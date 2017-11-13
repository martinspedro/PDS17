%% Trabalho Prático 2
clear; clc; close all

%% Exercício 1
Gb = -0.9;
Gt = 0;
A = 1;

% sampling frequency
Fs = 44100;

%% a)
% [THEORETICAL]
% Retuangular pulse from f [0, 2000]
% Amplitude of the pulse = 1

%% b)
% filter parameters
lpf_iir.Nfilter = 5;        % Filter Order
lpf_iir.fc = 2000;          % Cut Frequency      [Hz]
lpf_iir.Rp = 1;             % Ripple in passband [dB]
lpf_iir.Rs = 50;            % Attenuation in rejection band [dB]

% get filter coefficients
[lpf_iir.num, lpf_iir.den] = ellip(lpf_iir.Nfilter, lpf_iir.Rp, lpf_iir.Rs, lpf_iir.fc/(Fs/2));

figure(1)
freqz(lpf_iir.num, lpf_iir.den)
title('H_b - Lowpass IIR filter')

figure(2)
zplane(lpf_iir.num, lpf_iir.den)
title('H_b - Lowpass IIR filter')

%% c)
% [THEORETICAL]

% Cálculo da função de transferência  do equalizador
h1.num = Gb * lpf_iir.num + lpf_iir.den * A;
h1.den = lpf_iir.den;

%% d)

figure(3)
freqz(h1.num, h1.den)
title('H_1(f)')

figure(4)
grpdelay(h1.num, h1.den)
title('Group Delay of filter')

% O equalizador não possui fase linear. Isto implica que o atraso de fase
% não seja constante e consequente o atraso de grupo não é nulo, atrasando
% as diferentes frequências de diferente forma.

% Comparando com a alínea a), verificamos uma diferença significativa na
% forma do filtro. O equalizador não tem um comportamento retangular na
% frequência devido a Hb ser um filtro real
% 

%% e)
% A resposta impulsional é a resposta a um dirac
dirac = [ 1 zeros(1, 199)];

y = filter(h1.num, h1.den, dirac);
figure(4)
stem(y, '.')
hold on
plot(dirac)
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response')
legend('y', '\delta')

%% Exercício 2
% filtro FIR de ordem = 100

%% a)
% i. Função de transferência do equalizador
% LPF filter parameters
lpf_fir.Nfilter = 100;        % Filter Order
lpf_fir.fc = 2000;            % Cut Frequency      [Hz]
lpf_fir.num = fir1(lpf_fir.Nfilter, lpf_fir.fc/(Fs/2), 'low');
lpf_fir.den = 1;

% Equalizador
h2.num = Gb * lpf_fir.num;
h2.num(1) = h2.num(1) + A;
h2.den = 1;

% ii. Resposta em frequência do equalizador


% Caracteristica do filtro
% Filtro FIR -> Fase Linear
figure(5)
freqz(lpf_fir.num, lpf_fir.den)
title('LPF filter - Frequency domain')

figure(6)
zplane(lpf_fir.num, lpf_fir.den)
title('LPF filter - Poles and zeros plane')

% Resposta em frequência do equalizador (diagrama de blocos) 
figure(7)
freqz(h2.num, h2.den)
title('H_2(z) - Frequency domain');

figure(8)
zplane(h2.num, h2.num)
title('H_2(z) - Poles and zeros plane');

% ii. Resposta impulsional do filtro
y2.lpf = filter(lpf_fir.num, lpf_fir.den, dirac);
figure(9)
stem(y2.lpf, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | LPF_{fir}(\delta)')
legend('H_b(z)', '\delta')

y2.eq_0  = filter(h2.num, h2.den, dirac);
figure(10)
stem(y2.eq_0, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | H_2(\delta)')
legend('y', '\delta')


% Na figura 5 observamos um LPF com fase linear na abanda de passagem.
% Fora da banda de passagem, o filtro tem uma variação de fase não linear e
% a amplitude possui ripple
% Na figura 7 temos o filtro causado pelo equalizador. Este filtro não
% possui ganho constante na banda de passagem nem uma fase linear. 
% A partir de pi/8 (Fs/16) o seu ganho e fase são constantes
%
% O filtro LPF FIR tem um resposta impulsional simétrica do Equalizador. As
% amplitudes mantêm-se constantes nos dois casos

%% b) A(z) = z^-50
% i. Função de transferência do equalizador
h3.num = Gb * lpf_fir.num;
h3.num(51) = h3.num(51) + A;
h3.den = 1;

% Resposta em frequência do equalizador
figure(11)
freqz(h3.num, h3.den)
title('H_2(z) - Frequency domain');

figure(12)
zplane(h3.num, h3.num)
title('H_2(z) - Poles and zeros plane');

% ii. Atraso de Grupo e Resposta em freqência
figure(13)
subplot(121)
phasedelay(h3.num, h3.den)
title('Atraso de fase do Filtro')

subplot(122)
grpdelay(h3.num, h3.den)
title('Atraso de grupo do filtro')

% Podemos constatar que o atraso de grupo e o atraso de fase são contantes,
% ou seja, o filtro introduz um atraso contaste de 50 amostras em toda a
% gama de frequências de amostragem, o que não se verificava para o filtro
% anterior

% iii. Resposta impulsional do equalizador
y2.eq_50 = filter(h3.num, h3.den, dirac);
figure(14)
stem(y2.eq_50, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | H_2(\delta)')
legend('y', '\delta')


% A resposta impulsional passa a ter um dirac na amostra 50 (resultante do
% atraso causado pelo A = z^-50. A restante resposta é igual ao que 
% tinhamos aneriormente no caso de A = 1 

%% c)
% Devido a esse atraso passamos a ter a relação 
% R(w)*e^-jw50 + e^+jw50 = (R(w) + 1)*e^-jw50 quando A(z) = z^-50 
% em vez de R(w)*e^-jw50 + 1 quando A(z) = 1. 
% Ao introduzir o atraso garantimos que entre os dois membros do
% equalizador não existem fases diferentes, tendo o equalizador ter fase
% linear e variações em amplitude apenas dependentes da resposta em
% amplitude das funções de transferências dos membros. Assim garatimos que
% podemos escrever a função de transferência do equalizador com operações
% de combinação linear dos seus modulos 

%% Ex3
Gb = 9
Gt = 1/sqrt(10) -1

%% Ex4 - a)
% i. Função de transferência do equalizador
Nfilter = 100;

% Hb filter parameters
Hb.Nfilter = Nfilter;        % Filter Order
Hb.fc = 2000;            % Cut Frequency      [Hz]
Hb.num = fir1(Hb.Nfilter, Hb.fc/(Fs/2), 'low');
Hb.den = 1;

% Ht filter parameters
Ht.Nfilter = Nfilter;        % Filter Order
Ht.fc = 6000;            % Cut Frequency      [Hz]
Ht.num = fir1(Ht.Nfilter, Ht.fc/(Fs/2), 'high');
Ht.den = 1;

% Equalizador
h4.num = Gb * Hb.num + Gt * Ht.num ;
h4.num(51) = h4.num(51) + A;
h4.den = 1;

% ii. Resposta em frequência do equalizador
% Caracteristica dos filtros
% Filtro FIR Hb -> Fase Linear
figure(15)
freqz(Hb.num * Gb, Hb.den)
title('Hb LPF filter - Frequency domain')

figure(16)
zplane(Hb.num, Hb.den)
title('Hb LPF filter - Poles and zeros plane')

% Filtro FIR Ht -> Fase Linear
figure(17)
freqz(Ht.num * Gt, Ht.den)
title('Ht HPF filter - Frequency domain')

figure(18)
zplane(Ht.num, Ht.den)
title('Ht HPF filter - Poles and zeros plane')

% Resposta em frequência do equalizador (diagrama de blocos) 
figure(18)
freqz(h4.num, h4.den)
title('H_4(z) - Frequency domain');

figure(19)
zplane(h4.num, h4.num)
title('H_4(z) - Poles and zeros plane');


% ii. Resposta impulsional do filtro
y3.Hb = filter(Hb.num, Hb.den, dirac);
figure(20)
stem(y3.Hb, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | LPF_{fir}(\delta)')
legend('H_b(z)', '\delta')

y3.Ht = filter(Ht.num, Ht.den, dirac);
figure(21)
stem(y3.Ht, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | HPF_{fir}(\delta)')
legend('H_t(z)', '\delta')

y3.eq  = filter(h4.num, h4.den, dirac);
figure(22)
stem(y3.eq, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | H_4(\delta)')
legend('y', '\delta')


% Na figura 5 observamos um LPF com fase linear na abanda de passagem.
% Fora da banda de passagem, o filtro tem uma variação de fase não linear e
% a amplitude possui ripple
% Na figura 7 temos o filtro causado pelo equalizador. Este filtro não
% possui ganho constante na banda de passagem nem uma fase linear. 
% A partir de pi/8 (Fs/16) o seu ganho e fase são constantes
%
% O filtro LPF FIR tem um resposta impulsional simétrica do Equalizador. As
% amplitudes mantêm-se constantes nos dois casos

%% Trabalho Prático 2
clear; clc; close all

%% Exercício 1
Gb = -0.9;
Gt = 0;
A = 1;

% sampling frequency
Fs = 44100;

%% a)
% [THEORETICAL]
% Retuangular pulse from f [0, 2000]
% Amplitude of the pulse = 1

%% b)
% filter parameters
lpf_iir.Nfilter = 5;        % Filter Order
lpf_iir.fc = 2000;          % Cut Frequency      [Hz]
lpf_iir.Rp = 1;             % Ripple in passband [dB]
lpf_iir.Rs = 50;            % Attenuation in rejection band [dB]

% get filter coefficients
[lpf_iir.num, lpf_iir.den] = ellip(lpf_iir.Nfilter, lpf_iir.Rp, lpf_iir.Rs, lpf_iir.fc/(Fs/2));

figure(1)
freqz(lpf_iir.num, lpf_iir.den)
title('H_b - Lowpass IIR filter')

figure(2)
zplane(lpf_iir.num, lpf_iir.den)
title('H_b - Lowpass IIR filter')

%% c)
% [THEORETICAL]

% Cálculo da função de transferência  do equalizador
h1.num = Gb * lpf_iir.num + lpf_iir.den * A;
h1.den = lpf_iir.den;

%% d)

figure(3)
freqz(h1.num, h1.den)
title('H_1(f)')

figure(4)
grpdelay(h1.num, h1.den)
title('Group Delay of filter')

% O equalizador não possui fase linear. Isto implica que o atraso de fase
% não seja constante e consequente o atraso de grupo não é nulo, atrasando
% as diferentes frequências de diferente forma.

% Comparando com a alínea a), verificamos uma diferença significativa na
% forma do filtro. O equalizador não tem um comportamento retangular na
% frequência devido a Hb ser um filtro real
% 

%% e)
% A resposta impulsional é a resposta a um dirac
dirac = [ 1 zeros(1, 199)];

y = filter(h1.num, h1.den, dirac);
figure(4)
stem(y, '.')
hold on
plot(dirac)
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response')
legend('y', '\delta')

%% Exercício 2
% filtro FIR de ordem = 100

%% a)
% i. Função de transferência do equalizador
% LPF filter parameters
lpf_fir.Nfilter = 100;        % Filter Order
lpf_fir.fc = 2000;            % Cut Frequency      [Hz]
lpf_fir.num = fir1(lpf_fir.Nfilter, lpf_fir.fc/(Fs/2), 'low');
lpf_fir.den = 1;

% Equalizador
h2.num = Gb * lpf_fir.num;
h2.num(1) = h2.num(1) + A;
h2.den = 1;

% ii. Resposta em frequência do equalizador


% Caracteristica do filtro
% Filtro FIR -> Fase Linear
figure(5)
freqz(lpf_fir.num, lpf_fir.den)
title('LPF filter - Frequency domain')

figure(6)
zplane(lpf_fir.num, lpf_fir.den)
title('LPF filter - Poles and zeros plane')

% Resposta em frequência do equalizador (diagrama de blocos) 
figure(7)
freqz(h2.num, h2.den)
title('H_2(z) - Frequency domain');

figure(8)
zplane(h2.num, h2.num)
title('H_2(z) - Poles and zeros plane');

% ii. Resposta impulsional do filtro
y2.lpf = filter(lpf_fir.num, lpf_fir.den, dirac);
figure(9)
stem(y2.lpf, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | LPF_{fir}(\delta)')
legend('H_b(z)', '\delta')

y2.eq_0  = filter(h2.num, h2.den, dirac);
figure(10)
stem(y2.eq_0, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | H_2(\delta)')
legend('y', '\delta')


% Na figura 5 observamos um LPF com fase linear na abanda de passagem.
% Fora da banda de passagem, o filtro tem uma variação de fase não linear e
% a amplitude possui ripple
% Na figura 7 temos o filtro causado pelo equalizador. Este filtro não
% possui ganho constante na banda de passagem nem uma fase linear. 
% A partir de pi/8 (Fs/16) o seu ganho e fase são constantes
%
% O filtro LPF FIR tem um resposta impulsional simétrica do Equalizador. As
% amplitudes mantêm-se constantes nos dois casos

%% b) A(z) = z^-50
% i. Função de transferência do equalizador
h3.num = Gb * lpf_fir.num;
h3.num(51) = h3.num(51) + A;
h3.den = 1;

% Resposta em frequência do equalizador
figure(11)
freqz(h3.num, h3.den)
title('H_2(z) - Frequency domain');

figure(12)
zplane(h3.num, h3.num)
title('H_2(z) - Poles and zeros plane');

% ii. Atraso de Grupo e Resposta em freqência
figure(13)
subplot(121)
phasedelay(h3.num, h3.den)
title('Atraso de fase do Filtro')

subplot(122)
grpdelay(h3.num, h3.den)
title('Atraso de grupo do filtro')

% Podemos constatar que o atraso de grupo e o atraso de fase são contantes,
% ou seja, o filtro introduz um atraso contaste de 50 amostras em toda a
% gama de frequências de amostragem, o que não se verificava para o filtro
% anterior

% iii. Resposta impulsional do equalizador
y2.eq_50 = filter(h3.num, h3.den, dirac);
figure(14)
stem(y2.eq_50, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | H_2(\delta)')
legend('y', '\delta')


% A resposta impulsional passa a ter um dirac na amostra 50 (resultante do
% atraso causado pelo A = z^-50. A restante resposta é igual ao que 
% tinhamos aneriormente no caso de A = 1 

%% c)
% Devido a esse atraso passamos a ter a relação 
% R(w)*e^-jw50 + e^+jw50 = (R(w) + 1)*e^-jw50 quando A(z) = z^-50 
% em vez de R(w)*e^-jw50 + 1 quando A(z) = 1. 
% Ao introduzir o atraso garantimos que entre os dois membros do
% equalizador não existem fases diferentes, tendo o equalizador ter fase
% linear e variações em amplitude apenas dependentes da resposta em
% amplitude das funções de transferências dos membros. Assim garatimos que
% podemos escrever a função de transferência do equalizador com operações
% de combinação linear dos seus modulos 

%% Ex3
Gb = 9;
Gt = 1/sqrt(10) -1;

%% Ex4 - a)
% i. Função de transferência do equalizador
Nfilter = 100;

% Hb filter parameters
Hb.Nfilter = Nfilter;        % Filter Order
Hb.fc = 2000;            % Cut Frequency      [Hz]
Hb.num = fir1(Hb.Nfilter, Hb.fc/(Fs/2), 'low');
Hb.den = 1;

% Ht filter parameters
Ht.Nfilter = Nfilter;        % Filter Order
Ht.fc = 6000;            % Cut Frequency      [Hz]
Ht.num = fir1(Ht.Nfilter, Ht.fc/(Fs/2), 'high');
Ht.den = 1;

% Equalizador
h4.num = Gb * Hb.num + Gt * Ht.num ;
h4.num(51) = h4.num(51) + A;
h4.den = 1;


% ii. Resposta em frequência do equalizador
% Caracteristica dos filtros
% Filtro FIR Hb -> Fase Linear
figure(15)
freqz(Hb.num, Hb.den)
title('Hb LPF filter - Frequency domain')

figure(16)
zplane(Hb.num, Hb.den)
title('Hb LPF filter - Poles and zeros plane')

% Filtro FIR Ht -> Fase Linear
figure(17)
freqz(Ht.num, Ht.den)
title('Ht HPF filter - Frequency domain')

figure(18)
zplane(Ht.num, Ht.den)
title('Ht HPF filter - Poles and zeros plane')

% Resposta em frequência do equalizador (diagrama de blocos) 
figure(18)
freqz(h4.num, h4.den)
title('H_4(z) - Frequency domain');

figure(19)
zplane(h4.num, h4.num)
title('H_4(z) - Poles and zeros plane');


% ii. Resposta impulsional do filtro
y3.Hb = filter(Hb.num, Hb.den, dirac);
figure(20)
stem(y3.Hb, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | LPF_{fir}(\delta)')
legend('H_b(z)', '\delta')

y3.Ht = filter(Ht.num, Ht.den, dirac);
figure(21)
stem(y3.Ht, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | HPF_{fir}(\delta)')
legend('H_t(z)', '\delta')

y3.eq  = filter(h4.num, h4.den, dirac);
figure(22)
stem(y3.eq, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | H_4(\delta)')
legend('y', '\delta')

% Usando dois filtros com a mesma ordem, onde garantimos que possuímos a
% mesma fase (usamos os resultados do ex2.b), conseguimos obter a resposta
% em frequência pretendida no trabalho prático.
% As frequências de corte dos filtros são obtidas através da resposta em
% frequência. Os ganhos podem ser obtidos fazendo:
% 20log10(1 + Gb) = 20  => Gb = 9
% 20log10(1 + Gt) = -10 => Gt = 1/sqrt(10) - 1
% O fator 1 dentro do log é a contribição do A no ganho
% Vamos ter uma zona com ganho positivo causada por o filtro passa baixo
% até fc = 2000 Hz. Depois temos um ganho de 0 dB causado pelo A. O filtro
% passa baixo deixa de ter influência nesta zona e a partir de 6000 Hz o
% filtro passa-alto coloca o ganho em -10 dB.
% No calculo dos ganhos devemos ter em consideração o A, tanto no LPF e no
% HPF, porque a magnitude destes vai ser influenciada pelo ganho constante.
% A fase é constante em toda a banda, resultado da associação de 2 filtros
% FIR com fase linear e da introdução do atraso em A

%% Ex4 - b)
% i. Função de transferência do equalizador
% Hb filter parameters
Hb.Nfilter = 100;        % Filter Order
Hb.fc = 2000;            % Cut Frequency      [Hz]
Hb.num = fir1(Hb.Nfilter, Hb.fc/(Fs/2), 'low');
Hb.den = 1;

% Ht filter parameters
Ht.Nfilter = 90;        % Filter Order
Ht.fc = 6000;            % Cut Frequency      [Hz]
Ht.num = fir1(Ht.Nfilter, Ht.fc/(Fs/2), 'high');
Ht.den = 1;

% Equalizador
% O atraso deve estar centrado. Para isso é preciso fazer um pad com zeros
% à frente igual ao atraso e shiftar o sinal o número de amostras
% necessárias para os sinais ficarem com a mesma dimensão
idx = abs(Ht.Nfilter - Hb.Nfilter)/2;
A_delay = max(Hb.Nfilter, Ht.Nfilter)/2;
h5.num = Gb * Hb.num;
h5.num(idx+1:end-idx) = h5.num(idx+1:end-idx) + Gt * Ht.num;
h5.num(end-idx+1:end) = zeros(1, idx);
h5.num(A_delay + 1) = h5.num(A_delay + 1) + A;
h5.den = 1;


% ii. Resposta em frequência do equalizador
% Caracteristica dos filtros
% Filtro FIR Hb -> Fase Linear
figure(23)
freqz(Hb.num, Hb.den)
title('Hb LPF filter - Frequency domain')

figure(24)
zplane(Hb.num, Hb.den)
title('Hb LPF filter - Poles and zeros plane')

% Filtro FIR Ht -> Fase Linear
figure(25)
freqz(Ht.num, Ht.den)
title('Ht HPF filter - Frequency domain')

figure(26)
zplane(Ht.num, Ht.den)
title('Ht HPF filter - Poles and zeros plane')

% Resposta em frequência do equalizador (diagrama de blocos) 
figure(27)
freqz(h4.num, h4.den)
title('H_4(z) - Frequency domain');

figure(28)
zplane(h4.num, h4.num)
title('H_4(z) - Poles and zeros plane');


% ii. Resposta impulsional do filtro
y4.Hb = filter(Hb.num, Hb.den, dirac);
figure(29)
stem(y4.Hb, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | LPF_{fir}(\delta)')
legend('H_b(z)', '\delta')

y4.Ht = filter(Ht.num, Ht.den, dirac);
figure(30)
stem(y4.Ht, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | HPF_{fir}(\delta)')
legend('H_t(z)', '\delta')

y4.eq  = filter(h5.num, h5.den, dirac);
figure(31)
stem(y4.eq, '.')
hold on
stem(dirac, '.')
hold off
xlabel('')
ylabel('Amplitude')
title('Impulse response | H_4(\delta)')
legend('y', '\delta')

% Temos de usar o filtro Hb (LPF) com uma ordem inferior. Por isso, este
% filtro tem de sofrer um atraso igual a metade da  diferença de ordens dos
% filtros (neste caso, 10/2 = 5). Não pode ser o filtro passa alto a ser de
% ordem inferior porque senão influencia o LPF e a resposta é alterada. 
% O atraso de A deve-se ser igual ao atraso introduzido pelo filtro com
% maior ordem
% o atraso introduzido por um filtro é metade da sua ordem

% Os resultados são idênticos à alínea a)

%%
% Load signal
x.time = audioread('reportagem.wav');

% Downsample the signal (dont care about high frequencies...)
x.downsample = x.time(1:4:end);

% Filter using H4 (full equalizer with the same order in both filters)
y4.base_band = filter(h4.num, h4.den, x.downsample);

% Play sound in audible band
sound(y4.base_band, Fs);
