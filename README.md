# syscoin-governance-update
Bash Script to update current Masternode Governance Voting Key

How to create new Masternode Governance Voting Key;

1. Open Syscoin Qt and wait till it has fully synced, select “Window > Console” and enter "**masternode genkey**" to generate your masternode private key.
2. Open your masternode.conf file. Can be located in your Syscoin Directory.
3. Change your current Masternode GenKey to the new one.
4. Restart to your QT.
5. Open up your VPS
6. Run this script

```bash <(curl -sL https://raw.githubusercontent.com/bigpoppa-sys/syscoin-governance-update/master/script.sh)```

7. Press Enter for External IP Address, Masternode Port. Enter in your new Masternode Governance Voting Key.
8. Head back to your QT and reinitialize your Masternode.

**Notes:** 
- Seniority will not be effected (this is based on the tx of 100k)
- You will now be required to requalify for rewards payouts.
- This is only for users that have registered for sys hub.
