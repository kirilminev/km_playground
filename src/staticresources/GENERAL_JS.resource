function formatPhone(a) {
    a.value = a.value.trim();  
    var b = a.value,
    c = "",  
    d = -1;  
    if (0 < b.length && "+" != b.charAt(0)){  
        var e = 0;  
        if("1" == b.charAt(0)){
          b = b.substring(1, b.length);  
        }
        for(i = 0; i < b.length; i++){  
            var f = b.charAt(i);  
            if(f >= "0" && f <= "9"){  
                if(e == 0) c += "(";  
                else if(e == 3) c += ") ";  
                else if(e == 6) c += "-";  
                c += f;  
                e++; 
            }  
            if(!(f >= "0" && f <= "9") && f != " " && f != "-" && f != "." && f != "(" && f != ")"){  
                d = i;  
                break; 
            }  
        }  
        if(d >= 0) c += " " + b.substring(d, b.length);  
        if(e == 10 && c.length <= 40) a.value = c;
    }  
    return true;
}