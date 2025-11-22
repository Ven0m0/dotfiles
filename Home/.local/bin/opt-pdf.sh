#! /usr/bin/bash
# vim: set filetype=bash:

# opt-pdf: Recompresses .pdf files using Ghostscript or Poppler

# Copyright (C) 2013-2024 by Brian Lindholm.  This file is part of the
# littleutils utility set.
#
# The opt-pdf utility is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later version.
#
# The opt-pdf utility is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# the littleutils.  If not, see <https://www.gnu.org/licenses/>.

# get command-line options
BACKUP='n'
COLORDPI=''
FORCE='n'
GRAYDPI=''
MONODPI=''
QUIETFLAG='-q'
TOUCH='n'
VERBOSE='y'
WEBOPT='n'
while getopts bc:fg:hm:oqtv opts ; do
  case $opts in
    b) BACKUP='y' ;;
    c) COLORDPI="-dAutoFilterColorImages=false -dColorImageResolution=$OPTARG -dColorImageDownsampleType=/Bicubic" ;;
    f) FORCE='y' ;;
    g) GRAYDPI="-dAutoFilterGrayImages=false -dGrayImageResolution=$OPTARG -dGrayImageDownsampleType=/Bicubic" ;;
    h) echo 'opt-pdf 1.2.7'
       echo 'usage: opt-pdf [-b(ackup)] [-c(olor) DPI] [-f(orce_overwrite)]'
       echo '         [-g(rayscale) DPI] [-h(elp)] [-m(onochrome) DPI] [-t(ouch)]'
       echo '         [-o(ptimize_for_web)] [-q(uiet)] [-v(erbose)] PDF_filename ...'
       exit 0 ;;
    m) MONODPI="-dAutoFilterMonoImages=false -dMonoImageResolution=$OPTARG -dMonoImageDownsampleType=/Bicubic" ;;
    o) WEBOPT='y' ;;
    q) VERBOSE='n' ;;
    t) TOUCH='y' ;;
    v) QUIETFLAG='' ;;
    *) echo 'opt-pdf 1.2.7'
       echo 'usage: opt-pdf [-b(ackup)] [-c(olor) DPI] [-f(orce_overwrite)]'
       echo '         [-g(rayscale) DPI] [-h(elp)] [-m(onochrome) DPI] [-t(ouch)]'
       echo '         [-o(ptimize_for_web)] [-q(uiet)] [-v(erbose)] PDF_filename ...'
       exit 1 ;;
  esac
done
shift $((${OPTIND}-1))

# set up traps
trap 'rm -f $TMPPDF0 $TMPPDF1 $TMPPDF2 ; exit 1' 1 2 3 13 15

# handle special PDF options
declare -i GSVER=$(gs --version | sed -e 's/\.//' -e 's/\..*$//')
if [ "$WEBOPT" = 'y' ]; then
  if [ $GSVER -ge 950 ]; then
    PDFOPT='-dFastWebView=true -c 33550336 setvmthreshold'
  elif [ $GSVER -ge 907 ]; then
    PDFOPT='-dFastWebView=true -c .setpdfwrite'
  else
    PDFOPT='-c .setpdfwrite -f pdfopt.ps'
  fi
else
  if [ $GSVER -ge 950 ]; then
    PDFOPT='-c 33550336 setvmthreshold'
  else
    PDFOPT='-c .setpdfwrite'
  fi
fi

