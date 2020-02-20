#!/bin/bash

function zalohasnap_docu {
  less << 'ZALOHASNAPDOCU'
###########################################################

MIT License

Copyright (c) 2020 Fitus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

###########################################################

OVERVIEW

Zaloha_Snapshot is an add-on shellscript to Zaloha to create hardlink-based
snapshots of the backup directory (condition: hardlinks must be supported by the
underlying filesystem type).

This allows to create "Time Machine"-like backup solutions.

Zaloha_Snapshot has been created using the same technology and style as Zaloha
itself. Read Zaloha documentation to get acquainted with relevant terminology,
features, cautions and limitations.

On Linux/Unics, Zaloha_Snapshot runs natively. On Windows, Cygwin is needed.

Repository: https://github.com/Fitus/Zaloha_Snapshot.sh

Repository of Zaloha: https://github.com/Fitus/Zaloha.sh

###########################################################

MORE DETAILED DESCRIPTION

How do hardlink-based snapshots work: Assume a file exists in <backupDir>.
If Zaloha_Snapshot is invoked to create a snapshot directory (= <snapDir>)
of <backupDir>, it creates a hardlink in <snapDir> that points to the original
file in <backupDir>.

What happens at next run of Zaloha:

Scenario 1: No action occurs on the file in <backupDir> (because of no change
of the source file in <sourceDir>): The situation will stay as described above.
Please note that the physical storage space will be occupied only once (as the
hardlink takes very small additional space).

Scenario 2: The file in <backupDir> will be updated by Zaloha (due to change of
the source file in <sourceDir>): The update performed by Zaloha consists of
unlinking the hardlink (rm -f) and copying of the changed file to <backupDir>
(cp). The result will be that <snapDir> will contain the original file,
and <backupDir> will contain the updated file, both files now single-linked.

Please note that the "--noUnlink" option of Zaloha must NOT be used in order for
this to work.

Scenario 3: The file in <backupDir> will be removed by Zaloha (due to removal of
the source file in <sourceDir>): The removal (rm -f) will delete the file in
<backupDir>, but the hardlink (now single-linked file) in <snapDir> will stay.

Result after all three scenarios: <snapDir> still keeps the state of <backupDir>
at the time when it was created.

###########################################################

LIMITATIONS

First of all, the filesystem type of <backupDir> and of <snapDir> must support
hardlinks (e.g. the ext4 filesystem supports hardlinks).

Next, hardlinks must reside on the same storage device as the original file.
Also, practically: whole <backupDir> must reside on one single storage device
and whole <snapDir> must reside on the same storage device (= also all must
reside on same single storage device (device number)).

Then, Zaloha_Snapshot is incompatible with some operation modes of Zaloha:

 * as already stated above, the "--noUnlink" option must NOT be used

 * further, we say that the "--revNew" and "--revUp" options are also not
   compatible, because they imply that there will be user activity on
   <backupDir>, which is inconsistent with the whole concept.

 * further, <backupDir> and all snapshot directories should be accompanied by
   Zaloha metadata directories. One key reason is that objects other than files
   and directories are kept in metadata only. The default location of the Zaloha
   metadata directory is <backupDir>/.Zaloha_metadata, which is a good location
   as it is inside of <backupDir>. Placing the Zaloha metadata directory to a
   different location (via the "--metaDir" option) would create hard-to-manage
   situations with the (potentially many) snapshot directories, so we define
   that this is not compatible either.

###########################################################

INVOCATION

Zaloha_Snapshot.sh --backupDir=<backupDir> --snapDir=<snapDir> [ other options ]

--backupDir=<backupDir> is mandatory. <backupDir> must exist, otherwise Zaloha
    throws an error.

--snapDir=<snapDir> is mandatory. <snapDir> must NOT exist, otherwise Zaloha
    throws an error.

--noExec        ... do not actually create the contents of <snapDir> (= the
    subdirectories and the hardlinks), only prepare the script (file 930).
    The prepared script will not contain the "set -e" instruction. This means
    that the script ignores individual failed commands and tries to do as much
    work as possible, which is a behavior different from the interactive regime,
    where the script halts on the first error.

--noSnapHdr     ... do not write header to the shellscript to create snapshot
    directory (file 930). This option can be used only together with the
    "--noExec" option. The header contains definitions used in the body of the
    script. Header-less script (i.e. body only) can be easily used with an
    alternative header that contains different definitions.

--saveSpace     ... compress the CSV metadata file 505 and, unless the option
    "--noExec" has been given, remove the shellscript to create snapshot
    directory (file 930) upon exit. Saving space is the more relevant issue
    the more snapshot directories exist.

--noProgress    ... suppress progress messages (no screen output).

--mawk          ... use mawk, the very fast AWK implementation based on a
                    bytecode interpreter. Without this option, awk is used,
                    which usually maps to GNU awk (but not always).

--lTest         ... (do not use in real operations) support for lint-testing
                    of AWK programs

--help          ... show Zaloha_Snapshot documentation (using the LESS program)
                    and exit

In case of failure: resolve the problem, remove an eventually existing <snapDir>
and re-run Zaloha_Snapshot with same parameters.

###########################################################

TESTING, DEPLOYMENT, INTEGRATION

See corresponding section in Zaloha documentation for general issues.

For Zaloha_Snapshot, it is important to verify that the overall concept works
on your environment under all three scenarios described in section More Detailed
Description above. The Simple Demo scripts from the repository contain a
relevant minimalistic test case.

###########################################################

RESTORE FROM A SNAPSHOT DIRECTORY

As a restore from a snapshot directory is a less likely scenario and the
shellscripts for the case of restore (scripts 800 through 860) occupy space,
Zaloha_Snapshot (unlike Zaloha) does not prepare these scripts.

In case of need, they should be prepared manually by running the AWK program 700
on the CSV metadata file 505:

  awk -f "<AWK program 700>"                \
      -v backupDir="<snapDir>"              \
      -v restoreDir="<restoreDir>"          \
      -v f800="<script 800 to be created>"  \
      -v f810="<script 810 to be created>"  \
      -v f820="<script 820 to be created>"  \
      -v f830="<script 830 to be created>"  \
      -v f840="<script 840 to be created>"  \
      -v f850="<script 850 to be created>"  \
      -v f860="<script 860 to be created>"  \
      -v noR800Hdr=0                        \
      -v noR810Hdr=0                        \
      -v noR820Hdr=0                        \
      -v noR830Hdr=0                        \
      -v noR840Hdr=0                        \
      -v noR850Hdr=0                        \
      -v noR860Hdr=0                        \
      "<CSV metadata file 505>"

Note 1: All filenames/paths should begin with a "/" (if absolute) or with a "./"
(if relative), and <snapDir> and <restoreDir> must end with terminating "/".

Note 2: If any of the filenames/paths passed into AWK as variables (<snapDir>,
<restoreDir> and the <scripts 8xx to be created>) contain backslashes as "weird
characters", replace them by ///b. The AWK program 700 will replace ///b back
to backslashes inside.

###########################################################

SPECIAL AND CORNER CASES

Updates of ONLY the file attributes (owner, group, mode) by Zaloha: If Zaloha
operates with the "--pUser", "--pGroup" and/or "--pMode" options, it updates
the attributes on <backupDir> to reflect <sourceDir>. In case when ONLY the
attributes are updated (also not the file itself (= no unlinking)), the
attributes are updated on all hardlinks in the snapshot directories.
(More precisely, this depends on the type of the underlying filesystem:
there are some filesystem types that allow hardlinks to the same file to have
different sets of attributes).

Hardlinks on <sourceDir> and hardlinks on <backupDir>: Let's summarize the
situation to leave no room for confusion:

<sourceDir> is a user-maintained directory where hardlinks between files may
exist. Without the "--hLinks" option, Zaloha will treat each hardlink as a
separate regular file, and will synchronize each such file to <backupDir>.
With the "--hLinks" option, Zaloha will treat only the first hardlink as a file,
and will synchronize that file to <backupDir>. The second, third etc hardlinks
will be treated as "hardlinks" and will be kept in metadata only (the 505 file).

<backupDir>, on the other hand, must be a directory maintained solely by Zaloha
(user activity on <backupDir> is inconsistent with the concept of snapshots).
Zaloha never creates hardlinks on <backupDir>, also there should be none.
It is Zaloha_Snapshot that brings hardlinks into play, in the form that
snapshot directories contain hardlinks to files in <backupDir>.

###########################################################

HOW ZALOHA_SNAPSHOT WORKS INTERNALLY

Handling and checking of input parameters should be self-explanatory.

Zaloha_Snapshot then creates <snapDir> along with <snapDir>/.Zaloha_metadata
and then copies files 000, 100, 505 and 700 from <backupDir>/.Zaloha_metadata
into it.

The AWK program AWKSNAPCHECK then checks the 000 file and raises an error
if <backupDir> is maintained by an instance of Zaloha with options incompatible
with Zaloha_Snapshot (see section Limitations above).

The AWK program AWKSNAPSHOT then prepares a shellscript to create the contents
of the snapshot directory (the subdirectories and the hardlinks).

The prepared shellscript is then sourced to perform actual work (unless the
"--noExec" option is given.

###########################################################
ZALOHASNAPDOCU
}

# DEFINITIONS OF FILES COPIED FROM METADATA DIRECTORY OF ZALOHA

f000Base="000_parameters.csv"        # parameters under which Zaloha was invoked and internal variables
f100Base="100_awkpreproc.awk"        # AWK preprocessor for other AWK programs
f505Base="505_target.csv"            # target state (includes Exec2 and Exec3 actions) of synchronized directories
f700Base="700_restore.awk"           # AWK program for preparation of shellscripts for the case of restore
f999Base="999_mark_executed"         # empty touchfile marking execution of actions

# FILES CREATED BY ZALOHA_SNAPSHOT

f900Base="900_snapparam.csv"         # parameters under which Zaloha_Snapshot was invoked and internal variables
f910Base="910_snapcheck.awk"         # AWK program for checking of compatibility of Zaloha parameters
f920Base="920_snapshot.awk"          # AWK program for preparation of shellscript to create snapshot directory
f930Base="930_snapshot.sh"           # shellscript to create snapshot directory

###########################################################
set -u
set -e
set -o pipefail

function error_exit {
  echo "Zaloha_Snapshot.sh: ${1}" >&2
  exit 1
}

trap 'error_exit "Error on line ${LINENO}"' ERR

function opt_dupli_check {
  if [ ${1} -eq 1 ]; then
    error_exit "Option ${2} passed in two or more times"
  fi
}

function start_progress {
  if [ ${noProgress} -eq 0 ]; then
    echo -n "    ${1} ${DOTS60:1:$(( 53 - ${#1} ))}"
    progressCurrColNo=58
  fi
}

function start_progress_by_chars {
  if [ ${noProgress} -eq 0 ]; then
    echo -n "    ${1} "
    (( progressCurrColNo = ${#1} + 5 ))
  fi
}

function progress_char {
  if [ ${noProgress} -eq 0 ]; then
    if [ ${progressCurrColNo} -ge 80 ]; then
      echo -ne "\n    "
      progressCurrColNo=4
    fi
    echo -n "${1}"
    (( progressCurrColNo++ ))
  fi
}

function stop_progress {
  if [ ${noProgress} -eq 0 ]; then
    if [ ${progressCurrColNo} -gt 58 ]; then
      echo -ne "\n    "
      progressCurrColNo=4
    fi
    echo "${BLANKS60:1:$(( 58 - ${progressCurrColNo} ))} done."
  fi
}

TAB=$'\t'
NLINE=$'\n'
BSLASHPATTERN='\\'
CNTRLPATTERN='[[:cntrl:]]'
TRIPLETT='///t'      # escape for tab
TRIPLETN='///n'      # escape for newline
TRIPLETB='///b'      # escape for backslash
TRIPLETC='///c'      # display of control characters on terminal
TRIPLET='///'        # escape sequence, leading field, terminator field

FSTAB=$'\t'
printf -v BLANKS60 '%60s' ' '
DOTS60="${BLANKS60// /.}"

###########################################################
backupDir=
backupDirPassed=0
snapDir=
snapDirPassed=0
noExec=0
noSnapHdr=0
saveSpace=0
noProgress=0
mawk=0
lTest=0
help=0

for tmpVal in "${@}"
do
  case "${tmpVal}" in
    --backupDir=*)       opt_dupli_check ${backupDirPassed} "${tmpVal%%=*}";  backupDir="${tmpVal#*=}";  backupDirPassed=1 ;;
    --snapDir=*)         opt_dupli_check ${snapDirPassed} "${tmpVal%%=*}";    snapDir="${tmpVal#*=}";    snapDirPassed=1 ;;
    --noExec)            opt_dupli_check ${noExec} "${tmpVal}";      noExec=1 ;;
    --noSnapHdr)         opt_dupli_check ${noSnapHdr} "${tmpVal}";   noSnapHdr=1 ;;
    --saveSpace)         opt_dupli_check ${saveSpace} "${tmpVal}";   saveSpace=1 ;;
    --noProgress)        opt_dupli_check ${noProgress} "${tmpVal}";  noProgress=1 ;;
    --mawk)              opt_dupli_check ${mawk} "${tmpVal}";        mawk=1 ;;
    --lTest)             opt_dupli_check ${lTest} "${tmpVal}";       lTest=1 ;;
    --help)              opt_dupli_check ${help} "${tmpVal}";        help=1 ;;
    *) error_exit "Unknown option ${tmpVal//${CNTRLPATTERN}/${TRIPLETC}}, get help via Zaloha_Snapshot.sh --help" ;;
  esac
