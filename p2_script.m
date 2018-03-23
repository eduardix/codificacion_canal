% SCRIPT DE EJEMPLO DE FUNCIONAMIENTO
clear all
close all
clc

debug = 1; %Muestra mensajes por pantalla

% 1) CONSTRUYE EL CÓDIGO QR. CODIFICACIÓN:
ecl = 3;                %Nivel de corrección de errores, de 0 a 3.
texto = 'Bienvenido a Tx. Digital';      %Texto a codificar

[QR,info]   = qr_encode(texto,ecl,debug);

% Muestra con la máscara m_id:
id          = 1; %cambia de 1 a 8. Son las 8 máscaras
info.m_id   = id-1;

figure;
imshow(~QR{id},'InitialMagnification','fit');
title(['Código QR con máscara ' num2str(id-1)]);

% 2) CANAL:

tipo = 0;       %Canal transparente (sin fallos)
p = 0;          %Probabilidad de cruce, borrado, etc

[nQR,errores] = qr_channel(QR{id},p,tipo); %Función de canal

figure;
subplot(1,3,1), imshow(~QR{id},'InitialMagnification','fit');
title(['Código QR original con máscara ' num2str(id-1)]);

subplot(1,3,2), imshow(~errores,'InitialMagnification','fit');
title(['Patrón de error']);

subplot(1,3,3), imshow(~nQR,'InitialMagnification','fit');
title(['Código QR con errores']);

% 3) DECODIFICACIÓN:

% 3a) Demodulación y decisión:
% Se haría con una cámara, por ejemplo.
% En esta sección se capturan la imagen y se demodula. Aquí se decide si un
% módulo es un uno, un cero ó si se produce borrado.

% 3b) Decodificación formato. Vamos a suponer que se ha decodificado
% correctamente, por ello le pasaremos la función info con la información
% sobre el formato.

% 3c) Decodificación payload: En la variable secuencias se muestra el
% dataword, el codeword y los errores. También se devuelve el mensaje
% decodificado según la codificación de fuente utilizada.

[secuencias,mensaje] = qr_payload_decode(nQR,info,debug);