# run through files
declare -i S0=0 S1=0 S2=0
while [ $# -gt 0 ]; do

  # make sure we can read and modify file
  if [ ! -f "$1" -o ! -r "$1" -o ! -w "$1" ]; then
    echo "opt-pdf warning: $1 is not a writeable non-directory file"
    shift; continue
  fi

  # make sure it's a PDF
  file "$1" | grep -F -q 'PDF document'
  if [ $? -ne 0 ]; then
    echo "opt-pdf warning: $1 is not a PDF"
    shift; continue
  fi

  # skip already-processed files
  if [ "$FORCE" = 'n' ]; then
    command -v pdfinfo &>/dev/null
    if [ $? -eq 0 ]; then
      TMPPDF0=$(tempname opt-pdf_$$) || exit 99
      pdfinfo "$1" > $TMPPDF0
      grep -F Producer $TMPPDF0 | grep -F -q Ghostscript
      if [ $? -eq 0 ]; then
        echo "opt-pdf message: skipping ghostscript-processed $1"
        rm -f $TMPPDF0
        shift; continue
      fi
      grep -F Producer $TMPPDF0 | grep -F -q cairo
      if [ "$?" = '0' ]; then
        echo "opt-pdf message: skipping poppler-processed $1"
        rm -f $TMPPDF0
        shift; continue
      fi
    fi
  fi

  # run through ghostscript
  TMPPDF1=$(tempname -s .pdf opt-pdf_$$) || exit 99
  gs ${QUIETFLAG} -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dCompatibilityLevel=1.7 \
    -dDetectDuplicateImages=true -sBandListStorage=memory -dSubsetFonts=true \
    -dCompressFonts=true $COLORDPI $GRAYDPI $MONODPI -sOutputFile=$TMPPDF1 $PDFOPT -f "$1"
  if [ $? -eq 0 ]; then
    chmod --reference="$1" $TMPPDF1
    if [ "$TOUCH" = 'y' ]; then
      touch -r "$1" $TMPPDF1
    fi
    S1=$(filesize $TMPPDF1)
    GHOSTGOOD='y'
  else
    echo "opt-pdf warning: ghostscript failed to process $1: gs rc = $?"
    rm -f $TMPPDF1
    S1=$(((1<<63)-1))  # largest integer
    GHOSTGOOD='n'
  fi

  # run through poppler
  TMPPDF2=$(tempname -s .pdf opt-pdf_$$) || exit 99
  pdftocairo ${QUIETFLAG} -pdf "$1" $TMPPDF2
  if [ $? -eq 0 ]; then
    chmod --reference="$1" $TMPPDF2
    if [ "$TOUCH" = 'y' ]; then
      touch -r "$1" $TMPPDF2
    fi
    S2=$(filesize $TMPPDF2)
    POPPLERGOOD='y'
  else
    echo "opt-pdf warning: poppler failed to process $1: pdftocairo rc = $?"
    rm -f $TMPPDF2
    POPPLERGOOD='n'
    S2=$(((1<<63)-1))  # largest integer
  fi

  # see if we have any results to use
  if [ "$GHOSTGOOD" = 'n' -a "$POPPLERGOOD" = 'n' ]; then
    echo "opt-pdf error: both ghostscript and poppler failed; skipping..."
    shift; continue
  fi

  # ensure that new file is smaller
  S0=$(filesize "$1")
  if [ "$GHOSTGOOD" = 'n' -o $S2 -lt $S1 ]; then
    if [ $S2 -lt $S0 -o "$FORCE" = 'y' ]; then
      if [ "$BACKUP" = 'y' ]; then
        mv "$1" "${1}.bak"
      fi
      cp --preserve=timestamps $TMPPDF2 "$1"
      if [ "$VERBOSE" = 'y' ]; then
        echo "$1: using poppler - $S0 vs. $S2"
      fi
    elif [ "$VERBOSE" = 'y' ]; then
      echo "$1: unchanged"
    fi
  else
    if [ $S1 -lt $S0 -o "$FORCE" = 'y' ]; then
      if [ "$BACKUP" = 'y' ]; then
        mv "$1" "${1}.bak"
      fi
      cp --preserve=timestamps $TMPPDF1 "$1"
      if [ "$VERBOSE" = 'y' ]; then
        echo "$1: using ghostscript - $S0 vs. $S1"
      fi
    elif [ "$VERBOSE" = 'y' ]; then
      echo "$1: unchanged"
    fi
  fi

  # clean up afterwards
  rm -f $TMPPDF1 $TMPPDF2
  shift

done
