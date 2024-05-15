function res = hsTest(image, i, j, Ip, t, rowCoord, colCoord)

    check1darker = image(i - rowCoord(1,1), j + colCoord(1,1)) < (Ip - t);
    check9darker = image(i - rowCoord(9,1), j + colCoord(9,1)) < (Ip - t);
    check1brighter = image(i - rowCoord(1,1), j + colCoord(1,1)) > (Ip + t);
    check9brighter = image(i - rowCoord(9,1), j + colCoord(9,1)) > (Ip + t);

    check1 = ~check1darker && ~check1brighter;
    check9 = ~check9darker && ~check9brighter;
    
    if check1 && check9 %pixels 1 and 9 are close to p's intensity, so p isn't a corner
        res = 0;
    else %it could be corner, check that 3 pixels are contrasting Ip
        check5darker = image(i - rowCoord(5,1), j + colCoord(5,1)) < (Ip - t);
        check13darker = image(i - rowCoord(13,1), j + colCoord(13,1)) < (Ip - t);
        check5brighter = image(i - rowCoord(5,1), j + colCoord(5,1)) > (Ip + t);
        check13brighter = image(i - rowCoord(13,1), j + colCoord(13,1)) > (Ip + t);
        check5 = ~check5darker && ~check5brighter;
        check13 = ~check13darker && ~check13brighter;
        

        if (check1+check9+check5+check13) < 2
            res = 1;
        else
            res = 0;
        end
%         if check1darker && check9darker
%             res = xor(check5darker, check13darker);
%         elseif check1brighter && check9brighter
%             res = xor(check5brighter, check13brighter);
%         elseif (check1brighter && check9darker) || (check1darker && check9brighter)
%             res = (check5brighter && check13brighter) || (check5darker && check13darker);
%         elseif xor(check1brighter, check9brighter)
%             res = check5brighter && check13brighter;
%         elseif xor(check1darker, check9darker)
%             res = check5darker && check13darker;
%         else
%             res = 0;
%         end
    end
end