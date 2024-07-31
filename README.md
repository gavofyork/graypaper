# Graypaper: The JAM Specification

The description and formal specification of the Jam protocol, a potential successor to the Polkadot Relay chain.

Build with xelatex.

https://graypaper.com/

## Remaining near-term

### Finesse
- [ ] Make all subscript names capitalized
- [ ] Ensure all definitions are referenced
- [ ] Link and integrate to Bandersnatch RingVRF references (Davide/Syed) IN-PROGRESS
- [ ] Remove any "TODOs" in text
- [ ] Macrofy everything
- [ ] Limit number of extrinsics in a WP.

### Final PVM
- [ ] 64-bit PVM
- [ ] Gas pricing
  - [ ] Merkle reads in terms of nodes traversed.
  - [ ] Non-linear gas for export/import host calls
- [ ] No pages mappable in first 64 KB

### Final DA
- [ ] Formalize as much as possible.
- [ ] Migrate formalization & explanation:
  - [ ] guaranteeing-specific stuff into relevant section
  - [ ] assurance-specific stuff into relevant section
  - [ ] auditing-specific stuff into relevant section
- [ ] Include an epochal on-chain lookup from Work Package hash to segments root.
  - [ ] Allow import spec to be given as either WP hash (in case of being recent) or segments root.
  - [ ] How can this work given that WP hash to segments-root needs to happen in-core?
- [ ] Define Erasure Coding proof means
  - [x] Define binary Merkle proof-generation function which compiles neighbours down to leaf.
  - [ ] Define binary Merkle proof-verification function exists sequence of values which contains our value and Merklised to some root.

### Guaranteeing & Auditing
- [ ] Guarantees by validator indices
- [ ] Specify announcement signatures
- [ ] Specify how to build perspective on other validators with announcements

### Discussion and Conclusions/Further Work
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
- [ ] Include full calculations for bandwidth requirements.

## Stuff before 1.0

### Final networking protocol
- [ ] Consider a simple network protocol needed for M1/M2 and a production protocol for M3+
- [ ] Block distribution via EC and proactive-chunk-redistribution
- [ ] Guarantor-guarantor handover
- [ ] Star-shaped Point-to-point extrinsic distribution
- [ ] Mixnet for ticket submission

## Bring together sub-protocols
- [ ] Better integration to Grandpa paper
- [ ] Better description of Beefy
- [ ] Better integration to Bandersnatch RingVRF.

## Ideas to consider

### Work Packages
At present all WorkItems can succeed or fail independently. Instead we should be able to specify co-dependency criteria, so that if one fails, both fail. This should be respected through to accumulation, whereby an accumulator can commit to accumulating the `WorkResult` iff there is a signal from the other accumulator that the result has been accumulated there.

### Statistics/Bookkeeping
- [ ] Consider integrating the subjective extrinsic and state:
  - [ ] If so, have three items to allow for a whole epoch of opinion submission
  - [ ] In which case allow for guaranteeing val keys from last epoch to gain points

### General
- [ ] Think about time and relationship between lookup-anchor block and import/export period.
  - [ ] Lookup anchor: maybe it should be 48 hours since lookup anchor can already be up to 24 hours after reporting and we want something available up to 24 hours after that?
- [ ] Refine arguments:
  - [ ] Currently passing in the WP hash, some WP fields and all manifest preimages: Consider passing in the whole work-package and a work-item index.
- [ ] Consider removal of the arrow-above notation in favour of subscript and ellipsis (this only works for the right-arrow).
- Optional `on_report` entry point
- Remove assignments from state - no need for it to be there as it's derivable from $\eta_2$ alone.
- Make memo bounded, rather than fixed.

## Done
- Statistics/Bookkeeping
  - [x] Integrate into intro and definitions.
- [x] All "where" and "let" lines are unnumbered/integrated
- DA2
  - [x] Update chunks/segments to new size of 12 bytes / 4KB in the availability sections, especially the work-packages and work-reports section and appendix H.
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
  - [x] Specification of final segments for DA and ER.
  - [x] Re-erasure-code imports.
  - [x] Fetching imports and verification.
- [x] Independent definition of PVM.
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
- [x] Updated PVM
- [x] Remove extrinsic segment root. Rename "* segment-root" to just "segment-root".
- [x] Combine chunk-root for WP, concatenated extrinsics and concatenated imports.
- [x] Imports are host-call
- [x] Make work-report field r bold.
- [x] Segmented DA v2
  - [x] Underlying EC doesn't change, need to make clear segments are just a double-EC
- [x] Make work-report field r bold.
- [x] Need to translate the basic work result into an "L"; do it in the appendix to ease layout
  - [x] service - easy
  - [x] service code hash - easy
  - [x] payload hash - easy
  - [x] gas prioritization - just from WP?
  - [x] Consider introducing a host-call for reading manifest data rather than always passing it in.
### ELVES
- [x] Don't immediately alter kappa mid-epoch as it affects off-chain judgements.
- [x] Instead, apply the blacklist to guarantor sig verification directly.
- [x] Include the core in the WR.
- [x] Deposit the WR's signatures in with the judgement.
- [x] Require at >= 1 negative judgements to be included with a positive verdict, and place signer in offender keys.
- [x] Serialization of judgement stuff
- [x] Should always be possible to submit more guarantee signatures of a known-bad report to place them in the offender set.
  - [x] Only from lambda and kappa?
- [x] Use posterior kappa for everything except judgements.

% A set of independent, sequential, asynchronously interacting 32-octet state machines each of whose transitions lasts around 2 seconds of webassembly computation if a predetermined and fixed program and whose transition arguments are 5 MB. While well-suited to the verification of substrate blockchains, it is otherwise quite limiting.