done

if [ ${help} -eq 1 ]; then
  zalohasnap_docu
  exit 0
fi

if [ ${noSnapHdr} -eq 1 ] && [ ${noExec} -eq 0 ]; then
  error_exit "Option --noSnapHdr can be used only together with option --noExec"
fi

if [ ${mawk} -eq 1 ]; then
  awk="mawk"
elif [ ${lTest} -eq 1 ]; then
  awk="awk -Lfatal"
else
  awk="awk"
fi

###########################################################
if [ "" == "${backupDir}" ]; then
  error_exit "<backupDir> is mandatory, get help via Zaloha_Snapshot.sh --help"
fi
if [ "${backupDir/${TRIPLET}/}" != "${backupDir}" ]; then
  error_exit "<backupDir> contains the directory separator triplet (${TRIPLET})"
fi
if [ "/" != "${backupDir:0:1}" ] && [ "./" != "${backupDir:0:2}" ]; then
  backupDir="./${backupDir}"
fi
if [ "/" != "${backupDir: -1:1}" ]; then
  backupDir="${backupDir}/"
fi
if [ ! -d "${backupDir}" ]; then
  error_exit "<backupDir> is not a directory"
fi
backupDirAwk="${backupDir//${BSLASHPATTERN}/${TRIPLETB}}"
backupDirEsc="${backupDir//${TAB}/${TRIPLETT}}"
backupDirEsc="${backupDirEsc//${NLINE}/${TRIPLETN}}"

