function [secuencias,mensaje] = qr_payload_decode(QR,info,showmsg)

% Esta función de decodificación de códigos QR permite decodificar la carga
% útil. El resto de la información se pasa en la estructura "info", 
% procedente de otras funciones que no han sido realizadas. Estas funciones
% devolverían la versión, el tipo de máscara, la codificación de errores
% utilizada, el vector de borrado, etc.

% Inicializa variable de las capacidades 
capacity = [0 19 152 25;...
            1 16 128 20;...
            2 13 104 16;...
            3 9 72 10];

% Recuperamos zona donde se desarrolla la acción. Recostruye máscara de 
% carga útil:
tam = length(QR);
mascara = zeros(tam);

mascara(1:9,1:9) = 1;
mascara(1:9,tam-7:tam) = 1;
mascara(tam-7:tam,1:9) = 1;

% Patrón tiempos
lon = length(9:tam-7-1);
mascara(7,9:9+lon) = 1;
mascara(9:9+lon,7) = 1;

% Aplicamos la máscara de erosión
[unmaskedQR,mask]   = masking(QR,mascara,info.m_id,tam);

% Ordenamos los bits según indice
codebin = zeros(1,208);
indv = info.indice(:);
for i = 1:length(indv)
    if indv(i) > 0        
        codebin(indv(i)) = unmaskedQR(i);
    end
end
%code = bin2dec(codebin);
codebin = num2str(codebin')';
codeword = [];
k = 1;

%Convierte en decimal para ver algo:
for i = 1:8:length(codebin)    
    codeword(k) = bin2dec(codebin(i:i+7));
    k = k+1;    
end
if showmsg
    disp('La codeword leida es:');
    disp(codeword);
end

% Decodificación de canal
% Esta información procede del vector de formato: Modo y ECL. n lo sabría
% con el propio tamaño. Recordamos que actualmente sólo decodificados
% versión 1-L,M,Q y H

m = 8; %Datawords de 8 bits
% Longitudes 1-L,M,Q,H para el código acortado
n                   = 26;                       %26 bytes o 208 bits
k                   = capacity(info.ecl+1,2);

% Código real (no acortado)
n_pad               = 2^m-1;        %n en el codificador no acortado
k_pad               = k+(n_pad-n);  %k en el codificador no acortado                                   

% Decodificamos (REQUIERE COMMUNICATION TOOLBOX)
enc                 = fec.rsenc(n_pad,k_pad);
enc.GenPoly         = rsgenpoly(n_pad,k_pad,[],0);  %Polinomio generador
enc.Shortenedlength = n_pad-n;                  %Especifica acortamiento

decoder         = fec.rsdec(enc);%Construye decodificador
[decoded,cnumerr,ccode] = decode(decoder,codeword');

if showmsg
    disp('La secuencia decodificada es:');
    disp(decoded');
    if cnumerr == 0
        disp('¡No hay errores!');
    elseif cnumerr > 0
        disp(['Errores encontrados y corregidos: ' num2str(cnumerr)]);
    else
        disp('Demasiados errores, pero seguimos adelante');
    end
end

secuencias.decoded  = decoded;
secuencias.errores  = cnumerr;
secuencias.ccode    = ccode;

decobin = dec2bin(decoded,8);
frame = decobin';
frame = frame(:)';

% Decodificación de la fuente:
dic1 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:';

% Mira la cabecera:
%mode                = frame(1:4);
longitud            = bin2dec(frame(5:13)); %Longitud en caracteres

if showmsg 
    disp(['La longitud del mensaje según cabecera es: ' num2str(longitud)]);
end

long_format = capacity(info.ecl+1,4);

if (longitud == 0 || longitud > long_format) && cnumerr == -1
    longitud = long_format;
    if showmsg
        disp('Los errores no corregidos han afectado a la cabecera.');
        disp('Utilizamos longitud máxima.');            
    end
end

% Decodifica el texto. Para ello sacamos palabras de 11 bits según modo
% alfanumérico. Cada 11 bits son dos letras. 6 bits aislados son una letra.
% La expresión "min(45,...)" sirve para evitar decodificaciones fuera del
% diccionario cuando hay fallos catastróficos.

k = 1;
if longitud == 1
    msg = frame(14:19);   
    sc  = dic1(min(45,bin2dec(msg)+1));
elseif longitud == 2
    msg = frame(14:24);    
    sc(1) = dic1(min(45,floor(bin2dec(msg)/45)+1));
    sc(2) = dic1(rem(bin2dec(msg),45)+1);    
elseif ~mod(longitud,2)
    nbloc = longitud/2;
    for i = 1:nbloc        
        msg  = frame(11*(i-1)+14:11*(i-1)+24);
        sc(k) = dic1(min(45,floor(bin2dec(msg)/45)+1));
        sc(k+1) = dic1(rem(bin2dec(msg),45)+1);
        k = k+2;        
    end    
else
    nbloc = floor(longitud/2);
    for i = 1:nbloc        
        msg = frame(11*(i-1)+14:11*(i-1)+24);
        sc(k) = dic1(min(45,floor(bin2dec(msg)/45)+1));
        sc(k+1) = dic1(rem(bin2dec(msg),45)+1);
        k = k+2;
    end
    msg = frame(11*i+14:11*i+19);
    sc  = [sc dic1(rem(bin2dec(msg),45)+1)];
end
mensaje = sc;

    if showmsg
        disp(['El mensaje es: ' mensaje]);
    end
end