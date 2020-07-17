function y = OLA(x, out, coef)
% Implementacja algorytmu OLA (Overlap and Add algorithm)
%
% @x    buffor przetwarzany
% @out  buffor wyjściowy (konkatenacja)
% @coef współczynnik przesunięcia

        if ( coef > 2 || coef < 0) coef = 1;            % Warunek zachowania ciągłości sygnału
        end
        
        step = length(x);
        breakFrame = coef * step / 2;

        prefix = x(1 : breakFrame);
        sufix = x(breakFrame : end);

        y = [out(1 : end - breakFrame) out(end-breakFrame + 1 : end) + prefix sufix ];
end