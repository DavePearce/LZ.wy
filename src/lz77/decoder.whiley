package lz77

/**
 * A simplistic implementation of the Lempel-Ziv 77 decompression.
 *
 * See: http://en.wikipedia.org/wiki/LZ77_and_LZ78
 */
import std::ascii
import std::filesystem
import std::integer
import std::io
import std::math
import nat from std::integer
import u8 from std::integer

// Decompress the given compressed bytestream.  This is done in a
// relatively naive fashion, whereby the entire generated stream is kept
// in memory.  In practice, only the sliding window needs to be kept in
// memory.
public function decompress(byte[] data) -> byte[]:
    byte[] output = [0b;0]
    nat pos = 0
    //
    while (pos+1) < |data| where pos >= 0:
        byte header = data[pos]
        byte item = data[pos+1]
        // NOTE: calculating offset here suboptimal as can test
        // directly against 00000000b, but helps verification as later
        // know that offset != 0.        
        u8 offset = integer::to_uint(header)
        pos = pos + 2 
        if offset == 0:
            output = append(output,item)
        else:
            u8 len = integer::to_uint(item)
            // NOTE: start >= 0 not guaranteed.  If negative, we have
            // error case and implementation proceeds producing junk.
            int start = |output| - offset
            int i = start
            // NOTE: i >= 0 required to handle case of start < 0 by
            // allowing implementation to proceed regardless.
            while i >= 0 && i < (start+len) where i < |output|:
                item = output[i]
                output = append(output,item)
                i = i + 1     
    // all done!
    return output


// NOTE: This is temporary and should be removed.  The reason is it
// required is that Whiley dropped support for the append operator
// "++" and, whilst append is implemented in std::array, this is only
// for int[] (i.e. as there are no generics at this time).
public function append(byte[] items, byte item) -> (byte[] ritems)
    ensures |ritems| == |items| + 1:
    //
    byte[] nitems = [0b; |items| + 1]
    int i = 0
    //
    while i < |items|
        where i >= 0 && i <= |items|
        where |nitems| == |items| + 1:
        //
        nitems[i] = items[i]
        i = i + 1
    //
    nitems[i] = item    
    //
    return nitems
