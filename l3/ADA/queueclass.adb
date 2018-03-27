

package body QueueClass is

    function isEmpty( Q : access Queue ) return Boolean is
    begin
        if Q.size = 0 then
            return True;
        else
            return False;
        end if;
    end isEmpty;




    procedure push( Q : access Queue; E : Integer ) is
    begin
        Q.size := Q.size + 1;
        Q.q( Q.stop ) := E;
        Q.stop := Q.stop + 1;
        if Q.stop > Q.capacity then
            Q.stop := 1 ;
        end if;
    end push;

    function pop( Q : access Queue ) return Integer is
        temp : Integer;
    begin
        if Q.size > 0 then
            Q.size := Q.size - 1;
            temp := Q.start;
            Q.start := Q.start + 1;

            if Q.start > Q.capacity then
                Q.start := 1;
            end if;

            return Q.q( temp );
        else
            return -1;
        end if;
    end pop;


end QueueClass;
