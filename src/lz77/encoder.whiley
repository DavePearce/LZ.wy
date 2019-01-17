package lz77

/**
 * A simplistic implementation of the Lempel-Ziv 77 compression.
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

// Compress a given byte stream to produce a potentially shorter
// stream.  The resulting stream can be viewed as sequence of pairs of
// the form either (offset,length) or (offset,value).  In the latter,
// offset == 0 and the value is just emitted at that position in
// stream.  For the former case, the offset refers to a prior position in
// the stream from which len bytes are copied to the current position.
// For example, consider this simple sequence: (0,'a')(0,'b')(0,'c')(3,2).
// After processing the first pair we have "a", after the second pair "ab",
// after the third pair "abc" and, finally, after the last pair "abcab".
// Observe the sequence (0,'a')(1,3) makes sense and produces "aaaa".
// 
// As a more complex example, consider this
// 
//     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//     |T|h|i|s| |i|s| |h|i|s| |m|e|s|s|a|g|e|
//     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8
//
// The encoding of this would begin:
//
// (0,'T')(0,'h')(0,'i')(0,'s')(0,' ')(1,3)(7,4) ...
//
// Here, we see the second occurrence "is " is matched against the
// previous occurrence, and likewise for "his ".
function compress(byte[] data) -> byte[]:
    nat pos = 0
    byte[] output = [0b; 0]
    //
    // keep going until all data matched
    while pos < |data| where pos >= 0:
        int offset
        int len
        offset,len = findLongestMatch(data,pos)
        output = write_u8(output,offset)
        if offset == 0:
            output = append(output,data[pos])
            pos = pos + 1
        else:
            output = write_u8(output,len)
            pos = pos + len
    // done!
    return output

// Find longest match in bytestream window for data beginning at pos.
// The window size is fixed at 255 bytes in this case.  The algorithm
// traverses each byte in this window measuring the match size at that
// point, and recording the winner.  The result is the highest matched
// byte and the length of the match at that point.  For example,
// consider this:
// 
//     +-+-+-+-+-+-+-+-+
//     |T|h|i|s| |i|s| | ...
//     +-+-+-+-+-+-+-+-+
//      0 1 2 3 4 5 6 7 
//
// Suppose we're currently at position 5.  To find the longest match,
// we go back to the beginning of the window, or the start of the
// stream (whichever is closest).  Then we iterate forward, trying to
// match.  For example, 'T' won't match with 'i' so we proceed.
// Eventually, we get to index 2, and we match the prefix "is ".  Thus,
// the algorithm returns (2,3).
//
// Finally, observe that we won't find matches at every position.  For
// example, at position 7 we won't find a match for 'v' in the window.
// In such cases, we just return (0,0) to signal no match.
function findLongestMatch(byte[] data, nat pos) -> (u8 offset, u8 length):
    //
    u8 bestOffset = 0
    u8 bestLen = 0
    // Initialise index to start of sliding window, or start of stream.
    nat index = math::max(pos - 255,0)
    //
    while index < pos where (pos - index) <= 255:
        //
        int len = match(data,index,pos)
        if len > bestLen:
            bestOffset = pos - index
            bestLen = len
        index = index + 1
    //
    return bestOffset,bestLen

// Return largest match of two positions in the stream.  For example,
// suppose two positions like this:
//
//     +-+-+-+-+-+-+-+-+
//     |T|h|i|s| |i|s| | ...
//     +-+-+-+-+-+-+-+-+
//          ^     ^
//
// The algorithm moves each forward until it finds the first non-match
// character (or we reach the end).  It then returns the length of the
// match (which in this would be three).
function match(byte[] data, nat offset, nat end) -> (int length)
// Position to search from within sliding window
requires (end - offset) <= 255
// Returned match size cannot exceed sliding window
ensures 0 <= length && length <= 255:
    //
    nat pos = end
    u8 len = 0
    //
    while offset < pos && pos < |data| && data[offset] == data[pos] && len < 255:
        //
        offset = offset + 1
        pos = pos + 1
        len = len + 1
    //
    return len

function write_u8(byte[] bytes, u8 u1) -> byte[]:
    //
    return append(bytes,integer::to_unsigned_byte(u1))


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

