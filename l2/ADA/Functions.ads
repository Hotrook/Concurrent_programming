
with Ada.Unchecked_Deallocation; --pokiet potrzebny do zadeklarowani procedury zwalniajacej pamiec
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Text_IO; use Ada.Text_IO;



package Functions is



    procedure printFrost( toPrint : String; cond : Integer );
    function Minimum( A, B : Integer ) return Integer;



end Functions;
