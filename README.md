# Graypaper: The JAM Specification

The description and formal specification of the Jam protocol, a potential successor to the Polkadot Relay chain.

Build with xelatex.

## DA2

### 4K reconstruction size to allow for some optimization
  - Every 4K byte segment is inflated to 12K and then split into 1024 * 12 byte chunks of which 342 are needed.
  - The ensures that SIMD can be utilized when coding/reconstructing.

### Guarantor makes imports additionally available for 8 hours

This means the same data is in DA - one long-term and one short-term. Guarantor is expected to fetch from long-term and re-encode into short-term. Auditors only need reconstruct.

In order to ensure that data fetched and made re-available by a guarantor is correct, exported/extrinsic data is hashed and Merklized and a commitment stored in the WR. The paginated hashes which form a 64-entry discrete sub-tree, together with a justification to the commitment are placed in DA as additional segments alongside the extrinsic and export segments. These segments are referenced and distributed in the same way as regular segments in the overall erasure-coding root.

In order to ensure sub-trees are generally 64-entries, the binary Merkle tree is biased in a manner reminiscent of depth-first; all leaves are thus of depth $\lceil \log_2(s) \rceil$ where $s$ is the number of regular segments. Non-existent segments are represented by the null-hash.

Segments from export and segments from extrinsic are kept separate, both in the erasure root and in the segment trees. Two separate segment tree roots are stored in the WR alongside the erasure root.

Validator count $V = 1023$
Segment size $S = 4096$
Signature size $G = 128$
Segment-chunk proof size $P_C = 32 * \lceil\log_2(V)\rceil+\lceil\log_2(|E| + |X|)\rceil = 702$ B
Segment proof size $P = P_C\lceil\frac{V}{3}\rceil \approx 240$ KB

$W$: **Package size**; e.g. $S$
$X$: **Extrinsic**; e.g. $|X| = 1024, \sum X = |X|S$ MB
$E$: **Export**; e.g. $|E| = 2048, \sum E = |E|S$ MB
$I$: **Import**; $|I| = 2048, \sum I = |I|S$ MB

Export Merkle path is validator index to two roots and two chunks:
- WP chunk (only used for audits - kept for 8h)
- imports chunk (no need for separating by segment as not re-exported - segment-proof included to allow justification of data from manifest; only used for audits and kept for 8h)
- extrinsic segments chunks-root (segments are always kept for 28d)
- export segments chunks-root (segments are always kept for 28d)

This ensures that proof distribution need only cover a single proof per validator to these 4 hashes.

Imports chunk is a concatenation of all imported segments ordered as in manifest with each non-duplicate proof-segment in same order following. When passing imports into `refine`, only the work item's concatenated imports are exposed.

For all WPs in DA we store all chunks together with proof to our 4 hashes. This allows a proof to any individual chunk to be constructed as needed:
Overhead per WP is: $D = 32 * \lceil\log_2(V)\rceil = 320$ B.

WP includes manifest:
- imports: $\mathbf{i} \in [(\mathbb{H}, \mathbb{N})]$ (the segment-tree root and index into it)
- extrinsics: $\mathbf{x} \in [\mathbb{Y}]$
- exports: $\mathbf{e} \in [\mathbb{N}]$ (maximum number of exports per work item, $|\mathbf{x}| + \sum \mathbf{e} \le 3*1024$)

TODO: Consider: All segments lengths (as multiples of $S$) are placed in WR (1 byte each). TODO: Consider placing in DA instead, commitment in WR. TODO: Is this really needed? We have our chunk which is committed to and it therefore must be of a particular length; and we know the segment is a multiple of 4K.