###########################################################
if [ "" == "${snapDir}" ]; then
  error_exit "<snapDir> is mandatory, get help via Zaloha_Snapshot.sh --help"
fi
if [ "${snapDir/${TRIPLET}/}" != "${snapDir}" ]; then
  error_exit "<snapDir> contains the directory separator triplet (${TRIPLET})"
fi
if [ "/" != "${snapDir:0:1}" ] && [ "./" != "${snapDir:0:2}" ]; then
  snapDir="./${snapDir}"
fi
if [ "/" != "${snapDir: -1:1}" ]; then
  snapDir="${snapDir}/"
fi
if [ -e "${snapDir}" ]; then
  error_exit "<snapDir> already exists"
fi
snapDirAwk="${snapDir//${BSLASHPATTERN}/${TRIPLETB}}"
snapDirEsc="${snapDir//${TAB}/${TRIPLETT}}"
snapDirEsc="${snapDirEsc//${NLINE}/${TRIPLETN}}"

###########################################################
metaDirInternalBase=".Zaloha_metadata"

metaDirBackup="${backupDir}${metaDirInternalBase}/"
metaDirBackupEsc="${metaDirBackup//${TAB}/${TRIPLETT}}"
metaDirBackupEsc="${metaDirBackupEsc//${NLINE}/${TRIPLETN}}"

