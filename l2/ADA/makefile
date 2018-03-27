#
# Nazwy plikow *.adb, ktore wchodza do projektu
#
SRCS = z1ada.adb Buffor.adb DataClass.adb Functions.adb  TupleClass.adb types.adb LineClass.adb SwitchTaskClass.adb ReadFunctions.adb QueueClass.adb

#
# Nazwy plikow posrednich *.o
#
OBJS = z1ada.o types.o
#
# Nazwa pliku wynikowego
#
PROGRAM =	z1

$(PROGRAM):     $(SRCS)
		gnatmake  $(SRCS)
		@echo napisz: $(PROGRAM) aby uruchomic.


clean:
	rm  -f *.ali *.o $(PROGRAM) *~
