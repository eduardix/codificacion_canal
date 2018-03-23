function [pattern,mask] = masking(pattern,forbidden,ref,tam)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                      %
% Mask Pattern   Condition                             %
% Reference                                            %
% 000            (i + j) mod 2 = 0                     %
% 001            i mod 2 = 0                           %
% 010            j mod 3 = 0                           %
% 011            (i + j) mod 3 = 0                     % 
% 100            ((i div 2) + (j div 3)) mod 2 = 0     %
% 101            (i j) mod 2 + (i j) mod 3 = 0         %
% 110            ((i j) mod 2 + (i j) mod 3) mod 2 = 0 %
% 111            ((i j) mod 3 + (i+j) mod 2) mod 2 = 0 %
%                                                      % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nota: i columnas, j filas. Según estándar.

mask = ones(tam);

switch ref
    case 0 %000
       for i = 1:tam
            for j = 1:tam
                if mod((i-1)+(j-1),2) == 0 && forbidden(j,i) == 0                    
                    mask(j,i) = 0;
                    pattern(j,i) = ~pattern(j,i);                            
                end
            end
        end 
    case 1 %001
        for i = 1:tam
            for j = 1:tam
                if mod((j-1),2) == 0 && forbidden(j,i) == 0
                    mask(j,i) = 0;
                    pattern(j,i) = ~pattern(j,i);                            
                end
            end
        end
    case 2 %010
        for i = 1:tam
            for j = 1:tam
                if mod((i-1),3) == 0 && forbidden(j,i) == 0
                    mask(j,i) = 0;
                    pattern(j,i) = ~pattern(j,i);                            
                end
            end
        end
    case 3 %011
        for i = 1:tam
            for j = 1:tam
                if mod((i-1)+(j-1),3) == 0 && forbidden(j,i) == 0
                    mask(j,i) = 0;
                    pattern(j,i) = ~pattern(j,i);                            
                end
            end
        end
    case 4 %100
        for i = 1:tam
            for j = 1:tam
                if mod(floor((j-1)/2)+floor((i-1)/3),2) == 0 && forbidden(j,i) == 0
                    mask(j,i) = 0;
                    pattern(j,i) = ~pattern(j,i);                            
                end
            end
        end
    case 5 %101
        for i = 1:tam
            for j = 1:tam
                if (mod((i-1)*(j-1),2) + mod((i-1)*(j-1),3)) == 0 && forbidden(j,i) == 0
                    mask(j,i) = 0;
                    pattern(j,i) = ~pattern(j,i);                            
                end
            end
        end
    case 6 %110
        for i = 1:tam
            for j = 1:tam
                if mod(mod((i-1)*(j-1),2) + mod((i-1)*(j-1),3),2) == 0  && forbidden(j,i) == 0
                    mask(j,i) = 0;
                    pattern(j,i) = ~pattern(j,i);                            
                end
            end
        end
    case 7 %111
        for i = 1:tam
            for j = 1:tam
                if mod(mod((i-1)*(j-1),3) + mod((i-1)+(j-1),2),2)  == 0 && forbidden(j,i) == 0
                    mask(j,i) = 0;
                    pattern(j,i) = ~pattern(j,i);                            
                end
            end
        end
end

end
