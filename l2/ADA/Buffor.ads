with Ada.Unchecked_Deallocation; --pokiet potrzebny do zadeklarowani procedury zwalniajacej pamiec
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with TupleClass; use TupleClass;


package Buffor is



    task type Bufor( N : Integer ) is
        entry Take( TID, LID, priority : in Integer);
        entry Give( TID, LID, priority : out Integer);
    end Bufor;




    type BuforPointer is access Bufor;
    type BuforPointerArray is array( Positive range <>) of BuforPointer;




end Buffor;
