import sys, struct

src, dst = sys.argv[1], sys.argv[2]
data = open(src, 'rb').read()
if len(data) % 4:
    data += b'\x00' * (4 - len(data) % 4)
with open(dst, 'w') as f:
    for i in range(0, len(data), 4):
        (w,) = struct.unpack('<I', data[i:i+4])
        f.write('%08x\n' % w)
print('%s: %d words' % (dst, len(data) // 4))
