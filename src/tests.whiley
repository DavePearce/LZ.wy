import compress from lz77::encoder
import decompress from lz77::decoder

method test_01():
    assume compress([0b00,0b00,0b00]) == [0b11,0b00]


public export method main():
    test_01()


function broken(int i) -> (int r)
ensures r >= 0:
    return i