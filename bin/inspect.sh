#!/bin/sh
#
#----------
# Set some global variables.
#
ME="$0"
MYNAME=`basename "$ME"`
MYDIR=`dirname "$ME"`
MYDIR=`cd "$MYDIR"; pwd`
WD=`pwd`
#
# Redirect STDERR to STDOUT.
#
exec 2>&1
#
#----------
# Print environment variables.
#
cat <<EOF
<h2>Output from $ME:</h2>
<h3>Environment</h3>
<table><thead>
  <tr>
    <th>Variable</th>
    <th>Value</th>
  </tr>
</thead>
<tbody>
EOF
for VN in ROOT_PATH PLUGIN_PATH THIS_PLUGIN_PATH PAGE_PATH PAGE_ROUTE PAGE_URL PATH; do
  eval "VALUE=$"$VN""
  cat <<EOF
  <tr>
    <td>$VN</td>
    <td>$VALUE</td>
  </tr>
EOF
done
cat <<EOF
</tbody></table>
EOF
#
#----------
# Print interesting variables.
#
cat <<EOF
<h3>Interesting Settings</h3>
<table><thead>
  <tr>
    <th>Setting</th>
    <th>Value</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>Program file</td>
    <td>$ME</td>
  </tr>
  <tr>
    <td>Program file / Basename</td>
    <td>$MYNAME</td>
  </tr>
  <tr>
    <td>Program file / Absolute directory path</td>
    <td>$MYDIR</td>
  </tr>
  <tr>
    <td>Current working directory</td>
    <td>$WD</td>
  </tr>
</tbody></table>
EOF
#
#----------
# Print arguments.
#
cat <<EOF
<h3>Arguments</h3>
<table><thead>
  <tr>
    <th>Argument#</th>
    <th>Value</th>
  </tr>
</thead>
<tbody>
EOF
NARG=1
while [ -n "$1" ]; do
cat <<EOF
  <tr>
    <td>$NARG</td>
    <td>$1</td>
  </tr>
EOF
  NARG=`echo "1+$NARG" | bc`
  shift
done
cat <<EOF
</tbody></table>
EOF
#
#----------
# Print stdin.
#
STDIN=`cat`
cat <<EOF
<h3>STDIN</h3>
<pre><code>$STDIN</code></pre>
EOF
#
exit 0