metaDirSnap="${snapDir}${metaDirInternalBase}/"
metaDirSnapEsc="${metaDirSnap//${TAB}/${TRIPLETT}}"
metaDirSnapEsc="${metaDirSnapEsc//${NLINE}/${TRIPLETN}}"

if [ ! -d "${metaDirBackup}" ]; then
  error_exit "Zaloha metadata directory of <backupDir> does not exist where expected"
fi

###########################################################

f000="${metaDirSnap}${f000Base}"
f100="${metaDirSnap}${f100Base}"
f505="${metaDirSnap}${f505Base}"
f700="${metaDirSnap}${f700Base}"
f900="${metaDirSnap}${f900Base}"
f910="${metaDirSnap}${f910Base}"
f920="${metaDirSnap}${f920Base}"
f930="${metaDirSnap}${f930Base}"
f999="${metaDirSnap}${f999Base}"

if [ "${metaDirBackup}${f000Base}" -nt "${metaDirBackup}${f999Base}" ]; then
  error_exit "The actions prepared by Zaloha have not yet been executed"
fi

start_progress "Copying select files from Zaloha metadata directory"

mkdir -p "${metaDirSnap}"

cp --preserve=timestamps "${metaDirBackup}${f000Base}" "${f000}"
cp --preserve=timestamps "${metaDirBackup}${f100Base}" "${f100}"
cp --preserve=timestamps "${metaDirBackup}${f505Base}" "${f505}"
cp --preserve=timestamps "${metaDirBackup}${f700Base}" "${f700}"

