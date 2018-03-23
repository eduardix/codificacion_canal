function [QR, info] = qr_encode(texto,ecl,showmsg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EDUARDO DEL ARCO FERNÁNDEZ                                              %
% SIGNAL THEORY AND COMMUNICATIONS                                        %
% UNIVERSIDAD REY JUAN CARLOS                                             %
% SPAIN                                                                   %
% 2012                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BASED ON INTERNATIONAL STANDARD ISO/IEC 18004                           % 
% Information technology — Automatic                                      % 
% identification and data capture                                         %
% techniques — Bar code symbology — QR                                    %
% Code                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Esta función codifica una cadena de caracteres a un código QR versión 1
% (21x21) con cuatro posibles correciones de error (tabla 1) y ocho 
% máscaras. El presente código genera ocho códigos QR válidos, cada uno 
% utilizando una máscara diferente. Si la cadena de texto es demasiado
% larga, se acorta de acuerdo con la tabla 2. Si es demasiado corta, se
% utilizan las técnicas de relleno descritas en el estándar.

% Además, la función devuelve información extra para simplificar la
% decodificación y no tener que programar un decodificador completo. 

% La carga útil se codifica utilizando un código alfanumérico. También se
% utilizan caracteres de relleno, terminadores, etc.
% Esta realización del codificador está limitada a tamaño "versión 1".

% Tabla 1:
% Error Correction Level      
% L - 7%   ecl = 0          
% M - 15%  ecl = 1         
% Q - 25%  ecl = 2         
% H - 30%  ecl = 3

% Tabla 2:
% Capacidades según ECL para tamaño versión 1:
% ECL  Number of data words Number of databits Alphanumeric capacity
% L                      19                152                    25 
% M                      16                128                    20 
% Q                      13                104                    16 
% H                       9                 72                    10

% Diccionario de caracteres alfanuméricos para codificación de fuente:
dic1 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:';

% Capacidades de acuerdo con la tabla 2:
capacity = [0 19 152 25;...
            1 16 128 20;...
            2 13 104 16;...
            3 9 72 10];
        
% Dependiendo de la naturaleza de los datos a codificar, este tamaño
% permite cuatro modos de codificación. Se utilizará el modo alfanumérico.
%
% numeric mode :        0001
% alphanumeric mode :   0010
% 8bit byte mode:       0100
% KANJI mode :          1000
%
% Utilizaremos el modo alfanumérico.

% Iniciar algunas variables:

ver         = 1;                    %Versión 1.
tam         = 21 + (ver-1)*4;       %21 X 21 pixeles.
mode        = '0010';               %Modo alfanumérico

pattern     = zeros(tam);           %Patrón de búsqueda y tiempos Ver 1
mascara     = zeros(tam);           %Máscara diferenciando datos de formato
layout      = zeros(tam);           %Datos dispuestos en 2D

maskedlayout    = cell(1,8);        %Datos después de ocho máscaras
mask            = cell(1,8);        %Las ocho máscaras
formatrices     = cell(1,8);        %Vectores de formato en 2D
format          = cell(1,8);        %Vectores de formato en 1D
QR              = cell(1,8);        %Códigos terminados

maxbit      = capacity(ecl+1,3);    %Número de bits
cap         = capacity(ecl+1,4);    %Capacidad alfanumérica

%%%%%%%%%%%%%%%%%%%%%%%%%%% COMIENZO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convierte a mayúsculas
texto       = upper(texto);

% Medimos el texto:
l           = length(texto);
if showmsg
    disp(['Longitud del texto: ' num2str(l)]);
end

% Trunca si mayor que cap
if l > cap
    texto = texto(1:cap);    
    disp(['Hay que cortar: ' num2str(l) ' > '  num2str(cap)]);
    l = cap;
    if showmsg
        disp(texto);
    end
end

% Se codifica el número de caracteres en una cadena de 9 bits
lbin = dec2bin(l,9);

% Construye cabecera
header = [mode lbin];

% CODIFICA EN FUENTE utilizando standard:
k = 1;
if l == 1    
    sc = dec2bin(find(dic1 == texto(1))-1,6);
    sc=sc(:);
elseif l == 2
    
    sc = dec2bin(45*(find(dic1 == texto(1))-1)+(find(dic1 == texto(2))-1),11);
    sc=sc(:);
elseif ~mod(l,2)
    
    for i = 1:2:(l-1)        
        sc(k,:) = dec2bin(45*(find(dic1 == texto(i))-1)+(find(dic1 == texto(i+1))-1),11);
        k = k+1;
    end
    sc = sc';
    sc = sc(:);
else
    
    for i = 1:2:(l-1)        
        sc(k,:) = dec2bin(45*(find(dic1 == texto(i))-1)+(find(dic1 == texto(i+1))-1),11);
        k = k+1;
    end
    sc = sc';
    sc = [sc(:); dec2bin(find(dic1 == texto(end))-1,6)'];     
end

% Ahora añadimos terminadores y bytes de relleno hasta alcanzar la
% capacidad. Tiene que quedar una secuencia de maxbytes bytes:

frame           = [header sc'];
current_len     = length(frame);

if current_len < maxbit
    %Añadimos necesariamente la terminación
    stop = min(4,maxbit-current_len);
    stop = num2str(zeros(1,stop)')';
    frame = [frame stop];
    current_len     = length(frame);
end

if current_len < maxbit
    %Rellenamos hasta completar un byte
    pad         = mod(8-rem(current_len,8),8);
    frame       = [frame num2str(zeros(1,pad)')'];    
    
    %Si sique sin completarse añadimos bytes de relleno hasta completar la 
    %capacidad del QR.
    padpattern = ['00010001';'11101100'];
    i=1;
    while length(frame) < maxbit            
        frame = [frame padpattern(mod(i,2)+1,:)];
        i = i+1;
    end
    current_len     = length(frame);
end

if current_len == maxbit
    dataword = [];
    k = 1;
    
    for i = 1:8:length(frame)    
        dataword(k) = bin2dec(frame(i:i+7));
        k = k+1;    
    end
    if showmsg
        disp('La secuencia codificada en fuente es:');
        disp(dataword);
    end
else
    disp('Error');
end

% CODIFICACIÓN DE CANAL
m = 8; %Datawords de 8 bits

% Longitudes 1-L,M,Q,H para el código acortado
n                   = 26;
k                   = length(dataword);

% Código real (no acortado)
n_pad               = 2^m-1;        %n en el codificador no acortado
k_pad               = k+(n_pad-n);  %k en el codificador no acortado                                   

% Codificamos (REQUIERE COMMUNICATION TOOLBOX)
enc                 = fec.rsenc(n_pad,k_pad);
enc.GenPoly         = rsgenpoly(n_pad,k_pad,[],0);  %Polinomio generador
enc.Shortenedlength = n_pad-n;                  %Especifica acortamiento
code                = encode(enc,dataword');

if showmsg
    disp('La secuencia codificada en canal es:');
    disp(code');
end

% CONSTRUYE DISEÑO BÁSICO
% Se construyen los patrones de búsqueda y tiempo. También se construye una
% máscara para diferenciar la carga útil del resto de patrones e
% información de formato.

% Patrón búsqueda
pattern(1:7,1)          = 1;
pattern(1:7,7)          = 1;
pattern(1,1:7)          = 1;
pattern(7,1:7)          = 1;
pattern(3:5,3:5)        = 1;

pattern(1:7,tam-7+1:tam) = pattern(1:7,1:7);
pattern(tam-7+1:tam,1:7) = pattern(1:7,1:7);

mascara(1:9,1:9) = 1;
mascara(1:9,tam-7:tam) = 1;
mascara(tam-7:tam,1:9) = 1;

% Patrón tiempos
lon = length(9:tam-7-1);
mascara(7,9:9+lon) = 1;
mascara(9:9+lon,7) = 1;

for i = 9:2:9+lon
    pattern(7,i) = 1;
    pattern(i,7) = 1;
end
pattern(tam-7+1,9) = 1;

% COLOCA EL CODEWORD EN EL LAYOUT
% Repartimos los bits de la carga útil siguiendo el diseño de un código QR
% versión 1. 

indice = aligment(tam);     %Función de alineación. Sólo vale para tam = 21
indv        = indice(:);
codebin     = dec2bin(code)';
codebin     = codebin(:);

for i = 1:length(indv)
    if indv(i) > 0        
        layout(i) = str2double(codebin(indv(i)));
    end
end

% MÁSCARA E INFORMACIÓN DE FORMATO
% El estándar define 8 máscaras diferentes. Todas son válidas, es necesario
% elegir una. En esta realización las representaremos todas:

for m_id=1:8
    % Máscara:
    [maskedlayout{m_id},mask{m_id}] = masking(layout,mascara,m_id-1,tam);
    
    % Vector de formato:
    % Vector con información sobre el formato utilizado. Incluye máscara y ecl.
    % Es válido para versiones de 1 a 7. Es una secuencia de 5 bits con
    % corrección de errores BCH.
    
    formatrix           = zeros(tam);
    formv               = formatinfo(ecl,m_id); %Busca el vector de formato   

    %Primer vector
    formatrix(9,14:21)  = formv(8:15);
    formatrix(9,1:6)    = formv(1:6);
    formatrix(9,8)      = formv(7);

    %Segundo vector repetido
    formatrix(1:6,9)    = fliplr(formv(10:15));
    formatrix(15:21,9)  = fliplr(formv(1:7));
    formatrix(8:9,9)    = fliplr(formv(7:8));    
    formatrices{m_id}   = formatrix; 
    format{m_id}        = formv;
    
    %Montamos todo
    QR{m_id} = mod(maskedlayout{m_id} + formatrices{m_id} + pattern,2);       
end

% INFORMACIÓN EXTRA:

info.format     = format;     %Vector de formato 1D
info.ver        = ver;        %Versión  
info.ecl        = ecl;        %Error Correcting Level
info.texto      = texto;      %Texto
info.dataword   = dataword;   %La palabra código
info.code       = code;       %Código RS
info.enc        = enc;        %Codificador utilizado
info.indice     = indice;     %Colocación bits

end
