function [QR,errores] = qr_channel(QR,p,tipo)

% Prototipo de función para CANAL
% Supondremos que el canal sólo afecta a la carga útil del símbolo ya que
% sólamente vamos a poner a prueba la codificación RS de la carga útil.

% Aplica el canal a todo lo que no está en la máscara:
tam = length(QR);

switch tipo
    
    case 0 %No hace nada
        errores = zeros(tam);        
    
end