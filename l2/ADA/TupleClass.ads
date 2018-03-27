with Ada.Unchecked_Deallocation; --pokiet potrzebny do zadeklarowani procedury zwalniajacej pamiec
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;



package TupleClass is



    type Tuple is record
        TID, LID, priority: integer;
    end record;



end TupleClass;
