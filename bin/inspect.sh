#!/bin/sh
#
#  Copyright (c) 2020, Kai Thoene
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
