clearvars; close all;

%% Voice Gender Conversion
% Celem niniejszego skryptu jest jak najwierniejsza konwersja damskiego głosu na meski i vice versa bez strat na naturalności. 

[x, fs] = audioread("mowa_1.wav");
%soundsc(female,fs);

[m,n] = size(x);

% Zamienienie orientacji wertykalnej na horyzontalną
if (m > n) 
    x = x'; 
end

% Tworzenie wektora czasu
T = length(x)/fs;      
t = 0: 1/fs : T - 1/fs;   

% Preemfaza sygnału. Równomierne skupienie mocy sygnalu w zależności od
% częstotliwości
x = filter([1 -0.9735], 1, x);        

out = [];                                               % Pusty buffor na zmieniony sygnał wejściowy
nPred = 10;                                             % Liczba współczynników filtra LPC. Wystarcza tylko 5 (dodatkowe 5 to sprzężenia, aby uniknąć liczb zespolonych)
step = 180;                                             % Długość bloku próbek
windowSize = 240;                                       % Długość stosowanego okna, większy niż ilość poróbek
frames = floor((length(x) - windowSize) / step + 1);    % Liczba operacji analizy i syntezy do wykonania

% Paramentry konwersji
fRatio = 0.83;                                          % Oczekiwana częstotliwosć zgłosek w stosunku do sygnału wejściowego - współczynnik skalujący
pRatio = 0.65;                                          % Nowa częstotliwość pików


for i = 1 : frames
    
    % Pobranie kolejnej partii próbek
    n = 1 + (i - 1) * step : windowSize + (i - 1) * step;
    bx = x(n);
    
    % Okienkowanie sygnału
    %bx = bx.*hamming(windowSize)';
    
    %% Analiza: wyznaczanie parametrów sygnału
    
    % IMPLEMENTACJA ALGORYTMU AOLA
    %
    % Przedlużenie lub skrócenie sygnału bez wpływu na jego częstotliwość.
    % Dodatkowym atutem algorytmu AOLA jest zachowanie ciągłości sygnału
    
    refBuff = bx;                                       % Buffor referencyjny, stan początkowy
    ratio = length(bx)/ length(refBuff);                % Zawsze == 1 ale zapisane w ten sposób, aby podkreślić znaczenie
    
    if fRatio < 1                                       % Konwersja damsko-męska
        while ratio > fRatio                            
            bx = AOLA(bx, 'reverse');
            ratio = length(bx) / length(refBuff);
        end
    else                                                % Konwersja męsko-damska
        while ratio < fRatio                            
            bx = AOLA(bx);
            ratio = length(bx) / length(refBuff);
        end
    end
    
    % LINIOWE KODOWANIE PREDYKCYJNE (LPC)
    %
    % Filtracja LPC ma na celu odseparowanie informacji o barwie głosu  i 
    % jego intonacji od informacji o mowie i amplitudzie
    
    [a,g] = lpc(bx, nPred);
    
    bx = filter(1, a, bx);
    
    % Znowu AOLA 
    
    ratio = 1;
    refbuff = bx;
    if pRatio / fRatio < 1                              % Konwersja damsko-męska
        while ratio > pRatio / fRatio                            
            bx = AOLA(bx, 'reverse');
            ratio = length(bx) / length(refBuff);
        end
    else                                                % Konwersja męsko-damska
        while ratio < pRatio / fRatio                            
            bx = AOLA(bx);
            ratio = length(bx) / length(refBuff);
        end
    end
    
    bx = filter(a, 1, bx);
    
    out = [out bx];
end

% Deemfaza sygnału - odwrócenie wejściowego filtra preemfazy
out = filter(1, [1 -0.9735], out);

%%

figure(2);
subplot(211);
plot(0: 1/fs : length(x)/fs - 1/fs, x);
subplot(212);
fs = pRatio / fRatio * fs;
plot(0: 1/fs : length(out)/fs - 1/fs, out);


%soundsc(out, fs);

























    