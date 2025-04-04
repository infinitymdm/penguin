## SHA-3 Keccak Implementation

The files in this folder implement a SHA-3 compatible Keccak sponge function. This implementation
is designed to be flexible, with a configurable multicycle structure that can be easily set up for
any SHA-3 digest length.

### Testing

The easiest way to test this design is to run the testbench at
[tb/tb_sha3.sv](https://github.com/infinitymdm/penguin/blob/main/tb/tb_sha3_openssl.sv). Note that the
testbench checks its answers against `openssl`. You'll want to make sure you have that installed
(in addition to the usual prerequisites mentioned in
[the README](https://github.com/infinitymdm/penguin/tree/main?tab=readme-ov-file)).

Run the OpenSSL testbench like so:

```bash
just verilate tb_sha3_openssl +define+DIGEST_LENGTH=512+STAGES=6+MESSAGE_FILE=README.md
```

Feel free to use different values for the three `define`s. Valid values are:
- `DIGEST_LENGTH`: 512, 384, 256, 224 (per SHA-3 spec)
- `STAGES`: 1, 2, 3, 4, 6, 8, 12, 24
- `MESSAGE_FILE`: a relative path to any file from the repository root directory

If you try to run the testbench without one of those defines, you'll get an error complaining about
it. Hopefully those are pretty self-explanatory.

You can also simulate against the NIST byte-oriented test vectors by running

```bash
just verilate tb_sha3_nist +define+DIGEST_LENGTH=512+STAGES=6+MESSAGE_FILE=tb/SHA3_512LongMsg.rsp
```

Only the 512-bit .rsp files are included, but the rest can be obtained from NIST
[here](https://csrc.nist.gov/Projects/Cryptographic-Algorithm-Validation-Program/Secure-Hashing).

Last but not least, if you want to use Questa/ModelSim instead of verilator, just swap to the
`questasim` recipe. You can even use the same format for the defines, and this works with either
testbench.

```bash
just questasim tb_sha3_nist +define+DIGEST_LENGTH=512+STAGES=6+MESSAGE_FILE=tb/SHA3_512LongMsg.rsp
```

That said, Verilator massively outperforms Questa/ModelSim here. In my testing, Questa 2024.3 took
about 14 minutes to run through the NIST long messages, while Verilator was done compiling and
simulating in under 10 seconds. Given the performance difference, I highly recommend using the
Verilator flows!
