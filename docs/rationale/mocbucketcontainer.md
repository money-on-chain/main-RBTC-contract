# MoCBucketContainer

- Referenced by: MocBproxManager
- References/uses: SafeMath, Math
- Inherits from: MocBase

Defines the structure of a bucket and implements various utility methods related to said structure.
- State:
  - MoC Buckets: Mapping of named buckets. Despite currently having just two (`C0` & `X2`), this is expected to grow in the future and even be dynamically modified.
    `mapping(string => MoCBucket) internal mocBuckets;`
