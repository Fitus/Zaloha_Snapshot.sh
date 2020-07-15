### OVERVIEW

<pre>
Zaloha_Snapshot is an add-on script to Zaloha to create hardlink-based snapshots
of the backup directory (condition: hardlinks must be supported by the
underlying filesystem type).

This allows to create "Time Machine"-like backup solutions.

Zaloha_Snapshot has been created using the same technology and style as Zaloha
itself. Read Zaloha documentation to get acquainted with relevant terminology,
features, cautions and limitations.

On Linux/Unics, Zaloha_Snapshot runs natively. On Windows, Cygwin is needed.

Repository: <a href="https://github.com/Fitus/Zaloha_Snapshot.sh">https://github.com/Fitus/Zaloha_Snapshot.sh</a>

Repository of Zaloha: <a href="https://github.com/Fitus/Zaloha.sh">https://github.com/Fitus/Zaloha.sh</a>
</pre>


### MORE DETAILED DESCRIPTION

<pre>
How do hardlink-based snapshots work: Assume a file exists in &lt;backupDir&gt;.
If Zaloha_Snapshot is invoked to create a snapshot directory (= &lt;snapDir&gt;)
of &lt;backupDir&gt;, it creates a hardlink in &lt;snapDir&gt; that points to the original
file in &lt;backupDir&gt;.

What happens at next run of Zaloha:

Scenario 1: No action occurs on the file in &lt;backupDir&gt; (because of no change
of the source file in &lt;sourceDir&gt;): The situation will stay as described above.
Please note that the physical storage space will be occupied only once (as the
hardlink takes very small additional space).

Scenario 2: The file in &lt;backupDir&gt; will be updated by Zaloha (due to change of
the source file in &lt;sourceDir&gt;): The update performed by Zaloha consists of
unlinking the hardlink (rm -f) and copying of the changed file to &lt;backupDir&gt;
(cp). The result will be that &lt;snapDir&gt; will contain the original file,
and &lt;backupDir&gt; will contain the updated file, both files now single-linked.

Please note that the <b>--noUnlink</b> option of Zaloha must NOT be used in order for
this to work.

Scenario 3: The file in &lt;backupDir&gt; will be removed by Zaloha (due to removal of
the source file in &lt;sourceDir&gt;): The removal (rm -f) will delete the file in
&lt;backupDir&gt;, but the hardlink (now single-linked file) in &lt;snapDir&gt; will stay.

Result after all three scenarios: &lt;snapDir&gt; still keeps the state of &lt;backupDir&gt;
at the time when it was created.
</pre>


### LIMITATIONS

<pre>
First of all, the filesystem type of &lt;backupDir&gt; and of &lt;snapDir&gt; must support
hardlinks (e.g. the ext4 filesystem supports hardlinks).

Next, hardlinks must reside on the same storage device as the original file.
Also, practically: whole &lt;backupDir&gt; must reside on one single storage device
and whole &lt;snapDir&gt; must reside on the same storage device (= also all must
reside on same single storage device (device number)).

Then, Zaloha_Snapshot is incompatible with some operation modes of Zaloha:

 * as already stated above, the <b>--noUnlink</b> option must NOT be used

 * further, we say that the <b>--revNew</b> and <b>--revUp</b> options are also not
   compatible, because they imply that there will be user activity on
   &lt;backupDir&gt;, which is inconsistent with the whole concept.

 * further, &lt;backupDir&gt; and all snapshot directories should be accompanied by
   Zaloha metadata directories. One key reason is that objects other than files
   and directories are kept in metadata only. The default location of the Zaloha
   metadata directory is &lt;backupDir&gt;/.Zaloha_metadata, which is a good location
   as it is inside of &lt;backupDir&gt;. Placing the Zaloha metadata directory to a
   different location (via the <b>--metaDir</b> option) would create hard-to-manage
   situations with the (potentially many) snapshot directories, so we define
   that this is not compatible either.
</pre>


### INVOCATION

<pre>
<b>Zaloha_Snapshot.sh</b> <b>--backupDir</b>=&lt;backupDir&gt; <b>--snapDir</b>=&lt;snapDir&gt; [ other options ]

<b>--backupDir</b>=&lt;backupDir&gt; is mandatory. &lt;backupDir&gt; must exist, otherwise Zaloha
    throws an error.

<b>--snapDir</b>=&lt;snapDir&gt; is mandatory. &lt;snapDir&gt; must NOT exist, otherwise Zaloha
    throws an error.

<b>--noExec</b>        ... do not actually create the contents of &lt;snapDir&gt; (= the
    subdirectories and the hardlinks), only prepare the script (file 930).
    The prepared script will not contain the "set -e" instruction. This means
    that the script ignores individual failed commands and tries to do as much
    work as possible, which is a behavior different from the interactive regime,
    where the script halts on the first error.

<b>--noSnapHdr</b>     ... do not write header to the shellscript to create snapshot
    directory (file 930). This option can be used only together with the
    <b>--noExec</b> option. The header contains definitions used in the body of the
    script. Header-less script (i.e. body only) can be easily used with an
    alternative header that contains different definitions.

<b>--saveSpace</b>     ... compress the CSV metadata file 505 and, unless the option
    <b>--noExec</b> has been given, remove the shellscript to create snapshot
    directory (file 930) upon exit. Saving space is the more relevant issue
    the more snapshot directories exist.