stop_progress

###########################################################
${awk} '{ print }' << SNAPPARAMFILE > "${f900}"
${TRIPLET}${FSTAB}backupDir${FSTAB}${backupDir}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}backupDirAwk${FSTAB}${backupDirAwk}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}backupDirEsc${FSTAB}${backupDirEsc}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}snapDir${FSTAB}${snapDir}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}snapDirAwk${FSTAB}${snapDirAwk}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}snapDirEsc${FSTAB}${snapDirEsc}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}metaDirBackup${FSTAB}${metaDirBackup}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}metaDirBackupEsc${FSTAB}${metaDirBackupEsc}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}metaDirSnap${FSTAB}${metaDirSnap}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}metaDirSnapEsc${FSTAB}${metaDirSnapEsc}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}noExec${FSTAB}${noExec}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}noSnapHdr${FSTAB}${noSnapHdr}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}saveSpace${FSTAB}${saveSpace}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}noProgress${FSTAB}${noProgress}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}mawk${FSTAB}${mawk}${FSTAB}${TRIPLET}
${TRIPLET}${FSTAB}lTest${FSTAB}${lTest}${FSTAB}${TRIPLET}
SNAPPARAMFILE

###########################################################
${awk} -f "${f100}" << 'AWKSNAPCHECK' > "${f910}"
DEFINE_ERROR_EXIT
BEGIN {
  FS = FSTAB
  noUnlinkChecked = 0
  revNewChecked = 0
  revUpChecked = 0
}
{
  if (( 4 == NF ) && ( TRIPLET == $1 ) && ( TRIPLET == $4 )) {
    if ( "noUnlink" == $2 ) {
      if ( "0" != $3 ) {
        error_exit( "Option --noUnlink of Zaloha is incompatible with Zaloha_Snapshot" )
      }
      noUnlinkChecked = 1
    } else if ( "revNew" == $2 ) {
      if ( "0" != $3 ) {
        error_exit( "Option --revNew of Zaloha is incompatible with Zaloha_Snapshot" )
      }
      revNewChecked = 1
    } else if ( "revUp" == $2 ) {
      if ( "0" != $3 ) {
        error_exit( "Option --revUp of Zaloha is incompatible with Zaloha_Snapshot" )
      }
      revUpChecked = 1
    }
  }
}
END {
  if ( 1 != noUnlinkChecked ) {
    error_exit( "Unexpected, option --noUnlink does not exist in Zaloha parameters file" )
  }
  if ( 1 != revNewChecked ) {
    error_exit( "Unexpected, option --revNew does not exist in Zaloha parameters file" )
  }
  if ( 1 != revUpChecked ) {
    error_exit( "Unexpected, option --revUp does not exist in Zaloha parameters file" )
  }
}
AWKSNAPCHECK

