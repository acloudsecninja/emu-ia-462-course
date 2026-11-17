-- SUID/SGID binaries (T1548.001)
SELECT path, username, groupname, permissions FROM suid_bin;
-- SSH authorized_keys (T1098.004)
SELECT u.username, a.key_file, a.algorithm, a.comment FROM users u CROSS JOIN authorized_keys a USING (uid);
-- Critical auth files (T1098 / T1136)
SELECT path, sha256 FROM hash WHERE path IN ('/etc/passwd', '/etc/shadow', '/etc/sudoers');
-- Loaded kernel modules (T1547.006 / T1014)
SELECT name FROM kernel_modules;
