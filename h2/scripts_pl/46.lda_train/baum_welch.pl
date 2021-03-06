#!/usr/bin/perl
## ====================================================================
##
## Copyright (c) 1996-2000 Carnegie Mellon University.  All rights
## reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
##
## 1. Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
##
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in
##    the documentation and/or other materials provided with the
##    distribution.
##
## This work was supported in part by funding from the Defense Advanced
## Research Projects Agency and the National Science Foundation of the
## United States of America, and the CMU Sphinx Speech Consortium.
##
## THIS SOFTWARE IS PROVIDED BY CARNEGIE MELLON UNIVERSITY ``AS IS'' AND
## ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
## THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
## PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL CARNEGIE MELLON UNIVERSITY
## NOR ITS EMPLOYEES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
## SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
## LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
## DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
## THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
## ====================================================================
##
## Author: Ricky Houghton
## Author: David Huggins-Daines
##

use strict;
use File::Copy;
use File::Basename;
use File::Spec::Functions;
use File::Path;

use lib catdir(dirname($0), updir(), 'lib');
use SphinxTrain::Config;
use SphinxTrain::Util;

#************************************************************************
# this script performs baum-welch training using
# it needs as inputs an initial set of models in s3 format
# a mdef file and cepstra with transcription files.
#************************************************************************

$| = 1; # Turn on autoflushing

die "USAGE: $0 <iter> <part> <npart> <fullvar>" if (@ARGV != 4);
my ($iter, $part, $npart, $fullvar) = @ARGV;

# Accumulate over the single-Gaussian tied models
my $modelinitialname="${ST::CFG_EXPTNAME}.cd_${ST::CFG_DIRLABEL}_initial";
my $modelname="${ST::CFG_EXPTNAME}.cd_${ST::CFG_DIRLABEL}_${ST::CFG_N_TIED_STATES}";
my $mdefname="${ST::CFG_EXPTNAME}.$ST::CFG_N_TIED_STATES.mdef";
my $processname = "46.lda_train";

my $output_buffer_dir = "$ST::CFG_BWACCUM_DIR/${ST::CFG_EXPTNAME}_buff_${part}";
mkdir ($output_buffer_dir,0777);

my ($hmm_dir, $var2pass);
if ($iter == 1) {
    $hmm_dir  = "$ST::CFG_BASE_DIR/model_parameters/$modelinitialname";
    $var2pass	 = "no";
} else {
    $hmm_dir      = "$ST::CFG_BASE_DIR/model_parameters/$modelname";
    $var2pass	  = "yes";
}

my $moddeffn    = "$ST::CFG_BASE_DIR/model_architecture/$mdefname";
my $statepdeffn = $ST::CFG_HMM_TYPE; # indicates the type of HMMs
my $mixwfn  = "$hmm_dir/mixture_weights";
my $mwfloor = 1e-5;
my $tpfloor = 1e-5;
my $tmatfn  = "$hmm_dir/transition_matrices";
my $meanfn  = "$hmm_dir/means";
my $varfn   = "$hmm_dir/variances";
my $minvar  = 1e-4;

my @extra_args;
if ($ST::CFG_CD_VITERBI eq 'yes') {
    push(@extra_args, -viterbi => 'yes');
}

# aligned transcripts and the list of aligned files is obtained as a result
# of (03.) forced alignment or (04.) VTLN
my ($listoffiles, $transcriptfile) = GetLists();

my $topn;
if ($ST::CFG_HMM_TYPE eq '.cont') {
    $topn = 1
} else {
    $topn = $ST::CFG_FINAL_NUM_DENSITIES;
}
my $logdir   = "$ST::CFG_LOG_DIR/$processname";
my $logfile  = "$logdir/${ST::CFG_EXPTNAME}.$iter-$part.bw.log";
mkdir ($logdir,0777);

my $ctl_counter = 0;
open INPUT,"<$listoffiles" or die "Failed to open $listoffiles: $!";
while (<INPUT>) {
    $ctl_counter++;
}
close INPUT;
$ctl_counter = int ($ctl_counter / $npart) if $npart;
$ctl_counter = 1 unless ($ctl_counter);

Log("Baum welch starting for LDA, iteration: $iter ($part of $npart)", 'result');

my $return_value = RunTool
    ('bw', $logfile, $ctl_counter,
     -moddeffn => $moddeffn,
     -ts2cbfn => $statepdeffn,
     -mixwfn => $mixwfn,
     -mwfloor => $mwfloor,
     -tpfloor => $tpfloor,
     -tmatfn => $tmatfn,
     -meanfn => $meanfn,
     -varfn => $varfn,
     -ltsoov => $ST::CFG_LTSOOV,
     -dictfn => $ST::CFG_DICTIONARY,
     -fdictfn => $ST::CFG_FILLERDICT,
     -ctlfn => $listoffiles,
     -part => $part,
     -npart => $npart,
     -cepdir => $ST::CFG_FEATFILES_DIR,
     -cepext => $ST::CFG_FEATFILE_EXTENSION,
     -lsnfn => $transcriptfile,
     -accumdir => $output_buffer_dir,
     -varfloor => $minvar,
     -topn => $topn,
     -abeam => 1e-90,
     -bbeam => 1e-10,
     -agc => $ST::CFG_AGC,
     -cmn => $ST::CFG_CMN,
     -varnorm => $ST::CFG_VARNORM,
     -meanreest => "yes",
     -varreest => "yes",
     '-2passvar' => $var2pass,
     -fullvar => $fullvar,
     -diagfull => $fullvar,
     -feat => $ST::CFG_FEATURE,
     -ceplen => $ST::CFG_VECTOR_LENGTH,
     @extra_args,
     -timing => "no");


if ($return_value) {
  LogError("Failed to start bw");
}
exit ($return_value);
