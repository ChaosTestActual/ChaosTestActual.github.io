#!/bin/bash
set -euo pipefail

prefix="RITUAL: RODS FROM GODS: "

echo "$prefix orbital strike package has entered standby mode."
echo "$prefix let your identity return to the ether."

# Check if the user really wants to proceed
echo "
Are you sure you want to continue?
There is no return.
To continue, you must type the following and hit ENTER.

"

expected="I sign my own death warrant"
read -p $expected confirmation
if [[ "$confirmation" != $expected ]]; then
    echo "$prefix __ABORTED__."
    exit 1
fi

echo "$prefix __INITIATED__.

There is still time to turn back.

You have five seconds to reconsider your decision.

ctrl-c now if you wish to abort the ritual.

"
# Sleep for 5 seconds to give the user a chance to abort
for i in {5..1}; do
    echo -ne "\r$prefix $i seconds remaining... "
    sleep 1
done

echo "$prefix __PROCEEDING__."

sh ./identity-decoherence/ritual__banish-gpg.sh
sh ./identity-decoherence/ritual__banish-ssh.sh
sh ./identity-decoherence/ritual__banish-keychain.sh
sh ./identity-decoherence/ritual__banish-browsers.sh
sh ./identity-decoherence/ritual__banish-identity-tokens.sh
sh ./identity-decoherence/ritual__banish-network.sh
sh ./identity-decoherence/ritual__banish-logs.sh

echo "$prefix __COMPLETED__.

May the gods have mercy on your digital soul.
Your identity has been obliterated from existence.
You are now a ghost in the machine, free to roam the digital ether without a trace.
Use your newfound anonymity wisely.

$prefix __FINALIZED__."