start_progress "Checking of compatibility of Zaloha parameters"

${awk} -f "${f910}" "${f000}"

stop_progress

###########################################################
${awk} -f "${f100}" << 'AWKSNAPSHOT' > "${f920}"
BEGIN {
  FS = FSTAB
  pin = 1         # parallel index
  pri = 1         # progress index
  gsub( TRIPLETBREGEX, BSLASH, backupDir )
  gsub( TRIPLETBREGEX, BSLASH, snapDir )
  gsub( QUOTEREGEX, QUOTEESC, backupDir )
  gsub( QUOTEREGEX, QUOTEESC, snapDir )
  if ( 1 == noExec ) {
    if ( 0 == noSnapHdr ) {
      BIN_BASH
      print "backupDir='" backupDir "'"
      print "snapDir='" snapDir "'"
      print "MKDIR='mkdir'"
      print "LNHARD" ONE_TO_MAXPARALLEL "='ln'"
      print "set -u"
    }
  } else {
    print "MKDIR='mkdir'"
    print "LNHARD" ONE_TO_MAXPARALLEL "='ln'"
  }
  SECTION_LINE
}
{
  if (( $3 ~ /[df]/ ) && ( "" != $13 )) {
    pt = $13
    gsub( QUOTEREGEX, QUOTEESC, pt )
    gsub( TRIPLETNREGEX, NLINE, pt )
    gsub( TRIPLETTREGEX, TAB, pt )
    b = "\"${backupDir}\"'" pt "'"
    s = "\"${snapDir}\"'" pt "'"
    if ( "d" == $3 ) {
      print "${MKDIR} " s
    } else if ( "f" == $3 ) {
      print "${LNHARD" pin "} " b " " s
      if ( MAXPARALLEL <= pin ) {
        pin = 1
      } else {
        pin = pin + 1
      }
    }
    if ( 0 == noExec ) {
      if ( 10 <= pri ) {
        print "progress_char \".\""
        pri = 1
      } else {
        pri = pri + 1
      }
    }
  }
}
END {
  SECTION_LINE
}
AWKSNAPSHOT

start_progress "Preparing shellscript to create snapshot directory"

${awk} -f "${f920}"                    \
       -v backupDir="${backupDirAwk}"  \
       -v snapDir="${snapDirAwk}"      \
       -v noExec=${noExec}             \
       -v noSnapHdr=${noSnapHdr}       \
       "${f505}"                       > "${f930}"

stop_progress

###########################################################

if [ ${saveSpace} -eq 1 ]; then

  start_progress "Compressing CSV metadata file 505"

  gzip "${f505}"

  stop_progress

fi

###########################################################

# now all preparations are done, start executing ...

if [ ${noExec} -eq 1 ]; then
  exit 0
fi

start_progress_by_chars "Creating snapshot directory"

source "${f930}"

stop_progress

###########################################################

if [ ${saveSpace} -eq 1 ]; then

  start_progress "Removing shellscript to create snapshot directory"

  rm -f "${f930}"

  stop_progress

fi

###########################################################

start_progress "Copying file 999 from Zaloha metadata directory"

cp --preserve=timestamps "${metaDirBackup}${f999Base}" "${f999}"

stop_progress

###########################################################

# end