<b>--noProgress</b>    ... suppress progress messages (no screen output).

<b>--mawk</b>          ... use mawk, the very fast AWK implementation based on a
                    bytecode interpreter. Without this option, awk is used,
                    which usually maps to GNU awk (but not always).

<b>--lTest</b>         ... (do not use in real operations) support for lint-testing
                    of AWK programs

<b>--help</b>          ... show Zaloha_Snapshot documentation (using the LESS program)
                    and exit

In case of failure: resolve the problem, remove an eventually existing &lt;snapDir&gt;
and re-run Zaloha_Snapshot with same parameters.
</pre>


### TESTING, DEPLOYMENT, INTEGRATION

<pre>
See corresponding section in Zaloha documentation for general issues.

For Zaloha_Snapshot, it is important to verify that the overall concept works
on your environment under all three scenarios described in section More Detailed
Description above. The Simple Demo scripts from the repository contain a
relevant minimalistic test case.
</pre>


### RESTORE FROM A SNAPSHOT DIRECTORY

<pre>
As a restore from a snapshot directory is a less likely scenario and the
shellscripts for the case of restore (scripts 800 through 860) occupy space,
Zaloha_Snapshot (unlike Zaloha) does not prepare these scripts.

In case of need, they should be prepared manually by running the AWK program 700
on the CSV metadata file 505:

  awk -f "&lt;AWK program 700&gt;"                \
      -v backupDir="&lt;snapDir&gt;"              \
      -v restoreDir="&lt;restoreDir&gt;"          \
      -v f800="&lt;script 800 to be created&gt;"  \
      -v f810="&lt;script 810 to be created&gt;"  \
      -v f820="&lt;script 820 to be created&gt;"  \
      -v f830="&lt;script 830 to be created&gt;"  \
      -v f840="&lt;script 840 to be created&gt;"  \
      -v f850="&lt;script 850 to be created&gt;"  \
      -v f860="&lt;script 860 to be created&gt;"  \
      -v noR800Hdr=0                        \
      -v noR810Hdr=0                        \
      -v noR820Hdr=0                        \
      -v noR830Hdr=0                        \
      -v noR840Hdr=0                        \
      -v noR850Hdr=0                        \
      -v noR860Hdr=0                        \
      "&lt;CSV metadata file 505&gt;"

Note 1: All filenames/paths should begin with a "/" (if absolute) or with a "./"
(if relative), and &lt;snapDir&gt; and &lt;restoreDir&gt; must end with terminating "/".

Note 2: If any of the filenames/paths passed into AWK as variables (&lt;snapDir&gt;,
&lt;restoreDir&gt; and the &lt;scripts 8xx to be created&gt;) contain backslashes as "weird
characters", replace them by ///b. The AWK program 700 will replace ///b back
to backslashes inside.
</pre>


### SPECIAL AND CORNER CASES

<pre>
Updates of ONLY the file attributes (owner, group, mode) by Zaloha: If Zaloha
operates with the <b>--pUser,</b> <b>--pGroup</b> and/or <b>--pMode</b> options, it updates
the attributes on &lt;backupDir&gt; to reflect &lt;sourceDir&gt;. In case when ONLY the
attributes are updated (also not the file itself (= no unlinking)), the
attributes are updated on all hardlinks in the snapshot directories.
(More precisely, this depends on the type of the underlying filesystem:
there are some filesystem types that allow hardlinks to the same file to have
different sets of attributes).

Hardlinks on &lt;sourceDir&gt; and hardlinks on &lt;backupDir&gt;: Let's summarize the
situation to leave no room for confusion:

&lt;sourceDir&gt; is a user-maintained directory where hardlinks between files may
exist. Without the <b>--hLinks</b> option, Zaloha will treat each hardlink as a
separate regular file, and will synchronize each such file to &lt;backupDir&gt;.
With the <b>--hLinks</b> option, Zaloha will treat only the first hardlink as a file,
and will synchronize that file to &lt;backupDir&gt;. The second, third etc hardlinks
will be treated as "hardlinks" and will be kept in metadata only (the 505 file).

&lt;backupDir&gt;, on the other hand, must be a directory maintained solely by Zaloha
(user activity on &lt;backupDir&gt; is inconsistent with the concept of snapshots).
Zaloha never creates hardlinks on &lt;backupDir&gt;, also there should be none.
It is Zaloha_Snapshot that brings hardlinks into play, in the form that
snapshot directories contain hardlinks to files in &lt;backupDir&gt;.
</pre>


### HOW ZALOHA_SNAPSHOT WORKS INTERNALLY

<pre>
Handling and checking of input parameters should be self-explanatory.

Zaloha_Snapshot then creates &lt;snapDir&gt; along with &lt;snapDir&gt;/.Zaloha_metadata
and then copies files 000, 100, 505 and 700 from &lt;backupDir&gt;/.Zaloha_metadata
into it.

The AWK program AWKSNAPCHECK then checks the 000 file and raises an error
if &lt;backupDir&gt; is maintained by an instance of Zaloha with options incompatible
with Zaloha_Snapshot (see section Limitations above).

The AWK program AWKSNAPSHOT then prepares a shellscript to create the contents
of the snapshot directory (the subdirectories and the hardlinks).

The prepared shellscript is then sourced to perform actual work (unless the
<b>--noExec</b> option is given).
</pre>
