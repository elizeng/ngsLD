# ngsLD

`ngsLD` is a program to estimate pairwise linkage disequilibrium (LD) taking the uncertainty of genotype's assignation into account. It does so by avoiding genotype calling and using genotype likelihoods or posterior probabilities.

### Citation

`ngsLD` was published in 2015 at [Biological Journal of the Linnean Society](http://onlinelibrary.wiley.com/doi/10.1111/bij.12511/abstract), so please cite it if you use it in your work:

    Vieira FG, Lassalle F, Korneliussen TS, Fumagalli M
    Improving the estimation of genetic distances from Next-Generation Sequencing data
    Biological Journal of the Linnean Society (2015) doi: 10.1111/bij.12511

### Installation

`ngsLD` can be easily installed but has some external dependencies:

* `zlib`: v1.2.7 tested on Debian 7.8 (wheezy)
* `gsl` : v1.15 tested on Debian 7.8 (wheezy)
* `md5sum`: only needed for `make test`

To install the entire package just download the source code:

    % git clone https://github.com/fgvieira/ngsLD.git

To install these tools just run:

    % cd ngsLD
    % make
    % make test

Executables are built into the main directory. If you wish to clean all binaries and intermediate files:

    % make clean

### Usage

    % ./ngsLD [options] --geno glf/in/file --n_ind INT --n_sites INT --out_prefix output/file

#### Parameters
* `--geno FILE`: input file with genotypes, genotype likelihoods or genotype posterior probabilities.
* `--probs`: is the input genotype probabilities (likelihoods or posteriors)?
* `--log_scale`: is the input in log-scale?.
* `--n_ind INT`: sample size (number of individuals).
* `--n_sites INT`: total number of sites.
* `--pos` FILE: input file with site coordinates
* `--max_dist DOUBLE`: maximum distance between SNPs (in Kb) to calculate LD [100]
* `--min_r2`: minimum r^2 value to output [0.5]
* `--call_geno`: call genotypes before running analyses.
* `--N_thresh DOUBLE`: minimum threshold to consider site; missing data if otherwise (assumes -call_geno) 
* `--call_thresh DOUBLE`: minimum threshold to call genotype; left as is if otherwise (assumes -call_geno)
* `--out FILE`: output file name.
* `--n_threads INT`: number of threads to use. [1]
* `--version`: prints program version and exits.
* `--verbose INT`: selects verbosity level. [1]

### Input data
As input `ngsLD` needs a Genotype Likelihood (GL) file, formatted as __3\*n_ind\*n_sites__, either as gziped TSV or binary doubles.

### Thread pool
The thread pool	implementation was adapted from Mathias Brossard's and is freely available from:
https://github.com/mbrossard/threadpool
