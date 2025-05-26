// Wang hash – 32 bit integer → 32 bit integer
uint wangHash(inout uint seed) {
    seed = (seed ^ 61u) ^ (seed >> 16);
    seed *= 9u; seed = seed ^ (seed >> 4);
    seed *= 0x27d4eb2du; seed = seed ^ (seed >> 15);
    return seed;
}

float rand01(inout uint seed) { return float(wangHash(seed)) / 4294967296.0; }
