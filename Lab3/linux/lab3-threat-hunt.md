Hypothesis: "An attacker has established SSH-key-based persistence, created a backdoor account, and planted a SUID binary to escalate."

**Data sources queried: osquery (suid_bin, authorized_keys, hash, kernel_modules, users, processes), Windows Security log (4624, 4625, 4688, 4720, 4104).

**Findings: A comparison between the clean baseline system and the post attak shows distinct changes that align with attacker behavior rather than normal activity.
1) A new SUID binary ('/usr/local/bin/lab3-suit-test') owned by root was planted on the system to facilitate privilege escalation. 
2) A Rogue SSH public key was appended to the user's ~/.ssh/authorized_keys file to establish persistence.
3) The SHA256 hashes for '/etc/passwd' and '/etc/shadow' changed which confirmed the creation of unauthorized local backdoor accounts. 

**Mitre Attack Mapping
1) T1548.001: Abuse elevation control mechanism: Setuid and Setgid
2) T1098.004: Account Manipulation: SSH Authorized keys
3) T1136.001: Create Account: local Account

**Recommendations: 
1) Enforce 'nosuid' mounts: mount the directories where users have write access with the 'nosuid' flag to prevent unauthorized SUID binaries from executing.
2) Implement file integrity monitoring: Configure active FIM alerts using osquery or sysmon to immediately detect modifications to critical authentical files
3) Restrict local account creation and SSH keys: centralize authentication using a directory service to prevent local account creation. 

