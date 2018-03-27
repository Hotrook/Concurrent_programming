



package body Functions is



    function Minimum ( A, B: Integer) return Integer is
    begin
       if A <= B then
          return A;
       else
          return B;
       end if;
    end Minimum;



    procedure printFrost( toPrint : String; cond : Integer ) is
    begin
        if cond = 1 then
            Put_Line( toPrint );
        end if;
    end printFrost;



end Functions;
