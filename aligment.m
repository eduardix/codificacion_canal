function indice = aligment(tam)
    indice = zeros(tam);
    indice(10,10:21) = [154 153 120 119 74 73 72 71 26 25 24 23];
    
    for i=10:20
        indice(i+1,10:11) = indice(i,10:11) + 2;
        indice(i+1,14:15) = indice(i,14:15) + 2;
        indice(i+1,18:19) = indice(i,18:19) + 2;
        indice(i+1,12:13) = indice(i,12:13) - 2;
        indice(i+1,16:17) = indice(i,16:17) - 2;
        indice(i+1,20:21) = indice(i,20:21) - 2;        
    end
    
    indice(8,10:13) = [150 149 124 123];
    indice(9,10:13) = [152 151 122 121];
    
    indice(10:13,8:9) = [184 183;182 181;180 179;178 177];
    
    indice(1,10:13) = [138 137 136 135];
    for i=1:5
       indice(i+1,10:11) = indice(i,10:11) + 2; 
       indice(i+1,12:13) = indice(i,12:13) - 2;
    end
    
    indice(10,1:6) = [202 201 200 199 186 185];
    
    for i=10:12
        indice(i+1,1:2) = indice(i,1:2) + 2; 
        indice(i+1,5:6) = indice(i,5:6) + 2;
        indice(i+1,3:4) = indice(i,3:4) - 2;
    end
end