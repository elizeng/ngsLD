#pragma once

#include <gsl/gsl_statistics.h>
#include "read_data.hpp"
#include "threadpool.h"

extern bool SIG_COND;

// Struct to store all input arguments
typedef struct {
  char *in_geno;
  bool in_bin;
  bool in_probs;
  bool in_logscale;
  uint64_t n_ind;
  uint64_t n_sites;
  char *pos;
  double max_dist;
  bool call_geno;
  double N_thresh;
  double call_thresh;
  char *out;
  FILE *out_fh;
  uint n_threads;
  bool version;
  uint verbose;

  double ***in_geno_lkl;  // n_ind * n_sites+1 * N_GENO
  char **labels;          // n_sites+1
  double *pos_dist;       // n_sites+1

  double** geno_lkl;      // n_sites+1 * (n_ind * N_GENO)
  double** expected_geno; // n_ind * n_sites+1

  threadpool_t *thread_pool;
} params;

// Pthread structure
typedef struct {
  params *pars;
  uint64_t site;
} pth_struct;

// parse_args.cpp
void init_pars(params* );
void parse_cmd_args(params*, int, char**);


void calc_pair_LD (void*);
double pearson_r (double*, double*, uint64_t);
double bcf_pair_LD (double*, double*, uint64_t);
int pair_freq_iter(int, double*, double*, double*);
double est_freq(int, const double*);
