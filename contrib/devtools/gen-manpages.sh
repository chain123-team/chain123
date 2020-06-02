#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

CHAIN123D=${CHAIN123D:-$SRCDIR/chain123d}
CHAIN123CLI=${CHAIN123CLI:-$SRCDIR/chain123-cli}
CHAIN123TX=${CHAIN123TX:-$SRCDIR/chain123-tx}
CHAIN123QT=${CHAIN123QT:-$SRCDIR/qt/chain123-qt}

[ ! -x $CHAIN123D ] && echo "$CHAIN123D not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
C123VER=($($CHAIN123CLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$CHAIN123D --version | sed -n '1!p' >> footer.h2m

for cmd in $CHAIN123D $CHAIN123CLI $CHAIN123TX $CHAIN123QT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${C123VER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${C123VER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m