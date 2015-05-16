#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2006 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
#ident	"@(#)tst.header.ksh	1.1	06/08/28 SMI"

DIR=/var/tmp/dtest.$$

mkdir $DIR
cd $DIR

cat > prov.d <<EOF
provider test_prov {
	probe zero();
	probe one(uintptr_t);
	probe u_nder(char *);
	probe d__ash(int **);
};
EOF

dtrace -h -s prov.d
if [ $? -ne 0 ]; then
	print -u2 "failed to generate header file"
	exit 1
fi

cat > test.c <<EOF
#include <sys/types.h>
#include "prov.h"

int
main(int argc, char **argv)
{
	TEST_PROV_ZERO();
	TEST_PROV_ONE(1);
	TEST_PROV_U_NDER("hi there");
	TEST_PROV_D_ASH(argv);
}
EOF

cc -c test.c
if [ $? -ne 0 ]; then
	print -u2 "failed to compile test.c"
	exit 1
fi
dtrace -G -32 -s prov.d test.o
if [ $? -ne 0 ]; then
	print -u2 "failed to create DOF"
	exit 1
fi
cc -o test test.o prov.o
if [ $? -ne 0 ]; then
	print -u2 "failed to link final executable"
	exit 1
fi

cd /
/usr/bin/rm -rf $DIR
