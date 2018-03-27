
package Types is
    type Int_Array is array (Positive range <>) of Integer;
    type Int_Array2 is array( Positive range <>, Positive range <>) of Integer;
    type IntPointer is access Integer;
    type IntPointerArray is array( Positive range <> ) of IntPointer;
    type BREAK_TYPE is (SWITCH, LINE, TRAIN );
end Types;
