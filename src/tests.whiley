import compress from lz77::encoder
import decompress from lz77::decoder

method test_compress_01():
    assume compress([0b00]) == [0b01,0b01]

method test_compress_02():
    assume compress([0b00,0b01]) == [0b01,0b00,0b01,0b01]

method test_compress_03():
    assume compress([0b00,0b00,0b00]) == [0b11,0b00]

method test_compress_04():
    assume compress([0b00,0b00,0b00,0b01,0b01]) == [0b11,0b00,0b10,0b01]

method test_compress_05():
    assume compress([0b00,0b00,0b00,0b01,0b01,0b00,0b00]) == [0b11,0b00,0b10,0b01,0b10,0b00]

method test_decompress_01():
    assume decompress([0b11,0b00]) == [0b00,0b00,0b00]
