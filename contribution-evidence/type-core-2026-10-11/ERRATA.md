# Historical report count clarification

The preserved historical qualification report labels 12,400 as `compilerCorpus.sourceFiles`. This counted only `.ts` files (6,701 compiler and 5,699 conformance). It did not include the additional 349 `.tsx` and 2 `.js` files present in those directories, so it must not be described as the total number of corpus input files or executed cases. The physical directory total is 12,751 files; physical files and runner case/configuration keys are different quantities.

Likewise `transpile.sourceFiles: 24` counted only `.ts`; the directory also contains one `.tsx` file, for 25 physical inputs.

The directly verified execution totals remain 13,468 compiled configurations, 133,390 passing checks and 1,728 explicit skips, plus 41 passing transpile checks. No source-file total is used as evidence of complete test coverage in these PRs. Historical report bytes and hashes are preserved so prior records remain verifiable.