- Guaranteeing:
  - receive: $\sum I + \frac{1}{3}GV$ (reconstructed, optimistic; $VP$ for any segments whose reconstructed root doesn't match, max $|I|VP$; in such cases, slashing happens)
  - send: $\frac{1}{2}((\sum I + \sum X + \sum E + W) * 3 + VD)$
- Availability:
  - send (imports, to guarantors, ex. proof): $\sum I + \frac{1}{3}GV$ (opt: $\frac{1}{3}(I+GV)$)
  - receive (from guarantors inc. proof): $\sum I + \sum X + \sum E + W + \frac{1}{3}DV$
  - send (for auditing, inc. proof): $10 * (\sum X + \sum I + W + 32 + D)$
- Auditing:
  - receive (inc. proof): $10 * (\sum X + \sum I + W + 32 + D)$

- LT-DA per val per block:
  - $\sum X + \sum E + W + \frac{1}{3}V(D + 32)$ (extra 32 is the imports hash, which we must store for proof construction even after imports data is discarded)
    - e.g. $28 * 24 * 600 * (12\text{ MB} + 341 * 352) = 5.1$ TB (individual segments must be individually reconstructable, so proof and spec stored for each)
- ST-DA per val per block:
  - $\sum I$ MB
    - e.g. $12 * 600 * 8\text{ MB} = 57.6$ GB
- Total items in LT-DA: $T = 28*24*600*341*3*1024*32$

Total DA/val: 5.2 TB
Send:
- per 6s: $((\sum I + \sum X + \sum E + W) * 3 + VD) / 2 + \sum I + \frac{1}{3}GV + 10 * (\sum X + \sum I + W + 32 + D) = 12.5 \sum I + 11.5(\sum X + W) + \frac{3}{2}\sum E + \frac{1}{2}VD + \frac{1}{3}GV + 10D + 320$
- e.g. 12.5 * 8 MB + 11.5 * 4 MB + 1.5 * 8 MB + 220KB = 158 MB/6s = 26MB/s = 210 Mbps + K
Receive:
- per 6s: $\sum I + \frac{1}{3}GV + \sum I + \sum X + \sum E + W + \frac{1}{3}VD + 10 * (\sum X + \sum I + W + 32 + D) = 12\sum I + 11(\sum X + W) + \sum E + \frac{1}{3}VD + \frac{1}{3}GV + 10D + 320$
- e.g. 12 * 8 MB + 11 * 4 MB + 8 MB + 170KB = 148 MB/6s = 25MB/s = 200 Mbps


## Constraints

$12(\sum I + \sum X + W) + \frac{3}{2}\sum E < 160$ MB

$X + \sum E + \sum I + |I|\cdot P \le 15$ MB
$|X| + |E| \le 4096$



TODO: Consider VRF proof when requesting chunk so validators are equally responsible.

## Remaining for v0.1

### Content
- [ ] Rewards.
- [ ] Consider removal of the arrow-above notation in favour of subscript and ellipsis (this only works for the right-arrow).
- [ ] Think about time and relationship between lookup-anchor block and import/export period.
- [ ] Make work report field r bold.
- [ ] Refine arguments
  -  Currently passing in the WP hash, some WP fields and all manifest preimages.
  - [ ] Consider passing in the whole work-package and a work-item index.
  - [ ] Consider passing in the work-item.
  - [ ] Consider introducing a host-call for reading manifest data rather than always passing it in.
- [ ] Segmented DA v2
  - [ ] Include full calculations for bandwidth requirements.
  - [ ] Update chunks/segments to new size of 12 bytes / 4KB in the availability sections, especially the work packages and work reports section and appendix H.
  - [x] `export` is in multiples of 4096 bytes.
  - [x] Manifest specifies WI (maximum) export count.
  - [x] `import` is provided as concatenated segments of 4096 bytes, as per manifest.
  - [x] Constant-depth merkle root
  - [x] (Partial) Merkle proof generation function
  - [x] New erasure root (4 items per validator; 2 hashes + 2 roots).
  - [x] Specification of import hash (to include concatenated import data and proof).
    - [x] Proof spec.
    - [x] Specification of segment root.
  - [x] Additional two segment-roots in WR.
    - [x] Specification of segment tree.
  - [x] Specification of segment proofs.
  - [ ] Specification of final segments for DA and ER.
  - [ ] Re-erasure-code imports.
  - [x] Fetching imports and verification.
  - [ ] Migrate formalization & explanation:
    - [ ] guaranteeing-specific stuff into relevant section
    - [ ] assurance-specific stuff into relevant section
    - [ ] auditing-specific stuff into relevant section
  - [ ] Formalize as much as possible.
- [ ] Segmented DA v1
  - [x] Include manifest distribution in bandwidth: 511 * 2048 * 36 = 36 MB / 6s = 6 MB/s = 48Mbps
  - [ ] Amalgamate manifest distribution limit into bandwidth limit.
    - [ ] base = (15MB * 3 + proof_size * 1022) / 2 = 22.66 MB
    - [ ] per_provision = (size * 3 + proof_size * 1022)/2 + 68
    - [ ] 1024 provisions: 160 MB/WP proof / 6s = 27MB/s = 220Mbps
    - proof_size = 32 * 10 = 320.
  - [ ] Limit number of exports, not just size.
  - [ ] Ensure the 2048 is a limit for total manifest entries (import, extrinsic, export).
  - [ ] Remove the regular hash from manifests.
    - [ ] In doing so will need to properly consider how to reconstruct the WP for auditing.
  - [x] `export` host-call for Refine
  - [x] `imports` argument for Refine
  - [x] `require_root` in Work Result
  - [x] `provide_root` in Work Result
  - [x] `imports` in Work Package
  - [x] `extrinsics` in Work Package
  - [x] Guarantor task
    - [x] Ensure length of imports + WP <= 15MB, imports_count <= 2048
    - [x] Fetch/reconstruct all Imports
    - After execution:
    - [x] Disregard `export`s which would take length exports + WP > 15MB or exports_count > 2048
    - [x] Erasure-code all Extrinsic & Exports
    - [x] Distribute chunks of all Extrinsic & Exports
    - [x] Merklize erasure-roots to create WR `manifest_root`
  - [x] Assurer task
    - [x] Check receipt of WP and exports, as well as prescience of imports preimages, allowing computation of WR's `manifest_root` from first-principles.
  - [ ] Properly detail auditor verification task
    - [ ] Fetch/reconstuct WP
    - [ ] Ensure length of imports + extrinsics + WP <= 15MB (assurer-upload/auditor-download)
    - [ ] Ensure |imports| + |extrinsics| + |exports| <= 2048 (manifest distribution)
    - [ ] Fetch/reconstruct imports
      - Trivial since the import manifest contains erasure roots
    - [ ] Fetch/reconstruct extrinsics
      - Harder since WP contains extrinsic hash, but assurers only know by erasure-root.
      - Option 1: download the manifest and cross-reference - an extra ~136KB.
      - Option 2: include erasure roots in the WP's extrinsic spec - extra work for author
    - [ ] Erasure-code all extrinsics
    - After execution:
    - [ ] Ensure length of WP + extrinsics + exports <= 15MB (guarantor-upload/assurer-download)
    - [ ] Disregard `export`s which would take total length exports + WP > 15MB or exports_count > 2048
    - [ ] Erasure-code each export
    - [ ] Merklize WP imports field to verify WR `requires_root`
    - [ ] Merklize erasure-coded {extrinsics, exports} to verify WR `providers_root`
- [ ] Think about time and relationship between lookup-anchor block and import/export period.
- [ ] Make work report field r bold.
- [x] Need to translate the basic work result into an "L"; do it in the appendix to ease layout
  - [x] service - easy
  - [x] service code hash - easy
  - [x] payload hash - easy
  - [x] gas prioritization - just from WP?
- [ ] Refine arguments
  -  Currently passing in the WP hash, some WP fields and all manifest preimages.
  - [ ] Consider passing in the whole work-package and a work-item index.
  - [ ] Consider introducing a host-call for reading manifest data rather than always passing it in.

### Finesse
- [ ] Make all subscript names capitalized.
- [ ] Ensure all definitions are referenced.
- [ ] Link and integrate to Bandersnatch RingVRF references (Davide/Syed) IN-PROGRESS
- [ ] All "where" and "let" lines are unnumbered/integrated
- [ ] Remove any "TODOs" in text

## Remaining for v0.2
- [ ] Define Erasure Coding proof means
  - [ ] Define binary Merkle proof-generation function which compiles neighbours down to leaf.
  - [ ] Define binary Merkle proof-verification function exists sequence of values which contains our value and Merklised to some root.
- [ ] Improve audit spec
  - [ ] Announcement signatures
  - [ ] How to build perspective on other validators with announcements
- [ ] Discussion and Conclusions/Further Work
  - [x] Security assumptions: redirect to ELVES paper
  - [ ] Creating a parachains service: further work (RFC for upgrade perhaps)
    - [ ] Key differences
      - [ ] limited size of Work Output vs unlimited candidate receipt
      - [ ] Laissez-faire on Work Items vs requirement for valid transition
      - [ ] Hermit relay (staking &c is on system chains)
    - [ ] Supporting liveness
    - [ ] Supporting *MP
    - [ ] No need for UMP/DMP
  - [ ] Compare with danksharding v1
  - [ ] Deeper talk Cost & latency comparison with RISC0-VM and latest ZK stuff.

## Stuff to replicate to PolkaJam

- Beefy root and accumulate-result hash.
- Judgements
- Using posterior assignments.

## Ideas to consider

- optional `on_report` entry point
- Remove assignments from state - no need for it to be there as it's derivable from $\eta_2$ alone.
- Work Package should be Merklized on pre-stated boundary points.
  - Add BoundedVec<(ServiceId, u32, u32), MAX_POINTS> to WorkPackage
  - Construct Merkle trie for Work Package and put root in IsAuthorized
- Think harder about if the recent blocks, availability timeouts & anchor stuff is affected by using timeslot rather than height.
- Make memo bounded, rather than fixed.
- Lookup anchor: maybe it should be 48 hours since lookup anchor can already be up to 24 hours after reporting and we want something available up to 24 hours after that?

## Additional work
- [ ] Proper gas schedule.
- [ ] Networking protocol.
- [ ] Off-chain sub-protocols:
  - [ ] Better integration to Grandpa
  - [ ] Better description of Beefy
- [ ] Full definition of Bandersnatch RingVRF.
- [x] Independent definition of PVM.
- [ ] PVM:
  - [ ] Aux registers?
  - [ ] Move to 64-bit?
  - [ ] No pages mappable in first 64 KB 

% No persistent distance between parts as in eth, cos, dot etc

% A set of independent, sequential, asynchronously interacting 32-octet state machines each of whose transitions lasts around 2 seconds of webassembly computation if a predetermined and fixed program and whose transition arguments are 5 MB. While well-suited to the verification of substrate blockchains, it is otherwise quite limiting.



## Done

### Texty
- [x] Need to translate the basic work result into an "L"; do it in the appendix to ease layout
  - [x] service - easy
  - [x] service code hash - easy
  - [x] payload hash - easy
  - [x] gas prioritization - just from WP?
- [x] Edit Previous Work.
- [x] Edit Discussion.
- [x] Document guide at beginning.
- [x] Move constants to appendix and define at first use.
- [x] Context strings for all signatures.
  - [x] List of all context strings in definitions.
- [x] Remove header items from ST dependency graph where possible.
- [x] Update serialization
  - [x] For $\beta$ component $b$ - implement MMR encode.
  - [x] Additional field: $\rho_g$
- [x] Link and integrate to RISCV references (Jan) HAVE SPEC
- [x] Link and integrate to Beefy signing spec (Syed)
- [x] Link and integrate to Erasure-Coding references (work with Al)
- [x] Grandpa/best-block: Disregard blocks which we believe are equivocated unless finalized.
- [x] Other PVM work
  - [x] Define `sbrk` properly:
  - [x] Update host functions to agreed API.
  - [x] Figure out what to do with the jump table.
- [x] Define inner PVM host-calls
  - [x] Spec below
  - [x] Figure out what the $c_i$/$c_b$ are
  - [x] Avoid entry point
  - [x] Ensure code and jump-table is amalgamated down to VM-spec
  - [x] Move host calls to use register index
- [x] Update serialization for Judgement extrinsic and judgements state.
- [x] Define Beefy process
  - [x] Accumulate: should return Beefy service hash
  - [x] Define Keccak hash $\mathbb{H}_K$
  - [x] Remove Beefy root from header
  - [x] Put the Beefy root into recent blocks after computation
  - [x] Recent blocks should store MMR of roots of tree of accumulated service hashes
  - [x] Define an MMR
  - [x] Add \textsc{bls} public key to keyset (48 octet).
  - [x] Specify requirement of validators to sign.
- [x] Define audit process.
  - [x] Erasure coding root must be correct
  - [x] This means we cannot assume that the WP hash can be inverted.
  - [x] Instead, we assume that we can collect 1/3 chunks and combine to produce *some* data
  - [x] Then we check:
    - [x] if that hashes to the WP hash.
    - [x] if the erasure-coded chunks merklise into a tree of the given root.
  - [x] If so we continue.
  - [x] NOTE: The above should be done in guarantor stage also.
- [x] Auditing: Always finish once announced.
- [x] Judgements: Should cancel work-report from Rho prior to accumulation.
- [x] Signed judgements should not include guarantor keys;
  - [x] Judgement extrinsic should use from rho.
- [x] Check "Which History" section and ensure it mentions possibility for reversion via judgement.
  - [x] No reversion beyond finalized
  - [x] Of unfinalized extension, not block containing work-reports which appear in the banned-set of any other (valid) block.
- [x] Prior work and refine/remove the zk argumentation (work with Al)
- [x] Disputes state transitioning and extrinsic (work with Al)
- [x] Finish Merklization description
- [x] Bibliography
